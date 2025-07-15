// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_time_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskTimeLogModelImpl _$$TaskTimeLogModelImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$TaskTimeLogModelImpl', json, ($checkedConvert) {
  final val = _$TaskTimeLogModelImpl(
    id: $checkedConvert('id', (v) => v as String),
    taskId: $checkedConvert('taskId', (v) => v as String),
    userId: $checkedConvert('userId', (v) => v as String),
    userName: $checkedConvert('userName', (v) => v as String),
    startTime: $checkedConvert('startTime', (v) => DateTime.parse(v as String)),
    endTime: $checkedConvert(
      'endTime',
      (v) => const TimestampConverter().fromJson(v),
    ),
    description: $checkedConvert('description', (v) => v as String?),
    durationMinutes: $checkedConvert(
      'durationMinutes',
      (v) => (v as num?)?.toInt() ?? 0,
    ),
    isManualEntry: $checkedConvert('isManualEntry', (v) => v as bool? ?? false),
    isApproved: $checkedConvert('isApproved', (v) => v as bool? ?? false),
    approvedBy: $checkedConvert('approvedBy', (v) => v as String?),
    approvedByName: $checkedConvert('approvedByName', (v) => v as String?),
    approvedAt: $checkedConvert(
      'approvedAt',
      (v) => const TimestampConverter().fromJson(v),
    ),
    rejectionReason: $checkedConvert('rejectionReason', (v) => v as String?),
    attachments: $checkedConvert(
      'attachments',
      (v) =>
          (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    ),
    metadata: $checkedConvert('metadata', (v) => v as Map<String, dynamic>?),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$$TaskTimeLogModelImplToJson(
  _$TaskTimeLogModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'taskId': instance.taskId,
  'userId': instance.userId,
  'userName': instance.userName,
  'startTime': instance.startTime.toIso8601String(),
  'endTime': const TimestampConverter().toJson(instance.endTime),
  'description': instance.description,
  'durationMinutes': instance.durationMinutes,
  'isManualEntry': instance.isManualEntry,
  'isApproved': instance.isApproved,
  'approvedBy': instance.approvedBy,
  'approvedByName': instance.approvedByName,
  'approvedAt': const TimestampConverter().toJson(instance.approvedAt),
  'rejectionReason': instance.rejectionReason,
  'attachments': instance.attachments,
  'metadata': instance.metadata,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
