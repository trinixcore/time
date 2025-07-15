import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/providers/auth_providers.dart';
import '../../../../core/constants/validation_rules.dart';
import '../../../../core/models/user_model.dart';
import '../../../../shared/widgets/custom_loader.dart';
import '../../../../core/services/firebase_service.dart';

class SetupSuperAdminPage extends ConsumerStatefulWidget {
  const SetupSuperAdminPage({super.key});

  @override
  ConsumerState<SetupSuperAdminPage> createState() =>
      _SetupSuperAdminPageState();
}

class _SetupSuperAdminPageState extends ConsumerState<SetupSuperAdminPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _createSuperAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);

      print('🔄 Creating Super Admin...');
      // Create Super-Admin user
      await authService.createSuperAdmin(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        displayName: _displayNameController.text.trim(),
      );

      print('🔄 Initializing system data...');
      // Initialize system data (departments and designations)
      await authService.initializeSystemData();

      print('✅ Super Admin created successfully');

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Super Admin account created successfully! Please complete your profile.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Invalidate providers to force refresh
        print('🔄 Invalidating providers...');
        ref.invalidate(authStateProvider);
        ref.invalidate(currentUserProvider);
        ref.invalidate(shouldShowSetupProvider);
        ref.invalidate(isSetupCompletedProvider);
        ref.invalidate(hasUsersProvider);

        // Clear Firebase service cache to ensure fresh data
        print('🔄 Clearing Firebase service cache...');
        FirebaseService.clearCache();

        // Use the clear cache provider to ensure everything is refreshed
        print('🔄 Using clear cache provider...');
        ref.read(clearCacheProvider);

        // Small delay to ensure cache clearing is processed
        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate immediately to profile completion
        print('🚀 Navigating to profile completion...');
        context.go('/first-time-profile');
      }
    } catch (e) {
      print('❌ Super Admin creation error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  // Debug method to manually mark setup as completed
  Future<void> _markSetupCompleted() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔄 Manually marking setup as completed...');

      // Mark setup as completed directly
      await FirebaseService().markSetupCompleted();

      // Clear all caches
      FirebaseService.clearCache();
      ref.read(clearCacheProvider);

      // Invalidate all providers
      ref.invalidate(authStateProvider);
      ref.invalidate(currentUserProvider);
      ref.invalidate(shouldShowSetupProvider);
      ref.invalidate(isSetupCompletedProvider);
      ref.invalidate(hasUsersProvider);

      print('✅ Setup marked as completed');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Setup marked as completed successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Small delay to ensure cache clearing is processed
        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate to login or dashboard
        print('🚀 Navigating to login...');
        context.go('/login');
      }
    } catch (e) {
      print('❌ Error marking setup as completed: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to mark setup as completed: ${e.toString()}';
        });
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]',
    ).hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, number, and special character';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _validateDisplayName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Display name is required';
    }
    if (value.length < 2) {
      return 'Display name must be at least 2 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.bounceOut,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.shadow.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: AnimatedRotation(
                          duration: const Duration(seconds: 3),
                          turns: 1,
                          child: Image.asset(
                            'assets/images/ICON.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Setup Super-Admin',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create the first Super-Admin account to manage your organization',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Display Name Field
                      TextFormField(
                        controller: _displayNameController,
                        decoration: const InputDecoration(
                          labelText: 'Display Name',
                          hintText: 'Enter your full name',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: _validateDisplayName,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          hintText: 'Enter your email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter a strong password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed:
                                () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: _obscurePassword,
                        validator: _validatePassword,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password Field
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          hintText: 'Re-enter your password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed:
                                () => setState(
                                  () =>
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword,
                                ),
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: _obscureConfirmPassword,
                        validator: _validateConfirmPassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _createSuperAdmin(),
                      ),
                      const SizedBox(height: 24),

                      // Security Notice
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.security,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'MFA enrollment will be required after first login',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Create Button
                      FilledButton(
                        onPressed: _isLoading ? null : _createSuperAdmin,
                        child:
                            _isLoading
                                ? const CompactLoader()
                                : const Text('Create Super-Admin'),
                      ),

                      const SizedBox(height: 16),

                      // Debug button to mark setup as completed
                      OutlinedButton(
                        onPressed: _isLoading ? null : _markSetupCompleted,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                        ),
                        child:
                            _isLoading
                                ? const CompactLoader()
                                : const Text('Mark Setup as Completed (Debug)'),
                      ),

                      const SizedBox(height: 8),

                      // Debug info
                      Text(
                        'Use this if setup was already completed but app still shows setup page',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.orange,
                          fontStyle: FontStyle.italic,
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
