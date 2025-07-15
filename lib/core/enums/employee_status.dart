/// Employee status enumeration
enum EmployeeStatus {
  active('active', 'Active'),
  inactive('inactive', 'Inactive'),
  onLeave('on_leave', 'On Leave'),
  suspended('suspended', 'Suspended'),
  terminated('terminated', 'Terminated'),
  probation('probation', 'Probation'),
  notice('notice', 'Notice Period');

  const EmployeeStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  /// Create EmployeeStatus from string value
  static EmployeeStatus fromString(String value) {
    return EmployeeStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => throw ArgumentError('Invalid employee status: $value'),
    );
  }

  // Convenience getters
  bool get isActive => this == EmployeeStatus.active;
  bool get isInactive => this == EmployeeStatus.inactive;
  bool get isOnLeave => this == EmployeeStatus.onLeave;
  bool get isSuspended => this == EmployeeStatus.suspended;
  bool get isTerminated => this == EmployeeStatus.terminated;
  bool get isOnProbation => this == EmployeeStatus.probation;
  bool get isOnNotice => this == EmployeeStatus.notice;

  // Status checks
  bool get canWork =>
      this == EmployeeStatus.active || this == EmployeeStatus.probation;
  bool get canTakeLeave =>
      this == EmployeeStatus.active || this == EmployeeStatus.probation;
  bool get canAccessSystem => canWork;
  bool get isEmployed => this != EmployeeStatus.terminated;
}
