// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskCommentModelImpl _$$TaskCommentModelImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$TaskCommentModelImpl', json, ($checkedConvert) {
  final val = _$TaskCommentModelImpl(
    id: $checkedConvert('id', (v) => v as String),
    taskId: $checkedConvert('taskId', (v) => v as String),
    content: $checkedConvert('content', (v) => v as String),
    authorId: $checkedConvert('authorId', (v) => v as String),
    authorName: $checkedConvert('authorName', (v) => v as String),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
    parentCommentId: $checkedConvert('parentCommentId', (v) => v as String?),
    replies: $checkedConvert(
      'replies',
      (v) =>
          (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    ),
    attachments: $checkedConvert(
      'attachments',
      (v) =>
          (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    ),
    mentions: $checkedConvert(
      'mentions',
      (v) =>
          (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    ),
    isEdited: $checkedConvert('isEdited', (v) => v as bool? ?? false),
    isDeleted: $checkedConvert('isDeleted', (v) => v as bool? ?? false),
    editedBy: $checkedConvert('editedBy', (v) => v as String?),
    editedAt: $checkedConvert(
      'editedAt',
      (v) => const TimestampConverter().fromJson(v),
    ),
    deletedBy: $checkedConvert('deletedBy', (v) => v as String?),
    deletedAt: $checkedConvert(
      'deletedAt',
      (v) => const TimestampConverter().fromJson(v),
    ),
    metadata: $checkedConvert('metadata', (v) => v as Map<String, dynamic>?),
  );
  return val;
});

Map<String, dynamic> _$$TaskCommentModelImplToJson(
  _$TaskCommentModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'taskId': instance.taskId,
  'content': instance.content,
  'authorId': instance.authorId,
  'authorName': instance.authorName,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'parentCommentId': instance.parentCommentId,
  'replies': instance.replies,
  'attachments': instance.attachments,
  'mentions': instance.mentions,
  'isEdited': instance.isEdited,
  'isDeleted': instance.isDeleted,
  'editedBy': instance.editedBy,
  'editedAt': const TimestampConverter().toJson(instance.editedAt),
  'deletedBy': instance.deletedBy,
  'deletedAt': const TimestampConverter().toJson(instance.deletedAt),
  'metadata': instance.metadata,
};
