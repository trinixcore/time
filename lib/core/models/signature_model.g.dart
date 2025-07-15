// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signature_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SignatureImpl _$$SignatureImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$SignatureImpl', json, ($checkedConvert) {
  final val = _$SignatureImpl(
    id: $checkedConvert('id', (v) => v as String),
    ownerUid: $checkedConvert('ownerUid', (v) => v as String),
    ownerName: $checkedConvert('ownerName', (v) => v as String),
    imagePath: $checkedConvert('imagePath', (v) => v as String),
    requiresApproval: $checkedConvert('requiresApproval', (v) => v as bool),
    allowedLetterTypes: $checkedConvert(
      'allowedLetterTypes',
      (v) =>
          (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    ),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
    title: $checkedConvert('title', (v) => v as String?),
    department: $checkedConvert('department', (v) => v as String?),
    email: $checkedConvert('email', (v) => v as String?),
    phoneNumber: $checkedConvert('phoneNumber', (v) => v as String?),
    isActive: $checkedConvert('isActive', (v) => v as bool?),
    notes: $checkedConvert('notes', (v) => v as String?),
    metadata: $checkedConvert('metadata', (v) => v as Map<String, dynamic>?),
  );
  return val;
});

Map<String, dynamic> _$$SignatureImplToJson(_$SignatureImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ownerUid': instance.ownerUid,
      'ownerName': instance.ownerName,
      'imagePath': instance.imagePath,
      'requiresApproval': instance.requiresApproval,
      'allowedLetterTypes': instance.allowedLetterTypes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'title': instance.title,
      'department': instance.department,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'isActive': instance.isActive,
      'notes': instance.notes,
      'metadata': instance.metadata,
    };
