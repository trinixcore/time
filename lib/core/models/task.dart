import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/task_status.dart';
import '../enums/priority_level.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
class Task with _$Task {
  const factory Task({
    required String id,
    required String title,
    required String description,
    required TaskStatus status,
    required PriorityLevel priority,
    required String assignedToId,
    required String createdById,
    String? projectId,
    String? parentTaskId,
    DateTime? startDate,
    DateTime? dueDate,
    DateTime? completedAt,
    @Default(0.0) double estimatedHours,
    @Default(0.0) double actualHours,
    @Default(0) int progressPercentage,
    @Default([]) List<String> tags,
    @Default([]) List<String> attachments,
    @Default([]) List<String> subtaskIds,
    @Default([]) List<String> dependencyIds,
    required DateTime createdAt,
    required DateTime updatedAt,
    Map<String, dynamic>? metadata,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  // Additional methods and getters
  const Task._();

  /// Check if task is overdue
  bool get isOverdue {
    if (dueDate == null || status.isFinished) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /// Check if task is due soon (within 24 hours)
  bool get isDueSoon {
    if (dueDate == null || status.isFinished) return false;
    final now = DateTime.now();
    final timeDiff = dueDate!.difference(now);
    return timeDiff.inHours <= 24 && timeDiff.inHours > 0;
  }

  /// Get days until due date
  int? get daysUntilDue {
    if (dueDate == null) return null;
    return dueDate!.difference(DateTime.now()).inDays;
  }

  /// Get hours until due date
  int? get hoursUntilDue {
    if (dueDate == null) return null;
    return dueDate!.difference(DateTime.now()).inHours;
  }

  /// Get task duration in days
  int? get durationInDays {
    if (startDate == null || dueDate == null) return null;
    return dueDate!.difference(startDate!).inDays;
  }

  /// Get time spent on task
  Duration get timeSpent {
    return Duration(hours: actualHours.round());
  }

  /// Get estimated time remaining
  Duration get estimatedTimeRemaining {
    final remaining = estimatedHours - actualHours;
    return Duration(hours: remaining > 0 ? remaining.round() : 0);
  }

  /// Check if task is behind schedule
  bool get isBehindSchedule {
    if (estimatedHours == 0) return false;
    return actualHours > estimatedHours;
  }

  /// Get completion ratio (actual vs estimated hours)
  double get completionRatio {
    if (estimatedHours == 0) return 0.0;
    return (actualHours / estimatedHours).clamp(0.0, 2.0);
  }

  /// Check if task has subtasks
  bool get hasSubtasks => subtaskIds.isNotEmpty;

  /// Check if task has dependencies
  bool get hasDependencies => dependencyIds.isNotEmpty;

  /// Check if task has attachments
  bool get hasAttachments => attachments.isNotEmpty;

  /// Check if task is high priority
  bool get isHighPriority => priority.isHighPriority;

  /// Check if task requires immediate attention
  bool get requiresImmediateAttention => priority.requiresImmediateAttention;

  /// Get task age in days
  int get ageInDays => DateTime.now().difference(createdAt).inDays;

  /// Check if task is stale (not updated in 7 days)
  bool get isStale => DateTime.now().difference(updatedAt).inDays > 7;

  /// Create a copy with updated status
  Task updateStatus(TaskStatus newStatus) {
    final now = DateTime.now();
    return copyWith(
      status: newStatus,
      completedAt: newStatus.isCompleted ? now : null,
      progressPercentage: newStatus.isCompleted ? 100 : progressPercentage,
      updatedAt: now,
    );
  }

  /// Create a copy with updated progress
  Task updateProgress(int percentage) {
    final clampedPercentage = percentage.clamp(0, 100);
    final now = DateTime.now();

    return copyWith(
      progressPercentage: clampedPercentage,
      status: clampedPercentage == 100 ? TaskStatus.completed : status,
      completedAt: clampedPercentage == 100 ? now : completedAt,
      updatedAt: now,
    );
  }

  /// Create a copy with updated priority
  Task updatePriority(PriorityLevel newPriority) {
    return copyWith(priority: newPriority, updatedAt: DateTime.now());
  }

  /// Create a copy with updated time tracking
  Task updateTimeTracking({double? estimatedHours, double? actualHours}) {
    return copyWith(
      estimatedHours: estimatedHours ?? this.estimatedHours,
      actualHours: actualHours ?? this.actualHours,
      updatedAt: DateTime.now(),
    );
  }

  /// Add time to actual hours
  Task addTimeSpent(double hours) {
    return copyWith(
      actualHours: actualHours + hours,
      updatedAt: DateTime.now(),
    );
  }

  /// Create a copy with updated dates
  Task updateDates({DateTime? startDate, DateTime? dueDate}) {
    return copyWith(
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      updatedAt: DateTime.now(),
    );
  }

  /// Add tag to task
  Task addTag(String tag) {
    if (tags.contains(tag)) return this;
    return copyWith(tags: [...tags, tag], updatedAt: DateTime.now());
  }

  /// Remove tag from task
  Task removeTag(String tag) {
    return copyWith(
      tags: tags.where((t) => t != tag).toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// Add attachment to task
  Task addAttachment(String attachment) {
    if (attachments.contains(attachment)) return this;
    return copyWith(
      attachments: [...attachments, attachment],
      updatedAt: DateTime.now(),
    );
  }

  /// Remove attachment from task
  Task removeAttachment(String attachment) {
    return copyWith(
      attachments: attachments.where((a) => a != attachment).toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// Add subtask ID
  Task addSubtask(String subtaskId) {
    if (subtaskIds.contains(subtaskId)) return this;
    return copyWith(
      subtaskIds: [...subtaskIds, subtaskId],
      updatedAt: DateTime.now(),
    );
  }

  /// Remove subtask ID
  Task removeSubtask(String subtaskId) {
    return copyWith(
      subtaskIds: subtaskIds.where((id) => id != subtaskId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// Add dependency ID
  Task addDependency(String dependencyId) {
    if (dependencyIds.contains(dependencyId)) return this;
    return copyWith(
      dependencyIds: [...dependencyIds, dependencyId],
      updatedAt: DateTime.now(),
    );
  }

  /// Remove dependency ID
  Task removeDependency(String dependencyId) {
    return copyWith(
      dependencyIds: dependencyIds.where((id) => id != dependencyId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// Convert to map for Firestore
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    // Convert enums to strings for Firestore
    json['status'] = status.value;
    json['priority'] = priority.value;
    return json;
  }

  /// Create from Firestore document
  factory Task.fromFirestore(Map<String, dynamic> data) {
    // Convert string values back to enums
    if (data['status'] is String) {
      data['status'] = TaskStatus.fromString(data['status']).name;
    }
    if (data['priority'] is String) {
      data['priority'] = PriorityLevel.fromString(data['priority']).name;
    }
    return Task.fromJson(data);
  }
}
