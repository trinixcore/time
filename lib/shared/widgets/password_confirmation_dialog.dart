import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auth_service.dart';
import '../providers/auth_providers.dart';

class PasswordConfirmationDialog extends ConsumerStatefulWidget {
  final String title;
  final String message;
  final String actionButtonText;
  final VoidCallback onConfirmed;
  final Color? actionButtonColor;
  final IconData? icon;

  const PasswordConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.actionButtonText,
    required this.onConfirmed,
    this.actionButtonColor,
    this.icon,
  });

  @override
  ConsumerState<PasswordConfirmationDialog> createState() =>
      _PasswordConfirmationDialogState();
}

class _PasswordConfirmationDialogState
    extends ConsumerState<PasswordConfirmationDialog> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isVerifying = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _verifyPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final currentUser = ref.read(currentUserProvider).value;

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Verify password by attempting to re-authenticate
      await authService.verifyCurrentPassword(
        currentUser.email,
        _passwordController.text,
      );

      // Password verified successfully
      if (mounted) {
        Navigator.of(context).pop(true);
        widget.onConfirmed();
      }
    } catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('wrong-password') ||
        error.contains('invalid-credential') ||
        error.contains('Invalid credentials')) {
      return 'Incorrect password. Please try again.';
    } else if (error.contains('too-many-requests')) {
      return 'Too many failed attempts. Please try again later.';
    } else if (error.contains('user-not-found')) {
      return 'User authentication failed. Please log in again.';
    }
    return 'Password verification failed. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      icon:
          widget.icon != null
              ? Icon(
                widget.icon,
                color: widget.actionButtonColor ?? theme.colorScheme.primary,
                size: 32,
              )
              : null,
      title: Text(widget.title),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.message, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 24),

            // Security Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
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
                      'Please enter your password to confirm this action',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Password Field
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Your Password',
                  prefixIcon: const Icon(Icons.lock_outline),
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
                  border: const OutlineInputBorder(),
                  errorText: _errorMessage,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _verifyPassword(),
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.onErrorContainer,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: theme.colorScheme.onErrorContainer,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed:
              _isVerifying ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _isVerifying ? null : _verifyPassword,
          style: FilledButton.styleFrom(
            backgroundColor: widget.actionButtonColor,
          ),
          icon:
              _isVerifying
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Icon(Icons.check),
          label: Text(_isVerifying ? 'Verifying...' : widget.actionButtonText),
        ),
      ],
    );
  }
}

// Helper function to show password confirmation dialog
Future<bool> showPasswordConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String actionButtonText,
  required VoidCallback onConfirmed,
  Color? actionButtonColor,
  IconData? icon,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder:
        (context) => PasswordConfirmationDialog(
          title: title,
          message: message,
          actionButtonText: actionButtonText,
          onConfirmed: onConfirmed,
          actionButtonColor: actionButtonColor,
          icon: icon,
        ),
  );

  return result ?? false;
}
