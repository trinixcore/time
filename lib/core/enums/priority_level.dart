/// Priority level enumeration
enum PriorityLevel {
  low('low', 'Low', 1, 'green'),
  medium('medium', 'Medium', 2, 'yellow'),
  high('high', 'High', 3, 'orange'),
  urgent('urgent', 'Urgent', 4, 'red'),
  critical('critical', 'Critical', 5, 'darkred');

  const PriorityLevel(this.value, this.displayName, this.level, this.color);

  final String value;
  final String displayName;
  final int level;
  final String color;

  /// Create PriorityLevel from string value
  static PriorityLevel fromString(String value) {
    return PriorityLevel.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => throw ArgumentError('Invalid priority level: $value'),
    );
  }

  /// Create PriorityLevel from numeric level
  static PriorityLevel fromLevel(int level) {
    return PriorityLevel.values.firstWhere(
      (priority) => priority.level == level,
      orElse: () => throw ArgumentError('Invalid priority level: $level'),
    );
  }

  /// Check if this priority is higher than another
  bool isHigherThan(PriorityLevel other) => level > other.level;

  /// Check if this priority is lower than another
  bool isLowerThan(PriorityLevel other) => level < other.level;

  /// Check if this priority is equal or higher than another
  bool isEqualOrHigherThan(PriorityLevel other) => level >= other.level;

  // Convenience getters
  bool get isLow => this == PriorityLevel.low;
  bool get isMedium => this == PriorityLevel.medium;
  bool get isHigh => this == PriorityLevel.high;
  bool get isUrgent => this == PriorityLevel.urgent;
  bool get isCritical => this == PriorityLevel.critical;

  // Priority checks
  bool get requiresImmediateAttention => level >= PriorityLevel.urgent.level;
  bool get canBeDelayed => level <= PriorityLevel.medium.level;
  bool get needsEscalation => level >= PriorityLevel.high.level;
  bool get isHighPriority => level >= PriorityLevel.high.level;
  bool get isLowPriority => level <= PriorityLevel.medium.level;

  // Get all priorities at or above this level
  List<PriorityLevel> getPrioritiesAtOrAbove() {
    return PriorityLevel.values
        .where((priority) => priority.level >= level)
        .toList();
  }

  // Get all priorities below this level
  List<PriorityLevel> getPrioritiesBelow() {
    return PriorityLevel.values
        .where((priority) => priority.level < level)
        .toList();
  }

  // Get escalation timeline in hours
  int get escalationTimelineHours {
    switch (this) {
      case PriorityLevel.critical:
        return 1;
      case PriorityLevel.urgent:
        return 4;
      case PriorityLevel.high:
        return 24;
      case PriorityLevel.medium:
        return 72;
      case PriorityLevel.low:
        return 168; // 1 week
    }
  }
}
