// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'signature_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Signature _$SignatureFromJson(Map<String, dynamic> json) {
  return _Signature.fromJson(json);
}

/// @nodoc
mixin _$Signature {
  String get id => throw _privateConstructorUsedError;
  String get ownerUid =>
      throw _privateConstructorUsedError; // UID of director/authority
  String get ownerName =>
      throw _privateConstructorUsedError; // "Shila De Sarkar"
  String get imagePath =>
      throw _privateConstructorUsedError; // "signatures/director_1.png"
  bool get requiresApproval =>
      throw _privateConstructorUsedError; // Whether approval is needed before use
  List<String> get allowedLetterTypes =>
      throw _privateConstructorUsedError; // ["Offer Letter", "Experience"]
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError; // Additional metadata
  String? get title =>
      throw _privateConstructorUsedError; // "Director", "CEO", "HR Manager"
  String? get department => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  bool? get isActive => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this Signature to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Signature
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SignatureCopyWith<Signature> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SignatureCopyWith<$Res> {
  factory $SignatureCopyWith(Signature value, $Res Function(Signature) then) =
      _$SignatureCopyWithImpl<$Res, Signature>;
  @useResult
  $Res call({
    String id,
    String ownerUid,
    String ownerName,
    String imagePath,
    bool requiresApproval,
    List<String> allowedLetterTypes,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime updatedAt,
    String? title,
    String? department,
    String? email,
    String? phoneNumber,
    bool? isActive,
    String? notes,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$SignatureCopyWithImpl<$Res, $Val extends Signature>
    implements $SignatureCopyWith<$Res> {
  _$SignatureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Signature
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerUid = null,
    Object? ownerName = null,
    Object? imagePath = null,
    Object? requiresApproval = null,
    Object? allowedLetterTypes = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? title = freezed,
    Object? department = freezed,
    Object? email = freezed,
    Object? phoneNumber = freezed,
    Object? isActive = freezed,
    Object? notes = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            ownerUid:
                null == ownerUid
                    ? _value.ownerUid
                    : ownerUid // ignore: cast_nullable_to_non_nullable
                        as String,
            ownerName:
                null == ownerName
                    ? _value.ownerName
                    : ownerName // ignore: cast_nullable_to_non_nullable
                        as String,
            imagePath:
                null == imagePath
                    ? _value.imagePath
                    : imagePath // ignore: cast_nullable_to_non_nullable
                        as String,
            requiresApproval:
                null == requiresApproval
                    ? _value.requiresApproval
                    : requiresApproval // ignore: cast_nullable_to_non_nullable
                        as bool,
            allowedLetterTypes:
                null == allowedLetterTypes
                    ? _value.allowedLetterTypes
                    : allowedLetterTypes // ignore: cast_nullable_to_non_nullable
                        as List<String>,
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
            title:
                freezed == title
                    ? _value.title
                    : title // ignore: cast_nullable_to_non_nullable
                        as String?,
            department:
                freezed == department
                    ? _value.department
                    : department // ignore: cast_nullable_to_non_nullable
                        as String?,
            email:
                freezed == email
                    ? _value.email
                    : email // ignore: cast_nullable_to_non_nullable
                        as String?,
            phoneNumber:
                freezed == phoneNumber
                    ? _value.phoneNumber
                    : phoneNumber // ignore: cast_nullable_to_non_nullable
                        as String?,
            isActive:
                freezed == isActive
                    ? _value.isActive
                    : isActive // ignore: cast_nullable_to_non_nullable
                        as bool?,
            notes:
                freezed == notes
                    ? _value.notes
                    : notes // ignore: cast_nullable_to_non_nullable
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
abstract class _$$SignatureImplCopyWith<$Res>
    implements $SignatureCopyWith<$Res> {
  factory _$$SignatureImplCopyWith(
    _$SignatureImpl value,
    $Res Function(_$SignatureImpl) then,
  ) = __$$SignatureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String ownerUid,
    String ownerName,
    String imagePath,
    bool requiresApproval,
    List<String> allowedLetterTypes,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime updatedAt,
    String? title,
    String? department,
    String? email,
    String? phoneNumber,
    bool? isActive,
    String? notes,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$SignatureImplCopyWithImpl<$Res>
    extends _$SignatureCopyWithImpl<$Res, _$SignatureImpl>
    implements _$$SignatureImplCopyWith<$Res> {
  __$$SignatureImplCopyWithImpl(
    _$SignatureImpl _value,
    $Res Function(_$SignatureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Signature
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerUid = null,
    Object? ownerName = null,
    Object? imagePath = null,
    Object? requiresApproval = null,
    Object? allowedLetterTypes = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? title = freezed,
    Object? department = freezed,
    Object? email = freezed,
    Object? phoneNumber = freezed,
    Object? isActive = freezed,
    Object? notes = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$SignatureImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        ownerUid:
            null == ownerUid
                ? _value.ownerUid
                : ownerUid // ignore: cast_nullable_to_non_nullable
                    as String,
        ownerName:
            null == ownerName
                ? _value.ownerName
                : ownerName // ignore: cast_nullable_to_non_nullable
                    as String,
        imagePath:
            null == imagePath
                ? _value.imagePath
                : imagePath // ignore: cast_nullable_to_non_nullable
                    as String,
        requiresApproval:
            null == requiresApproval
                ? _value.requiresApproval
                : requiresApproval // ignore: cast_nullable_to_non_nullable
                    as bool,
        allowedLetterTypes:
            null == allowedLetterTypes
                ? _value._allowedLetterTypes
                : allowedLetterTypes // ignore: cast_nullable_to_non_nullable
                    as List<String>,
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
        title:
            freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                    as String?,
        department:
            freezed == department
                ? _value.department
                : department // ignore: cast_nullable_to_non_nullable
                    as String?,
        email:
            freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                    as String?,
        phoneNumber:
            freezed == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                    as String?,
        isActive:
            freezed == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                    as bool?,
        notes:
            freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
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
class _$SignatureImpl implements _Signature {
  const _$SignatureImpl({
    required this.id,
    required this.ownerUid,
    required this.ownerName,
    required this.imagePath,
    required this.requiresApproval,
    final List<String> allowedLetterTypes = const [],
    @TimestampConverter() required this.createdAt,
    @TimestampConverter() required this.updatedAt,
    this.title,
    this.department,
    this.email,
    this.phoneNumber,
    this.isActive,
    this.notes,
    final Map<String, dynamic>? metadata,
  }) : _allowedLetterTypes = allowedLetterTypes,
       _metadata = metadata;

  factory _$SignatureImpl.fromJson(Map<String, dynamic> json) =>
      _$$SignatureImplFromJson(json);

  @override
  final String id;
  @override
  final String ownerUid;
  // UID of director/authority
  @override
  final String ownerName;
  // "Shila De Sarkar"
  @override
  final String imagePath;
  // "signatures/director_1.png"
  @override
  final bool requiresApproval;
  // Whether approval is needed before use
  final List<String> _allowedLetterTypes;
  // Whether approval is needed before use
  @override
  @JsonKey()
  List<String> get allowedLetterTypes {
    if (_allowedLetterTypes is EqualUnmodifiableListView)
      return _allowedLetterTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allowedLetterTypes);
  }

  // ["Offer Letter", "Experience"]
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime updatedAt;
  // Additional metadata
  @override
  final String? title;
  // "Director", "CEO", "HR Manager"
  @override
  final String? department;
  @override
  final String? email;
  @override
  final String? phoneNumber;
  @override
  final bool? isActive;
  @override
  final String? notes;
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
    return 'Signature(id: $id, ownerUid: $ownerUid, ownerName: $ownerName, imagePath: $imagePath, requiresApproval: $requiresApproval, allowedLetterTypes: $allowedLetterTypes, createdAt: $createdAt, updatedAt: $updatedAt, title: $title, department: $department, email: $email, phoneNumber: $phoneNumber, isActive: $isActive, notes: $notes, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SignatureImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.ownerUid, ownerUid) ||
                other.ownerUid == ownerUid) &&
            (identical(other.ownerName, ownerName) ||
                other.ownerName == ownerName) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.requiresApproval, requiresApproval) ||
                other.requiresApproval == requiresApproval) &&
            const DeepCollectionEquality().equals(
              other._allowedLetterTypes,
              _allowedLetterTypes,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.department, department) ||
                other.department == department) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    ownerUid,
    ownerName,
    imagePath,
    requiresApproval,
    const DeepCollectionEquality().hash(_allowedLetterTypes),
    createdAt,
    updatedAt,
    title,
    department,
    email,
    phoneNumber,
    isActive,
    notes,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of Signature
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SignatureImplCopyWith<_$SignatureImpl> get copyWith =>
      __$$SignatureImplCopyWithImpl<_$SignatureImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SignatureImplToJson(this);
  }
}

abstract class _Signature implements Signature {
  const factory _Signature({
    required final String id,
    required final String ownerUid,
    required final String ownerName,
    required final String imagePath,
    required final bool requiresApproval,
    final List<String> allowedLetterTypes,
    @TimestampConverter() required final DateTime createdAt,
    @TimestampConverter() required final DateTime updatedAt,
    final String? title,
    final String? department,
    final String? email,
    final String? phoneNumber,
    final bool? isActive,
    final String? notes,
    final Map<String, dynamic>? metadata,
  }) = _$SignatureImpl;

  factory _Signature.fromJson(Map<String, dynamic> json) =
      _$SignatureImpl.fromJson;

  @override
  String get id;
  @override
  String get ownerUid; // UID of director/authority
  @override
  String get ownerName; // "Shila De Sarkar"
  @override
  String get imagePath; // "signatures/director_1.png"
  @override
  bool get requiresApproval; // Whether approval is needed before use
  @override
  List<String> get allowedLetterTypes; // ["Offer Letter", "Experience"]
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt; // Additional metadata
  @override
  String? get title; // "Director", "CEO", "HR Manager"
  @override
  String? get department;
  @override
  String? get email;
  @override
  String? get phoneNumber;
  @override
  bool? get isActive;
  @override
  String? get notes;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of Signature
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SignatureImplCopyWith<_$SignatureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
