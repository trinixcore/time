import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/permission_config_model.dart';
import '../enums/user_role.dart';
import '../enums/document_enums.dart';
import '../utils/document_permissions.dart';
import '../utils/logger.dart';
import 'firebase_service.dart';

/// Service for managing dynamic permission configurations
class PermissionManagementService {
  static final PermissionManagementService _instance =
      PermissionManagementService._internal();

  factory PermissionManagementService() => _instance;
  PermissionManagementService._internal();

  final FirebaseService _firebaseService = FirebaseService();
  final Uuid _uuid = const Uuid();

  // Cache for permission configurations
  static final Map<String, PermissionConfigModel> _permissionCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 30);

  /// Get permission configuration for a role
  Future<PermissionConfigModel?> getPermissionConfig(UserRole role) async {
    try {
      final cacheKey = role.value;
      final now = DateTime.now();

      // Check cache first
      if (_permissionCache.containsKey(cacheKey) &&
          _cacheTimestamps.containsKey(cacheKey) &&
          now.difference(_cacheTimestamps[cacheKey]!) < _cacheExpiry) {
        AppLogger.permission('Using cached config for ${role.value}');
        return _permissionCache[cacheKey];
      }

      AppLogger.permission('Fetching config for role: ${role.value}');

      // Query Firebase for the role configuration
      final querySnapshot =
          await _firebaseService.firestore
              .collection('permission_configs')
              .where('role', isEqualTo: role.value)
              .where('isActive', isEqualTo: true)
              .limit(1)
              .get();

      PermissionConfigModel? config;

      if (querySnapshot.docs.isNotEmpty) {
        // Use stored configuration
        final doc = querySnapshot.docs.first;
        config = PermissionConfigModel.fromJson(doc.data());
        AppLogger.permissionSuccess('Found stored config for ${role.value}');
      } else {
        // Create default configuration from static permissions
        config = _createDefaultConfig(role);
        AppLogger.permission('Created default config for ${role.value}');
      }

      // Update cache
      if (config != null) {
        _permissionCache[cacheKey] = config;
        _cacheTimestamps[cacheKey] = now;
      }

      return config;
    } catch (e) {
      AppLogger.permissionError('Error getting config for ${role.value}: $e');
      // Fallback to default configuration
      return _createDefaultConfig(role);
    }
  }

  /// Save or update permission configuration
  Future<void> savePermissionConfig(
    PermissionConfigModel config,
    String updatedBy,
    String updatedByName,
  ) async {
    try {
      AppLogger.permission('Saving config for role: ${config.role.value}');

      // Fetch the old config for diffing
      final oldConfig = await getPermissionConfig(config.role);

      // Update the config with current timestamp and user
      final updatedConfig = config.copyWith(
        updatedAt: DateTime.now(),
        updatedBy: updatedBy,
      );

      // Save to Firebase
      await _firebaseService.firestore
          .collection('permission_configs')
          .doc(config.id)
          .set(updatedConfig.toJson(), SetOptions(merge: true));

      // Clear cache for this role to ensure fresh permissions are loaded
      clearCacheForRole(config.role);

      // Compute field-level changes
      Map<String, Map<String, dynamic>> fieldChanges = {};
      if (oldConfig != null) {
        fieldChanges = _diffPermissionConfigs(oldConfig, updatedConfig);
      }

      // Log the action
      await _logPermissionChange(
        config.role,
        'update',
        updatedBy,
        updatedByName,
        additionalDetails: {
          'configId': config.id,
          'changes': 'Permission configuration updated',
          'updatedFields': fieldChanges.keys.toList(),
          if (fieldChanges.isNotEmpty) 'fieldChanges': fieldChanges,
        },
      );

      AppLogger.permissionSuccess('Config saved for ${config.role.value}');
      AppLogger.permission('Cache cleared for immediate effect');
    } catch (e) {
      AppLogger.permissionError('Error saving config: $e');
      throw Exception('Failed to save permission configuration: $e');
    }
  }

  /// Create new permission configuration
  Future<PermissionConfigModel> createPermissionConfig(
    UserRole role,
    DocumentPermissionConfig documentConfig,
    SystemPermissionConfig systemConfig,
    String createdBy,
    String createdByName,
  ) async {
    try {
      AppLogger.permission('Creating config for role: ${role.value}');

      final configId = _uuid.v4();
      final now = DateTime.now();

      final config = PermissionConfigModel(
        id: configId,
        role: role,
        documentConfig: documentConfig,
        systemConfig: systemConfig,
        createdAt: now,
        updatedAt: now,
        createdBy: createdBy,
        updatedBy: createdBy,
        isActive: true,
      );

      // Save to Firebase
      await _firebaseService.firestore
          .collection('permission_configs')
          .doc(configId)
          .set(config.toJson());

      // Clear cache for this role to ensure fresh permissions are loaded
      clearCacheForRole(role);

      // Log the action
      await _logPermissionChange(
        role,
        'create',
        createdBy,
        createdByName,
        additionalDetails: {
          'configId': configId,
          'changes': 'New permission configuration created',
          'documentPermissions':
              documentConfig.accessibleCategories.map((c) => c.value).toList(),
          'systemPermissions':
              systemConfig.canManageSystem
                  ? 'Full system access'
                  : 'Limited system access',
        },
      );

      AppLogger.permissionSuccess('Config created for ${role.value}');
      AppLogger.permission('Cache cleared for immediate effect');
      return config;
    } catch (e) {
      AppLogger.permissionError('Error creating config: $e');
      throw Exception('Failed to create permission configuration: $e');
    }
  }

  /// Get all permission configurations
  Future<List<PermissionConfigModel>> getAllPermissionConfigs() async {
    try {
      AppLogger.permission('Fetching all permission configs');

      // Remove orderBy to avoid composite index requirement
      final querySnapshot =
          await _firebaseService.firestore
              .collection('permission_configs')
              .where('isActive', isEqualTo: true)
              .get();

      AppLogger.permissionSuccess(
        'Found ${querySnapshot.docs.length} documents',
      );

      final configs =
          querySnapshot.docs
              .map((doc) {
                try {
                  return PermissionConfigModel.fromJson(doc.data());
                } catch (e) {
                  AppLogger.permissionError(
                    'Error parsing config ${doc.id}: $e',
                  );
                  return null;
                }
              })
              .where((config) => config != null)
              .cast<PermissionConfigModel>()
              .toList();

      // Sort by role level (highest to lowest) - client-side sorting
      configs.sort((a, b) => b.role.level.compareTo(a.role.level));

      // Update cache for all configs
      final now = DateTime.now();
      for (final config in configs) {
        final cacheKey = config.role.value;
        _permissionCache[cacheKey] = config;
        _cacheTimestamps[cacheKey] = now;
      }

      AppLogger.permissionSuccess('Fetched ${configs.length} configs');
      return configs;
    } catch (e) {
      AppLogger.permissionError('Error fetching all configs: $e');
      throw Exception('Failed to fetch permission configurations: $e');
    }
  }

  /// Reset role to default permissions
  Future<PermissionConfigModel> resetToDefault(
    UserRole role,
    String updatedBy,
    String updatedByName,
  ) async {
    try {
      AppLogger.permission('Resetting ${role.value} to defaults');

      // Create default configuration
      final defaultConfig = _createDefaultConfig(role);

      // Save the default configuration
      await savePermissionConfig(defaultConfig, updatedBy, updatedByName);

      // Log the action
      await _logPermissionChange(
        role,
        'reset',
        updatedBy,
        updatedByName,
        additionalDetails: {
          'changes': 'Permission configuration reset to default values',
          'reason': 'Manual reset requested',
          'defaultPermissions': 'Static role-based permissions applied',
        },
      );

      AppLogger.permissionSuccess('Reset ${role.value} to defaults');
      return defaultConfig;
    } catch (e) {
      AppLogger.permissionError('Error resetting to defaults: $e');
      throw Exception('Failed to reset to default permissions: $e');
    }
  }

  /// Initialize default configurations for all roles
  Future<void> initializeDefaultConfigs(
    String createdBy,
    String createdByName,
  ) async {
    try {
      AppLogger.permission('Initializing default configs');

      for (final role in UserRole.values) {
        if (role == UserRole.inactive) continue; // Skip inactive role

        try {
          // Check if config already exists
          final querySnapshot =
              await _firebaseService.firestore
                  .collection('permission_configs')
                  .where('role', isEqualTo: role.value)
                  .where('isActive', isEqualTo: true)
                  .limit(1)
                  .get();

          if (querySnapshot.docs.isNotEmpty) {
            AppLogger.permission('Config exists for ${role.value}');
            continue;
          }

          // Create default configuration
          final defaultConfig = _createDefaultConfig(role);
          final updatedConfig = defaultConfig.copyWith(
            createdBy: createdBy,
            updatedBy: createdBy,
          );

          // Save to Firebase
          await _firebaseService.firestore
              .collection('permission_configs')
              .doc(updatedConfig.id)
              .set(updatedConfig.toJson());

          // Update cache
          final cacheKey = role.value;
          _permissionCache[cacheKey] = updatedConfig;
          _cacheTimestamps[cacheKey] = DateTime.now();

          AppLogger.permissionSuccess(
            'Created default config for ${role.value}',
          );
        } catch (e) {
          AppLogger.permissionError(
            'Error creating config for ${role.value}: $e',
          );
          // Continue with other roles even if one fails
        }
      }

      // Log the initialization
      await _logPermissionChange(
        UserRole.sa,
        'initialize_defaults',
        createdBy,
        createdByName,
        additionalDetails: {
          'changes':
              'Default permission configurations initialized for all roles',
          'rolesInitialized':
              UserRole.values
                  .where((r) => r != UserRole.inactive)
                  .map((r) => r.value)
                  .toList(),
          'totalConfigs':
              UserRole.values.where((r) => r != UserRole.inactive).length,
          'reason': 'System initialization or first-time setup',
        },
      );

      AppLogger.permissionSuccess('Default configs initialization completed');
    } catch (e) {
      AppLogger.permissionError('Error initializing default configs: $e');
      throw Exception('Failed to initialize default configurations: $e');
    }
  }

  /// Manually create all default configurations (for debugging/setup)
  Future<void> createAllDefaultConfigs({
    String? userId,
    String? userName,
  }) async {
    try {
      final currentUserId = userId ?? 'system';
      final currentUserName = userName ?? 'System Admin';

      AppLogger.permission('Manually creating all default configs');

      // First, clear any existing cache
      _permissionCache.clear();
      _cacheTimestamps.clear();

      // Create configs for each role
      for (final role in UserRole.values) {
        if (role == UserRole.inactive) continue;

        try {
          AppLogger.permission('Creating config for ${role.displayName}');

          // Delete existing config if any
          final existingQuery =
              await _firebaseService.firestore
                  .collection('permission_configs')
                  .where('role', isEqualTo: role.value)
                  .get();

          for (final doc in existingQuery.docs) {
            await doc.reference.delete();
            AppLogger.permission('Deleted existing config for ${role.value}');
          }

          // Create new default config
          final config = _createDefaultConfig(role);
          final finalConfig = config.copyWith(
            createdBy: currentUserId,
            updatedBy: currentUserId,
          );

          // Save to Firebase
          await _firebaseService.firestore
              .collection('permission_configs')
              .doc(finalConfig.id)
              .set(finalConfig.toJson());

          AppLogger.permissionSuccess('Created config for ${role.displayName}');

          // Small delay to avoid overwhelming Firebase
          await Future.delayed(const Duration(milliseconds: 100));
        } catch (e) {
          AppLogger.permissionError(
            'Error creating config for ${role.value}: $e',
          );
        }
      }

      // Log the manual creation
      await _logPermissionChange(
        UserRole.sa,
        'manual_create_all',
        currentUserId,
        currentUserName,
        additionalDetails: {
          'changes': 'All permission configurations manually recreated',
          'rolesCreated':
              UserRole.values
                  .where((r) => r != UserRole.inactive)
                  .map((r) => r.value)
                  .toList(),
          'totalConfigs':
              UserRole.values.where((r) => r != UserRole.inactive).length,
          'reason': 'Manual recreation requested',
          'existingConfigsDeleted': true,
        },
      );

      AppLogger.permissionSuccess('Manual creation completed');
    } catch (e) {
      AppLogger.permissionError('Error in manual creation: $e');
      throw Exception('Failed to manually create configurations: $e');
    }
  }

  /// Clear the permission cache
  void clearCache() {
    AppLogger.permission('Clearing permission cache');
    _permissionCache.clear();
    _cacheTimestamps.clear();
    AppLogger.permissionSuccess('Permission cache cleared');
  }

  /// Clear cache for a specific role
  void clearCacheForRole(UserRole role) {
    final key = role.value;
    AppLogger.permission('Clearing cache for role: $key');
    _permissionCache.remove(key);
    _cacheTimestamps.remove(key);
    AppLogger.permissionSuccess('Cache cleared for role: $key');
  }

  /// Get effective permissions for a role (with fallback to static)
  DocumentAccessMatrix getEffectivePermissions(UserRole role) {
    try {
      final cacheKey = role.value;
      final config = _permissionCache[cacheKey];

      if (config != null) {
        // Convert dynamic config to DocumentAccessMatrix
        return DocumentAccessMatrix(
          canViewAll: config.documentConfig.canViewAll,
          canUploadToAll: config.documentConfig.canUploadToAll,
          canDeleteAny: config.documentConfig.canDeleteAny,
          canManagePermissions: config.documentConfig.canManagePermissions,
          canCreateFolders: config.documentConfig.canCreateFolders,
          canArchiveDocuments: config.documentConfig.canArchiveDocuments,
          canUploadToEmployeeDocuments:
              config.documentConfig.canUploadToEmployeeDocuments,
          canViewAsEmployee: config.documentConfig.canViewAsEmployee,
          accessibleCategories: config.documentConfig.accessibleCategories,
          accessiblePaths: config.documentConfig.accessiblePaths,
          maxFileSizeMB: config.documentConfig.maxFileSizeMB,
          allowedFileTypes: config.documentConfig.allowedFileTypes,
          uploadableCategories: config.documentConfig.uploadableCategories,
          deletableCategories: config.documentConfig.deletableCategories,
        );
      }

      // Fallback to static permissions
      return DocumentPermissions.getPermissionsForRole(role);
    } catch (e) {
      AppLogger.permissionError('Error getting effective permissions: $e');
      // Fallback to static permissions
      return DocumentPermissions.getPermissionsForRole(role);
    }
  }

  /// Get effective permissions asynchronously
  Future<DocumentAccessMatrix> getEffectivePermissionsAsync(
    UserRole role,
  ) async {
    try {
      // Check cache first
      final cacheKey = 'permissions_${role.value}';
      if (_cacheTimestamps.containsKey(cacheKey)) {
        final now = DateTime.now();
        final cacheTimestamp = _cacheTimestamps[cacheKey];
        if (cacheTimestamp != null &&
            now.difference(cacheTimestamp).inMinutes < 30) {
          final cachedConfig = _permissionCache[cacheKey]!;
          return DocumentAccessMatrix(
            canViewAll: cachedConfig.documentConfig.canViewAll,
            canUploadToAll: cachedConfig.documentConfig.canUploadToAll,
            canDeleteAny: cachedConfig.documentConfig.canDeleteAny,
            canManagePermissions:
                cachedConfig.documentConfig.canManagePermissions,
            canCreateFolders: cachedConfig.documentConfig.canCreateFolders,
            canArchiveDocuments:
                cachedConfig.documentConfig.canArchiveDocuments,
            canUploadToEmployeeDocuments:
                cachedConfig.documentConfig.canUploadToEmployeeDocuments,
            canViewAsEmployee: cachedConfig.documentConfig.canViewAsEmployee,
            accessibleCategories:
                cachedConfig.documentConfig.accessibleCategories,
            accessiblePaths: cachedConfig.documentConfig.accessiblePaths,
            maxFileSizeMB: cachedConfig.documentConfig.maxFileSizeMB,
            allowedFileTypes: cachedConfig.documentConfig.allowedFileTypes,
            uploadableCategories:
                cachedConfig.documentConfig.uploadableCategories,
            deletableCategories:
                cachedConfig.documentConfig.deletableCategories,
          );
        }
      }

      // Get static permissions as base
      final staticPermissions = DocumentPermissions.getPermissionsForRole(role);

      // Try to get config from Firebase
      final config = await getPermissionConfig(role);

      if (config != null) {
        // Create dynamic permissions with proper fallbacks
        List<DocumentCategory> finalUploadableCategories =
            config.documentConfig.uploadableCategories;
        List<DocumentCategory> finalDeletableCategories =
            config.documentConfig.deletableCategories;

        // If uploadableCategories is empty, use fallback logic
        if (finalUploadableCategories.isEmpty) {
          if (config.documentConfig.canUploadToAll) {
            finalUploadableCategories =
                config.documentConfig.accessibleCategories;
          } else {
            finalUploadableCategories = staticPermissions.uploadableCategories;
          }
        }

        // If deletableCategories is empty, use fallback logic
        if (finalDeletableCategories.isEmpty) {
          if (config.documentConfig.canDeleteAny) {
            finalDeletableCategories =
                config.documentConfig.accessibleCategories;
          } else {
            finalDeletableCategories = staticPermissions.deletableCategories;
          }
        }

        final matrix = DocumentAccessMatrix(
          canViewAll: config.documentConfig.canViewAll,
          canUploadToAll: config.documentConfig.canUploadToAll,
          canDeleteAny: config.documentConfig.canDeleteAny,
          canManagePermissions: config.documentConfig.canManagePermissions,
          canCreateFolders: config.documentConfig.canCreateFolders,
          canArchiveDocuments: config.documentConfig.canArchiveDocuments,
          canUploadToEmployeeDocuments:
              config.documentConfig.canUploadToEmployeeDocuments,
          canViewAsEmployee: config.documentConfig.canViewAsEmployee,
          accessibleCategories: config.documentConfig.accessibleCategories,
          accessiblePaths: config.documentConfig.accessiblePaths,
          maxFileSizeMB: config.documentConfig.maxFileSizeMB,
          allowedFileTypes: config.documentConfig.allowedFileTypes,
          uploadableCategories: finalUploadableCategories,
          deletableCategories: finalDeletableCategories,
        );

        // Cache the result
        _permissionCache[cacheKey] = config;
        _cacheTimestamps[cacheKey] = DateTime.now();

        return matrix;
      }

      // Cache static permissions as fallback
      _permissionCache[cacheKey] = PermissionConfigModel(
        id: '',
        role: role,
        documentConfig: DocumentPermissionConfig(
          canViewAll: staticPermissions.canViewAll,
          canUploadToAll: staticPermissions.canUploadToAll,
          canDeleteAny: staticPermissions.canDeleteAny,
          canManagePermissions: staticPermissions.canManagePermissions,
          canCreateFolders: staticPermissions.canCreateFolders,
          canArchiveDocuments: staticPermissions.canArchiveDocuments,
          canUploadToEmployeeDocuments: role.isSuperAdmin || role.isAdmin,
          canViewAsEmployee: role.isSuperAdmin || role.isAdmin,
          accessibleCategories: staticPermissions.accessibleCategories,
          accessiblePaths: staticPermissions.accessiblePaths,
          maxFileSizeMB: staticPermissions.maxFileSizeMB,
          allowedFileTypes: staticPermissions.allowedFileTypes,
          uploadableCategories: staticPermissions.uploadableCategories,
          deletableCategories: staticPermissions.deletableCategories,
        ),
        systemConfig: SystemPermissionConfig(
          canManageSystem: role.canManageSystem,
          canAccessAdminPanel: role.canAccessAdminPanel,
          canDelegateRoles: role.canDelegateRoles,
          canManageCompanySettings: role.canManageCompanySettings,
          canManageUsers: role.canManageUsers,
          canCreateUsers: role.canCreateUsers,
          canDeactivateUsers: role.canDeactivateUsers,
          canViewAllUsers: role.canViewAllUsers,
          canAssignRoles: role.canAssignRoles,
          canManageEmployees: role.canManageEmployees,
          canViewEmployeeDetails: role.canViewEmployeeDetails,
          canEditEmployeeProfiles: role.canEditEmployeeProfiles,
          canManageEmployeeDocuments: role.canManageEmployeeDocuments,
          canConductPerformanceReviews: role.canConductPerformanceReviews,
          canManageTasks: role.canManageTasks,
          canAssignTasks: role.canAssignTasks,
          canViewTeamTasks: role.canViewTeamTasks,
          canCreateProjects: role.canCreateProjects,
          canManageProjects: role.canManageProjects,
          canViewReports: role.canViewReports,
          canGenerateReports: role.canGenerateReports,
          canViewAnalytics: role.canViewAnalytics,
          canExportData: role.canExportData,
          canApproveLeaves: role.canApproveLeaves,
          canViewTeamAttendance: role.canViewTeamAttendance,
          canManageAttendancePolicy: role.canManageAttendancePolicy,
          canOverrideAttendance: role.canOverrideAttendance,
          canViewSalaryInfo: role.canViewSalaryInfo,
          canManagePayroll: role.canManagePayroll,
          canApproveBudgets: role.canApproveBudgets,
          canViewFinancialReports: role.canViewFinancialReports,
          canManageTraining: role.canManageTraining,
          canAssignTraining: role.canAssignTraining,
          canViewTrainingReports: role.canViewTrainingReports,
          canCreateTrainingContent: role.canCreateTrainingContent,
          canSendCompanyAnnouncements: role.canSendCompanyAnnouncements,
          canModerateDiscussions: role.canModerateDiscussions,
          canAccessAllChannels: role.canAccessAllChannels,
          canViewAuditLogs: role.canViewAuditLogs,
          canManageSecuritySettings: role.canManageSecuritySettings,
          canAccessComplianceReports: role.canAccessComplianceReports,
          canWorkRemotely: role.canWorkRemotely,
          canAccessAfterHours: role.canAccessAfterHours,
          canBypassApprovals: role.canBypassApprovals,
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'system',
        updatedBy: 'system',
        isActive: true,
      );
      _cacheTimestamps[cacheKey] = DateTime.now();

      return staticPermissions;
    } catch (e) {
      AppLogger.permissionError('Error getting effective permissions: $e');
      return DocumentPermissions.getPermissionsForRole(role);
    }
  }

  /// Get effective system permissions asynchronously
  Future<SystemPermissionConfig> getEffectiveSystemPermissionsAsync(
    UserRole role,
  ) async {
    try {
      AppLogger.permission('Getting system permissions for ${role.value}');

      // Try to get config from Firebase
      final config = await getPermissionConfig(role);

      if (config != null) {
        AppLogger.permissionSuccess(
          'Using dynamic system permissions for ${role.value}',
        );
        return config.systemConfig;
      }

      AppLogger.permission(
        'Creating default system permissions for ${role.value}',
      );
      // Fallback to creating default system permissions
      return SystemPermissionConfig(
        canManageSystem: role.canManageSystem,
        canAccessAdminPanel: role.canAccessAdminPanel,
        canDelegateRoles: role.canDelegateRoles,
        canManageCompanySettings: role.canManageCompanySettings,
        canManageUsers: role.canManageUsers,
        canCreateUsers: role.canCreateUsers,
        canDeactivateUsers: role.canDeactivateUsers,
        canViewAllUsers: role.canViewAllUsers,
        canAssignRoles: role.canAssignRoles,
        canManageEmployees: role.canManageEmployees,
        canViewEmployeeDetails: role.canViewEmployeeDetails,
        canEditEmployeeProfiles: role.canEditEmployeeProfiles,
        canManageEmployeeDocuments: role.canManageEmployeeDocuments,
        canConductPerformanceReviews: role.canConductPerformanceReviews,
        canManageTasks: role.canManageTasks,
        canAssignTasks: role.canAssignTasks,
        canViewTeamTasks: role.canViewTeamTasks,
        canCreateProjects: role.canCreateProjects,
        canManageProjects: role.canManageProjects,
        canViewReports: role.canViewReports,
        canGenerateReports: role.canGenerateReports,
        canViewAnalytics: role.canViewAnalytics,
        canExportData: role.canExportData,
        canApproveLeaves: role.canApproveLeaves,
        canViewTeamAttendance: role.canViewTeamAttendance,
        canManageAttendancePolicy: role.canManageAttendancePolicy,
        canOverrideAttendance: role.canOverrideAttendance,
        canViewSalaryInfo: role.canViewSalaryInfo,
        canManagePayroll: role.canManagePayroll,
        canApproveBudgets: role.canApproveBudgets,
        canViewFinancialReports: role.canViewFinancialReports,
        canManageTraining: role.canManageTraining,
        canAssignTraining: role.canAssignTraining,
        canViewTrainingReports: role.canViewTrainingReports,
        canCreateTrainingContent: role.canCreateTrainingContent,
        canSendCompanyAnnouncements: role.canSendCompanyAnnouncements,
        canModerateDiscussions: role.canModerateDiscussions,
        canAccessAllChannels: role.canAccessAllChannels,
        canViewAuditLogs: role.canViewAuditLogs,
        canManageSecuritySettings: role.canManageSecuritySettings,
        canAccessComplianceReports: role.canAccessComplianceReports,
        canWorkRemotely: role.canWorkRemotely,
        canAccessAfterHours: role.canAccessAfterHours,
        canBypassApprovals: role.canBypassApprovals,
      );
    } catch (e) {
      AppLogger.permissionError('Error getting system permissions: $e');
      // Return default system permissions based on role
      return SystemPermissionConfig(
        canManageSystem: role.canManageSystem,
        canAccessAdminPanel: role.canAccessAdminPanel,
        canDelegateRoles: role.canDelegateRoles,
        canManageCompanySettings: role.canManageCompanySettings,
        canManageUsers: role.canManageUsers,
        canCreateUsers: role.canCreateUsers,
        canDeactivateUsers: role.canDeactivateUsers,
        canViewAllUsers: role.canViewAllUsers,
        canAssignRoles: role.canAssignRoles,
        canManageEmployees: role.canManageEmployees,
        canViewEmployeeDetails: role.canViewEmployeeDetails,
        canEditEmployeeProfiles: role.canEditEmployeeProfiles,
        canManageEmployeeDocuments: role.canManageEmployeeDocuments,
        canConductPerformanceReviews: role.canConductPerformanceReviews,
        canManageTasks: role.canManageTasks,
        canAssignTasks: role.canAssignTasks,
        canViewTeamTasks: role.canViewTeamTasks,
        canCreateProjects: role.canCreateProjects,
        canManageProjects: role.canManageProjects,
        canViewReports: role.canViewReports,
        canGenerateReports: role.canGenerateReports,
        canViewAnalytics: role.canViewAnalytics,
        canExportData: role.canExportData,
        canApproveLeaves: role.canApproveLeaves,
        canViewTeamAttendance: role.canViewTeamAttendance,
        canManageAttendancePolicy: role.canManageAttendancePolicy,
        canOverrideAttendance: role.canOverrideAttendance,
        canViewSalaryInfo: role.canViewSalaryInfo,
        canManagePayroll: role.canManagePayroll,
        canApproveBudgets: role.canApproveBudgets,
        canViewFinancialReports: role.canViewFinancialReports,
        canManageTraining: role.canManageTraining,
        canAssignTraining: role.canAssignTraining,
        canViewTrainingReports: role.canViewTrainingReports,
        canCreateTrainingContent: role.canCreateTrainingContent,
        canSendCompanyAnnouncements: role.canSendCompanyAnnouncements,
        canModerateDiscussions: role.canModerateDiscussions,
        canAccessAllChannels: role.canAccessAllChannels,
        canViewAuditLogs: role.canViewAuditLogs,
        canManageSecuritySettings: role.canManageSecuritySettings,
        canAccessComplianceReports: role.canAccessComplianceReports,
        canWorkRemotely: role.canWorkRemotely,
        canAccessAfterHours: role.canAccessAfterHours,
        canBypassApprovals: role.canBypassApprovals,
      );
    }
  }

  /// Check if a role can access a specific document path
  Future<bool> canAccessPath(
    UserRole role,
    String path, {
    String? employeeId,
    String? department,
    List<String>? assignedProjects,
  }) async {
    try {
      final permissions = await getEffectivePermissionsAsync(role);

      // Super admin can access everything
      if (role == UserRole.sa) return true;

      // Check against accessible paths
      for (final allowedPath in permissions.accessiblePaths) {
        if (allowedPath == '*') return true;

        // Replace placeholders with actual values
        String resolvedPath = allowedPath
            .replaceAll('{employee_id}', employeeId ?? '')
            .replaceAll('{department}', department ?? '');

        // Handle assigned projects
        if (allowedPath.contains('{assigned_projects}') &&
            assignedProjects != null) {
          for (final project in assignedProjects) {
            final projectPath = allowedPath.replaceAll(
              '{assigned_projects}',
              project,
            );
            if (_pathMatches(path, projectPath)) return true;
          }
          continue;
        }

        if (_pathMatches(path, resolvedPath)) return true;
      }

      return false;
    } catch (e) {
      AppLogger.permissionError('Error checking path access: $e');
      return false;
    }
  }

  /// Check if a path matches a pattern (supports wildcards)
  bool _pathMatches(String path, String pattern) {
    if (pattern.endsWith('/*')) {
      final prefix = pattern.substring(0, pattern.length - 2);
      return path.startsWith(prefix);
    }
    return path == pattern;
  }

  /// Check if a user has a specific system permission
  Future<bool> hasSystemPermission(UserRole role, String permission) async {
    try {
      final systemPermissions = await getEffectiveSystemPermissionsAsync(role);

      switch (permission) {
        case 'canManageSystem':
          return systemPermissions.canManageSystem;
        default:
          return false;
      }
    } catch (e) {
      AppLogger.permissionError('Error checking system permission: $e');
      return false;
    }
  }

  /// Check if a user has a specific document permission
  Future<bool> hasDocumentPermission(UserRole role, String permission) async {
    try {
      AppLogger.permission(
        'Checking document permission: $permission for role: ${role.value}',
      );

      final documentPermissions = await getEffectivePermissionsAsync(role);

      AppLogger.permissionSuccess(
        'Document permissions loaded: canViewAll=${documentPermissions.canViewAll}, canUploadToAll=${documentPermissions.canUploadToAll}',
      );

      bool hasPermission = false;
      switch (permission) {
        case 'canViewAll':
          hasPermission = documentPermissions.canViewAll;
          break;
        case 'canUploadToAll':
          hasPermission = documentPermissions.canUploadToAll;
          break;
        case 'canDeleteAny':
          hasPermission = documentPermissions.canDeleteAny;
          break;
        case 'canManagePermissions':
          hasPermission = documentPermissions.canManagePermissions;
          break;
        case 'canCreateFolders':
          hasPermission = documentPermissions.canCreateFolders;
          break;
        case 'canArchiveDocuments':
          hasPermission = documentPermissions.canArchiveDocuments;
          break;
        default:
          AppLogger.warning(
            'PERMISSION',
            'Unknown document permission: $permission',
          );
          hasPermission = false;
      }

      AppLogger.permissionSuccess(
        'Permission check result: $permission = $hasPermission for role ${role.value}',
      );
      return hasPermission;
    } catch (e) {
      AppLogger.permissionError('Error checking document permission: $e');
      return false;
    }
  }

  /// Create default configuration from static permissions
  PermissionConfigModel _createDefaultConfig(UserRole role) {
    final staticMatrix = DocumentPermissions.getPermissionsForRole(role);
    final configId = _uuid.v4();
    final now = DateTime.now();

    return PermissionConfigModel(
      id: configId,
      role: role,
      documentConfig: DocumentPermissionConfig(
        canViewAll: staticMatrix.canViewAll,
        canUploadToAll: staticMatrix.canUploadToAll,
        canDeleteAny: staticMatrix.canDeleteAny,
        canManagePermissions: staticMatrix.canManagePermissions,
        canCreateFolders: staticMatrix.canCreateFolders,
        canArchiveDocuments: staticMatrix.canArchiveDocuments,
        canUploadToEmployeeDocuments: role.isSuperAdmin || role.isAdmin,
        canViewAsEmployee: role.isSuperAdmin || role.isAdmin,
        accessibleCategories: staticMatrix.accessibleCategories,
        accessiblePaths: staticMatrix.accessiblePaths,
        maxFileSizeMB: staticMatrix.maxFileSizeMB,
        allowedFileTypes: staticMatrix.allowedFileTypes,
        uploadableCategories: staticMatrix.uploadableCategories,
        deletableCategories: staticMatrix.deletableCategories,
      ),
      systemConfig: SystemPermissionConfig(
        canManageSystem: role.canManageSystem,
        canAccessAdminPanel: role.canAccessAdminPanel,
        canDelegateRoles: role.canDelegateRoles,
        canManageCompanySettings: role.canManageCompanySettings,
        canManageUsers: role.canManageUsers,
        canCreateUsers: role.canCreateUsers,
        canDeactivateUsers: role.canDeactivateUsers,
        canViewAllUsers: role.canViewAllUsers,
        canAssignRoles: role.canAssignRoles,
        canManageEmployees: role.canManageEmployees,
        canViewEmployeeDetails: role.canViewEmployeeDetails,
        canEditEmployeeProfiles: role.canEditEmployeeProfiles,
        canManageEmployeeDocuments: role.canManageEmployeeDocuments,
        canConductPerformanceReviews: role.canConductPerformanceReviews,
        canManageTasks: role.canManageTasks,
        canAssignTasks: role.canAssignTasks,
        canViewTeamTasks: role.canViewTeamTasks,
        canCreateProjects: role.canCreateProjects,
        canManageProjects: role.canManageProjects,
        canViewReports: role.canViewReports,
        canGenerateReports: role.canGenerateReports,
        canViewAnalytics: role.canViewAnalytics,
        canExportData: role.canExportData,
        canApproveLeaves: role.canApproveLeaves,
        canViewTeamAttendance: role.canViewTeamAttendance,
        canManageAttendancePolicy: role.canManageAttendancePolicy,
        canOverrideAttendance: role.canOverrideAttendance,
        canViewSalaryInfo: role.canViewSalaryInfo,
        canManagePayroll: role.canManagePayroll,
        canApproveBudgets: role.canApproveBudgets,
        canViewFinancialReports: role.canViewFinancialReports,
        canManageTraining: role.canManageTraining,
        canAssignTraining: role.canAssignTraining,
        canViewTrainingReports: role.canViewTrainingReports,
        canCreateTrainingContent: role.canCreateTrainingContent,
        canSendCompanyAnnouncements: role.canSendCompanyAnnouncements,
        canModerateDiscussions: role.canModerateDiscussions,
        canAccessAllChannels: role.canAccessAllChannels,
        canViewAuditLogs: role.canViewAuditLogs,
        canManageSecuritySettings: role.canManageSecuritySettings,
        canAccessComplianceReports: role.canAccessComplianceReports,
        canWorkRemotely: role.canWorkRemotely,
        canAccessAfterHours: role.canAccessAfterHours,
        canBypassApprovals: role.canBypassApprovals,
      ),
      createdAt: now,
      updatedAt: now,
      createdBy: 'system',
      updatedBy: 'system',
      isActive: true,
    );
  }

  /// Log permission changes for audit purposes
  Future<void> _logPermissionChange(
    UserRole role,
    String action,
    String userId,
    String userName, {
    Map<String, dynamic>? additionalDetails,
  }) async {
    try {
      final logEntry = {
        'role': role.value,
        'roleDisplayName': role.displayName,
        'action': action,
        'userId': userId,
        'userName': userName,
        'timestamp': Timestamp.now(),
        'details': {
          'roleDisplayName': role.displayName,
          'roleLevel': role.level,
          'actionDescription': _getActionDescription(action),
          'severity': _getActionSeverity(action),
          'sessionId': 'web_session_${DateTime.now().millisecondsSinceEpoch}',
          ...?additionalDetails,
        },
      };

      await _firebaseService.firestore
          .collection('permission_audit_logs')
          .add(logEntry);
      AppLogger.permissionSuccess(
        'Audit log created: $action for ${role.displayName}',
      );
    } catch (e) {
      AppLogger.warning('PERMISSION', 'Failed to log permission change: $e');
      // Don't throw error for logging failures
    }
  }

  /// Get human-readable action description
  String _getActionDescription(String action) {
    switch (action.toLowerCase()) {
      case 'create':
        return 'Created new permission configuration';
      case 'update':
        return 'Updated existing permission configuration';
      case 'reset':
        return 'Reset permission configuration to default values';
      case 'initialize_defaults':
        return 'Initialized default permission configurations for all roles';
      case 'manual_create_all':
        return 'Manually created all permission configurations';
      case 'delete':
        return 'Deleted permission configuration';
      case 'activate':
        return 'Activated permission configuration';
      case 'deactivate':
        return 'Deactivated permission configuration';
      default:
        return 'Permission action: ${action.replaceAll('_', ' ')}';
    }
  }

  /// Get severity level for audit actions
  String _getActionSeverity(String action) {
    switch (action.toLowerCase()) {
      case 'create':
      case 'update':
        return 'MEDIUM';
      case 'reset':
      case 'initialize_defaults':
      case 'manual_create_all':
        return 'HIGH';
      case 'delete':
      case 'deactivate':
        return 'CRITICAL';
      default:
        return 'LOW';
    }
  }

  /// Clear all permission cache (useful for testing or immediate effect)
  static void clearAllCache() {
    AppLogger.permission('Clearing ALL permission cache');
    _permissionCache.clear();
    _cacheTimestamps.clear();
    AppLogger.permissionSuccess('ALL permission cache cleared');
  }

  /// Check if user can view specific employee folder
  Future<bool> canViewEmployeeFolder(
    UserRole role,
    String folderCode,
    String folderName, {
    String? currentUserEmployeeId,
    String? targetEmployeeId,
  }) async {
    try {
      // Users always have view access to their own documents
      if (currentUserEmployeeId != null &&
          targetEmployeeId != null &&
          currentUserEmployeeId == targetEmployeeId) {
        AppLogger.permissionSuccess(
          'User has default view access to own documents',
        );
        return true;
      }

      final config = await getPermissionConfig(role);
      if (config == null) {
        // Fallback to category-level permissions
        final permissions = await getEffectivePermissionsAsync(role);
        return permissions.canViewAll ||
            permissions.accessibleCategories.contains(
              DocumentCategory.employee,
            );
      }

      final folderKey = '${folderCode}_$folderName';

      // Check folder-specific permission first
      if (config.documentConfig.employeeFolderViewPermissions.containsKey(
        folderKey,
      )) {
        return config.documentConfig.employeeFolderViewPermissions[folderKey] ??
            false;
      }

      // Fallback to category-level permissions
      return config.documentConfig.canViewAll ||
          config.documentConfig.accessibleCategories.contains(
            DocumentCategory.employee,
          );
    } catch (e) {
      AppLogger.permissionError(
        'Error checking view permission for folder $folderCode: $e',
      );
      return false;
    }
  }

  /// Check if user can upload to specific employee folder
  Future<bool> canUploadToEmployeeFolder(
    UserRole role,
    String folderCode,
    String folderName,
  ) async {
    try {
      AppLogger.permission(
        'Checking upload permission for folder: ${folderCode}_$folderName',
      );

      final config = await getPermissionConfig(role);
      if (config == null) {
        AppLogger.warning(
          'PERMISSION',
          'No config found, using fallback for employee category',
        );
        // Fallback to category-level permissions
        final permissions = await getEffectivePermissionsAsync(role);
        final canUpload =
            permissions.canUploadToAll ||
            permissions.uploadableCategories.contains(
              DocumentCategory.employee,
            );
        AppLogger.permissionSuccess(
          'Fallback result for ${folderCode}_$folderName: $canUpload',
        );
        return canUpload;
      }

      AppLogger.permissionSuccess(
        'canUploadToAll: ${config.documentConfig.canUploadToAll}',
      );
      AppLogger.permissionSuccess(
        'uploadableCategories: ${config.documentConfig.uploadableCategories.map((c) => c.value).join(', ')}',
      );

      // First check if user has global upload permissions
      if (config.documentConfig.canUploadToAll) {
        AppLogger.permissionSuccess('User has canUploadToAll permission');
        return true;
      }

      // Check if user has employee category upload permission (master control)
      if (config.documentConfig.uploadableCategories.contains(
        DocumentCategory.employee,
      )) {
        AppLogger.permissionSuccess(
          'User has employee category upload permission',
        );
        return true;
      }

      // If no category-level permission, check folder-specific permissions
      final folderKey = '${folderCode}_$folderName';
      AppLogger.permission(
        'Checking folder-specific permission for key: $folderKey',
      );

      if (config.documentConfig.employeeFolderUploadPermissions.containsKey(
        folderKey,
      )) {
        final hasPermission =
            config.documentConfig.employeeFolderUploadPermissions[folderKey] ??
            false;
        AppLogger.permissionSuccess(
          'Found folder-specific permission for $folderKey: $hasPermission',
        );
        return hasPermission;
      }

      AppLogger.permissionError(
        'No upload permission found for folder ${folderCode}_$folderName',
      );
      return false;
    } catch (e) {
      AppLogger.permissionError(
        'Error checking upload permission for folder $folderCode: $e',
      );
      return false;
    }
  }

  /// Check if user can delete from specific employee folder
  Future<bool> canDeleteFromEmployeeFolder(
    UserRole role,
    String folderCode,
    String folderName, {
    String? currentUserEmployeeId,
    String? targetEmployeeId,
  }) async {
    try {
      AppLogger.permission('Checking delete permission:');
      AppLogger.permission('  - Role: ${role.value}');
      AppLogger.permission('  - Current User ID: $currentUserEmployeeId');
      AppLogger.permission('  - Target User ID: $targetEmployeeId');
      AppLogger.permission('  - Folder: ${folderCode}_$folderName');

      // If viewing own documents, deny delete permission
      if (currentUserEmployeeId != null &&
          targetEmployeeId != null &&
          currentUserEmployeeId == targetEmployeeId) {
        AppLogger.permissionError('Users cannot delete their own documents');
        return false;
      }

      // Get permission config
      final config = await getPermissionConfig(role);
      if (config == null) {
        AppLogger.permissionError('No permission config found');
        return false;
      }

      final folderKey = '${folderCode}_$folderName';

      // Check folder-specific permission from Edit Permissions modal
      if (config.documentConfig.employeeFolderDeletePermissions.containsKey(
        folderKey,
      )) {
        final hasPermission =
            config.documentConfig.employeeFolderDeletePermissions[folderKey] ??
            false;
        AppLogger.permissionSuccess(
          'Using folder-specific permission: $hasPermission',
        );
        return hasPermission;
      }

      // If no specific permission set, deny access
      AppLogger.permissionError(
        'No specific delete permission found for folder',
      );
      return false;
    } catch (e) {
      AppLogger.permissionError('Error checking delete permission: $e');
      return false;
    }
  }

  /// Extract folder information from a path
  Map<String, String>? extractFolderInfo(String folderPath) {
    try {
      // Extract folder code and name from path like: employees/TRX2025000001_Samrat_De_Sarkar/03_appraisal
      final pathParts = folderPath.split('/');
      if (pathParts.length >= 3 && pathParts[0] == 'employees') {
        final folderPart = pathParts[2]; // e.g., "03_appraisal"
        final parts = folderPart.split('_');
        if (parts.length >= 2) {
          final code = parts[0]; // e.g., "03"
          final name = parts.sublist(1).join('_'); // e.g., "appraisal"
          return {'code': code, 'name': name};
        }
      }
      return null;
    } catch (e) {
      AppLogger.permissionError('Error extracting folder info: $e');
      return null;
    }
  }

  /// Fetch permission audit logs (for audit trail UI)
  Future<List<Map<String, dynamic>>> fetchPermissionAuditLogs({
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firebaseService.firestore
          .collection('permission_audit_logs')
          .orderBy('timestamp', descending: true)
          .limit(limit);
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      AppLogger.permissionError('Error fetching audit logs: $e');
      return [];
    }
  }

  /// Create sample audit logs for testing/demonstration
  Future<void> createSampleAuditLogs(String userId, String userName) async {
    try {
      AppLogger.permission('Creating sample audit logs...');

      final sampleActions = [
        {
          'role': UserRole.sa,
          'action': 'initialize_defaults',
          'details': {
            'changes':
                'System initialized with default permission configurations',
            'rolesInitialized': [
              'sa',
              'admin',
              'hr',
              'manager',
              'tl',
              'se',
              'employee',
            ],
            'totalConfigs': 7,
            'reason': 'Initial system setup',
          },
        },
        {
          'role': UserRole.admin,
          'action': 'update',
          'details': {
            'configId': 'sample_config_001',
            'changes': 'Updated document access permissions',
            'updatedFields': ['canViewAll', 'canUploadToAll'],
            'reason': 'Enhanced document management capabilities',
          },
        },
        {
          'role': UserRole.hr,
          'action': 'create',
          'details': {
            'configId': 'sample_config_002',
            'changes': 'Created custom HR permissions',
            'documentPermissions': ['employee', 'hr', 'policies'],
            'systemPermissions': 'HR management access',
            'reason': 'New HR role configuration',
          },
        },
        {
          'role': UserRole.manager,
          'action': 'reset',
          'details': {
            'changes': 'Reset manager permissions to defaults',
            'reason': 'Compliance audit requirement',
            'defaultPermissions': 'Standard manager permissions applied',
          },
        },
        {
          'role': UserRole.employee,
          'action': 'update',
          'details': {
            'configId': 'sample_config_003',
            'changes': 'Updated employee document access',
            'updatedFields': ['accessibleCategories', 'uploadableCategories'],
            'reason': 'New document categories added',
          },
        },
      ];

      for (final sample in sampleActions) {
        await _logPermissionChange(
          sample['role'] as UserRole,
          sample['action'] as String,
          userId,
          userName,
          additionalDetails: sample['details'] as Map<String, dynamic>,
        );

        // Add some delay between logs to create realistic timestamps
        await Future.delayed(const Duration(seconds: 1));
      }

      AppLogger.permissionSuccess('Sample audit logs created successfully');
    } catch (e) {
      AppLogger.permissionError('Error creating sample audit logs: $e');
    }
  }

  /// Diff two permission configs and return a map of changed fields with old/new values
  Map<String, Map<String, dynamic>> _diffPermissionConfigs(
    PermissionConfigModel oldConfig,
    PermissionConfigModel newConfig,
  ) {
    final changes = <String, Map<String, dynamic>>{};

    // Compare top-level fields
    if (oldConfig.role != newConfig.role) {
      changes['role'] = {
        'old': oldConfig.role.value,
        'new': newConfig.role.value,
      };
    }
    if (oldConfig.isActive != newConfig.isActive) {
      changes['isActive'] = {
        'old': oldConfig.isActive,
        'new': newConfig.isActive,
      };
    }

    // Compare DocumentPermissionConfig fields
    final oldDoc = oldConfig.documentConfig;
    final newDoc = newConfig.documentConfig;
    void compareDocField(String key, dynamic oldVal, dynamic newVal) {
      if (oldVal != newVal) {
        changes['documentConfig.$key'] = {'old': oldVal, 'new': newVal};
      }
    }

    compareDocField('canViewAll', oldDoc.canViewAll, newDoc.canViewAll);
    compareDocField(
      'canUploadToAll',
      oldDoc.canUploadToAll,
      newDoc.canUploadToAll,
    );
    compareDocField('canDeleteAny', oldDoc.canDeleteAny, newDoc.canDeleteAny);
    compareDocField(
      'canManagePermissions',
      oldDoc.canManagePermissions,
      newDoc.canManagePermissions,
    );
    compareDocField(
      'canCreateFolders',
      oldDoc.canCreateFolders,
      newDoc.canCreateFolders,
    );
    compareDocField(
      'canArchiveDocuments',
      oldDoc.canArchiveDocuments,
      newDoc.canArchiveDocuments,
    );
    compareDocField(
      'canUploadToEmployeeDocuments',
      oldDoc.canUploadToEmployeeDocuments,
      newDoc.canUploadToEmployeeDocuments,
    );
    compareDocField(
      'canViewAsEmployee',
      oldDoc.canViewAsEmployee,
      newDoc.canViewAsEmployee,
    );
    compareDocField(
      'accessibleCategories',
      oldDoc.accessibleCategories.map((c) => c.value).toList(),
      newDoc.accessibleCategories.map((c) => c.value).toList(),
    );
    compareDocField(
      'accessiblePaths',
      oldDoc.accessiblePaths,
      newDoc.accessiblePaths,
    );
    compareDocField(
      'maxFileSizeMB',
      oldDoc.maxFileSizeMB,
      newDoc.maxFileSizeMB,
    );
    compareDocField(
      'allowedFileTypes',
      oldDoc.allowedFileTypes.map((t) => t.extension).toList(),
      newDoc.allowedFileTypes.map((t) => t.extension).toList(),
    );
    compareDocField(
      'uploadableCategories',
      oldDoc.uploadableCategories.map((c) => c.value).toList(),
      newDoc.uploadableCategories.map((c) => c.value).toList(),
    );
    compareDocField(
      'deletableCategories',
      oldDoc.deletableCategories.map((c) => c.value).toList(),
      newDoc.deletableCategories.map((c) => c.value).toList(),
    );
    compareDocField(
      'employeeFolderViewPermissions',
      oldDoc.employeeFolderViewPermissions,
      newDoc.employeeFolderViewPermissions,
    );
    compareDocField(
      'employeeFolderUploadPermissions',
      oldDoc.employeeFolderUploadPermissions,
      newDoc.employeeFolderUploadPermissions,
    );
    compareDocField(
      'employeeFolderDeletePermissions',
      oldDoc.employeeFolderDeletePermissions,
      newDoc.employeeFolderDeletePermissions,
    );

    // Compare SystemPermissionConfig fields
    final oldSys = oldConfig.systemConfig;
    final newSys = newConfig.systemConfig;
    void compareSysField(String key, dynamic oldVal, dynamic newVal) {
      if (oldVal != newVal) {
        changes['systemConfig.$key'] = {'old': oldVal, 'new': newVal};
      }
    }

    // Compare all bool fields (manually listed for clarity)
    compareSysField(
      'canManageSystem',
      oldSys.canManageSystem,
      newSys.canManageSystem,
    );
    compareSysField(
      'canAccessAdminPanel',
      oldSys.canAccessAdminPanel,
      newSys.canAccessAdminPanel,
    );
    compareSysField(
      'canDelegateRoles',
      oldSys.canDelegateRoles,
      newSys.canDelegateRoles,
    );
    compareSysField(
      'canManageCompanySettings',
      oldSys.canManageCompanySettings,
      newSys.canManageCompanySettings,
    );
    compareSysField(
      'canManageUsers',
      oldSys.canManageUsers,
      newSys.canManageUsers,
    );
    compareSysField(
      'canCreateUsers',
      oldSys.canCreateUsers,
      newSys.canCreateUsers,
    );
    compareSysField(
      'canDeactivateUsers',
      oldSys.canDeactivateUsers,
      newSys.canDeactivateUsers,
    );
    compareSysField(
      'canViewAllUsers',
      oldSys.canViewAllUsers,
      newSys.canViewAllUsers,
    );
    compareSysField(
      'canAssignRoles',
      oldSys.canAssignRoles,
      newSys.canAssignRoles,
    );
    compareSysField(
      'canManageEmployees',
      oldSys.canManageEmployees,
      newSys.canManageEmployees,
    );
    compareSysField(
      'canAddEmployees',
      oldSys.canAddEmployees,
      newSys.canAddEmployees,
    );
    compareSysField(
      'canViewEmployeeDetails',
      oldSys.canViewEmployeeDetails,
      newSys.canViewEmployeeDetails,
    );
    compareSysField(
      'canEditEmployeeProfiles',
      oldSys.canEditEmployeeProfiles,
      newSys.canEditEmployeeProfiles,
    );
    compareSysField(
      'canManageEmployeeDocuments',
      oldSys.canManageEmployeeDocuments,
      newSys.canManageEmployeeDocuments,
    );
    compareSysField(
      'canConductPerformanceReviews',
      oldSys.canConductPerformanceReviews,
      newSys.canConductPerformanceReviews,
    );
    compareSysField(
      'canManageTasks',
      oldSys.canManageTasks,
      newSys.canManageTasks,
    );
    compareSysField(
      'canCreateTasks',
      oldSys.canCreateTasks,
      newSys.canCreateTasks,
    );
    compareSysField(
      'canDeleteTasks',
      oldSys.canDeleteTasks,
      newSys.canDeleteTasks,
    );
    compareSysField(
      'canDeleteTaskDocuments',
      oldSys.canDeleteTaskDocuments,
      newSys.canDeleteTaskDocuments,
    );
    compareSysField(
      'canAssignTasks',
      oldSys.canAssignTasks,
      newSys.canAssignTasks,
    );
    compareSysField(
      'canViewTeamTasks',
      oldSys.canViewTeamTasks,
      newSys.canViewTeamTasks,
    );
    compareSysField(
      'canCreateProjects',
      oldSys.canCreateProjects,
      newSys.canCreateProjects,
    );
    compareSysField(
      'canManageProjects',
      oldSys.canManageProjects,
      newSys.canManageProjects,
    );
    compareSysField(
      'canViewReports',
      oldSys.canViewReports,
      newSys.canViewReports,
    );
    compareSysField(
      'canGenerateReports',
      oldSys.canGenerateReports,
      newSys.canGenerateReports,
    );
    compareSysField(
      'canViewAnalytics',
      oldSys.canViewAnalytics,
      newSys.canViewAnalytics,
    );
    compareSysField(
      'canExportData',
      oldSys.canExportData,
      newSys.canExportData,
    );
    compareSysField(
      'canApproveLeaves',
      oldSys.canApproveLeaves,
      newSys.canApproveLeaves,
    );
    compareSysField(
      'canViewTeamAttendance',
      oldSys.canViewTeamAttendance,
      newSys.canViewTeamAttendance,
    );
    compareSysField(
      'canManageAttendancePolicy',
      oldSys.canManageAttendancePolicy,
      newSys.canManageAttendancePolicy,
    );
    compareSysField(
      'canOverrideAttendance',
      oldSys.canOverrideAttendance,
      newSys.canOverrideAttendance,
    );
    compareSysField(
      'canViewSalaryInfo',
      oldSys.canViewSalaryInfo,
      newSys.canViewSalaryInfo,
    );
    compareSysField(
      'canManagePayroll',
      oldSys.canManagePayroll,
      newSys.canManagePayroll,
    );
    compareSysField(
      'canApproveBudgets',
      oldSys.canApproveBudgets,
      newSys.canApproveBudgets,
    );
    compareSysField(
      'canViewFinancialReports',
      oldSys.canViewFinancialReports,
      newSys.canViewFinancialReports,
    );
    compareSysField(
      'canManageTraining',
      oldSys.canManageTraining,
      newSys.canManageTraining,
    );
    compareSysField(
      'canAssignTraining',
      oldSys.canAssignTraining,
      newSys.canAssignTraining,
    );
    compareSysField(
      'canViewTrainingReports',
      oldSys.canViewTrainingReports,
      newSys.canViewTrainingReports,
    );
    compareSysField(
      'canCreateTrainingContent',
      oldSys.canCreateTrainingContent,
      newSys.canCreateTrainingContent,
    );
    compareSysField(
      'canSendCompanyAnnouncements',
      oldSys.canSendCompanyAnnouncements,
      newSys.canSendCompanyAnnouncements,
    );
    compareSysField(
      'canModerateDiscussions',
      oldSys.canModerateDiscussions,
      newSys.canModerateDiscussions,
    );
    compareSysField(
      'canAccessAllChannels',
      oldSys.canAccessAllChannels,
      newSys.canAccessAllChannels,
    );
    compareSysField(
      'canViewAuditLogs',
      oldSys.canViewAuditLogs,
      newSys.canViewAuditLogs,
    );
    compareSysField(
      'canManageSecuritySettings',
      oldSys.canManageSecuritySettings,
      newSys.canManageSecuritySettings,
    );
    compareSysField(
      'canAccessComplianceReports',
      oldSys.canAccessComplianceReports,
      newSys.canAccessComplianceReports,
    );
    compareSysField(
      'canWorkRemotely',
      oldSys.canWorkRemotely,
      newSys.canWorkRemotely,
    );
    compareSysField(
      'canAccessAfterHours',
      oldSys.canAccessAfterHours,
      newSys.canAccessAfterHours,
    );
    compareSysField(
      'canBypassApprovals',
      oldSys.canBypassApprovals,
      newSys.canBypassApprovals,
    );

    // Compare pagePermissions (allPagePermissions is a map)
    final oldPages = oldSys.pagePermissions.allPagePermissions;
    final newPages = newSys.pagePermissions.allPagePermissions;
    for (final key in oldPages.keys) {
      if (oldPages[key] != newPages[key]) {
        changes['systemConfig.pagePermissions.$key'] = {
          'old': oldPages[key],
          'new': newPages[key],
        };
      }
    }

    return changes;
  }
}
