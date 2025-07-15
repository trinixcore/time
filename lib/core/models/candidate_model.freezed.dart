// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'candidate_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Candidate _$CandidateFromJson(Map<String, dynamic> json) {
  return _Candidate.fromJson(json);
}

/// @nodoc
mixin _$Candidate {
  String get id => throw _privateConstructorUsedError;
  String get candidateId =>
      throw _privateConstructorUsedError; // CND2024000001 format
  String get firstName => throw _privateConstructorUsedError;
  String get lastName => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get phoneNumber => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String get createdBy =>
      throw _privateConstructorUsedError; // Personal Information
  String? get gender => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get dateOfBirth => throw _privateConstructorUsedError;
  String? get nationality => throw _privateConstructorUsedError;
  String? get maritalStatus => throw _privateConstructorUsedError;
  String? get personalEmail =>
      throw _privateConstructorUsedError; // Address Information
  String? get address => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get state => throw _privateConstructorUsedError;
  String? get country => throw _privateConstructorUsedError;
  String? get postalCode =>
      throw _privateConstructorUsedError; // Employment Information
  String? get department => throw _privateConstructorUsedError;
  String? get designation => throw _privateConstructorUsedError;
  String? get position => throw _privateConstructorUsedError;
  String? get employmentType =>
      throw _privateConstructorUsedError; // Full-time, Part-time, Contract, Intern
  String? get workLocation =>
      throw _privateConstructorUsedError; // Office, Remote, Hybrid
  double? get offeredSalary => throw _privateConstructorUsedError;
  String? get salaryGrade => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get expectedJoiningDate => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get offerDate => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get acceptanceDate => throw _privateConstructorUsedError; // Organizational Structure
  String? get reportingManagerId => throw _privateConstructorUsedError;
  String? get hiringManagerId => throw _privateConstructorUsedError;
  String? get departmentId =>
      throw _privateConstructorUsedError; // Skills and Qualifications
  List<String> get skills => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get qualifications =>
      throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get certifications =>
      throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get workExperience =>
      throw _privateConstructorUsedError; // Documents
  List<String> get documentIds => throw _privateConstructorUsedError;
  String? get profileImageUrl => throw _privateConstructorUsedError;
  String? get resumeUrl => throw _privateConstructorUsedError;
  String? get offerLetterUrl => throw _privateConstructorUsedError;
  String? get appointmentLetterUrl =>
      throw _privateConstructorUsedError; // Status and Workflow
  String? get status =>
      throw _privateConstructorUsedError; // "applied", "interviewed", "offered", "accepted", "onboarded"
  String? get currentStage =>
      throw _privateConstructorUsedError; // "screening", "interview", "offer", "onboarding"
  @TimestampConverter()
  DateTime? get lastStageUpdate => throw _privateConstructorUsedError;
  String? get stageUpdatedBy =>
      throw _privateConstructorUsedError; // Employee ID (assigned after onboarding)
  String? get employeeId => throw _privateConstructorUsedError;
  String? get userId =>
      throw _privateConstructorUsedError; // Firebase Auth user ID (assigned after user creation)
  // Additional metadata
  String? get notes => throw _privateConstructorUsedError;
  String? get rejectionReason => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get rejectedAt => throw _privateConstructorUsedError;
  String? get rejectedBy => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this Candidate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Candidate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CandidateCopyWith<Candidate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CandidateCopyWith<$Res> {
  factory $CandidateCopyWith(Candidate value, $Res Function(Candidate) then) =
      _$CandidateCopyWithImpl<$Res, Candidate>;
  @useResult
  $Res call({
    String id,
    String candidateId,
    String firstName,
    String lastName,
    String email,
    String phoneNumber,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime updatedAt,
    String createdBy,
    String? gender,
    @TimestampConverter() DateTime? dateOfBirth,
    String? nationality,
    String? maritalStatus,
    String? personalEmail,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? department,
    String? designation,
    String? position,
    String? employmentType,
    String? workLocation,
    double? offeredSalary,
    String? salaryGrade,
    @TimestampConverter() DateTime? expectedJoiningDate,
    @TimestampConverter() DateTime? offerDate,
    @TimestampConverter() DateTime? acceptanceDate,
    String? reportingManagerId,
    String? hiringManagerId,
    String? departmentId,
    List<String> skills,
    List<Map<String, dynamic>> qualifications,
    List<Map<String, dynamic>> certifications,
    List<Map<String, dynamic>> workExperience,
    List<String> documentIds,
    String? profileImageUrl,
    String? resumeUrl,
    String? offerLetterUrl,
    String? appointmentLetterUrl,
    String? status,
    String? currentStage,
    @TimestampConverter() DateTime? lastStageUpdate,
    String? stageUpdatedBy,
    String? employeeId,
    String? userId,
    String? notes,
    String? rejectionReason,
    @TimestampConverter() DateTime? rejectedAt,
    String? rejectedBy,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$CandidateCopyWithImpl<$Res, $Val extends Candidate>
    implements $CandidateCopyWith<$Res> {
  _$CandidateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Candidate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? candidateId = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? email = null,
    Object? phoneNumber = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? createdBy = null,
    Object? gender = freezed,
    Object? dateOfBirth = freezed,
    Object? nationality = freezed,
    Object? maritalStatus = freezed,
    Object? personalEmail = freezed,
    Object? address = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? country = freezed,
    Object? postalCode = freezed,
    Object? department = freezed,
    Object? designation = freezed,
    Object? position = freezed,
    Object? employmentType = freezed,
    Object? workLocation = freezed,
    Object? offeredSalary = freezed,
    Object? salaryGrade = freezed,
    Object? expectedJoiningDate = freezed,
    Object? offerDate = freezed,
    Object? acceptanceDate = freezed,
    Object? reportingManagerId = freezed,
    Object? hiringManagerId = freezed,
    Object? departmentId = freezed,
    Object? skills = null,
    Object? qualifications = null,
    Object? certifications = null,
    Object? workExperience = null,
    Object? documentIds = null,
    Object? profileImageUrl = freezed,
    Object? resumeUrl = freezed,
    Object? offerLetterUrl = freezed,
    Object? appointmentLetterUrl = freezed,
    Object? status = freezed,
    Object? currentStage = freezed,
    Object? lastStageUpdate = freezed,
    Object? stageUpdatedBy = freezed,
    Object? employeeId = freezed,
    Object? userId = freezed,
    Object? notes = freezed,
    Object? rejectionReason = freezed,
    Object? rejectedAt = freezed,
    Object? rejectedBy = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            candidateId:
                null == candidateId
                    ? _value.candidateId
                    : candidateId // ignore: cast_nullable_to_non_nullable
                        as String,
            firstName:
                null == firstName
                    ? _value.firstName
                    : firstName // ignore: cast_nullable_to_non_nullable
                        as String,
            lastName:
                null == lastName
                    ? _value.lastName
                    : lastName // ignore: cast_nullable_to_non_nullable
                        as String,
            email:
                null == email
                    ? _value.email
                    : email // ignore: cast_nullable_to_non_nullable
                        as String,
            phoneNumber:
                null == phoneNumber
                    ? _value.phoneNumber
                    : phoneNumber // ignore: cast_nullable_to_non_nullable
                        as String,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            updatedAt:
                null == updatedAt
                    ? _value.updatedAt
                    : updatedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            createdBy:
                null == createdBy
                    ? _value.createdBy
                    : createdBy // ignore: cast_nullable_to_non_nullable
                        as String,
            gender:
                freezed == gender
                    ? _value.gender
                    : gender // ignore: cast_nullable_to_non_nullable
                        as String?,
            dateOfBirth:
                freezed == dateOfBirth
                    ? _value.dateOfBirth
                    : dateOfBirth // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            nationality:
                freezed == nationality
                    ? _value.nationality
                    : nationality // ignore: cast_nullable_to_non_nullable
                        as String?,
            maritalStatus:
                freezed == maritalStatus
                    ? _value.maritalStatus
                    : maritalStatus // ignore: cast_nullable_to_non_nullable
                        as String?,
            personalEmail:
                freezed == personalEmail
                    ? _value.personalEmail
                    : personalEmail // ignore: cast_nullable_to_non_nullable
                        as String?,
            address:
                freezed == address
                    ? _value.address
                    : address // ignore: cast_nullable_to_non_nullable
                        as String?,
            city:
                freezed == city
                    ? _value.city
                    : city // ignore: cast_nullable_to_non_nullable
                        as String?,
            state:
                freezed == state
                    ? _value.state
                    : state // ignore: cast_nullable_to_non_nullable
                        as String?,
            country:
                freezed == country
                    ? _value.country
                    : country // ignore: cast_nullable_to_non_nullable
                        as String?,
            postalCode:
                freezed == postalCode
                    ? _value.postalCode
                    : postalCode // ignore: cast_nullable_to_non_nullable
                        as String?,
            department:
                freezed == department
                    ? _value.department
                    : department // ignore: cast_nullable_to_non_nullable
                        as String?,
            designation:
                freezed == designation
                    ? _value.designation
                    : designation // ignore: cast_nullable_to_non_nullable
                        as String?,
            position:
                freezed == position
                    ? _value.position
                    : position // ignore: cast_nullable_to_non_nullable
                        as String?,
            employmentType:
                freezed == employmentType
                    ? _value.employmentType
                    : employmentType // ignore: cast_nullable_to_non_nullable
                        as String?,
            workLocation:
                freezed == workLocation
                    ? _value.workLocation
                    : workLocation // ignore: cast_nullable_to_non_nullable
                        as String?,
            offeredSalary:
                freezed == offeredSalary
                    ? _value.offeredSalary
                    : offeredSalary // ignore: cast_nullable_to_non_nullable
                        as double?,
            salaryGrade:
                freezed == salaryGrade
                    ? _value.salaryGrade
                    : salaryGrade // ignore: cast_nullable_to_non_nullable
                        as String?,
            expectedJoiningDate:
                freezed == expectedJoiningDate
                    ? _value.expectedJoiningDate
                    : expectedJoiningDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            offerDate:
                freezed == offerDate
                    ? _value.offerDate
                    : offerDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            acceptanceDate:
                freezed == acceptanceDate
                    ? _value.acceptanceDate
                    : acceptanceDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            reportingManagerId:
                freezed == reportingManagerId
                    ? _value.reportingManagerId
                    : reportingManagerId // ignore: cast_nullable_to_non_nullable
                        as String?,
            hiringManagerId:
                freezed == hiringManagerId
                    ? _value.hiringManagerId
                    : hiringManagerId // ignore: cast_nullable_to_non_nullable
                        as String?,
            departmentId:
                freezed == departmentId
                    ? _value.departmentId
                    : departmentId // ignore: cast_nullable_to_non_nullable
                        as String?,
            skills:
                null == skills
                    ? _value.skills
                    : skills // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            qualifications:
                null == qualifications
                    ? _value.qualifications
                    : qualifications // ignore: cast_nullable_to_non_nullable
                        as List<Map<String, dynamic>>,
            certifications:
                null == certifications
                    ? _value.certifications
                    : certifications // ignore: cast_nullable_to_non_nullable
                        as List<Map<String, dynamic>>,
            workExperience:
                null == workExperience
                    ? _value.workExperience
                    : workExperience // ignore: cast_nullable_to_non_nullable
                        as List<Map<String, dynamic>>,
            documentIds:
                null == documentIds
                    ? _value.documentIds
                    : documentIds // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            profileImageUrl:
                freezed == profileImageUrl
                    ? _value.profileImageUrl
                    : profileImageUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
            resumeUrl:
                freezed == resumeUrl
                    ? _value.resumeUrl
                    : resumeUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
            offerLetterUrl:
                freezed == offerLetterUrl
                    ? _value.offerLetterUrl
                    : offerLetterUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
            appointmentLetterUrl:
                freezed == appointmentLetterUrl
                    ? _value.appointmentLetterUrl
                    : appointmentLetterUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
            status:
                freezed == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String?,
            currentStage:
                freezed == currentStage
                    ? _value.currentStage
                    : currentStage // ignore: cast_nullable_to_non_nullable
                        as String?,
            lastStageUpdate:
                freezed == lastStageUpdate
                    ? _value.lastStageUpdate
                    : lastStageUpdate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            stageUpdatedBy:
                freezed == stageUpdatedBy
                    ? _value.stageUpdatedBy
                    : stageUpdatedBy // ignore: cast_nullable_to_non_nullable
                        as String?,
            employeeId:
                freezed == employeeId
                    ? _value.employeeId
                    : employeeId // ignore: cast_nullable_to_non_nullable
                        as String?,
            userId:
                freezed == userId
                    ? _value.userId
                    : userId // ignore: cast_nullable_to_non_nullable
                        as String?,
            notes:
                freezed == notes
                    ? _value.notes
                    : notes // ignore: cast_nullable_to_non_nullable
                        as String?,
            rejectionReason:
                freezed == rejectionReason
                    ? _value.rejectionReason
                    : rejectionReason // ignore: cast_nullable_to_non_nullable
                        as String?,
            rejectedAt:
                freezed == rejectedAt
                    ? _value.rejectedAt
                    : rejectedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            rejectedBy:
                freezed == rejectedBy
                    ? _value.rejectedBy
                    : rejectedBy // ignore: cast_nullable_to_non_nullable
                        as String?,
            metadata:
                freezed == metadata
                    ? _value.metadata
                    : metadata // ignore: cast_nullable_to_non_nullable
                        as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CandidateImplCopyWith<$Res>
    implements $CandidateCopyWith<$Res> {
  factory _$$CandidateImplCopyWith(
    _$CandidateImpl value,
    $Res Function(_$CandidateImpl) then,
  ) = __$$CandidateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String candidateId,
    String firstName,
    String lastName,
    String email,
    String phoneNumber,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime updatedAt,
    String createdBy,
    String? gender,
    @TimestampConverter() DateTime? dateOfBirth,
    String? nationality,
    String? maritalStatus,
    String? personalEmail,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? department,
    String? designation,
    String? position,
    String? employmentType,
    String? workLocation,
    double? offeredSalary,
    String? salaryGrade,
    @TimestampConverter() DateTime? expectedJoiningDate,
    @TimestampConverter() DateTime? offerDate,
    @TimestampConverter() DateTime? acceptanceDate,
    String? reportingManagerId,
    String? hiringManagerId,
    String? departmentId,
    List<String> skills,
    List<Map<String, dynamic>> qualifications,
    List<Map<String, dynamic>> certifications,
    List<Map<String, dynamic>> workExperience,
    List<String> documentIds,
    String? profileImageUrl,
    String? resumeUrl,
    String? offerLetterUrl,
    String? appointmentLetterUrl,
    String? status,
    String? currentStage,
    @TimestampConverter() DateTime? lastStageUpdate,
    String? stageUpdatedBy,
    String? employeeId,
    String? userId,
    String? notes,
    String? rejectionReason,
    @TimestampConverter() DateTime? rejectedAt,
    String? rejectedBy,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$CandidateImplCopyWithImpl<$Res>
    extends _$CandidateCopyWithImpl<$Res, _$CandidateImpl>
    implements _$$CandidateImplCopyWith<$Res> {
  __$$CandidateImplCopyWithImpl(
    _$CandidateImpl _value,
    $Res Function(_$CandidateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Candidate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? candidateId = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? email = null,
    Object? phoneNumber = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? createdBy = null,
    Object? gender = freezed,
    Object? dateOfBirth = freezed,
    Object? nationality = freezed,
    Object? maritalStatus = freezed,
    Object? personalEmail = freezed,
    Object? address = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? country = freezed,
    Object? postalCode = freezed,
    Object? department = freezed,
    Object? designation = freezed,
    Object? position = freezed,
    Object? employmentType = freezed,
    Object? workLocation = freezed,
    Object? offeredSalary = freezed,
    Object? salaryGrade = freezed,
    Object? expectedJoiningDate = freezed,
    Object? offerDate = freezed,
    Object? acceptanceDate = freezed,
    Object? reportingManagerId = freezed,
    Object? hiringManagerId = freezed,
    Object? departmentId = freezed,
    Object? skills = null,
    Object? qualifications = null,
    Object? certifications = null,
    Object? workExperience = null,
    Object? documentIds = null,
    Object? profileImageUrl = freezed,
    Object? resumeUrl = freezed,
    Object? offerLetterUrl = freezed,
    Object? appointmentLetterUrl = freezed,
    Object? status = freezed,
    Object? currentStage = freezed,
    Object? lastStageUpdate = freezed,
    Object? stageUpdatedBy = freezed,
    Object? employeeId = freezed,
    Object? userId = freezed,
    Object? notes = freezed,
    Object? rejectionReason = freezed,
    Object? rejectedAt = freezed,
    Object? rejectedBy = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$CandidateImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        candidateId:
            null == candidateId
                ? _value.candidateId
                : candidateId // ignore: cast_nullable_to_non_nullable
                    as String,
        firstName:
            null == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                    as String,
        lastName:
            null == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                    as String,
        email:
            null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                    as String,
        phoneNumber:
            null == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                    as String,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        updatedAt:
            null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        createdBy:
            null == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                    as String,
        gender:
            freezed == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                    as String?,
        dateOfBirth:
            freezed == dateOfBirth
                ? _value.dateOfBirth
                : dateOfBirth // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        nationality:
            freezed == nationality
                ? _value.nationality
                : nationality // ignore: cast_nullable_to_non_nullable
                    as String?,
        maritalStatus:
            freezed == maritalStatus
                ? _value.maritalStatus
                : maritalStatus // ignore: cast_nullable_to_non_nullable
                    as String?,
        personalEmail:
            freezed == personalEmail
                ? _value.personalEmail
                : personalEmail // ignore: cast_nullable_to_non_nullable
                    as String?,
        address:
            freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                    as String?,
        city:
            freezed == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                    as String?,
        state:
            freezed == state
                ? _value.state
                : state // ignore: cast_nullable_to_non_nullable
                    as String?,
        country:
            freezed == country
                ? _value.country
                : country // ignore: cast_nullable_to_non_nullable
                    as String?,
        postalCode:
            freezed == postalCode
                ? _value.postalCode
                : postalCode // ignore: cast_nullable_to_non_nullable
                    as String?,
        department:
            freezed == department
                ? _value.department
                : department // ignore: cast_nullable_to_non_nullable
                    as String?,
        designation:
            freezed == designation
                ? _value.designation
                : designation // ignore: cast_nullable_to_non_nullable
                    as String?,
        position:
            freezed == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                    as String?,
        employmentType:
            freezed == employmentType
                ? _value.employmentType
                : employmentType // ignore: cast_nullable_to_non_nullable
                    as String?,
        workLocation:
            freezed == workLocation
                ? _value.workLocation
                : workLocation // ignore: cast_nullable_to_non_nullable
                    as String?,
        offeredSalary:
            freezed == offeredSalary
                ? _value.offeredSalary
                : offeredSalary // ignore: cast_nullable_to_non_nullable
                    as double?,
        salaryGrade:
            freezed == salaryGrade
                ? _value.salaryGrade
                : salaryGrade // ignore: cast_nullable_to_non_nullable
                    as String?,
        expectedJoiningDate:
            freezed == expectedJoiningDate
                ? _value.expectedJoiningDate
                : expectedJoiningDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        offerDate:
            freezed == offerDate
                ? _value.offerDate
                : offerDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        acceptanceDate:
            freezed == acceptanceDate
                ? _value.acceptanceDate
                : acceptanceDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        reportingManagerId:
            freezed == reportingManagerId
                ? _value.reportingManagerId
                : reportingManagerId // ignore: cast_nullable_to_non_nullable
                    as String?,
        hiringManagerId:
            freezed == hiringManagerId
                ? _value.hiringManagerId
                : hiringManagerId // ignore: cast_nullable_to_non_nullable
                    as String?,
        departmentId:
            freezed == departmentId
                ? _value.departmentId
                : departmentId // ignore: cast_nullable_to_non_nullable
                    as String?,
        skills:
            null == skills
                ? _value._skills
                : skills // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        qualifications:
            null == qualifications
                ? _value._qualifications
                : qualifications // ignore: cast_nullable_to_non_nullable
                    as List<Map<String, dynamic>>,
        certifications:
            null == certifications
                ? _value._certifications
                : certifications // ignore: cast_nullable_to_non_nullable
                    as List<Map<String, dynamic>>,
        workExperience:
            null == workExperience
                ? _value._workExperience
                : workExperience // ignore: cast_nullable_to_non_nullable
                    as List<Map<String, dynamic>>,
        documentIds:
            null == documentIds
                ? _value._documentIds
                : documentIds // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        profileImageUrl:
            freezed == profileImageUrl
                ? _value.profileImageUrl
                : profileImageUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
        resumeUrl:
            freezed == resumeUrl
                ? _value.resumeUrl
                : resumeUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
        offerLetterUrl:
            freezed == offerLetterUrl
                ? _value.offerLetterUrl
                : offerLetterUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
        appointmentLetterUrl:
            freezed == appointmentLetterUrl
                ? _value.appointmentLetterUrl
                : appointmentLetterUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
        status:
            freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String?,
        currentStage:
            freezed == currentStage
                ? _value.currentStage
                : currentStage // ignore: cast_nullable_to_non_nullable
                    as String?,
        lastStageUpdate:
            freezed == lastStageUpdate
                ? _value.lastStageUpdate
                : lastStageUpdate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        stageUpdatedBy:
            freezed == stageUpdatedBy
                ? _value.stageUpdatedBy
                : stageUpdatedBy // ignore: cast_nullable_to_non_nullable
                    as String?,
        employeeId:
            freezed == employeeId
                ? _value.employeeId
                : employeeId // ignore: cast_nullable_to_non_nullable
                    as String?,
        userId:
            freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                    as String?,
        notes:
            freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                    as String?,
        rejectionReason:
            freezed == rejectionReason
                ? _value.rejectionReason
                : rejectionReason // ignore: cast_nullable_to_non_nullable
                    as String?,
        rejectedAt:
            freezed == rejectedAt
                ? _value.rejectedAt
                : rejectedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        rejectedBy:
            freezed == rejectedBy
                ? _value.rejectedBy
                : rejectedBy // ignore: cast_nullable_to_non_nullable
                    as String?,
        metadata:
            freezed == metadata
                ? _value._metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                    as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CandidateImpl extends _Candidate {
  const _$CandidateImpl({
    required this.id,
    required this.candidateId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    @TimestampConverter() required this.createdAt,
    @TimestampConverter() required this.updatedAt,
    required this.createdBy,
    this.gender,
    @TimestampConverter() this.dateOfBirth,
    this.nationality,
    this.maritalStatus,
    this.personalEmail,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.department,
    this.designation,
    this.position,
    this.employmentType,
    this.workLocation,
    this.offeredSalary,
    this.salaryGrade,
    @TimestampConverter() this.expectedJoiningDate,
    @TimestampConverter() this.offerDate,
    @TimestampConverter() this.acceptanceDate,
    this.reportingManagerId,
    this.hiringManagerId,
    this.departmentId,
    final List<String> skills = const [],
    final List<Map<String, dynamic>> qualifications = const [],
    final List<Map<String, dynamic>> certifications = const [],
    final List<Map<String, dynamic>> workExperience = const [],
    final List<String> documentIds = const [],
    this.profileImageUrl,
    this.resumeUrl,
    this.offerLetterUrl,
    this.appointmentLetterUrl,
    this.status,
    this.currentStage,
    @TimestampConverter() this.lastStageUpdate,
    this.stageUpdatedBy,
    this.employeeId,
    this.userId,
    this.notes,
    this.rejectionReason,
    @TimestampConverter() this.rejectedAt,
    this.rejectedBy,
    final Map<String, dynamic>? metadata,
  }) : _skills = skills,
       _qualifications = qualifications,
       _certifications = certifications,
       _workExperience = workExperience,
       _documentIds = documentIds,
       _metadata = metadata,
       super._();

  factory _$CandidateImpl.fromJson(Map<String, dynamic> json) =>
      _$$CandidateImplFromJson(json);

  @override
  final String id;
  @override
  final String candidateId;
  // CND2024000001 format
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final String email;
  @override
  final String phoneNumber;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime updatedAt;
  @override
  final String createdBy;
  // Personal Information
  @override
  final String? gender;
  @override
  @TimestampConverter()
  final DateTime? dateOfBirth;
  @override
  final String? nationality;
  @override
  final String? maritalStatus;
  @override
  final String? personalEmail;
  // Address Information
  @override
  final String? address;
  @override
  final String? city;
  @override
  final String? state;
  @override
  final String? country;
  @override
  final String? postalCode;
  // Employment Information
  @override
  final String? department;
  @override
  final String? designation;
  @override
  final String? position;
  @override
  final String? employmentType;
  // Full-time, Part-time, Contract, Intern
  @override
  final String? workLocation;
  // Office, Remote, Hybrid
  @override
  final double? offeredSalary;
  @override
  final String? salaryGrade;
  @override
  @TimestampConverter()
  final DateTime? expectedJoiningDate;
  @override
  @TimestampConverter()
  final DateTime? offerDate;
  @override
  @TimestampConverter()
  final DateTime? acceptanceDate;
  // Organizational Structure
  @override
  final String? reportingManagerId;
  @override
  final String? hiringManagerId;
  @override
  final String? departmentId;
  // Skills and Qualifications
  final List<String> _skills;
  // Skills and Qualifications
  @override
  @JsonKey()
  List<String> get skills {
    if (_skills is EqualUnmodifiableListView) return _skills;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_skills);
  }

  final List<Map<String, dynamic>> _qualifications;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get qualifications {
    if (_qualifications is EqualUnmodifiableListView) return _qualifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_qualifications);
  }

  final List<Map<String, dynamic>> _certifications;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get certifications {
    if (_certifications is EqualUnmodifiableListView) return _certifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_certifications);
  }

  final List<Map<String, dynamic>> _workExperience;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get workExperience {
    if (_workExperience is EqualUnmodifiableListView) return _workExperience;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_workExperience);
  }

  // Documents
  final List<String> _documentIds;
  // Documents
  @override
  @JsonKey()
  List<String> get documentIds {
    if (_documentIds is EqualUnmodifiableListView) return _documentIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_documentIds);
  }

  @override
  final String? profileImageUrl;
  @override
  final String? resumeUrl;
  @override
  final String? offerLetterUrl;
  @override
  final String? appointmentLetterUrl;
  // Status and Workflow
  @override
  final String? status;
  // "applied", "interviewed", "offered", "accepted", "onboarded"
  @override
  final String? currentStage;
  // "screening", "interview", "offer", "onboarding"
  @override
  @TimestampConverter()
  final DateTime? lastStageUpdate;
  @override
  final String? stageUpdatedBy;
  // Employee ID (assigned after onboarding)
  @override
  final String? employeeId;
  @override
  final String? userId;
  // Firebase Auth user ID (assigned after user creation)
  // Additional metadata
  @override
  final String? notes;
  @override
  final String? rejectionReason;
  @override
  @TimestampConverter()
  final DateTime? rejectedAt;
  @override
  final String? rejectedBy;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'Candidate(id: $id, candidateId: $candidateId, firstName: $firstName, lastName: $lastName, email: $email, phoneNumber: $phoneNumber, createdAt: $createdAt, updatedAt: $updatedAt, createdBy: $createdBy, gender: $gender, dateOfBirth: $dateOfBirth, nationality: $nationality, maritalStatus: $maritalStatus, personalEmail: $personalEmail, address: $address, city: $city, state: $state, country: $country, postalCode: $postalCode, department: $department, designation: $designation, position: $position, employmentType: $employmentType, workLocation: $workLocation, offeredSalary: $offeredSalary, salaryGrade: $salaryGrade, expectedJoiningDate: $expectedJoiningDate, offerDate: $offerDate, acceptanceDate: $acceptanceDate, reportingManagerId: $reportingManagerId, hiringManagerId: $hiringManagerId, departmentId: $departmentId, skills: $skills, qualifications: $qualifications, certifications: $certifications, workExperience: $workExperience, documentIds: $documentIds, profileImageUrl: $profileImageUrl, resumeUrl: $resumeUrl, offerLetterUrl: $offerLetterUrl, appointmentLetterUrl: $appointmentLetterUrl, status: $status, currentStage: $currentStage, lastStageUpdate: $lastStageUpdate, stageUpdatedBy: $stageUpdatedBy, employeeId: $employeeId, userId: $userId, notes: $notes, rejectionReason: $rejectionReason, rejectedAt: $rejectedAt, rejectedBy: $rejectedBy, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CandidateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.candidateId, candidateId) ||
                other.candidateId == candidateId) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.nationality, nationality) ||
                other.nationality == nationality) &&
            (identical(other.maritalStatus, maritalStatus) ||
                other.maritalStatus == maritalStatus) &&
            (identical(other.personalEmail, personalEmail) ||
                other.personalEmail == personalEmail) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.postalCode, postalCode) ||
                other.postalCode == postalCode) &&
            (identical(other.department, department) ||
                other.department == department) &&
            (identical(other.designation, designation) ||
                other.designation == designation) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.employmentType, employmentType) ||
                other.employmentType == employmentType) &&
            (identical(other.workLocation, workLocation) ||
                other.workLocation == workLocation) &&
            (identical(other.offeredSalary, offeredSalary) ||
                other.offeredSalary == offeredSalary) &&
            (identical(other.salaryGrade, salaryGrade) ||
                other.salaryGrade == salaryGrade) &&
            (identical(other.expectedJoiningDate, expectedJoiningDate) ||
                other.expectedJoiningDate == expectedJoiningDate) &&
            (identical(other.offerDate, offerDate) ||
                other.offerDate == offerDate) &&
            (identical(other.acceptanceDate, acceptanceDate) ||
                other.acceptanceDate == acceptanceDate) &&
            (identical(other.reportingManagerId, reportingManagerId) ||
                other.reportingManagerId == reportingManagerId) &&
            (identical(other.hiringManagerId, hiringManagerId) ||
                other.hiringManagerId == hiringManagerId) &&
            (identical(other.departmentId, departmentId) ||
                other.departmentId == departmentId) &&
            const DeepCollectionEquality().equals(other._skills, _skills) &&
            const DeepCollectionEquality().equals(
              other._qualifications,
              _qualifications,
            ) &&
            const DeepCollectionEquality().equals(
              other._certifications,
              _certifications,
            ) &&
            const DeepCollectionEquality().equals(
              other._workExperience,
              _workExperience,
            ) &&
            const DeepCollectionEquality().equals(
              other._documentIds,
              _documentIds,
            ) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl) &&
            (identical(other.resumeUrl, resumeUrl) ||
                other.resumeUrl == resumeUrl) &&
            (identical(other.offerLetterUrl, offerLetterUrl) ||
                other.offerLetterUrl == offerLetterUrl) &&
            (identical(other.appointmentLetterUrl, appointmentLetterUrl) ||
                other.appointmentLetterUrl == appointmentLetterUrl) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.currentStage, currentStage) ||
                other.currentStage == currentStage) &&
            (identical(other.lastStageUpdate, lastStageUpdate) ||
                other.lastStageUpdate == lastStageUpdate) &&
            (identical(other.stageUpdatedBy, stageUpdatedBy) ||
                other.stageUpdatedBy == stageUpdatedBy) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
            (identical(other.rejectedAt, rejectedAt) ||
                other.rejectedAt == rejectedAt) &&
            (identical(other.rejectedBy, rejectedBy) ||
                other.rejectedBy == rejectedBy) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    candidateId,
    firstName,
    lastName,
    email,
    phoneNumber,
    createdAt,
    updatedAt,
    createdBy,
    gender,
    dateOfBirth,
    nationality,
    maritalStatus,
    personalEmail,
    address,
    city,
    state,
    country,
    postalCode,
    department,
    designation,
    position,
    employmentType,
    workLocation,
    offeredSalary,
    salaryGrade,
    expectedJoiningDate,
    offerDate,
    acceptanceDate,
    reportingManagerId,
    hiringManagerId,
    departmentId,
    const DeepCollectionEquality().hash(_skills),
    const DeepCollectionEquality().hash(_qualifications),
    const DeepCollectionEquality().hash(_certifications),
    const DeepCollectionEquality().hash(_workExperience),
    const DeepCollectionEquality().hash(_documentIds),
    profileImageUrl,
    resumeUrl,
    offerLetterUrl,
    appointmentLetterUrl,
    status,
    currentStage,
    lastStageUpdate,
    stageUpdatedBy,
    employeeId,
    userId,
    notes,
    rejectionReason,
    rejectedAt,
    rejectedBy,
    const DeepCollectionEquality().hash(_metadata),
  ]);

  /// Create a copy of Candidate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CandidateImplCopyWith<_$CandidateImpl> get copyWith =>
      __$$CandidateImplCopyWithImpl<_$CandidateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CandidateImplToJson(this);
  }
}

abstract class _Candidate extends Candidate {
  const factory _Candidate({
    required final String id,
    required final String candidateId,
    required final String firstName,
    required final String lastName,
    required final String email,
    required final String phoneNumber,
    @TimestampConverter() required final DateTime createdAt,
    @TimestampConverter() required final DateTime updatedAt,
    required final String createdBy,
    final String? gender,
    @TimestampConverter() final DateTime? dateOfBirth,
    final String? nationality,
    final String? maritalStatus,
    final String? personalEmail,
    final String? address,
    final String? city,
    final String? state,
    final String? country,
    final String? postalCode,
    final String? department,
    final String? designation,
    final String? position,
    final String? employmentType,
    final String? workLocation,
    final double? offeredSalary,
    final String? salaryGrade,
    @TimestampConverter() final DateTime? expectedJoiningDate,
    @TimestampConverter() final DateTime? offerDate,
    @TimestampConverter() final DateTime? acceptanceDate,
    final String? reportingManagerId,
    final String? hiringManagerId,
    final String? departmentId,
    final List<String> skills,
    final List<Map<String, dynamic>> qualifications,
    final List<Map<String, dynamic>> certifications,
    final List<Map<String, dynamic>> workExperience,
    final List<String> documentIds,
    final String? profileImageUrl,
    final String? resumeUrl,
    final String? offerLetterUrl,
    final String? appointmentLetterUrl,
    final String? status,
    final String? currentStage,
    @TimestampConverter() final DateTime? lastStageUpdate,
    final String? stageUpdatedBy,
    final String? employeeId,
    final String? userId,
    final String? notes,
    final String? rejectionReason,
    @TimestampConverter() final DateTime? rejectedAt,
    final String? rejectedBy,
    final Map<String, dynamic>? metadata,
  }) = _$CandidateImpl;
  const _Candidate._() : super._();

  factory _Candidate.fromJson(Map<String, dynamic> json) =
      _$CandidateImpl.fromJson;

  @override
  String get id;
  @override
  String get candidateId; // CND2024000001 format
  @override
  String get firstName;
  @override
  String get lastName;
  @override
  String get email;
  @override
  String get phoneNumber;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt;
  @override
  String get createdBy; // Personal Information
  @override
  String? get gender;
  @override
  @TimestampConverter()
  DateTime? get dateOfBirth;
  @override
  String? get nationality;
  @override
  String? get maritalStatus;
  @override
  String? get personalEmail; // Address Information
  @override
  String? get address;
  @override
  String? get city;
  @override
  String? get state;
  @override
  String? get country;
  @override
  String? get postalCode; // Employment Information
  @override
  String? get department;
  @override
  String? get designation;
  @override
  String? get position;
  @override
  String? get employmentType; // Full-time, Part-time, Contract, Intern
  @override
  String? get workLocation; // Office, Remote, Hybrid
  @override
  double? get offeredSalary;
  @override
  String? get salaryGrade;
  @override
  @TimestampConverter()
  DateTime? get expectedJoiningDate;
  @override
  @TimestampConverter()
  DateTime? get offerDate;
  @override
  @TimestampConverter()
  DateTime? get acceptanceDate; // Organizational Structure
  @override
  String? get reportingManagerId;
  @override
  String? get hiringManagerId;
  @override
  String? get departmentId; // Skills and Qualifications
  @override
  List<String> get skills;
  @override
  List<Map<String, dynamic>> get qualifications;
  @override
  List<Map<String, dynamic>> get certifications;
  @override
  List<Map<String, dynamic>> get workExperience; // Documents
  @override
  List<String> get documentIds;
  @override
  String? get profileImageUrl;
  @override
  String? get resumeUrl;
  @override
  String? get offerLetterUrl;
  @override
  String? get appointmentLetterUrl; // Status and Workflow
  @override
  String? get status; // "applied", "interviewed", "offered", "accepted", "onboarded"
  @override
  String? get currentStage; // "screening", "interview", "offer", "onboarding"
  @override
  @TimestampConverter()
  DateTime? get lastStageUpdate;
  @override
  String? get stageUpdatedBy; // Employee ID (assigned after onboarding)
  @override
  String? get employeeId;
  @override
  String? get userId; // Firebase Auth user ID (assigned after user creation)
  // Additional metadata
  @override
  String? get notes;
  @override
  String? get rejectionReason;
  @override
  @TimestampConverter()
  DateTime? get rejectedAt;
  @override
  String? get rejectedBy;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of Candidate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CandidateImplCopyWith<_$CandidateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
