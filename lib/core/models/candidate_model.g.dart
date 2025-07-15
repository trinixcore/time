// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candidate_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CandidateImpl _$$CandidateImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$CandidateImpl', json, ($checkedConvert) {
  final val = _$CandidateImpl(
    id: $checkedConvert('id', (v) => v as String),
    candidateId: $checkedConvert('candidateId', (v) => v as String),
    firstName: $checkedConvert('firstName', (v) => v as String),
    lastName: $checkedConvert('lastName', (v) => v as String),
    email: $checkedConvert('email', (v) => v as String),
    phoneNumber: $checkedConvert('phoneNumber', (v) => v as String),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
    createdBy: $checkedConvert('createdBy', (v) => v as String),
    gender: $checkedConvert('gender', (v) => v as String?),
    dateOfBirth: $checkedConvert(
      'dateOfBirth',
      (v) => const TimestampConverter().fromJson(v),
    ),
    nationality: $checkedConvert('nationality', (v) => v as String?),
    maritalStatus: $checkedConvert('maritalStatus', (v) => v as String?),
    personalEmail: $checkedConvert('personalEmail', (v) => v as String?),
    address: $checkedConvert('address', (v) => v as String?),
    city: $checkedConvert('city', (v) => v as String?),
    state: $checkedConvert('state', (v) => v as String?),
    country: $checkedConvert('country', (v) => v as String?),
    postalCode: $checkedConvert('postalCode', (v) => v as String?),
    department: $checkedConvert('department', (v) => v as String?),
    designation: $checkedConvert('designation', (v) => v as String?),
    position: $checkedConvert('position', (v) => v as String?),
    employmentType: $checkedConvert('employmentType', (v) => v as String?),
    workLocation: $checkedConvert('workLocation', (v) => v as String?),
    offeredSalary: $checkedConvert(
      'offeredSalary',
      (v) => (v as num?)?.toDouble(),
    ),
    salaryGrade: $checkedConvert('salaryGrade', (v) => v as String?),
    expectedJoiningDate: $checkedConvert(
      'expectedJoiningDate',
      (v) => const TimestampConverter().fromJson(v),
    ),
    offerDate: $checkedConvert(
      'offerDate',
      (v) => const TimestampConverter().fromJson(v),
    ),
    acceptanceDate: $checkedConvert(
      'acceptanceDate',
      (v) => const TimestampConverter().fromJson(v),
    ),
    reportingManagerId: $checkedConvert(
      'reportingManagerId',
      (v) => v as String?,
    ),
    hiringManagerId: $checkedConvert('hiringManagerId', (v) => v as String?),
    departmentId: $checkedConvert('departmentId', (v) => v as String?),
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
    offerLetterUrl: $checkedConvert('offerLetterUrl', (v) => v as String?),
    appointmentLetterUrl: $checkedConvert(
      'appointmentLetterUrl',
      (v) => v as String?,
    ),
    status: $checkedConvert('status', (v) => v as String?),
    currentStage: $checkedConvert('currentStage', (v) => v as String?),
    lastStageUpdate: $checkedConvert(
      'lastStageUpdate',
      (v) => const TimestampConverter().fromJson(v),
    ),
    stageUpdatedBy: $checkedConvert('stageUpdatedBy', (v) => v as String?),
    employeeId: $checkedConvert('employeeId', (v) => v as String?),
    userId: $checkedConvert('userId', (v) => v as String?),
    notes: $checkedConvert('notes', (v) => v as String?),
    rejectionReason: $checkedConvert('rejectionReason', (v) => v as String?),
    rejectedAt: $checkedConvert(
      'rejectedAt',
      (v) => const TimestampConverter().fromJson(v),
    ),
    rejectedBy: $checkedConvert('rejectedBy', (v) => v as String?),
    metadata: $checkedConvert('metadata', (v) => v as Map<String, dynamic>?),
  );
  return val;
});

Map<String, dynamic> _$$CandidateImplToJson(
  _$CandidateImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'candidateId': instance.candidateId,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'createdBy': instance.createdBy,
  'gender': instance.gender,
  'dateOfBirth': const TimestampConverter().toJson(instance.dateOfBirth),
  'nationality': instance.nationality,
  'maritalStatus': instance.maritalStatus,
  'personalEmail': instance.personalEmail,
  'address': instance.address,
  'city': instance.city,
  'state': instance.state,
  'country': instance.country,
  'postalCode': instance.postalCode,
  'department': instance.department,
  'designation': instance.designation,
  'position': instance.position,
  'employmentType': instance.employmentType,
  'workLocation': instance.workLocation,
  'offeredSalary': instance.offeredSalary,
  'salaryGrade': instance.salaryGrade,
  'expectedJoiningDate': const TimestampConverter().toJson(
    instance.expectedJoiningDate,
  ),
  'offerDate': const TimestampConverter().toJson(instance.offerDate),
  'acceptanceDate': const TimestampConverter().toJson(instance.acceptanceDate),
  'reportingManagerId': instance.reportingManagerId,
  'hiringManagerId': instance.hiringManagerId,
  'departmentId': instance.departmentId,
  'skills': instance.skills,
  'qualifications': instance.qualifications,
  'certifications': instance.certifications,
  'workExperience': instance.workExperience,
  'documentIds': instance.documentIds,
  'profileImageUrl': instance.profileImageUrl,
  'resumeUrl': instance.resumeUrl,
  'offerLetterUrl': instance.offerLetterUrl,
  'appointmentLetterUrl': instance.appointmentLetterUrl,
  'status': instance.status,
  'currentStage': instance.currentStage,
  'lastStageUpdate': const TimestampConverter().toJson(
    instance.lastStageUpdate,
  ),
  'stageUpdatedBy': instance.stageUpdatedBy,
  'employeeId': instance.employeeId,
  'userId': instance.userId,
  'notes': instance.notes,
  'rejectionReason': instance.rejectionReason,
  'rejectedAt': const TimestampConverter().toJson(instance.rejectedAt),
  'rejectedBy': instance.rejectedBy,
  'metadata': instance.metadata,
};
