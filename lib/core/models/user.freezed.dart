// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get firstName => throw _privateConstructorUsedError;
  String get lastName => throw _privateConstructorUsedError;
  UserRole get role => throw _privateConstructorUsedError;
  EmployeeStatus get status => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  String? get profileImageUrl => throw _privateConstructorUsedError;
  String? get department => throw _privateConstructorUsedError;
  String? get position => throw _privateConstructorUsedError;
  String? get managerId => throw _privateConstructorUsedError;
  DateTime? get dateOfJoining => throw _privateConstructorUsedError;
  DateTime? get lastLoginAt => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  bool get isEmailVerified => throw _privateConstructorUsedError;
  bool get isSuperAdmin => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call({
    String id,
    String email,
    String firstName,
    String lastName,
    UserRole role,
    EmployeeStatus status,
    String? phoneNumber,
    String? profileImageUrl,
    String? department,
    String? position,
    String? managerId,
    DateTime? dateOfJoining,
    DateTime? lastLoginAt,
    bool isActive,
    bool isEmailVerified,
    bool isSuperAdmin,
    DateTime createdAt,
    DateTime updatedAt,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? role = null,
    Object? status = null,
    Object? phoneNumber = freezed,
    Object? profileImageUrl = freezed,
    Object? department = freezed,
    Object? position = freezed,
    Object? managerId = freezed,
    Object? dateOfJoining = freezed,
    Object? lastLoginAt = freezed,
    Object? isActive = null,
    Object? isEmailVerified = null,
    Object? isSuperAdmin = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            email:
                null == email
                    ? _value.email
                    : email // ignore: cast_nullable_to_non_nullable
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
            phoneNumber:
                freezed == phoneNumber
                    ? _value.phoneNumber
                    : phoneNumber // ignore: cast_nullable_to_non_nullable
                        as String?,
            profileImageUrl:
                freezed == profileImageUrl
                    ? _value.profileImageUrl
                    : profileImageUrl // ignore: cast_nullable_to_non_nullable
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
            managerId:
                freezed == managerId
                    ? _value.managerId
                    : managerId // ignore: cast_nullable_to_non_nullable
                        as String?,
            dateOfJoining:
                freezed == dateOfJoining
                    ? _value.dateOfJoining
                    : dateOfJoining // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            lastLoginAt:
                freezed == lastLoginAt
                    ? _value.lastLoginAt
                    : lastLoginAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            isActive:
                null == isActive
                    ? _value.isActive
                    : isActive // ignore: cast_nullable_to_non_nullable
                        as bool,
            isEmailVerified:
                null == isEmailVerified
                    ? _value.isEmailVerified
                    : isEmailVerified // ignore: cast_nullable_to_non_nullable
                        as bool,
            isSuperAdmin:
                null == isSuperAdmin
                    ? _value.isSuperAdmin
                    : isSuperAdmin // ignore: cast_nullable_to_non_nullable
                        as bool,
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
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
    _$UserImpl value,
    $Res Function(_$UserImpl) then,
  ) = __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String email,
    String firstName,
    String lastName,
    UserRole role,
    EmployeeStatus status,
    String? phoneNumber,
    String? profileImageUrl,
    String? department,
    String? position,
    String? managerId,
    DateTime? dateOfJoining,
    DateTime? lastLoginAt,
    bool isActive,
    bool isEmailVerified,
    bool isSuperAdmin,
    DateTime createdAt,
    DateTime updatedAt,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
    : super(_value, _then);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? role = null,
    Object? status = null,
    Object? phoneNumber = freezed,
    Object? profileImageUrl = freezed,
    Object? department = freezed,
    Object? position = freezed,
    Object? managerId = freezed,
    Object? dateOfJoining = freezed,
    Object? lastLoginAt = freezed,
    Object? isActive = null,
    Object? isEmailVerified = null,
    Object? isSuperAdmin = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? metadata = freezed,
  }) {
    return _then(
      _$UserImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        email:
            null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
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
        phoneNumber:
            freezed == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                    as String?,
        profileImageUrl:
            freezed == profileImageUrl
                ? _value.profileImageUrl
                : profileImageUrl // ignore: cast_nullable_to_non_nullable
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
        managerId:
            freezed == managerId
                ? _value.managerId
                : managerId // ignore: cast_nullable_to_non_nullable
                    as String?,
        dateOfJoining:
            freezed == dateOfJoining
                ? _value.dateOfJoining
                : dateOfJoining // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        lastLoginAt:
            freezed == lastLoginAt
                ? _value.lastLoginAt
                : lastLoginAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        isActive:
            null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                    as bool,
        isEmailVerified:
            null == isEmailVerified
                ? _value.isEmailVerified
                : isEmailVerified // ignore: cast_nullable_to_non_nullable
                    as bool,
        isSuperAdmin:
            null == isSuperAdmin
                ? _value.isSuperAdmin
                : isSuperAdmin // ignore: cast_nullable_to_non_nullable
                    as bool,
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
class _$UserImpl extends _User {
  const _$UserImpl({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.status,
    this.phoneNumber,
    this.profileImageUrl,
    this.department,
    this.position,
    this.managerId,
    this.dateOfJoining,
    this.lastLoginAt,
    this.isActive = true,
    this.isEmailVerified = false,
    this.isSuperAdmin = false,
    required this.createdAt,
    required this.updatedAt,
    final Map<String, dynamic>? metadata,
  }) : _metadata = metadata,
       super._();

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final UserRole role;
  @override
  final EmployeeStatus status;
  @override
  final String? phoneNumber;
  @override
  final String? profileImageUrl;
  @override
  final String? department;
  @override
  final String? position;
  @override
  final String? managerId;
  @override
  final DateTime? dateOfJoining;
  @override
  final DateTime? lastLoginAt;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final bool isEmailVerified;
  @override
  @JsonKey()
  final bool isSuperAdmin;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
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
    return 'User(id: $id, email: $email, firstName: $firstName, lastName: $lastName, role: $role, status: $status, phoneNumber: $phoneNumber, profileImageUrl: $profileImageUrl, department: $department, position: $position, managerId: $managerId, dateOfJoining: $dateOfJoining, lastLoginAt: $lastLoginAt, isActive: $isActive, isEmailVerified: $isEmailVerified, isSuperAdmin: $isSuperAdmin, createdAt: $createdAt, updatedAt: $updatedAt, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl) &&
            (identical(other.department, department) ||
                other.department == department) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.managerId, managerId) ||
                other.managerId == managerId) &&
            (identical(other.dateOfJoining, dateOfJoining) ||
                other.dateOfJoining == dateOfJoining) &&
            (identical(other.lastLoginAt, lastLoginAt) ||
                other.lastLoginAt == lastLoginAt) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isEmailVerified, isEmailVerified) ||
                other.isEmailVerified == isEmailVerified) &&
            (identical(other.isSuperAdmin, isSuperAdmin) ||
                other.isSuperAdmin == isSuperAdmin) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    email,
    firstName,
    lastName,
    role,
    status,
    phoneNumber,
    profileImageUrl,
    department,
    position,
    managerId,
    dateOfJoining,
    lastLoginAt,
    isActive,
    isEmailVerified,
    isSuperAdmin,
    createdAt,
    updatedAt,
    const DeepCollectionEquality().hash(_metadata),
  ]);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(this);
  }
}

abstract class _User extends User {
  const factory _User({
    required final String id,
    required final String email,
    required final String firstName,
    required final String lastName,
    required final UserRole role,
    required final EmployeeStatus status,
    final String? phoneNumber,
    final String? profileImageUrl,
    final String? department,
    final String? position,
    final String? managerId,
    final DateTime? dateOfJoining,
    final DateTime? lastLoginAt,
    final bool isActive,
    final bool isEmailVerified,
    final bool isSuperAdmin,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final Map<String, dynamic>? metadata,
  }) = _$UserImpl;
  const _User._() : super._();

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override
  String get firstName;
  @override
  String get lastName;
  @override
  UserRole get role;
  @override
  EmployeeStatus get status;
  @override
  String? get phoneNumber;
  @override
  String? get profileImageUrl;
  @override
  String? get department;
  @override
  String? get position;
  @override
  String? get managerId;
  @override
  DateTime? get dateOfJoining;
  @override
  DateTime? get lastLoginAt;
  @override
  bool get isActive;
  @override
  bool get isEmailVerified;
  @override
  bool get isSuperAdmin;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
