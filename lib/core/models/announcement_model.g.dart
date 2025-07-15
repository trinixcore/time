// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AnnouncementImpl _$$AnnouncementImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$AnnouncementImpl', json, ($checkedConvert) {
  final val = _$AnnouncementImpl(
    id: $checkedConvert('id', (v) => v as String),
    title: $checkedConvert('title', (v) => v as String),
    content: $checkedConvert('content', (v) => v as String),
    createdBy: $checkedConvert('createdBy', (v) => v as String),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    expiresAt: $checkedConvert(
      'expiresAt',
      (v) => const TimestampConverter().fromJson(v),
    ),
    isActive: $checkedConvert('isActive', (v) => v as bool? ?? true),
    priority: $checkedConvert('priority', (v) => v as String? ?? 'medium'),
    tags: $checkedConvert(
      'tags',
      (v) =>
          (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    ),
    category: $checkedConvert('category', (v) => v as String?),
    richContent: $checkedConvert('richContent', (v) => v as String?),
    attachments: $checkedConvert(
      'attachments',
      (v) =>
          (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    ),
    targetDepartments: $checkedConvert(
      'targetDepartments',
      (v) =>
          (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    ),
    targetRoles: $checkedConvert(
      'targetRoles',
      (v) =>
          (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    ),
    isGlobal: $checkedConvert('isGlobal', (v) => v as bool? ?? true),
    requiresAcknowledgment: $checkedConvert(
      'requiresAcknowledgment',
      (v) => v as bool? ?? false,
    ),
    acknowledgedBy: $checkedConvert(
      'acknowledgedBy',
      (v) =>
          (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    ),
    maxViews: $checkedConvert('maxViews', (v) => (v as num?)?.toInt()),
    viewCount: $checkedConvert('viewCount', (v) => (v as num?)?.toInt() ?? 0),
    createdByName: $checkedConvert('createdByName', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$$AnnouncementImplToJson(_$AnnouncementImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': const TimestampConverter().toJson(instance.expiresAt),
      'isActive': instance.isActive,
      'priority': instance.priority,
      'tags': instance.tags,
      'category': instance.category,
      'richContent': instance.richContent,
      'attachments': instance.attachments,
      'targetDepartments': instance.targetDepartments,
      'targetRoles': instance.targetRoles,
      'isGlobal': instance.isGlobal,
      'requiresAcknowledgment': instance.requiresAcknowledgment,
      'acknowledgedBy': instance.acknowledgedBy,
      'maxViews': instance.maxViews,
      'viewCount': instance.viewCount,
      'createdByName': instance.createdByName,
    };
