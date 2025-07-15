/// Firestore collection and document paths
class FirestorePaths {
  // Root Collections
  static const String users = 'users';
  static const String employees = 'employees';
  static const String tasks = 'tasks';
  static const String leaves = 'leaves';
  static const String documents = 'documents';
  static const String departments = 'departments';
  static const String projects = 'projects';
  static const String notifications = 'notifications';
  static const String auditLogs = 'auditLogs';
  static const String settings = 'settings';
  static const String setup = 'setup';
  static const String profileUpdateRequests = 'profileUpdateRequests';

  // Sub-collection names
  static const String profilesSubCollection = 'profiles';
  static const String sessionsSubCollection = 'sessions';
  static const String commentsSubCollection = 'comments';
  static const String attachmentsSubCollection = 'attachments';
  static const String approvalsSubCollection = 'approvals';
  static const String versionsSubCollection = 'versions';
  static const String performanceSubCollection = 'performance';
  static const String timeEntriesSubCollection = 'timeEntries';

  // System Documents
  static const String setupCompleted = 'setup/completed';
  static const String appSettings = 'settings/app';
  static const String companySettings = 'settings/company';

  // Helper methods for dynamic paths
  static String userDocument(String userId) => '$users/$userId';
  static String employeeDocument(String employeeId) => '$employees/$employeeId';
  static String taskDocument(String taskId) => '$tasks/$taskId';
  static String leaveDocument(String leaveId) => '$leaves/$leaveId';
  static String documentDocument(String documentId) => '$documents/$documentId';

  // Sub-collection paths
  static String userProfiles(String userId) =>
      '${userDocument(userId)}/$profilesSubCollection';
  static String userSessions(String userId) =>
      '${userDocument(userId)}/$sessionsSubCollection';
  static String taskComments(String taskId) =>
      '${taskDocument(taskId)}/$commentsSubCollection';
  static String taskAttachments(String taskId) =>
      '${taskDocument(taskId)}/$attachmentsSubCollection';
  static String leaveApprovals(String leaveId) =>
      '${leaveDocument(leaveId)}/$approvalsSubCollection';
  static String documentVersions(String documentId) =>
      '${documentDocument(documentId)}/$versionsSubCollection';
  static String employeePerformance(String employeeId) =>
      '${employeeDocument(employeeId)}/$performanceSubCollection';
  static String employeeTimeEntries(String employeeId) =>
      '${employeeDocument(employeeId)}/$timeEntriesSubCollection';

  // Audit log paths
  static String superAdminLogs(String userId) =>
      '$auditLogs/superAdmin/$userId';
  static String adminLogs(String userId) => '$auditLogs/admin/$userId';
  static String userActivityLogs(String userId) => '$auditLogs/users/$userId';
}
