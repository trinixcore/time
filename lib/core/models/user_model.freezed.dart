// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  String get uid => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  @UserRoleConverter()
  UserRole get role => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  String? get department => throw _privateConstructorUsedError;
  String? get position => throw _privateConstructorUsedError;
  String? get employeeId => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get lastLoginAt => throw _privateConstructorUsedError;
  bool? get mfaEnabled => throw _privateConstructorUsedError;
  String? get createdBy =>
      throw _privateConstructorUsedError; // Optional termination fields
  @TimestampConverter()
  DateTime? get terminationDate => throw _privateConstructorUsedError;
  String? get terminationReason => throw _privateConstructorUsedError;
  String? get terminationComments => throw _privateConstructorUsedError;
  String? get terminatedBy => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get lastWorkingDay => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get reactivationDate => throw _privateConstructorUsedError;
  String? get reactivationReason => throw _privateConstructorUsedError;
  String? get reactivationComments => throw _privateConstructorUsedError;
  String? get reactivatedBy => throw _privateConstructorUsedError; // NEW FIELD
  String? get candidateId => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call({
    String uid,
    String email,
    String displayName,
    @UserRoleConverter() UserRole role,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime updatedAt,
    bool isActive,
    String? photoUrl,
    String? phoneNumber,
    String? department,
    String? position,
    String? employeeId,
    @TimestampConverter() DateTime? lastLoginAt,
    bool? mfaEnabled,
    String? createdBy,
    @TimestampConverter() DateTime? terminationDate,
    String? terminationReason,
    String? terminationComments,
    String? terminatedBy,
    @TimestampConverter() DateTime? lastWorkingDay,
    @TimestampConverter() DateTime? reactivationDate,
    String? reactivationReason,
    String? reactivationComments,
    String? reactivatedBy,
    String? candidateId,
  });
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? email = null,
    Object? displayName = null,
    Object? role = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? isActive = null,
    Object? photoUrl = freezed,
    Object? phoneNumber = freezed,
    Object? department = freezed,
    Object? position = freezed,
    Object? employeeId = freezed,
    Object? lastLoginAt = freezed,
    Object? mfaEnabled = freezed,
    Object? createdBy = freezed,
    Object? terminationDate = freezed,
    Object? terminationReason = freezed,
    Object? terminationComments = freezed,
    Object? terminatedBy = freezed,
    Object? lastWorkingDay = freezed,
    Object? reactivationDate = freezed,
    Object? reactivationReason = freezed,
    Object? reactivationComments = freezed,
    Object? reactivatedBy = freezed,
    Object? candidateId = freezed,
  }) {
    return _then(
      _value.copyWith(
            uid:
                null == uid
                    ? _value.uid
                    : uid // ignore: cast_nullable_to_non_nullable
                        as String,
            email:
                null == email
                    ? _value.email
                    : email // ignore: cast_nullable_to_non_nullable
                        as String,
            displayName:
                null == displayName
                    ? _value.displayName
                    : displayName // ignore: cast_nullable_to_non_nullable
                        as String,
            role:
                null == role
                    ? _value.role
                    : role // ignore: cast_nullable_to_non_nullable
                        as UserRole,
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
            isActive:
                null == isActive
                    ? _value.isActive
                    : isActive // ignore: cast_nullable_to_non_nullable
                        as bool,
            photoUrl:
                freezed == photoUrl
                    ? _value.photoUrl
                    : photoUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
            phoneNumber:
                freezed == phoneNumber
                    ? _value.phoneNumber
                    : phoneNumber // ignore: cast_nullable_to_non_nullable
                        as String?,
            department:
                freezed == department
                    ? _value.department
                    : department // ignore: cast_nullable_to_non_nullable
                        as String?,
            position:
                freezed == position
                    ? _value.position
                    : position // ignore: cast_nullable_to_non_nullable
                        as String?,
            employeeId:
                freezed == employeeId
                    ? _value.employeeId
                    : employeeId // ignore: cast_nullable_to_non_nullable
                        as String?,
            lastLoginAt:
                freezed == lastLoginAt
                    ? _value.lastLoginAt
                    : lastLoginAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            mfaEnabled:
                freezed == mfaEnabled
                    ? _value.mfaEnabled
                    : mfaEnabled // ignore: cast_nullable_to_non_nullable
                        as bool?,
            createdBy:
                freezed == createdBy
                    ? _value.createdBy
                    : createdBy // ignore: cast_nullable_to_non_nullable
                        as String?,
            terminationDate:
                freezed == terminationDate
                    ? _value.terminationDate
                    : terminationDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            terminationReason:
                freezed == terminationReason
                    ? _value.terminationReason
                    : terminationReason // ignore: cast_nullable_to_non_nullable
                        as String?,
            terminationComments:
                freezed == terminationComments
                    ? _value.terminationComments
                    : terminationComments // ignore: cast_nullable_to_non_nullable
                        as String?,
            terminatedBy:
                freezed == terminatedBy
                    ? _value.terminatedBy
                    : terminatedBy // ignore: cast_nullable_to_non_nullable
                        as String?,
            lastWorkingDay:
                freezed == lastWorkingDay
                    ? _value.lastWorkingDay
                    : lastWorkingDay // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            reactivationDate:
                freezed == reactivationDate
                    ? _value.reactivationDate
                    : reactivationDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            reactivationReason:
                freezed == reactivationReason
                    ? _value.reactivationReason
                    : reactivationReason // ignore: cast_nullable_to_non_nullable
                        as String?,
            reactivationComments:
                freezed == reactivationComments
                    ? _value.reactivationComments
                    : reactivationComments // ignore: cast_nullable_to_non_nullable
                        as String?,
            reactivatedBy:
                freezed == reactivatedBy
                    ? _value.reactivatedBy
                    : reactivatedBy // ignore: cast_nullable_to_non_nullable
                        as String?,
            candidateId:
                freezed == candidateId
                    ? _value.candidateId
                    : candidateId // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
    _$UserModelImpl value,
    $Res Function(_$UserModelImpl) then,
  ) = __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String uid,
    String email,
    String displayName,
    @UserRoleConverter() UserRole role,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime updatedAt,
    bool isActive,
    String? photoUrl,
    String? phoneNumber,
    String? department,
    String? position,
    String? employeeId,
    @TimestampConverter() DateTime? lastLoginAt,
    bool? mfaEnabled,
    String? createdBy,
    @TimestampConverter() DateTime? terminationDate,
    String? terminationReason,
    String? terminationComments,
    String? terminatedBy,
    @TimestampConverter() DateTime? lastWorkingDay,
    @TimestampConverter() DateTime? reactivationDate,
    String? reactivationReason,
    String? reactivationComments,
    String? reactivatedBy,
    String? candidateId,
  });
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
    _$UserModelImpl _value,
    $Res Function(_$UserModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? email = null,
    Object? displayName = null,
    Object? role = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? isActive = null,
    Object? photoUrl = freezed,
    Object? phoneNumber = freezed,
    Object? department = freezed,
    Object? position = freezed,
    Object? employeeId = freezed,
    Object? lastLoginAt = freezed,
    Object? mfaEnabled = freezed,
    Object? createdBy = freezed,
    Object? terminationDate = freezed,
    Object? terminationReason = freezed,
    Object? terminationComments = freezed,
    Object? terminatedBy = freezed,
    Object? lastWorkingDay = freezed,
    Object? reactivationDate = freezed,
    Object? reactivationReason = freezed,
    Object? reactivationComments = freezed,
    Object? reactivatedBy = freezed,
    Object? candidateId = freezed,
  }) {
    return _then(
      _$UserModelImpl(
        uid:
            null == uid
                ? _value.uid
                : uid // ignore: cast_nullable_to_non_nullable
                    as String,
        email:
            null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                    as String,
        displayName:
            null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                    as String,
        role:
            null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                    as UserRole,
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
        isActive:
            null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                    as bool,
        photoUrl:
            freezed == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
        phoneNumber:
            freezed == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                    as String?,
        department:
            freezed == department
                ? _value.department
                : department // ignore: cast_nullable_to_non_nullable
                    as String?,
        position:
            freezed == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                    as String?,
        employeeId:
            freezed == employeeId
                ? _value.employeeId
                : employeeId // ignore: cast_nullable_to_non_nullable
                    as String?,
        lastLoginAt:
            freezed == lastLoginAt
                ? _value.lastLoginAt
                : lastLoginAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        mfaEnabled:
            freezed == mfaEnabled
                ? _value.mfaEnabled
                : mfaEnabled // ignore: cast_nullable_to_non_nullable
                    as bool?,
        createdBy:
            freezed == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                    as String?,
        terminationDate:
            freezed == terminationDate
                ? _value.terminationDate
                : terminationDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        terminationReason:
            freezed == terminationReason
                ? _value.terminationReason
                : terminationReason // ignore: cast_nullable_to_non_nullable
                    as String?,
        terminationComments:
            freezed == terminationComments
                ? _value.terminationComments
                : terminationComments // ignore: cast_nullable_to_non_nullable
                    as String?,
        terminatedBy:
            freezed == terminatedBy
                ? _value.terminatedBy
                : terminatedBy // ignore: cast_nullable_to_non_nullable
                    as String?,
        lastWorkingDay:
            freezed == lastWorkingDay
                ? _value.lastWorkingDay
                : lastWorkingDay // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        reactivationDate:
            freezed == reactivationDate
                ? _value.reactivationDate
                : reactivationDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        reactivationReason:
            freezed == reactivationReason
                ? _value.reactivationReason
                : reactivationReason // ignore: cast_nullable_to_non_nullable
                    as String?,
        reactivationComments:
            freezed == reactivationComments
                ? _value.reactivationComments
                : reactivationComments // ignore: cast_nullable_to_non_nullable
                    as String?,
        reactivatedBy:
            freezed == reactivatedBy
                ? _value.reactivatedBy
                : reactivatedBy // ignore: cast_nullable_to_non_nullable
                    as String?,
        candidateId:
            freezed == candidateId
                ? _value.candidateId
                : candidateId // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl implements _UserModel {
  const _$UserModelImpl({
    required this.uid,
    required this.email,
    required this.displayName,
    @UserRoleConverter() required this.role,
    @TimestampConverter() required this.createdAt,
    @TimestampConverter() required this.updatedAt,
    required this.isActive,
    this.photoUrl,
    this.phoneNumber,
    this.department,
    this.position,
    this.employeeId,
    @TimestampConverter() this.lastLoginAt,
    this.mfaEnabled,
    this.createdBy,
    @TimestampConverter() this.terminationDate,
    this.terminationReason,
    this.terminationComments,
    this.terminatedBy,
    @TimestampConverter() this.lastWorkingDay,
    @TimestampConverter() this.reactivationDate,
    this.reactivationReason,
    this.reactivationComments,
    this.reactivatedBy,
    this.candidateId,
  });

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  final String uid;
  @override
  final String email;
  @override
  final String displayName;
  @override
  @UserRoleConverter()
  final UserRole role;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime updatedAt;
  @override
  final bool isActive;
  @override
  final String? photoUrl;
  @override
  final String? phoneNumber;
  @override
  final String? department;
  @override
  final String? position;
  @override
  final String? employeeId;
  @override
  @TimestampConverter()
  final DateTime? lastLoginAt;
  @override
  final bool? mfaEnabled;
  @override
  final String? createdBy;
  // Optional termination fields
  @override
  @TimestampConverter()
  final DateTime? terminationDate;
  @override
  final String? terminationReason;
  @override
  final String? terminationComments;
  @override
  final String? terminatedBy;
  @override
  @TimestampConverter()
  final DateTime? lastWorkingDay;
  @override
  @TimestampConverter()
  final DateTime? reactivationDate;
  @override
  final String? reactivationReason;
  @override
  final String? reactivationComments;
  @override
  final String? reactivatedBy;
  // NEW FIELD
  @override
  final String? candidateId;

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, role: $role, createdAt: $createdAt, updatedAt: $updatedAt, isActive: $isActive, photoUrl: $photoUrl, phoneNumber: $phoneNumber, department: $department, position: $position, employeeId: $employeeId, lastLoginAt: $lastLoginAt, mfaEnabled: $mfaEnabled, createdBy: $createdBy, terminationDate: $terminationDate, terminationReason: $terminationReason, terminationComments: $terminationComments, terminatedBy: $terminatedBy, lastWorkingDay: $lastWorkingDay, reactivationDate: $reactivationDate, reactivationReason: $reactivationReason, reactivationComments: $reactivationComments, reactivatedBy: $reactivatedBy, candidateId: $candidateId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.department, department) ||
                other.department == department) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.lastLoginAt, lastLoginAt) ||
                other.lastLoginAt == lastLoginAt) &&
            (identical(other.mfaEnabled, mfaEnabled) ||
                other.mfaEnabled == mfaEnabled) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.terminationDate, terminationDate) ||
                other.terminationDate == terminationDate) &&
            (identical(other.terminationReason, terminationReason) ||
                other.terminationReason == terminationReason) &&
            (identical(other.terminationComments, terminationComments) ||
                other.terminationComments == terminationComments) &&
            (identical(other.terminatedBy, terminatedBy) ||
                other.terminatedBy == terminatedBy) &&
            (identical(other.lastWorkingDay, lastWorkingDay) ||
                other.lastWorkingDay == lastWorkingDay) &&
            (identical(other.reactivationDate, reactivationDate) ||
                other.reactivationDate == reactivationDate) &&
            (identical(other.reactivationReason, reactivationReason) ||
                other.reactivationReason == reactivationReason) &&
            (identical(other.reactivationComments, reactivationComments) ||
                other.reactivationComments == reactivationComments) &&
            (identical(other.reactivatedBy, reactivatedBy) ||
                other.reactivatedBy == reactivatedBy) &&
            (identical(other.candidateId, candidateId) ||
                other.candidateId == candidateId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    uid,
    email,
    displayName,
    role,
    createdAt,
    updatedAt,
    isActive,
    photoUrl,
    phoneNumber,
    department,
    position,
    employeeId,
    lastLoginAt,
    mfaEnabled,
    createdBy,
    terminationDate,
    terminationReason,
    terminationComments,
    terminatedBy,
    lastWorkingDay,
    reactivationDate,
    reactivationReason,
    reactivationComments,
    reactivatedBy,
    candidateId,
  ]);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(this);
  }
}

abstract class _UserModel implements UserModel {
  const factory _UserModel({
    required final String uid,
    required final String email,
    required final String displayName,
    @UserRoleConverter() required final UserRole role,
    @TimestampConverter() required final DateTime createdAt,
    @TimestampConverter() required final DateTime updatedAt,
    required final bool isActive,
    final String? photoUrl,
    final String? phoneNumber,
    final String? department,
    final String? position,
    final String? employeeId,
    @TimestampConverter() final DateTime? lastLoginAt,
    final bool? mfaEnabled,
    final String? createdBy,
    @TimestampConverter() final DateTime? terminationDate,
    final String? terminationReason,
    final String? terminationComments,
    final String? terminatedBy,
    @TimestampConverter() final DateTime? lastWorkingDay,
    @TimestampConverter() final DateTime? reactivationDate,
    final String? reactivationReason,
    final String? reactivationComments,
    final String? reactivatedBy,
    final String? candidateId,
  }) = _$UserModelImpl;

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  String get uid;
  @override
  String get email;
  @override
  String get displayName;
  @override
  @UserRoleConverter()
  UserRole get role;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt;
  @override
  bool get isActive;
  @override
  String? get photoUrl;
  @override
  String? get phoneNumber;
  @override
  String? get department;
  @override
  String? get position;
  @override
  String? get employeeId;
  @override
  @TimestampConverter()
  DateTime? get lastLoginAt;
  @override
  bool? get mfaEnabled;
  @override
  String? get createdBy; // Optional termination fields
  @override
  @TimestampConverter()
  DateTime? get terminationDate;
  @override
  String? get terminationReason;
  @override
  String? get terminationComments;
  @override
  String? get terminatedBy;
  @override
  @TimestampConverter()
  DateTime? get lastWorkingDay;
  @override
  @TimestampConverter()
  DateTime? get reactivationDate;
  @override
  String? get reactivationReason;
  @override
  String? get reactivationComments;
  @override
  String? get reactivatedBy; // NEW FIELD
  @override
  String? get candidateId;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
