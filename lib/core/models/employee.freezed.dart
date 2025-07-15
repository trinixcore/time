// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'employee.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Employee _$EmployeeFromJson(Map<String, dynamic> json) {
  return _Employee.fromJson(json);
}

/// @nodoc
mixin _$Employee {
  String get id => throw _privateConstructorUsedError;
  String get userId =>
      throw _privateConstructorUsedError; // Reference to Firebase Auth user
  String get employeeId =>
      throw _privateConstructorUsedError; // TRX2024000001 format
  String get firstName => throw _privateConstructorUsedError;
  String get lastName => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  UserRole get role => throw _privateConstructorUsedError;
  EmployeeStatus get status => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String get createdBy =>
      throw _privateConstructorUsedError; // Contact Information
  String? get phoneNumber => throw _privateConstructorUsedError;
  String? get emergencyContactName => throw _privateConstructorUsedError;
  String? get emergencyContactPhone => throw _privateConstructorUsedError;
  String? get personalEmail =>
      throw _privateConstructorUsedError; // Address Information
  String? get address => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get state => throw _privateConstructorUsedError;
  String? get country => throw _privateConstructorUsedError;
  String? get postalCode =>
      throw _privateConstructorUsedError; // Personal Information
  String? get gender => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get dateOfBirth => throw _privateConstructorUsedError;
  String? get nationality => throw _privateConstructorUsedError;
  String? get maritalStatus =>
      throw _privateConstructorUsedError; // Employment Information
  String? get department => throw _privateConstructorUsedError;
  String? get designation => throw _privateConstructorUsedError;
  String? get position => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get joiningDate => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get probationEndDate => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get confirmationDate => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get terminationDate => throw _privateConstructorUsedError;
  String? get employmentType =>
      throw _privateConstructorUsedError; // Full-time, Part-time, Contract, Intern
  String? get workLocation =>
      throw _privateConstructorUsedError; // Office, Remote, Hybrid
  double? get salary => throw _privateConstructorUsedError;
  String? get salaryGrade =>
      throw _privateConstructorUsedError; // Organizational Structure
  String? get reportingManagerId => throw _privateConstructorUsedError;
  String? get hiringManagerId => throw _privateConstructorUsedError;
  String? get departmentId => throw _privateConstructorUsedError;
  List<String> get teamIds => throw _privateConstructorUsedError;
  List<String> get projectIds => throw _privateConstructorUsedError;
  List<String> get subordinateIds =>
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
  String? get resumeUrl =>
      throw _privateConstructorUsedError; // Performance and Attendance
  double? get performanceRating => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get lastPerformanceReview => throw _privateConstructorUsedError;
  int? get totalLeaveDays => throw _privateConstructorUsedError;
  int? get usedLeaveDays => throw _privateConstructorUsedError;
  double? get attendancePercentage =>
      throw _privateConstructorUsedError; // System Fields
  @TimestampConverter()
  DateTime? get lastLoginAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get lastUpdatedBy => throw _privateConstructorUsedError;
  String? get updatedBy => throw _privateConstructorUsedError;
  bool? get isActive => throw _privateConstructorUsedError;
  Map<String, dynamic>? get customFields => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata =>
      throw _privateConstructorUsedError; // Audit Fields
  List<Map<String, dynamic>> get auditLog => throw _privateConstructorUsedError;

  /// Serializes this Employee to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Employee
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EmployeeCopyWith<Employee> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmployeeCopyWith<$Res> {
  factory $EmployeeCopyWith(Employee value, $Res Function(Employee) then) =
      _$EmployeeCopyWithImpl<$Res, Employee>;
  @useResult
  $Res call({
    String id,
    String userId,
    String employeeId,
    String firstName,
    String lastName,
    String email,
    UserRole role,
    EmployeeStatus status,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime updatedAt,
    String createdBy,
    String? phoneNumber,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? personalEmail,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? gender,
    @TimestampConverter() DateTime? dateOfBirth,
    String? nationality,
    String? maritalStatus,
    String? department,
    String? designation,
    String? position,
    @TimestampConverter() DateTime? joiningDate,
    @TimestampConverter() DateTime? probationEndDate,
    @TimestampConverter() DateTime? confirmationDate,
    @TimestampConverter() DateTime? terminationDate,
    String? employmentType,
    String? workLocation,
    double? salary,
    String? salaryGrade,
    String? reportingManagerId,
    String? hiringManagerId,
    String? departmentId,
    List<String> teamIds,
    List<String> projectIds,
    List<String> subordinateIds,
    List<String> skills,
    List<Map<String, dynamic>> qualifications,
    List<Map<String, dynamic>> certifications,
    List<Map<String, dynamic>> workExperience,
    List<String> documentIds,
    String? profileImageUrl,
    String? resumeUrl,
    double? performanceRating,
    @TimestampConverter() DateTime? lastPerformanceReview,
    int? totalLeaveDays,
    int? usedLeaveDays,
    double? attendancePercentage,
    @TimestampConverter() DateTime? lastLoginAt,
    @TimestampConverter() DateTime? lastUpdatedBy,
    String? updatedBy,
    bool? isActive,
    Map<String, dynamic>? customFields,
    Map<String, dynamic>? metadata,
    List<Map<String, dynamic>> auditLog,
  });
}

/// @nodoc
class _$EmployeeCopyWithImpl<$Res, $Val extends Employee>
    implements $EmployeeCopyWith<$Res> {
  _$EmployeeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Employee
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? employeeId = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? email = null,
    Object? role = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? createdBy = null,
    Object? phoneNumber = freezed,
    Object? emergencyContactName = freezed,
    Object? emergencyContactPhone = freezed,
    Object? personalEmail = freezed,
    Object? address = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? country = freezed,
    Object? postalCode = freezed,
    Object? gender = freezed,
    Object? dateOfBirth = freezed,
    Object? nationality = freezed,
    Object? maritalStatus = freezed,
    Object? department = freezed,
    Object? designation = freezed,
    Object? position = freezed,
    Object? joiningDate = freezed,
    Object? probationEndDate = freezed,
    Object? confirmationDate = freezed,
    Object? terminationDate = freezed,
    Object? employmentType = freezed,
    Object? workLocation = freezed,
    Object? salary = freezed,
    Object? salaryGrade = freezed,
    Object? reportingManagerId = freezed,
    Object? hiringManagerId = freezed,
    Object? departmentId = freezed,
    Object? teamIds = null,
    Object? projectIds = null,
    Object? subordinateIds = null,
    Object? skills = null,
    Object? qualifications = null,
    Object? certifications = null,
    Object? workExperience = null,
    Object? documentIds = null,
    Object? profileImageUrl = freezed,
    Object? resumeUrl = freezed,
    Object? performanceRating = freezed,
    Object? lastPerformanceReview = freezed,
    Object? totalLeaveDays = freezed,
    Object? usedLeaveDays = freezed,
    Object? attendancePercentage = freezed,
    Object? lastLoginAt = freezed,
    Object? lastUpdatedBy = freezed,
    Object? updatedBy = freezed,
    Object? isActive = freezed,
    Object? customFields = freezed,
    Object? metadata = freezed,
    Object? auditLog = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            userId:
                null == userId
                    ? _value.userId
                    : userId // ignore: cast_nullable_to_non_nullable
                        as String,
            employeeId:
                null == employeeId
                    ? _value.employeeId
                    : employeeId // ignore: cast_nullable_to_non_nullable
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
            role:
                null == role
                    ? _value.role
                    : role // ignore: cast_nullable_to_non_nullable
                        as UserRole,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as EmployeeStatus,
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
            phoneNumber:
                freezed == phoneNumber
                    ? _value.phoneNumber
                    : phoneNumber // ignore: cast_nullable_to_non_nullable
                        as String?,
            emergencyContactName:
                freezed == emergencyContactName
                    ? _value.emergencyContactName
                    : emergencyContactName // ignore: cast_nullable_to_non_nullable
                        as String?,
            emergencyContactPhone:
                freezed == emergencyContactPhone
                    ? _value.emergencyContactPhone
                    : emergencyContactPhone // ignore: cast_nullable_to_non_nullable
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
            joiningDate:
                freezed == joiningDate
                    ? _value.joiningDate
                    : joiningDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            probationEndDate:
                freezed == probationEndDate
                    ? _value.probationEndDate
                    : probationEndDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            confirmationDate:
                freezed == confirmationDate
                    ? _value.confirmationDate
                    : confirmationDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            terminationDate:
                freezed == terminationDate
                    ? _value.terminationDate
                    : terminationDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
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
            salary:
                freezed == salary
                    ? _value.salary
                    : salary // ignore: cast_nullable_to_non_nullable
                        as double?,
            salaryGrade:
                freezed == salaryGrade
                    ? _value.salaryGrade
                    : salaryGrade // ignore: cast_nullable_to_non_nullable
                        as String?,
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
            teamIds:
                null == teamIds
                    ? _value.teamIds
                    : teamIds // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            projectIds:
                null == projectIds
                    ? _value.projectIds
                    : projectIds // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            subordinateIds:
                null == subordinateIds
                    ? _value.subordinateIds
                    : subordinateIds // ignore: cast_nullable_to_non_nullable
                        as List<String>,
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
            performanceRating:
                freezed == performanceRating
                    ? _value.performanceRating
                    : performanceRating // ignore: cast_nullable_to_non_nullable
                        as double?,
            lastPerformanceReview:
                freezed == lastPerformanceReview
                    ? _value.lastPerformanceReview
                    : lastPerformanceReview // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            totalLeaveDays:
                freezed == totalLeaveDays
                    ? _value.totalLeaveDays
                    : totalLeaveDays // ignore: cast_nullable_to_non_nullable
                        as int?,
            usedLeaveDays:
                freezed == usedLeaveDays
                    ? _value.usedLeaveDays
                    : usedLeaveDays // ignore: cast_nullable_to_non_nullable
                        as int?,
            attendancePercentage:
                freezed == attendancePercentage
                    ? _value.attendancePercentage
                    : attendancePercentage // ignore: cast_nullable_to_non_nullable
                        as double?,
            lastLoginAt:
                freezed == lastLoginAt
                    ? _value.lastLoginAt
                    : lastLoginAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            lastUpdatedBy:
                freezed == lastUpdatedBy
                    ? _value.lastUpdatedBy
                    : lastUpdatedBy // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            updatedBy:
                freezed == updatedBy
                    ? _value.updatedBy
                    : updatedBy // ignore: cast_nullable_to_non_nullable
                        as String?,
            isActive:
                freezed == isActive
                    ? _value.isActive
                    : isActive // ignore: cast_nullable_to_non_nullable
                        as bool?,
            customFields:
                freezed == customFields
                    ? _value.customFields
                    : customFields // ignore: cast_nullable_to_non_nullable
                        as Map<String, dynamic>?,
            metadata:
                freezed == metadata
                    ? _value.metadata
                    : metadata // ignore: cast_nullable_to_non_nullable
                        as Map<String, dynamic>?,
            auditLog:
                null == auditLog
                    ? _value.auditLog
                    : auditLog // ignore: cast_nullable_to_non_nullable
                        as List<Map<String, dynamic>>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EmployeeImplCopyWith<$Res>
    implements $EmployeeCopyWith<$Res> {
  factory _$$EmployeeImplCopyWith(
    _$EmployeeImpl value,
    $Res Function(_$EmployeeImpl) then,
  ) = __$$EmployeeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String employeeId,
    String firstName,
    String lastName,
    String email,
    UserRole role,
    EmployeeStatus status,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime updatedAt,
    String createdBy,
    String? phoneNumber,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? personalEmail,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? gender,
    @TimestampConverter() DateTime? dateOfBirth,
    String? nationality,
    String? maritalStatus,
    String? department,
    String? designation,
    String? position,
    @TimestampConverter() DateTime? joiningDate,
    @TimestampConverter() DateTime? probationEndDate,
    @TimestampConverter() DateTime? confirmationDate,
    @TimestampConverter() DateTime? terminationDate,
    String? employmentType,
    String? workLocation,
    double? salary,
    String? salaryGrade,
    String? reportingManagerId,
    String? hiringManagerId,
    String? departmentId,
    List<String> teamIds,
    List<String> projectIds,
    List<String> subordinateIds,
    List<String> skills,
    List<Map<String, dynamic>> qualifications,
    List<Map<String, dynamic>> certifications,
    List<Map<String, dynamic>> workExperience,
    List<String> documentIds,
    String? profileImageUrl,
    String? resumeUrl,
    double? performanceRating,
    @TimestampConverter() DateTime? lastPerformanceReview,
    int? totalLeaveDays,
    int? usedLeaveDays,
    double? attendancePercentage,
    @TimestampConverter() DateTime? lastLoginAt,
    @TimestampConverter() DateTime? lastUpdatedBy,
    String? updatedBy,
    bool? isActive,
    Map<String, dynamic>? customFields,
    Map<String, dynamic>? metadata,
    List<Map<String, dynamic>> auditLog,
  });
}

/// @nodoc
class __$$EmployeeImplCopyWithImpl<$Res>
    extends _$EmployeeCopyWithImpl<$Res, _$EmployeeImpl>
    implements _$$EmployeeImplCopyWith<$Res> {
  __$$EmployeeImplCopyWithImpl(
    _$EmployeeImpl _value,
    $Res Function(_$EmployeeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Employee
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? employeeId = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? email = null,
    Object? role = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? createdBy = null,
    Object? phoneNumber = freezed,
    Object? emergencyContactName = freezed,
    Object? emergencyContactPhone = freezed,
    Object? personalEmail = freezed,
    Object? address = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? country = freezed,
    Object? postalCode = freezed,
    Object? gender = freezed,
    Object? dateOfBirth = freezed,
    Object? nationality = freezed,
    Object? maritalStatus = freezed,
    Object? department = freezed,
    Object? designation = freezed,
    Object? position = freezed,
    Object? joiningDate = freezed,
    Object? probationEndDate = freezed,
    Object? confirmationDate = freezed,
    Object? terminationDate = freezed,
    Object? employmentType = freezed,
    Object? workLocation = freezed,
    Object? salary = freezed,
    Object? salaryGrade = freezed,
    Object? reportingManagerId = freezed,
    Object? hiringManagerId = freezed,
    Object? departmentId = freezed,
    Object? teamIds = null,
    Object? projectIds = null,
    Object? subordinateIds = null,
    Object? skills = null,
    Object? qualifications = null,
    Object? certifications = null,
    Object? workExperience = null,
    Object? documentIds = null,
    Object? profileImageUrl = freezed,
    Object? resumeUrl = freezed,
    Object? performanceRating = freezed,
    Object? lastPerformanceReview = freezed,
    Object? totalLeaveDays = freezed,
    Object? usedLeaveDays = freezed,
    Object? attendancePercentage = freezed,
    Object? lastLoginAt = freezed,
    Object? lastUpdatedBy = freezed,
    Object? updatedBy = freezed,
    Object? isActive = freezed,
    Object? customFields = freezed,
    Object? metadata = freezed,
    Object? auditLog = null,
  }) {
    return _then(
      _$EmployeeImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        userId:
            null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                    as String,
        employeeId:
            null == employeeId
                ? _value.employeeId
                : employeeId // ignore: cast_nullable_to_non_nullable
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
        role:
            null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                    as UserRole,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as EmployeeStatus,
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
        phoneNumber:
            freezed == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                    as String?,
        emergencyContactName:
            freezed == emergencyContactName
                ? _value.emergencyContactName
                : emergencyContactName // ignore: cast_nullable_to_non_nullable
                    as String?,
        emergencyContactPhone:
            freezed == emergencyContactPhone
                ? _value.emergencyContactPhone
                : emergencyContactPhone // ignore: cast_nullable_to_non_nullable
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
        joiningDate:
            freezed == joiningDate
                ? _value.joiningDate
                : joiningDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        probationEndDate:
            freezed == probationEndDate
                ? _value.probationEndDate
                : probationEndDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        confirmationDate:
            freezed == confirmationDate
                ? _value.confirmationDate
                : confirmationDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        terminationDate:
            freezed == terminationDate
                ? _value.terminationDate
                : terminationDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
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
        salary:
            freezed == salary
                ? _value.salary
                : salary // ignore: cast_nullable_to_non_nullable
                    as double?,
        salaryGrade:
            freezed == salaryGrade
                ? _value.salaryGrade
                : salaryGrade // ignore: cast_nullable_to_non_nullable
                    as String?,
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
        teamIds:
            null == teamIds
                ? _value._teamIds
                : teamIds // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        projectIds:
            null == projectIds
                ? _value._projectIds
                : projectIds // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        subordinateIds:
            null == subordinateIds
                ? _value._subordinateIds
                : subordinateIds // ignore: cast_nullable_to_non_nullable
                    as List<String>,
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
        performanceRating:
            freezed == performanceRating
                ? _value.performanceRating
                : performanceRating // ignore: cast_nullable_to_non_nullable
                    as double?,
        lastPerformanceReview:
            freezed == lastPerformanceReview
                ? _value.lastPerformanceReview
                : lastPerformanceReview // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        totalLeaveDays:
            freezed == totalLeaveDays
                ? _value.totalLeaveDays
                : totalLeaveDays // ignore: cast_nullable_to_non_nullable
                    as int?,
        usedLeaveDays:
            freezed == usedLeaveDays
                ? _value.usedLeaveDays
                : usedLeaveDays // ignore: cast_nullable_to_non_nullable
                    as int?,
        attendancePercentage:
            freezed == attendancePercentage
                ? _value.attendancePercentage
                : attendancePercentage // ignore: cast_nullable_to_non_nullable
                    as double?,
        lastLoginAt:
            freezed == lastLoginAt
                ? _value.lastLoginAt
                : lastLoginAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        lastUpdatedBy:
            freezed == lastUpdatedBy
                ? _value.lastUpdatedBy
                : lastUpdatedBy // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        updatedBy:
            freezed == updatedBy
                ? _value.updatedBy
                : updatedBy // ignore: cast_nullable_to_non_nullable
                    as String?,
        isActive:
            freezed == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                    as bool?,
        customFields:
            freezed == customFields
                ? _value._customFields
                : customFields // ignore: cast_nullable_to_non_nullable
                    as Map<String, dynamic>?,
        metadata:
            freezed == metadata
                ? _value._metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                    as Map<String, dynamic>?,
        auditLog:
            null == auditLog
                ? _value._auditLog
                : auditLog // ignore: cast_nullable_to_non_nullable
                    as List<Map<String, dynamic>>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EmployeeImpl extends _Employee {
  const _$EmployeeImpl({
    required this.id,
    required this.userId,
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.status,
    @TimestampConverter() required this.createdAt,
    @TimestampConverter() required this.updatedAt,
    required this.createdBy,
    this.phoneNumber,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.personalEmail,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.gender,
    @TimestampConverter() this.dateOfBirth,
    this.nationality,
    this.maritalStatus,
    this.department,
    this.designation,
    this.position,
    @TimestampConverter() this.joiningDate,
    @TimestampConverter() this.probationEndDate,
    @TimestampConverter() this.confirmationDate,
    @TimestampConverter() this.terminationDate,
    this.employmentType,
    this.workLocation,
    this.salary,
    this.salaryGrade,
    this.reportingManagerId,
    this.hiringManagerId,
    this.departmentId,
    final List<String> teamIds = const [],
    final List<String> projectIds = const [],
    final List<String> subordinateIds = const [],
    final List<String> skills = const [],
    final List<Map<String, dynamic>> qualifications = const [],
    final List<Map<String, dynamic>> certifications = const [],
    final List<Map<String, dynamic>> workExperience = const [],
    final List<String> documentIds = const [],
    this.profileImageUrl,
    this.resumeUrl,
    this.performanceRating,
    @TimestampConverter() this.lastPerformanceReview,
    this.totalLeaveDays,
    this.usedLeaveDays,
    this.attendancePercentage,
    @TimestampConverter() this.lastLoginAt,
    @TimestampConverter() this.lastUpdatedBy,
    this.updatedBy,
    this.isActive,
    final Map<String, dynamic>? customFields,
    final Map<String, dynamic>? metadata,
    final List<Map<String, dynamic>> auditLog = const [],
  }) : _teamIds = teamIds,
       _projectIds = projectIds,
       _subordinateIds = subordinateIds,
       _skills = skills,
       _qualifications = qualifications,
       _certifications = certifications,
       _workExperience = workExperience,
       _documentIds = documentIds,
       _customFields = customFields,
       _metadata = metadata,
       _auditLog = auditLog,
       super._();

  factory _$EmployeeImpl.fromJson(Map<String, dynamic> json) =>
      _$$EmployeeImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  // Reference to Firebase Auth user
  @override
  final String employeeId;
  // TRX2024000001 format
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final String email;
  @override
  final UserRole role;
  @override
  final EmployeeStatus status;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime updatedAt;
  @override
  final String createdBy;
  // Contact Information
  @override
  final String? phoneNumber;
  @override
  final String? emergencyContactName;
  @override
  final String? emergencyContactPhone;
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
  // Employment Information
  @override
  final String? department;
  @override
  final String? designation;
  @override
  final String? position;
  @override
  @TimestampConverter()
  final DateTime? joiningDate;
  @override
  @TimestampConverter()
  final DateTime? probationEndDate;
  @override
  @TimestampConverter()
  final DateTime? confirmationDate;
  @override
  @TimestampConverter()
  final DateTime? terminationDate;
  @override
  final String? employmentType;
  // Full-time, Part-time, Contract, Intern
  @override
  final String? workLocation;
  // Office, Remote, Hybrid
  @override
  final double? salary;
  @override
  final String? salaryGrade;
  // Organizational Structure
  @override
  final String? reportingManagerId;
  @override
  final String? hiringManagerId;
  @override
  final String? departmentId;
  final List<String> _teamIds;
  @override
  @JsonKey()
  List<String> get teamIds {
    if (_teamIds is EqualUnmodifiableListView) return _teamIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_teamIds);
  }

  final List<String> _projectIds;
  @override
  @JsonKey()
  List<String> get projectIds {
    if (_projectIds is EqualUnmodifiableListView) return _projectIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_projectIds);
  }

  final List<String> _subordinateIds;
  @override
  @JsonKey()
  List<String> get subordinateIds {
    if (_subordinateIds is EqualUnmodifiableListView) return _subordinateIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subordinateIds);
  }

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
  // Performance and Attendance
  @override
  final double? performanceRating;
  @override
  @TimestampConverter()
  final DateTime? lastPerformanceReview;
  @override
  final int? totalLeaveDays;
  @override
  final int? usedLeaveDays;
  @override
  final double? attendancePercentage;
  // System Fields
  @override
  @TimestampConverter()
  final DateTime? lastLoginAt;
  @override
  @TimestampConverter()
  final DateTime? lastUpdatedBy;
  @override
  final String? updatedBy;
  @override
  final bool? isActive;
  final Map<String, dynamic>? _customFields;
  @override
  Map<String, dynamic>? get customFields {
    final value = _customFields;
    if (value == null) return null;
    if (_customFields is EqualUnmodifiableMapView) return _customFields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  // Audit Fields
  final List<Map<String, dynamic>> _auditLog;
  // Audit Fields
  @override
  @JsonKey()
  List<Map<String, dynamic>> get auditLog {
    if (_auditLog is EqualUnmodifiableListView) return _auditLog;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_auditLog);
  }

  @override
  String toString() {
    return 'Employee(id: $id, userId: $userId, employeeId: $employeeId, firstName: $firstName, lastName: $lastName, email: $email, role: $role, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, createdBy: $createdBy, phoneNumber: $phoneNumber, emergencyContactName: $emergencyContactName, emergencyContactPhone: $emergencyContactPhone, personalEmail: $personalEmail, address: $address, city: $city, state: $state, country: $country, postalCode: $postalCode, gender: $gender, dateOfBirth: $dateOfBirth, nationality: $nationality, maritalStatus: $maritalStatus, department: $department, designation: $designation, position: $position, joiningDate: $joiningDate, probationEndDate: $probationEndDate, confirmationDate: $confirmationDate, terminationDate: $terminationDate, employmentType: $employmentType, workLocation: $workLocation, salary: $salary, salaryGrade: $salaryGrade, reportingManagerId: $reportingManagerId, hiringManagerId: $hiringManagerId, departmentId: $departmentId, teamIds: $teamIds, projectIds: $projectIds, subordinateIds: $subordinateIds, skills: $skills, qualifications: $qualifications, certifications: $certifications, workExperience: $workExperience, documentIds: $documentIds, profileImageUrl: $profileImageUrl, resumeUrl: $resumeUrl, performanceRating: $performanceRating, lastPerformanceReview: $lastPerformanceReview, totalLeaveDays: $totalLeaveDays, usedLeaveDays: $usedLeaveDays, attendancePercentage: $attendancePercentage, lastLoginAt: $lastLoginAt, lastUpdatedBy: $lastUpdatedBy, updatedBy: $updatedBy, isActive: $isActive, customFields: $customFields, metadata: $metadata, auditLog: $auditLog)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmployeeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.emergencyContactName, emergencyContactName) ||
                other.emergencyContactName == emergencyContactName) &&
            (identical(other.emergencyContactPhone, emergencyContactPhone) ||
                other.emergencyContactPhone == emergencyContactPhone) &&
            (identical(other.personalEmail, personalEmail) ||
                other.personalEmail == personalEmail) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.postalCode, postalCode) ||
                other.postalCode == postalCode) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.nationality, nationality) ||
                other.nationality == nationality) &&
            (identical(other.maritalStatus, maritalStatus) ||
                other.maritalStatus == maritalStatus) &&
            (identical(other.department, department) ||
                other.department == department) &&
            (identical(other.designation, designation) ||
                other.designation == designation) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.joiningDate, joiningDate) ||
                other.joiningDate == joiningDate) &&
            (identical(other.probationEndDate, probationEndDate) ||
                other.probationEndDate == probationEndDate) &&
            (identical(other.confirmationDate, confirmationDate) ||
                other.confirmationDate == confirmationDate) &&
            (identical(other.terminationDate, terminationDate) ||
                other.terminationDate == terminationDate) &&
            (identical(other.employmentType, employmentType) ||
                other.employmentType == employmentType) &&
            (identical(other.workLocation, workLocation) ||
                other.workLocation == workLocation) &&
            (identical(other.salary, salary) || other.salary == salary) &&
            (identical(other.salaryGrade, salaryGrade) ||
                other.salaryGrade == salaryGrade) &&
            (identical(other.reportingManagerId, reportingManagerId) ||
                other.reportingManagerId == reportingManagerId) &&
            (identical(other.hiringManagerId, hiringManagerId) ||
                other.hiringManagerId == hiringManagerId) &&
            (identical(other.departmentId, departmentId) ||
                other.departmentId == departmentId) &&
            const DeepCollectionEquality().equals(other._teamIds, _teamIds) &&
            const DeepCollectionEquality().equals(
              other._projectIds,
              _projectIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._subordinateIds,
              _subordinateIds,
            ) &&
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
            (identical(other.performanceRating, performanceRating) ||
                other.performanceRating == performanceRating) &&
            (identical(other.lastPerformanceReview, lastPerformanceReview) ||
                other.lastPerformanceReview == lastPerformanceReview) &&
            (identical(other.totalLeaveDays, totalLeaveDays) ||
                other.totalLeaveDays == totalLeaveDays) &&
            (identical(other.usedLeaveDays, usedLeaveDays) ||
                other.usedLeaveDays == usedLeaveDays) &&
            (identical(other.attendancePercentage, attendancePercentage) ||
                other.attendancePercentage == attendancePercentage) &&
            (identical(other.lastLoginAt, lastLoginAt) ||
                other.lastLoginAt == lastLoginAt) &&
            (identical(other.lastUpdatedBy, lastUpdatedBy) ||
                other.lastUpdatedBy == lastUpdatedBy) &&
            (identical(other.updatedBy, updatedBy) ||
                other.updatedBy == updatedBy) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            const DeepCollectionEquality().equals(
              other._customFields,
              _customFields,
            ) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            const DeepCollectionEquality().equals(other._auditLog, _auditLog));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    userId,
    employeeId,
    firstName,
    lastName,
    email,
    role,
    status,
    createdAt,
    updatedAt,
    createdBy,
    phoneNumber,
    emergencyContactName,
    emergencyContactPhone,
    personalEmail,
    address,
    city,
    state,
    country,
    postalCode,
    gender,
    dateOfBirth,
    nationality,
    maritalStatus,
    department,
    designation,
    position,
    joiningDate,
    probationEndDate,
    confirmationDate,
    terminationDate,
    employmentType,
    workLocation,
    salary,
    salaryGrade,
    reportingManagerId,
    hiringManagerId,
    departmentId,
    const DeepCollectionEquality().hash(_teamIds),
    const DeepCollectionEquality().hash(_projectIds),
    const DeepCollectionEquality().hash(_subordinateIds),
    const DeepCollectionEquality().hash(_skills),
    const DeepCollectionEquality().hash(_qualifications),
    const DeepCollectionEquality().hash(_certifications),
    const DeepCollectionEquality().hash(_workExperience),
    const DeepCollectionEquality().hash(_documentIds),
    profileImageUrl,
    resumeUrl,
    performanceRating,
    lastPerformanceReview,
    totalLeaveDays,
    usedLeaveDays,
    attendancePercentage,
    lastLoginAt,
    lastUpdatedBy,
    updatedBy,
    isActive,
    const DeepCollectionEquality().hash(_customFields),
    const DeepCollectionEquality().hash(_metadata),
    const DeepCollectionEquality().hash(_auditLog),
  ]);

  /// Create a copy of Employee
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmployeeImplCopyWith<_$EmployeeImpl> get copyWith =>
      __$$EmployeeImplCopyWithImpl<_$EmployeeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EmployeeImplToJson(this);
  }
}

abstract class _Employee extends Employee {
  const factory _Employee({
    required final String id,
    required final String userId,
    required final String employeeId,
    required final String firstName,
    required final String lastName,
    required final String email,
    required final UserRole role,
    required final EmployeeStatus status,
    @TimestampConverter() required final DateTime createdAt,
    @TimestampConverter() required final DateTime updatedAt,
    required final String createdBy,
    final String? phoneNumber,
    final String? emergencyContactName,
    final String? emergencyContactPhone,
    final String? personalEmail,
    final String? address,
    final String? city,
    final String? state,
    final String? country,
    final String? postalCode,
    final String? gender,
    @TimestampConverter() final DateTime? dateOfBirth,
    final String? nationality,
    final String? maritalStatus,
    final String? department,
    final String? designation,
    final String? position,
    @TimestampConverter() final DateTime? joiningDate,
    @TimestampConverter() final DateTime? probationEndDate,
    @TimestampConverter() final DateTime? confirmationDate,
    @TimestampConverter() final DateTime? terminationDate,
    final String? employmentType,
    final String? workLocation,
    final double? salary,
    final String? salaryGrade,
    final String? reportingManagerId,
    final String? hiringManagerId,
    final String? departmentId,
    final List<String> teamIds,
    final List<String> projectIds,
    final List<String> subordinateIds,
    final List<String> skills,
    final List<Map<String, dynamic>> qualifications,
    final List<Map<String, dynamic>> certifications,
    final List<Map<String, dynamic>> workExperience,
    final List<String> documentIds,
    final String? profileImageUrl,
    final String? resumeUrl,
    final double? performanceRating,
    @TimestampConverter() final DateTime? lastPerformanceReview,
    final int? totalLeaveDays,
    final int? usedLeaveDays,
    final double? attendancePercentage,
    @TimestampConverter() final DateTime? lastLoginAt,
    @TimestampConverter() final DateTime? lastUpdatedBy,
    final String? updatedBy,
    final bool? isActive,
    final Map<String, dynamic>? customFields,
    final Map<String, dynamic>? metadata,
    final List<Map<String, dynamic>> auditLog,
  }) = _$EmployeeImpl;
  const _Employee._() : super._();

  factory _Employee.fromJson(Map<String, dynamic> json) =
      _$EmployeeImpl.fromJson;

  @override
  String get id;
  @override
  String get userId; // Reference to Firebase Auth user
  @override
  String get employeeId; // TRX2024000001 format
  @override
  String get firstName;
  @override
  String get lastName;
  @override
  String get email;
  @override
  UserRole get role;
  @override
  EmployeeStatus get status;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt;
  @override
  String get createdBy; // Contact Information
  @override
  String? get phoneNumber;
  @override
  String? get emergencyContactName;
  @override
  String? get emergencyContactPhone;
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
  String? get postalCode; // Personal Information
  @override
  String? get gender;
  @override
  @TimestampConverter()
  DateTime? get dateOfBirth;
  @override
  String? get nationality;
  @override
  String? get maritalStatus; // Employment Information
  @override
  String? get department;
  @override
  String? get designation;
  @override
  String? get position;
  @override
  @TimestampConverter()
  DateTime? get joiningDate;
  @override
  @TimestampConverter()
  DateTime? get probationEndDate;
  @override
  @TimestampConverter()
  DateTime? get confirmationDate;
  @override
  @TimestampConverter()
  DateTime? get terminationDate;
  @override
  String? get employmentType; // Full-time, Part-time, Contract, Intern
  @override
  String? get workLocation; // Office, Remote, Hybrid
  @override
  double? get salary;
  @override
  String? get salaryGrade; // Organizational Structure
  @override
  String? get reportingManagerId;
  @override
  String? get hiringManagerId;
  @override
  String? get departmentId;
  @override
  List<String> get teamIds;
  @override
  List<String> get projectIds;
  @override
  List<String> get subordinateIds; // Skills and Qualifications
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
  String? get resumeUrl; // Performance and Attendance
  @override
  double? get performanceRating;
  @override
  @TimestampConverter()
  DateTime? get lastPerformanceReview;
  @override
  int? get totalLeaveDays;
  @override
  int? get usedLeaveDays;
  @override
  double? get attendancePercentage; // System Fields
  @override
  @TimestampConverter()
  DateTime? get lastLoginAt;
  @override
  @TimestampConverter()
  DateTime? get lastUpdatedBy;
  @override
  String? get updatedBy;
  @override
  bool? get isActive;
  @override
  Map<String, dynamic>? get customFields;
  @override
  Map<String, dynamic>? get metadata; // Audit Fields
  @override
  List<Map<String, dynamic>> get auditLog;

  /// Create a copy of Employee
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmployeeImplCopyWith<_$EmployeeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
