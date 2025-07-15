// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProjectImpl _$$ProjectImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$ProjectImpl', json, ($checkedConvert) {
  final val = _$ProjectImpl(
    id: $checkedConvert('id', (v) => v as String),
    name: $checkedConvert('name', (v) => v as String),
    description: $checkedConvert('description', (v) => v as String),
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(_$ProjectStatusEnumMap, v),
    ),
    priority: $checkedConvert(
      'priority',
      (v) => $enumDecode(_$ProjectPriorityEnumMap, v),
    ),
    managerId: $checkedConvert('managerId', (v) => v as String),
    startDate: $checkedConvert('startDate', (v) => DateTime.parse(v as String)),
    endDate: $checkedConvert(
      'endDate',
      (v) => const TimestampConverter().fromJson(v),
    ),
    actualEndDate: $checkedConvert(
      'actualEndDate',
      (v) => const TimestampConverter().fromJson(v),
    ),
    budget: $checkedConvert('budget', (v) => (v as num?)?.toDouble() ?? 0.0),
    actualCost: $checkedConvert(
      'actualCost',
      (v) => (v as num?)?.toDouble() ?? 0.0,
    ),
    progressPercentage: $checkedConvert(
      'progressPercentage',
      (v) => (v as num?)?.toInt() ?? 0,
    ),
    teamMemberIds: $checkedConvert(
      'teamMemberIds',
      (v) =>
          (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    ),
    tags: $checkedConvert(
      'tags',
      (v) =>
          (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    ),
    attachments: $checkedConvert(
      'attachments',
      (v) =>
          (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    ),
    clientId: $checkedConvert('clientId', (v) => v as String?),
    clientName: $checkedConvert('clientName', (v) => v as String?),
    departmentId: $checkedConvert('departmentId', (v) => v as String?),
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

Map<String, dynamic> _$$ProjectImplToJson(
  _$ProjectImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'status': _$ProjectStatusEnumMap[instance.status]!,
  'priority': _$ProjectPriorityEnumMap[instance.priority]!,
  'managerId': instance.managerId,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': const TimestampConverter().toJson(instance.endDate),
  'actualEndDate': const TimestampConverter().toJson(instance.actualEndDate),
  'budget': instance.budget,
  'actualCost': instance.actualCost,
  'progressPercentage': instance.progressPercentage,
  'teamMemberIds': instance.teamMemberIds,
  'tags': instance.tags,
  'attachments': instance.attachments,
  'clientId': instance.clientId,
  'clientName': instance.clientName,
  'departmentId': instance.departmentId,
  'customFields': instance.customFields,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'createdById': instance.createdById,
  'metadata': instance.metadata,
};

const _$ProjectStatusEnumMap = {
  ProjectStatus.planning: 'planning',
  ProjectStatus.active: 'active',
  ProjectStatus.onHold: 'onHold',
  ProjectStatus.completed: 'completed',
  ProjectStatus.cancelled: 'cancelled',
};

const _$ProjectPriorityEnumMap = {
  ProjectPriority.low: 'low',
  ProjectPriority.medium: 'medium',
  ProjectPriority.high: 'high',
  ProjectPriority.critical: 'critical',
};
