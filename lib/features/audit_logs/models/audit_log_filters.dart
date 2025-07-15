class AuditLogFilters {
  final String? action;
  final String? targetType;
  final String? status;
  final String? userId;
  final DateTime? startDate;
  final DateTime? endDate;

  const AuditLogFilters({
    this.action,
    this.targetType,
    this.status,
    this.userId,
    this.startDate,
    this.endDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuditLogFilters &&
          runtimeType == other.runtimeType &&
          action == other.action &&
          targetType == other.targetType &&
          status == other.status &&
          userId == other.userId &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode =>
      action.hashCode ^
      targetType.hashCode ^
      status.hashCode ^
      userId.hashCode ^
      startDate.hashCode ^
      endDate.hashCode;
}
