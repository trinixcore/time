import '../enums/document_enums.dart';

/// Constants for Team Lead role permissions
class TeamLeadPermissions {
  static const List<String> accessiblePaths = [
    'employees/{team_members}/*',
    'projects/{assigned_projects}/*',
    'shared/*',
    'training/*',
    'departments/{department}/team/*',
    'my-documents/*',
  ];

  static const List<DocumentCategory> accessibleCategories = [
    DocumentCategory.employee,
    DocumentCategory.project,
    DocumentCategory.shared,
    DocumentCategory.training,
    DocumentCategory.department,
  ];

  static const List<DocumentCategory> uploadableCategories = [
    DocumentCategory.project,
    DocumentCategory.shared,
    DocumentCategory.training,
    DocumentCategory.department,
  ];

  static const List<DocumentFileType> allowedFileTypes = [
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
  ];

  static const int maxFileSizeMB = 25;
  static const bool canCreateFolders = true;
  static const bool canUploadToEmployeeDocuments = true;
  static const bool canViewAsEmployee = true;
  static const bool canArchiveDocuments = false;
  static const bool canManagePermissions = false;
  static const bool canViewAll = false;
  static const bool canUploadToAll = false;
  static const bool canDeleteAny = false;
}

/// Constants for other roles can be added here...
