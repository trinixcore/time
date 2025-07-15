// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EmployeeImpl _$$EmployeeImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$EmployeeImpl', json, ($checkedConvert) {
  final val = _$EmployeeImpl(
    id: $checkedConvert('id', (v) => v as String),
    userId: $checkedConvert('userId', (v) => v as String),
    employeeId: $checkedConvert('employeeId', (v) => v as String),
    firstName: $checkedConvert('firstName', (v) => v as String),
    lastName: $checkedConvert('lastName', (v) => v as String),
    email: $checkedConvert('email', (v) => v as String),
    role: $checkedConvert('role', (v) => $enumDecode(_$UserRoleEnumMap, v)),
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(_$EmployeeStatusEnumMap, v),
    ),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
    createdBy: $checkedConvert('createdBy', (v) => v as String),
    phoneNumber: $checkedConvert('phoneNumber', (v) => v as String?),
    emergencyContactName: $checkedConvert(
      'emergencyContactName',
      (v) => v as String?,
    ),
    emergencyContactPhone: $checkedConvert(
      'emergencyContactPhone',
      (v) => v as String?,
    ),
    personalEmail: $checkedConvert('personalEmail', (v) => v as String?),
    address: $checkedConvert('address', (v) => v as String?),
    city: $checkedConvert('city', (v) => v as String?),
    state: $checkedConvert('state', (v) => v as String?),
    country: $checkedConvert('country', (v) => v as String?),
    postalCode: $checkedConvert('postalCode', (v) => v as String?),
    gender: $checkedConvert('gender', (v) => v as String?),
    dateOfBirth: $checkedConvert(
      'dateOfBirth',
      (v) => const TimestampConverter().fromJson(v),
    ),
    nationality: $checkedConvert('nationality', (v) => v as String?),
    maritalStatus: $checkedConvert('maritalStatus', (v) => v as String?),
    department: $checkedConvert('department', (v) => v as String?),
    designation: $checkedConvert('designation', (v) => v as String?),
    position: $checkedConvert('position', (v) => v as String?),
    joiningDate: $checkedConvert(
      'joiningDate',
      (v) => const TimestampConverter().fromJson(v),
    ),
    probationEndDate: $checkedConvert(
      'probationEndDate',
      (v) => const TimestampConverter().fromJson(v),
    ),
    confirmationDate: $checkedConvert(
      'confirmationDate',
      (v) => const TimestampConverter().fromJson(v),
    ),
    terminationDate: $checkedConvert(
      'terminationDate',
      (v) => const TimestampConverter().fromJson(v),
    ),
    employmentType: $checkedConvert('employmentType', (v) => v as String?),
    workLocation: $checkedConvert('workLocation', (v) => v as String?),
    salary: $checkedConvert('salary', (v) => (v as num?)?.toDouble()),
    salaryGrade: $checkedConvert('salaryGrade', (v) => v as String?),
    reportingManagerId: $checkedConvert(
      'reportingManagerId',
      (v) => v as String?,
    ),
    hiringManagerId: $checkedConvert('hiringManagerId', (v) => v as String?),
    departmentId: $checkedConvert('departmentId', (v) => v as String?),
    teamIds: $checkedConvert(
      'teamIds',
      (v) =>
          (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    ),
    projectIds: $checkedConvert(
      'projectIds',
      (v) =>
          (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    ),
    subordinateIds: $checkedConvert(
      'subordinateIds',
      (v) =>
          (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    ),
    skills: $checkedConvert(
      'skills',
      (v) =>
          (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    ),
    qualifications: $checkedConvert(
      'qualifications',
      (v) =>
          (v as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
    ),
    certifications: $checkedConvert(
      'certifications',
      (v) =>
          (v as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
    ),
    workExperience: $checkedConvert(
      'workExperience',
      (v) =>
          (v as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
    ),
    documentIds: $checkedConvert(
      'documentIds',
      (v) =>
          (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    ),
    profileImageUrl: $checkedConvert('profileImageUrl', (v) => v as String?),
    resumeUrl: $checkedConvert('resumeUrl', (v) => v as String?),
    performanceRating: $checkedConvert(
      'performanceRating',
      (v) => (v as num?)?.toDouble(),
    ),
    lastPerformanceReview: $checkedConvert(
      'lastPerformanceReview',
      (v) => const TimestampConverter().fromJson(v),
    ),
    totalLeaveDays: $checkedConvert(
      'totalLeaveDays',
      (v) => (v as num?)?.toInt(),
    ),
    usedLeaveDays: $checkedConvert(
      'usedLeaveDays',
      (v) => (v as num?)?.toInt(),
    ),
    attendancePercentage: $checkedConvert(
      'attendancePercentage',
      (v) => (v as num?)?.toDouble(),
    ),
    lastLoginAt: $checkedConvert(
      'lastLoginAt',
      (v) => const TimestampConverter().fromJson(v),
    ),
    lastUpdatedBy: $checkedConvert(
      'lastUpdatedBy',
      (v) => const TimestampConverter().fromJson(v),
    ),
    updatedBy: $checkedConvert('updatedBy', (v) => v as String?),
    isActive: $checkedConvert('isActive', (v) => v as bool?),
    customFields: $checkedConvert(
      'customFields',
      (v) => v as Map<String, dynamic>?,
    ),
    metadata: $checkedConvert('metadata', (v) => v as Map<String, dynamic>?),
    auditLog: $checkedConvert(
      'auditLog',
      (v) =>
          (v as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
    ),
  );
  return val;
});

Map<String, dynamic> _$$EmployeeImplToJson(
  _$EmployeeImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'employeeId': instance.employeeId,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'email': instance.email,
  'role': _$UserRoleEnumMap[instance.role]!,
  'status': _$EmployeeStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'createdBy': instance.createdBy,
  'phoneNumber': instance.phoneNumber,
  'emergencyContactName': instance.emergencyContactName,
  'emergencyContactPhone': instance.emergencyContactPhone,
  'personalEmail': instance.personalEmail,
  'address': instance.address,
  'city': instance.city,
  'state': instance.state,
  'country': instance.country,
  'postalCode': instance.postalCode,
  'gender': instance.gender,
  'dateOfBirth': const TimestampConverter().toJson(instance.dateOfBirth),
  'nationality': instance.nationality,
  'maritalStatus': instance.maritalStatus,
  'department': instance.department,
  'designation': instance.designation,
  'position': instance.position,
  'joiningDate': const TimestampConverter().toJson(instance.joiningDate),
  'probationEndDate': const TimestampConverter().toJson(
    instance.probationEndDate,
  ),
  'confirmationDate': const TimestampConverter().toJson(
    instance.confirmationDate,
  ),
  'terminationDate': const TimestampConverter().toJson(
    instance.terminationDate,
  ),
  'employmentType': instance.employmentType,
  'workLocation': instance.workLocation,
  'salary': instance.salary,
  'salaryGrade': instance.salaryGrade,
  'reportingManagerId': instance.reportingManagerId,
  'hiringManagerId': instance.hiringManagerId,
  'departmentId': instance.departmentId,
  'teamIds': instance.teamIds,
  'projectIds': instance.projectIds,
  'subordinateIds': instance.subordinateIds,
  'skills': instance.skills,
  'qualifications': instance.qualifications,
  'certifications': instance.certifications,
  'workExperience': instance.workExperience,
  'documentIds': instance.documentIds,
  'profileImageUrl': instance.profileImageUrl,
  'resumeUrl': instance.resumeUrl,
  'performanceRating': instance.performanceRating,
  'lastPerformanceReview': const TimestampConverter().toJson(
    instance.lastPerformanceReview,
  ),
  'totalLeaveDays': instance.totalLeaveDays,
  'usedLeaveDays': instance.usedLeaveDays,
  'attendancePercentage': instance.attendancePercentage,
  'lastLoginAt': const TimestampConverter().toJson(instance.lastLoginAt),
  'lastUpdatedBy': const TimestampConverter().toJson(instance.lastUpdatedBy),
  'updatedBy': instance.updatedBy,
  'isActive': instance.isActive,
  'customFields': instance.customFields,
  'metadata': instance.metadata,
  'auditLog': instance.auditLog,
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
