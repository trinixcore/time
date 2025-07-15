// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moment_media_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MomentMediaImpl _$$MomentMediaImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(r'_$MomentMediaImpl', json, ($checkedConvert) {
      final val = _$MomentMediaImpl(
        id: $checkedConvert('id', (v) => v as String),
        fileName: $checkedConvert('fileName', (v) => v as String),
        fileUrl: $checkedConvert('fileUrl', (v) => v as String),
        mediaType: $checkedConvert(
          'mediaType',
          (v) => $enumDecode(_$MediaTypeEnumMap, v),
        ),
        displayOrder: $checkedConvert(
          'displayOrder',
          (v) => (v as num).toInt(),
        ),
        uploadedBy: $checkedConvert('uploadedBy', (v) => v as String),
        uploadedAt: $checkedConvert(
          'uploadedAt',
          (v) => DateTime.parse(v as String),
        ),
        title: $checkedConvert('title', (v) => v as String?),
        description: $checkedConvert('description', (v) => v as String?),
        isActive: $checkedConvert('isActive', (v) => v as bool? ?? true),
      );
      return val;
    });

Map<String, dynamic> _$$MomentMediaImplToJson(_$MomentMediaImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fileName': instance.fileName,
      'fileUrl': instance.fileUrl,
      'mediaType': _$MediaTypeEnumMap[instance.mediaType]!,
      'displayOrder': instance.displayOrder,
      'uploadedBy': instance.uploadedBy,
      'uploadedAt': instance.uploadedAt.toIso8601String(),
      'title': instance.title,
      'description': instance.description,
      'isActive': instance.isActive,
    };

const _$MediaTypeEnumMap = {MediaType.image: 'image', MediaType.video: 'video'};
