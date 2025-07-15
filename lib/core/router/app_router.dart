import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/candidate_model.dart';
import '../../shared/providers/auth_providers.dart';
import '../../features/auth/ui/login_page.dart';
import '../../features/auth/ui/register_page.dart';
import '../../features/auth/ui/reset_password_page.dart';
import '../../features/auth/ui/first_time_profile_page.dart';
import '../../features/auth/ui/access_denied_page.dart';
import '../../features/dashboard/ui/dashboard_page.dart';
import '../../features/auth/presentation/pages/setup_super_admin_page.dart';
import '../../features/admin/ui/users_page.dart';
import '../../features/admin/ui/create_user_page.dart';
import '../../features/admin/ui/edit_user_page.dart';
import '../../features/common/ui/coming_soon_page.dart';
import '../../features/auth/ui/profile_page.dart';
import '../../features/auth/ui/profile_approval_page.dart';
import '../../features/employees/presentation/pages/employees_page.dart';
import '../../features/employees/presentation/pages/employee_details_page.dart';
import '../../features/org_chart/ui/org_chart_page.dart';
import '../../features/documents/ui/documents_page.dart';
import '../../features/documents/ui/my_documents_page.dart';
import '../../features/documents/ui/my_documents_folder_page.dart';
import '../enums/document_enums.dart';
import '../../features/admin/ui/permission_management_page.dart';
import '../../features/admin/ui/dynamic_config_page.dart';
import '../services/page_access_service.dart';
// Task Management imports
import '../../features/tasks/ui/task_list_page.dart';
import '../../features/tasks/ui/task_detail_page.dart';
import '../../features/tasks/ui/task_calendar_page.dart';
import '../../features/tasks/ui/task_analytics_page.dart';
import '../../features/dashboard/ui/moments_admin_page.dart';
import '../../features/audit_logs/ui/audit_log_page.dart';
import '../../features/letters/ui/letters_page.dart';

class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(this.ref) {
    // Listen to auth state changes
    _authSubscription = ref.listen(authStateProvider, (previous, next) {
      notifyListeners();
    });

    // Listen to setup state changes
    _setupSubscription = ref.listen(shouldShowSetupProvider, (previous, next) {
      notifyListeners();
    });

    // Listen to current user changes
    _userSubscription = ref.listen(currentUserProvider, (previous, next) {
      notifyListeners();
    });
  }

  final Ref ref;
  late final ProviderSubscription _authSubscription;
  late final ProviderSubscription _setupSubscription;
  late final ProviderSubscription _userSubscription;

  @override
  void dispose() {
    _authSubscription.close();
    _setupSubscription.close();
    _userSubscription.close();
    super.dispose();
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = RouterRefreshNotifier(ref);
  final pageAccessService = PageAccessService();

  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: refreshNotifier,
    redirect: (context, state) async {
      final currentPath = state.matchedLocation;
      //print('🔄 Router redirect: currentPath = $currentPath');

      // Get provider states with optimized caching
      final setupAsync = ref.read(shouldShowSetupProvider);
      final authAsync = ref.read(authStateProvider);
      final userModelAsync = ref.read(currentUserProvider);

      // Debug logging for stuck providers
      //print('🔍 Provider states:');
      //print('  - setupAsync.isLoading: ${setupAsync.isLoading}');
      //print('  - authAsync.isLoading: ${authAsync.isLoading}');
      //print('  - setupAsync.hasValue: ${setupAsync.hasValue}');
      //print('  - authAsync.hasValue: ${authAsync.hasValue}');
      if (setupAsync.hasValue) {
        print('  - setupAsync.value: ${setupAsync.value}');
      }
      if (authAsync.hasValue) {
        print('  - authAsync.value: ${authAsync.value?.email ?? 'null'}');
      }

      // Don't redirect to loading page - let pages handle their own loading states
      // Only redirect for actual navigation logic, not loading states

      // If we have both values but setup is still showing as required,
      // and user is authenticated, there might be a cache issue
      if (setupAsync.hasValue &&
          authAsync.hasValue &&
          authAsync.value != null &&
          setupAsync.value == true) {
        print(
          '🚨 Potential cache issue detected: User authenticated but setup still required',
        );
        print('  - Clearing cache and invalidating providers...');

        // Clear cache and invalidate providers
        ref.invalidate(isSetupCompletedProvider);
        ref.invalidate(hasUsersProvider);
        ref.invalidate(shouldShowSetupProvider);

        // Allow one more check, but if still stuck, bypass to dashboard
        final retrySetup = ref.read(shouldShowSetupProvider);
        if (retrySetup.hasValue && retrySetup.value == true) {
          print(
            '🚨 Setup still required after cache clear - forcing dashboard access',
          );
          return '/dashboard';
        }
      }

      // Handle setup flow with better error handling
      return setupAsync.when(
        data: (shouldShowSetup) {
          if (shouldShowSetup) {
            if (currentPath != '/setup-super-admin') {
              //print('🚀 Redirecting to setup-super-admin');
              return '/setup-super-admin';
            }
            return null;
          }

          // Check authentication
          return authAsync.when(
            data: (user) {
              if (user == null) {
                // Not authenticated - redirect to login unless already on auth pages
                final authPages = ['/login', '/register', '/reset-password'];
                if (!authPages.contains(currentPath)) {
                  //print('🚀 Redirecting to login - not authenticated');
                  return '/login';
                }
                return null;
              }

              // User is authenticated
              //print('👤 User authenticated: ${user.email}');

              // Redirect away from auth pages if authenticated
              final authPages = ['/login', '/register', '/reset-password'];
              if (authPages.contains(currentPath)) {
                print('🚀 Redirecting authenticated user away from auth page');

                // Check if profile needs completion (non-blocking)
                return userModelAsync.when(
                  data: (userModel) {
                    if (userModel != null && _isProfileIncomplete(userModel)) {
                      return '/first-time-profile';
                    }
                    return '/dashboard';
                  },
                  loading:
                      () => '/dashboard', // Default to dashboard while loading
                  error:
                      (_, __) => '/dashboard', // Default to dashboard on error
                );
              }

              // Check if user needs to complete profile (non-blocking)
              if (!userModelAsync.isLoading) {
                final userModel = userModelAsync.valueOrNull;
                if (userModel != null) {
                  final needsProfileCompletion = _isProfileIncomplete(
                    userModel,
                  );

                  if (needsProfileCompletion &&
                      currentPath != '/first-time-profile') {
                    print(
                      '🚀 Redirecting to profile completion - incomplete profile detected',
                    );
                    return '/first-time-profile';
                  }

                  if (!needsProfileCompletion &&
                      currentPath == '/first-time-profile') {
                    print('🚀 Profile complete, redirecting to dashboard');
                    return '/dashboard';
                  }

                  // ============= NEW PAGE ACCESS CONTROL =============
                  // Check page-level permissions for the current path
                  return _checkPageAccess(
                    currentPath,
                    userModel,
                    pageAccessService,
                  );
                }
              }

              print('✅ No redirect needed for: $currentPath');
              return null;
            },
            loading: () {
              // Don't redirect to loading page - let current page show loading state
              //print('⏳ Auth loading, staying on current page: $currentPath');
              return null;
            },
            error: (_, __) {
              // On auth error, redirect to login
              print('❌ Auth error, redirecting to login');
              return '/login';
            },
          );
        },
        loading: () {
          // Don't redirect to loading page - let current page show loading state
          print('⏳ Setup loading, staying on current page: $currentPath');
          return null;
        },
        error: (_, __) {
          // On setup error, assume no setup needed and proceed with auth check
          print('❌ Setup check error, proceeding with auth check');
          return authAsync.when(
            data: (user) => user == null ? '/login' : null,
            loading: () => null, // Stay on current page while loading
            error: (_, __) => '/login',
          );
        },
      );
    },
    routes: [
      // Root route
      GoRoute(path: '/', redirect: (context, state) => '/dashboard'),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordPage(),
      ),
      GoRoute(
        path: '/first-time-profile',
        builder: (context, state) => const FirstTimeProfilePage(),
      ),
      GoRoute(
        path: '/access-denied',
        builder:
            (context, state) => AccessDeniedPage(
              requestedPath: state.uri.queryParameters['path'] ?? 'Unknown',
              reason:
                  state.uri.queryParameters['reason'] ??
                  'Insufficient permissions',
            ),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/setup-super-admin',
        builder: (context, state) => const SetupSuperAdminPage(),
      ),

      // Admin Routes
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const UsersPage(),
      ),
      GoRoute(
        path: '/admin/users/create',
        builder: (context, state) {
          // Check if candidate data is passed via query parameters
          final candidateId = state.uri.queryParameters['candidateId'];
          final candidateName = state.uri.queryParameters['candidateName'];
          final candidateEmail = state.uri.queryParameters['candidateEmail'];
          final candidateDepartment =
              state.uri.queryParameters['candidateDepartment'];
          final candidateDesignation =
              state.uri.queryParameters['candidateDesignation'];

          Candidate? candidate;
          if (candidateId != null &&
              candidateName != null &&
              candidateEmail != null) {
            candidate = Candidate.create(
              candidateId: candidateId,
              firstName: candidateName.split(' ').first,
              lastName: candidateName.split(' ').skip(1).join(' '),
              email: candidateEmail,
              phoneNumber: '',
              createdBy: '',
              department: candidateDepartment,
              designation: candidateDesignation,
            );
          }

          return CreateUserPage(candidate: candidate);
        },
      ),
      GoRoute(
        path: '/admin/users/edit/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          final isPending = state.uri.queryParameters['pending'] == 'true';
          return EditUserPage(userId: userId, isPending: isPending);
        },
      ),
      GoRoute(
        path: '/admin/settings',
        builder: (context, state) => const PermissionManagementPage(),
      ),
      GoRoute(
        path: '/admin/config',
        builder: (context, state) => const DynamicConfigPage(),
      ),
      GoRoute(
        path: '/admin/moments',
        builder: (context, state) => MomentsAdminPage(),
      ),
      GoRoute(
        path: '/admin/audit-logs',
        builder: (context, state) => const AuditLogPage(),
      ),

      // Profile Routes
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/profile/approvals',
        builder: (context, state) => const ProfileApprovalPage(),
      ),

      // Feature Routes
      GoRoute(
        path: '/employees',
        name: 'employees',
        builder: (context, state) => const EmployeesPage(),
      ),
      GoRoute(
        path: '/employees/:id',
        name: 'employee-details',
        builder: (context, state) {
          final employeeId = state.pathParameters['id']!;
          return EmployeeDetailsPage(employeeId: employeeId);
        },
      ),
      GoRoute(
        path: '/org-chart',
        builder: (context, state) => const OrgChartPage(),
      ),
      GoRoute(
        path: '/documents',
        builder: (context, state) {
          final category = state.uri.queryParameters['category'];
          final folderId = state.uri.queryParameters['folderId'];
          return DocumentsPage(
            category:
                category != null ? DocumentCategory.fromString(category) : null,
            folderId: folderId,
          );
        },
      ),
      GoRoute(
        path: '/documents/category/:category',
        builder: (context, state) {
          final categoryName = state.pathParameters['category']!;
          // Parse category from string
          final category = DocumentCategory.values.firstWhere(
            (c) => c.name.toLowerCase() == categoryName.toLowerCase(),
            orElse: () => DocumentCategory.shared,
          );
          return DocumentsPage(category: category);
        },
      ),
      GoRoute(
        path: '/documents/folder/:folderId',
        builder: (context, state) {
          final folderId = state.pathParameters['folderId']!;
          return DocumentsPage(folderId: folderId);
        },
      ),
      GoRoute(
        path: '/tasks',
        builder: (context, state) => const TaskListPage(),
      ),
      GoRoute(
        path: '/tasks/:taskId',
        builder: (context, state) {
          final taskId = state.pathParameters['taskId']!;
          return TaskDetailPage(taskId: taskId);
        },
      ),
      GoRoute(
        path: '/tasks/calendar',
        builder: (context, state) => const TaskCalendarPage(),
      ),
      GoRoute(
        path: '/tasks/analytics',
        builder: (context, state) => const TaskAnalyticsPage(),
      ),
      GoRoute(
        path: '/leaves',
        builder:
            (context, state) => const ComingSoonPage(
              title: 'Leave Management',
              description:
                  'Request, approve, and manage employee leave applications.',
              icon: Icons.event_available,
              currentPath: '/leaves',
            ),
      ),
      GoRoute(
        path: '/my-documents',
        builder: (context, state) => const MyDocumentsPage(),
      ),
      GoRoute(
        path: '/my-documents/folder/:folderPath',
        builder: (context, state) {
          final folderPath = Uri.decodeComponent(
            state.pathParameters['folderPath']!,
          );
          return MyDocumentsFolderPage(folderPath: folderPath);
        },
      ),
      GoRoute(
        path: '/letters',
        builder: (context, state) => const LettersPage(),
      ),
    ],
    errorBuilder:
        (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Page Not Found',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text('The page "${state.matchedLocation}" could not be found.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/dashboard'),
                  child: const Text('Go to Dashboard'),
                ),
              ],
            ),
          ),
        ),
  );
});

/// NEW: Check page access permissions
Future<String?> _checkPageAccess(
  String currentPath,
  UserModel userModel,
  PageAccessService pageAccessService,
) async {
  try {
    // Skip access check for certain paths
    final skipPaths = [
      '/login',
      '/register',
      '/reset-password',
      '/first-time-profile',
      '/setup-super-admin',
      '/access-denied',
    ];

    if (skipPaths.any((path) => currentPath.startsWith(path))) {
      return null; // Allow access to auth and setup pages
    }

    //print('🔐 [ROUTER] Checking page access for: $currentPath');

    final hasAccess = await pageAccessService.canAccessPage(
      pagePath: currentPath,
      user: userModel,
    );

    if (!hasAccess) {
      print(
        '❌ [ROUTER] Access denied to $currentPath for ${userModel.role.displayName}',
      );
      final encodedPath = Uri.encodeComponent(currentPath);
      final reason = Uri.encodeComponent(
        'Page access denied for your role: ${userModel.role.displayName}',
      );
      return '/access-denied?path=$encodedPath&reason=$reason';
    }

    print(
      '✅ [ROUTER] Access granted to $currentPath for ${userModel.role.displayName}',
    );
    return null; // Allow access
  } catch (e) {
    print('❌ [ROUTER] Error checking page access: $e');
    // On error, allow access to prevent blocking users
    return null;
  }
}

/// Check if user profile is incomplete
bool _isProfileIncomplete(UserModel userModel) {
  // Check required fields for profile completion
  final missingFields = <String>[];

  if (userModel.displayName.isEmpty) {
    missingFields.add('displayName');
  }

  if (userModel.department == null || userModel.department!.isEmpty) {
    missingFields.add('department');
  }

  if (userModel.position == null || userModel.position!.isEmpty) {
    missingFields.add('position');
  }

  final isIncomplete = missingFields.isNotEmpty;

  if (isIncomplete) {
    print('Profile incomplete. Missing fields: ${missingFields.join(', ')}');
  }

  return isIncomplete;
}

// Placeholder page for routes that haven't been implemented yet
class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              '$title Page',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'This page is under construction.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
