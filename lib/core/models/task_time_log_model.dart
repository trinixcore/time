import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'task_time_log_model.freezed.dart';
part 'task_time_log_model.g.dart';

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
class TaskTimeLogModel with _$TaskTimeLogModel {
  const factory TaskTimeLogModel({
    required String id,
    required String taskId,
    required String userId,
    required String userName,
    @TimestampConverter() required DateTime startTime,
    @TimestampConverter() DateTime? endTime,
    String? description,
    @Default(0) int durationMinutes,
    @Default(false) bool isManualEntry,
    @Default(false) bool isApproved,
    String? approvedBy,
    String? approvedByName,
    @TimestampConverter() DateTime? approvedAt,
    String? rejectionReason,
    @Default([]) List<String> attachments,
    Map<String, dynamic>? metadata,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _TaskTimeLogModel;

  factory TaskTimeLogModel.fromJson(Map<String, dynamic> json) =>
      _$TaskTimeLogModelFromJson(json);

  // Additional methods and getters
  const TaskTimeLogModel._();

  bool get isActive => endTime == null;
  bool get isCompleted => endTime != null;
  bool get isPendingApproval =>
      isCompleted && !isApproved && approvedBy == null;
  bool get isRejected => rejectionReason != null;

  // Calculate duration
  Duration get duration {
    if (endTime == null) {
      return DateTime.now().difference(startTime);
    }
    return endTime!.difference(startTime);
  }

  int get durationInMinutes {
    return duration.inMinutes;
  }

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  // Convert to map for Firestore
  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  // Create from Firestore document
  factory TaskTimeLogModel.fromFirestore(Map<String, dynamic> data) {
    return TaskTimeLogModel.fromJson(data);
  }
}
