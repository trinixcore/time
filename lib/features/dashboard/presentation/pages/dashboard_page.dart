import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/auth_providers.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isSuperAdmin = ref.watch(isSuperAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authService = ref.read(authServiceProvider);
              await authService.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.dashboard, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'Welcome to the Dashboard!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            currentUser.when(
              data:
                  (user) =>
                      user != null
                          ? Column(
                            children: [
                              Text('Welcome, ${user.displayName}!'),
                              Text('Email: ${user.email}'),
                              Text('Role: ${user.role.value}'),
                              const SizedBox(height: 16),
                              isSuperAdmin.when(
                                data:
                                    (isSuper) =>
                                        isSuper
                                            ? const Card(
                                              child: Padding(
                                                padding: EdgeInsets.all(16.0),
                                                child: Column(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .admin_panel_settings,
                                                      color: Colors.orange,
                                                    ),
                                                    SizedBox(height: 8),
                                                    Text(
                                                      'Super-Admin Privileges Active',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      'You have full system access',
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                            : const SizedBox.shrink(),
                                loading:
                                    () => const CircularProgressIndicator(),
                                error: (_, __) => const SizedBox.shrink(),
                              ),
                            ],
                          )
                          : const Text('No user data available'),
              loading: () => const CircularProgressIndicator(),
              error: (error, _) => Text('Error: $error'),
            ),
            const SizedBox(height: 32),
            const Text(
              'TODO: Implement dashboard features',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
