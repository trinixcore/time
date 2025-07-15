// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TimeEntryImpl _$$TimeEntryImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$TimeEntryImpl', json, ($checkedConvert) {
  final val = _$TimeEntryImpl(
    id: $checkedConvert('id', (v) => v as String),
    employeeId: $checkedConvert('employeeId', (v) => v as String),
    taskId: $checkedConvert('taskId', (v) => v as String?),
    projectId: $checkedConvert('projectId', (v) => v as String?),
    startTime: $checkedConvert('startTime', (v) => DateTime.parse(v as String)),
    endTime: $checkedConvert(
      'endTime',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    description: $checkedConvert('description', (v) => v as String?),
    durationMinutes: $checkedConvert(
      'durationMinutes',
      (v) => (v as num?)?.toInt() ?? 0,
    ),
    isManualEntry: $checkedConvert('isManualEntry', (v) => v as bool? ?? false),
    isApproved: $checkedConvert('isApproved', (v) => v as bool? ?? false),
    approvedById: $checkedConvert('approvedById', (v) => v as String?),
    approvedAt: $checkedConvert(
      'approvedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    tags: $checkedConvert(
      'tags',
      (v) =>
          (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    ),
    location: $checkedConvert('location', (v) => v as String?),
    customFields: $checkedConvert(
      'customFields',
      (v) => v as Map<String, dynamic>?,
    ),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
    createdById: $checkedConvert('createdById', (v) => v as String?),
    metadata: $checkedConvert('metadata', (v) => v as Map<String, dynamic>?),
  );
  return val;
});

Map<String, dynamic> _$$TimeEntryImplToJson(_$TimeEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeId': instance.employeeId,
      'taskId': instance.taskId,
      'projectId': instance.projectId,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'description': instance.description,
      'durationMinutes': instance.durationMinutes,
      'isManualEntry': instance.isManualEntry,
      'isApproved': instance.isApproved,
      'approvedById': instance.approvedById,
      'approvedAt': instance.approvedAt?.toIso8601String(),
      'tags': instance.tags,
      'location': instance.location,
      'customFields': instance.customFields,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'createdById': instance.createdById,
      'metadata': instance.metadata,
    };
