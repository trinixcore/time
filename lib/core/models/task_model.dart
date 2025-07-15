import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/task_status.dart';
import '../enums/priority_level.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

// Custom converter for handling Firestore Timestamp and String dates
class TimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const TimestampConverter();

  @override
  DateTime? fromJson(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is String) {
      return DateTime.parse(value);
    }

    throw ArgumentError('Cannot convert $value to DateTime');
  }

  @override
  dynamic toJson(DateTime? dateTime) {
    if (dateTime == null) return null;
    return Timestamp.fromDate(dateTime);
  }
}

// Custom converter for handling TaskStatus values
class TaskStatusConverter implements JsonConverter<TaskStatus, String> {
  const TaskStatusConverter();

  @override
  TaskStatus fromJson(String value) => TaskStatus.fromString(value);

  @override
  String toJson(TaskStatus status) => status.value;
}

// Custom converter for handling PriorityLevel values
class PriorityLevelConverter implements JsonConverter<PriorityLevel, String> {
  const PriorityLevelConverter();

  @override
  PriorityLevel fromJson(String value) => PriorityLevel.fromString(value);

  @override
  String toJson(PriorityLevel priority) => priority.value;
}

@freezed
class TaskModel with _$TaskModel {
  const factory TaskModel({
    required String id,
    required String title,
    required String description,
    @PriorityLevelConverter() required PriorityLevel priority,
    @TaskStatusConverter() @Default(TaskStatus.todo) TaskStatus status,
    @TimestampConverter() required DateTime dueDate,
    required String departmentId,
    required String projectId,
    required String assignedTo,
    required String createdBy,
    String? category,
    @Default([]) List<String> tags,
    @Default([]) List<String> attachments,
    @Default([]) List<String> watchers,
    @Default(0) int estimatedHours,
    @Default(0) int actualHours,
    @Default(0) int timeSpentMinutes,
    @Default(0) int progressPercentage,
    @TimestampConverter() DateTime? lastProgressUpdate,
    String? parentTaskId,
    @Default([]) List<String> dependencies,
    @Default([]) List<String> subTaskIds,
    @TimestampConverter() DateTime? completedAt,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
    Map<String, dynamic>? metadata,
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  // Additional methods and getters
  const TaskModel._();

  bool get isOverdue => dueDate.isBefore(DateTime.now()) && !status.isCompleted;

  bool get isDueSoon {
    final now = DateTime.now();
    final daysUntilDue = dueDate.difference(now).inDays;
    return daysUntilDue <= 3 && daysUntilDue >= 0 && !status.isCompleted;
  }

  bool get isActive => status.isActive;
  bool get isCompleted => status.isCompleted || progressPercentage >= 100;
  bool get isCancelled => status.isCancelled;
  bool get isInProgress => progressPercentage > 0 && progressPercentage < 100;
  bool get isBlocked => status.isBlocked;

  bool get hasSubTasks => subTaskIds.isNotEmpty;
  bool get hasDependencies => dependencies.isNotEmpty;
  bool get isSubTask => parentTaskId != null;
  bool get isParentTask => subTaskIds.isNotEmpty;

  bool get isHighPriority => priority.isHighPriority;
  bool get requiresImmediateAttention => priority.requiresImmediateAttention;

  // Time tracking helpers
  bool get isTimeTracking => false;
  bool get canStartTimeTracking => false;
  bool get canStopTimeTracking => false;

  // Progress calculation
  int get progressPercentage {
    if (status.isCompleted) return 100;
    if (status.isCancelled) return 0;

    // If we have actual hours vs estimated hours, calculate progress
    if (estimatedHours > 0) {
      return (actualHours / estimatedHours * 100).round().clamp(0, 100);
    }

    // Default progress based on status
    switch (status) {
      case TaskStatus.todo:
        return 0;
      case TaskStatus.inProgress:
        return 50;
      case TaskStatus.review:
        return 75;
      case TaskStatus.testing:
        return 90;
      default:
        return 0;
    }
  }

  // Duration helpers
  Duration? get duration {
    if (completedAt == null) return null;
    return completedAt!.difference(createdAt);
  }

  String get formattedDuration {
    final dur = duration;
    if (dur == null) return 'Not started';

    final hours = dur.inHours;
    final minutes = dur.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  // Status transition helpers
  bool canTransitionTo(TaskStatus newStatus) {
    return status.getNextPossibleStatuses().contains(newStatus);
  }

  // Task hierarchy helpers
  bool isDescendantOf(String taskId) {
    if (parentTaskId == taskId) return true;
    if (parentTaskId == null) return false;
    // This would need to be implemented with full task tree access
    return false;
  }

  bool isAncestorOf(String taskId) {
    return subTaskIds.contains(taskId);
  }

  // Delivery risk assessment
  String get deliveryRisk {
    if (isCompleted) return 'Completed';

    final now = DateTime.now();
    final totalDuration = dueDate.difference(createdAt).inDays;
    final elapsedDuration = now.difference(createdAt).inDays;

    if (totalDuration <= 0) return 'High Risk';

    final expectedProgress = (elapsedDuration / totalDuration * 100).clamp(
      0,
      100,
    );
    final progressGap = expectedProgress - progressPercentage;

    if (now.isAfter(dueDate)) return 'Overdue';
    if (progressGap > 30) return 'High Risk';
    if (progressGap > 15) return 'Medium Risk';
    if (progressGap > 5) return 'Low Risk';
    return 'On Track';
  }

  // Convert to map for Firestore
  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  // Create from Firestore document
  factory TaskModel.fromFirestore(Map<String, dynamic> data) {
    return TaskModel.fromJson(data);
  }
}
