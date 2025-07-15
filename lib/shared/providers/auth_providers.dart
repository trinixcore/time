import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/models/user_model.dart';
import '../../core/enums/user_role.dart';
import '../../core/enums/document_enums.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/permission_management_service.dart';
import '../../core/models/permission_config_model.dart';
import '../../core/utils/document_permissions.dart';

// Firebase Auth State Provider
final authStateProvider = StreamProvider<User?>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.auth.authStateChanges();
});

// Current Firebase User Provider (for basic auth info)
final currentFirebaseUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Current User Model Provider (for full user data)
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) async {
      if (user == null) return null;
      return await AuthService().getCurrentUserModel();
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Current User Role Provider
final currentUserRoleProvider = FutureProvider<UserRole?>((ref) async {
  final userModel = await ref.watch(currentUserProvider.future);
  return userModel?.role;
});

// Authentication Status Provider
final authStatusProvider = Provider<AsyncValue<AuthStatus>>((ref) {
  final authState = ref.watch(authStateProvider);
  final userModel = ref.watch(currentUserProvider);

  return authState.when(
    data: (user) {
      if (user == null) {
        return const AsyncValue.data(AuthStatus.unauthenticated);
      }

      return userModel.when(
        data: (model) {
          if (model == null) {
            return const AsyncValue.data(AuthStatus.unauthenticated);
          }
          if (!model.isActive) {
            return const AsyncValue.data(AuthStatus.deactivated);
          }
          return const AsyncValue.data(AuthStatus.authenticated);
        },
        loading: () => const AsyncValue.loading(),
        error: (error, stack) => AsyncValue.error(error, stack),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Setup Completion Check Provider (with caching)
final isSetupCompletedProvider = FutureProvider<bool>((ref) async {
  final firebaseService = ref.watch(firebaseServiceProvider);
  try {
    return await firebaseService.isSetupCompleted().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        print('⚠️ Setup completion check timed out - assuming not completed');
        return false;
      },
    );
  } catch (e) {
    print('❌ Error checking setup completion: $e');
    return false;
  }
});

// Has Any Users Check Provider (with caching)
final hasUsersProvider = FutureProvider<bool>((ref) async {
  final firebaseService = ref.watch(firebaseServiceProvider);
  try {
    return await firebaseService.hasAnyUsers().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        print('⚠️ User existence check timed out - assuming users exist');
        return true;
      },
    );
  } catch (e) {
    print('❌ Error checking for users: $e');
    return true; // Fail safe - assume users exist
  }
});

// Should Show Setup Provider - combines setup completion and user existence
final shouldShowSetupProvider = Provider<AsyncValue<bool>>((ref) {
  final setupAsync = ref.watch(isSetupCompletedProvider);
  final usersAsync = ref.watch(hasUsersProvider);

  // Return loading state if either is loading
  if (setupAsync.isLoading || usersAsync.isLoading) {
    return const AsyncValue.loading();
  }

  // Handle errors gracefully
  if (setupAsync.hasError || usersAsync.hasError) {
    // If there's an error, assume setup is needed to be safe
    return const AsyncValue.data(true);
  }

  // Both have data
  final isSetupCompleted = setupAsync.value ?? false;
  final hasUsers = usersAsync.value ?? true;

  // Show setup if not completed OR no users exist
  final shouldShow = !isSetupCompleted || !hasUsers;
  return AsyncValue.data(shouldShow);
});

// Role-based Access Providers
final isSuperAdminProvider = FutureProvider<bool>((ref) async {
  final userModel = await ref.watch(currentUserProvider.future);
  return userModel?.isSuperAdmin ?? false;
});

final isAdminProvider = FutureProvider<bool>((ref) async {
  final userModel = await ref.watch(currentUserProvider.future);
  return userModel?.isAdmin ?? false;
});

final canManageUsersProvider = FutureProvider<bool>((ref) async {
  final userModel = await ref.watch(currentUserProvider.future);
  return userModel?.canManageUsers ?? false;
});

final canManageSystemProvider = FutureProvider<bool>((ref) async {
  final userModel = await ref.watch(currentUserProvider.future);
  return userModel?.canManageSystem ?? false;
});

// Route Access Providers
final canAccessDashboardProvider = FutureProvider<bool>((ref) async {
  final authStatus = ref.watch(authStatusProvider);
  return authStatus.when(
    data: (status) => status == AuthStatus.authenticated,
    loading: () => false,
    error: (_, __) => false,
  );
});

final canAccessAdminPanelProvider = FutureProvider<bool>((ref) async {
  final canManageUsers = await ref.watch(canManageUsersProvider.future);
  final canManageSystem = await ref.watch(canManageSystemProvider.future);
  return canManageUsers || canManageSystem;
});

final canAccessSuperAdminPanelProvider = FutureProvider<bool>((ref) async {
  return await ref.watch(isSuperAdminProvider.future);
});

// Password Strength Provider
final passwordStrengthProvider = Provider.family<PasswordStrength, String>((
  ref,
  password,
) {
  final score = AuthService.getPasswordStrength(password);
  final isStrong = AuthService.isPasswordStrong(password);

  return PasswordStrength(
    score: score,
    isStrong: isStrong,
    feedback: _getPasswordFeedback(password, score),
  );
});

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// All Users Provider - fetches all users from the users collection
final allUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getAllUsers();
});

// Firebase Service Provider
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

// Helper function for password feedback
List<String> _getPasswordFeedback(String password, int score) {
  final feedback = <String>[];

  if (password.length < 8) {
    feedback.add('Password must be at least 8 characters long');
  }
  if (!RegExp(r'[a-z]').hasMatch(password)) {
    feedback.add('Add lowercase letters');
  }
  if (!RegExp(r'[A-Z]').hasMatch(password)) {
    feedback.add('Add uppercase letters');
  }
  if (!RegExp(r'\d').hasMatch(password)) {
    feedback.add('Add numbers');
  }
  if (!RegExp(r'[@\$!%*?&]').hasMatch(password)) {
    feedback.add('Add special characters (@\$!%*?&)');
  }

  return feedback;
}

// Data Classes
enum AuthStatus { authenticated, unauthenticated, deactivated }

class PasswordStrength {
  final int score;
  final bool isStrong;
  final List<String> feedback;

  const PasswordStrength({
    required this.score,
    required this.isStrong,
    required this.feedback,
  });

  String get strengthText {
    switch (score) {
      case 0:
      case 1:
        return 'Very Weak';
      case 2:
        return 'Weak';
      case 3:
        return 'Fair';
      case 4:
        return 'Good';
      case 5:
        return 'Strong';
      default:
        return 'Unknown';
    }
  }

  double get strengthPercentage => (score / 5.0).clamp(0.0, 1.0);
}

// Clear Cache Provider - for clearing cache when needed
final clearCacheProvider = Provider<void>((ref) {
  FirebaseService.clearCache();
  // Invalidate all related providers
  ref.invalidate(isSetupCompletedProvider);
  ref.invalidate(hasUsersProvider);
  ref.invalidate(shouldShowSetupProvider);
  ref.invalidate(authStateProvider);
  ref.invalidate(currentUserProvider);
});

// User authentication status provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentFirebaseUserProvider);
  return user != null;
});

/// Permission Management Service Provider
final permissionManagementServiceProvider =
    Provider<PermissionManagementService>((ref) {
      return PermissionManagementService();
    });

/// User's Document Permissions Provider
final userDocumentPermissionsProvider = FutureProvider<DocumentAccessMatrix?>((
  ref,
) async {
  final authService = ref.watch(authServiceProvider);
  final permissionService = ref.watch(permissionManagementServiceProvider);

  try {
    final currentUser = await authService.getCurrentUserModel();
    if (currentUser == null) return null;

    return await permissionService.getEffectivePermissionsAsync(
      currentUser.role,
    );
  } catch (e) {
    print('❌ [PROVIDER] Error getting user document permissions: $e');
    return null;
  }
});

/// User's System Permissions Provider
final userSystemPermissionsProvider = FutureProvider<SystemPermissionConfig?>((
  ref,
) async {
  final authService = ref.watch(authServiceProvider);
  final permissionService = ref.watch(permissionManagementServiceProvider);

  try {
    final currentUser = await authService.getCurrentUserModel();
    if (currentUser == null) return null;

    return await permissionService.getEffectiveSystemPermissionsAsync(
      currentUser.role,
    );
  } catch (e) {
    print('❌ [PROVIDER] Error getting user system permissions: $e');
    return null;
  }
});

/// Check if user has specific document permission
final hasDocumentPermissionProvider = FutureProvider.family<bool, String>((
  ref,
  permission,
) async {
  final authService = ref.watch(authServiceProvider);
  final permissionService = ref.watch(permissionManagementServiceProvider);

  try {
    final currentUser = await authService.getCurrentUserModel();
    if (currentUser == null) return false;

    return await permissionService.hasDocumentPermission(
      currentUser.role,
      permission,
    );
  } catch (e) {
    print('❌ [PROVIDER] Error checking document permission $permission: $e');
    return false;
  }
});

/// Check if user can access specific document path
final canAccessDocumentPathProvider =
    FutureProvider.family<bool, Map<String, dynamic>>((ref, params) async {
      final authService = ref.watch(authServiceProvider);
      final permissionService = ref.watch(permissionManagementServiceProvider);

      try {
        final currentUser = await authService.getCurrentUserModel();
        if (currentUser == null) return false;

        final path = params['path'] as String;
        final employeeId = params['employeeId'] as String?;
        final department = params['department'] as String?;
        final assignedProjects = params['assignedProjects'] as List<String>?;

        return await permissionService.canAccessPath(
          currentUser.role,
          path,
          employeeId: employeeId,
          department: department,
          assignedProjects: assignedProjects,
        );
      } catch (e) {
        print('❌ [PROVIDER] Error checking path access: $e');
        return false;
      }
    });

/// Check if user can upload to specific category
final canUploadToCategoryProvider =
    FutureProvider.family<bool, DocumentCategory>((ref, category) async {
      final authService = ref.watch(authServiceProvider);
      final permissionService = ref.watch(permissionManagementServiceProvider);

      try {
        final currentUser = await authService.getCurrentUserModel();
        if (currentUser == null) return false;

        final permissions = await permissionService
            .getEffectivePermissionsAsync(currentUser.role);

        return permissions.canUploadToCategory(category);
      } catch (e) {
        print('❌ [PROVIDER] Error checking category upload permission: $e');
        return false;
      }
    });

/// Check if user can delete from specific category
final canDeleteFromCategoryProvider =
    FutureProvider.family<bool, DocumentCategory>((ref, category) async {
      final authService = ref.watch(authServiceProvider);
      final permissionService = ref.watch(permissionManagementServiceProvider);

      try {
        final currentUser = await authService.getCurrentUserModel();
        if (currentUser == null) return false;

        final permissions = await permissionService
            .getEffectivePermissionsAsync(currentUser.role);

        return permissions.canDeleteFromCategory(category);
      } catch (e) {
        print('❌ [PROVIDER] Error checking category delete permission: $e');
        return false;
      }
    });

/// Check if user can view employee documents as another user (for "View As" feature)
final canViewAsEmployeeProvider = FutureProvider<bool>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final permissionService = ref.watch(permissionManagementServiceProvider);

  try {
    final currentUser = await authService.getCurrentUserModel();
    if (currentUser == null) return false;

    // Get effective permissions and check canViewAsEmployee
    final permissions = await permissionService.getEffectivePermissionsAsync(
      currentUser.role,
    );
    return permissions.canViewAsEmployee;
  } catch (e) {
    print('❌ [PROVIDER] Error checking view as permission: $e');
    return false;
  }
});

/// Check if user can upload employee documents
/// Takes the target employee ID as parameter for "View As" context
final canUploadToEmployeeDocumentsProvider = FutureProvider.family<
  bool,
  String?
>((ref, targetEmployeeId) async {
  final authService = ref.watch(authServiceProvider);
  final permissionService = ref.watch(permissionManagementServiceProvider);

  try {
    final currentUser = await authService.getCurrentUserModel();
    if (currentUser == null) return false;

    final permissions = await permissionService.getEffectivePermissionsAsync(
      currentUser.role,
    );

    // Super Admin can always upload employee documents
    if (currentUser.role == UserRole.sa) {
      return true;
    }

    // Check if user can upload to employee category
    final canUploadToEmployeeCategory = permissions.canUploadToCategory(
      DocumentCategory.employee,
    );

    // If uploading to own documents (no target employee or target is self)
    if (targetEmployeeId == null || targetEmployeeId == currentUser.uid) {
      // Employees can upload their own documents if they have employee category access
      return canUploadToEmployeeCategory;
    }

    // For uploading to other employee's documents, need management permissions
    final systemPermissions = await permissionService
        .getEffectiveSystemPermissionsAsync(currentUser.role);
    final canManageEmployeeDocuments =
        systemPermissions.canManageEmployeeDocuments;
    return canUploadToEmployeeCategory && canManageEmployeeDocuments;
  } catch (e) {
    print(
      '❌ [PROVIDER] Error checking employee document upload permission: $e',
    );
    return false;
  }
});

/// Check if user can upload to employee folders (considering folder-specific permissions)
final canUploadToEmployeeFoldersProvider = FutureProvider<bool>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final permissionService = ref.watch(permissionManagementServiceProvider);

  try {
    final currentUser = await authService.getCurrentUserModel();
    if (currentUser == null) {
      print('❌ [EMPLOYEE UPLOAD PROVIDER] No current user found');
      return false;
    }

    print(
      '🔍 [EMPLOYEE UPLOAD PROVIDER] Checking permissions for user: ${currentUser.role.value}',
    );

    // Super Admin can always upload employee documents
    if (currentUser.role == UserRole.sa) {
      print('✅ [EMPLOYEE UPLOAD PROVIDER] Super admin access granted');
      return true;
    }

    final permissions = await permissionService.getEffectivePermissionsAsync(
      currentUser.role,
    );

    print('🔍 [EMPLOYEE UPLOAD PROVIDER] User permissions:');
    print('  - canUploadToAll: ${permissions.canUploadToAll}');
    print(
      '  - uploadableCategories: ${permissions.uploadableCategories.map((c) => c.value).join(', ')}',
    );

    // First check if user has general employee category upload permission
    if (permissions.canUploadToCategory(DocumentCategory.employee)) {
      print(
        '✅ [EMPLOYEE UPLOAD PROVIDER] User has general employee category upload permission',
      );
      return true;
    }

    // If no general permission, check if user has any folder-specific permissions
    final config = await permissionService.getPermissionConfig(
      currentUser.role,
    );
    if (config != null) {
      print(
        '🔍 [EMPLOYEE UPLOAD PROVIDER] Checking folder-specific permissions...',
      );
      print(
        '  - employeeFolderUploadPermissions: ${config.documentConfig.employeeFolderUploadPermissions}',
      );

      // Check if user has upload permission to any employee folder
      final hasAnyFolderPermission = config
          .documentConfig
          .employeeFolderUploadPermissions
          .values
          .any((hasPermission) => hasPermission == true);

      if (hasAnyFolderPermission) {
        print(
          '✅ [EMPLOYEE UPLOAD PROVIDER] User has folder-specific employee upload permissions',
        );
        return true;
      }
    } else {
      print(
        '⚠️ [EMPLOYEE UPLOAD PROVIDER] No permission config found for role: ${currentUser.role.value}',
      );
    }

    print(
      '❌ [EMPLOYEE UPLOAD PROVIDER] User has no employee document upload permissions',
    );
    return false;
  } catch (e) {
    print(
      '❌ [EMPLOYEE UPLOAD PROVIDER] Error checking employee folder upload permission: $e',
    );
    return false;
  }
});

/// Check if user can delete employee documents
/// Takes document metadata as parameter to check ownership and context
final canDeleteEmployeeDocumentProvider = FutureProvider.family<
  bool,
  Map<String, dynamic>
>((ref, documentData) async {
  final authService = ref.watch(authServiceProvider);
  final permissionService = ref.watch(permissionManagementServiceProvider);

  try {
    final currentUser = await authService.getCurrentUserModel();
    if (currentUser == null) return false;

    final permissions = await permissionService.getEffectivePermissionsAsync(
      currentUser.role,
    );

    // Super Admin can always delete employee documents
    if (currentUser.role == UserRole.sa) {
      return true;
    }

    final uploadedBy = documentData['uploadedBy'] as String?;
    final employeeId = documentData['employeeId'] as String?;

    // Check if user can delete from employee category
    final canDeleteFromEmployeeCategory = permissions.canDeleteFromCategory(
      DocumentCategory.employee,
    );

    // If deleting own documents
    if (uploadedBy == currentUser.uid || employeeId == currentUser.uid) {
      // Employees can delete their own documents if they have employee category delete access
      return canDeleteFromEmployeeCategory;
    }

    // For deleting other employee's documents, need management permissions
    final systemPermissions = await permissionService
        .getEffectiveSystemPermissionsAsync(currentUser.role);
    final canManageEmployeeDocuments =
        systemPermissions.canManageEmployeeDocuments;
    return canDeleteFromEmployeeCategory && canManageEmployeeDocuments;
  } catch (e) {
    print(
      '❌ [PROVIDER] Error checking employee document delete permission: $e',
    );
    return false;
  }
});

/// Check if user can delete task documents
final canDeleteTaskDocumentsProvider = FutureProvider<bool>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final permissionService = ref.watch(permissionManagementServiceProvider);

  try {
    final currentUser = await authService.getCurrentUserModel();
    if (currentUser == null) return false;

    final systemPermissions = await permissionService
        .getEffectiveSystemPermissionsAsync(currentUser.role);

    return systemPermissions.canDeleteTaskDocuments;
  } catch (e) {
    print('❌ [PROVIDER] Error checking task document delete permission: $e');
    return false;
  }
});

/// Check if user can delete a specific task document (considers both system permission and ownership)
final canDeleteSpecificTaskDocumentProvider = FutureProvider.family<
  bool,
  Map<String, dynamic>
>((ref, documentData) async {
  final authService = ref.watch(authServiceProvider);
  final permissionService = ref.watch(permissionManagementServiceProvider);

  try {
    final currentUser = await authService.getCurrentUserModel();
    if (currentUser == null) {
      print('❌ [TASK DOC DELETE] No current user found');
      return false;
    }

    final uploadedBy = documentData['uploadedBy'] as String?;

    print('🔍 [TASK DOC DELETE] Checking delete permission:');
    //print('  - Current User ID: ${currentUser.uid}');
    //print('  - Document Uploaded By: $uploadedBy');
    //print('  - Current User Role: ${currentUser.role.value}');

    // Check if user is the document uploader (always allowed to delete own documents)
    if (uploadedBy == currentUser.uid) {
      print('✅ [TASK DOC DELETE] User is document uploader - allowing delete');
      return true;
    }

    // Check system permission for deleting other users' documents
    final systemPermissions = await permissionService
        .getEffectiveSystemPermissionsAsync(currentUser.role);

    final canDelete = systemPermissions.canDeleteTaskDocuments;
    print('🔍 [TASK DOC DELETE] System permission check:');
    print('  - canDeleteTaskDocuments: $canDelete');

    return canDelete;
  } catch (e) {
    print(
      '❌ [TASK DOC DELETE] Error checking specific task document delete permission: $e',
    );
    return false;
  }
});
