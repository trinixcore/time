import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../dashboard/ui/dashboard_scaffold.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _firebaseService = FirebaseService();

  // Controllers for editable fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyContactNameController = TextEditingController();
  final _addressController = TextEditingController();

  // User data
  UserModel? _currentUser;
  Map<String, dynamic>? _userData;
  String? _selectedGender;
  DateTime? _selectedDateOfBirth;

  // Read-only fields
  String? _department;
  String? _designation;
  String? _hiringManagerName;
  String? _reportingManagerName;
  String? _employeeId;
  String? _email;
  DateTime? _joiningDate;

  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emergencyContactController.dispose();
    _emergencyContactNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      currentPath: '/profile',
      child: _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading profile...'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          _buildPageHeader(theme),
          const SizedBox(height: 32),

          // Profile Content
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;
                return isWide
                    ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Summary Card
                        Expanded(
                          flex: 1,
                          child: _buildProfileSummaryCard(theme),
                        ),
                        const SizedBox(width: 24),

                        // Profile Form
                        Expanded(flex: 2, child: _buildProfileForm(theme)),
                      ],
                    )
                    : Column(
                      children: [
                        _buildProfileSummaryCard(theme),
                        const SizedBox(height: 24),
                        _buildProfileForm(theme),
                      ],
                    );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Profile',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your personal information and account settings',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimary.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.person,
            size: 64,
            color: theme.colorScheme.onPrimary.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSummaryCard(ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Avatar and Basic Info
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      _userData != null
                          ? '${_userData!['firstName']?.substring(0, 1) ?? ''}${_userData!['lastName']?.substring(0, 1) ?? ''}'
                          : 'U',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _userData != null
                        ? '${_userData!['firstName'] ?? ''} ${_userData!['lastName'] ?? ''}'
                        : 'User Name',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _designation ?? 'Position',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Company Information (Read-only)
            Text(
              'Company Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildInfoRow(theme, 'Employee ID', _employeeId ?? 'N/A'),
            _buildInfoRow(theme, 'Email', _email ?? 'N/A'),
            _buildInfoRow(theme, 'Department', _department ?? 'N/A'),
            _buildInfoRow(theme, 'Designation', _designation ?? 'N/A'),
            _buildInfoRow(theme, 'Hiring Manager', _hiringManagerName ?? 'N/A'),
            _buildInfoRow(
              theme,
              'Reporting Manager',
              _reportingManagerName ?? 'N/A',
            ),
            if (_joiningDate != null)
              _buildInfoRow(theme, 'Joining Date', _formatDate(_joiningDate!)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildProfileForm(ThemeData theme) {
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
                    'Edit Profile',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Consumer(
                    builder: (context, ref, child) {
                      return ref
                          .watch(isSuperAdminProvider)
                          .when(
                            data:
                                (isSuperAdmin) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isSuperAdmin
                                            ? theme
                                                .colorScheme
                                                .secondaryContainer
                                            : theme
                                                .colorScheme
                                                .primaryContainer,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    isSuperAdmin
                                        ? 'Direct Update'
                                        : 'Requires Approval',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color:
                                          isSuperAdmin
                                              ? theme
                                                  .colorScheme
                                                  .onSecondaryContainer
                                              : theme
                                                  .colorScheme
                                                  .onPrimaryContainer,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            loading:
                                () => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    'Requires Approval',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color:
                                          theme.colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            error:
                                (_, __) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    'Requires Approval',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color:
                                          theme.colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                          );
                    },
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
                                  ? 'Update your personal information. As a super admin, your changes will be applied immediately.'
                                  : 'Update your personal information. Changes will require approval from your hiring manager.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        loading:
                            () => Text(
                              'Update your personal information. Changes will require approval from your hiring manager.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        error:
                            (_, __) => Text(
                              'Update your personal information. Changes will require approval from your hiring manager.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                      );
                },
              ),
              const SizedBox(height: 24),

              // Form Fields
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'First name is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Last name is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          ['Male', 'Female', 'Other', 'Prefer not to say']
                              .map(
                                (gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (value) => setState(() => _selectedGender = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: () => _selectDateOfBirth(),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDateOfBirth != null
                        ? _formatDate(_selectedDateOfBirth!)
                        : 'Select date',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Emergency Contact Section
              Text(
                'Emergency Contact',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _emergencyContactNameController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _emergencyContactController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: Consumer(
                  builder: (context, ref, child) {
                    return ref
                        .watch(isSuperAdminProvider)
                        .when(
                          data:
                              (isSuperAdmin) => FilledButton.icon(
                                onPressed:
                                    _isSubmitting ? null : _submitProfileUpdate,
                                icon:
                                    _isSubmitting
                                        ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : Icon(
                                          isSuperAdmin
                                              ? Icons.save
                                              : Icons.send,
                                        ),
                                label: Text(
                                  _isSubmitting
                                      ? 'Submitting...'
                                      : isSuperAdmin
                                      ? 'Update Profile'
                                      : 'Submit for Approval',
                                ),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              ),
                          loading:
                              () => FilledButton.icon(
                                onPressed:
                                    _isSubmitting ? null : _submitProfileUpdate,
                                icon:
                                    _isSubmitting
                                        ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Icon(Icons.send),
                                label: Text(
                                  _isSubmitting
                                      ? 'Submitting...'
                                      : 'Submit for Approval',
                                ),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              ),
                          error:
                              (_, __) => FilledButton.icon(
                                onPressed:
                                    _isSubmitting ? null : _submitProfileUpdate,
                                icon:
                                    _isSubmitting
                                        ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Icon(Icons.send),
                                label: Text(
                                  _isSubmitting
                                      ? 'Submitting...'
                                      : 'Submit for Approval',
                                ),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              ),
                        );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateOfBirth() async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          _selectedDateOfBirth ??
          DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 16)),
    );
    if (date != null) {
      setState(() => _selectedDateOfBirth = date);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        _userData = userData;
        _currentUser = UserModel.fromJson(userData);

        // Handle firstName and lastName with fallback to displayName
        String firstName = userData['firstName'] ?? '';
        String lastName = userData['lastName'] ?? '';

        // If firstName/lastName are empty but displayName exists, split it
        if ((firstName.isEmpty || lastName.isEmpty) &&
            userData['displayName'] != null) {
          final displayName = userData['displayName'] as String;
          final nameParts = displayName.trim().split(' ');
          if (firstName.isEmpty) {
            firstName = nameParts.isNotEmpty ? nameParts.first : '';
          }
          if (lastName.isEmpty) {
            lastName =
                nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
          }
        }

        // Populate editable fields
        _firstNameController.text = firstName;
        _lastNameController.text = lastName;
        _phoneController.text =
            userData['phoneNumber'] ?? userData['phone'] ?? '';

        // Handle emergency contact with fallback
        _emergencyContactController.text =
            userData['emergencyContact'] ??
            userData['emergencyContactPhone'] ??
            '';
        _emergencyContactNameController.text =
            userData['emergencyContactName'] ?? '';
        _addressController.text = userData['address'] ?? '';
        _selectedGender = userData['gender'];

        if (userData['dateOfBirth'] != null) {
          _selectedDateOfBirth = DateTime.parse(userData['dateOfBirth']);
        }

        // Set read-only fields
        _department = userData['department'];
        _designation = userData['designation'] ?? userData['position'];
        _hiringManagerName = userData['hiringManagerName'];
        _reportingManagerName = userData['reportingManagerName'];
        _employeeId = userData['employeeId'];
        _email = _currentUser?.email;

        if (userData['joiningDate'] != null) {
          _joiningDate = DateTime.parse(userData['joiningDate']);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submitProfileUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Check if user is super admin
      final isSuperAdmin = await ref.read(isSuperAdminProvider.future);

      // Prepare update data
      final updateData = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'emergencyContact': _emergencyContactController.text.trim(),
        'emergencyContactName': _emergencyContactNameController.text.trim(),
        'address': _addressController.text.trim(),
        'gender': _selectedGender,
        'dateOfBirth': _selectedDateOfBirth?.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (isSuperAdmin) {
        // Super admin can update directly without approval
        await _updateProfileDirectly(updateData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Reload the profile to show updated data
          await _loadUserProfile();
        }
      } else {
        // Regular users need approval
        await _createApprovalRequest(updateData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile update request submitted for approval'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error submitting update: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _updateProfileDirectly(Map<String, dynamic> updateData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Update user document directly
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update(updateData);

    // Log the activity
    await FirebaseFirestore.instance.collection('activity_logs').add({
      'userId': user.uid,
      'userName': '${updateData['firstName']} ${updateData['lastName']}',
      'action': 'profile_updated',
      'description': 'Super admin updated their profile directly',
      'timestamp': FieldValue.serverTimestamp(),
      'metadata': {'updatedFields': updateData.keys.toList()},
    });
  }

  Future<void> _createApprovalRequest(Map<String, dynamic> updateData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Get hiring manager ID from user document
    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

    final userData = userDoc.data()!;
    final hiringManagerId = userData['hiringManagerId'];

    if (hiringManagerId == null) {
      throw Exception('No hiring manager assigned for approval');
    }

    // Create approval request
    await FirebaseFirestore.instance
        .collection('profile_approval_requests')
        .add({
          'userId': user.uid,
          'userName':
              '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}',
          'employeeId': _employeeId,
          'department': _department,
          'designation': _designation,
          'approverId': hiringManagerId,
          'approverName': _hiringManagerName,
          'requestedChanges': updateData,
          'currentData': {
            'firstName': userData['firstName'],
            'lastName': userData['lastName'],
            'phoneNumber': userData['phoneNumber'] ?? userData['phone'],
            'emergencyContact': userData['emergencyContact'],
            'emergencyContactName': userData['emergencyContactName'],
            'address': userData['address'],
            'gender': userData['gender'],
            'dateOfBirth': userData['dateOfBirth'],
          },
          'status': 'pending',
          'requestedAt': FieldValue.serverTimestamp(),
          'comments': '',
        });
  }
}
