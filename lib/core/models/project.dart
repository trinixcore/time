import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/project_status.dart';
import '../enums/project_priority.dart';

part 'project.freezed.dart';
part 'project.g.dart';

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
    return dateTime?.toIso8601String();
  }
}

@freezed
class Project with _$Project {
  const factory Project({
    required String id,
    required String name,
    required String description,
    required ProjectStatus status,
    required ProjectPriority priority,
    required String managerId,
    @TimestampConverter() required DateTime startDate,
    @TimestampConverter() DateTime? endDate,
    @TimestampConverter() DateTime? actualEndDate,
    @Default(0.0) double budget,
    @Default(0.0) double actualCost,
    @Default(0) int progressPercentage,
    @Default([]) List<String> teamMemberIds,
    @Default([]) List<String> tags,
    @Default([]) List<String> attachments,
    String? clientId,
    String? clientName,
    String? departmentId,
    Map<String, dynamic>? customFields,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
    String? createdById,
    Map<String, dynamic>? metadata,
  }) = _Project;

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  // Additional methods and getters
  const Project._();

  /// Get project duration in days
  int get durationInDays {
    final end = actualEndDate ?? endDate ?? DateTime.now();
    return end.difference(startDate).inDays + 1;
  }

  /// Get remaining days (if project has end date)
  int? get remainingDays {
    if (endDate == null) return null;
    if (status.isCompleted) return 0;

    final now = DateTime.now();
    if (now.isAfter(endDate!)) return 0;

    return endDate!.difference(now).inDays;
  }

  /// Check if project is overdue
  bool get isOverdue {
    if (endDate == null || status.isCompleted) return false;
    return DateTime.now().isAfter(endDate!);
  }

  /// Check if project is due soon (within 7 days)
  bool get isDueSoon {
    final remaining = remainingDays;
    return remaining != null && remaining <= 7 && remaining > 0;
  }

  /// Get project progress as a decimal (0.0 to 1.0)
  double get progressDecimal => progressPercentage / 100.0;

  /// Check if project is on track (progress matches time elapsed)
  bool get isOnTrack {
    if (endDate == null) return true;

    final totalDuration = endDate!.difference(startDate).inDays;
    final elapsedDuration = DateTime.now().difference(startDate).inDays;
    final expectedProgress = (elapsedDuration / totalDuration * 100).clamp(
      0,
      100,
    );

    // Consider on track if within 10% of expected progress
    return (progressPercentage - expectedProgress).abs() <= 10;
  }

  /// Get budget utilization percentage
  double get budgetUtilization {
    if (budget <= 0) return 0.0;
    return (actualCost / budget * 100).clamp(0, double.infinity);
  }

  /// Check if project is over budget
  bool get isOverBudget => actualCost > budget && budget > 0;

  /// Get remaining budget
  double get remainingBudget => budget - actualCost;

  /// Get team size
  int get teamSize => teamMemberIds.length;

  /// Check if user is team member
  bool isTeamMember(String userId) => teamMemberIds.contains(userId);

  /// Check if user is project manager
  bool isManager(String userId) => managerId == userId;

  /// Get project health score (0-100)
  int get healthScore {
    int score = 100;

    // Deduct points for being overdue
    if (isOverdue) score -= 30;

    // Deduct points for being over budget
    if (isOverBudget) score -= 20;

    // Deduct points for being behind schedule
    if (!isOnTrack && progressPercentage < 50) score -= 15;

    // Deduct points for high priority projects with low progress
    if (priority.isHigh && progressPercentage < 25) score -= 15;

    // Deduct points for inactive status
    if (status.isOnHold || status.isCancelled) score -= 40;

    return score.clamp(0, 100);
  }

  /// Get project status color
  String get statusColor => status.colorCode;

  /// Get project priority color
  String get priorityColor => priority.colorCode;

  /// Create a copy with updated progress
  Project updateProgress(int newProgress) {
    return copyWith(
      progressPercentage: newProgress.clamp(0, 100),
      updatedAt: DateTime.now(),
    );
  }

  /// Create a copy with updated status
  Project updateStatus(ProjectStatus newStatus) {
    final now = DateTime.now();
    return copyWith(
      status: newStatus,
      actualEndDate: newStatus.isCompleted ? now : actualEndDate,
      updatedAt: now,
    );
  }

  /// Create a copy with updated budget
  Project updateBudget({double? budget, double? actualCost}) {
    return copyWith(
      budget: budget ?? this.budget,
      actualCost: actualCost ?? this.actualCost,
      updatedAt: DateTime.now(),
    );
  }

  /// Add team member to project
  Project addTeamMember(String userId) {
    if (teamMemberIds.contains(userId)) return this;
    return copyWith(
      teamMemberIds: [...teamMemberIds, userId],
      updatedAt: DateTime.now(),
    );
  }

  /// Remove team member from project
  Project removeTeamMember(String userId) {
    return copyWith(
      teamMemberIds: teamMemberIds.where((id) => id != userId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// Add tag to project
  Project addTag(String tag) {
    if (tags.contains(tag)) return this;
    return copyWith(tags: [...tags, tag], updatedAt: DateTime.now());
  }

  /// Remove tag from project
  Project removeTag(String tag) {
    return copyWith(
      tags: tags.where((t) => t != tag).toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// Add attachment to project
  Project addAttachment(String attachment) {
    if (attachments.contains(attachment)) return this;
    return copyWith(
      attachments: [...attachments, attachment],
      updatedAt: DateTime.now(),
    );
  }

  /// Remove attachment from project
  Project removeAttachment(String attachment) {
    return copyWith(
      attachments: attachments.where((a) => a != attachment).toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// Update custom field
  Project updateCustomField(String key, dynamic value) {
    final updatedFields = Map<String, dynamic>.from(customFields ?? {});
    updatedFields[key] = value;

    return copyWith(customFields: updatedFields, updatedAt: DateTime.now());
  }

  /// Remove custom field
  Project removeCustomField(String key) {
    if (customFields == null || !customFields!.containsKey(key)) return this;

    final updatedFields = Map<String, dynamic>.from(customFields!);
    updatedFields.remove(key);

    return copyWith(
      customFields: updatedFields.isEmpty ? null : updatedFields,
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
  factory Project.fromFirestore(Map<String, dynamic> data) {
    // Convert string values back to enums
    if (data['status'] is String) {
      data['status'] = ProjectStatus.fromString(data['status']).name;
    }
    if (data['priority'] is String) {
      data['priority'] = ProjectPriority.fromString(data['priority']).name;
    }
    return Project.fromJson(data);
  }
}
