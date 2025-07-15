// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$UserImpl', json, ($checkedConvert) {
  final val = _$UserImpl(
    id: $checkedConvert('id', (v) => v as String),
    email: $checkedConvert('email', (v) => v as String),
    firstName: $checkedConvert('firstName', (v) => v as String),
    lastName: $checkedConvert('lastName', (v) => v as String),
    role: $checkedConvert('role', (v) => $enumDecode(_$UserRoleEnumMap, v)),
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(_$EmployeeStatusEnumMap, v),
    ),
    phoneNumber: $checkedConvert('phoneNumber', (v) => v as String?),
    profileImageUrl: $checkedConvert('profileImageUrl', (v) => v as String?),
    department: $checkedConvert('department', (v) => v as String?),
    position: $checkedConvert('position', (v) => v as String?),
    managerId: $checkedConvert('managerId', (v) => v as String?),
    dateOfJoining: $checkedConvert(
      'dateOfJoining',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    lastLoginAt: $checkedConvert(
      'lastLoginAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    isActive: $checkedConvert('isActive', (v) => v as bool? ?? true),
    isEmailVerified: $checkedConvert(
      'isEmailVerified',
      (v) => v as bool? ?? false,
    ),
    isSuperAdmin: $checkedConvert('isSuperAdmin', (v) => v as bool? ?? false),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
    metadata: $checkedConvert('metadata', (v) => v as Map<String, dynamic>?),
  );
  return val;
});

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'role': _$UserRoleEnumMap[instance.role]!,
      'status': _$EmployeeStatusEnumMap[instance.status]!,
      'phoneNumber': instance.phoneNumber,
      'profileImageUrl': instance.profileImageUrl,
      'department': instance.department,
      'position': instance.position,
      'managerId': instance.managerId,
      'dateOfJoining': instance.dateOfJoining?.toIso8601String(),
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
      'isActive': instance.isActive,
      'isEmailVerified': instance.isEmailVerified,
      'isSuperAdmin': instance.isSuperAdmin,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$UserRoleEnumMap = {
  UserRole.sa: 'sa',
  UserRole.admin: 'admin',
  UserRole.hr: 'hr',
  UserRole.manager: 'manager',
  UserRole.tl: 'tl',
  UserRole.se: 'se',
  UserRole.employee: 'employee',
  UserRole.contractor: 'contractor',
  UserRole.intern: 'intern',
  UserRole.vendor: 'vendor',
  UserRole.inactive: 'inactive',
};

const _$EmployeeStatusEnumMap = {
  EmployeeStatus.active: 'active',
  EmployeeStatus.inactive: 'inactive',
  EmployeeStatus.onLeave: 'onLeave',
  EmployeeStatus.suspended: 'suspended',
  EmployeeStatus.terminated: 'terminated',
  EmployeeStatus.probation: 'probation',
  EmployeeStatus.notice: 'notice',
};
