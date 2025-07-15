// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FolderModelImpl _$$FolderModelImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$FolderModelImpl', json, ($checkedConvert) {
  final val = _$FolderModelImpl(
    id: $checkedConvert('id', (v) => v as String),
    name: $checkedConvert('name', (v) => v as String),
    path: $checkedConvert('path', (v) => v as String),
    category: $checkedConvert(
      'category',
      (v) => $enumDecode(_$DocumentCategoryEnumMap, v),
    ),
    accessLevel: $checkedConvert(
      'accessLevel',
      (v) => $enumDecode(_$DocumentAccessLevelEnumMap, v),
    ),
    createdBy: $checkedConvert('createdBy', (v) => v as String),
    createdByName: $checkedConvert('createdByName', (v) => v as String),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
    accessRoles: $checkedConvert(
      'accessRoles',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    accessUserIds: $checkedConvert(
      'accessUserIds',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    parentId: $checkedConvert('parentId', (v) => v as String?),
    parentPath: $checkedConvert('parentPath', (v) => v as String?),
    description: $checkedConvert('description', (v) => v as String?),
    metadata: $checkedConvert('metadata', (v) => v as Map<String, dynamic>?),
    tags: $checkedConvert(
      'tags',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
    isArchived: $checkedConvert('isArchived', (v) => v as bool?),
    archivedAt: $checkedConvert(
      'archivedAt',
      (v) => const TimestampConverter().fromJson(v),
    ),
    archivedBy: $checkedConvert('archivedBy', (v) => v as String?),
    archivedByName: $checkedConvert('archivedByName', (v) => v as String?),
    archiveReason: $checkedConvert('archiveReason', (v) => v as String?),
    documentCount: $checkedConvert(
      'documentCount',
      (v) => (v as num?)?.toInt(),
    ),
    subfolderCount: $checkedConvert(
      'subfolderCount',
      (v) => (v as num?)?.toInt(),
    ),
    lastAccessedAt: $checkedConvert(
      'lastAccessedAt',
      (v) => const TimestampConverter().fromJson(v),
    ),
    lastAccessedBy: $checkedConvert('lastAccessedBy', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$$FolderModelImplToJson(
  _$FolderModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'path': instance.path,
  'category': _$DocumentCategoryEnumMap[instance.category]!,
  'accessLevel': _$DocumentAccessLevelEnumMap[instance.accessLevel]!,
  'createdBy': instance.createdBy,
  'createdByName': instance.createdByName,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'accessRoles': instance.accessRoles,
  'accessUserIds': instance.accessUserIds,
  'parentId': instance.parentId,
  'parentPath': instance.parentPath,
  'description': instance.description,
  'metadata': instance.metadata,
  'tags': instance.tags,
  'isArchived': instance.isArchived,
  'archivedAt': const TimestampConverter().toJson(instance.archivedAt),
  'archivedBy': instance.archivedBy,
  'archivedByName': instance.archivedByName,
  'archiveReason': instance.archiveReason,
  'documentCount': instance.documentCount,
  'subfolderCount': instance.subfolderCount,
  'lastAccessedAt': const TimestampConverter().toJson(instance.lastAccessedAt),
  'lastAccessedBy': instance.lastAccessedBy,
};

const _$DocumentCategoryEnumMap = {
  DocumentCategory.company: 'company',
  DocumentCategory.department: 'department',
  DocumentCategory.employee: 'employee',
  DocumentCategory.project: 'project',
  DocumentCategory.shared: 'shared',
  DocumentCategory.hr: 'hr',
  DocumentCategory.finance: 'finance',
  DocumentCategory.legal: 'legal',
  DocumentCategory.training: 'training',
  DocumentCategory.compliance: 'compliance',
};

const _$DocumentAccessLevelEnumMap = {
  DocumentAccessLevel.public: 'public',
  DocumentAccessLevel.restricted: 'restricted',
  DocumentAccessLevel.confidential: 'confidential',
  DocumentAccessLevel.private: 'private',
};
