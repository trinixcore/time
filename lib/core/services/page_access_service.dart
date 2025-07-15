import '../models/permission_config_model.dart';
import '../models/user_model.dart';
import '../enums/user_role.dart';
import '../utils/logger.dart';
import 'permission_management_service.dart';

/// Service for managing page-level access control
class PageAccessService {
  static final PageAccessService _instance = PageAccessService._internal();
  factory PageAccessService() => _instance;
  PageAccessService._internal();

  final PermissionManagementService _permissionService =
      PermissionManagementService();

  /// Check if a user can access a specific page
  Future<bool> canAccessPage({
    required String pagePath,
    required UserModel user,
  }) async {
    try {
      //print(
      //'🔐 [PAGE ACCESS] Checking access for ${user.role.displayName} to $pagePath',
      //);

      // Get the user's role permission configuration
      final permissionConfig = await _permissionService.getPermissionConfig(
        user.role,
      );

      if (permissionConfig == null) {
        //print(
        //'⚠️ [PAGE ACCESS] No permission config found for ${user.role.displayName}, using defaults',
        //);
        return _checkDefaultPageAccess(pagePath, user.role);
      }

      final pagePermissions = permissionConfig.systemConfig.pagePermissions;
      final systemConfig = permissionConfig.systemConfig;

      //print(
      //'🔍 [PAGE ACCESS] Permission config loaded for ${user.role.displayName}',
      //);
      //print(
      //'🔍 [PAGE ACCESS] canAccessAuditLogs: ${pagePermissions.canAccessAuditLogs}',
      //);
      //print(
      //'🔍 [PAGE ACCESS] canAccessMoments: ${pagePermissions.canAccessMoments}',
      //);

      // Check page-level permission first
      bool hasPageAccess = _checkPagePermission(pagePath, pagePermissions);

      if (!hasPageAccess) {
        //print(
        //'❌ [PAGE ACCESS] Page access denied for ${user.role.displayName} to $pagePath',
        //);
        return false;
      }

      // Additional permission checks for specific pages
      if (pagePath.toLowerCase().contains('employees')) {
        // For employees page, check if they have either manage employees permission
        // or any specific employee-related permission
        bool hasEmployeeAccess =
            systemConfig.canManageEmployees ||
            systemConfig.canAddEmployees ||
            systemConfig.canViewEmployeeDetails ||
            systemConfig.canEditEmployeeProfiles ||
            systemConfig.canManageEmployeeDocuments;

        if (!hasEmployeeAccess) {
          //print(
          //'❌ [PAGE ACCESS] Employee management access denied for ${user.role.displayName}',
          //);
          return false;
        }
      }

      // Check employee ID-based restrictions if enabled
      if (pagePermissions.useEmployeeIdRestriction && user.employeeId != null) {
        bool employeeCanAccess = pagePermissions.canEmployeeAccess(
          user.employeeId,
        );

        if (!employeeCanAccess) {
          //print(
          //'❌ [PAGE ACCESS] Employee ID restriction blocked access for ${user.employeeId} to $pagePath',
          //);
          return false;
        }
      }

      //print(
      //'✅ [PAGE ACCESS] Access granted for ${user.role.displayName} (${user.employeeId}) to $pagePath',
      //);
      return true;
    } catch (e) {
      //print('❌ [PAGE ACCESS] Error checking page access: $e');
      // Fall back to role-based default permissions
      return _checkDefaultPageAccess(pagePath, user.role);
    }
  }

  /// Check page permission based on path
  bool _checkPagePermission(
    String pagePath,
    PagePermissionConfig pagePermissions,
  ) {
    // Normalize page path for comparison
    final normalizedPath = pagePath.toLowerCase().replaceAll('/', '');

    //print('🔍 [PAGE ACCESS] Checking permission for path: $pagePath');
    //print('🔍 [PAGE ACCESS] Normalized path: $normalizedPath');
    //print(
    //'🔍 [PAGE ACCESS] canAccessAuditLogs: ${pagePermissions.canAccessAuditLogs}',
    //);

    // Test case for audit logs path
    if (pagePath == 'admin/audit-logs') {
      print('🔍 [PAGE ACCESS] Testing audit logs path normalization');
      //print('🔍 [PAGE ACCESS] Original: $pagePath');
      //print('🔍 [PAGE ACCESS] Normalized: $normalizedPath');
      print('🔍 [PAGE ACCESS] Expected: adminaudit-logs');
      //print('🔍 [PAGE ACCESS] Match: ${normalizedPath == 'adminaudit-logs'}');
    }

    // Allow all /tasks/* subroutes if canAccessTasks is true
    if (normalizedPath.startsWith('tasks')) {
      return pagePermissions.canAccessTasks;
    }

    switch (normalizedPath) {
      case 'dashboard':
        return pagePermissions.canAccessDashboard;
      case 'employees':
        return pagePermissions.canAccessEmployees;
      case 'my-documents':
      case 'mydocuments':
        return pagePermissions.canAccessMyDocuments;
      case 'documents':
        return pagePermissions.canAccessDocuments;
      case 'leaves':
        return pagePermissions.canAccessLeaves;
      case 'admin':
      case 'adminusers':
      case 'admin/users':
        return pagePermissions.canAccessUserManagement;
      case 'profile':
        return pagePermissions.canAccessProfile;
      case 'profileapprovals':
      case 'profile/approvals':
        return pagePermissions.canAccessProfileApprovals;
      case 'settings':
      case 'adminsettings':
      case 'admin/settings':
        return pagePermissions.canAccessSystemSettings;
      case 'org-chart':
      case 'orgchart':
        return pagePermissions.canAccessOrgChart;
      case 'adminmoments':
      case 'admin/moments':
        return pagePermissions.canAccessMoments;
      case 'adminaudit-logs':
      case 'admin/audit-logs':
        //print(
        //'🔍 [PAGE ACCESS] Found audit logs path, returning: ${pagePermissions.canAccessAuditLogs}',
        //);
        return pagePermissions.canAccessAuditLogs;
      case 'adminconfig':
      case 'admin/config':
        return pagePermissions
            .canAccessDynamicConfig; // Use specific dynamic config permission
      case 'letters':
        return pagePermissions.canAccessLetters;
      default:
        // For unknown pages, check if it's an admin page
        if (normalizedPath.startsWith('admin')) {
          print(
            '🔍 [PAGE ACCESS] Admin path detected, checking specific permissions',
          );
          // Check specific admin page permissions instead of using OR logic
          if (normalizedPath.contains('moments')) {
            //print(
            //'🔍 [PAGE ACCESS] Moments path detected, returning: ${pagePermissions.canAccessMoments}',
            //);
            return pagePermissions.canAccessMoments;
          }
          if (normalizedPath.contains('audit-logs')) {
            //print(
            //'🔍 [PAGE ACCESS] Audit logs path detected, returning: ${pagePermissions.canAccessAuditLogs}',
            //);
            return pagePermissions.canAccessAuditLogs;
          }
          if (normalizedPath.contains('users')) {
            return pagePermissions.canAccessUserManagement;
          }
          if (normalizedPath.contains('settings')) {
            return pagePermissions.canAccessSystemSettings;
          }
          if (normalizedPath.contains('config')) {
            return pagePermissions.canAccessDynamicConfig;
          }
          // For other admin pages, deny access by default unless explicitly allowed
          //print('🔍 [PAGE ACCESS] Unknown admin path, denying access');
          return false;
        }
        // Default to allowing access for unrecognized pages
        //print('🔍 [PAGE ACCESS] Unknown path, allowing access');
        return true;
    }
  }

  /// Default page access based on role (fallback when no config exists)
  bool _checkDefaultPageAccess(String pagePath, UserRole role) {
    final normalizedPath = pagePath.toLowerCase().replaceAll('/', '');

    switch (normalizedPath) {
      case 'dashboard':
        return true; // Everyone can access dashboard

      case 'employees':
        return role.canViewEmployeeDetails ||
            role.isSuperAdmin ||
            role.isAdmin ||
            role.isHR ||
            role.isManager;

      case 'my-documents':
      case 'mydocuments':
        return true; // Everyone can access their own documents

      case 'documents':
        return role.canManageEmployeeDocuments ||
            role.isSuperAdmin ||
            role.isAdmin ||
            role.isHR;

      case 'tasks':
        return role.canManageTasks ||
            role.canAssignTasks ||
            role.canViewTeamTasks ||
            role.isSuperAdmin ||
            role.isAdmin ||
            role.isManager;

      case 'leaves':
        return role.canApproveLeaves ||
            role.isSuperAdmin ||
            role.isAdmin ||
            role.isHR ||
            role.isManager;

      case 'admin':
      case 'adminusers':
      case 'admin/users':
        return role.canManageUsers || role.isSuperAdmin || role.isAdmin;

      case 'profileapprovals':
      case 'profile/approvals':
        return role.canManageUsers ||
            role.isSuperAdmin ||
            role.isAdmin ||
            role.isHR;

      case 'settings':
      case 'adminsettings':
      case 'admin/settings':
        return role.isSuperAdmin;

      case 'profile':
        return true; // Everyone can access their profile

      case 'org-chart':
      case 'orgchart':
        return role.canViewEmployeeDetails ||
            role.isSuperAdmin ||
            role.isAdmin ||
            role.isHR ||
            role.isManager;

      case 'adminmoments':
      case 'admin/moments':
        return role.isSuperAdmin ||
            role.isAdmin; // Only super admin and admin can access moments
      case 'adminaudit-logs':
      case 'admin/audit-logs':
        return role.isSuperAdmin ||
            role.isAdmin ||
            role.isHR ||
            role.isManager ||
            role.isTeamLead; // Only privileged roles can access audit logs
      case 'adminconfig':
      case 'admin/config':
        return role.isSuperAdmin; // Only super admin can access dynamic config
      case 'letters':
        return role.isSuperAdmin ||
            role.isAdmin ||
            role.isHR; // Letters access for privileged roles
      default:
        return true; // Default to allowing access
    }
  }

  /// Get all accessible pages for a user
  Future<Map<String, bool>> getAccessiblePages(UserModel user) async {
    final pages = [
      'dashboard',
      'employees',
      'my-documents',
      'documents',
      'tasks',
      'leaves',
      'admin/users',
      'profile/approvals',
      'admin/settings',
      'admin/config',
      'profile',
      'org-chart',
      'admin/moments',
      'admin/audit-logs',
    ];

    final accessMap = <String, bool>{};

    for (final page in pages) {
      accessMap[page] = await canAccessPage(pagePath: page, user: user);
    }

    return accessMap;
  }

  /// Get page restrictions summary for a user
  Future<Map<String, dynamic>> getPageRestrictionsSummary(
    UserModel user,
  ) async {
    try {
      final permissionConfig = await _permissionService.getPermissionConfig(
        user.role,
      );

      if (permissionConfig == null) {
        return {
          'hasRestrictions': false,
          'useEmployeeIdRestriction': false,
          'allowedEmployeeIds': <String>[],
          'restrictedEmployeeIds': <String>[],
          'accessiblePages': await getAccessiblePages(user),
        };
      }

      final pagePermissions = permissionConfig.systemConfig.pagePermissions;

      return {
        'hasRestrictions': pagePermissions.useEmployeeIdRestriction,
        'useEmployeeIdRestriction': pagePermissions.useEmployeeIdRestriction,
        'allowedEmployeeIds': pagePermissions.allowedEmployeeIds,
        'restrictedEmployeeIds': pagePermissions.restrictedEmployeeIds,
        'accessiblePages': await getAccessiblePages(user),
        'employeeCanAccess':
            user.employeeId != null
                ? pagePermissions.canEmployeeAccess(user.employeeId)
                : true,
      };
    } catch (e) {
      print('❌ [PAGE ACCESS] Error getting restrictions summary: $e');
      return {
        'hasRestrictions': false,
        'useEmployeeIdRestriction': false,
        'allowedEmployeeIds': <String>[],
        'restrictedEmployeeIds': <String>[],
        'accessiblePages': await getAccessiblePages(user),
        'employeeCanAccess': true,
      };
    }
  }

  /// Clear the permission cache (useful when permissions are updated)
  void clearCache() {
    _permissionService.clearCache();
    print('🗑️ [PAGE ACCESS] Cleared page access cache');
  }
}
