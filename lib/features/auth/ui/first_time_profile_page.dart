import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/constants/validation_rules.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/models/user_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/widgets/custom_loader.dart';
import '../../letters/services/candidate_service.dart';
import '../../../core/models/candidate_model.dart';

class FirstTimeProfilePage extends ConsumerStatefulWidget {
  const FirstTimeProfilePage({super.key});

  @override
  ConsumerState<FirstTimeProfilePage> createState() =>
      _FirstTimeProfilePageState();
}

class _FirstTimeProfilePageState extends ConsumerState<FirstTimeProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactPhoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedGender;
  String? _selectedDepartment;
  String? _selectedDesignation;
  DateTime? _selectedDateOfBirth;
  DateTime? _selectedJoiningDate;
  bool _isJoiningDateAutoPopulated =
      false; // Track if joining date was auto-populated
  bool _isPhoneNumberAutoPopulated =
      false; // Track if phone number was auto-populated

  List<String> _departments = [];
  List<String> _designations = [];
  Map<String, dynamic>? _reportingManager;
  Map<String, dynamic>? _hiringManager;
  Map<String, dynamic>? _currentUserData;

  @override
  void initState() {
    super.initState();
    // Load data after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    try {
      final authService = ref.read(authServiceProvider);

      // Load departments and designations
      final departments = await authService.getDepartments();
      final designations = await authService.getDesignations();

      // Load current user data
      final user = await ref.read(currentUserProvider.future);

      if (mounted) {
        setState(() {
          _departments = departments;
          _designations = designations;
          if (user != null) {
            _displayNameController.text = user.displayName ?? '';
            _phoneController.text = user.phoneNumber ?? '';
            // Pre-select department and designation if they exist
            _selectedDepartment = user.department ?? _selectedDepartment;
            _selectedDesignation = user.position ?? _selectedDesignation;
          }
        });

        // Load additional data from pending_users if user data is available
        if (user != null) {
          await _loadPendingUserData(user.employeeId);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load initial data: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _loadPendingUserData(String? employeeId) async {
    try {
      if (employeeId == null) return;

      // Use Firebase service directly
      final firestore = FirebaseService().firestore;

      // First try to get data from pending_users
      final pendingDoc =
          await firestore.collection('pending_users').doc(employeeId).get();

      Map<String, dynamic>? userData;

      if (pendingDoc.exists) {
        userData = pendingDoc.data()!;
      } else {
        // If not in pending_users, check the user's document
        final user = await ref.read(currentUserProvider.future);
        if (user != null) {
          final userDoc =
              await firestore.collection('users').doc(user.uid).get();
          if (userDoc.exists) {
            userData = userDoc.data()!;
          }
        }
      }

      if (userData != null) {
        // Load manager information
        final reportingManagerId = userData['reportingManagerId'] as String?;
        final hiringManagerId = userData['hiringManagerId'] as String?;

        // Load manager details
        if (reportingManagerId != null) {
          _reportingManager = await _loadManagerInformation(reportingManagerId);
        }

        if (hiringManagerId != null) {
          _hiringManager = await _loadManagerInformation(hiringManagerId);
        }

        // Pre-populate fields from user data
        if (mounted) {
          setState(() {
            // Override with data from pending_users or user document (admin-assigned data)
            if (userData != null) {
              _selectedDepartment =
                  userData['department'] as String? ?? _selectedDepartment;
              _selectedDesignation =
                  userData['designation'] as String? ?? _selectedDesignation;
            }

            // Store the user data for reference
            _currentUserData = userData;
          });
        }

        // Check if user was created from a candidate and load candidate data
        final candidateId = userData['candidateId'] as String?;
        if (candidateId != null) {
          await _loadCandidateData(candidateId);
        }
      }
    } catch (e) {
      print('Error loading pending user data: $e');
    }
  }

  /// Load candidate data and auto-populate form fields
  Future<void> _loadCandidateData(String candidateId) async {
    try {
      final candidateService = CandidateService();
      final candidate = await candidateService.getCandidateByCandidateId(
        candidateId,
      );

      if (candidate != null && mounted) {
        setState(() {
          // Auto-populate phone number from candidate
          if (candidate.phoneNumber.isNotEmpty &&
              _phoneController.text.isEmpty) {
            _phoneController.text = candidate.phoneNumber;
            _isPhoneNumberAutoPopulated = true;
          }

          // Auto-populate joining date from candidate's expected joining date
          if (candidate.expectedJoiningDate != null &&
              _selectedJoiningDate == null) {
            _selectedJoiningDate = candidate.expectedJoiningDate;
            _isJoiningDateAutoPopulated = true;
          }
        });

        print(
          '✅ Auto-populated candidate data: Phone=${candidate.phoneNumber}, JoiningDate=${candidate.expectedJoiningDate}',
        );
      }
    } catch (e) {
      print('Error loading candidate data: $e');
    }
  }

  Future<Map<String, dynamic>?> _loadManagerInformation(String userUid) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final managerDoc = await firestore.collection('users').doc(userUid).get();
      if (managerDoc.exists) {
        return managerDoc.data();
      }
    } catch (e) {
      print('Error loading manager information: $e');
    }
    return null;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String _formatRoleName(UserRole role) {
    switch (role) {
      case UserRole.sa:
        return 'Super Admin';
      case UserRole.admin:
        return 'Admin';
      case UserRole.hr:
        return 'HR';
      case UserRole.manager:
        return 'Manager';
      case UserRole.tl:
        return 'Team Lead';
      case UserRole.se:
        return 'Senior Employee';
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

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Additional validation for required fields
    if (_selectedDateOfBirth == null) {
      setState(() {
        _errorMessage = 'Please select your date of birth';
      });
      return;
    }

    if (_selectedJoiningDate == null) {
      setState(() {
        _errorMessage = 'Please select your joining date';
      });
      return;
    }

    if (_selectedDepartment == null) {
      setState(() {
        _errorMessage = 'Please select your department';
      });
      return;
    }

    if (_selectedDesignation == null) {
      setState(() {
        _errorMessage = 'Please select your designation';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);

      // Prepare additional data for corporate profile
      final additionalData = <String, dynamic>{
        'department': _selectedDepartment,
        'designation': _selectedDesignation,
        'gender': _selectedGender,
        'dateOfBirth': _selectedDateOfBirth?.toIso8601String(),
        'joiningDate': _selectedJoiningDate?.toIso8601String(),
        'emergencyContactName':
            _emergencyContactNameController.text.trim().isEmpty
                ? null
                : _emergencyContactNameController.text.trim(),
        'emergencyContactPhone':
            _emergencyContactPhoneController.text.trim().isEmpty
                ? null
                : _emergencyContactPhoneController.text.trim(),
        'address':
            _addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim(),
        'profileCompleted': true,
        'profileCompletedAt': DateTime.now().toIso8601String(),
      };

      // Add manager information if available
      if (_reportingManager != null) {
        additionalData['reportingManagerId'] = _reportingManager!['uid'];
        additionalData['reportingManagerName'] =
            _reportingManager!['displayName'];
      }

      if (_hiringManager != null) {
        additionalData['hiringManagerId'] = _hiringManager!['uid'];
        additionalData['hiringManagerName'] = _hiringManager!['displayName'];
      }

      print('🔄 Starting profile update...');
      await authService.updateUserProfile(
        displayName: _displayNameController.text.trim(),
        phoneNumber:
            _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
        additionalData: additionalData,
      );

      print('✅ Profile updated successfully');

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Profile completed successfully! Redirecting to dashboard...',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Invalidate providers to force refresh
        print('🔄 Invalidating providers...');
        ref.invalidate(currentUserProvider);
        ref.invalidate(authStateProvider);

        // Navigate immediately to dashboard
        print('🚀 Navigating to dashboard...');
        context.go('/dashboard');
      }
    } catch (e) {
      print('❌ Profile update error: $e');
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isDateOfBirth) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isDateOfBirth
              ? DateTime.now().subtract(
                const Duration(days: 365 * 25),
              ) // Default to 25 years ago
              : DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      helpText: isDateOfBirth ? 'Select Date of Birth' : 'Select Joining Date',
    );

    if (picked != null) {
      setState(() {
        if (isDateOfBirth) {
          _selectedDateOfBirth = picked;
        } else {
          _selectedJoiningDate = picked;
        }
      });
    }
  }

  Widget _buildManagerCard(String title, Map<String, dynamic>? manager) {
    if (manager == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.primaryColor,
                  child: Text(
                    manager['displayName']?.substring(0, 1).toUpperCase() ??
                        'M',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        manager['displayName'] ?? 'Unknown',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (manager['employeeId'] != null)
                        Text(
                          'ID: ${manager['employeeId']}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(
    String label,
    String value,
    IconData icon,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          hint,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Welcome Header
              Text(
                user?.role.isSuperAdmin == true
                    ? 'Complete Super Admin Profile'
                    : 'Complete Your Profile',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                user?.role.isSuperAdmin == true
                    ? 'As the Super Admin, please complete your profile to finish the system setup'
                    : 'Please complete your corporate profile information to get started',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // User Info Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Information',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.email,
                            size: 20,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              user?.email ?? 'Loading...',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.badge,
                            size: 20,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              user != null
                                  ? _formatRoleName(user.role)
                                  : 'Loading...',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      if (user?.employeeId != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.work_outline,
                              size: 20,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Employee ID: ${user!.employeeId}',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),

              // Profile Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Personal Information Section
                    Text(
                      'Personal Information',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Display Name Field
                    TextFormField(
                      controller: _displayNameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name *',
                        hintText: 'Enter your full name',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: theme.inputDecorationTheme.fillColor,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Full name is required';
                        }
                        if (value.trim().length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        if (!RegExp(
                          ValidationRules.namePattern,
                        ).hasMatch(value.trim())) {
                          return 'Please enter a valid name';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),

                    // Phone Number Field
                    TextFormField(
                      controller: _phoneController,
                      enabled:
                          !_isPhoneNumberAutoPopulated, // Disable if auto-populated
                      decoration: InputDecoration(
                        labelText: 'Phone Number *',
                        hintText: 'Enter your phone number',
                        prefixIcon: const Icon(Icons.phone),
                        suffixIcon:
                            _isPhoneNumberAutoPopulated
                                ? const Icon(Icons.lock, color: Colors.orange)
                                : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor:
                            _isPhoneNumberAutoPopulated
                                ? theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.3)
                                : theme.inputDecorationTheme.fillColor,
                        helperText:
                            _isPhoneNumberAutoPopulated
                                ? 'Pre-filled from candidate data'
                                : null,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Phone number is required';
                        }
                        if (!RegExp(
                          ValidationRules.phonePattern,
                        ).hasMatch(value.trim())) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),

                    // Gender Selection
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: InputDecoration(
                        labelText: 'Gender *',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: theme.inputDecorationTheme.fillColor,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Male', child: Text('Male')),
                        DropdownMenuItem(
                          value: 'Female',
                          child: Text('Female'),
                        ),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                        DropdownMenuItem(
                          value: 'Prefer not to say',
                          child: Text('Prefer not to say'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select your gender';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Date of Birth
                    InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date of Birth *',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: theme.inputDecorationTheme.fillColor,
                        ),
                        child: Text(
                          _selectedDateOfBirth != null
                              ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                              : 'Select date of birth',
                          style:
                              _selectedDateOfBirth != null
                                  ? theme.textTheme.bodyLarge
                                  : theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.hintColor,
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Address
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Address *',
                        hintText: 'Enter your complete address',
                        prefixIcon: const Icon(Icons.home),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: theme.inputDecorationTheme.fillColor,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Address is required';
                        }
                        if (value.trim().length < 10) {
                          return 'Please enter a complete address';
                        }
                        return null;
                      },
                      maxLines: 2,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 24),

                    // Professional Information Section
                    Text(
                      'Professional Information',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Department
                    _currentUserData != null &&
                            _currentUserData!['department'] != null
                        ? _buildReadOnlyField(
                          'Department *',
                          _selectedDepartment ?? 'Not assigned',
                          Icons.business,
                          'Assigned by admin',
                        )
                        : DropdownButtonFormField<String>(
                          value: _selectedDepartment,
                          decoration: InputDecoration(
                            labelText: 'Department *',
                            hintText: 'Select your department',
                            prefixIcon: const Icon(Icons.business),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: theme.inputDecorationTheme.fillColor,
                          ),
                          items:
                              _departments.map((String department) {
                                return DropdownMenuItem<String>(
                                  value: department,
                                  child: Text(department),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedDepartment = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select your department';
                            }
                            return null;
                          },
                        ),
                    const SizedBox(height: 16),

                    // Designation
                    _currentUserData != null &&
                            _currentUserData!['designation'] != null
                        ? _buildReadOnlyField(
                          'Designation *',
                          _selectedDesignation ?? 'Not assigned',
                          Icons.work,
                          'Assigned by admin',
                        )
                        : DropdownButtonFormField<String>(
                          value: _selectedDesignation,
                          decoration: InputDecoration(
                            labelText: 'Designation *',
                            hintText: 'Select your designation',
                            prefixIcon: const Icon(Icons.work),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: theme.inputDecorationTheme.fillColor,
                          ),
                          items:
                              _designations.map((String designation) {
                                return DropdownMenuItem<String>(
                                  value: designation,
                                  child: Text(designation),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedDesignation = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select your designation';
                            }
                            return null;
                          },
                        ),
                    const SizedBox(height: 16),

                    // Joining Date
                    InkWell(
                      onTap:
                          _isJoiningDateAutoPopulated
                              ? null
                              : () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Joining Date *',
                          prefixIcon: const Icon(Icons.event),
                          suffixIcon:
                              _isJoiningDateAutoPopulated
                                  ? const Icon(Icons.lock, color: Colors.orange)
                                  : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor:
                              _isJoiningDateAutoPopulated
                                  ? theme.colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.3)
                                  : theme.inputDecorationTheme.fillColor,
                          helperText:
                              _isJoiningDateAutoPopulated
                                  ? 'Pre-filled from candidate data'
                                  : null,
                        ),
                        child: Text(
                          _selectedJoiningDate != null
                              ? '${_selectedJoiningDate!.day}/${_selectedJoiningDate!.month}/${_selectedJoiningDate!.year}'
                              : 'Select joining date',
                          style:
                              _selectedJoiningDate != null
                                  ? theme.textTheme.bodyLarge
                                  : theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.hintColor,
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Manager Information Section (if assigned)
                    if (_reportingManager != null ||
                        _hiringManager != null) ...[
                      Text(
                        'Manager Information',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please confirm the manager assignments made by the admin:',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Reporting Manager Card
                      _buildManagerCard('Reporting Manager', _reportingManager),
                      if (_reportingManager != null) const SizedBox(height: 12),

                      // Hiring Manager Card
                      _buildManagerCard('Hiring Manager', _hiringManager),
                      const SizedBox(height: 24),
                    ],

                    // Emergency Contact Section
                    Text(
                      'Emergency Contact',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Emergency Contact Name
                    TextFormField(
                      controller: _emergencyContactNameController,
                      decoration: InputDecoration(
                        labelText: 'Emergency Contact Name *',
                        hintText: 'Enter emergency contact person name',
                        prefixIcon: const Icon(Icons.contact_emergency),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: theme.inputDecorationTheme.fillColor,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Emergency contact name is required';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),

                    // Emergency Contact Phone
                    TextFormField(
                      controller: _emergencyContactPhoneController,
                      decoration: InputDecoration(
                        labelText: 'Emergency Contact Phone *',
                        hintText: 'Enter emergency contact phone number',
                        prefixIcon: const Icon(Icons.phone_in_talk),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: theme.inputDecorationTheme.fillColor,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Emergency contact phone is required';
                        }
                        if (!RegExp(
                          ValidationRules.phonePattern,
                        ).hasMatch(value.trim())) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 32),

                    // Complete Profile Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          _isLoading
                              ? const CompactLoader()
                              : const Text(
                                'Complete Profile & Continue',
                                style: TextStyle(fontSize: 16),
                              ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Help Text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: theme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Profile Completion',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• All fields marked with * are required\n'
                      '• This information helps us serve you better\n'
                      '• You can update this information later in your profile settings\n'
                      '• Your data is secure and confidential',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
