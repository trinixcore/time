import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/page_access_service.dart';
import '../../core/models/user_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/permission_management_service.dart';
import 'auth_providers.dart';

/// Provider for the page access service
final pageAccessServiceProvider = Provider<PageAccessService>((ref) {
  return PageAccessService();
});

/// Provider for page accessibility map
final pageAccessibilityProvider = FutureProvider<Map<String, bool>>((
  ref,
) async {
  final pageAccessService = ref.read(pageAccessServiceProvider);
  final currentUser = await ref.watch(currentUserProvider.future);

  if (currentUser == null) {
    return <String, bool>{};
  }

  return await pageAccessService.getAccessiblePages(currentUser);
});

/// Provider for specific page access
final pageAccessProvider = FutureProvider.family<bool, String>((
  ref,
  pagePath,
) async {
  final pageAccessService = ref.read(pageAccessServiceProvider);
  final currentUser = await ref.watch(currentUserProvider.future);

  if (currentUser == null) {
    return false;
  }

  return await pageAccessService.canAccessPage(
    pagePath: pagePath,
    user: currentUser,
  );
});

/// Provider for page restrictions summary
final pageRestrictionsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final pageAccessService = ref.read(pageAccessServiceProvider);
  final currentUser = await ref.watch(currentUserProvider.future);

  if (currentUser == null) {
    return <String, dynamic>{};
  }

  return await pageAccessService.getPageRestrictionsSummary(currentUser);
});

/// Convenience providers for specific pages
final canAccessDashboardProvider = FutureProvider<bool>((ref) async {
  return await ref.watch(pageAccessProvider('dashboard').future);
});

final canAccessEmployeesProvider = FutureProvider<bool>((ref) async {
  return await ref.watch(pageAccessProvider('employees').future);
});

final canAccessMyDocumentsProvider = FutureProvider<bool>((ref) async {
  return await ref.watch(pageAccessProvider('my-documents').future);
});

final canAccessDocumentsProvider = FutureProvider<bool>((ref) async {
  return await ref.watch(pageAccessProvider('documents').future);
});

final canAccessTasksProvider = FutureProvider<bool>((ref) async {
  return await ref.watch(pageAccessProvider('tasks').future);
});

final canAccessLeavesProvider = FutureProvider<bool>((ref) async {
  return await ref.watch(pageAccessProvider('leaves').future);
});

final canAccessUserManagementProvider = FutureProvider<bool>((ref) async {
  return await ref.watch(pageAccessProvider('admin/users').future);
});

final canAccessProfileApprovalsProvider = FutureProvider<bool>((ref) async {
  return await ref.watch(pageAccessProvider('profile/approvals').future);
});

final canAccessSystemSettingsProvider = FutureProvider<bool>((ref) async {
  return await ref.watch(pageAccessProvider('admin/settings').future);
});

final canAccessOrgChartProvider = FutureProvider<bool>((ref) async {
  return await ref.watch(pageAccessProvider('org-chart').future);
});

final canAccessMomentsProvider = FutureProvider<bool>((ref) async {
  return await ref.watch(pageAccessProvider('admin/moments').future);
});

final canAccessAuditLogsProvider = FutureProvider<bool>((ref) async {
  return await ref.watch(pageAccessProvider('admin/audit-logs').future);
});

final canAccessDynamicConfigProvider = FutureProvider<bool>((ref) async {
  return await ref.watch(pageAccessProvider('admin/config').future);
});

final canAccessLettersProvider = FutureProvider<bool>((ref) async {
  return await ref.watch(pageAccessProvider('letters').future);
});

/// Signature Management Permission Providers
final canManageSignaturesProvider = FutureProvider<bool>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final permissionService = ref.watch(permissionManagementServiceProvider);

  try {
    final currentUser = await authService.getCurrentUserModel();
    if (currentUser == null) return false;

    final systemPermissions = await permissionService
        .getEffectiveSystemPermissionsAsync(currentUser.role);

    return systemPermissions.canManageSignatures;
  } catch (e) {
    print('❌ [PROVIDER] Error checking signature management permission: $e');
    return false;
  }
});

final canAddSignaturesProvider = FutureProvider<bool>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final permissionService = ref.watch(permissionManagementServiceProvider);

  try {
    final currentUser = await authService.getCurrentUserModel();
    if (currentUser == null) return false;

    final systemPermissions = await permissionService
        .getEffectiveSystemPermissionsAsync(currentUser.role);

    return systemPermissions.canAddSignatures;
  } catch (e) {
    print('❌ [PROVIDER] Error checking signature add permission: $e');
    return false;
  }
});

final canEditSignaturesProvider = FutureProvider<bool>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final permissionService = ref.watch(permissionManagementServiceProvider);

  try {
    final currentUser = await authService.getCurrentUserModel();
    if (currentUser == null) return false;

    final systemPermissions = await permissionService
        .getEffectiveSystemPermissionsAsync(currentUser.role);

    return systemPermissions.canEditSignatures;
  } catch (e) {
    print('❌ [PROVIDER] Error checking signature edit permission: $e');
    return false;
  }
});

final canDeleteSignaturesProvider = FutureProvider<bool>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final permissionService = ref.watch(permissionManagementServiceProvider);

  try {
    final currentUser = await authService.getCurrentUserModel();
    if (currentUser == null) return false;

    final systemPermissions = await permissionService
        .getEffectiveSystemPermissionsAsync(currentUser.role);

    return systemPermissions.canDeleteSignatures;
  } catch (e) {
    print('❌ [PROVIDER] Error checking signature delete permission: $e');
    return false;
  }
});

/// Provider to clear page access cache
final clearPageAccessCacheProvider = Provider<VoidCallback>((ref) {
  return () {
    final pageAccessService = ref.read(pageAccessServiceProvider);
    pageAccessService.clearCache();

    // Invalidate all page access providers
    ref.invalidate(pageAccessibilityProvider);
    ref.invalidate(pageAccessProvider);
    ref.invalidate(pageRestrictionsProvider);
    ref.invalidate(canAccessDashboardProvider);
    ref.invalidate(canAccessEmployeesProvider);
    ref.invalidate(canAccessMyDocumentsProvider);
    ref.invalidate(canAccessDocumentsProvider);
    ref.invalidate(canAccessTasksProvider);
    ref.invalidate(canAccessLeavesProvider);
    ref.invalidate(canAccessUserManagementProvider);
    ref.invalidate(canAccessProfileApprovalsProvider);
    ref.invalidate(canAccessSystemSettingsProvider);
    ref.invalidate(canAccessOrgChartProvider);
    ref.invalidate(canAccessMomentsProvider);
    ref.invalidate(canAccessAuditLogsProvider);
    ref.invalidate(canAccessDynamicConfigProvider);
    ref.invalidate(canAccessLettersProvider);
    ref.invalidate(canManageSignaturesProvider);
    ref.invalidate(canAddSignaturesProvider);
    ref.invalidate(canEditSignaturesProvider);
    ref.invalidate(canDeleteSignaturesProvider);
  };
});
