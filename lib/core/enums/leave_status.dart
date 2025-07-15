/// Leave status enumeration
enum LeaveStatus {
  pending('pending', 'Pending'),
  approved('approved', 'Approved'),
  rejected('rejected', 'Rejected'),
  cancelled('cancelled', 'Cancelled');

  const LeaveStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  /// Create LeaveStatus from string value
  static LeaveStatus fromString(String value) {
    return LeaveStatus.values.firstWhere(
      (status) => status.value == value.toLowerCase(),
      orElse: () => LeaveStatus.pending,
    );
  }

  /// Check if status is pending
  bool get isPending => this == LeaveStatus.pending;

  /// Check if status is approved
  bool get isApproved => this == LeaveStatus.approved;

  /// Check if status is rejected
  bool get isRejected => this == LeaveStatus.rejected;

  /// Check if status is cancelled
  bool get isCancelled => this == LeaveStatus.cancelled;

  /// Check if leave can be cancelled
  bool get canBeCancelled => isPending || isApproved;

  /// Check if leave can be modified
  bool get canBeModified => isPending;

  /// Check if status is final (cannot be changed)
  bool get isFinal => isRejected || isCancelled;

  /// Check if status allows approval actions
  bool get allowsApprovalActions => isPending;

  /// Get status color for UI
  String get colorCode {
    switch (this) {
      case LeaveStatus.pending:
        return '#FFA500'; // Orange
      case LeaveStatus.approved:
        return '#4CAF50'; // Green
      case LeaveStatus.rejected:
        return '#F44336'; // Red
      case LeaveStatus.cancelled:
        return '#9E9E9E'; // Grey
    }
  }

  /// Get status icon for UI
  String get iconName {
    switch (this) {
      case LeaveStatus.pending:
        return 'schedule';
      case LeaveStatus.approved:
        return 'check_circle';
      case LeaveStatus.rejected:
        return 'cancel';
      case LeaveStatus.cancelled:
        return 'block';
    }
  }

  @override
  String toString() => displayName;
}
