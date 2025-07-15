import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/constants/validation_rules.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../shared/widgets/password_confirmation_dialog.dart';
import '../../dashboard/ui/dashboard_scaffold.dart';
import '../../../core/services/audit_log_service.dart';

// Provider for users data (same as in users_page.dart)
final usersDataProvider =
    StreamProvider<Map<String, List<QueryDocumentSnapshot>>>((ref) {
      return Stream.fromFuture(
        Future.wait([
          FirebaseFirestore.instance.collection('users').get(),
          FirebaseFirestore.instance.collection('pending_users').get(),
        ]).then(
          (results) => {'active': results[0].docs, 'pending': results[1].docs},
        ),
      );
    });

class EditUserPage extends ConsumerStatefulWidget {
  final String userId;
  final bool isPending;

  const EditUserPage({super.key, required this.userId, this.isPending = false});

  @override
  ConsumerState<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends ConsumerState<EditUserPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for editable fields
  final _displayNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _departmentController = TextEditingController();
  final _designationController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactPhoneController = TextEditingController();

  // User data
  Map<String, dynamic>? _userData;
  UserRole? _selectedRole;
  String? _selectedGender;
  DateTime? _selectedDateOfBirth;
  DateTime? _selectedJoiningDate;
  bool? _isActive;
  String? _selectedReportingManagerId;
  String? _selectedHiringManagerId;
  List<Map<String, dynamic>> _availableManagers = [];

  // State
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _hasChanges = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAvailableManagers();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _employeeIdController.dispose();
    _departmentController.dispose();
    _designationController.dispose();
    _addressController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      currentPath: '/admin/users/edit/${widget.userId}',
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading user data...'),
          ],
        ),
      );
    }

    if (_userData == null) {
      return _buildErrorState('User not found');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(theme),
          const SizedBox(height: 32),

          // Content
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;
                return isWide
                    ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Summary Card
                        Expanded(flex: 1, child: _buildUserSummaryCard(theme)),
                        const SizedBox(width: 24),

                        // Edit Form
                        Expanded(flex: 2, child: _buildEditForm(theme)),
                      ],
                    )
                    : Column(
                      children: [
                        _buildUserSummaryCard(theme),
                        const SizedBox(height: 24),
                        _buildEditForm(theme),
                      ],
                    );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.go('/admin/users'),
          icon: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isPending ? 'Edit Pending User' : 'Edit User',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_userData != null)
                Text(
                  _userData!['displayName'] ??
                      _userData!['email'] ??
                      'Unknown User',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        if (_hasChanges) ...[
          OutlinedButton(onPressed: _resetForm, child: const Text('Reset')),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: _isSubmitting ? null : _saveChanges,
            icon:
                _isSubmitting
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.save),
            label: Text(_isSubmitting ? 'Saving...' : 'Save Changes'),
          ),
        ],
      ],
    );
  }

  Widget _buildUserSummaryCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'User Summary',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Avatar and basic info
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    (_userData!['displayName'] ?? _userData!['email'] ?? '?')[0]
                        .toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userData!['displayName'] ?? 'No Name',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _userData!['email'] ?? 'No Email',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (_userData!['employeeId'] != null)
                        Text(
                          'ID: ${_userData!['employeeId']}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Status and role info
            _buildInfoRow(
              'Status',
              widget.isPending
                  ? 'Pending'
                  : (_isActive == true ? 'Active' : 'Inactive'),
              widget.isPending
                  ? Colors.orange
                  : (_isActive == true ? Colors.green : Colors.red),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Role',
              _formatRole(_userData!['role'] ?? 'employee'),
              theme.colorScheme.primary,
            ),
            if (_userData!['department'] != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                'Department',
                _userData!['department'],
                theme.colorScheme.onSurfaceVariant,
              ),
            ],
            if (_userData!['designation'] != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                'Designation',
                _userData!['designation'],
                theme.colorScheme.onSurfaceVariant,
              ),
            ],

            const SizedBox(height: 24),

            // Timestamps
            if (_userData!['createdAt'] != null) ...[
              _buildInfoRow(
                'Created',
                _formatDate(_userData!['createdAt']),
                theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
            ],
            if (_userData!['updatedAt'] != null)
              _buildInfoRow(
                'Last Updated',
                _formatDate(_userData!['updatedAt']),
                theme.colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Edit User Information',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Consumer(
                builder: (context, ref, child) {
                  return ref
                      .watch(isSuperAdminProvider)
                      .when(
                        data:
                            (isSuperAdmin) => Text(
                              isSuperAdmin
                                  ? 'As a super admin, your changes will be applied immediately.'
                                  : 'Changes will be applied immediately. Use caution when editing user information.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        loading:
                            () => Text(
                              'Changes will be applied immediately. Use caution when editing user information.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        error:
                            (_, __) => Text(
                              'Changes will be applied immediately. Use caution when editing user information.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                      );
                },
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Basic Information Section
              _buildSectionHeader('Basic Information', theme),
              const SizedBox(height: 16),

              // Display Name
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Full name is required';
                  }
                  if (value.trim().length < ValidationRules.minNameLength) {
                    return 'Name must be at least ${ValidationRules.minNameLength} characters';
                  }
                  if (!RegExp(
                    ValidationRules.namePattern,
                  ).hasMatch(value.trim())) {
                    return 'Please enter a valid name';
                  }
                  return null;
                },
                onChanged: (_) => _onFieldChanged(),
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(
                    ValidationRules.emailPattern,
                  ).hasMatch(value.trim())) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                onChanged: (_) => _onFieldChanged(),
              ),
              const SizedBox(height: 16),

              // Employee ID (read-only for existing users)
              TextFormField(
                controller: _employeeIdController,
                decoration: const InputDecoration(
                  labelText: 'Employee ID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                readOnly: !widget.isPending,
                validator:
                    widget.isPending
                        ? (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Employee ID is required';
                          }
                          return null;
                        }
                        : null,
                onChanged: widget.isPending ? (_) => _onFieldChanged() : null,
              ),
              const SizedBox(height: 16),

              // Phone Number
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (!RegExp(
                      ValidationRules.phonePattern,
                    ).hasMatch(value.trim())) {
                      return 'Please enter a valid phone number';
                    }
                  }
                  return null;
                },
                onChanged: (_) => _onFieldChanged(),
              ),
              const SizedBox(height: 24),

              // Work Information Section
              _buildSectionHeader('Work Information', theme),
              const SizedBox(height: 16),

              // Role Selection
              Consumer(
                builder: (context, ref, child) {
                  return ref
                      .watch(isSuperAdminProvider)
                      .when(
                        data: (isSuperAdmin) {
                          // If editing a super admin user and current user is not super admin, make it read-only
                          if (_selectedRole == UserRole.sa && !isSuperAdmin) {
                            return TextFormField(
                              initialValue: _formatRole('sa'),
                              decoration: const InputDecoration(
                                labelText: 'Role *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.work),
                                suffixIcon: Icon(
                                  Icons.lock,
                                  color: Colors.grey,
                                ),
                              ),
                              readOnly: true,
                              style: const TextStyle(color: Colors.grey),
                            );
                          }

                          // Get available roles based on current user permissions
                          final availableRoles =
                              isSuperAdmin
                                  ? UserRole.values
                                      .where(
                                        (role) => role != UserRole.inactive,
                                      )
                                      .toList()
                                  : UserRole.values
                                      .where(
                                        (role) =>
                                            role != UserRole.sa &&
                                            role != UserRole.inactive,
                                      )
                                      .toList();

                          return DropdownButtonFormField<UserRole>(
                            value: _selectedRole,
                            decoration: const InputDecoration(
                              labelText: 'Role *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.work),
                            ),
                            items:
                                availableRoles
                                    .map(
                                      (role) => DropdownMenuItem(
                                        value: role,
                                        child: Text(role.displayName),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value;
                                _onFieldChanged();
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a role';
                              }
                              return null;
                            },
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error:
                            (error, stack) => DropdownButtonFormField<UserRole>(
                              value: _selectedRole,
                              decoration: const InputDecoration(
                                labelText: 'Role *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.work),
                              ),
                              items:
                                  UserRole.values
                                      .where(
                                        (role) =>
                                            role != UserRole.sa &&
                                            role != UserRole.inactive,
                                      )
                                      .map(
                                        (role) => DropdownMenuItem(
                                          value: role,
                                          child: Text(role.displayName),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedRole = value;
                                  _onFieldChanged();
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a role';
                                }
                                return null;
                              },
                            ),
                      );
                },
              ),
              const SizedBox(height: 16),

              // Department
              TextFormField(
                controller: _departmentController,
                decoration: const InputDecoration(
                  labelText: 'Department',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                onChanged: (_) => _onFieldChanged(),
              ),
              const SizedBox(height: 16),

              // Designation
              TextFormField(
                controller: _designationController,
                decoration: const InputDecoration(
                  labelText: 'Designation',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work_outline),
                ),
                onChanged: (_) => _onFieldChanged(),
              ),
              const SizedBox(height: 16),

              // Status (for existing users)
              if (!widget.isPending)
                CheckboxListTile(
                  title: const Text('Active User'),
                  subtitle: const Text('Uncheck to deactivate this user'),
                  value: _isActive ?? true,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value ?? true;
                      _onFieldChanged();
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),

              const SizedBox(height: 24),

              // Management Section
              _buildSectionHeader('Management', theme),
              const SizedBox(height: 8),
              Text(
                'Assign reporting and hiring managers for this employee',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 16),

              // Reporting Manager
              DropdownButtonFormField<String>(
                value:
                    _availableManagers.any(
                          (m) => m['uid'] == _selectedReportingManagerId,
                        )
                        ? _selectedReportingManagerId
                        : null,
                decoration: const InputDecoration(
                  labelText: 'Reporting Manager',
                  hintText: 'Select reporting manager',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.supervisor_account),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('No reporting manager'),
                  ),
                  ..._availableManagers
                      .where(
                        (manager) =>
                            manager['uid'] != null &&
                            manager['displayName'] != null,
                      )
                      .map((manager) {
                        final managerName = manager['displayName'] ?? 'Unknown';
                        final employeeId = manager['employeeId'] ?? '';
                        final displayText =
                            employeeId.isNotEmpty
                                ? '$managerName (ID: $employeeId)'
                                : managerName;

                        return DropdownMenuItem<String>(
                          value: manager['uid'],
                          child: Text(
                            displayText,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      })
                      .toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedReportingManagerId = value;
                    _onFieldChanged();
                  });
                },
              ),
              const SizedBox(height: 16),

              // Hiring Manager
              DropdownButtonFormField<String>(
                value:
                    _availableManagers.any(
                          (m) => m['uid'] == _selectedHiringManagerId,
                        )
                        ? _selectedHiringManagerId
                        : null,
                decoration: const InputDecoration(
                  labelText: 'Hiring Manager',
                  hintText: 'Select hiring manager (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_add),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('No hiring manager'),
                  ),
                  ..._availableManagers
                      .where(
                        (manager) =>
                            manager['uid'] != null &&
                            manager['displayName'] != null,
                      )
                      .map((manager) {
                        final managerName = manager['displayName'] ?? 'Unknown';
                        final employeeId = manager['employeeId'] ?? '';
                        final displayText =
                            employeeId.isNotEmpty
                                ? '$managerName (ID: $employeeId)'
                                : managerName;

                        return DropdownMenuItem<String>(
                          value: manager['uid'],
                          child: Text(
                            displayText,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      })
                      .toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedHiringManagerId = value;
                    _onFieldChanged();
                  });
                },
              ),

              const SizedBox(height: 24),

              // Personal Information Section
              _buildSectionHeader('Personal Information', theme),
              const SizedBox(height: 16),

              // Gender
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                  DropdownMenuItem(
                    value: 'Prefer not to say',
                    child: Text('Prefer not to say'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                    _onFieldChanged();
                  });
                },
              ),
              const SizedBox(height: 16),

              // Date of Birth
              _buildDateField(
                label: 'Date of Birth',
                selectedDate: _selectedDateOfBirth,
                onDateSelected: (date) {
                  setState(() {
                    _selectedDateOfBirth = date;
                    _onFieldChanged();
                  });
                },
                lastDate: DateTime.now().subtract(
                  const Duration(days: 365 * 16),
                ), // Minimum 16 years old
              ),
              const SizedBox(height: 16),

              // Joining Date
              _buildDateField(
                label: 'Joining Date',
                selectedDate: _selectedJoiningDate,
                onDateSelected: (date) {
                  setState(() {
                    _selectedJoiningDate = date;
                    _onFieldChanged();
                  });
                },
                firstDate: DateTime(2000),
                lastDate: DateTime.now().add(
                  const Duration(days: 365),
                ), // Can be future date
              ),
              const SizedBox(height: 16),

              // Address
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 3,
                onChanged: (_) => _onFieldChanged(),
              ),
              const SizedBox(height: 24),

              // Emergency Contact Section
              _buildSectionHeader('Emergency Contact', theme),
              const SizedBox(height: 16),

              // Emergency Contact Name
              TextFormField(
                controller: _emergencyContactNameController,
                decoration: const InputDecoration(
                  labelText: 'Emergency Contact Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.contact_emergency),
                ),
                onChanged: (_) => _onFieldChanged(),
              ),
              const SizedBox(height: 16),

              // Emergency Contact Phone
              TextFormField(
                controller: _emergencyContactPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Emergency Contact Phone',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_in_talk),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (!RegExp(
                      ValidationRules.phonePattern,
                    ).hasMatch(value.trim())) {
                      return 'Please enter a valid phone number';
                    }
                  }
                  return null;
                },
                onChanged: (_) => _onFieldChanged(),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go('/admin/users'),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed:
                          _hasChanges && !_isSubmitting ? _saveChanges : null,
                      icon:
                          _isSubmitting
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.save),
                      label: Text(_isSubmitting ? 'Saving...' : 'Save Changes'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime) onDateSelected,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: firstDate ?? DateTime(1950),
          lastDate: lastDate ?? DateTime.now(),
        );
        if (date != null) {
          onDateSelected(date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          selectedDate != null
              ? _formatDate(selectedDate.toIso8601String())
              : 'Select date',
          style: TextStyle(
            color: selectedDate != null ? null : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text('Error', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.go('/admin/users'),
            child: const Text('Back to Users'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _formatRole(String role) {
    switch (role) {
      case 'sa':
        return 'Super Admin';
      case 'admin':
        return 'Admin';
      case 'hr':
        return 'HR';
      case 'manager':
        return 'Manager';
      case 'team_lead':
        return 'Team Lead';
      case 'senior_employee':
        return 'Senior Employee';
      case 'employee':
        return 'Employee';
      case 'contractor':
        return 'Contractor';
      case 'intern':
        return 'Intern';
      case 'vendor':
        return 'Vendor';
      case 'inactive':
        return 'Inactive';
      default:
        return role;
    }
  }

  String _formatDate(dynamic dateValue) {
    try {
      DateTime date;

      if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else if (dateValue is Timestamp) {
        date = dateValue.toDate();
      } else {
        return dateValue.toString();
      }

      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateValue.toString();
    }
  }

  void _onFieldChanged() {
    setState(() {
      _hasChanges = _checkForChanges();
      _errorMessage = null; // Clear error when user makes changes
    });
  }

  bool _checkForChanges() {
    if (_userData == null) return false;

    final currentData = _getCurrentFormData();

    for (final key in currentData.keys) {
      final originalValue = _userData![key];
      final currentValue = currentData[key];

      if (originalValue != currentValue) {
        return true;
      }
    }

    return false;
  }

  Map<String, dynamic> _getCurrentFormData() {
    return {
      'displayName': _displayNameController.text.trim(),
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'employeeId': _employeeIdController.text.trim(),
      'department': _departmentController.text.trim(),
      'designation': _designationController.text.trim(),
      'role': _selectedRole?.value,
      'gender': _selectedGender,
      'dateOfBirth': _selectedDateOfBirth?.toIso8601String(),
      'joiningDate': _selectedJoiningDate?.toIso8601String(),
      'address': _addressController.text.trim(),
      'emergencyContactName': _emergencyContactNameController.text.trim(),
      'emergencyContactPhone': _emergencyContactPhoneController.text.trim(),
      'isActive': _isActive,
      'reportingManagerId': _selectedReportingManagerId,
      'hiringManagerId': _selectedHiringManagerId,
    };
  }

  Future<void> _loadUserData() async {
    try {
      setState(() => _isLoading = true);

      final collection = widget.isPending ? 'pending_users' : 'users';
      final doc =
          await FirebaseFirestore.instance
              .collection(collection)
              .doc(widget.userId)
              .get();

      if (!doc.exists) {
        setState(() {
          _userData = null;
          _isLoading = false;
        });
        return;
      }

      final data = doc.data()!;
      setState(() {
        _userData = data;

        // Populate form fields
        _displayNameController.text = data['displayName'] ?? '';
        _firstNameController.text = data['firstName'] ?? '';
        _lastNameController.text = data['lastName'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phoneNumber'] ?? data['phone'] ?? '';
        _employeeIdController.text = data['employeeId'] ?? '';
        _departmentController.text = data['department'] ?? '';
        _designationController.text =
            data['designation'] ?? data['position'] ?? '';
        _addressController.text = data['address'] ?? '';
        _emergencyContactNameController.text =
            data['emergencyContactName'] ?? '';
        _emergencyContactPhoneController.text =
            data['emergencyContactPhone'] ?? data['emergencyContact'] ?? '';

        // Set dropdown values
        final roleString = data['role'] ?? 'employee';
        _selectedRole = UserRole.fromString(roleString);

        _selectedGender = data['gender'];
        _isActive = data['isActive'] ?? true;

        // Set dates
        if (data['dateOfBirth'] != null) {
          try {
            _selectedDateOfBirth = DateTime.parse(data['dateOfBirth']);
          } catch (e) {
            // Handle invalid date format
          }
        }

        if (data['joiningDate'] != null) {
          try {
            _selectedJoiningDate = DateTime.parse(data['joiningDate']);
          } catch (e) {
            // Handle invalid date format
          }
        }

        // Set manager values
        _selectedReportingManagerId = data['reportingManagerId'];
        _selectedHiringManagerId = data['hiringManagerId'];

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load user data: $e';
        _isLoading = false;
      });
    }
  }

  void _resetForm() {
    setState(() {
      _hasChanges = false;
      _errorMessage = null;
    });
    _loadUserData(); // Reload original data
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    // Update the changes status before checking
    _hasChanges = _checkForChanges();

    // Check if there are any changes
    if (!_hasChanges) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No changes to save'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show password confirmation dialog before saving
    final confirmed = await showPasswordConfirmationDialog(
      context: context,
      title: 'Confirm User Update',
      message:
          'You are about to update user information for ${_displayNameController.text}. This action requires password verification for security.',
      actionButtonText: 'Update User',
      actionButtonColor: Theme.of(context).colorScheme.primary,
      icon: Icons.edit,
      onConfirmed: () {}, // Empty callback since we handle the result below
    );

    if (confirmed) {
      // Password was verified successfully, proceed with save
      await _performSave();
    }
  }

  Future<void> _performSave() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedData = <String, dynamic>{
        'displayName': _displayNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phoneNumber':
            _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
        'role': _selectedRole?.value,
        'department':
            _departmentController.text.trim().isEmpty
                ? null
                : _departmentController.text.trim(),
        'designation':
            _designationController.text.trim().isEmpty
                ? null
                : _designationController.text.trim(),
        'dateOfBirth': _selectedDateOfBirth?.toIso8601String(),
        'address':
            _addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim(),
        'emergencyContactName':
            _emergencyContactNameController.text.trim().isEmpty
                ? null
                : _emergencyContactNameController.text.trim(),
        'emergencyContactPhone':
            _emergencyContactPhoneController.text.trim().isEmpty
                ? null
                : _emergencyContactPhoneController.text.trim(),
        'isActive': _isActive,
        'updatedAt': DateTime.now().toIso8601String(),
        'reportingManagerId': _selectedReportingManagerId,
        'hiringManagerId': _selectedHiringManagerId,
      };

      // Update user in Firestore
      final collection = widget.isPending ? 'pending_users' : 'users';
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(widget.userId)
          .update(updatedData);

      // Log the activity
      await FirebaseFirestore.instance.collection('activity_logs').add({
        'userId': widget.userId,
        'userName': updatedData['displayName'] ?? 'Unknown User',
        'action': 'user_updated',
        'description': 'User information updated by admin',
        'timestamp': FieldValue.serverTimestamp(),
        'metadata': {
          'updatedFields': updatedData.keys.toList(),
          'isPending': widget.isPending,
        },
      });

      // Audit log for user update
      final currentUser = ref.read(currentUserProvider).value;
      await AuditLogService().logEvent(
        action: 'ADMIN_UPDATE_USER',
        userId: currentUser?.uid,
        userName: currentUser?.displayName ?? currentUser?.email ?? 'Unknown',
        userEmail: currentUser?.email,
        status: 'success',
        targetType: 'user',
        targetId: widget.userId,
        details: {
          'updatedUserEmail': updatedData['email'],
          'updatedUserDisplayName': updatedData['displayName'],
          'updatedUserRole': updatedData['role'],
          'updatedFields': updatedData.keys.toList(),
          'isPending': widget.isPending,
          'department': updatedData['department'],
          'designation': updatedData['designation'],
          'isActive': updatedData['isActive'],
        },
      );

      // Invalidate the users data provider to refresh the list
      ref.invalidate(usersDataProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User ${_displayNameController.text} updated successfully',
            ),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () {
                context.go('/admin/users');
              },
            ),
          ),
        );

        // Navigate back to users page
        context.go('/admin/users');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadAvailableManagers() async {
    try {
      final authService = ref.read(authServiceProvider);
      final managers = await authService.getActiveUsersForSelection();
      if (mounted) {
        setState(() {
          _availableManagers = managers;
          // Validate manager selections after loading managers
          _validateManagerSelections();
        });
      }
    } catch (e) {
      print('❌ Error loading managers: $e');
      // Handle error silently
    }
  }

  void _validateManagerSelections() {
    // Get list of available manager IDs
    final availableManagerIds = _availableManagers.map((m) => m['uid']).toSet();

    // Validate reporting manager
    if (_selectedReportingManagerId != null &&
        !availableManagerIds.contains(_selectedReportingManagerId)) {
      print(
        '⚠️ Invalid reporting manager ID: $_selectedReportingManagerId, resetting to null',
      );
      _selectedReportingManagerId = null;
    }

    // Validate hiring manager
    if (_selectedHiringManagerId != null &&
        !availableManagerIds.contains(_selectedHiringManagerId)) {
      print(
        '⚠️ Invalid hiring manager ID: $_selectedHiringManagerId, resetting to null',
      );
      _selectedHiringManagerId = null;
    }
  }
}
