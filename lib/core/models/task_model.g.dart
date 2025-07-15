// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskModelImpl _$$TaskModelImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$TaskModelImpl', json, ($checkedConvert) {
  final val = _$TaskModelImpl(
    id: $checkedConvert('id', (v) => v as String),
    title: $checkedConvert('title', (v) => v as String),
    description: $checkedConvert('description', (v) => v as String),
    priority: $checkedConvert(
      'priority',
      (v) => const PriorityLevelConverter().fromJson(v as String),
    ),
    status: $checkedConvert(
      'status',
      (v) =>
          v == null
              ? TaskStatus.todo
              : const TaskStatusConverter().fromJson(v as String),
    ),
    dueDate: $checkedConvert('dueDate', (v) => DateTime.parse(v as String)),
    departmentId: $checkedConvert('departmentId', (v) => v as String),
    projectId: $checkedConvert('projectId', (v) => v as String),
    assignedTo: $checkedConvert('assignedTo', (v) => v as String),
    createdBy: $checkedConvert('createdBy', (v) => v as String),
    category: $checkedConvert('category', (v) => v as String?),
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
    watchers: $checkedConvert(
      'watchers',
      (v) =>
          (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    ),
    estimatedHours: $checkedConvert(
      'estimatedHours',
      (v) => (v as num?)?.toInt() ?? 0,
    ),
    actualHours: $checkedConvert(
      'actualHours',
      (v) => (v as num?)?.toInt() ?? 0,
    ),
    timeSpentMinutes: $checkedConvert(
      'timeSpentMinutes',
      (v) => (v as num?)?.toInt() ?? 0,
    ),
    progressPercentage: $checkedConvert(
      'progressPercentage',
      (v) => (v as num?)?.toInt() ?? 0,
    ),
    lastProgressUpdate: $checkedConvert(
      'lastProgressUpdate',
      (v) => const TimestampConverter().fromJson(v),
    ),
    parentTaskId: $checkedConvert('parentTaskId', (v) => v as String?),
    dependencies: $checkedConvert(
      'dependencies',
      (v) =>
          (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    ),
    subTaskIds: $checkedConvert(
      'subTaskIds',
      (v) =>
          (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    ),
    completedAt: $checkedConvert(
      'completedAt',
      (v) => const TimestampConverter().fromJson(v),
    ),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
    metadata: $checkedConvert('metadata', (v) => v as Map<String, dynamic>?),
  );
  return val;
});

Map<String, dynamic> _$$TaskModelImplToJson(_$TaskModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'priority': const PriorityLevelConverter().toJson(instance.priority),
      'status': const TaskStatusConverter().toJson(instance.status),
      'dueDate': instance.dueDate.toIso8601String(),
      'departmentId': instance.departmentId,
      'projectId': instance.projectId,
      'assignedTo': instance.assignedTo,
      'createdBy': instance.createdBy,
      'category': instance.category,
      'tags': instance.tags,
      'attachments': instance.attachments,
      'watchers': instance.watchers,
      'estimatedHours': instance.estimatedHours,
      'actualHours': instance.actualHours,
      'timeSpentMinutes': instance.timeSpentMinutes,
      'progressPercentage': instance.progressPercentage,
      'lastProgressUpdate': const TimestampConverter().toJson(
        instance.lastProgressUpdate,
      ),
      'parentTaskId': instance.parentTaskId,
      'dependencies': instance.dependencies,
      'subTaskIds': instance.subTaskIds,
      'completedAt': const TimestampConverter().toJson(instance.completedAt),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'metadata': instance.metadata,
    };
