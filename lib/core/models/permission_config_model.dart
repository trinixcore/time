import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/user_role.dart';
import '../enums/document_enums.dart';
import '../constants/role_permissions.dart';

/// Model for dynamic permission configurations
class PermissionConfigModel {
  final String id;
  final UserRole role;
  final DocumentPermissionConfig documentConfig;
  final SystemPermissionConfig systemConfig;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String updatedBy;
  final bool isActive;

  const PermissionConfigModel({
    required this.id,
    required this.role,
    required this.documentConfig,
    required this.systemConfig,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
    this.isActive = true,
  });

  /// Convert to JSON for Firebase storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.value,
      'documentConfig': documentConfig.toJson(),
      'systemConfig': systemConfig.toJson(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'isActive': isActive,
    };
  }

  /// Create from Firebase document
  factory PermissionConfigModel.fromJson(Map<String, dynamic> json) {
    return PermissionConfigModel(
      id: json['id'] ?? '',
      role: UserRole.fromString(json['role'] ?? 'employee'),
      documentConfig: DocumentPermissionConfig.fromJson(
        json['documentConfig'] ?? {},
      ),
      systemConfig: SystemPermissionConfig.fromJson(json['systemConfig'] ?? {}),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: json['createdBy'] ?? '',
      updatedBy: json['updatedBy'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  /// Create a copy with updated values
  PermissionConfigModel copyWith({
    String? id,
    UserRole? role,
    DocumentPermissionConfig? documentConfig,
    SystemPermissionConfig? systemConfig,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isActive,
  }) {
    return PermissionConfigModel(
      id: id ?? this.id,
      role: role ?? this.role,
      documentConfig: documentConfig ?? this.documentConfig,
      systemConfig: systemConfig ?? this.systemConfig,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Create default permission configuration for a role
  static PermissionConfigModel createDefaultForRole({
    required UserRole role,
    required String createdBy,
    required String updatedBy,
  }) {
    final now = DateTime.now();

    return PermissionConfigModel(
      id: '${role.value}_default',
      role: role,
      documentConfig: DocumentPermissionConfig.createDefaultForRole(role),
      systemConfig: SystemPermissionConfig.createDefaultForRole(role),
      createdAt: now,
      updatedAt: now,
      createdBy: createdBy,
      updatedBy: updatedBy,
      isActive: true,
    );
  }
}

/// Document-specific permission configuration
class DocumentPermissionConfig {
  final bool canViewAll;
  final bool canUploadToAll;
  final bool canDeleteAny;
  final bool canManagePermissions;
  final bool canCreateFolders;
  final bool canArchiveDocuments;
  final bool canUploadToEmployeeDocuments;
  final bool canViewAsEmployee;
  final List<DocumentCategory> accessibleCategories;
  final List<String> accessiblePaths;
  final int maxFileSizeMB;
  final List<DocumentFileType> allowedFileTypes;

  // Category-specific upload permissions
  final List<DocumentCategory> uploadableCategories;

  // Category-specific delete permissions
  final List<DocumentCategory> deletableCategories;

  // Employee folder-specific permissions
  final Map<String, bool> employeeFolderViewPermissions;
  final Map<String, bool> employeeFolderUploadPermissions;
  final Map<String, bool> employeeFolderDeletePermissions;

  const DocumentPermissionConfig({
    required this.canViewAll,
    required this.canUploadToAll,
    required this.canDeleteAny,
    required this.canManagePermissions,
    required this.canCreateFolders,
    required this.canArchiveDocuments,
    required this.canUploadToEmployeeDocuments,
    required this.canViewAsEmployee,
    required this.accessibleCategories,
    required this.accessiblePaths,
    required this.maxFileSizeMB,
    required this.allowedFileTypes,
    required this.uploadableCategories,
    required this.deletableCategories,
    this.employeeFolderViewPermissions = const {},
    this.employeeFolderUploadPermissions = const {},
    this.employeeFolderDeletePermissions = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'canViewAll': canViewAll,
      'canUploadToAll': canUploadToAll,
      'canDeleteAny': canDeleteAny,
      'canManagePermissions': canManagePermissions,
      'canCreateFolders': canCreateFolders,
      'canArchiveDocuments': canArchiveDocuments,
      'canUploadToEmployeeDocuments': canUploadToEmployeeDocuments,
      'canViewAsEmployee': canViewAsEmployee,
      'accessibleCategories': accessibleCategories.map((c) => c.value).toList(),
      'accessiblePaths': accessiblePaths,
      'maxFileSizeMB': maxFileSizeMB,
      'allowedFileTypes': allowedFileTypes.map((t) => t.extension).toList(),
      'uploadableCategories': uploadableCategories.map((c) => c.value).toList(),
      'deletableCategories': deletableCategories.map((c) => c.value).toList(),
      'employeeFolderViewPermissions': employeeFolderViewPermissions,
      'employeeFolderUploadPermissions': employeeFolderUploadPermissions,
      'employeeFolderDeletePermissions': employeeFolderDeletePermissions,
    };
  }

  factory DocumentPermissionConfig.fromJson(Map<String, dynamic> json) {
    return DocumentPermissionConfig(
      canViewAll: json['canViewAll'] ?? false,
      canUploadToAll: json['canUploadToAll'] ?? false,
      canDeleteAny: json['canDeleteAny'] ?? false,
      canManagePermissions: json['canManagePermissions'] ?? false,
      canCreateFolders: json['canCreateFolders'] ?? false,
      canArchiveDocuments: json['canArchiveDocuments'] ?? false,
      canUploadToEmployeeDocuments:
          json['canUploadToEmployeeDocuments'] ?? false,
      canViewAsEmployee: json['canViewAsEmployee'] ?? false,
      accessibleCategories:
          (json['accessibleCategories'] as List<dynamic>?)
              ?.map((c) => DocumentCategory.fromString(c.toString()))
              .toList() ??
          [],
      accessiblePaths: List<String>.from(json['accessiblePaths'] ?? []),
      maxFileSizeMB: json['maxFileSizeMB'] ?? 10,
      allowedFileTypes:
          (json['allowedFileTypes'] as List<dynamic>?)
              ?.map((t) => DocumentFileType.fromExtension(t.toString()))
              .toList() ??
          [],
      uploadableCategories:
          (json['uploadableCategories'] as List<dynamic>?)
              ?.map((c) => DocumentCategory.fromString(c.toString()))
              .toList() ??
          [],
      deletableCategories:
          (json['deletableCategories'] as List<dynamic>?)
              ?.map((c) => DocumentCategory.fromString(c.toString()))
              .toList() ??
          [],
      employeeFolderViewPermissions: Map<String, bool>.from(
        json['employeeFolderViewPermissions'] ?? {},
      ),
      employeeFolderUploadPermissions: Map<String, bool>.from(
        json['employeeFolderUploadPermissions'] ?? {},
      ),
      employeeFolderDeletePermissions: Map<String, bool>.from(
        json['employeeFolderDeletePermissions'] ?? {},
      ),
    );
  }

  DocumentPermissionConfig copyWith({
    bool? canViewAll,
    bool? canUploadToAll,
    bool? canDeleteAny,
    bool? canManagePermissions,
    bool? canCreateFolders,
    bool? canArchiveDocuments,
    bool? canUploadToEmployeeDocuments,
    bool? canViewAsEmployee,
    List<DocumentCategory>? accessibleCategories,
    List<String>? accessiblePaths,
    int? maxFileSizeMB,
    List<DocumentFileType>? allowedFileTypes,
    List<DocumentCategory>? uploadableCategories,
    List<DocumentCategory>? deletableCategories,
    Map<String, bool>? employeeFolderViewPermissions,
    Map<String, bool>? employeeFolderUploadPermissions,
    Map<String, bool>? employeeFolderDeletePermissions,
  }) {
    return DocumentPermissionConfig(
      canViewAll: canViewAll ?? this.canViewAll,
      canUploadToAll: canUploadToAll ?? this.canUploadToAll,
      canDeleteAny: canDeleteAny ?? this.canDeleteAny,
      canManagePermissions: canManagePermissions ?? this.canManagePermissions,
      canCreateFolders: canCreateFolders ?? this.canCreateFolders,
      canArchiveDocuments: canArchiveDocuments ?? this.canArchiveDocuments,
      canUploadToEmployeeDocuments:
          canUploadToEmployeeDocuments ?? this.canUploadToEmployeeDocuments,
      canViewAsEmployee: canViewAsEmployee ?? this.canViewAsEmployee,
      accessibleCategories: accessibleCategories ?? this.accessibleCategories,
      accessiblePaths: accessiblePaths ?? this.accessiblePaths,
      maxFileSizeMB: maxFileSizeMB ?? this.maxFileSizeMB,
      allowedFileTypes: allowedFileTypes ?? this.allowedFileTypes,
      uploadableCategories: uploadableCategories ?? this.uploadableCategories,
      deletableCategories: deletableCategories ?? this.deletableCategories,
      employeeFolderViewPermissions:
          employeeFolderViewPermissions ?? this.employeeFolderViewPermissions,
      employeeFolderUploadPermissions:
          employeeFolderUploadPermissions ??
          this.employeeFolderUploadPermissions,
      employeeFolderDeletePermissions:
          employeeFolderDeletePermissions ??
          this.employeeFolderDeletePermissions,
    );
  }

  /// Check if user can upload to a specific category
  bool canUploadToCategory(DocumentCategory category) {
    // If user has global upload permission, they can upload to any accessible category
    if (canUploadToAll) {
      return accessibleCategories.any((c) => c.value == category.value);
    }

    // Otherwise, check if the specific category is in uploadable categories
    return uploadableCategories.any((c) => c.value == category.value);
  }

  /// Check if user can delete from a specific category
  bool canDeleteFromCategory(DocumentCategory category) {
    // If user has global delete permission, they can delete from any accessible category
    if (canDeleteAny) {
      return accessibleCategories.any((c) => c.value == category.value);
    }

    // Otherwise, check if the specific category is in the deletable categories
    return deletableCategories.any((c) => c.value == category.value);
  }

  /// Create default document permissions based on user role
  static DocumentPermissionConfig createDefaultForRole(UserRole role) {
    switch (role) {
      case UserRole.sa:
        // Super Admins get full access to everything
        return DocumentPermissionConfig(
          canViewAll: true,
          canUploadToAll: true,
          canDeleteAny: true,
          canManagePermissions: true,
          canCreateFolders: true,
          canArchiveDocuments: true,
          canUploadToEmployeeDocuments: true,
          canViewAsEmployee: true,
          accessibleCategories: DocumentCategory.values,
          accessiblePaths: const [],
          maxFileSizeMB: 1000,
          allowedFileTypes: DocumentFileType.values,
          uploadableCategories: DocumentCategory.values,
          deletableCategories: DocumentCategory.values,
        );

      case UserRole.admin:
        // Admins get most document permissions
        return DocumentPermissionConfig(
          canViewAll: true,
          canUploadToAll: true,
          canDeleteAny: true,
          canManagePermissions: true,
          canCreateFolders: true,
          canArchiveDocuments: true,
          canUploadToEmployeeDocuments: true,
          canViewAsEmployee: true,
          accessibleCategories: DocumentCategory.values,
          accessiblePaths: const [],
          maxFileSizeMB: 500,
          allowedFileTypes: DocumentFileType.values,
          uploadableCategories: DocumentCategory.values,
          deletableCategories: DocumentCategory.values,
        );

      case UserRole.hr:
        // HR gets employee document access
        return DocumentPermissionConfig(
          canViewAll: true,
          canUploadToAll: false,
          canDeleteAny: false,
          canManagePermissions: false,
          canCreateFolders: true,
          canArchiveDocuments: true,
          canUploadToEmployeeDocuments: false,
          canViewAsEmployee: false,
          accessibleCategories: [
            DocumentCategory.employee,
            DocumentCategory.hr,
            DocumentCategory.company,
            DocumentCategory.training,
          ],
          accessiblePaths: const [],
          maxFileSizeMB: 100,
          allowedFileTypes: DocumentFileType.values,
          uploadableCategories: [
            DocumentCategory.employee,
            DocumentCategory.hr,
            DocumentCategory.company,
            DocumentCategory.training,
          ],
          deletableCategories: [DocumentCategory.hr],
        );

      case UserRole.manager:
        // Managers get team document access
        return DocumentPermissionConfig(
          canViewAll: false,
          canUploadToAll: false,
          canDeleteAny: false,
          canManagePermissions: false,
          canCreateFolders: true,
          canArchiveDocuments: false,
          canUploadToEmployeeDocuments: false,
          canViewAsEmployee: false,
          accessibleCategories: [
            DocumentCategory.employee,
            DocumentCategory.shared,
            DocumentCategory.project,
          ],
          accessiblePaths: const [],
          maxFileSizeMB: 50,
          allowedFileTypes: DocumentFileType.values,
          uploadableCategories: [
            DocumentCategory.shared,
            DocumentCategory.project,
          ],
          deletableCategories: const [],
        );

      case UserRole.tl:
        return DocumentPermissionConfig(
          canViewAll: TeamLeadPermissions.canViewAll,
          canUploadToAll: TeamLeadPermissions.canUploadToAll,
          canDeleteAny: TeamLeadPermissions.canDeleteAny,
          canManagePermissions: TeamLeadPermissions.canManagePermissions,
          canCreateFolders: TeamLeadPermissions.canCreateFolders,
          canArchiveDocuments: TeamLeadPermissions.canArchiveDocuments,
          canUploadToEmployeeDocuments:
              TeamLeadPermissions.canUploadToEmployeeDocuments,
          canViewAsEmployee: TeamLeadPermissions.canViewAsEmployee,
          accessibleCategories: TeamLeadPermissions.accessibleCategories,
          accessiblePaths: TeamLeadPermissions.accessiblePaths,
          maxFileSizeMB: TeamLeadPermissions.maxFileSizeMB,
          allowedFileTypes: TeamLeadPermissions.allowedFileTypes,
          uploadableCategories: TeamLeadPermissions.uploadableCategories,
          deletableCategories: const [],
        );

      case UserRole.se:
      case UserRole.employee:
      case UserRole.contractor:
      case UserRole.intern:
      default:
        // Basic employees get minimal document access
        return DocumentPermissionConfig(
          canViewAll: false,
          canUploadToAll: false,
          canDeleteAny: false,
          canManagePermissions: false,
          canCreateFolders: false,
          canArchiveDocuments: false,
          canUploadToEmployeeDocuments: false,
          canViewAsEmployee: false,
          accessibleCategories: [
            DocumentCategory.employee,
            DocumentCategory.shared,
          ],
          accessiblePaths: const [],
          maxFileSizeMB: 25,
          allowedFileTypes: [
            DocumentFileType.pdf,
            DocumentFileType.doc,
            DocumentFileType.docx,
            DocumentFileType.jpg,
            DocumentFileType.png,
          ],
          uploadableCategories: [DocumentCategory.employee],
          deletableCategories: const [],
        );
    }
  }
}

/// Page-level permission configuration
class PagePermissionConfig {
  final bool canAccessDashboard;
  final bool canAccessEmployees;
  final bool canAccessMyDocuments;
  final bool canAccessDocuments;
  final bool canAccessTasks;
  final bool canAccessLeaves;
  final bool canAccessLetters;
  final bool canAccessUserManagement;
  final bool canAccessProfileApprovals;
  final bool canAccessSystemSettings;
  final bool canAccessProfile;
  final bool canAccessOrgChart;
  final bool canAccessMoments;
  final bool canAccessAuditLogs;
  final bool canAccessDynamicConfig;

  // Employee ID-based access control
  final List<String>
  allowedEmployeeIds; // Empty list means all employees allowed
  final List<String>
  restrictedEmployeeIds; // Specific employee IDs that are restricted
  final bool
  useEmployeeIdRestriction; // Whether to use employee ID-based restrictions

  const PagePermissionConfig({
    this.canAccessDashboard = true,
    this.canAccessEmployees = false,
    this.canAccessMyDocuments = false,
    this.canAccessDocuments = false,
    this.canAccessTasks = false,
    this.canAccessLeaves = false,
    this.canAccessLetters = false,
    this.canAccessUserManagement = false,
    this.canAccessProfileApprovals = false,
    this.canAccessSystemSettings = false,
    this.canAccessProfile = true,
    this.canAccessOrgChart = false,
    this.canAccessMoments = false,
    this.canAccessAuditLogs = false,
    this.canAccessDynamicConfig = false,
    this.allowedEmployeeIds = const [],
    this.restrictedEmployeeIds = const [],
    this.useEmployeeIdRestriction = false,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'canAccessDashboard': canAccessDashboard,
      'canAccessEmployees': canAccessEmployees,
      'canAccessMyDocuments': canAccessMyDocuments,
      'canAccessDocuments': canAccessDocuments,
      'canAccessTasks': canAccessTasks,
      'canAccessLeaves': canAccessLeaves,
      'canAccessLetters': canAccessLetters,
      'canAccessUserManagement': canAccessUserManagement,
      'canAccessProfileApprovals': canAccessProfileApprovals,
      'canAccessSystemSettings': canAccessSystemSettings,
      'canAccessProfile': canAccessProfile,
      'canAccessOrgChart': canAccessOrgChart,
      'canAccessMoments': canAccessMoments,
      'canAccessAuditLogs': canAccessAuditLogs,
      'canAccessDynamicConfig': canAccessDynamicConfig,
      'allowedEmployeeIds': allowedEmployeeIds,
      'restrictedEmployeeIds': restrictedEmployeeIds,
      'useEmployeeIdRestriction': useEmployeeIdRestriction,
    };
  }

  /// Create from JSON
  factory PagePermissionConfig.fromJson(Map<String, dynamic> json) {
    return PagePermissionConfig(
      canAccessDashboard: json['canAccessDashboard'] ?? true,
      canAccessEmployees: json['canAccessEmployees'] ?? false,
      canAccessMyDocuments: json['canAccessMyDocuments'] ?? false,
      canAccessDocuments: json['canAccessDocuments'] ?? false,
      canAccessTasks: json['canAccessTasks'] ?? false,
      canAccessLeaves: json['canAccessLeaves'] ?? false,
      canAccessLetters: json['canAccessLetters'] ?? false,
      canAccessUserManagement: json['canAccessUserManagement'] ?? false,
      canAccessProfileApprovals: json['canAccessProfileApprovals'] ?? false,
      canAccessSystemSettings: json['canAccessSystemSettings'] ?? false,
      canAccessProfile: json['canAccessProfile'] ?? true,
      canAccessOrgChart: json['canAccessOrgChart'] ?? false,
      canAccessMoments: json['canAccessMoments'] ?? false,
      canAccessAuditLogs: json['canAccessAuditLogs'] ?? false,
      canAccessDynamicConfig: json['canAccessDynamicConfig'] ?? false,
      allowedEmployeeIds: List<String>.from(json['allowedEmployeeIds'] ?? []),
      restrictedEmployeeIds: List<String>.from(
        json['restrictedEmployeeIds'] ?? [],
      ),
      useEmployeeIdRestriction: json['useEmployeeIdRestriction'] ?? false,
    );
  }

  /// Create a copy with updated values
  PagePermissionConfig copyWith({
    bool? canAccessDashboard,
    bool? canAccessEmployees,
    bool? canAccessMyDocuments,
    bool? canAccessDocuments,
    bool? canAccessTasks,
    bool? canAccessLeaves,
    bool? canAccessLetters,
    bool? canAccessUserManagement,
    bool? canAccessProfileApprovals,
    bool? canAccessSystemSettings,
    bool? canAccessProfile,
    bool? canAccessOrgChart,
    bool? canAccessMoments,
    bool? canAccessAuditLogs,
    bool? canAccessDynamicConfig,
    List<String>? allowedEmployeeIds,
    List<String>? restrictedEmployeeIds,
    bool? useEmployeeIdRestriction,
  }) {
    return PagePermissionConfig(
      canAccessDashboard: canAccessDashboard ?? this.canAccessDashboard,
      canAccessEmployees: canAccessEmployees ?? this.canAccessEmployees,
      canAccessMyDocuments: canAccessMyDocuments ?? this.canAccessMyDocuments,
      canAccessDocuments: canAccessDocuments ?? this.canAccessDocuments,
      canAccessTasks: canAccessTasks ?? this.canAccessTasks,
      canAccessLeaves: canAccessLeaves ?? this.canAccessLeaves,
      canAccessLetters: canAccessLetters ?? this.canAccessLetters,
      canAccessUserManagement:
          canAccessUserManagement ?? this.canAccessUserManagement,
      canAccessProfileApprovals:
          canAccessProfileApprovals ?? this.canAccessProfileApprovals,
      canAccessSystemSettings:
          canAccessSystemSettings ?? this.canAccessSystemSettings,
      canAccessProfile: canAccessProfile ?? this.canAccessProfile,
      canAccessOrgChart: canAccessOrgChart ?? this.canAccessOrgChart,
      canAccessMoments: canAccessMoments ?? this.canAccessMoments,
      canAccessAuditLogs: canAccessAuditLogs ?? this.canAccessAuditLogs,
      canAccessDynamicConfig:
          canAccessDynamicConfig ?? this.canAccessDynamicConfig,
      allowedEmployeeIds: allowedEmployeeIds ?? this.allowedEmployeeIds,
      restrictedEmployeeIds:
          restrictedEmployeeIds ?? this.restrictedEmployeeIds,
      useEmployeeIdRestriction:
          useEmployeeIdRestriction ?? this.useEmployeeIdRestriction,
    );
  }

  /// Check if a specific employee ID can access based on restrictions
  bool canEmployeeAccess(String? employeeId) {
    if (!useEmployeeIdRestriction || employeeId == null) {
      return true; // No restrictions or no employee ID provided
    }

    // If there are specific allowed employee IDs, check if this one is allowed
    if (allowedEmployeeIds.isNotEmpty) {
      return allowedEmployeeIds.contains(employeeId);
    }

    // If there are restricted employee IDs, check if this one is NOT restricted
    if (restrictedEmployeeIds.isNotEmpty) {
      return !restrictedEmployeeIds.contains(employeeId);
    }

    return true; // No specific restrictions
  }

  /// Get list of all page permissions as a map
  Map<String, bool> get allPagePermissions => {
    'dashboard': canAccessDashboard,
    'employees': canAccessEmployees,
    'myDocuments': canAccessMyDocuments,
    'documents': canAccessDocuments,
    'tasks': canAccessTasks,
    'leaves': canAccessLeaves,
    'userManagement': canAccessUserManagement,
    'profileApprovals': canAccessProfileApprovals,
    'systemSettings': canAccessSystemSettings,
    'profile': canAccessProfile,
    'orgChart': canAccessOrgChart,
    'moments': canAccessMoments,
    'auditLogs': canAccessAuditLogs,
    'dynamicConfig': canAccessDynamicConfig,
  };

  /// Create default page permissions based on user role
  static PagePermissionConfig createDefaultForRole(UserRole role) {
    switch (role) {
      case UserRole.sa:
        // Super Admins get full access to everything
        return const PagePermissionConfig(
          canAccessDashboard: true,
          canAccessEmployees: true,
          canAccessMyDocuments: true,
          canAccessDocuments: true,
          canAccessTasks: true,
          canAccessLeaves: true,
          canAccessLetters: true, // <-- Enable Letters for Super Admin
          canAccessUserManagement: true,
          canAccessProfileApprovals: true,
          canAccessSystemSettings: true,
          canAccessProfile: true,
          canAccessOrgChart: true,
          canAccessMoments: true,
          canAccessAuditLogs: true,
          canAccessDynamicConfig:
              true, // Only Super Admin can access dynamic config
          useEmployeeIdRestriction: false, // No restrictions for Super Admin
        );

      case UserRole.admin:
        // Admins get access to most things except system settings
        return const PagePermissionConfig(
          canAccessDashboard: true,
          canAccessEmployees: true,
          canAccessMyDocuments: true,
          canAccessDocuments: true,
          canAccessTasks: true,
          canAccessLeaves: true,
          canAccessLetters: true, // <-- Enable Letters for Admin
          canAccessUserManagement: true,
          canAccessProfileApprovals: true,
          canAccessSystemSettings: false, // Only Super Admin can access
          canAccessProfile: true,
          canAccessOrgChart: true,
          canAccessMoments: true, // Admin can manage dashboard content
          canAccessAuditLogs: true,
          canAccessDynamicConfig: false, // Only Super Admin can access
        );

      case UserRole.hr:
        // HR can access employee and document management
        return const PagePermissionConfig(
          canAccessDashboard: true,
          canAccessEmployees: true,
          canAccessMyDocuments: true,
          canAccessDocuments: true,
          canAccessTasks: false,
          canAccessLeaves: true,
          canAccessLetters: true, // <-- Enable Letters for HR
          canAccessUserManagement: false,
          canAccessProfileApprovals: true,
          canAccessSystemSettings: false,
          canAccessProfile: true,
          canAccessOrgChart: true,
          canAccessMoments: true, // HR can manage dashboard content
          canAccessAuditLogs: true,
          canAccessDynamicConfig: false, // Only Super Admin can access
        );

      case UserRole.manager:
        // Managers can access team-related features
        return const PagePermissionConfig(
          canAccessDashboard: true,
          canAccessEmployees: true,
          canAccessMyDocuments: true,
          canAccessDocuments: false,
          canAccessTasks: true,
          canAccessLeaves: true,
          canAccessUserManagement: false,
          canAccessProfileApprovals: false,
          canAccessSystemSettings: false,
          canAccessProfile: true,
          canAccessOrgChart: true,
          canAccessMoments: true, // Manager can manage dashboard content
          canAccessAuditLogs: true,
          canAccessDynamicConfig: false, // Only Super Admin can access
        );

      case UserRole.tl:
        // Team Leads have limited management access
        return const PagePermissionConfig(
          canAccessDashboard: true,
          canAccessEmployees: true,
          canAccessMyDocuments: true,
          canAccessDocuments: true,
          canAccessTasks: true,
          canAccessLeaves: false,
          canAccessUserManagement: false,
          canAccessProfileApprovals: false,
          canAccessSystemSettings: false,
          canAccessProfile: true,
          canAccessOrgChart: true,
          canAccessMoments: true, // Team Lead can manage dashboard content
          canAccessAuditLogs: true,
          canAccessDynamicConfig: false, // Only Super Admin can access
        );

      case UserRole.se:
      case UserRole.employee:
      case UserRole.contractor:
      case UserRole.intern:
      default:
        // Basic employees get minimal access
        return const PagePermissionConfig(
          canAccessDashboard: true,
          canAccessEmployees: false,
          canAccessMyDocuments: true,
          canAccessDocuments: false,
          canAccessTasks: false,
          canAccessLeaves: false,
          canAccessUserManagement: false,
          canAccessProfileApprovals: false,
          canAccessSystemSettings: false,
          canAccessProfile: true,
          canAccessOrgChart: false,
          canAccessMoments:
              false, // Regular employees cannot manage dashboard content
          canAccessAuditLogs: false,
          canAccessDynamicConfig: false, // Only Super Admin can access
        );
    }
  }
}

/// Enhanced System Permission Configuration with Page-level permissions
class SystemPermissionConfig {
  // Page-level permissions
  final PagePermissionConfig pagePermissions;

  // Existing system permissions
  final bool canManageSystem;
  final bool canAccessAdminPanel;
  final bool canDelegateRoles;
  final bool canManageCompanySettings;
  final bool canManageUsers;
  final bool canCreateUsers;
  final bool canDeactivateUsers;
  final bool canViewAllUsers;
  final bool canAssignRoles;
  final bool canManageEmployees;
  final bool canAddEmployees;
  final bool canViewEmployeeDetails;
  final bool canEditEmployeeProfiles;
  final bool canManageEmployeeDocuments;
  final bool canConductPerformanceReviews;
  final bool canManageTasks;
  final bool canCreateTasks;
  final bool canDeleteTasks;
  final bool canDeleteTaskDocuments;
  final bool canAssignTasks;
  final bool canViewTeamTasks;
  final bool canCreateProjects;
  final bool canManageProjects;
  final bool canViewReports;
  final bool canGenerateReports;
  final bool canViewAnalytics;
  final bool canExportData;
  final bool canApproveLeaves;
  final bool canViewTeamAttendance;
  final bool canManageAttendancePolicy;
  final bool canOverrideAttendance;
  final bool canViewSalaryInfo;
  final bool canManagePayroll;
  final bool canApproveBudgets;
  final bool canViewFinancialReports;
  final bool canManageTraining;
  final bool canAssignTraining;
  final bool canViewTrainingReports;
  final bool canCreateTrainingContent;
  final bool canSendCompanyAnnouncements;
  final bool canModerateDiscussions;
  final bool canAccessAllChannels;
  final bool canViewAuditLogs;
  final bool canManageSecuritySettings;
  final bool canAccessComplianceReports;
  final bool canWorkRemotely;
  final bool canAccessAfterHours;
  final bool canBypassApprovals;
  final bool canManageSignatures;
  final bool canAddSignatures;
  final bool canEditSignatures;
  final bool canDeleteSignatures;

  const SystemPermissionConfig({
    this.pagePermissions = const PagePermissionConfig(),
    this.canManageSystem = false,
    this.canAccessAdminPanel = false,
    this.canDelegateRoles = false,
    this.canManageCompanySettings = false,
    this.canManageUsers = false,
    this.canCreateUsers = false,
    this.canDeactivateUsers = false,
    this.canViewAllUsers = false,
    this.canAssignRoles = false,
    this.canManageEmployees = false,
    this.canAddEmployees = false,
    this.canViewEmployeeDetails = false,
    this.canEditEmployeeProfiles = false,
    this.canManageEmployeeDocuments = false,
    this.canConductPerformanceReviews = false,
    this.canManageTasks = false,
    this.canCreateTasks = false,
    this.canDeleteTasks = false,
    this.canDeleteTaskDocuments = false,
    this.canAssignTasks = false,
    this.canViewTeamTasks = false,
    this.canCreateProjects = false,
    this.canManageProjects = false,
    this.canViewReports = false,
    this.canGenerateReports = false,
    this.canViewAnalytics = false,
    this.canExportData = false,
    this.canApproveLeaves = false,
    this.canViewTeamAttendance = false,
    this.canManageAttendancePolicy = false,
    this.canOverrideAttendance = false,
    this.canViewSalaryInfo = false,
    this.canManagePayroll = false,
    this.canApproveBudgets = false,
    this.canViewFinancialReports = false,
    this.canManageTraining = false,
    this.canAssignTraining = false,
    this.canViewTrainingReports = false,
    this.canCreateTrainingContent = false,
    this.canSendCompanyAnnouncements = false,
    this.canModerateDiscussions = false,
    this.canAccessAllChannels = false,
    this.canViewAuditLogs = false,
    this.canManageSecuritySettings = false,
    this.canAccessComplianceReports = false,
    this.canWorkRemotely = false,
    this.canAccessAfterHours = false,
    this.canBypassApprovals = false,
    this.canManageSignatures = false,
    this.canAddSignatures = false,
    this.canEditSignatures = false,
    this.canDeleteSignatures = false,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'pagePermissions': pagePermissions.toJson(),
      'canManageSystem': canManageSystem,
      'canAccessAdminPanel': canAccessAdminPanel,
      'canDelegateRoles': canDelegateRoles,
      'canManageCompanySettings': canManageCompanySettings,
      'canManageUsers': canManageUsers,
      'canCreateUsers': canCreateUsers,
      'canDeactivateUsers': canDeactivateUsers,
      'canViewAllUsers': canViewAllUsers,
      'canAssignRoles': canAssignRoles,
      'canManageEmployees': canManageEmployees,
      'canAddEmployees': canAddEmployees,
      'canViewEmployeeDetails': canViewEmployeeDetails,
      'canEditEmployeeProfiles': canEditEmployeeProfiles,
      'canManageEmployeeDocuments': canManageEmployeeDocuments,
      'canConductPerformanceReviews': canConductPerformanceReviews,
      'canManageTasks': canManageTasks,
      'canCreateTasks': canCreateTasks,
      'canDeleteTasks': canDeleteTasks,
      'canDeleteTaskDocuments': canDeleteTaskDocuments,
      'canAssignTasks': canAssignTasks,
      'canViewTeamTasks': canViewTeamTasks,
      'canCreateProjects': canCreateProjects,
      'canManageProjects': canManageProjects,
      'canViewReports': canViewReports,
      'canGenerateReports': canGenerateReports,
      'canViewAnalytics': canViewAnalytics,
      'canExportData': canExportData,
      'canApproveLeaves': canApproveLeaves,
      'canViewTeamAttendance': canViewTeamAttendance,
      'canManageAttendancePolicy': canManageAttendancePolicy,
      'canOverrideAttendance': canOverrideAttendance,
      'canViewSalaryInfo': canViewSalaryInfo,
      'canManagePayroll': canManagePayroll,
      'canApproveBudgets': canApproveBudgets,
      'canViewFinancialReports': canViewFinancialReports,
      'canManageTraining': canManageTraining,
      'canAssignTraining': canAssignTraining,
      'canViewTrainingReports': canViewTrainingReports,
      'canCreateTrainingContent': canCreateTrainingContent,
      'canSendCompanyAnnouncements': canSendCompanyAnnouncements,
      'canModerateDiscussions': canModerateDiscussions,
      'canAccessAllChannels': canAccessAllChannels,
      'canViewAuditLogs': canViewAuditLogs,
      'canManageSecuritySettings': canManageSecuritySettings,
      'canAccessComplianceReports': canAccessComplianceReports,
      'canWorkRemotely': canWorkRemotely,
      'canAccessAfterHours': canAccessAfterHours,
      'canBypassApprovals': canBypassApprovals,
      'canManageSignatures': canManageSignatures,
      'canAddSignatures': canAddSignatures,
      'canEditSignatures': canEditSignatures,
      'canDeleteSignatures': canDeleteSignatures,
    };
  }

  /// Create from JSON
  factory SystemPermissionConfig.fromJson(Map<String, dynamic> json) {
    return SystemPermissionConfig(
      pagePermissions: PagePermissionConfig.fromJson(
        json['pagePermissions'] ?? {},
      ),
      canManageSystem: json['canManageSystem'] ?? false,
      canAccessAdminPanel: json['canAccessAdminPanel'] ?? false,
      canDelegateRoles: json['canDelegateRoles'] ?? false,
      canManageCompanySettings: json['canManageCompanySettings'] ?? false,
      canManageUsers: json['canManageUsers'] ?? false,
      canCreateUsers: json['canCreateUsers'] ?? false,
      canDeactivateUsers: json['canDeactivateUsers'] ?? false,
      canViewAllUsers: json['canViewAllUsers'] ?? false,
      canAssignRoles: json['canAssignRoles'] ?? false,
      canManageEmployees: json['canManageEmployees'] ?? false,
      canAddEmployees: json['canAddEmployees'] ?? false,
      canViewEmployeeDetails: json['canViewEmployeeDetails'] ?? false,
      canEditEmployeeProfiles: json['canEditEmployeeProfiles'] ?? false,
      canManageEmployeeDocuments: json['canManageEmployeeDocuments'] ?? false,
      canConductPerformanceReviews:
          json['canConductPerformanceReviews'] ?? false,
      canManageTasks: json['canManageTasks'] ?? false,
      canCreateTasks: json['canCreateTasks'] ?? false,
      canDeleteTasks: json['canDeleteTasks'] ?? false,
      canDeleteTaskDocuments: json['canDeleteTaskDocuments'] ?? false,
      canAssignTasks: json['canAssignTasks'] ?? false,
      canViewTeamTasks: json['canViewTeamTasks'] ?? false,
      canCreateProjects: json['canCreateProjects'] ?? false,
      canManageProjects: json['canManageProjects'] ?? false,
      canViewReports: json['canViewReports'] ?? false,
      canGenerateReports: json['canGenerateReports'] ?? false,
      canViewAnalytics: json['canViewAnalytics'] ?? false,
      canExportData: json['canExportData'] ?? false,
      canApproveLeaves: json['canApproveLeaves'] ?? false,
      canViewTeamAttendance: json['canViewTeamAttendance'] ?? false,
      canManageAttendancePolicy: json['canManageAttendancePolicy'] ?? false,
      canOverrideAttendance: json['canOverrideAttendance'] ?? false,
      canViewSalaryInfo: json['canViewSalaryInfo'] ?? false,
      canManagePayroll: json['canManagePayroll'] ?? false,
      canApproveBudgets: json['canApproveBudgets'] ?? false,
      canViewFinancialReports: json['canViewFinancialReports'] ?? false,
      canManageTraining: json['canManageTraining'] ?? false,
      canAssignTraining: json['canAssignTraining'] ?? false,
      canViewTrainingReports: json['canViewTrainingReports'] ?? false,
      canCreateTrainingContent: json['canCreateTrainingContent'] ?? false,
      canSendCompanyAnnouncements: json['canSendCompanyAnnouncements'] ?? false,
      canModerateDiscussions: json['canModerateDiscussions'] ?? false,
      canAccessAllChannels: json['canAccessAllChannels'] ?? false,
      canViewAuditLogs: json['canViewAuditLogs'] ?? false,
      canManageSecuritySettings: json['canManageSecuritySettings'] ?? false,
      canAccessComplianceReports: json['canAccessComplianceReports'] ?? false,
      canWorkRemotely: json['canWorkRemotely'] ?? false,
      canAccessAfterHours: json['canAccessAfterHours'] ?? false,
      canBypassApprovals: json['canBypassApprovals'] ?? false,
      canManageSignatures: json['canManageSignatures'] ?? false,
      canAddSignatures: json['canAddSignatures'] ?? false,
      canEditSignatures: json['canEditSignatures'] ?? false,
      canDeleteSignatures: json['canDeleteSignatures'] ?? false,
    );
  }

  /// Create a copy with updated values
  SystemPermissionConfig copyWith({
    PagePermissionConfig? pagePermissions,
    bool? canManageSystem,
    bool? canAccessAdminPanel,
    bool? canDelegateRoles,
    bool? canManageCompanySettings,
    bool? canManageUsers,
    bool? canCreateUsers,
    bool? canDeactivateUsers,
    bool? canViewAllUsers,
    bool? canAssignRoles,
    bool? canManageEmployees,
    bool? canAddEmployees,
    bool? canViewEmployeeDetails,
    bool? canEditEmployeeProfiles,
    bool? canManageEmployeeDocuments,
    bool? canConductPerformanceReviews,
    bool? canManageTasks,
    bool? canCreateTasks,
    bool? canDeleteTasks,
    bool? canDeleteTaskDocuments,
    bool? canAssignTasks,
    bool? canViewTeamTasks,
    bool? canCreateProjects,
    bool? canManageProjects,
    bool? canViewReports,
    bool? canGenerateReports,
    bool? canViewAnalytics,
    bool? canExportData,
    bool? canApproveLeaves,
    bool? canViewTeamAttendance,
    bool? canManageAttendancePolicy,
    bool? canOverrideAttendance,
    bool? canViewSalaryInfo,
    bool? canManagePayroll,
    bool? canApproveBudgets,
    bool? canViewFinancialReports,
    bool? canManageTraining,
    bool? canAssignTraining,
    bool? canViewTrainingReports,
    bool? canCreateTrainingContent,
    bool? canSendCompanyAnnouncements,
    bool? canModerateDiscussions,
    bool? canAccessAllChannels,
    bool? canViewAuditLogs,
    bool? canManageSecuritySettings,
    bool? canAccessComplianceReports,
    bool? canWorkRemotely,
    bool? canAccessAfterHours,
    bool? canBypassApprovals,
    bool? canManageSignatures,
    bool? canAddSignatures,
    bool? canEditSignatures,
    bool? canDeleteSignatures,
  }) {
    return SystemPermissionConfig(
      pagePermissions: pagePermissions ?? this.pagePermissions,
      canManageSystem: canManageSystem ?? this.canManageSystem,
      canAccessAdminPanel: canAccessAdminPanel ?? this.canAccessAdminPanel,
      canDelegateRoles: canDelegateRoles ?? this.canDelegateRoles,
      canManageCompanySettings:
          canManageCompanySettings ?? this.canManageCompanySettings,
      canManageUsers: canManageUsers ?? this.canManageUsers,
      canCreateUsers: canCreateUsers ?? this.canCreateUsers,
      canDeactivateUsers: canDeactivateUsers ?? this.canDeactivateUsers,
      canViewAllUsers: canViewAllUsers ?? this.canViewAllUsers,
      canAssignRoles: canAssignRoles ?? this.canAssignRoles,
      canManageEmployees: canManageEmployees ?? this.canManageEmployees,
      canAddEmployees: canAddEmployees ?? this.canAddEmployees,
      canViewEmployeeDetails:
          canViewEmployeeDetails ?? this.canViewEmployeeDetails,
      canEditEmployeeProfiles:
          canEditEmployeeProfiles ?? this.canEditEmployeeProfiles,
      canManageEmployeeDocuments:
          canManageEmployeeDocuments ?? this.canManageEmployeeDocuments,
      canConductPerformanceReviews:
          canConductPerformanceReviews ?? this.canConductPerformanceReviews,
      canManageTasks: canManageTasks ?? this.canManageTasks,
      canCreateTasks: canCreateTasks ?? this.canCreateTasks,
      canDeleteTasks: canDeleteTasks ?? this.canDeleteTasks,
      canDeleteTaskDocuments:
          canDeleteTaskDocuments ?? this.canDeleteTaskDocuments,
      canAssignTasks: canAssignTasks ?? this.canAssignTasks,
      canViewTeamTasks: canViewTeamTasks ?? this.canViewTeamTasks,
      canCreateProjects: canCreateProjects ?? this.canCreateProjects,
      canManageProjects: canManageProjects ?? this.canManageProjects,
      canViewReports: canViewReports ?? this.canViewReports,
      canGenerateReports: canGenerateReports ?? this.canGenerateReports,
      canViewAnalytics: canViewAnalytics ?? this.canViewAnalytics,
      canExportData: canExportData ?? this.canExportData,
      canApproveLeaves: canApproveLeaves ?? this.canApproveLeaves,
      canViewTeamAttendance:
          canViewTeamAttendance ?? this.canViewTeamAttendance,
      canManageAttendancePolicy:
          canManageAttendancePolicy ?? this.canManageAttendancePolicy,
      canOverrideAttendance:
          canOverrideAttendance ?? this.canOverrideAttendance,
      canViewSalaryInfo: canViewSalaryInfo ?? this.canViewSalaryInfo,
      canManagePayroll: canManagePayroll ?? this.canManagePayroll,
      canApproveBudgets: canApproveBudgets ?? this.canApproveBudgets,
      canViewFinancialReports:
          canViewFinancialReports ?? this.canViewFinancialReports,
      canManageTraining: canManageTraining ?? this.canManageTraining,
      canAssignTraining: canAssignTraining ?? this.canAssignTraining,
      canViewTrainingReports:
          canViewTrainingReports ?? this.canViewTrainingReports,
      canCreateTrainingContent:
          canCreateTrainingContent ?? this.canCreateTrainingContent,
      canSendCompanyAnnouncements:
          canSendCompanyAnnouncements ?? this.canSendCompanyAnnouncements,
      canModerateDiscussions:
          canModerateDiscussions ?? this.canModerateDiscussions,
      canAccessAllChannels: canAccessAllChannels ?? this.canAccessAllChannels,
      canViewAuditLogs: canViewAuditLogs ?? this.canViewAuditLogs,
      canManageSecuritySettings:
          canManageSecuritySettings ?? this.canManageSecuritySettings,
      canAccessComplianceReports:
          canAccessComplianceReports ?? this.canAccessComplianceReports,
      canWorkRemotely: canWorkRemotely ?? this.canWorkRemotely,
      canAccessAfterHours: canAccessAfterHours ?? this.canAccessAfterHours,
      canBypassApprovals: canBypassApprovals ?? this.canBypassApprovals,
      canManageSignatures: canManageSignatures ?? this.canManageSignatures,
      canAddSignatures: canAddSignatures ?? this.canAddSignatures,
      canEditSignatures: canEditSignatures ?? this.canEditSignatures,
      canDeleteSignatures: canDeleteSignatures ?? this.canDeleteSignatures,
    );
  }

  /// Create default system permissions based on user role
  static SystemPermissionConfig createDefaultForRole(UserRole role) {
    final defaultPagePermissions = PagePermissionConfig.createDefaultForRole(
      role,
    );

    switch (role) {
      case UserRole.sa:
        // Super Admins get full access to everything
        return SystemPermissionConfig(
          pagePermissions: defaultPagePermissions,
          canManageSystem: true,
          canAccessAdminPanel: true,
          canDelegateRoles: true,
          canManageCompanySettings: true,
          canManageUsers: true,
          canCreateUsers: true,
          canDeactivateUsers: true,
          canViewAllUsers: true,
          canAssignRoles: true,
          canManageEmployees: true,
          canAddEmployees: false,
          canViewEmployeeDetails: true,
          canEditEmployeeProfiles: true,
          canManageEmployeeDocuments: true,
          canConductPerformanceReviews: true,
          canManageTasks: true,
          canCreateTasks: true,
          canDeleteTasks: true,
          canDeleteTaskDocuments: true,
          canAssignTasks: true,
          canViewTeamTasks: true,
          canCreateProjects: true,
          canManageProjects: true,
          canViewReports: true,
          canGenerateReports: true,
          canViewAnalytics: true,
          canExportData: true,
          canApproveLeaves: true,
          canViewTeamAttendance: true,
          canManageAttendancePolicy: true,
          canOverrideAttendance: true,
          canViewSalaryInfo: true,
          canManagePayroll: true,
          canApproveBudgets: true,
          canViewFinancialReports: true,
          canManageTraining: true,
          canAssignTraining: true,
          canViewTrainingReports: true,
          canCreateTrainingContent: true,
          canSendCompanyAnnouncements: true,
          canModerateDiscussions: true,
          canAccessAllChannels: true,
          canViewAuditLogs: true,
          canManageSecuritySettings: true,
          canAccessComplianceReports: true,
          canWorkRemotely: true,
          canAccessAfterHours: true,
          canBypassApprovals: true,
          canManageSignatures: true,
          canAddSignatures: true,
          canEditSignatures: true,
          canDeleteSignatures: true,
        );

      case UserRole.admin:
        // Admins get most permissions except system-level ones
        return SystemPermissionConfig(
          pagePermissions: defaultPagePermissions,
          canManageSystem: false, // Only Super Admin
          canAccessAdminPanel: true,
          canDelegateRoles: true,
          canManageCompanySettings: false, // Only Super Admin
          canManageUsers: true,
          canCreateUsers: true, // Can create users in admin panel
          canDeactivateUsers: true,
          canViewAllUsers: true,
          canAssignRoles: true,
          canManageEmployees: true,
          canAddEmployees:
              false, // Disable adding employees from employees page
          canViewEmployeeDetails: true,
          canEditEmployeeProfiles: true,
          canManageEmployeeDocuments: true,
          canConductPerformanceReviews: true,
          canManageTasks: true,
          canCreateTasks: true,
          canDeleteTasks: true,
          canDeleteTaskDocuments: true,
          canAssignTasks: true,
          canViewTeamTasks: true,
          canCreateProjects: true,
          canManageProjects: true,
          canViewReports: true,
          canGenerateReports: true,
          canViewAnalytics: true,
          canExportData: true,
          canApproveLeaves: true,
          canViewTeamAttendance: true,
          canManageAttendancePolicy: true,
          canOverrideAttendance: true,
          canViewSalaryInfo: true,
          canManagePayroll: true,
          canApproveBudgets: true,
          canViewFinancialReports: true,
          canManageTraining: true,
          canAssignTraining: true,
          canViewTrainingReports: true,
          canCreateTrainingContent: true,
          canSendCompanyAnnouncements: true,
          canModerateDiscussions: true,
          canAccessAllChannels: true,
          canViewAuditLogs: true,
          canManageSecuritySettings: false, // Only Super Admin
          canAccessComplianceReports: true,
          canWorkRemotely: true,
          canAccessAfterHours: true,
          canBypassApprovals: false, // Only Super Admin
          canManageSignatures: true,
          canAddSignatures: true,
          canEditSignatures: true,
          canDeleteSignatures: true,
        );

      case UserRole.hr:
        // HR gets employee and document management permissions
        return SystemPermissionConfig(
          pagePermissions: defaultPagePermissions,
          canManageEmployees: true,
          canAddEmployees: false, // HR should use admin panel to create users
          canViewEmployeeDetails: true,
          canEditEmployeeProfiles: true,
          canManageEmployeeDocuments: true,
          canConductPerformanceReviews: true,
          canApproveLeaves: true,
          canViewTeamAttendance: true,
          canManageAttendancePolicy: true,
          canViewSalaryInfo: true,
          canManagePayroll: true,
          canManageTraining: true,
          canAssignTraining: true,
          canViewTrainingReports: true,
          canCreateTrainingContent: true,
          canSendCompanyAnnouncements: true,
          canViewReports: true,
          canGenerateReports: true,
          canViewAnalytics: true,
          canExportData: true,
          // No user management permissions for HR
          canCreateUsers: false,
          canManageUsers: false,
          canDeactivateUsers: false,
          canAssignRoles: false,
          canManageSignatures: true,
          canAddSignatures: true,
          canEditSignatures: true,
          canDeleteSignatures: true,
        );

      case UserRole.manager:
        // Managers get team management permissions
        return SystemPermissionConfig(
          pagePermissions: defaultPagePermissions,
          canViewEmployeeDetails: true,
          canAddEmployees: false, // Managers cannot add employees
          canManageTasks: true,
          canCreateTasks: true,
          canDeleteTasks: true,
          canDeleteTaskDocuments: true,
          canAssignTasks: true,
          canViewTeamTasks: true,
          canCreateProjects: true,
          canManageProjects: true,
          canApproveLeaves: true,
          canViewTeamAttendance: true,
          canViewReports: true,
          canGenerateReports: true,
          canViewAnalytics: true,
          canExportData: true,
          // No user management permissions for managers
          canCreateUsers: false,
          canManageUsers: false,
          canDeactivateUsers: false,
          canAssignRoles: false,
          canManageSignatures: true,
          canAddSignatures: true,
          canEditSignatures: true,
          canDeleteSignatures: true,
        );

      case UserRole.tl:
        // Team Leads get limited management permissions
        return SystemPermissionConfig(
          pagePermissions: defaultPagePermissions,
          canManageTasks: true,
          canCreateTasks: true,
          canDeleteTasks: true,
          canDeleteTaskDocuments: true,
          canAssignTasks: true,
          canViewTeamTasks: true,
          canCreateProjects: true,
          canViewReports: true,
          // No employee or user management permissions
          canAddEmployees: false,
          canCreateUsers: false,
          canManageUsers: false,
          canDeactivateUsers: false,
          canAssignRoles: false,
          canManageSignatures: true,
          canAddSignatures: true,
          canEditSignatures: true,
          canDeleteSignatures: true,
        );

      case UserRole.se:
      case UserRole.employee:
      case UserRole.contractor:
      case UserRole.intern:
      default:
        // Basic employees get minimal permissions
        return SystemPermissionConfig(
          pagePermissions: defaultPagePermissions,
          // No management permissions at all
          canAddEmployees: false,
          canCreateUsers: false,
          canManageUsers: false,
          canDeactivateUsers: false,
          canAssignRoles: false,
          canManageSignatures: true,
          canAddSignatures: true,
          canEditSignatures: true,
          canDeleteSignatures: true,
        );
    }
  }
}
