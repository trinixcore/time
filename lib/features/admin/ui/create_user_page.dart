import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../dashboard/ui/dashboard_scaffold.dart';
import 'dart:math';
import '../../../core/services/audit_log_service.dart';
import '../../../core/models/candidate_model.dart';
import '../../letters/services/candidate_service.dart';
import '../../letters/providers/candidate_providers.dart';
import 'package:collection/collection.dart';

class CreateUserPage extends ConsumerStatefulWidget {
  final Candidate? candidate;

  const CreateUserPage({super.key, this.candidate});

  @override
  ConsumerState<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends ConsumerState<CreateUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _employeeIdController = TextEditingController();

  UserRole _selectedRole = UserRole.employee;
  bool _isLoading = false;
  String? _generatedPassword;
  String? _selectedReportingManagerId;
  String? _selectedHiringManagerId;
  String? _selectedDepartment;
  String? _selectedDesignation;
  String? _selectedCandidateId; // New field for candidate dropdown
  Candidate?
  _selectedCandidate; // Add this to store the selected candidate object
  List<Map<String, dynamic>> _availableManagers = [];
  List<String> _departments = [];
  List<String> _designations = [];

  @override
  void initState() {
    super.initState();
    _generateEmployeeId();
    _generatePassword();
    _loadAvailableManagers();
    _loadDepartmentsAndDesignations();
    _prefillCandidateData();
  }

  void _prefillCandidateData() {
    if (widget.candidate != null) {
      final candidate = widget.candidate!;
      _displayNameController.text = candidate.fullName;
      _emailController.text = candidate.email;
      _selectedDepartment = candidate.department;
      _selectedDesignation = candidate.designation;
      _selectedCandidateId = candidate.id; // Set the selected candidate ID
      _selectedCandidate = candidate; // Store the candidate object

      // Set default role based on candidate's designation or department
      if (candidate.designation?.toLowerCase().contains('manager') == true ||
          candidate.designation?.toLowerCase().contains('lead') == true) {
        _selectedRole = UserRole.tl;
      } else {
        _selectedRole = UserRole.employee;
      }
    }
  }

  void _onCandidateSelected(Candidate? candidate) {
    if (candidate != null) {
      setState(() {
        _displayNameController.text = candidate.fullName;
        _emailController.text = candidate.email;
        _selectedDepartment = candidate.department;
        _selectedDesignation = candidate.designation;
        _selectedCandidateId =
            candidate.candidateId; // Use candidateId field, not document ID
        _selectedCandidate = candidate; // Store the candidate object

        // Set default role based on candidate's designation or department
        if (candidate.designation?.toLowerCase().contains('manager') == true ||
            candidate.designation?.toLowerCase().contains('lead') == true) {
          _selectedRole = UserRole.tl;
        } else {
          _selectedRole = UserRole.employee;
        }
      });
    } else {
      // Clear form when no candidate is selected
      setState(() {
        _displayNameController.clear();
        _emailController.clear();
        _selectedDepartment = null;
        _selectedDesignation = null;
        _selectedCandidateId = null;
        _selectedCandidate = null; // Clear the candidate object
        _selectedRole = UserRole.employee;
      });
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableManagers() async {
    try {
      final authService = ref.read(authServiceProvider);
      final managers = await authService.getActiveUsersForSelection();
      print('🔍 Loaded ${managers.length} managers: $managers');
      if (mounted) {
        setState(() {
          _availableManagers = managers;
        });
      }
    } catch (e) {
      print('❌ Error loading managers: $e');
      // Handle error silently
    }
  }

  Future<void> _loadDepartmentsAndDesignations() async {
    try {
      final authService = ref.read(authServiceProvider);
      final departments = await authService.getDepartments();
      final designations = await authService.getDesignations();
      if (mounted) {
        setState(() {
          _departments = departments;
          _designations = designations;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _generateEmployeeId() {
    final currentYear = DateTime.now().year;
    _employeeIdController.text = 'TRX${currentYear}XXXXXX (Auto-generated)';
  }

  void _generatePassword() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@\$&';
    final random = DateTime.now().millisecondsSinceEpoch;
    var password = '';

    // Ensure at least one of each required character type
    password += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'[random % 26];
    password += 'abcdefghijklmnopqrstuvwxyz'[random % 26];
    password += '0123456789'[random % 10];
    password += '!@\$&'[random % 4];

    // Fill the rest randomly
    for (int i = 4; i < 12; i++) {
      password += chars[(random + i) % chars.length];
    }

    // Shuffle the password
    final passwordList = password.split('');
    for (int i = passwordList.length - 1; i > 0; i--) {
      final j = (random + i) % (i + 1);
      final temp = passwordList[i];
      passwordList[i] = passwordList[j];
      passwordList[j] = temp;
    }

    _generatedPassword = passwordList.join();
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final currentUser = ref.read(currentUserProvider).value;

      final createdUser = await authService.registerUser(
        email: _emailController.text.trim(),
        password: _generatedPassword!,
        displayName: _displayNameController.text.trim(),
        role: _selectedRole,
        createdBy: currentUser?.uid ?? 'unknown',
        department: _selectedDepartment,
        designation: _selectedDesignation,
        reportingManagerId: _selectedReportingManagerId,
        hiringManagerId: _selectedHiringManagerId,
        // Pass candidateId if available - use the actual candidateId field
        candidateId:
            widget.candidate?.candidateId ?? _selectedCandidate?.candidateId,
      );

      // If this is candidate onboarding, update candidate status
      if (widget.candidate != null || _selectedCandidate != null) {
        try {
          // Import the candidate service
          final candidateService = ref.read(candidateServiceProvider);
          final candidateId =
              widget.candidate?.id ??
              _selectedCandidate!.id; // Use document ID for service calls

          await candidateService.updateCandidateStatus(
            candidateId,
            'onboarded',
            updatedBy: currentUser?.uid,
          );

          // Assign employee ID to candidate
          await candidateService.assignEmployeeId(
            candidateId,
            createdUser.employeeId ?? '',
            createdUser.uid,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Candidate ${_displayNameController.text} successfully onboarded! Employee ID: ${createdUser.employeeId}',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        } catch (e) {
          print('Warning: Failed to update candidate status: $e');
          // Don't fail the user creation if candidate update fails
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'User created successfully! Employee ID: ${createdUser.employeeId}',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }

      // Show password dialog with actual employee ID
      _showPasswordDialog(createdUser.employeeId ?? 'N/A');

      // Audit log for user creation
      await AuditLogService().logEvent(
        action:
            (widget.candidate != null || _selectedCandidate != null)
                ? 'CANDIDATE_ONBOARDED'
                : 'ADMIN_CREATE_USER',
        userId: currentUser?.uid,
        userName: currentUser?.displayName ?? currentUser?.email ?? 'Unknown',
        userEmail: currentUser?.email,
        status: 'success',
        targetType: 'user',
        targetId: createdUser.uid,
        details: {
          'createdUserEmail': createdUser.email,
          'createdUserDisplayName': createdUser.displayName,
          'createdUserRole': createdUser.role.value,
          'createdUserEmployeeId': createdUser.employeeId,
          'department': createdUser.department,
          'position': createdUser.position,
          if (widget.candidate != null)
            'candidateId': widget.candidate!.candidateId,
          if (widget.candidate != null)
            'candidateName': widget.candidate!.fullName,
          if (_selectedCandidate != null)
            'selectedCandidateId': _selectedCandidate!.candidateId,
          if (_selectedCandidate != null)
            'selectedCandidateName': _selectedCandidate!.fullName,
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create user: $e'),
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

  void _showPasswordDialog(String actualEmployeeId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('User Created Successfully'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Employee: ${_displayNameController.text}'),
                Text('Email: ${_emailController.text}'),
                Text('Employee ID: $actualEmployeeId'),
                const SizedBox(height: 16),
                const Text(
                  'Temporary Password:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _generatedPassword!,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: _generatedPassword!),
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password copied to clipboard'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.copy),
                        tooltip: 'Copy password',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Employee Login Instructions:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1. Employee should use "Employee Login" on the login page\n'
                        '2. Enter Employee ID: $actualEmployeeId\n'
                        '3. Enter the temporary password above\n'
                        '4. They will be prompted to change password on first login',
                        style: TextStyle(color: Colors.blue[700]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Important: The employee must change this password on first login.',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  try {
                    final authService = ref.read(authServiceProvider);
                    final currentUser = ref.read(currentUserProvider).value;

                    await authService.markCredentialsShared(
                      employeeId: actualEmployeeId,
                      sharedBy: currentUser?.uid ?? 'unknown',
                    );

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Credentials marked as shared'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.of(context).pop();
                      context.go('/admin/users');
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to mark as shared: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Mark as Shared & Continue'),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/admin/users');
                },
                child: const Text('Continue Without Marking'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DashboardScaffold(
      currentPath: '/admin/users/create',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
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
                        widget.candidate != null || _selectedCandidate != null
                            ? 'Onboard Candidate'
                            : 'Create New User',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.candidate != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Converting candidate to employee: ${widget.candidate!.fullName}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ] else if (_selectedCandidate != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Converting candidate to employee: ${_selectedCandidate!.fullName}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Form
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.candidate != null || _selectedCandidate != null
                              ? 'Candidate Onboarding'
                              : 'Employee Information',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Candidate Selection Dropdown
                        Consumer(
                          builder: (context, ref, child) {
                            final candidatesAsync = ref.watch(
                              candidatesProvider,
                            );

                            return candidatesAsync.when(
                              data: (candidates) {
                                // Filter candidates that are not yet onboarded
                                final availableCandidates =
                                    candidates
                                        .where((c) => c.status != 'onboarded')
                                        .toList();

                                return DropdownButtonFormField<String>(
                                  value: _selectedCandidateId,
                                  decoration: const InputDecoration(
                                    labelText: 'Select Candidate (Optional)',
                                    hintText:
                                        'Choose a candidate to auto-fill form',
                                    prefixIcon: Icon(Icons.person_add),
                                    helperText:
                                        'Selecting a candidate will auto-populate the form fields',
                                  ),
                                  items: [
                                    const DropdownMenuItem<String>(
                                      value: null,
                                      child: Text('No candidate selected'),
                                    ),
                                    ...availableCandidates.map((candidate) {
                                      return DropdownMenuItem<String>(
                                        value:
                                            candidate
                                                .candidateId, // Use candidateId
                                        child: Text(
                                          '${candidate.fullName} (${candidate.email})',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                  onChanged: (value) {
                                    if (value == null) {
                                      _onCandidateSelected(null);
                                    } else {
                                      final selectedCandidate =
                                          availableCandidates.firstWhereOrNull(
                                            (c) => c.candidateId == value,
                                          );
                                      _onCandidateSelected(selectedCandidate);
                                    }
                                  },
                                );
                              },
                              loading: () => const LinearProgressIndicator(),
                              error:
                                  (error, stack) => Text(
                                    'Error loading candidates: $error',
                                    style: TextStyle(
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Display Name
                        TextFormField(
                          controller: _displayNameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name *',
                            hintText: 'Enter employee full name',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Full name is required';
                            }
                            if (value.trim().length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Email
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email Address *',
                            hintText: 'Enter employee email',
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Employee ID
                        TextFormField(
                          controller: _employeeIdController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Employee ID *',
                            hintText: 'Auto-generated on creation',
                            prefixIcon: Icon(Icons.badge),
                            helperText:
                                'Unique ID will be generated automatically',
                          ),
                          validator: (value) {
                            // No validation needed since it's auto-generated
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Role Selection
                        DropdownButtonFormField<UserRole>(
                          value: _selectedRole,
                          decoration: const InputDecoration(
                            labelText: 'Role *',
                            prefixIcon: Icon(Icons.work),
                          ),
                          items:
                              UserRole.values
                                  .where(
                                    (role) => role != UserRole.sa,
                                  ) // Only super admin can create super admin
                                  .map(
                                    (role) => DropdownMenuItem(
                                      value: role,
                                      child: Text(_formatRoleName(role)),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedRole = value;
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a role';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Department
                        DropdownButtonFormField<String>(
                          value: _selectedDepartment,
                          decoration: const InputDecoration(
                            labelText: 'Department',
                            hintText: 'Select department (optional)',
                            prefixIcon: Icon(Icons.business),
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('No department assigned'),
                            ),
                            ..._departments.map((department) {
                              return DropdownMenuItem<String>(
                                value: department,
                                child: Text(department),
                              );
                            }).toList(),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedDepartment = value;
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        // Designation
                        DropdownButtonFormField<String>(
                          value: _selectedDesignation,
                          decoration: const InputDecoration(
                            labelText: 'Designation',
                            hintText: 'Select designation (optional)',
                            prefixIcon: Icon(Icons.work_outline),
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('No designation assigned'),
                            ),
                            ..._designations.map((designation) {
                              return DropdownMenuItem<String>(
                                value: designation,
                                child: Text(designation),
                              );
                            }).toList(),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedDesignation = value;
                            });
                          },
                        ),

                        const SizedBox(height: 24),

                        // Manager Assignment Section
                        Text(
                          'Manager Assignment',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
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
                          value: _selectedReportingManagerId,
                          decoration: const InputDecoration(
                            labelText: 'Reporting Manager',
                            hintText: 'Select reporting manager',
                            prefixIcon: Icon(Icons.supervisor_account),
                          ),
                          items:
                              _availableManagers.map((manager) {
                                final managerName =
                                    manager['displayName'] ?? 'Unknown';
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
                              }).toList(),
                          onChanged: (value) {
                            print('🔄 Reporting manager selected: $value');
                            setState(() {
                              _selectedReportingManagerId = value;
                            });
                          },
                          validator: (value) {
                            // Optional field - no validation required
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Hiring Manager
                        DropdownButtonFormField<String>(
                          value: _selectedHiringManagerId,
                          decoration: const InputDecoration(
                            labelText: 'Hiring Manager',
                            hintText: 'Select hiring manager (optional)',
                            prefixIcon: Icon(Icons.person_add),
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('No hiring manager'),
                            ),
                            ..._availableManagers.map((manager) {
                              final managerName =
                                  manager['displayName'] ?? 'Unknown';
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
                            }).toList(),
                          ],
                          onChanged: (value) {
                            print('🔄 Hiring manager selected: $value');
                            setState(() {
                              _selectedHiringManagerId = value;
                            });
                          },
                          validator: (value) {
                            // Optional field, so no validation needed
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),

                        // Password Info
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: theme.colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Password Information',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '• A secure temporary password will be automatically generated\n'
                                '• The user will be required to change it on first login\n'
                                '• You will receive the password after user creation',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Create Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _createUser,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child:
                                _isLoading
                                    ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          widget.candidate != null ||
                                                  _selectedCandidate != null
                                              ? 'Onboarding Candidate...'
                                              : 'Creating User...',
                                        ),
                                      ],
                                    )
                                    : Text(
                                      widget.candidate != null ||
                                              _selectedCandidate != null
                                          ? 'Onboard Candidate'
                                          : 'Create User',
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRoleName(UserRole role) {
    switch (role) {
      case UserRole.sa:
        return 'Super Admin';
      case UserRole.admin:
        return 'Admin';
      case UserRole.tl:
        return 'Team Lead';
      case UserRole.se:
        return 'Senior Employee';
      case UserRole.hr:
        return 'HR';
      case UserRole.manager:
        return 'Manager';
      case UserRole.employee:
        return 'Employee';
      case UserRole.contractor:
        return 'Contractor';
      case UserRole.intern:
        return 'Intern';
      case UserRole.vendor:
        return 'Vendor';
      case UserRole.inactive:
        return 'Inactive';
    }
  }
}
