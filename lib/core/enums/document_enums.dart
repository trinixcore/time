/// Document category enumeration for organizing documents
enum DocumentCategory {
  company(
    'company',
    'Company Documents',
    'Company-wide policies and documents',
  ),
  department(
    'department',
    'Department Documents',
    'Department-specific documents',
  ),
  employee('employee', 'Employee Documents', 'Individual employee documents'),
  project('project', 'Project Documents', 'Project-related documents'),
  shared('shared', 'Shared Documents', 'Shared resources and forms'),
  hr('hr', 'HR Documents', 'Human resources documents'),
  finance('finance', 'Finance Documents', 'Financial documents and reports'),
  legal('legal', 'Legal Documents', 'Legal contracts and agreements'),
  training(
    'training',
    'Training Materials',
    'Training and development resources',
  ),
  compliance(
    'compliance',
    'Compliance Documents',
    'Regulatory and compliance documents',
  );

  const DocumentCategory(this.value, this.displayName, this.description);

  final String value;
  final String displayName;
  final String description;

  static DocumentCategory fromString(String value) {
    return DocumentCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => DocumentCategory.shared,
    );
  }
}

/// Document access level enumeration
enum DocumentAccessLevel {
  public('public', 'Public', 'Accessible to all employees'),
  restricted('restricted', 'Restricted', 'Limited access based on roles'),
  confidential('confidential', 'Confidential', 'High-level access only'),
  private('private', 'Private', 'Owner and authorized personnel only');

  const DocumentAccessLevel(this.value, this.displayName, this.description);

  final String value;
  final String displayName;
  final String description;

  static DocumentAccessLevel fromString(String value) {
    return DocumentAccessLevel.values.firstWhere(
      (level) => level.value == value,
      orElse: () => DocumentAccessLevel.restricted,
    );
  }
}

/// File type enumeration for document classification
enum DocumentFileType {
  pdf('pdf', 'PDF Document', 'application/pdf'),
  doc('doc', 'Word Document', 'application/msword'),
  docx(
    'docx',
    'Word Document',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  ),
  pages('pages', 'Pages Document', 'application/x-iwork-pages-sffpages'),
  xls('xls', 'Excel Spreadsheet', 'application/vnd.ms-excel'),
  xlsx(
    'xlsx',
    'Excel Spreadsheet',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  ),
  numbers(
    'numbers',
    'Numbers Spreadsheet',
    'application/x-iwork-numbers-sffnumbers',
  ),
  ppt('ppt', 'PowerPoint Presentation', 'application/vnd.ms-powerpoint'),
  pptx(
    'pptx',
    'PowerPoint Presentation',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
  ),
  keynote(
    'keynote',
    'Keynote Presentation',
    'application/x-iwork-keynote-sffkey',
  ),
  txt('txt', 'Text File', 'text/plain'),
  csv('csv', 'CSV File', 'text/csv'),
  jpg('jpg', 'JPEG Image', 'image/jpeg'),
  jpeg('jpeg', 'JPEG Image', 'image/jpeg'),
  png('png', 'PNG Image', 'image/png'),
  gif('gif', 'GIF Image', 'image/gif'),
  zip('zip', 'ZIP Archive', 'application/zip'),
  rar('rar', 'RAR Archive', 'application/x-rar-compressed'),
  mp4('mp4', 'MP4 Video', 'video/mp4'),
  mp3('mp3', 'MP3 Audio', 'audio/mpeg'),
  other('other', 'Other', 'application/octet-stream');

  const DocumentFileType(this.extension, this.displayName, this.mimeType);

  final String extension;
  final String displayName;
  final String mimeType;

  static DocumentFileType fromExtension(String extension) {
    final cleanExt = extension.toLowerCase().replaceAll('.', '');
    return DocumentFileType.values.firstWhere(
      (type) => type.extension == cleanExt,
      orElse: () => DocumentFileType.other,
    );
  }

  static DocumentFileType fromMimeType(String mimeType) {
    return DocumentFileType.values.firstWhere(
      (type) => type.mimeType == mimeType,
      orElse: () => DocumentFileType.other,
    );
  }

  bool get isImage => [
    DocumentFileType.jpg,
    DocumentFileType.jpeg,
    DocumentFileType.png,
    DocumentFileType.gif,
  ].contains(this);

  bool get isDocument => [
    DocumentFileType.pdf,
    DocumentFileType.doc,
    DocumentFileType.docx,
    DocumentFileType.pages,
    DocumentFileType.txt,
  ].contains(this);

  bool get isSpreadsheet => [
    DocumentFileType.xls,
    DocumentFileType.xlsx,
    DocumentFileType.numbers,
    DocumentFileType.csv,
  ].contains(this);

  bool get isPresentation => [
    DocumentFileType.ppt,
    DocumentFileType.pptx,
    DocumentFileType.keynote,
  ].contains(this);

  bool get isArchive =>
      [DocumentFileType.zip, DocumentFileType.rar].contains(this);

  bool get isMedia =>
      [DocumentFileType.mp4, DocumentFileType.mp3].contains(this);
}

/// Document status enumeration
enum DocumentStatus {
  draft('draft', 'Draft', 'Document is in draft state'),
  pending('pending', 'Pending Review', 'Document is pending approval'),
  approved('approved', 'Approved', 'Document has been approved'),
  rejected('rejected', 'Rejected', 'Document has been rejected'),
  archived('archived', 'Archived', 'Document has been archived'),
  deleted('deleted', 'Deleted', 'Document has been deleted');

  const DocumentStatus(this.value, this.displayName, this.description);

  final String value;
  final String displayName;
  final String description;

  static DocumentStatus fromString(String value) {
    return DocumentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => DocumentStatus.draft,
    );
  }
}
