enum ProjectStatus {
  planning('planning', 'Planning'),
  active('active', 'Active'),
  onHold('on_hold', 'On Hold'),
  completed('completed', 'Completed'),
  cancelled('cancelled', 'Cancelled');

  const ProjectStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  /// Create ProjectStatus from string value
  static ProjectStatus fromString(String value) {
    return ProjectStatus.values.firstWhere(
      (status) => status.value == value.toLowerCase(),
      orElse: () => ProjectStatus.planning,
    );
  }

  /// Check if status is planning
  bool get isPlanning => this == ProjectStatus.planning;

  /// Check if status is active
  bool get isActive => this == ProjectStatus.active;

  /// Check if status is on hold
  bool get isOnHold => this == ProjectStatus.onHold;

  /// Check if status is completed
  bool get isCompleted => this == ProjectStatus.completed;

  /// Check if status is cancelled
  bool get isCancelled => this == ProjectStatus.cancelled;

  /// Check if project is in progress (active or planning)
  bool get isInProgress => isPlanning || isActive;

  /// Check if project is finished (completed or cancelled)
  bool get isFinished => isCompleted || isCancelled;

  /// Check if status allows modifications
  bool get allowsModifications => isPlanning || isActive || isOnHold;

  /// Check if status allows task creation
  bool get allowsTaskCreation => isPlanning || isActive;

  /// Get status color for UI
  String get colorCode {
    switch (this) {
      case ProjectStatus.planning:
        return '#2196F3'; // Blue
      case ProjectStatus.active:
        return '#4CAF50'; // Green
      case ProjectStatus.onHold:
        return '#FF9800'; // Orange
      case ProjectStatus.completed:
        return '#8BC34A'; // Light Green
      case ProjectStatus.cancelled:
        return '#F44336'; // Red
    }
  }

  /// Get status icon for UI
  String get iconName {
    switch (this) {
      case ProjectStatus.planning:
        return 'design_services';
      case ProjectStatus.active:
        return 'play_circle';
      case ProjectStatus.onHold:
        return 'pause_circle';
      case ProjectStatus.completed:
        return 'check_circle';
      case ProjectStatus.cancelled:
        return 'cancel';
    }
  }

  @override
  String toString() => displayName;
}
