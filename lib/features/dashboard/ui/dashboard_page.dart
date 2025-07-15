import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/providers/auth_providers.dart';
import '../providers/dashboard_providers.dart';
import '../../../core/providers/performance_providers.dart';
import 'dashboard_scaffold.dart';
import '../providers/moments_providers.dart';
import '../../../core/models/moment_media_model.dart';
import '../../../core/models/announcement_model.dart';
import '../../../core/services/auth_service.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'dart:ui';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        AuthService().onAppPaused();
        break;
      case AppLifecycleState.resumed:
        AuthService().onAppResumed();
        break;
      case AppLifecycleState.detached:
        AuthService().onAppPaused();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final shouldShowSetup = ref.watch(shouldShowSetupProvider);
    final currentUser = ref.watch(currentUserProvider);
    final authState = ref.watch(authStateProvider);

    return CoolAIBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: shouldShowSetup.when(
          data: (needsSetup) {
            if (needsSetup) {
              return _buildSetupWelcome(context);
            }

            return authState.when(
              data: (user) {
                if (user == null) {
                  return _buildLoginPrompt(context);
                }

                return currentUser.when(
                  data: (userModel) {
                    if (userModel == null) {
                      return _buildLoadingScreen();
                    }

                    if (userModel.department == null ||
                        userModel.department!.isEmpty) {
                      return _buildProfileCompletionPrompt(context);
                    }

                    return DashboardScaffold(
                      currentPath: '/dashboard',
                      child: const DashboardContent(),
                    );
                  },
                  loading: () => _buildLoadingScreen(),
                  error:
                      (error, _) =>
                          _buildErrorScreen(context, error.toString()),
                );
              },
              loading: () => _buildLoadingScreen(),
              error: (error, _) => _buildErrorScreen(context, error.toString()),
            );
          },
          loading: () => _buildLoadingScreen(),
          error: (error, _) => _buildErrorScreen(context, error.toString()),
        ),
      ),
    );
  }

  Widget _buildSetupWelcome(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.rocket_launch,
                  size: 120,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 32),
                Text(
                  'Welcome to Your Organization Management System!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Let\'s get started by setting up your first Super Admin account.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                FilledButton.icon(
                  onPressed: () => context.go('/setup-super-admin'),
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Setup Super Admin'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.login, size: 80, color: theme.colorScheme.primary),
                const SizedBox(height: 24),
                Text(
                  'Please Sign In',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'You need to sign in to access the dashboard.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCompletionPrompt(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_outline,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Complete Your Profile',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Please complete your profile to access the dashboard.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () => context.go('/first-time-profile'),
                  child: const Text('Complete Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String error) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Something went wrong',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                error,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => context.go('/login'),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardContent extends ConsumerWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider);
    final isSuperAdmin = ref.watch(isSuperAdminProvider);
    final canManageUsers = ref.watch(canManageUsersProvider);

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh all dashboard data
        ref.read(globalRefreshProvider.notifier).refreshAll();
        // Wait a bit for the refresh to propagate
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            currentUser.when(
              data:
                  (user) =>
                      user != null
                          ? _buildWelcomeSection(theme, user)
                          : const SizedBox.shrink(),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 32),

            // Carousel Section
            DashboardCarouselWidget(),
            const SizedBox(height: 32),

            // Announcement Section
            DashboardAnnouncementsWidget(),
            const SizedBox(height: 32),

            // Stats Cards
            _buildStatsCards(theme, ref),

            const SizedBox(height: 32),

            // Recent Activity
            _buildRecentActivity(theme, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(ThemeData theme, dynamic user) {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

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
                  '$greeting, ${user.displayName?.split(' ').first ?? 'User'}!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome back to your dashboard',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimary.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(now),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.dashboard,
            size: 64,
            color: theme.colorScheme.onPrimary.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(ThemeData theme, WidgetRef ref) {
    final totalEmployees = ref.watch(totalEmployeesProvider);
    final userActiveTasks = ref.watch(userActiveTasksProvider);
    final pendingProfileApprovals = ref.watch(pendingProfileApprovalsProvider);
    final documentsCount = ref.watch(documentsCountProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            return isWide
                ? Row(
                  children: [
                    Expanded(
                      child: totalEmployees.when(
                        data:
                            (count) => _buildStatCard(
                              theme,
                              'Total Employees',
                              count.toString(),
                              Icons.people,
                              Colors.blue,
                            ),
                        loading:
                            () => _buildStatCard(
                              theme,
                              'Total Employees',
                              '...',
                              Icons.people,
                              Colors.blue,
                            ),
                        error:
                            (_, __) => _buildStatCard(
                              theme,
                              'Total Employees',
                              'Error',
                              Icons.people,
                              Colors.blue,
                            ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: userActiveTasks.when(
                        data:
                            (count) => _buildStatCard(
                              theme,
                              'My Active Tasks',
                              count.toString(),
                              Icons.task,
                              Colors.orange,
                            ),
                        loading:
                            () => _buildStatCard(
                              theme,
                              'My Active Tasks',
                              '...',
                              Icons.task,
                              Colors.orange,
                            ),
                        error:
                            (_, __) => _buildStatCard(
                              theme,
                              'My Active Tasks',
                              'Error',
                              Icons.task,
                              Colors.orange,
                            ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: pendingProfileApprovals.when(
                        data:
                            (count) => _buildStatCard(
                              theme,
                              'Pending Approvals',
                              count.toString(),
                              Icons.approval,
                              Colors.red,
                            ),
                        loading:
                            () => _buildStatCard(
                              theme,
                              'Pending Approvals',
                              '...',
                              Icons.approval,
                              Colors.red,
                            ),
                        error:
                            (_, __) => _buildStatCard(
                              theme,
                              'Pending Approvals',
                              'Error',
                              Icons.approval,
                              Colors.red,
                            ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: documentsCount.when(
                        data:
                            (count) => _buildStatCard(
                              theme,
                              'Documents',
                              count.toString(),
                              Icons.description,
                              Colors.purple,
                            ),
                        loading:
                            () => _buildStatCard(
                              theme,
                              'Documents',
                              '...',
                              Icons.description,
                              Colors.purple,
                            ),
                        error:
                            (_, __) => _buildStatCard(
                              theme,
                              'Documents',
                              'Error',
                              Icons.description,
                              Colors.purple,
                            ),
                      ),
                    ),
                  ],
                )
                : Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: totalEmployees.when(
                            data:
                                (count) => _buildStatCard(
                                  theme,
                                  'Total Employees',
                                  count.toString(),
                                  Icons.people,
                                  Colors.blue,
                                ),
                            loading:
                                () => _buildStatCard(
                                  theme,
                                  'Total Employees',
                                  '...',
                                  Icons.people,
                                  Colors.blue,
                                ),
                            error:
                                (_, __) => _buildStatCard(
                                  theme,
                                  'Total Employees',
                                  'Error',
                                  Icons.people,
                                  Colors.blue,
                                ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: userActiveTasks.when(
                            data:
                                (count) => _buildStatCard(
                                  theme,
                                  'My Active Tasks',
                                  count.toString(),
                                  Icons.task,
                                  Colors.orange,
                                ),
                            loading:
                                () => _buildStatCard(
                                  theme,
                                  'My Active Tasks',
                                  '...',
                                  Icons.task,
                                  Colors.orange,
                                ),
                            error:
                                (_, __) => _buildStatCard(
                                  theme,
                                  'My Active Tasks',
                                  'Error',
                                  Icons.task,
                                  Colors.orange,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: pendingProfileApprovals.when(
                            data:
                                (count) => _buildStatCard(
                                  theme,
                                  'Pending Approvals',
                                  count.toString(),
                                  Icons.approval,
                                  Colors.red,
                                ),
                            loading:
                                () => _buildStatCard(
                                  theme,
                                  'Pending Approvals',
                                  '...',
                                  Icons.approval,
                                  Colors.red,
                                ),
                            error:
                                (_, __) => _buildStatCard(
                                  theme,
                                  'Pending Approvals',
                                  'Error',
                                  Icons.approval,
                                  Colors.red,
                                ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: documentsCount.when(
                            data:
                                (count) => _buildStatCard(
                                  theme,
                                  'Documents',
                                  count.toString(),
                                  Icons.description,
                                  Colors.purple,
                                ),
                            loading:
                                () => _buildStatCard(
                                  theme,
                                  'Documents',
                                  '...',
                                  Icons.description,
                                  Colors.purple,
                                ),
                            error:
                                (_, __) => _buildStatCard(
                                  theme,
                                  'Documents',
                                  'Error',
                                  Icons.description,
                                  Colors.purple,
                                ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: SizedBox(),
                        ), // Empty space for alignment
                      ],
                    ),
                  ],
                );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(
                  value,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(ThemeData theme, WidgetRef ref) {
    final recentActivity = ref.watch(recentActivityProvider);
    final onlineUserCount = ref.watch(onlineUserCountProvider);
    final currentUserStatus = ref.watch(currentUserStatusProvider);

    String _formatTimestamp(dynamic ts) {
      if (ts == null) return 'Never';

      DateTime dateTime;
      if (ts is Timestamp) {
        dateTime = ts.toDate();
      } else if (ts is DateTime) {
        dateTime = ts;
      } else if (ts is String) {
        try {
          dateTime = DateTime.parse(ts);
        } catch (e) {
          return 'Invalid date';
        }
      } else {
        return 'Unknown';
      }

      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      } else {
        return 'Just now';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Online user count and last login/logout
                Row(
                  children: [
                    Icon(Icons.people, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    onlineUserCount.when(
                      data:
                          (count) => Text(
                            'Users online: $count',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      loading:
                          () => const SizedBox(
                            width: 80,
                            child: LinearProgressIndicator(),
                          ),
                      error:
                          (_, __) => Text(
                            'Error',
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                    ),
                    const Spacer(),
                    Icon(Icons.login, color: theme.colorScheme.primary),
                    const SizedBox(width: 4),
                    currentUserStatus.when(
                      data:
                          (status) => Text(
                            'Last login: ${_formatTimestamp(status?['lastLogin'])}',
                            style: theme.textTheme.bodySmall,
                          ),
                      loading:
                          () => const SizedBox(
                            width: 60,
                            child: LinearProgressIndicator(),
                          ),
                      error:
                          (_, __) => Text(
                            'Error',
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.logout, color: theme.colorScheme.primary),
                    const SizedBox(width: 4),
                    currentUserStatus.when(
                      data:
                          (status) => Text(
                            'Last logout: ${_formatTimestamp(status?['lastLogout'])}',
                            style: theme.textTheme.bodySmall,
                          ),
                      loading:
                          () => const SizedBox(
                            width: 60,
                            child: LinearProgressIndicator(),
                          ),
                      error:
                          (_, __) => Text(
                            'Error',
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Activity list
                recentActivity.when(
                  data: (activities) {
                    if (activities.isEmpty) {
                      return Column(
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No recent activity',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Activity will appear here as users interact with the system',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          activities.take(5).map((activity) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          activity['description'] ??
                                              'Unknown activity',
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                        Text(
                                          _formatActivityTime(
                                            activity['timestamp'],
                                          ),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color:
                                                    theme
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    );
                  },
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (_, __) => Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: theme.colorScheme.error.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading activity',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatActivityTime(dynamic timestamp) {
    try {
      DateTime dateTime;
      if (timestamp is Timestamp) {
        dateTime = timestamp.toDate();
      } else if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } else {
        return 'Unknown time';
      }

      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class DashboardCarouselWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<DashboardCarouselWidget> createState() =>
      _DashboardCarouselWidgetState();
}

class _DashboardCarouselWidgetState
    extends ConsumerState<DashboardCarouselWidget> {
  int _currentPage = 0;
  final Map<String, double> _aspectRatioCache = {};
  late final PageController _pageController;
  Timer? _autoPageTimer;
  bool _isVideoPlaying = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoPageTimer();
  }

  @override
  void dispose() {
    _autoPageTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPageTimer() {
    _autoPageTimer?.cancel();
    _autoPageTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted && !_isVideoPlaying) {
        final mediaList = ref.read(activeMomentMediaProvider);
        mediaList.whenData((media) {
          if (media.length > 1) {
            final nextPage = (_currentPage + 1) % media.length;
            _pageController.animateToPage(
              nextPage,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    });
  }

  void _onVideoPlay(bool isPlaying) {
    setState(() {
      _isVideoPlaying = isPlaying;
    });
    if (isPlaying) {
      _autoPageTimer?.cancel();
    } else {
      _startAutoPageTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaList = ref.watch(activeMomentMediaProvider);
    const carouselAspect = 16 / 5;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: mediaList.when(
        data: (media) {
          if (media.isEmpty) {
            return Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: AspectRatio(
                aspectRatio: carouselAspect,
                child: Center(
                  child: Text(
                    'No moments to display.',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ),
            );
          }
          return Column(
            children: [
              Card(
                elevation: 3,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: AspectRatio(
                    aspectRatio: carouselAspect,
                    child: PageView.builder(
                      itemCount: media.length,
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                          _isVideoPlaying =
                              false; // Reset video playing state on page change
                        });
                      },
                      itemBuilder: (context, index) {
                        final m = media[index];
                        if (m.mediaType == MediaType.image) {
                          return _SmartFitImage(
                            url: m.signedUrl!,
                            aspectRatioCache: _aspectRatioCache,
                            boxAspect: carouselAspect,
                          );
                        } else {
                          // Video preview with play icon
                          return _InlineVideoPlayer(
                            videoUrl: m.signedUrl!,
                            fileName: m.fileName,
                            mediaType: m.mediaType,
                            onPlayStateChanged: _onVideoPlay,
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
              if (media.length > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      media.length,
                      (index) => GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 16 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color:
                                _currentPage == index
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading moments: $e')),
      ),
    );
  }
}

class _SmartFitImage extends StatefulWidget {
  final String url;
  final Map<String, double> aspectRatioCache;
  final double boxAspect;
  const _SmartFitImage({
    required this.url,
    required this.aspectRatioCache,
    required this.boxAspect,
  });

  @override
  State<_SmartFitImage> createState() => _SmartFitImageState();
}

class _SmartFitImageState extends State<_SmartFitImage> {
  double? _imageAspect;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _getImageAspect();
  }

  void _getImageAspect() async {
    if (widget.aspectRatioCache.containsKey(widget.url)) {
      setState(() {
        _imageAspect = widget.aspectRatioCache[widget.url];
        _loading = false;
      });
      return;
    }
    final image = Image.network(widget.url);
    final completer = Completer<ui.Image>();
    image.image
        .resolve(const ImageConfiguration())
        .addListener(
          ImageStreamListener(
            (info, _) {
              completer.complete(info.image);
            },
            onError: (error, stackTrace) {
              setState(() {
                _error = true;
                _loading = false;
              });
            },
          ),
        );
    try {
      final img = await completer.future;
      final aspect = img.width / img.height;
      widget.aspectRatioCache[widget.url] = aspect;
      setState(() {
        _imageAspect = aspect;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }
    if (_error) {
      return Center(child: Icon(Icons.broken_image, size: 48));
    }
    // Smart fit logic
    final fit =
        (_imageAspect != null &&
                (_imageAspect! > widget.boxAspect * 0.95 &&
                    _imageAspect! < widget.boxAspect * 1.05))
            ? BoxFit.cover
            : BoxFit.contain;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (fit == BoxFit.contain)
          // Blurred background for tall/narrow images
          ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Image.network(
              widget.url,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.2),
              colorBlendMode: BlendMode.darken,
            ),
          ),
        Center(
          child: Image.network(
            widget.url,
            fit: fit,
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
          ),
        ),
      ],
    );
  }
}

// Update _InlineVideoPlayer to support play icon and play state callback
class _InlineVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String fileName;
  final MediaType mediaType;
  final void Function(bool isPlaying)? onPlayStateChanged;

  const _InlineVideoPlayer({
    required this.videoUrl,
    required this.fileName,
    required this.mediaType,
    this.onPlayStateChanged,
  });

  @override
  State<_InlineVideoPlayer> createState() => _InlineVideoPlayerState();
}

class _InlineVideoPlayerState extends State<_InlineVideoPlayer> {
  String _viewType = '';
  bool _showPlayer = false;
  html.VideoElement? _videoElement;

  @override
  void initState() {
    super.initState();
    _viewType = 'inline-video-${widget.videoUrl.hashCode}';
    _registerVideoPlayer();
  }

  void _registerVideoPlayer() {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      _videoElement =
          html.VideoElement()
            ..src = widget.videoUrl
            ..controls = true
            ..autoplay = true
            ..muted = false
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.objectFit = 'contain'
            ..style.borderRadius = '0px';

      _videoElement!.onPlay.listen((event) {
        widget.onPlayStateChanged?.call(true);
      });
      _videoElement!.onPause.listen((event) {
        widget.onPlayStateChanged?.call(false);
      });
      _videoElement!.onEnded.listen((event) {
        widget.onPlayStateChanged?.call(false);
      });
      return _videoElement!;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mediaType == MediaType.video) {
      if (_showPlayer) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          child: HtmlElementView(viewType: _viewType),
        );
      } else {
        // Show preview with play icon
        return Container(
          color: Colors.black,
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.videocam, size: 64, color: Colors.blueGrey),
                const SizedBox(height: 12),
                Text(
                  widget.fileName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text('Video', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: Icon(Icons.play_arrow),
                  label: Text('Play'),
                  onPressed: () {
                    setState(() {
                      _showPlayer = true;
                    });
                    widget.onPlayStateChanged?.call(true);
                  },
                ),
              ],
            ),
          ),
        );
      }
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off, size: 48, color: Colors.white),
            SizedBox(height: 16),
            Text('Not a video file', style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }
  }
}

class DashboardAnnouncementsWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final announcements = ref.watch(activeAnnouncementsProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: announcements.when(
          data: (ann) {
            if (ann.isEmpty) {
              return Column(
                children: [
                  Icon(
                    Icons.campaign_outlined,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No announcements at this time.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later for updates and important information',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(
                        0.7,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            final sortedAnnouncements = List<Announcement>.from(ann)
              ..sort((a, b) {
                if (a.isHighPriority && !b.isHighPriority) return -1;
                if (!a.isHighPriority && b.isHighPriority) return 1;
                return b.createdAt.compareTo(a.createdAt);
              });

            return currentUser.when(
              data:
                  (user) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.campaign,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Announcements',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (sortedAnnouncements.any((a) => a.isHighPriority))
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${sortedAnnouncements.where((a) => a.isHighPriority).length} High Priority',
                                style: TextStyle(
                                  color: theme.colorScheme.onError,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...sortedAnnouncements
                          .map(
                            (a) => _buildAnnouncementCard(a, theme, user, ref),
                          )
                          .toList(),
                    ],
                  ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error loading user'),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (e, _) => Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: theme.colorScheme.error.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading announcements',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please try refreshing the page',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(
    Announcement announcement,
    ThemeData theme,
    dynamic user,
    WidgetRef ref,
  ) {
    final isHighPriority = announcement.isHighPriority;
    final isExpired = announcement.isExpired;
    final isExpiringSoon = announcement.isExpiringSoon;
    final requiresAck = announcement.requiresAcknowledgment;
    final hasAcknowledged =
        user != null && announcement.acknowledgedBy.contains(user.uid);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isHighPriority ? 4 : 1,
      color:
          isHighPriority
              ? null
              : (isHighPriority
                  ? null
                  : theme.colorScheme.errorContainer.withOpacity(0.1)),
      child: Container(
        decoration:
            isHighPriority
                ? BoxDecoration(
                  border: Border.all(color: theme.colorScheme.error, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [
                      Color(0xFFFFE082), // Yellow
                      Color(0xFFFF80AB), // Pink
                      Color(0xFFB388FF), // Purple
                      Color(0xFF82B1FF), // Blue
                      Color(0xFF80D8FF), // Cyan
                    ],
                    stops: [0.0, 0.3, 0.5, 0.7, 1.0],
                  ),
                )
                : null,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with priority indicator
            Row(
              children: [
                Icon(
                  isHighPriority ? Icons.priority_high : Icons.campaign,
                  color:
                      isHighPriority
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    announcement.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          isHighPriority
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (isHighPriority)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'HIGH PRIORITY',
                      style: TextStyle(
                        color: theme.colorScheme.onError,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Content
            Text(announcement.content, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            // Tags
            if (announcement.tags.isNotEmpty) ...[
              Wrap(
                spacing: 4,
                children:
                    announcement.tags
                        .map(
                          (tag) => Chip(
                            label: Text(tag),
                            backgroundColor: theme.colorScheme.primaryContainer,
                            labelStyle: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontSize: 10,
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 8),
            ],
            // Footer with metadata
            Row(
              children: [
                Icon(
                  Icons.category,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  announcement.categoryDisplayName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatRelativeTime(announcement.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                if (announcement.expiresAt != null)
                  Row(
                    children: [
                      Icon(
                        Icons.timer_off,
                        size: 14,
                        color:
                            isExpired
                                ? theme.colorScheme.error
                                : isExpiringSoon
                                ? Colors.orange
                                : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isExpired
                            ? 'Expired'
                            : isExpiringSoon
                            ? 'Expires soon'
                            : 'Expires ${_formatRelativeTime(announcement.expiresAt!)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              isExpired
                                  ? theme.colorScheme.error
                                  : isExpiringSoon
                                  ? Colors.orange
                                  : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            // Additional info
            if (requiresAck || announcement.maxViews != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (requiresAck) ...[
                    Icon(
                      hasAcknowledged
                          ? Icons.check_circle
                          : Icons.check_circle_outline,
                      size: 14,
                      color:
                          hasAcknowledged
                              ? Colors.green
                              : theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    hasAcknowledged
                        ? Text(
                          'Acknowledged',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                          ),
                        )
                        : TextButton(
                          onPressed: () async {
                            if (user == null) return;
                            final doc = FirebaseFirestore.instance
                                .collection('announcements')
                                .doc(announcement.id);
                            await doc.update({
                              'acknowledgedBy': FieldValue.arrayUnion([
                                user.uid,
                              ]),
                            });
                            // Optionally, refresh the provider
                            ref.invalidate(activeAnnouncementsProvider);
                          },
                          child: const Text('Mark as Read'),
                        ),
                    const SizedBox(width: 16),
                  ],
                  if (announcement.maxViews != null) ...[
                    Icon(
                      Icons.visibility,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${announcement.viewCount}/${announcement.maxViews} views',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class ModalCarouselWidget extends StatefulWidget {
  final List<MomentMedia> mediaList;
  final int initialIndex;

  const ModalCarouselWidget({
    required this.mediaList,
    required this.initialIndex,
  });

  @override
  State<ModalCarouselWidget> createState() => _ModalCarouselWidgetState();
}

class _ModalCarouselWidgetState extends State<ModalCarouselWidget> {
  late PageController _pageController;
  Timer? _autoPageTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _startAutoPageTimer();
  }

  @override
  void dispose() {
    _autoPageTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPageTimer() {
    _autoPageTimer?.cancel();
    if (widget.mediaList.length > 1) {
      _autoPageTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (mounted) {
          final nextPage = (_currentPage + 1) % widget.mediaList.length;
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.mediaList.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final m = widget.mediaList[index];
                if (m.mediaType == MediaType.image) {
                  return _SmartFitImage(
                    url: m.signedUrl!,
                    aspectRatioCache: {},
                    boxAspect: 16 / 9,
                  );
                } else {
                  // Video preview (show icon and filename)
                  return Container(
                    color: theme.colorScheme.surfaceContainerLowest,
                    width: double.infinity,
                    height: double.infinity,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.videocam,
                            size: 64,
                            color: Colors.blueGrey,
                          ),
                          const SizedBox(height: 12),
                          Text(m.fileName, style: theme.textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text('Video', style: theme.textTheme.bodySmall),
                          const SizedBox(height: 8),
                          if (m.signedUrl != null)
                            OutlinedButton.icon(
                              icon: Icon(Icons.play_arrow),
                              label: Text('Play'),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => Dialog(
                                        child: AspectRatio(
                                          aspectRatio: 16 / 9,
                                          child: Container(
                                            width: 480,
                                            height: 270,
                                            child: _InlineVideoPlayer(
                                              videoUrl: m.signedUrl!,
                                              fileName: m.fileName,
                                              mediaType: m.mediaType,
                                            ),
                                          ),
                                        ),
                                      ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          if (widget.mediaList.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.mediaList.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 16 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color:
                          _currentPage == index
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CoolAIBackground extends StatelessWidget {
  final Widget child;
  const CoolAIBackground({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [
                Color(0xFF0F2027), // Deep blue/black
                Color(0xFF2C5364), // Blue-gray
                Color(0xFF6A82FB), // Blue
                Color(0xFFFC5C7D), // Pink
                Color(0xFFFFE082), // Yellow accent
              ],
              stops: [0.0, 0.3, 0.6, 0.85, 1.0],
            ),
          ),
        ),
        // Optional: Add a blur for a glassmorphism effect
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            color: Colors.black.withOpacity(0.05), // subtle overlay
          ),
        ),
        // Page content
        child,
      ],
    );
  }
}
