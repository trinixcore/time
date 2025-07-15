import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../core/constants/validation_rules.dart';
import '../../../shared/widgets/custom_loader.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isEmployeeLogin = false; // Toggle between email and employee ID
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _employeeIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);

      if (_isEmployeeLogin) {
        // Employee login with employee ID
        await authService.signInWithEmployeeId(
          employeeId: _employeeIdController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        // Admin/Super Admin login with email
        await authService.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      if (mounted) {
        context.go('/dashboard');
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
    if (error.contains('user-not-found')) {
      return 'No account found with this email address.';
    } else if (error.contains('wrong-password') ||
        error.contains('Invalid credentials')) {
      return 'Incorrect password. Please try again.';
    } else if (error.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    } else if (error.contains('user-disabled')) {
      return 'This account has been disabled. Please contact support.';
    } else if (error.contains('too-many-requests')) {
      return 'Too many failed attempts. Please try again later.';
    } else if (error.contains('deactivated')) {
      return 'Your account has been deactivated. Please contact administrator.';
    } else if (error.contains('Employee ID not found')) {
      return 'Employee ID not found. Please check your ID and try again.';
    }
    return 'Login failed. Please check your credentials and try again.';
  }

  void _toggleLoginMode() {
    setState(() {
      _isEmployeeLogin = !_isEmployeeLogin;
      _errorMessage = null;
      // Clear form fields when switching modes
      _emailController.clear();
      _employeeIdController.clear();
      _passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                elevation: 8,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.elasticOut,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(seconds: 2),
                            tween: Tween(begin: 0.8, end: 1.0),
                            builder: (context, scale, child) {
                              return Transform.scale(
                                scale: scale,
                                child: Image.asset(
                                  'assets/images/ICON.png',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.contain,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title and Subtitle
                      Text(
                        'TRINIX Internal Management Engine',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isEmployeeLogin ? 'Employee Sign In' : 'Admin Sign In',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Login Mode Toggle
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(
                            0.3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (_isEmployeeLogin) _toggleLoginMode();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        !_isEmployeeLogin
                                            ? theme.colorScheme.primary
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Admin Login',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color:
                                          !_isEmployeeLogin
                                              ? theme.colorScheme.onPrimary
                                              : theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (!_isEmployeeLogin) _toggleLoginMode();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        _isEmployeeLogin
                                            ? theme.colorScheme.primary
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Employee Login',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color:
                                          _isEmployeeLogin
                                              ? theme.colorScheme.onPrimary
                                              : theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

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

                      // Login Form
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Email Field (for Admin) or Employee ID Field (for Employee)
                            if (_isEmployeeLogin) ...[
                              TextFormField(
                                controller: _employeeIdController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Employee ID',
                                  hintText: 'e.g., TRX2024000001',
                                  prefixIcon: Icon(Icons.badge_outlined),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Employee ID is required';
                                  }
                                  if (!RegExp(
                                    r'^TRX\d{10}$',
                                  ).hasMatch(value.trim())) {
                                    return 'Please enter a valid Employee ID (TRX followed by 10 digits)';
                                  }
                                  return null;
                                },
                              ),
                            ] else ...[
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
                            ],
                            const SizedBox(height: 16),

                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _handleLogin(),
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
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                child:
                                    _isLoading
                                        ? const CompactLoader()
                                        : const Text('Sign In'),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Forgot Password Link
                      TextButton(
                        onPressed: () => context.push('/reset-password'),
                        child: const Text('Forgot your password?'),
                      ),

                      const SizedBox(height: 16),

                      // Footer
                      Text(
                        '© 2024 T.I.M.E',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
