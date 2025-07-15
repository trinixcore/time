/// Task status enumeration
enum TaskStatus {
  todo('todo', 'To Do'),
  inProgress('in_progress', 'In Progress'),
  review('review', 'Under Review'),
  testing('testing', 'Testing'),
  completed('completed', 'Completed'),
  cancelled('cancelled', 'Cancelled'),
  onHold('on_hold', 'On Hold'),
  blocked('blocked', 'Blocked');

  const TaskStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  /// Create TaskStatus from string value
  static TaskStatus fromString(String value) {
    return TaskStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => throw ArgumentError('Invalid task status: $value'),
    );
  }

  // Convenience getters
  bool get isTodo => this == TaskStatus.todo;
  bool get isInProgress => this == TaskStatus.inProgress;
  bool get isUnderReview => this == TaskStatus.review;
  bool get isTesting => this == TaskStatus.testing;
  bool get isCompleted => this == TaskStatus.completed;
  bool get isCancelled => this == TaskStatus.cancelled;
  bool get isOnHold => this == TaskStatus.onHold;
  bool get isBlocked => this == TaskStatus.blocked;

  // Status checks
  bool get isActive => this == TaskStatus.todo || this == TaskStatus.inProgress;
  bool get isFinished =>
      this == TaskStatus.completed || this == TaskStatus.cancelled;
  bool get canBeWorkedOn =>
      this == TaskStatus.todo ||
      this == TaskStatus.inProgress ||
      this == TaskStatus.review;
  bool get requiresAttention =>
      this == TaskStatus.blocked || this == TaskStatus.onHold;
  bool get isInWorkflow => !isFinished && !requiresAttention;

  // Get next possible statuses
  List<TaskStatus> getNextPossibleStatuses() {
    switch (this) {
      case TaskStatus.todo:
        return [TaskStatus.inProgress, TaskStatus.onHold, TaskStatus.cancelled];
      case TaskStatus.inProgress:
        return [
          TaskStatus.review,
          TaskStatus.testing,
          TaskStatus.completed,
          TaskStatus.onHold,
          TaskStatus.blocked,
          TaskStatus.cancelled,
        ];
      case TaskStatus.review:
        return [
          TaskStatus.inProgress,
          TaskStatus.testing,
          TaskStatus.completed,
          TaskStatus.cancelled,
        ];
      case TaskStatus.testing:
        return [
          TaskStatus.inProgress,
          TaskStatus.completed,
          TaskStatus.cancelled,
        ];
      case TaskStatus.onHold:
        return [TaskStatus.todo, TaskStatus.inProgress, TaskStatus.cancelled];
      case TaskStatus.blocked:
        return [TaskStatus.todo, TaskStatus.inProgress, TaskStatus.cancelled];
      case TaskStatus.completed:
      case TaskStatus.cancelled:
        return [];
    }
  }
}
