import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/auth_providers.dart';

class AccessDeniedPage extends ConsumerWidget {
  final String requestedPath;
  final String reason;

  const AccessDeniedPage({
    super.key,
    required this.requestedPath,
    required this.reason,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Denied'),
        backgroundColor: theme.colorScheme.errorContainer,
        foregroundColor: theme.colorScheme.onErrorContainer,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.no_accounts,
                    size: 80,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  'Access Denied',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Reason
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.error.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Reason',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        reason,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Requested Path Info
                if (requestedPath.isNotEmpty && requestedPath != 'Unknown') ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.link,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Requested Path: ',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            requestedPath,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // User Info
                currentUser.when(
                  data:
                      (user) =>
                          user != null
                              ? Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer
                                      .withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person,
                                          color: theme.colorScheme.primary,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Current User',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                                color:
                                                    theme.colorScheme.primary,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${user.displayName} (${user.email})',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Role: ${user.role.displayName}',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color:
                                                theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                          ),
                                    ),
                                    if (user.employeeId != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Employee ID: ${user.employeeId}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color:
                                                  theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              )
                              : const SizedBox.shrink(),
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 32),

                // Action Buttons
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: () => context.go('/dashboard'),
                      icon: const Icon(Icons.home),
                      label: const Text('Go to Dashboard'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.go('/profile'),
                      icon: const Icon(Icons.person),
                      label: const Text('View Profile'),
                    ),
                    TextButton.icon(
                      onPressed: () => context.go('/login'),
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign Out'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Help Text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.help_outline,
                            color: theme.colorScheme.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Need Help?',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'If you believe you should have access to this page, please contact your administrator or IT support. They can review and update your role permissions.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
