import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'task_comment_model.freezed.dart';
part 'task_comment_model.g.dart';

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
class TaskCommentModel with _$TaskCommentModel {
  const factory TaskCommentModel({
    required String id,
    required String taskId,
    required String content,
    required String authorId,
    required String authorName,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
    String? parentCommentId,
    @Default([]) List<String> replies,
    @Default([]) List<String> attachments,
    @Default([]) List<String> mentions,
    @Default(false) bool isEdited,
    @Default(false) bool isDeleted,
    String? editedBy,
    @TimestampConverter() DateTime? editedAt,
    String? deletedBy,
    @TimestampConverter() DateTime? deletedAt,
    Map<String, dynamic>? metadata,
  }) = _TaskCommentModel;

  factory TaskCommentModel.fromJson(Map<String, dynamic> json) =>
      _$TaskCommentModelFromJson(json);

  // Additional methods and getters
  const TaskCommentModel._();

  bool get isReply => parentCommentId != null;
  bool get isTopLevel => parentCommentId == null;
  bool get hasReplies => replies.isNotEmpty;
  bool get hasAttachments => attachments.isNotEmpty;
  bool get hasMentions => mentions.isNotEmpty;

  // Convert to map for Firestore
  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  // Create from Firestore document
  factory TaskCommentModel.fromFirestore(Map<String, dynamic> data) {
    return TaskCommentModel.fromJson(data);
  }
}
