// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DocumentModelImpl _$$DocumentModelImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$DocumentModelImpl', json, ($checkedConvert) {
  final val = _$DocumentModelImpl(
    id: $checkedConvert('id', (v) => v as String),
    fileName: $checkedConvert('fileName', (v) => v as String),
    originalFileName: $checkedConvert('originalFileName', (v) => v as String),
    supabasePath: $checkedConvert('supabasePath', (v) => v as String),
    firebasePath: $checkedConvert('firebasePath', (v) => v as String),
    category: $checkedConvert(
      'category',
      (v) => $enumDecode(_$DocumentCategoryEnumMap, v),
    ),
    fileType: $checkedConvert(
      'fileType',
      (v) => $enumDecode(_$DocumentFileTypeEnumMap, v),
    ),
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(_$DocumentStatusEnumMap, v),
    ),
    accessLevel: $checkedConvert(
      'accessLevel',
      (v) => $enumDecode(_$DocumentAccessLevelEnumMap, v),
    ),
    uploadedBy: $checkedConvert('uploadedBy', (v) => v as String),
    uploadedByName: $checkedConvert('uploadedByName', (v) => v as String),
    uploadedAt: $checkedConvert(
      'uploadedAt',
      (v) => DateTime.parse(v as String),
    ),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
    fileSizeBytes: $checkedConvert('fileSizeBytes', (v) => (v as num).toInt()),
    accessRoles: $checkedConvert(
      'accessRoles',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    accessUserIds: $checkedConvert(
      'accessUserIds',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    description: $checkedConvert('description', (v) => v as String?),
    version: $checkedConvert('version', (v) => v as String?),
    folderId: $checkedConvert('folderId', (v) => v as String?),
    folderPath: $checkedConvert('folderPath', (v) => v as String?),
    mimeType: $checkedConvert('mimeType', (v) => v as String?),
    checksum: $checkedConvert('checksum', (v) => v as String?),
    metadata: $checkedConvert('metadata', (v) => v as Map<String, dynamic>?),
    tags: $checkedConvert(
      'tags',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
    approvedBy: $checkedConvert('approvedBy', (v) => v as String?),
    approvedByName: $checkedConvert('approvedByName', (v) => v as String?),
    approvedAt: $checkedConvert(
      'approvedAt',
      (v) => const TimestampConverter().fromJson(v),
    ),
    rejectedBy: $checkedConvert('rejectedBy', (v) => v as String?),
    rejectedByName: $checkedConvert('rejectedByName', (v) => v as String?),
    rejectedAt: $checkedConvert(
      'rejectedAt',
      (v) => const TimestampConverter().fromJson(v),
    ),
    rejectionReason: $checkedConvert('rejectionReason', (v) => v as String?),
    archivedAt: $checkedConvert(
      'archivedAt',
      (v) => const TimestampConverter().fromJson(v),
    ),
    archivedBy: $checkedConvert('archivedBy', (v) => v as String?),
    archivedByName: $checkedConvert('archivedByName', (v) => v as String?),
    archiveReason: $checkedConvert('archiveReason', (v) => v as String?),
    expiresAt: $checkedConvert(
      'expiresAt',
      (v) => const TimestampConverter().fromJson(v),
    ),
    isConfidential: $checkedConvert('isConfidential', (v) => v as bool?),
    requiresApproval: $checkedConvert('requiresApproval', (v) => v as bool?),
    downloadCount: $checkedConvert(
      'downloadCount',
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

Map<String, dynamic> _$$DocumentModelImplToJson(
  _$DocumentModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'fileName': instance.fileName,
  'originalFileName': instance.originalFileName,
  'supabasePath': instance.supabasePath,
  'firebasePath': instance.firebasePath,
  'category': _$DocumentCategoryEnumMap[instance.category]!,
  'fileType': _$DocumentFileTypeEnumMap[instance.fileType]!,
  'status': _$DocumentStatusEnumMap[instance.status]!,
  'accessLevel': _$DocumentAccessLevelEnumMap[instance.accessLevel]!,
  'uploadedBy': instance.uploadedBy,
  'uploadedByName': instance.uploadedByName,
  'uploadedAt': instance.uploadedAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'fileSizeBytes': instance.fileSizeBytes,
  'accessRoles': instance.accessRoles,
  'accessUserIds': instance.accessUserIds,
  'description': instance.description,
  'version': instance.version,
  'folderId': instance.folderId,
  'folderPath': instance.folderPath,
  'mimeType': instance.mimeType,
  'checksum': instance.checksum,
  'metadata': instance.metadata,
  'tags': instance.tags,
  'approvedBy': instance.approvedBy,
  'approvedByName': instance.approvedByName,
  'approvedAt': const TimestampConverter().toJson(instance.approvedAt),
  'rejectedBy': instance.rejectedBy,
  'rejectedByName': instance.rejectedByName,
  'rejectedAt': const TimestampConverter().toJson(instance.rejectedAt),
  'rejectionReason': instance.rejectionReason,
  'archivedAt': const TimestampConverter().toJson(instance.archivedAt),
  'archivedBy': instance.archivedBy,
  'archivedByName': instance.archivedByName,
  'archiveReason': instance.archiveReason,
  'expiresAt': const TimestampConverter().toJson(instance.expiresAt),
  'isConfidential': instance.isConfidential,
  'requiresApproval': instance.requiresApproval,
  'downloadCount': instance.downloadCount,
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

const _$DocumentFileTypeEnumMap = {
  DocumentFileType.pdf: 'pdf',
  DocumentFileType.doc: 'doc',
  DocumentFileType.docx: 'docx',
  DocumentFileType.pages: 'pages',
  DocumentFileType.xls: 'xls',
  DocumentFileType.xlsx: 'xlsx',
  DocumentFileType.numbers: 'numbers',
  DocumentFileType.ppt: 'ppt',
  DocumentFileType.pptx: 'pptx',
  DocumentFileType.keynote: 'keynote',
  DocumentFileType.txt: 'txt',
  DocumentFileType.csv: 'csv',
  DocumentFileType.jpg: 'jpg',
  DocumentFileType.jpeg: 'jpeg',
  DocumentFileType.png: 'png',
  DocumentFileType.gif: 'gif',
  DocumentFileType.zip: 'zip',
  DocumentFileType.rar: 'rar',
  DocumentFileType.mp4: 'mp4',
  DocumentFileType.mp3: 'mp3',
  DocumentFileType.other: 'other',
};

const _$DocumentStatusEnumMap = {
  DocumentStatus.draft: 'draft',
  DocumentStatus.pending: 'pending',
  DocumentStatus.approved: 'approved',
  DocumentStatus.rejected: 'rejected',
  DocumentStatus.archived: 'archived',
  DocumentStatus.deleted: 'deleted',
};

const _$DocumentAccessLevelEnumMap = {
  DocumentAccessLevel.public: 'public',
  DocumentAccessLevel.restricted: 'restricted',
  DocumentAccessLevel.confidential: 'confidential',
  DocumentAccessLevel.private: 'private',
};
