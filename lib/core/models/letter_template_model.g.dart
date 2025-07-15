// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'letter_template_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LetterTemplateImpl _$$LetterTemplateImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$LetterTemplateImpl', json, ($checkedConvert) {
  final val = _$LetterTemplateImpl(
    id: $checkedConvert('id', (v) => v as String),
    name: $checkedConvert('name', (v) => v as String),
    type: $checkedConvert('type', (v) => v as String),
    content: $checkedConvert('content', (v) => v as String),
    variables: $checkedConvert(
      'variables',
      (v) =>
          (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    ),
    defaultValues: $checkedConvert(
      'defaultValues',
      (v) =>
          (v as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    ),
    isActive: $checkedConvert('isActive', (v) => v as bool? ?? true),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
    createdBy: $checkedConvert('createdBy', (v) => v as String),
    description: $checkedConvert('description', (v) => v as String?),
    category: $checkedConvert('category', (v) => v as String?),
    requiredFields: $checkedConvert(
      'requiredFields',
      (v) =>
          (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    ),
    optionalFields: $checkedConvert(
      'optionalFields',
      (v) =>
          (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    ),
    signatureId: $checkedConvert('signatureId', (v) => v as String?),
    metadata: $checkedConvert(
      'metadata',
      (v) => v as Map<String, dynamic>? ?? const {},
    ),
  );
  return val;
});

Map<String, dynamic> _$$LetterTemplateImplToJson(
  _$LetterTemplateImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': instance.type,
  'content': instance.content,
  'variables': instance.variables,
  'defaultValues': instance.defaultValues,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'createdBy': instance.createdBy,
  'description': instance.description,
  'category': instance.category,
  'requiredFields': instance.requiredFields,
  'optionalFields': instance.optionalFields,
  'signatureId': instance.signatureId,
  'metadata': instance.metadata,
};
