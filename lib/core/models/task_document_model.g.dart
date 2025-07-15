// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_document_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskDocumentModelImpl _$$TaskDocumentModelImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$TaskDocumentModelImpl', json, ($checkedConvert) {
  final val = _$TaskDocumentModelImpl(
    id: $checkedConvert('id', (v) => v as String),
    taskId: $checkedConvert('taskId', (v) => v as String),
    fileName: $checkedConvert('fileName', (v) => v as String),
    originalFileName: $checkedConvert('originalFileName', (v) => v as String),
    supabasePath: $checkedConvert('supabasePath', (v) => v as String),
    firebasePath: $checkedConvert('firebasePath', (v) => v as String),
    fileType: $checkedConvert('fileType', (v) => v as String),
    mimeType: $checkedConvert('mimeType', (v) => v as String),
    fileSizeBytes: $checkedConvert('fileSizeBytes', (v) => (v as num).toInt()),
    uploadedBy: $checkedConvert('uploadedBy', (v) => v as String),
    uploadedByName: $checkedConvert('uploadedByName', (v) => v as String),
    uploadedAt: $checkedConvert(
      'uploadedAt',
      (v) => DateTime.parse(v as String),
    ),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
    description: $checkedConvert('description', (v) => v as String?),
    tags: $checkedConvert(
      'tags',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
    checksum: $checkedConvert('checksum', (v) => v as String?),
    isConfidential: $checkedConvert(
      'isConfidential',
      (v) => v as bool? ?? false,
    ),
    status: $checkedConvert('status', (v) => v as String? ?? 'approved'),
  );
  return val;
});

Map<String, dynamic> _$$TaskDocumentModelImplToJson(
  _$TaskDocumentModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'taskId': instance.taskId,
  'fileName': instance.fileName,
  'originalFileName': instance.originalFileName,
  'supabasePath': instance.supabasePath,
  'firebasePath': instance.firebasePath,
  'fileType': instance.fileType,
  'mimeType': instance.mimeType,
  'fileSizeBytes': instance.fileSizeBytes,
  'uploadedBy': instance.uploadedBy,
  'uploadedByName': instance.uploadedByName,
  'uploadedAt': instance.uploadedAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'description': instance.description,
  'tags': instance.tags,
  'checksum': instance.checksum,
  'isConfidential': instance.isConfidential,
  'status': instance.status,
};
