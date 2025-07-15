import '../enums/user_role.dart';
import '../enums/document_enums.dart';
import '../constants/role_permissions.dart';

/// Document permission matrix for role-based access control
class DocumentPermissions {
  /// Get document access permissions for a specific role
  static DocumentAccessMatrix getPermissionsForRole(UserRole role) {
    switch (role) {
      case UserRole.sa:
        return DocumentAccessMatrix(
          canViewAll: true,
          canUploadToAll: true,
          canDeleteAny: true,
          canManagePermissions: true,
          canCreateFolders: true,
          canArchiveDocuments: true,
          canUploadToEmployeeDocuments: true,
          canViewAsEmployee: true,
          accessibleCategories: DocumentCategory.values,
          accessiblePaths: ['*'],
          maxFileSizeMB: 1000,
          allowedFileTypes: DocumentFileType.values,
          uploadableCategories: DocumentCategory.values,
          deletableCategories: DocumentCategory.values,
        );

      case UserRole.admin:
        return DocumentAccessMatrix(
          canViewAll: true,
          canUploadToAll: true,
          canDeleteAny: true,
          canManagePermissions: true,
          canCreateFolders: true,
          canArchiveDocuments: true,
          canUploadToEmployeeDocuments: true,
          canViewAsEmployee: true,
          accessibleCategories: [
            DocumentCategory.company,
            DocumentCategory.employee,
            DocumentCategory.department,
            DocumentCategory.project,
            DocumentCategory.shared,
            DocumentCategory.hr,
            DocumentCategory.training,
          ],
          accessiblePaths: ['*'],
          maxFileSizeMB: 500,
          allowedFileTypes: DocumentFileType.values,
          uploadableCategories: DocumentCategory.values,
          deletableCategories: DocumentCategory.values,
        );

      case UserRole.hr:
        return DocumentAccessMatrix(
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
            DocumentCategory.hr,
            DocumentCategory.training,
          ],
          accessiblePaths: ['employees/*', 'hr/*', 'training/*'],
          maxFileSizeMB: 100,
          allowedFileTypes: DocumentFileType.values,
          uploadableCategories: [
            DocumentCategory.hr,
            DocumentCategory.training,
          ],
          deletableCategories: [DocumentCategory.hr],
        );

      case UserRole.manager:
        return const DocumentAccessMatrix(
          canViewAll: false,
          canUploadToAll: false,
          canDeleteAny: false,
          canManagePermissions: false,
          canCreateFolders: true,
          canArchiveDocuments: false,
          canUploadToEmployeeDocuments: false,
          canViewAsEmployee: false,
          accessibleCategories: [
            DocumentCategory.department,
            DocumentCategory.project,
            DocumentCategory.shared,
            DocumentCategory.training,
          ],
          accessiblePaths: [
            'departments/{department}/*',
            'projects/{assigned_projects}/*',
            'shared/*',
            'training/*',
          ],
          maxFileSizeMB: 20,
          allowedFileTypes: [
            DocumentFileType.pdf,
            DocumentFileType.doc,
            DocumentFileType.docx,
            DocumentFileType.pages,
            DocumentFileType.xls,
            DocumentFileType.xlsx,
            DocumentFileType.numbers,
            DocumentFileType.ppt,
            DocumentFileType.pptx,
            DocumentFileType.keynote,
            DocumentFileType.txt,
            DocumentFileType.csv,
            DocumentFileType.jpg,
            DocumentFileType.jpeg,
            DocumentFileType.png,
          ],
          uploadableCategories: [
            DocumentCategory.department,
            DocumentCategory.project,
            DocumentCategory.shared,
          ],
          deletableCategories: [
            DocumentCategory.department,
            DocumentCategory.project,
            DocumentCategory.shared,
          ], // Manager can delete from their managed categories
        );

      case UserRole.tl:
        return DocumentAccessMatrix(
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
        return const DocumentAccessMatrix(
          canViewAll: false,
          canUploadToAll: false,
          canDeleteAny: false,
          canManagePermissions: false,
          canCreateFolders: false,
          canArchiveDocuments: false,
          canUploadToEmployeeDocuments: false,
          canViewAsEmployee: false,
          accessibleCategories: [
            DocumentCategory.project,
            DocumentCategory.shared,
            DocumentCategory.training,
          ],
          accessiblePaths: [
            'projects/{assigned_projects}/*',
            'shared/*',
            'training/*',
            'employees/{employee_id}/*',
          ],
          maxFileSizeMB: 15,
          allowedFileTypes: [
            DocumentFileType.pdf,
            DocumentFileType.doc,
            DocumentFileType.docx,
            DocumentFileType.pages,
            DocumentFileType.xls,
            DocumentFileType.xlsx,
            DocumentFileType.numbers,
            DocumentFileType.ppt,
            DocumentFileType.pptx,
            DocumentFileType.keynote,
            DocumentFileType.txt,
            DocumentFileType.csv,
            DocumentFileType.jpg,
            DocumentFileType.jpeg,
            DocumentFileType.png,
          ],
          uploadableCategories: [
            DocumentCategory.project,
            DocumentCategory.shared,
            DocumentCategory.training,
          ],
          deletableCategories: [
            DocumentCategory.shared,
          ], // Senior employee can only delete from shared category
        );

      case UserRole.employee:
        return const DocumentAccessMatrix(
          canViewAll: false,
          canUploadToAll: false,
          canDeleteAny: false,
          canManagePermissions: false,
          canCreateFolders: false,
          canArchiveDocuments: false,
          canUploadToEmployeeDocuments: false,
          canViewAsEmployee: false,
          accessibleCategories: [
            DocumentCategory.shared,
            DocumentCategory.training,
          ],
          accessiblePaths: [
            'shared/*',
            'training/*',
            'employees/{employee_id}/*',
          ],
          maxFileSizeMB: 10,
          allowedFileTypes: [
            DocumentFileType.pdf,
            DocumentFileType.doc,
            DocumentFileType.docx,
            DocumentFileType.jpg,
            DocumentFileType.jpeg,
            DocumentFileType.png,
            DocumentFileType.txt,
          ],
          uploadableCategories: [DocumentCategory.shared],
          deletableCategories:
              [], // Regular employee cannot delete any documents
        );

      case UserRole.contractor:
        return DocumentAccessMatrix(
          canViewAll: false,
          canUploadToAll: false,
          canDeleteAny: false,
          canManagePermissions: false,
          canCreateFolders: false,
          canArchiveDocuments: false,
          canUploadToEmployeeDocuments: false,
          canViewAsEmployee: false,
          accessibleCategories: [
            DocumentCategory.project,
            DocumentCategory.shared,
          ],
          accessiblePaths: [
            'employees/{employee_id}/*',
            'projects/{assigned_projects}/*',
            'shared/contractors/*',
          ],
          maxFileSizeMB: 10,
          allowedFileTypes: [
            DocumentFileType.pdf,
            DocumentFileType.doc,
            DocumentFileType.docx,
            DocumentFileType.jpg,
            DocumentFileType.jpeg,
            DocumentFileType.png,
          ],
          uploadableCategories: [
            DocumentCategory.project,
            DocumentCategory.shared,
          ],
          deletableCategories: [],
        );

      case UserRole.intern:
        return const DocumentAccessMatrix(
          canViewAll: false,
          canUploadToAll: false,
          canDeleteAny: false,
          canManagePermissions: false,
          canCreateFolders: false,
          canArchiveDocuments: false,
          canUploadToEmployeeDocuments: false,
          canViewAsEmployee: false,
          accessibleCategories: [
            DocumentCategory.shared,
            DocumentCategory.training,
          ],
          accessiblePaths: [
            'employees/{employee_id}/*',
            'shared/interns/*',
            'training/*',
          ],
          maxFileSizeMB: 5,
          allowedFileTypes: [
            DocumentFileType.pdf,
            DocumentFileType.doc,
            DocumentFileType.docx,
            DocumentFileType.jpg,
            DocumentFileType.jpeg,
            DocumentFileType.png,
          ],
          uploadableCategories: [
            DocumentCategory.shared,
            DocumentCategory.training,
          ],
          deletableCategories: [], // Intern cannot delete any documents
        );

      case UserRole.vendor:
        return DocumentAccessMatrix(
          canViewAll: false,
          canUploadToAll: false,
          canDeleteAny: false,
          canManagePermissions: false,
          canCreateFolders: false,
          canArchiveDocuments: false,
          canUploadToEmployeeDocuments: false,
          canViewAsEmployee: false,
          accessibleCategories: [DocumentCategory.shared],
          accessiblePaths: ['shared/vendors/*'],
          maxFileSizeMB: 5,
          allowedFileTypes: [
            DocumentFileType.pdf,
            DocumentFileType.doc,
            DocumentFileType.docx,
          ],
          uploadableCategories: [DocumentCategory.shared],
          deletableCategories: [], // Vendor cannot delete any documents
        );

      case UserRole.inactive:
        return DocumentAccessMatrix(
          canViewAll: false,
          canUploadToAll: false,
          canDeleteAny: false,
          canManagePermissions: false,
          canCreateFolders: false,
          canArchiveDocuments: false,
          canUploadToEmployeeDocuments: false,
          canViewAsEmployee: false,
          accessibleCategories: [],
          accessiblePaths: [],
          maxFileSizeMB: 0,
          allowedFileTypes: [],
          uploadableCategories: [],
          deletableCategories: [], // Inactive user cannot delete any documents
        );
    }
  }

  /// Check if a role can access a specific document path
  static bool canAccessPath(
    UserRole role,
    String path, {
    String? employeeId,
    String? department,
    List<String>? assignedProjects,
    List<String>? teamMembers,
  }) {
    final permissions = getPermissionsForRole(role);

    // Super admin can access everything
    if (role == UserRole.sa) return true;

    // Check against accessible paths
    for (final allowedPath in permissions.accessiblePaths) {
      if (allowedPath == '*') return true;

      // Replace placeholders with actual values
      String resolvedPath = allowedPath
          .replaceAll('{employee_id}', employeeId ?? '')
          .replaceAll('{department}', department ?? '');

      // Handle team members
      if (allowedPath.contains('{team_members}') && teamMembers != null) {
        for (final member in teamMembers) {
          final memberPath = allowedPath.replaceAll('{team_members}', member);
          if (_pathMatches(path, memberPath)) return true;
        }
        continue;
      }

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
  }

  /// Check if a path matches a pattern (supports wildcards)
  static bool _pathMatches(String path, String pattern) {
    if (pattern.endsWith('/*')) {
      final prefix = pattern.substring(0, pattern.length - 2);
      return path.startsWith(prefix);
    }
    return path == pattern;
  }

  /// Get folder access permissions for a role
  static List<String> getAccessibleFolders(
    UserRole role, {
    String? employeeId,
    String? department,
    List<String>? assignedProjects,
  }) {
    final permissions = getPermissionsForRole(role);
    final folders = <String>[];

    for (final path in permissions.accessiblePaths) {
      String resolvedPath = path
          .replaceAll('{employee_id}', employeeId ?? '')
          .replaceAll('{department}', department ?? '');

      // Handle assigned projects
      if (path.contains('{assigned_projects}') && assignedProjects != null) {
        for (final project in assignedProjects) {
          final projectPath = path.replaceAll('{assigned_projects}', project);
          folders.add(projectPath);
        }
      } else {
        folders.add(resolvedPath);
      }
    }

    return folders;
  }
}

/// Document access matrix class
class DocumentAccessMatrix {
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
  final List<DocumentCategory> uploadableCategories;
  final List<DocumentCategory> deletableCategories;

  const DocumentAccessMatrix({
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
  });

  /// Check if a file type is allowed
  bool isFileTypeAllowed(DocumentFileType fileType) {
    return allowedFileTypes.contains(fileType);
  }

  /// Check if file size is within limits
  bool isFileSizeAllowed(int fileSizeBytes) {
    final fileSizeMB = fileSizeBytes / (1024 * 1024);
    return fileSizeMB <= maxFileSizeMB;
  }

  /// Check if a category is accessible
  bool isCategoryAccessible(DocumentCategory category) {
    return accessibleCategories.contains(category);
  }

  /// Check if user can upload to a specific category
  bool canUploadToCategory(DocumentCategory category) {
    // If user has global upload permission, they can upload to any accessible category
    if (canUploadToAll) {
      return accessibleCategories.contains(category);
    }

    // Otherwise, check if the specific category is in the uploadable categories
    return uploadableCategories.contains(category);
  }

  /// Check if user can delete from a specific category
  bool canDeleteFromCategory(DocumentCategory category) {
    // If user has global delete permission, they can delete from any accessible category
    if (canDeleteAny) {
      return accessibleCategories.contains(category);
    }

    // Otherwise, check if the specific category is in the deletable categories
    return deletableCategories.contains(category);
  }
}
