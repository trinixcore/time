import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../shared/providers/page_access_providers.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/user_model.dart';
import '../../../core/enums/user_role.dart';
import '../../../features/admin/ui/users_page.dart';
import '../../../features/admin/ui/create_user_page.dart';
import '../../../features/admin/ui/edit_user_page.dart';
import '../../../features/admin/ui/permission_management_page.dart';
import '../../../features/dashboard/ui/moments_admin_page.dart';
import '../../../features/employees/presentation/pages/employees_page.dart';
import '../../../features/org_chart/ui/org_chart_page.dart';
import '../../../features/documents/ui/documents_page.dart';
import '../../../features/documents/ui/my_documents_page.dart';
import '../../../features/tasks/ui/task_list_page.dart';
import '../../../features/auth/ui/profile_page.dart';
import '../../../features/auth/ui/profile_approval_page.dart';
import '../../../core/enums/document_enums.dart';
import '../../../core/models/profile_update_request.dart';
import '../../../shared/widgets/enhanced_user_hierarchy_dialog.dart';
import '../../../shared/widgets/user_hierarchy_dialog.dart';
import '../../../shared/providers/auth_providers.dart' as auth_providers;

class DashboardScaffold extends ConsumerStatefulWidget {
  final Widget child;
  final String currentPath;

  const DashboardScaffold({
    super.key,
    required this.child,
    required this.currentPath,
  });

  @override
  ConsumerState<DashboardScaffold> createState() => _DashboardScaffoldState();
}

class _DashboardScaffoldState extends ConsumerState<DashboardScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider);
    final isSuperAdmin = ref.watch(isSuperAdminProvider);
    final canManageUsers = ref.watch(canManageUsersProvider);

    // Watch page access providers
    final canAccessEmployees = ref.watch(canAccessEmployeesProvider);
    final canAccessMyDocuments = ref.watch(canAccessMyDocumentsProvider);
    final canAccessDocuments = ref.watch(canAccessDocumentsProvider);
    final canAccessTasks = ref.watch(canAccessTasksProvider);
    final canAccessLeaves = ref.watch(canAccessLeavesProvider);
    final canAccessUserManagement = ref.watch(canAccessUserManagementProvider);
    final canAccessProfileApprovals = ref.watch(
      canAccessProfileApprovalsProvider,
    );
    final canAccessSystemSettings = ref.watch(canAccessSystemSettingsProvider);
    final canAccessOrgChart = ref.watch(canAccessOrgChartProvider);
    final canAccessMoments = ref.watch(canAccessMomentsProvider);
    final canAccessAuditLogs = ref.watch(canAccessAuditLogsProvider);
    final canAccessDynamicConfig = ref.watch(canAccessDynamicConfigProvider);
    final canAccessLetters = ref.watch(canAccessLettersProvider);

    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(theme, currentUser),
      drawer: _buildDrawer(theme, isSuperAdmin, canManageUsers, {
        'employees': canAccessEmployees,
        'myDocuments': canAccessMyDocuments,
        'documents': canAccessDocuments,
        'tasks': canAccessTasks,
        'leaves': canAccessLeaves,
        'userManagement': canAccessUserManagement,
        'profileApprovals': canAccessProfileApprovals,
        'systemSettings': canAccessSystemSettings,
        'orgChart': canAccessOrgChart,
        'moments': canAccessMoments,
        'auditLogs': canAccessAuditLogs,
        'dynamicConfig': canAccessDynamicConfig,
      }, canAccessLetters),
      body: Row(
        children: [
          // Side Navigation (Desktop)
          if (MediaQuery.of(context).size.width >= 1024)
            _buildSideNavigation(theme, isSuperAdmin, canManageUsers, {
              'employees': canAccessEmployees,
              'myDocuments': canAccessMyDocuments,
              'documents': canAccessDocuments,
              'tasks': canAccessTasks,
              'leaves': canAccessLeaves,
              'userManagement': canAccessUserManagement,
              'profileApprovals': canAccessProfileApprovals,
              'systemSettings': canAccessSystemSettings,
              'orgChart': canAccessOrgChart,
              'moments': canAccessMoments,
              'auditLogs': canAccessAuditLogs,
              'dynamicConfig': canAccessDynamicConfig,
            }, canAccessLetters),

          // Main Content
          Expanded(
            child: Container(
              color: theme.colorScheme.surfaceContainerLowest,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    ThemeData theme,
    AsyncValue<dynamic> currentUser,
  ) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Image.asset(
              'assets/images/ICON.png',
              width: 36,
              height: 36,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 8),
          // Make title responsive to prevent overflow
          Flexible(
            child: Text(
              'TRINIX Internal Management Engine',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
      backgroundColor: theme.colorScheme.surface,
      elevation: 1,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
      leading:
          MediaQuery.of(context).size.width < 1024
              ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              )
              : null,
      automaticallyImplyLeading: MediaQuery.of(context).size.width < 1024,
      actions: [
        // Notifications
        IconButton(
          icon: Badge(smallSize: 8, child: Icon(Icons.notifications_outlined)),
          onPressed: () {
            // TODO: Show notifications
          },
        ),
        const SizedBox(width: 8),

        // User Menu
        currentUser.when(
          data:
              (user) =>
                  user != null
                      ? PopupMenuButton<String>(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: theme.colorScheme.primary,
                              child: Text(
                                user.displayName
                                        ?.substring(0, 1)
                                        .toUpperCase() ??
                                    'U',
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (MediaQuery.of(context).size.width >= 768) ...[
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      user.displayName ?? 'User',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    Text(
                                      _buildPositionAndRole(user),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color:
                                                theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Icon(
                              Icons.arrow_drop_down,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                        itemBuilder:
                            (context) => [
                              PopupMenuItem(
                                value: 'profile',
                                child: ListTile(
                                  leading: const Icon(Icons.person_outline),
                                  title: const Text('Profile'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              PopupMenuItem(
                                value: 'settings',
                                child: ListTile(
                                  leading: const Icon(Icons.settings_outlined),
                                  title: const Text('Settings'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              const PopupMenuDivider(),
                              PopupMenuItem(
                                value: 'logout',
                                child: ListTile(
                                  leading: Icon(
                                    Icons.logout,
                                    color: theme.colorScheme.error,
                                  ),
                                  title: Text(
                                    'Sign Out',
                                    style: TextStyle(
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                        onSelected: _handleUserMenuAction,
                      )
                      : const SizedBox.shrink(),
          loading: () => const CircularProgressIndicator(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildSideNavigation(
    ThemeData theme,
    AsyncValue<bool> isSuperAdmin,
    AsyncValue<bool> canManageUsers,
    Map<String, AsyncValue<bool>> pageAccess,
    AsyncValue<bool> canAccessLetters,
  ) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Logo/Brand Section
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.shadow.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.elasticOut,
                        child: Image.asset(
                          'assets/images/ICON.png',
                          width: 56,
                          height: 56,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'TRINIX Internal Management Engine',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                // Dashboard is always visible
                _buildNavItem(
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard,
                  label: 'Dashboard',
                  path: '/dashboard',
                  theme: theme,
                ),

                // Employees - conditionally visible based on page access
                pageAccess['employees']?.when(
                      data:
                          (canAccess) =>
                              canAccess
                                  ? _buildNavItem(
                                    icon: Icons.people_outline,
                                    selectedIcon: Icons.people,
                                    label: 'Employees',
                                    path: '/employees',
                                    theme: theme,
                                  )
                                  : const SizedBox.shrink(),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ) ??
                    const SizedBox.shrink(),

                // My Documents - conditionally visible
                pageAccess['myDocuments']?.when(
                      data:
                          (canAccess) =>
                              canAccess
                                  ? Consumer(
                                    builder: (context, ref, child) {
                                      final currentUser = ref.watch(
                                        currentUserProvider,
                                      );
                                      return currentUser.when(
                                        data: (user) {
                                          if (user != null &&
                                              user.employeeId != null &&
                                              user.employeeId!.isNotEmpty) {
                                            return _buildNavItem(
                                              icon: Icons.folder_outlined,
                                              selectedIcon: Icons.folder,
                                              label: '📁 My Documents',
                                              path: '/my-documents',
                                              theme: theme,
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        },
                                        loading: () => const SizedBox.shrink(),
                                        error:
                                            (_, __) => const SizedBox.shrink(),
                                      );
                                    },
                                  )
                                  : const SizedBox.shrink(),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ) ??
                    const SizedBox.shrink(),

                // Documents - conditionally visible
                pageAccess['documents']?.when(
                      data:
                          (canAccess) =>
                              canAccess
                                  ? _buildNavItem(
                                    icon: Icons.description_outlined,
                                    selectedIcon: Icons.description,
                                    label: 'Documents',
                                    path: '/documents',
                                    theme: theme,
                                  )
                                  : const SizedBox.shrink(),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ) ??
                    const SizedBox.shrink(),

                // Tasks - conditionally visible
                pageAccess['tasks']?.when(
                      data:
                          (canAccess) =>
                              canAccess
                                  ? _buildNavItem(
                                    icon: Icons.task_outlined,
                                    selectedIcon: Icons.task,
                                    label: 'Tasks',
                                    path: '/tasks',
                                    theme: theme,
                                  )
                                  : const SizedBox.shrink(),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ) ??
                    const SizedBox.shrink(),

                // Leaves - conditionally visible
                // pageAccess['leaves']?.when(
                //       data:
                //           (canAccess) =>
                //               canAccess
                //                   ? _buildNavItem(
                //                     icon: Icons.event_available_outlined,
                //                     selectedIcon: Icons.event_available,
                //                     label: 'Leaves',
                //                     path: '/leaves',
                //                     theme: theme,
                //                   )
                //                   : const SizedBox.shrink(),
                //       loading: () => const SizedBox.shrink(),
                //       error: (_, __) => const SizedBox.shrink(),
                //     ) ??
                //     const SizedBox.shrink(),

                // Letters & Signatures - conditionally visible
                canAccessLetters.when(
                  data:
                      (canAccess) =>
                          canAccess
                              ? _buildNavItem(
                                icon: Icons.mail_outline,
                                selectedIcon: Icons.mail,
                                label: 'Letters & Signatures',
                                path: '/letters',
                                theme: theme,
                              )
                              : const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                // Admin Section - show if user can manage users OR has access to any admin pages
                if (canManageUsers.when(
                      data: (canManage) => canManage,
                      loading: () => false,
                      error: (_, __) => false,
                    ) ||
                    pageAccess['userManagement']?.when(
                          data: (canAccess) => canAccess,
                          loading: () => false,
                          error: (_, __) => false,
                        ) ==
                        true ||
                    pageAccess['profileApprovals']?.when(
                          data: (canAccess) => canAccess,
                          loading: () => false,
                          error: (_, __) => false,
                        ) ==
                        true ||
                    pageAccess['systemSettings']?.when(
                          data: (canAccess) => canAccess,
                          loading: () => false,
                          error: (_, __) => false,
                        ) ==
                        true ||
                    pageAccess['moments']?.when(
                          data: (canAccess) => canAccess,
                          loading: () => false,
                          error: (_, __) => false,
                        ) ==
                        true ||
                    pageAccess['auditLogs']?.when(
                          data: (canAccess) => canAccess,
                          loading: () => false,
                          error: (_, __) => false,
                        ) ==
                        true ||
                    pageAccess['dynamicConfig']?.when(
                          data: (canAccess) => canAccess,
                          loading: () => false,
                          error: (_, __) => false,
                        ) ==
                        true) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      'Administration',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // User Management - conditionally visible
                  pageAccess['userManagement']?.when(
                        data:
                            (canAccess) =>
                                canAccess
                                    ? _buildNavItem(
                                      icon: Icons.admin_panel_settings_outlined,
                                      selectedIcon: Icons.admin_panel_settings,
                                      label: 'User Management',
                                      path: '/admin/users',
                                      theme: theme,
                                    )
                                    : const SizedBox.shrink(),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ) ??
                      const SizedBox.shrink(),

                  // Profile Approvals - conditionally visible
                  pageAccess['profileApprovals']?.when(
                        data:
                            (canAccess) =>
                                canAccess
                                    ? _buildNavItem(
                                      icon: Icons.approval_outlined,
                                      selectedIcon: Icons.approval,
                                      label: 'Profile Approvals',
                                      path: '/profile/approvals',
                                      theme: theme,
                                    )
                                    : const SizedBox.shrink(),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ) ??
                      const SizedBox.shrink(),

                  // System Settings - conditionally visible
                  pageAccess['systemSettings']?.when(
                        data:
                            (canAccess) =>
                                canAccess
                                    ? _buildNavItem(
                                      icon: Icons.settings_outlined,
                                      selectedIcon: Icons.settings,
                                      label: 'System Settings',
                                      path: '/admin/settings',
                                      theme: theme,
                                    )
                                    : const SizedBox.shrink(),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ) ??
                      const SizedBox.shrink(),

                  // Dynamic Configuration - conditionally visible (for super admins)
                  pageAccess['dynamicConfig']?.when(
                        data:
                            (canAccess) =>
                                canAccess
                                    ? _buildNavItem(
                                      icon: Icons.build_outlined,
                                      selectedIcon: Icons.build,
                                      label: 'Dynamic Config',
                                      path: '/admin/config',
                                      theme: theme,
                                    )
                                    : const SizedBox.shrink(),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ) ??
                      const SizedBox.shrink(),

                  // Moments - conditionally visible
                  pageAccess['moments']?.when(
                        data:
                            (canAccess) =>
                                canAccess
                                    ? _buildNavItem(
                                      icon: Icons.photo_library_outlined,
                                      selectedIcon: Icons.photo_library,
                                      label: 'Moments',
                                      path: '/admin/moments',
                                      theme: theme,
                                    )
                                    : const SizedBox.shrink(),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ) ??
                      const SizedBox.shrink(),

                  // Audit Logs - conditionally visible (for admins)
                  pageAccess['auditLogs']?.when(
                        data:
                            (canAccess) =>
                                canAccess
                                    ? _buildNavItem(
                                      icon: Icons.security_outlined,
                                      selectedIcon: Icons.security,
                                      label: 'Audit Logs',
                                      path: '/admin/audit-logs',
                                      theme: theme,
                                    )
                                    : const SizedBox.shrink(),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ) ??
                      const SizedBox.shrink(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(
    ThemeData theme,
    AsyncValue<bool> isSuperAdmin,
    AsyncValue<bool> canManageUsers,
    Map<String, AsyncValue<bool>> pageAccess,
    AsyncValue<bool> canAccessLetters,
  ) {
    return Drawer(
      child: _buildSideNavigation(
        theme,
        isSuperAdmin,
        canManageUsers,
        pageAccess,
        canAccessLetters,
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required String path,
    required ThemeData theme,
  }) {
    final isSelected = widget.currentPath.startsWith(path);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        leading: Icon(
          isSelected ? selectedIcon : icon,
          color:
              isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
        ),
        title: Text(
          label,
          style: TextStyle(
            color:
                isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        selected: isSelected,
        selectedTileColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          context.go(path);
          if (MediaQuery.of(context).size.width < 1024) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  String _buildPositionAndRole(dynamic user) {
    final position = user.position ?? 'Not assigned';
    final role = _formatRoleName(user.role);
    return '$position - $role';
  }

  String _formatRoleName(dynamic role) {
    if (role == null) return 'User';
    final roleStr = role.toString().split('.').last;
    switch (roleStr) {
      case 'superAdmin':
        return 'Super Admin';
      case 'admin':
        return 'Admin';
      case 'hr':
        return 'HR';
      case 'manager':
        return 'Manager';
      case 'employee':
        return 'Employee';
      default:
        return roleStr;
    }
  }

  void _handleUserMenuAction(String action) {
    switch (action) {
      case 'profile':
        context.go('/profile');
        break;
      case 'settings':
        context.go('/settings');
        break;
      case 'logout':
        _handleSignOut();
        break;
    }
  }

  Future<void> _handleSignOut() async {
    try {
      await AuthService().signOut();
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign out: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
