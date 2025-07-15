// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$UserModelImpl', json, ($checkedConvert) {
  final val = _$UserModelImpl(
    uid: $checkedConvert('uid', (v) => v as String),
    email: $checkedConvert('email', (v) => v as String),
    displayName: $checkedConvert('displayName', (v) => v as String),
    role: $checkedConvert(
      'role',
      (v) => const UserRoleConverter().fromJson(v as String),
    ),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
    isActive: $checkedConvert('isActive', (v) => v as bool),
    photoUrl: $checkedConvert('photoUrl', (v) => v as String?),
    phoneNumber: $checkedConvert('phoneNumber', (v) => v as String?),
    department: $checkedConvert('department', (v) => v as String?),
    position: $checkedConvert('position', (v) => v as String?),
    employeeId: $checkedConvert('employeeId', (v) => v as String?),
    lastLoginAt: $checkedConvert(
      'lastLoginAt',
      (v) => const TimestampConverter().fromJson(v),
    ),
    mfaEnabled: $checkedConvert('mfaEnabled', (v) => v as bool?),
    createdBy: $checkedConvert('createdBy', (v) => v as String?),
    terminationDate: $checkedConvert(
      'terminationDate',
      (v) => const TimestampConverter().fromJson(v),
    ),
    terminationReason: $checkedConvert(
      'terminationReason',
      (v) => v as String?,
    ),
    terminationComments: $checkedConvert(
      'terminationComments',
      (v) => v as String?,
    ),
    terminatedBy: $checkedConvert('terminatedBy', (v) => v as String?),
    lastWorkingDay: $checkedConvert(
      'lastWorkingDay',
      (v) => const TimestampConverter().fromJson(v),
    ),
    reactivationDate: $checkedConvert(
      'reactivationDate',
      (v) => const TimestampConverter().fromJson(v),
    ),
    reactivationReason: $checkedConvert(
      'reactivationReason',
      (v) => v as String?,
    ),
    reactivationComments: $checkedConvert(
      'reactivationComments',
      (v) => v as String?,
    ),
    reactivatedBy: $checkedConvert('reactivatedBy', (v) => v as String?),
    candidateId: $checkedConvert('candidateId', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$$UserModelImplToJson(
  _$UserModelImpl instance,
) => <String, dynamic>{
  'uid': instance.uid,
  'email': instance.email,
  'displayName': instance.displayName,
  'role': const UserRoleConverter().toJson(instance.role),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'isActive': instance.isActive,
  'photoUrl': instance.photoUrl,
  'phoneNumber': instance.phoneNumber,
  'department': instance.department,
  'position': instance.position,
  'employeeId': instance.employeeId,
  'lastLoginAt': const TimestampConverter().toJson(instance.lastLoginAt),
  'mfaEnabled': instance.mfaEnabled,
  'createdBy': instance.createdBy,
  'terminationDate': const TimestampConverter().toJson(
    instance.terminationDate,
  ),
  'terminationReason': instance.terminationReason,
  'terminationComments': instance.terminationComments,
  'terminatedBy': instance.terminatedBy,
  'lastWorkingDay': const TimestampConverter().toJson(instance.lastWorkingDay),
  'reactivationDate': const TimestampConverter().toJson(
    instance.reactivationDate,
  ),
  'reactivationReason': instance.reactivationReason,
  'reactivationComments': instance.reactivationComments,
  'reactivatedBy': instance.reactivatedBy,
  'candidateId': instance.candidateId,
};
