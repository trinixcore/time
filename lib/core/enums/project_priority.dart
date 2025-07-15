enum ProjectPriority {
  low('low', 'Low'),
  medium('medium', 'Medium'),
  high('high', 'High'),
  critical('critical', 'Critical');

  const ProjectPriority(this.value, this.displayName);

  final String value;
  final String displayName;

  /// Create ProjectPriority from string value
  static ProjectPriority fromString(String value) {
    return ProjectPriority.values.firstWhere(
      (priority) => priority.value == value.toLowerCase(),
      orElse: () => ProjectPriority.medium,
    );
  }

  /// Check if priority is low
  bool get isLow => this == ProjectPriority.low;

  /// Check if priority is medium
  bool get isMedium => this == ProjectPriority.medium;

  /// Check if priority is high
  bool get isHigh => this == ProjectPriority.high;

  /// Check if priority is critical
  bool get isCritical => this == ProjectPriority.critical;

  /// Check if priority is high or critical
  bool get isHighPriority => isHigh || isCritical;

  /// Get priority level as integer (1-4)
  int get level {
    switch (this) {
      case ProjectPriority.low:
        return 1;
      case ProjectPriority.medium:
        return 2;
      case ProjectPriority.high:
        return 3;
      case ProjectPriority.critical:
        return 4;
    }
  }

  /// Get priority color for UI
  String get colorCode {
    switch (this) {
      case ProjectPriority.low:
        return '#4CAF50'; // Green
      case ProjectPriority.medium:
        return '#FF9800'; // Orange
      case ProjectPriority.high:
        return '#FF5722'; // Deep Orange
      case ProjectPriority.critical:
        return '#F44336'; // Red
    }
  }

  /// Get priority icon for UI
  String get iconName {
    switch (this) {
      case ProjectPriority.low:
        return 'keyboard_arrow_down';
      case ProjectPriority.medium:
        return 'remove';
      case ProjectPriority.high:
        return 'keyboard_arrow_up';
      case ProjectPriority.critical:
        return 'priority_high';
    }
  }

  /// Compare priorities (for sorting)
  int compareTo(ProjectPriority other) => level.compareTo(other.level);

  @override
  String toString() => displayName;
}
