import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/enums/user_role.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../core/constants/validation_rules.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _departmentController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  UserRole _selectedRole = UserRole.employee;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final currentUser = await ref.read(currentUserProvider.future);

      if (currentUser == null) {
        throw Exception('You must be logged in to create users');
      }

      await authService.registerUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _displayNameController.text.trim(),
        role: _selectedRole,
        createdBy: currentUser.uid,
        phoneNumber:
            _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
        department:
            _departmentController.text.trim().isEmpty
                ? null
                : _departmentController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User ${_displayNameController.text} created successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('email-already-in-use')) {
      return 'An account with this email already exists.';
    } else if (error.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    } else if (error.contains('weak-password')) {
      return 'Password is too weak. Please choose a stronger password.';
    } else if (error.contains('Unauthorized')) {
      return 'You do not have permission to create users.';
    }
    return 'Registration failed. Please try again.';
  }

  String _formatRoleName(UserRole role) {
    switch (role) {
      case UserRole.employee:
        return 'Employee';
      case UserRole.se:
        return 'Senior Employee';
      case UserRole.tl:
        return 'Team Lead';
      case UserRole.manager:
        return 'Manager';
      case UserRole.hr:
        return 'HR';
      case UserRole.admin:
        return 'Admin';
      case UserRole.sa:
        return 'Super Admin';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final passwordStrength = ref.watch(
      passwordStrengthProvider(_passwordController.text),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Create New User'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'User Registration',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a new user account for the system',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Error Message
                if (_errorMessage != null) ...[
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
                          size: 20,
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
                  const SizedBox(height: 16),
                ],

                // Registration Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Display Name Field
                      TextFormField(
                        controller: _displayNameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return ValidationRules.requiredFieldMessage;
                          }
                          if (value.trim().length <
                              ValidationRules.minNameLength) {
                            return 'Name must be at least ${ValidationRules.minNameLength} characters';
                          }
                          if (!RegExp(
                            ValidationRules.namePattern,
                          ).hasMatch(value)) {
                            return ValidationRules.invalidNameMessage;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return ValidationRules.requiredFieldMessage;
                          }
                          if (!RegExp(
                            ValidationRules.emailPattern,
                          ).hasMatch(value)) {
                            return ValidationRules.invalidEmailMessage;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Role Selection
                      DropdownButtonFormField<UserRole>(
                        value: _selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                        ),
                        items:
                            UserRole.values.map((role) {
                              return DropdownMenuItem(
                                value: role,
                                child: Text(_formatRoleName(role)),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedRole = value;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null) {
                            return ValidationRules.requiredFieldMessage;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Phone Field (Optional)
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number (Optional)',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            if (!RegExp(
                              ValidationRules.phonePattern,
                            ).hasMatch(value)) {
                              return ValidationRules.invalidPhoneMessage;
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Department Field (Optional)
                      TextFormField(
                        controller: _departmentController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Department (Optional)',
                          prefixIcon: Icon(Icons.business_outlined),
                        ),
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            if (value.trim().length <
                                ValidationRules.minDepartmentNameLength) {
                              return 'Department name must be at least ${ValidationRules.minDepartmentNameLength} characters';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        onChanged:
                            (value) => setState(
                              () {},
                            ), // Trigger password strength update
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return ValidationRules.requiredFieldMessage;
                          }
                          if (!AuthService.isPasswordStrong(value)) {
                            return ValidationRules.weakPasswordMessage;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      // Password Strength Indicator
                      if (_passwordController.text.isNotEmpty) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Password Strength: ',
                                  style: theme.textTheme.bodySmall,
                                ),
                                Text(
                                  passwordStrength.strengthText,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color:
                                        passwordStrength.isStrong
                                            ? Colors.green
                                            : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: passwordStrength.strengthPercentage,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                passwordStrength.isStrong
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                            if (passwordStrength.feedback.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              ...passwordStrength.feedback.map(
                                (feedback) => Text(
                                  '• $feedback',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Confirm Password Field
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return ValidationRules.requiredFieldMessage;
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text('Create User'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Cancel Button
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
