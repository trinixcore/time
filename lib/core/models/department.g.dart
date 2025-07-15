// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'department.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DepartmentImpl _$$DepartmentImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$DepartmentImpl', json, ($checkedConvert) {
  final val = _$DepartmentImpl(
    id: $checkedConvert('id', (v) => v as String),
    name: $checkedConvert('name', (v) => v as String),
    description: $checkedConvert('description', (v) => v as String),
    managerId: $checkedConvert('managerId', (v) => v as String?),
    parentDepartmentId: $checkedConvert(
      'parentDepartmentId',
      (v) => v as String?,
    ),
    employeeIds: $checkedConvert(
      'employeeIds',
      (v) =>
          (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    ),
    subDepartmentIds: $checkedConvert(
      'subDepartmentIds',
      (v) =>
          (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    ),
    budget: $checkedConvert('budget', (v) => (v as num?)?.toDouble() ?? 0.0),
    actualSpending: $checkedConvert(
      'actualSpending',
      (v) => (v as num?)?.toDouble() ?? 0.0,
    ),
    isActive: $checkedConvert('isActive', (v) => v as bool? ?? true),
    location: $checkedConvert('location', (v) => v as String?),
    contactEmail: $checkedConvert('contactEmail', (v) => v as String?),
    contactPhone: $checkedConvert('contactPhone', (v) => v as String?),
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

Map<String, dynamic> _$$DepartmentImplToJson(_$DepartmentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'managerId': instance.managerId,
      'parentDepartmentId': instance.parentDepartmentId,
      'employeeIds': instance.employeeIds,
      'subDepartmentIds': instance.subDepartmentIds,
      'budget': instance.budget,
      'actualSpending': instance.actualSpending,
      'isActive': instance.isActive,
      'location': instance.location,
      'contactEmail': instance.contactEmail,
      'contactPhone': instance.contactPhone,
      'customFields': instance.customFields,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'createdById': instance.createdById,
      'metadata': instance.metadata,
    };
