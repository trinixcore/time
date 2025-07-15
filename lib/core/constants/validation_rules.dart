/// Validation rules and constants
class ValidationRules {
  // Password Rules
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const String passwordPattern =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';

  // Name Rules
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const String namePattern = r'^[a-zA-Z\s\-\.]+$';

  // Email Rules
  static const int maxEmailLength = 254;
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  // Phone Rules
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;
  static const String phonePattern = r'^\+?[1-9]\d{1,14}$';

  // Employee ID Rules
  static const int minEmployeeIdLength = 3;
  static const int maxEmployeeIdLength = 20;
  static const String employeeIdPattern = r'^[A-Z0-9\-]+$';

  // Task Rules
  static const int minTaskTitleLength = 3;
  static const int maxTaskTitleLength = 100;
  static const int maxTaskDescriptionLength = 1000;

  // Leave Rules
  static const int minLeaveReasonLength = 10;
  static const int maxLeaveReasonLength = 500;
  static const int maxLeaveDays = 365;

  // Document Rules
  static const int maxDocumentNameLength = 100;
  static const int maxDocumentDescriptionLength = 500;
  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
  ];
  static const List<String> allowedDocumentExtensions = [
    'pdf',
    'doc',
    'docx',
    'txt',
    'rtf',
  ];
  static const List<String> allowedSpreadsheetExtensions = [
    'xls',
    'xlsx',
    'csv',
  ];

  // Department Rules
  static const int minDepartmentNameLength = 2;
  static const int maxDepartmentNameLength = 50;

  // Project Rules
  static const int minProjectNameLength = 3;
  static const int maxProjectNameLength = 100;
  static const int maxProjectDescriptionLength = 1000;

  // Comment Rules
  static const int minCommentLength = 1;
  static const int maxCommentLength = 500;

  // Search Rules
  static const int minSearchQueryLength = 2;
  static const int maxSearchQueryLength = 100;

  // Pagination Rules
  static const int minPageSize = 5;
  static const int maxPageSize = 100;
  static const int defaultPageSize = 20;

  // Time Entry Rules
  static const int minTimeEntryMinutes = 15; // 15 minutes minimum
  static const int maxTimeEntryHours = 24; // 24 hours maximum per entry

  // Validation Messages
  static const String requiredFieldMessage = 'This field is required';
  static const String invalidEmailMessage =
      'Please enter a valid email address';
  static const String weakPasswordMessage =
      'Password must contain at least 8 characters with uppercase, lowercase, number and special character';
  static const String invalidPhoneMessage = 'Please enter a valid phone number';
  static const String invalidNameMessage =
      'Name can only contain letters, spaces, hyphens, dots and apostrophes';
  static const String fileTooLargeMessage = 'File size must be less than 10MB';
  static const String invalidFileTypeMessage = 'File type not supported';
}
