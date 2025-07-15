/// User role enumeration with hierarchical levels and comprehensive permissions
enum UserRole {
  sa('sa', 'Super Admin', 100),
  admin('admin', 'Admin', 80),
  hr('hr', 'HR', 70),
  manager('mgr', 'Manager', 60),
  tl('tl', 'Team Lead', 55),
  se('se', 'Senior Employee', 50),
  employee('emp', 'Employee', 40),
  contractor('con', 'Contractor', 35),
  intern('int', 'Intern', 30),
  vendor('ven', 'Vendor', 25),
  inactive('ina', 'Inactive', 0);

  const UserRole(this.value, this.displayName, this.level);

  final String value;
  final String displayName;
  final int level;

  /// Create UserRole from string value
  static UserRole fromString(String value) {
    // Handle both formats: "UserRole.emp" and "emp"
    String cleanValue = value;
    if (value.startsWith('UserRole.')) {
      cleanValue = value.substring('UserRole.'.length);
    }

    // Try to match by value or name
    try {
      return UserRole.values.firstWhere(
        (role) => role.value == cleanValue || role.name == cleanValue,
      );
    } catch (e) {
      // If not found, return default employee role
      return UserRole.employee;
    }
  }

  /// Check if this role has higher or equal level than another role
  bool hasLevelOrAbove(UserRole other) => level >= other.level;

  /// Check if this role has lower level than another role
  bool hasLevelBelow(UserRole other) => level < other.level;

  /// Get all roles with level equal or below this role
  List<UserRole> getRolesAtOrBelow() {
    return UserRole.values.where((role) => role.level <= level).toList();
  }

  /// Get all roles with level above this role
  List<UserRole> getRolesAbove() {
    return UserRole.values.where((role) => role.level > level).toList();
  }

  /// Get all manageable roles (roles that this role can assign/manage)
  List<UserRole> getManageableRoles() {
    switch (this) {
      case UserRole.sa:
        return UserRole.values.where((role) => role != UserRole.sa).toList();
      case UserRole.admin:
        return UserRole.values
            .where((role) => role.level < UserRole.admin.level)
            .toList();
      case UserRole.hr:
        return UserRole.values
            .where(
              (role) =>
                  role.level <= UserRole.manager.level &&
                  role != UserRole.admin,
            )
            .toList();
      default:
        return [];
    }
  }

  // Convenience getters for role identification
  bool get isSuperAdmin => this == UserRole.sa;
  bool get isAdmin => this == UserRole.admin;
  bool get isHR => this == UserRole.hr;
  bool get isManager => this == UserRole.manager;
  bool get isTeamLead => this == UserRole.tl;
  bool get isSeniorEmployee => this == UserRole.se;
  bool get isEmployee => this == UserRole.employee;
  bool get isContractor => this == UserRole.contractor;
  bool get isIntern => this == UserRole.intern;
  bool get isVendor => this == UserRole.vendor;
  bool get isInactive => this == UserRole.inactive;

  // Management level checks
  bool get isManagementLevel => level >= UserRole.manager.level;
  bool get isLeadershipLevel => level >= UserRole.tl.level;
  bool get isStaffLevel =>
      level >= UserRole.employee.level && level < UserRole.tl.level;
  bool get isExternalRole =>
      this == UserRole.contractor || this == UserRole.vendor;
  bool get isTemporaryRole =>
      this == UserRole.intern || this == UserRole.contractor;

  // Core System Permissions
  bool get canManageSystem => level >= UserRole.sa.level;
  bool get canAccessAdminPanel => level >= UserRole.admin.level;
  bool get canDelegateRoles => level >= UserRole.sa.level;
  bool get canManageCompanySettings => level >= UserRole.admin.level;

  // User Management Permissions
  bool get canManageUsers => level >= UserRole.admin.level;
  bool get canCreateUsers => level >= UserRole.hr.level;
  bool get canDeactivateUsers => level >= UserRole.admin.level;
  bool get canViewAllUsers => level >= UserRole.hr.level;
  bool get canAssignRoles => level >= UserRole.admin.level;

  // Employee Management Permissions
  bool get canManageEmployees => level >= UserRole.hr.level;
  bool get canViewEmployeeDetails => level >= UserRole.manager.level;
  bool get canEditEmployeeProfiles => level >= UserRole.hr.level;
  bool get canManageEmployeeDocuments => level >= UserRole.hr.level;
  bool get canConductPerformanceReviews => level >= UserRole.manager.level;

  // Task & Project Management Permissions
  bool get canManageTasks => level >= UserRole.tl.level;
  bool get canAssignTasks => level >= UserRole.tl.level;
  bool get canViewTeamTasks => level >= UserRole.tl.level;
  bool get canCreateProjects => level >= UserRole.manager.level;
  bool get canManageProjects => level >= UserRole.manager.level;

  // Reporting & Analytics Permissions
  bool get canViewReports => level >= UserRole.manager.level;
  bool get canGenerateReports => level >= UserRole.manager.level;
  bool get canViewAnalytics => level >= UserRole.manager.level;
  bool get canExportData => level >= UserRole.manager.level;

  // Leave & Attendance Permissions
  bool get canApproveLeaves => level >= UserRole.tl.level;
  bool get canViewTeamAttendance => level >= UserRole.tl.level;
  bool get canManageAttendancePolicy => level >= UserRole.hr.level;
  bool get canOverrideAttendance => level >= UserRole.manager.level;

  // Document Management Permissions
  bool get canManageDocuments => level >= UserRole.hr.level;
  bool get canUploadDocuments =>
      level >= UserRole.employee.level && !isExternalRole;
  bool get canViewCompanyDocuments => level >= UserRole.employee.level;
  bool get canApproveDocuments => level >= UserRole.manager.level;

  // Financial & Payroll Permissions
  bool get canViewSalaryInfo => level >= UserRole.hr.level;
  bool get canManagePayroll => level >= UserRole.hr.level;
  bool get canApproveBudgets => level >= UserRole.manager.level;
  bool get canViewFinancialReports => level >= UserRole.admin.level;

  // Training & Development Permissions
  bool get canManageTraining => level >= UserRole.hr.level;
  bool get canAssignTraining => level >= UserRole.manager.level;
  bool get canViewTrainingReports => level >= UserRole.manager.level;
  bool get canCreateTrainingContent => level >= UserRole.hr.level;

  // Communication & Collaboration Permissions
  bool get canSendCompanyAnnouncements => level >= UserRole.hr.level;
  bool get canModerateDiscussions => level >= UserRole.tl.level;
  bool get canAccessAllChannels => level >= UserRole.manager.level;

  // Security & Compliance Permissions
  bool get canViewAuditLogs => level >= UserRole.admin.level;
  bool get canManageSecuritySettings => level >= UserRole.sa.level;
  bool get canAccessComplianceReports => level >= UserRole.hr.level;

  // Special Access Permissions
  bool get canWorkRemotely =>
      level >= UserRole.employee.level && !isExternalRole;
  bool get canAccessAfterHours => level >= UserRole.se.level;
  bool get canBypassApprovals => level >= UserRole.admin.level;
  bool get hasLimitedAccess => isExternalRole || isTemporaryRole;

  /// Get role-specific dashboard widgets
  List<String> getDashboardWidgets() {
    switch (this) {
      case UserRole.sa:
        return [
          'system_health',
          'user_analytics',
          'security_alerts',
          'company_metrics',
          'admin_actions',
          'audit_logs',
        ];
      case UserRole.admin:
        return [
          'user_management',
          'system_reports',
          'company_metrics',
          'admin_actions',
          'security_overview',
        ];
      case UserRole.hr:
        return [
          'employee_overview',
          'leave_requests',
          'recruitment_pipeline',
          'training_progress',
          'compliance_status',
        ];
      case UserRole.manager:
        return [
          'team_performance',
          'project_status',
          'leave_approvals',
          'team_analytics',
          'budget_overview',
        ];
      case UserRole.tl:
        return [
          'team_tasks',
          'team_attendance',
          'performance_metrics',
          'leave_calendar',
        ];
      case UserRole.se:
        return [
          'my_projects',
          'team_updates',
          'skill_development',
          'mentoring_tasks',
        ];
      case UserRole.employee:
        return [
          'my_tasks',
          'attendance_summary',
          'leave_balance',
          'announcements',
        ];
      case UserRole.contractor:
        return ['assigned_projects', 'timesheet', 'contract_details'];
      case UserRole.intern:
        return [
          'learning_path',
          'assigned_tasks',
          'mentor_feedback',
          'training_schedule',
        ];
      case UserRole.vendor:
        return ['service_requests', 'contract_status', 'payment_schedule'];
      case UserRole.inactive:
        return [];
    }
  }

  /// Get role-specific navigation items
  List<String> getNavigationItems() {
    List<String> items = ['dashboard', 'profile'];

    if (canViewTeamTasks) items.add('tasks');
    if (canManageEmployees) items.add('employees');
    if (canManageDocuments) items.add('documents');
    if (canViewReports) items.add('reports');
    if (canApproveLeaves) items.add('leaves');
    if (canManageTraining) items.add('training');
    if (canManageUsers) items.add('user_management');
    if (canAccessAdminPanel) items.add('admin');
    if (canManageSystem) items.add('system_settings');

    // Role-specific items
    if (isHR) items.addAll(['recruitment', 'payroll', 'compliance']);
    if (isManager || isTeamLead) items.add('team_management');
    if (isContractor || isVendor) items.add('contracts');
    if (isIntern) items.add('learning');

    return items;
  }

  /// Get role color for UI representation
  String getRoleColor() {
    switch (this) {
      case UserRole.sa:
        return '#FF0000'; // Red
      case UserRole.admin:
        return '#FF6600'; // Orange
      case UserRole.hr:
        return '#9900CC'; // Purple
      case UserRole.manager:
        return '#0066CC'; // Blue
      case UserRole.tl:
        return '#0099CC'; // Light Blue
      case UserRole.se:
        return '#00CC66'; // Green
      case UserRole.employee:
        return '#66CC00'; // Light Green
      case UserRole.contractor:
        return '#CCCC00'; // Yellow
      case UserRole.intern:
        return '#CC6600'; // Brown
      case UserRole.vendor:
        return '#CC0066'; // Pink
      case UserRole.inactive:
        return '#999999'; // Gray
    }
  }

  /// Get role icon for UI representation
  String getRoleIcon() {
    switch (this) {
      case UserRole.sa:
        return 'admin_panel_settings';
      case UserRole.admin:
        return 'settings';
      case UserRole.hr:
        return 'people';
      case UserRole.manager:
        return 'supervisor_account';
      case UserRole.tl:
        return 'group';
      case UserRole.se:
        return 'star';
      case UserRole.employee:
        return 'person';
      case UserRole.contractor:
        return 'work';
      case UserRole.intern:
        return 'school';
      case UserRole.vendor:
        return 'business';
      case UserRole.inactive:
        return 'block';
    }
  }
}
