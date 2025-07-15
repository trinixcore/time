// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskImpl _$$TaskImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$TaskImpl', json, ($checkedConvert) {
  final val = _$TaskImpl(
    id: $checkedConvert('id', (v) => v as String),
    title: $checkedConvert('title', (v) => v as String),
    description: $checkedConvert('description', (v) => v as String),
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(_$TaskStatusEnumMap, v),
    ),
    priority: $checkedConvert(
      'priority',
      (v) => $enumDecode(_$PriorityLevelEnumMap, v),
    ),
    assignedToId: $checkedConvert('assignedToId', (v) => v as String),
    createdById: $checkedConvert('createdById', (v) => v as String),
    projectId: $checkedConvert('projectId', (v) => v as String?),
    parentTaskId: $checkedConvert('parentTaskId', (v) => v as String?),
    startDate: $checkedConvert(
      'startDate',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    dueDate: $checkedConvert(
      'dueDate',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    completedAt: $checkedConvert(
      'completedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    estimatedHours: $checkedConvert(
      'estimatedHours',
      (v) => (v as num?)?.toDouble() ?? 0.0,
    ),
    actualHours: $checkedConvert(
      'actualHours',
      (v) => (v as num?)?.toDouble() ?? 0.0,
    ),
    progressPercentage: $checkedConvert(
      'progressPercentage',
      (v) => (v as num?)?.toInt() ?? 0,
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
    subtaskIds: $checkedConvert(
      'subtaskIds',
      (v) =>
          (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    ),
    dependencyIds: $checkedConvert(
      'dependencyIds',
      (v) =>
          (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    ),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
    metadata: $checkedConvert('metadata', (v) => v as Map<String, dynamic>?),
  );
  return val;
});

Map<String, dynamic> _$$TaskImplToJson(_$TaskImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'status': _$TaskStatusEnumMap[instance.status]!,
      'priority': _$PriorityLevelEnumMap[instance.priority]!,
      'assignedToId': instance.assignedToId,
      'createdById': instance.createdById,
      'projectId': instance.projectId,
      'parentTaskId': instance.parentTaskId,
      'startDate': instance.startDate?.toIso8601String(),
      'dueDate': instance.dueDate?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'estimatedHours': instance.estimatedHours,
      'actualHours': instance.actualHours,
      'progressPercentage': instance.progressPercentage,
      'tags': instance.tags,
      'attachments': instance.attachments,
      'subtaskIds': instance.subtaskIds,
      'dependencyIds': instance.dependencyIds,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$TaskStatusEnumMap = {
  TaskStatus.todo: 'todo',
  TaskStatus.inProgress: 'inProgress',
  TaskStatus.review: 'review',
  TaskStatus.testing: 'testing',
  TaskStatus.completed: 'completed',
  TaskStatus.cancelled: 'cancelled',
  TaskStatus.onHold: 'onHold',
  TaskStatus.blocked: 'blocked',
};

const _$PriorityLevelEnumMap = {
  PriorityLevel.low: 'low',
  PriorityLevel.medium: 'medium',
  PriorityLevel.high: 'high',
  PriorityLevel.urgent: 'urgent',
  PriorityLevel.critical: 'critical',
};
