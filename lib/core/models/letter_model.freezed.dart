// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'letter_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SignatureApproval _$SignatureApprovalFromJson(Map<String, dynamic> json) {
  return _SignatureApproval.fromJson(json);
}

/// @nodoc
mixin _$SignatureApproval {
  String get signatureId =>
      throw _privateConstructorUsedError; // ID of the signature authority
  String get signatureOwnerUid =>
      throw _privateConstructorUsedError; // UID of the signature owner
  String get signatureOwnerName =>
      throw _privateConstructorUsedError; // Name of the signature owner
  String get signatureTitle =>
      throw _privateConstructorUsedError; // Title of the signature owner (e.g., "Director")
  @SignatureStatusConverter()
  SignatureStatus get status => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get approvedAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get rejectedAt => throw _privateConstructorUsedError;
  String? get approvedBy =>
      throw _privateConstructorUsedError; // UID of who approved (usually the same as signatureOwnerUid)
  String? get approvedByName =>
      throw _privateConstructorUsedError; // Name of who approved
  String? get rejectionReason => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this SignatureApproval to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SignatureApproval
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SignatureApprovalCopyWith<SignatureApproval> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SignatureApprovalCopyWith<$Res> {
  factory $SignatureApprovalCopyWith(
    SignatureApproval value,
    $Res Function(SignatureApproval) then,
  ) = _$SignatureApprovalCopyWithImpl<$Res, SignatureApproval>;
  @useResult
  $Res call({
    String signatureId,
    String signatureOwnerUid,
    String signatureOwnerName,
    String signatureTitle,
    @SignatureStatusConverter() SignatureStatus status,
    @TimestampConverter() DateTime? approvedAt,
    @TimestampConverter() DateTime? rejectedAt,
    String? approvedBy,
    String? approvedByName,
    String? rejectionReason,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime updatedAt,
  });

  $SignatureStatusCopyWith<$Res> get status;
}

/// @nodoc
class _$SignatureApprovalCopyWithImpl<$Res, $Val extends SignatureApproval>
    implements $SignatureApprovalCopyWith<$Res> {
  _$SignatureApprovalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SignatureApproval
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? signatureId = null,
    Object? signatureOwnerUid = null,
    Object? signatureOwnerName = null,
    Object? signatureTitle = null,
    Object? status = null,
    Object? approvedAt = freezed,
    Object? rejectedAt = freezed,
    Object? approvedBy = freezed,
    Object? approvedByName = freezed,
    Object? rejectionReason = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            signatureId:
                null == signatureId
                    ? _value.signatureId
                    : signatureId // ignore: cast_nullable_to_non_nullable
                        as String,
            signatureOwnerUid:
                null == signatureOwnerUid
                    ? _value.signatureOwnerUid
                    : signatureOwnerUid // ignore: cast_nullable_to_non_nullable
                        as String,
            signatureOwnerName:
                null == signatureOwnerName
                    ? _value.signatureOwnerName
                    : signatureOwnerName // ignore: cast_nullable_to_non_nullable
                        as String,
            signatureTitle:
                null == signatureTitle
                    ? _value.signatureTitle
                    : signatureTitle // ignore: cast_nullable_to_non_nullable
                        as String,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as SignatureStatus,
            approvedAt:
                freezed == approvedAt
                    ? _value.approvedAt
                    : approvedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            rejectedAt:
                freezed == rejectedAt
                    ? _value.rejectedAt
                    : rejectedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            approvedBy:
                freezed == approvedBy
                    ? _value.approvedBy
                    : approvedBy // ignore: cast_nullable_to_non_nullable
                        as String?,
            approvedByName:
                freezed == approvedByName
                    ? _value.approvedByName
                    : approvedByName // ignore: cast_nullable_to_non_nullable
                        as String?,
            rejectionReason:
                freezed == rejectionReason
                    ? _value.rejectionReason
                    : rejectionReason // ignore: cast_nullable_to_non_nullable
                        as String?,
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
          )
          as $Val,
    );
  }

  /// Create a copy of SignatureApproval
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SignatureStatusCopyWith<$Res> get status {
    return $SignatureStatusCopyWith<$Res>(_value.status, (value) {
      return _then(_value.copyWith(status: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SignatureApprovalImplCopyWith<$Res>
    implements $SignatureApprovalCopyWith<$Res> {
  factory _$$SignatureApprovalImplCopyWith(
    _$SignatureApprovalImpl value,
    $Res Function(_$SignatureApprovalImpl) then,
  ) = __$$SignatureApprovalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String signatureId,
    String signatureOwnerUid,
    String signatureOwnerName,
    String signatureTitle,
    @SignatureStatusConverter() SignatureStatus status,
    @TimestampConverter() DateTime? approvedAt,
    @TimestampConverter() DateTime? rejectedAt,
    String? approvedBy,
    String? approvedByName,
    String? rejectionReason,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime updatedAt,
  });

  @override
  $SignatureStatusCopyWith<$Res> get status;
}

/// @nodoc
class __$$SignatureApprovalImplCopyWithImpl<$Res>
    extends _$SignatureApprovalCopyWithImpl<$Res, _$SignatureApprovalImpl>
    implements _$$SignatureApprovalImplCopyWith<$Res> {
  __$$SignatureApprovalImplCopyWithImpl(
    _$SignatureApprovalImpl _value,
    $Res Function(_$SignatureApprovalImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SignatureApproval
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? signatureId = null,
    Object? signatureOwnerUid = null,
    Object? signatureOwnerName = null,
    Object? signatureTitle = null,
    Object? status = null,
    Object? approvedAt = freezed,
    Object? rejectedAt = freezed,
    Object? approvedBy = freezed,
    Object? approvedByName = freezed,
    Object? rejectionReason = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$SignatureApprovalImpl(
        signatureId:
            null == signatureId
                ? _value.signatureId
                : signatureId // ignore: cast_nullable_to_non_nullable
                    as String,
        signatureOwnerUid:
            null == signatureOwnerUid
                ? _value.signatureOwnerUid
                : signatureOwnerUid // ignore: cast_nullable_to_non_nullable
                    as String,
        signatureOwnerName:
            null == signatureOwnerName
                ? _value.signatureOwnerName
                : signatureOwnerName // ignore: cast_nullable_to_non_nullable
                    as String,
        signatureTitle:
            null == signatureTitle
                ? _value.signatureTitle
                : signatureTitle // ignore: cast_nullable_to_non_nullable
                    as String,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as SignatureStatus,
        approvedAt:
            freezed == approvedAt
                ? _value.approvedAt
                : approvedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        rejectedAt:
            freezed == rejectedAt
                ? _value.rejectedAt
                : rejectedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        approvedBy:
            freezed == approvedBy
                ? _value.approvedBy
                : approvedBy // ignore: cast_nullable_to_non_nullable
                    as String?,
        approvedByName:
            freezed == approvedByName
                ? _value.approvedByName
                : approvedByName // ignore: cast_nullable_to_non_nullable
                    as String?,
        rejectionReason:
            freezed == rejectionReason
                ? _value.rejectionReason
                : rejectionReason // ignore: cast_nullable_to_non_nullable
                    as String?,
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SignatureApprovalImpl implements _SignatureApproval {
  const _$SignatureApprovalImpl({
    required this.signatureId,
    required this.signatureOwnerUid,
    required this.signatureOwnerName,
    required this.signatureTitle,
    @SignatureStatusConverter() required this.status,
    @TimestampConverter() this.approvedAt,
    @TimestampConverter() this.rejectedAt,
    this.approvedBy,
    this.approvedByName,
    this.rejectionReason,
    @TimestampConverter() required this.createdAt,
    @TimestampConverter() required this.updatedAt,
  });

  factory _$SignatureApprovalImpl.fromJson(Map<String, dynamic> json) =>
      _$$SignatureApprovalImplFromJson(json);

  @override
  final String signatureId;
  // ID of the signature authority
  @override
  final String signatureOwnerUid;
  // UID of the signature owner
  @override
  final String signatureOwnerName;
  // Name of the signature owner
  @override
  final String signatureTitle;
  // Title of the signature owner (e.g., "Director")
  @override
  @SignatureStatusConverter()
  final SignatureStatus status;
  @override
  @TimestampConverter()
  final DateTime? approvedAt;
  @override
  @TimestampConverter()
  final DateTime? rejectedAt;
  @override
  final String? approvedBy;
  // UID of who approved (usually the same as signatureOwnerUid)
  @override
  final String? approvedByName;
  // Name of who approved
  @override
  final String? rejectionReason;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime updatedAt;

  @override
  String toString() {
    return 'SignatureApproval(signatureId: $signatureId, signatureOwnerUid: $signatureOwnerUid, signatureOwnerName: $signatureOwnerName, signatureTitle: $signatureTitle, status: $status, approvedAt: $approvedAt, rejectedAt: $rejectedAt, approvedBy: $approvedBy, approvedByName: $approvedByName, rejectionReason: $rejectionReason, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SignatureApprovalImpl &&
            (identical(other.signatureId, signatureId) ||
                other.signatureId == signatureId) &&
            (identical(other.signatureOwnerUid, signatureOwnerUid) ||
                other.signatureOwnerUid == signatureOwnerUid) &&
            (identical(other.signatureOwnerName, signatureOwnerName) ||
                other.signatureOwnerName == signatureOwnerName) &&
            (identical(other.signatureTitle, signatureTitle) ||
                other.signatureTitle == signatureTitle) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.approvedAt, approvedAt) ||
                other.approvedAt == approvedAt) &&
            (identical(other.rejectedAt, rejectedAt) ||
                other.rejectedAt == rejectedAt) &&
            (identical(other.approvedBy, approvedBy) ||
                other.approvedBy == approvedBy) &&
            (identical(other.approvedByName, approvedByName) ||
                other.approvedByName == approvedByName) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    signatureId,
    signatureOwnerUid,
    signatureOwnerName,
    signatureTitle,
    status,
    approvedAt,
    rejectedAt,
    approvedBy,
    approvedByName,
    rejectionReason,
    createdAt,
    updatedAt,
  );

  /// Create a copy of SignatureApproval
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SignatureApprovalImplCopyWith<_$SignatureApprovalImpl> get copyWith =>
      __$$SignatureApprovalImplCopyWithImpl<_$SignatureApprovalImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SignatureApprovalImplToJson(this);
  }
}

abstract class _SignatureApproval implements SignatureApproval {
  const factory _SignatureApproval({
    required final String signatureId,
    required final String signatureOwnerUid,
    required final String signatureOwnerName,
    required final String signatureTitle,
    @SignatureStatusConverter() required final SignatureStatus status,
    @TimestampConverter() final DateTime? approvedAt,
    @TimestampConverter() final DateTime? rejectedAt,
    final String? approvedBy,
    final String? approvedByName,
    final String? rejectionReason,
    @TimestampConverter() required final DateTime createdAt,
    @TimestampConverter() required final DateTime updatedAt,
  }) = _$SignatureApprovalImpl;

  factory _SignatureApproval.fromJson(Map<String, dynamic> json) =
      _$SignatureApprovalImpl.fromJson;

  @override
  String get signatureId; // ID of the signature authority
  @override
  String get signatureOwnerUid; // UID of the signature owner
  @override
  String get signatureOwnerName; // Name of the signature owner
  @override
  String get signatureTitle; // Title of the signature owner (e.g., "Director")
  @override
  @SignatureStatusConverter()
  SignatureStatus get status;
  @override
  @TimestampConverter()
  DateTime? get approvedAt;
  @override
  @TimestampConverter()
  DateTime? get rejectedAt;
  @override
  String? get approvedBy; // UID of who approved (usually the same as signatureOwnerUid)
  @override
  String? get approvedByName; // Name of who approved
  @override
  String? get rejectionReason;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt;

  /// Create a copy of SignatureApproval
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SignatureApprovalImplCopyWith<_$SignatureApprovalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Letter _$LetterFromJson(Map<String, dynamic> json) {
  return _Letter.fromJson(json);
}

/// @nodoc
mixin _$Letter {
  String get id => throw _privateConstructorUsedError;
  String get type =>
      throw _privateConstructorUsedError; // Offer Letter, Appointment Letter, etc.
  String get content =>
      throw _privateConstructorUsedError; // GPT-generated content
  String get employeeName => throw _privateConstructorUsedError;
  String get employeeEmail => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError; // userId
  List<String> get signatureAuthorityUids =>
      throw _privateConstructorUsedError; // Multiple director/authority UIDs
  @LetterStatusConverter()
  LetterStatus get letterStatus => throw _privateConstructorUsedError;
  @SignatureStatusConverter()
  SignatureStatus get signatureStatus => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError; // PDF and storage information
  String? get signedPdfPath =>
      throw _privateConstructorUsedError; // letters/{letterId}/offer.pdf
  String? get signedPdfUrl =>
      throw _privateConstructorUsedError; // Supabase signed URL (deprecated - generated on demand)
  String? get storedIn =>
      throw _privateConstructorUsedError; // "supabase.process"
  // Timestamps for workflow tracking
  @TimestampConverter()
  DateTime? get submittedForApprovalAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get approvedAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get rejectedAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get sentAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get acceptedAt => throw _privateConstructorUsedError; // Additional metadata
  String? get rejectionReason => throw _privateConstructorUsedError;
  String? get sentVia =>
      throw _privateConstructorUsedError; // "email", "hand-delivered", etc.
  String? get sentTo =>
      throw _privateConstructorUsedError; // recipient email or contact info
  String? get notes => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  String? get headerId => throw _privateConstructorUsedError;
  String? get footerId => throw _privateConstructorUsedError;
  String? get logoId =>
      throw _privateConstructorUsedError; // Individual signature approvals tracking
  List<SignatureApproval> get signatureApprovals =>
      throw _privateConstructorUsedError;

  /// Serializes this Letter to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Letter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LetterCopyWith<Letter> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LetterCopyWith<$Res> {
  factory $LetterCopyWith(Letter value, $Res Function(Letter) then) =
      _$LetterCopyWithImpl<$Res, Letter>;
  @useResult
  $Res call({
    String id,
    String type,
    String content,
    String employeeName,
    String employeeEmail,
    String createdBy,
    List<String> signatureAuthorityUids,
    @LetterStatusConverter() LetterStatus letterStatus,
    @SignatureStatusConverter() SignatureStatus signatureStatus,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime updatedAt,
    String? signedPdfPath,
    String? signedPdfUrl,
    String? storedIn,
    @TimestampConverter() DateTime? submittedForApprovalAt,
    @TimestampConverter() DateTime? approvedAt,
    @TimestampConverter() DateTime? rejectedAt,
    @TimestampConverter() DateTime? sentAt,
    @TimestampConverter() DateTime? acceptedAt,
    String? rejectionReason,
    String? sentVia,
    String? sentTo,
    String? notes,
    Map<String, dynamic>? metadata,
    String? headerId,
    String? footerId,
    String? logoId,
    List<SignatureApproval> signatureApprovals,
  });

  $LetterStatusCopyWith<$Res> get letterStatus;
  $SignatureStatusCopyWith<$Res> get signatureStatus;
}

/// @nodoc
class _$LetterCopyWithImpl<$Res, $Val extends Letter>
    implements $LetterCopyWith<$Res> {
  _$LetterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Letter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? content = null,
    Object? employeeName = null,
    Object? employeeEmail = null,
    Object? createdBy = null,
    Object? signatureAuthorityUids = null,
    Object? letterStatus = null,
    Object? signatureStatus = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? signedPdfPath = freezed,
    Object? signedPdfUrl = freezed,
    Object? storedIn = freezed,
    Object? submittedForApprovalAt = freezed,
    Object? approvedAt = freezed,
    Object? rejectedAt = freezed,
    Object? sentAt = freezed,
    Object? acceptedAt = freezed,
    Object? rejectionReason = freezed,
    Object? sentVia = freezed,
    Object? sentTo = freezed,
    Object? notes = freezed,
    Object? metadata = freezed,
    Object? headerId = freezed,
    Object? footerId = freezed,
    Object? logoId = freezed,
    Object? signatureApprovals = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as String,
            content:
                null == content
                    ? _value.content
                    : content // ignore: cast_nullable_to_non_nullable
                        as String,
            employeeName:
                null == employeeName
                    ? _value.employeeName
                    : employeeName // ignore: cast_nullable_to_non_nullable
                        as String,
            employeeEmail:
                null == employeeEmail
                    ? _value.employeeEmail
                    : employeeEmail // ignore: cast_nullable_to_non_nullable
                        as String,
            createdBy:
                null == createdBy
                    ? _value.createdBy
                    : createdBy // ignore: cast_nullable_to_non_nullable
                        as String,
            signatureAuthorityUids:
                null == signatureAuthorityUids
                    ? _value.signatureAuthorityUids
                    : signatureAuthorityUids // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            letterStatus:
                null == letterStatus
                    ? _value.letterStatus
                    : letterStatus // ignore: cast_nullable_to_non_nullable
                        as LetterStatus,
            signatureStatus:
                null == signatureStatus
                    ? _value.signatureStatus
                    : signatureStatus // ignore: cast_nullable_to_non_nullable
                        as SignatureStatus,
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
            signedPdfPath:
                freezed == signedPdfPath
                    ? _value.signedPdfPath
                    : signedPdfPath // ignore: cast_nullable_to_non_nullable
                        as String?,
            signedPdfUrl:
                freezed == signedPdfUrl
                    ? _value.signedPdfUrl
                    : signedPdfUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
            storedIn:
                freezed == storedIn
                    ? _value.storedIn
                    : storedIn // ignore: cast_nullable_to_non_nullable
                        as String?,
            submittedForApprovalAt:
                freezed == submittedForApprovalAt
                    ? _value.submittedForApprovalAt
                    : submittedForApprovalAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            approvedAt:
                freezed == approvedAt
                    ? _value.approvedAt
                    : approvedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            rejectedAt:
                freezed == rejectedAt
                    ? _value.rejectedAt
                    : rejectedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            sentAt:
                freezed == sentAt
                    ? _value.sentAt
                    : sentAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            acceptedAt:
                freezed == acceptedAt
                    ? _value.acceptedAt
                    : acceptedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            rejectionReason:
                freezed == rejectionReason
                    ? _value.rejectionReason
                    : rejectionReason // ignore: cast_nullable_to_non_nullable
                        as String?,
            sentVia:
                freezed == sentVia
                    ? _value.sentVia
                    : sentVia // ignore: cast_nullable_to_non_nullable
                        as String?,
            sentTo:
                freezed == sentTo
                    ? _value.sentTo
                    : sentTo // ignore: cast_nullable_to_non_nullable
                        as String?,
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
            headerId:
                freezed == headerId
                    ? _value.headerId
                    : headerId // ignore: cast_nullable_to_non_nullable
                        as String?,
            footerId:
                freezed == footerId
                    ? _value.footerId
                    : footerId // ignore: cast_nullable_to_non_nullable
                        as String?,
            logoId:
                freezed == logoId
                    ? _value.logoId
                    : logoId // ignore: cast_nullable_to_non_nullable
                        as String?,
            signatureApprovals:
                null == signatureApprovals
                    ? _value.signatureApprovals
                    : signatureApprovals // ignore: cast_nullable_to_non_nullable
                        as List<SignatureApproval>,
          )
          as $Val,
    );
  }

  /// Create a copy of Letter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LetterStatusCopyWith<$Res> get letterStatus {
    return $LetterStatusCopyWith<$Res>(_value.letterStatus, (value) {
      return _then(_value.copyWith(letterStatus: value) as $Val);
    });
  }

  /// Create a copy of Letter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SignatureStatusCopyWith<$Res> get signatureStatus {
    return $SignatureStatusCopyWith<$Res>(_value.signatureStatus, (value) {
      return _then(_value.copyWith(signatureStatus: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LetterImplCopyWith<$Res> implements $LetterCopyWith<$Res> {
  factory _$$LetterImplCopyWith(
    _$LetterImpl value,
    $Res Function(_$LetterImpl) then,
  ) = __$$LetterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String type,
    String content,
    String employeeName,
    String employeeEmail,
    String createdBy,
    List<String> signatureAuthorityUids,
    @LetterStatusConverter() LetterStatus letterStatus,
    @SignatureStatusConverter() SignatureStatus signatureStatus,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime updatedAt,
    String? signedPdfPath,
    String? signedPdfUrl,
    String? storedIn,
    @TimestampConverter() DateTime? submittedForApprovalAt,
    @TimestampConverter() DateTime? approvedAt,
    @TimestampConverter() DateTime? rejectedAt,
    @TimestampConverter() DateTime? sentAt,
    @TimestampConverter() DateTime? acceptedAt,
    String? rejectionReason,
    String? sentVia,
    String? sentTo,
    String? notes,
    Map<String, dynamic>? metadata,
    String? headerId,
    String? footerId,
    String? logoId,
    List<SignatureApproval> signatureApprovals,
  });

  @override
  $LetterStatusCopyWith<$Res> get letterStatus;
  @override
  $SignatureStatusCopyWith<$Res> get signatureStatus;
}

/// @nodoc
class __$$LetterImplCopyWithImpl<$Res>
    extends _$LetterCopyWithImpl<$Res, _$LetterImpl>
    implements _$$LetterImplCopyWith<$Res> {
  __$$LetterImplCopyWithImpl(
    _$LetterImpl _value,
    $Res Function(_$LetterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Letter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? content = null,
    Object? employeeName = null,
    Object? employeeEmail = null,
    Object? createdBy = null,
    Object? signatureAuthorityUids = null,
    Object? letterStatus = null,
    Object? signatureStatus = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? signedPdfPath = freezed,
    Object? signedPdfUrl = freezed,
    Object? storedIn = freezed,
    Object? submittedForApprovalAt = freezed,
    Object? approvedAt = freezed,
    Object? rejectedAt = freezed,
    Object? sentAt = freezed,
    Object? acceptedAt = freezed,
    Object? rejectionReason = freezed,
    Object? sentVia = freezed,
    Object? sentTo = freezed,
    Object? notes = freezed,
    Object? metadata = freezed,
    Object? headerId = freezed,
    Object? footerId = freezed,
    Object? logoId = freezed,
    Object? signatureApprovals = null,
  }) {
    return _then(
      _$LetterImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as String,
        content:
            null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                    as String,
        employeeName:
            null == employeeName
                ? _value.employeeName
                : employeeName // ignore: cast_nullable_to_non_nullable
                    as String,
        employeeEmail:
            null == employeeEmail
                ? _value.employeeEmail
                : employeeEmail // ignore: cast_nullable_to_non_nullable
                    as String,
        createdBy:
            null == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                    as String,
        signatureAuthorityUids:
            null == signatureAuthorityUids
                ? _value._signatureAuthorityUids
                : signatureAuthorityUids // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        letterStatus:
            null == letterStatus
                ? _value.letterStatus
                : letterStatus // ignore: cast_nullable_to_non_nullable
                    as LetterStatus,
        signatureStatus:
            null == signatureStatus
                ? _value.signatureStatus
                : signatureStatus // ignore: cast_nullable_to_non_nullable
                    as SignatureStatus,
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
        signedPdfPath:
            freezed == signedPdfPath
                ? _value.signedPdfPath
                : signedPdfPath // ignore: cast_nullable_to_non_nullable
                    as String?,
        signedPdfUrl:
            freezed == signedPdfUrl
                ? _value.signedPdfUrl
                : signedPdfUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
        storedIn:
            freezed == storedIn
                ? _value.storedIn
                : storedIn // ignore: cast_nullable_to_non_nullable
                    as String?,
        submittedForApprovalAt:
            freezed == submittedForApprovalAt
                ? _value.submittedForApprovalAt
                : submittedForApprovalAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        approvedAt:
            freezed == approvedAt
                ? _value.approvedAt
                : approvedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        rejectedAt:
            freezed == rejectedAt
                ? _value.rejectedAt
                : rejectedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        sentAt:
            freezed == sentAt
                ? _value.sentAt
                : sentAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        acceptedAt:
            freezed == acceptedAt
                ? _value.acceptedAt
                : acceptedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        rejectionReason:
            freezed == rejectionReason
                ? _value.rejectionReason
                : rejectionReason // ignore: cast_nullable_to_non_nullable
                    as String?,
        sentVia:
            freezed == sentVia
                ? _value.sentVia
                : sentVia // ignore: cast_nullable_to_non_nullable
                    as String?,
        sentTo:
            freezed == sentTo
                ? _value.sentTo
                : sentTo // ignore: cast_nullable_to_non_nullable
                    as String?,
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
        headerId:
            freezed == headerId
                ? _value.headerId
                : headerId // ignore: cast_nullable_to_non_nullable
                    as String?,
        footerId:
            freezed == footerId
                ? _value.footerId
                : footerId // ignore: cast_nullable_to_non_nullable
                    as String?,
        logoId:
            freezed == logoId
                ? _value.logoId
                : logoId // ignore: cast_nullable_to_non_nullable
                    as String?,
        signatureApprovals:
            null == signatureApprovals
                ? _value._signatureApprovals
                : signatureApprovals // ignore: cast_nullable_to_non_nullable
                    as List<SignatureApproval>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LetterImpl implements _Letter {
  const _$LetterImpl({
    required this.id,
    required this.type,
    required this.content,
    required this.employeeName,
    required this.employeeEmail,
    required this.createdBy,
    final List<String> signatureAuthorityUids = const [],
    @LetterStatusConverter() required this.letterStatus,
    @SignatureStatusConverter() required this.signatureStatus,
    @TimestampConverter() required this.createdAt,
    @TimestampConverter() required this.updatedAt,
    this.signedPdfPath,
    this.signedPdfUrl,
    this.storedIn,
    @TimestampConverter() this.submittedForApprovalAt,
    @TimestampConverter() this.approvedAt,
    @TimestampConverter() this.rejectedAt,
    @TimestampConverter() this.sentAt,
    @TimestampConverter() this.acceptedAt,
    this.rejectionReason,
    this.sentVia,
    this.sentTo,
    this.notes,
    final Map<String, dynamic>? metadata,
    this.headerId,
    this.footerId,
    this.logoId,
    final List<SignatureApproval> signatureApprovals = const [],
  }) : _signatureAuthorityUids = signatureAuthorityUids,
       _metadata = metadata,
       _signatureApprovals = signatureApprovals;

  factory _$LetterImpl.fromJson(Map<String, dynamic> json) =>
      _$$LetterImplFromJson(json);

  @override
  final String id;
  @override
  final String type;
  // Offer Letter, Appointment Letter, etc.
  @override
  final String content;
  // GPT-generated content
  @override
  final String employeeName;
  @override
  final String employeeEmail;
  @override
  final String createdBy;
  // userId
  final List<String> _signatureAuthorityUids;
  // userId
  @override
  @JsonKey()
  List<String> get signatureAuthorityUids {
    if (_signatureAuthorityUids is EqualUnmodifiableListView)
      return _signatureAuthorityUids;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_signatureAuthorityUids);
  }

  // Multiple director/authority UIDs
  @override
  @LetterStatusConverter()
  final LetterStatus letterStatus;
  @override
  @SignatureStatusConverter()
  final SignatureStatus signatureStatus;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime updatedAt;
  // PDF and storage information
  @override
  final String? signedPdfPath;
  // letters/{letterId}/offer.pdf
  @override
  final String? signedPdfUrl;
  // Supabase signed URL (deprecated - generated on demand)
  @override
  final String? storedIn;
  // "supabase.process"
  // Timestamps for workflow tracking
  @override
  @TimestampConverter()
  final DateTime? submittedForApprovalAt;
  @override
  @TimestampConverter()
  final DateTime? approvedAt;
  @override
  @TimestampConverter()
  final DateTime? rejectedAt;
  @override
  @TimestampConverter()
  final DateTime? sentAt;
  @override
  @TimestampConverter()
  final DateTime? acceptedAt;
  // Additional metadata
  @override
  final String? rejectionReason;
  @override
  final String? sentVia;
  // "email", "hand-delivered", etc.
  @override
  final String? sentTo;
  // recipient email or contact info
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
  final String? headerId;
  @override
  final String? footerId;
  @override
  final String? logoId;
  // Individual signature approvals tracking
  final List<SignatureApproval> _signatureApprovals;
  // Individual signature approvals tracking
  @override
  @JsonKey()
  List<SignatureApproval> get signatureApprovals {
    if (_signatureApprovals is EqualUnmodifiableListView)
      return _signatureApprovals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_signatureApprovals);
  }

  @override
  String toString() {
    return 'Letter(id: $id, type: $type, content: $content, employeeName: $employeeName, employeeEmail: $employeeEmail, createdBy: $createdBy, signatureAuthorityUids: $signatureAuthorityUids, letterStatus: $letterStatus, signatureStatus: $signatureStatus, createdAt: $createdAt, updatedAt: $updatedAt, signedPdfPath: $signedPdfPath, signedPdfUrl: $signedPdfUrl, storedIn: $storedIn, submittedForApprovalAt: $submittedForApprovalAt, approvedAt: $approvedAt, rejectedAt: $rejectedAt, sentAt: $sentAt, acceptedAt: $acceptedAt, rejectionReason: $rejectionReason, sentVia: $sentVia, sentTo: $sentTo, notes: $notes, metadata: $metadata, headerId: $headerId, footerId: $footerId, logoId: $logoId, signatureApprovals: $signatureApprovals)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LetterImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.employeeName, employeeName) ||
                other.employeeName == employeeName) &&
            (identical(other.employeeEmail, employeeEmail) ||
                other.employeeEmail == employeeEmail) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            const DeepCollectionEquality().equals(
              other._signatureAuthorityUids,
              _signatureAuthorityUids,
            ) &&
            (identical(other.letterStatus, letterStatus) ||
                other.letterStatus == letterStatus) &&
            (identical(other.signatureStatus, signatureStatus) ||
                other.signatureStatus == signatureStatus) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.signedPdfPath, signedPdfPath) ||
                other.signedPdfPath == signedPdfPath) &&
            (identical(other.signedPdfUrl, signedPdfUrl) ||
                other.signedPdfUrl == signedPdfUrl) &&
            (identical(other.storedIn, storedIn) ||
                other.storedIn == storedIn) &&
            (identical(other.submittedForApprovalAt, submittedForApprovalAt) ||
                other.submittedForApprovalAt == submittedForApprovalAt) &&
            (identical(other.approvedAt, approvedAt) ||
                other.approvedAt == approvedAt) &&
            (identical(other.rejectedAt, rejectedAt) ||
                other.rejectedAt == rejectedAt) &&
            (identical(other.sentAt, sentAt) || other.sentAt == sentAt) &&
            (identical(other.acceptedAt, acceptedAt) ||
                other.acceptedAt == acceptedAt) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
            (identical(other.sentVia, sentVia) || other.sentVia == sentVia) &&
            (identical(other.sentTo, sentTo) || other.sentTo == sentTo) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.headerId, headerId) ||
                other.headerId == headerId) &&
            (identical(other.footerId, footerId) ||
                other.footerId == footerId) &&
            (identical(other.logoId, logoId) || other.logoId == logoId) &&
            const DeepCollectionEquality().equals(
              other._signatureApprovals,
              _signatureApprovals,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    type,
    content,
    employeeName,
    employeeEmail,
    createdBy,
    const DeepCollectionEquality().hash(_signatureAuthorityUids),
    letterStatus,
    signatureStatus,
    createdAt,
    updatedAt,
    signedPdfPath,
    signedPdfUrl,
    storedIn,
    submittedForApprovalAt,
    approvedAt,
    rejectedAt,
    sentAt,
    acceptedAt,
    rejectionReason,
    sentVia,
    sentTo,
    notes,
    const DeepCollectionEquality().hash(_metadata),
    headerId,
    footerId,
    logoId,
    const DeepCollectionEquality().hash(_signatureApprovals),
  ]);

  /// Create a copy of Letter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LetterImplCopyWith<_$LetterImpl> get copyWith =>
      __$$LetterImplCopyWithImpl<_$LetterImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LetterImplToJson(this);
  }
}

abstract class _Letter implements Letter {
  const factory _Letter({
    required final String id,
    required final String type,
    required final String content,
    required final String employeeName,
    required final String employeeEmail,
    required final String createdBy,
    final List<String> signatureAuthorityUids,
    @LetterStatusConverter() required final LetterStatus letterStatus,
    @SignatureStatusConverter() required final SignatureStatus signatureStatus,
    @TimestampConverter() required final DateTime createdAt,
    @TimestampConverter() required final DateTime updatedAt,
    final String? signedPdfPath,
    final String? signedPdfUrl,
    final String? storedIn,
    @TimestampConverter() final DateTime? submittedForApprovalAt,
    @TimestampConverter() final DateTime? approvedAt,
    @TimestampConverter() final DateTime? rejectedAt,
    @TimestampConverter() final DateTime? sentAt,
    @TimestampConverter() final DateTime? acceptedAt,
    final String? rejectionReason,
    final String? sentVia,
    final String? sentTo,
    final String? notes,
    final Map<String, dynamic>? metadata,
    final String? headerId,
    final String? footerId,
    final String? logoId,
    final List<SignatureApproval> signatureApprovals,
  }) = _$LetterImpl;

  factory _Letter.fromJson(Map<String, dynamic> json) = _$LetterImpl.fromJson;

  @override
  String get id;
  @override
  String get type; // Offer Letter, Appointment Letter, etc.
  @override
  String get content; // GPT-generated content
  @override
  String get employeeName;
  @override
  String get employeeEmail;
  @override
  String get createdBy; // userId
  @override
  List<String> get signatureAuthorityUids; // Multiple director/authority UIDs
  @override
  @LetterStatusConverter()
  LetterStatus get letterStatus;
  @override
  @SignatureStatusConverter()
  SignatureStatus get signatureStatus;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt; // PDF and storage information
  @override
  String? get signedPdfPath; // letters/{letterId}/offer.pdf
  @override
  String? get signedPdfUrl; // Supabase signed URL (deprecated - generated on demand)
  @override
  String? get storedIn; // "supabase.process"
  // Timestamps for workflow tracking
  @override
  @TimestampConverter()
  DateTime? get submittedForApprovalAt;
  @override
  @TimestampConverter()
  DateTime? get approvedAt;
  @override
  @TimestampConverter()
  DateTime? get rejectedAt;
  @override
  @TimestampConverter()
  DateTime? get sentAt;
  @override
  @TimestampConverter()
  DateTime? get acceptedAt; // Additional metadata
  @override
  String? get rejectionReason;
  @override
  String? get sentVia; // "email", "hand-delivered", etc.
  @override
  String? get sentTo; // recipient email or contact info
  @override
  String? get notes;
  @override
  Map<String, dynamic>? get metadata;
  @override
  String? get headerId;
  @override
  String? get footerId;
  @override
  String? get logoId; // Individual signature approvals tracking
  @override
  List<SignatureApproval> get signatureApprovals;

  /// Create a copy of Letter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LetterImplCopyWith<_$LetterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$LetterStatus {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() draft,
    required TResult Function() pendingApproval,
    required TResult Function() approved,
    required TResult Function() sent,
    required TResult Function() accepted,
    required TResult Function() rejected,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? draft,
    TResult? Function()? pendingApproval,
    TResult? Function()? approved,
    TResult? Function()? sent,
    TResult? Function()? accepted,
    TResult? Function()? rejected,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? draft,
    TResult Function()? pendingApproval,
    TResult Function()? approved,
    TResult Function()? sent,
    TResult Function()? accepted,
    TResult Function()? rejected,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LetterDraft value) draft,
    required TResult Function(_LetterPendingApproval value) pendingApproval,
    required TResult Function(_LetterApproved value) approved,
    required TResult Function(_LetterSent value) sent,
    required TResult Function(_LetterAccepted value) accepted,
    required TResult Function(_LetterRejected value) rejected,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LetterDraft value)? draft,
    TResult? Function(_LetterPendingApproval value)? pendingApproval,
    TResult? Function(_LetterApproved value)? approved,
    TResult? Function(_LetterSent value)? sent,
    TResult? Function(_LetterAccepted value)? accepted,
    TResult? Function(_LetterRejected value)? rejected,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LetterDraft value)? draft,
    TResult Function(_LetterPendingApproval value)? pendingApproval,
    TResult Function(_LetterApproved value)? approved,
    TResult Function(_LetterSent value)? sent,
    TResult Function(_LetterAccepted value)? accepted,
    TResult Function(_LetterRejected value)? rejected,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LetterStatusCopyWith<$Res> {
  factory $LetterStatusCopyWith(
    LetterStatus value,
    $Res Function(LetterStatus) then,
  ) = _$LetterStatusCopyWithImpl<$Res, LetterStatus>;
}

/// @nodoc
class _$LetterStatusCopyWithImpl<$Res, $Val extends LetterStatus>
    implements $LetterStatusCopyWith<$Res> {
  _$LetterStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LetterStatus
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$LetterDraftImplCopyWith<$Res> {
  factory _$$LetterDraftImplCopyWith(
    _$LetterDraftImpl value,
    $Res Function(_$LetterDraftImpl) then,
  ) = __$$LetterDraftImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LetterDraftImplCopyWithImpl<$Res>
    extends _$LetterStatusCopyWithImpl<$Res, _$LetterDraftImpl>
    implements _$$LetterDraftImplCopyWith<$Res> {
  __$$LetterDraftImplCopyWithImpl(
    _$LetterDraftImpl _value,
    $Res Function(_$LetterDraftImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LetterStatus
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LetterDraftImpl implements _LetterDraft {
  const _$LetterDraftImpl();

  @override
  String toString() {
    return 'LetterStatus.draft()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LetterDraftImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() draft,
    required TResult Function() pendingApproval,
    required TResult Function() approved,
    required TResult Function() sent,
    required TResult Function() accepted,
    required TResult Function() rejected,
  }) {
    return draft();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? draft,
    TResult? Function()? pendingApproval,
    TResult? Function()? approved,
    TResult? Function()? sent,
    TResult? Function()? accepted,
    TResult? Function()? rejected,
  }) {
    return draft?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? draft,
    TResult Function()? pendingApproval,
    TResult Function()? approved,
    TResult Function()? sent,
    TResult Function()? accepted,
    TResult Function()? rejected,
    required TResult orElse(),
  }) {
    if (draft != null) {
      return draft();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LetterDraft value) draft,
    required TResult Function(_LetterPendingApproval value) pendingApproval,
    required TResult Function(_LetterApproved value) approved,
    required TResult Function(_LetterSent value) sent,
    required TResult Function(_LetterAccepted value) accepted,
    required TResult Function(_LetterRejected value) rejected,
  }) {
    return draft(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LetterDraft value)? draft,
    TResult? Function(_LetterPendingApproval value)? pendingApproval,
    TResult? Function(_LetterApproved value)? approved,
    TResult? Function(_LetterSent value)? sent,
    TResult? Function(_LetterAccepted value)? accepted,
    TResult? Function(_LetterRejected value)? rejected,
  }) {
    return draft?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LetterDraft value)? draft,
    TResult Function(_LetterPendingApproval value)? pendingApproval,
    TResult Function(_LetterApproved value)? approved,
    TResult Function(_LetterSent value)? sent,
    TResult Function(_LetterAccepted value)? accepted,
    TResult Function(_LetterRejected value)? rejected,
    required TResult orElse(),
  }) {
    if (draft != null) {
      return draft(this);
    }
    return orElse();
  }
}

abstract class _LetterDraft implements LetterStatus {
  const factory _LetterDraft() = _$LetterDraftImpl;
}

/// @nodoc
abstract class _$$LetterPendingApprovalImplCopyWith<$Res> {
  factory _$$LetterPendingApprovalImplCopyWith(
    _$LetterPendingApprovalImpl value,
    $Res Function(_$LetterPendingApprovalImpl) then,
  ) = __$$LetterPendingApprovalImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LetterPendingApprovalImplCopyWithImpl<$Res>
    extends _$LetterStatusCopyWithImpl<$Res, _$LetterPendingApprovalImpl>
    implements _$$LetterPendingApprovalImplCopyWith<$Res> {
  __$$LetterPendingApprovalImplCopyWithImpl(
    _$LetterPendingApprovalImpl _value,
    $Res Function(_$LetterPendingApprovalImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LetterStatus
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LetterPendingApprovalImpl implements _LetterPendingApproval {
  const _$LetterPendingApprovalImpl();

  @override
  String toString() {
    return 'LetterStatus.pendingApproval()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LetterPendingApprovalImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() draft,
    required TResult Function() pendingApproval,
    required TResult Function() approved,
    required TResult Function() sent,
    required TResult Function() accepted,
    required TResult Function() rejected,
  }) {
    return pendingApproval();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? draft,
    TResult? Function()? pendingApproval,
    TResult? Function()? approved,
    TResult? Function()? sent,
    TResult? Function()? accepted,
    TResult? Function()? rejected,
  }) {
    return pendingApproval?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? draft,
    TResult Function()? pendingApproval,
    TResult Function()? approved,
    TResult Function()? sent,
    TResult Function()? accepted,
    TResult Function()? rejected,
    required TResult orElse(),
  }) {
    if (pendingApproval != null) {
      return pendingApproval();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LetterDraft value) draft,
    required TResult Function(_LetterPendingApproval value) pendingApproval,
    required TResult Function(_LetterApproved value) approved,
    required TResult Function(_LetterSent value) sent,
    required TResult Function(_LetterAccepted value) accepted,
    required TResult Function(_LetterRejected value) rejected,
  }) {
    return pendingApproval(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LetterDraft value)? draft,
    TResult? Function(_LetterPendingApproval value)? pendingApproval,
    TResult? Function(_LetterApproved value)? approved,
    TResult? Function(_LetterSent value)? sent,
    TResult? Function(_LetterAccepted value)? accepted,
    TResult? Function(_LetterRejected value)? rejected,
  }) {
    return pendingApproval?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LetterDraft value)? draft,
    TResult Function(_LetterPendingApproval value)? pendingApproval,
    TResult Function(_LetterApproved value)? approved,
    TResult Function(_LetterSent value)? sent,
    TResult Function(_LetterAccepted value)? accepted,
    TResult Function(_LetterRejected value)? rejected,
    required TResult orElse(),
  }) {
    if (pendingApproval != null) {
      return pendingApproval(this);
    }
    return orElse();
  }
}

abstract class _LetterPendingApproval implements LetterStatus {
  const factory _LetterPendingApproval() = _$LetterPendingApprovalImpl;
}

/// @nodoc
abstract class _$$LetterApprovedImplCopyWith<$Res> {
  factory _$$LetterApprovedImplCopyWith(
    _$LetterApprovedImpl value,
    $Res Function(_$LetterApprovedImpl) then,
  ) = __$$LetterApprovedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LetterApprovedImplCopyWithImpl<$Res>
    extends _$LetterStatusCopyWithImpl<$Res, _$LetterApprovedImpl>
    implements _$$LetterApprovedImplCopyWith<$Res> {
  __$$LetterApprovedImplCopyWithImpl(
    _$LetterApprovedImpl _value,
    $Res Function(_$LetterApprovedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LetterStatus
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LetterApprovedImpl implements _LetterApproved {
  const _$LetterApprovedImpl();

  @override
  String toString() {
    return 'LetterStatus.approved()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LetterApprovedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() draft,
    required TResult Function() pendingApproval,
    required TResult Function() approved,
    required TResult Function() sent,
    required TResult Function() accepted,
    required TResult Function() rejected,
  }) {
    return approved();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? draft,
    TResult? Function()? pendingApproval,
    TResult? Function()? approved,
    TResult? Function()? sent,
    TResult? Function()? accepted,
    TResult? Function()? rejected,
  }) {
    return approved?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? draft,
    TResult Function()? pendingApproval,
    TResult Function()? approved,
    TResult Function()? sent,
    TResult Function()? accepted,
    TResult Function()? rejected,
    required TResult orElse(),
  }) {
    if (approved != null) {
      return approved();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LetterDraft value) draft,
    required TResult Function(_LetterPendingApproval value) pendingApproval,
    required TResult Function(_LetterApproved value) approved,
    required TResult Function(_LetterSent value) sent,
    required TResult Function(_LetterAccepted value) accepted,
    required TResult Function(_LetterRejected value) rejected,
  }) {
    return approved(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LetterDraft value)? draft,
    TResult? Function(_LetterPendingApproval value)? pendingApproval,
    TResult? Function(_LetterApproved value)? approved,
    TResult? Function(_LetterSent value)? sent,
    TResult? Function(_LetterAccepted value)? accepted,
    TResult? Function(_LetterRejected value)? rejected,
  }) {
    return approved?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LetterDraft value)? draft,
    TResult Function(_LetterPendingApproval value)? pendingApproval,
    TResult Function(_LetterApproved value)? approved,
    TResult Function(_LetterSent value)? sent,
    TResult Function(_LetterAccepted value)? accepted,
    TResult Function(_LetterRejected value)? rejected,
    required TResult orElse(),
  }) {
    if (approved != null) {
      return approved(this);
    }
    return orElse();
  }
}

abstract class _LetterApproved implements LetterStatus {
  const factory _LetterApproved() = _$LetterApprovedImpl;
}

/// @nodoc
abstract class _$$LetterSentImplCopyWith<$Res> {
  factory _$$LetterSentImplCopyWith(
    _$LetterSentImpl value,
    $Res Function(_$LetterSentImpl) then,
  ) = __$$LetterSentImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LetterSentImplCopyWithImpl<$Res>
    extends _$LetterStatusCopyWithImpl<$Res, _$LetterSentImpl>
    implements _$$LetterSentImplCopyWith<$Res> {
  __$$LetterSentImplCopyWithImpl(
    _$LetterSentImpl _value,
    $Res Function(_$LetterSentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LetterStatus
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LetterSentImpl implements _LetterSent {
  const _$LetterSentImpl();

  @override
  String toString() {
    return 'LetterStatus.sent()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LetterSentImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() draft,
    required TResult Function() pendingApproval,
    required TResult Function() approved,
    required TResult Function() sent,
    required TResult Function() accepted,
    required TResult Function() rejected,
  }) {
    return sent();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? draft,
    TResult? Function()? pendingApproval,
    TResult? Function()? approved,
    TResult? Function()? sent,
    TResult? Function()? accepted,
    TResult? Function()? rejected,
  }) {
    return sent?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? draft,
    TResult Function()? pendingApproval,
    TResult Function()? approved,
    TResult Function()? sent,
    TResult Function()? accepted,
    TResult Function()? rejected,
    required TResult orElse(),
  }) {
    if (sent != null) {
      return sent();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LetterDraft value) draft,
    required TResult Function(_LetterPendingApproval value) pendingApproval,
    required TResult Function(_LetterApproved value) approved,
    required TResult Function(_LetterSent value) sent,
    required TResult Function(_LetterAccepted value) accepted,
    required TResult Function(_LetterRejected value) rejected,
  }) {
    return sent(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LetterDraft value)? draft,
    TResult? Function(_LetterPendingApproval value)? pendingApproval,
    TResult? Function(_LetterApproved value)? approved,
    TResult? Function(_LetterSent value)? sent,
    TResult? Function(_LetterAccepted value)? accepted,
    TResult? Function(_LetterRejected value)? rejected,
  }) {
    return sent?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LetterDraft value)? draft,
    TResult Function(_LetterPendingApproval value)? pendingApproval,
    TResult Function(_LetterApproved value)? approved,
    TResult Function(_LetterSent value)? sent,
    TResult Function(_LetterAccepted value)? accepted,
    TResult Function(_LetterRejected value)? rejected,
    required TResult orElse(),
  }) {
    if (sent != null) {
      return sent(this);
    }
    return orElse();
  }
}

abstract class _LetterSent implements LetterStatus {
  const factory _LetterSent() = _$LetterSentImpl;
}

/// @nodoc
abstract class _$$LetterAcceptedImplCopyWith<$Res> {
  factory _$$LetterAcceptedImplCopyWith(
    _$LetterAcceptedImpl value,
    $Res Function(_$LetterAcceptedImpl) then,
  ) = __$$LetterAcceptedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LetterAcceptedImplCopyWithImpl<$Res>
    extends _$LetterStatusCopyWithImpl<$Res, _$LetterAcceptedImpl>
    implements _$$LetterAcceptedImplCopyWith<$Res> {
  __$$LetterAcceptedImplCopyWithImpl(
    _$LetterAcceptedImpl _value,
    $Res Function(_$LetterAcceptedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LetterStatus
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LetterAcceptedImpl implements _LetterAccepted {
  const _$LetterAcceptedImpl();

  @override
  String toString() {
    return 'LetterStatus.accepted()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LetterAcceptedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() draft,
    required TResult Function() pendingApproval,
    required TResult Function() approved,
    required TResult Function() sent,
    required TResult Function() accepted,
    required TResult Function() rejected,
  }) {
    return accepted();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? draft,
    TResult? Function()? pendingApproval,
    TResult? Function()? approved,
    TResult? Function()? sent,
    TResult? Function()? accepted,
    TResult? Function()? rejected,
  }) {
    return accepted?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? draft,
    TResult Function()? pendingApproval,
    TResult Function()? approved,
    TResult Function()? sent,
    TResult Function()? accepted,
    TResult Function()? rejected,
    required TResult orElse(),
  }) {
    if (accepted != null) {
      return accepted();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LetterDraft value) draft,
    required TResult Function(_LetterPendingApproval value) pendingApproval,
    required TResult Function(_LetterApproved value) approved,
    required TResult Function(_LetterSent value) sent,
    required TResult Function(_LetterAccepted value) accepted,
    required TResult Function(_LetterRejected value) rejected,
  }) {
    return accepted(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LetterDraft value)? draft,
    TResult? Function(_LetterPendingApproval value)? pendingApproval,
    TResult? Function(_LetterApproved value)? approved,
    TResult? Function(_LetterSent value)? sent,
    TResult? Function(_LetterAccepted value)? accepted,
    TResult? Function(_LetterRejected value)? rejected,
  }) {
    return accepted?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LetterDraft value)? draft,
    TResult Function(_LetterPendingApproval value)? pendingApproval,
    TResult Function(_LetterApproved value)? approved,
    TResult Function(_LetterSent value)? sent,
    TResult Function(_LetterAccepted value)? accepted,
    TResult Function(_LetterRejected value)? rejected,
    required TResult orElse(),
  }) {
    if (accepted != null) {
      return accepted(this);
    }
    return orElse();
  }
}

abstract class _LetterAccepted implements LetterStatus {
  const factory _LetterAccepted() = _$LetterAcceptedImpl;
}

/// @nodoc
abstract class _$$LetterRejectedImplCopyWith<$Res> {
  factory _$$LetterRejectedImplCopyWith(
    _$LetterRejectedImpl value,
    $Res Function(_$LetterRejectedImpl) then,
  ) = __$$LetterRejectedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LetterRejectedImplCopyWithImpl<$Res>
    extends _$LetterStatusCopyWithImpl<$Res, _$LetterRejectedImpl>
    implements _$$LetterRejectedImplCopyWith<$Res> {
  __$$LetterRejectedImplCopyWithImpl(
    _$LetterRejectedImpl _value,
    $Res Function(_$LetterRejectedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LetterStatus
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LetterRejectedImpl implements _LetterRejected {
  const _$LetterRejectedImpl();

  @override
  String toString() {
    return 'LetterStatus.rejected()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LetterRejectedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() draft,
    required TResult Function() pendingApproval,
    required TResult Function() approved,
    required TResult Function() sent,
    required TResult Function() accepted,
    required TResult Function() rejected,
  }) {
    return rejected();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? draft,
    TResult? Function()? pendingApproval,
    TResult? Function()? approved,
    TResult? Function()? sent,
    TResult? Function()? accepted,
    TResult? Function()? rejected,
  }) {
    return rejected?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? draft,
    TResult Function()? pendingApproval,
    TResult Function()? approved,
    TResult Function()? sent,
    TResult Function()? accepted,
    TResult Function()? rejected,
    required TResult orElse(),
  }) {
    if (rejected != null) {
      return rejected();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LetterDraft value) draft,
    required TResult Function(_LetterPendingApproval value) pendingApproval,
    required TResult Function(_LetterApproved value) approved,
    required TResult Function(_LetterSent value) sent,
    required TResult Function(_LetterAccepted value) accepted,
    required TResult Function(_LetterRejected value) rejected,
  }) {
    return rejected(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LetterDraft value)? draft,
    TResult? Function(_LetterPendingApproval value)? pendingApproval,
    TResult? Function(_LetterApproved value)? approved,
    TResult? Function(_LetterSent value)? sent,
    TResult? Function(_LetterAccepted value)? accepted,
    TResult? Function(_LetterRejected value)? rejected,
  }) {
    return rejected?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LetterDraft value)? draft,
    TResult Function(_LetterPendingApproval value)? pendingApproval,
    TResult Function(_LetterApproved value)? approved,
    TResult Function(_LetterSent value)? sent,
    TResult Function(_LetterAccepted value)? accepted,
    TResult Function(_LetterRejected value)? rejected,
    required TResult orElse(),
  }) {
    if (rejected != null) {
      return rejected(this);
    }
    return orElse();
  }
}

abstract class _LetterRejected implements LetterStatus {
  const factory _LetterRejected() = _$LetterRejectedImpl;
}

/// @nodoc
mixin _$SignatureStatus {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() pending,
    required TResult Function() approved,
    required TResult Function() rejected,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? pending,
    TResult? Function()? approved,
    TResult? Function()? rejected,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? pending,
    TResult Function()? approved,
    TResult Function()? rejected,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SignaturePending value) pending,
    required TResult Function(_SignatureApproved value) approved,
    required TResult Function(_SignatureRejected value) rejected,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SignaturePending value)? pending,
    TResult? Function(_SignatureApproved value)? approved,
    TResult? Function(_SignatureRejected value)? rejected,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SignaturePending value)? pending,
    TResult Function(_SignatureApproved value)? approved,
    TResult Function(_SignatureRejected value)? rejected,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SignatureStatusCopyWith<$Res> {
  factory $SignatureStatusCopyWith(
    SignatureStatus value,
    $Res Function(SignatureStatus) then,
  ) = _$SignatureStatusCopyWithImpl<$Res, SignatureStatus>;
}

/// @nodoc
class _$SignatureStatusCopyWithImpl<$Res, $Val extends SignatureStatus>
    implements $SignatureStatusCopyWith<$Res> {
  _$SignatureStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SignatureStatus
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$SignaturePendingImplCopyWith<$Res> {
  factory _$$SignaturePendingImplCopyWith(
    _$SignaturePendingImpl value,
    $Res Function(_$SignaturePendingImpl) then,
  ) = __$$SignaturePendingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SignaturePendingImplCopyWithImpl<$Res>
    extends _$SignatureStatusCopyWithImpl<$Res, _$SignaturePendingImpl>
    implements _$$SignaturePendingImplCopyWith<$Res> {
  __$$SignaturePendingImplCopyWithImpl(
    _$SignaturePendingImpl _value,
    $Res Function(_$SignaturePendingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SignatureStatus
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SignaturePendingImpl implements _SignaturePending {
  const _$SignaturePendingImpl();

  @override
  String toString() {
    return 'SignatureStatus.pending()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SignaturePendingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() pending,
    required TResult Function() approved,
    required TResult Function() rejected,
  }) {
    return pending();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? pending,
    TResult? Function()? approved,
    TResult? Function()? rejected,
  }) {
    return pending?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? pending,
    TResult Function()? approved,
    TResult Function()? rejected,
    required TResult orElse(),
  }) {
    if (pending != null) {
      return pending();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SignaturePending value) pending,
    required TResult Function(_SignatureApproved value) approved,
    required TResult Function(_SignatureRejected value) rejected,
  }) {
    return pending(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SignaturePending value)? pending,
    TResult? Function(_SignatureApproved value)? approved,
    TResult? Function(_SignatureRejected value)? rejected,
  }) {
    return pending?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SignaturePending value)? pending,
    TResult Function(_SignatureApproved value)? approved,
    TResult Function(_SignatureRejected value)? rejected,
    required TResult orElse(),
  }) {
    if (pending != null) {
      return pending(this);
    }
    return orElse();
  }
}

abstract class _SignaturePending implements SignatureStatus {
  const factory _SignaturePending() = _$SignaturePendingImpl;
}

/// @nodoc
abstract class _$$SignatureApprovedImplCopyWith<$Res> {
  factory _$$SignatureApprovedImplCopyWith(
    _$SignatureApprovedImpl value,
    $Res Function(_$SignatureApprovedImpl) then,
  ) = __$$SignatureApprovedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SignatureApprovedImplCopyWithImpl<$Res>
    extends _$SignatureStatusCopyWithImpl<$Res, _$SignatureApprovedImpl>
    implements _$$SignatureApprovedImplCopyWith<$Res> {
  __$$SignatureApprovedImplCopyWithImpl(
    _$SignatureApprovedImpl _value,
    $Res Function(_$SignatureApprovedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SignatureStatus
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SignatureApprovedImpl implements _SignatureApproved {
  const _$SignatureApprovedImpl();

  @override
  String toString() {
    return 'SignatureStatus.approved()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SignatureApprovedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() pending,
    required TResult Function() approved,
    required TResult Function() rejected,
  }) {
    return approved();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? pending,
    TResult? Function()? approved,
    TResult? Function()? rejected,
  }) {
    return approved?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? pending,
    TResult Function()? approved,
    TResult Function()? rejected,
    required TResult orElse(),
  }) {
    if (approved != null) {
      return approved();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SignaturePending value) pending,
    required TResult Function(_SignatureApproved value) approved,
    required TResult Function(_SignatureRejected value) rejected,
  }) {
    return approved(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SignaturePending value)? pending,
    TResult? Function(_SignatureApproved value)? approved,
    TResult? Function(_SignatureRejected value)? rejected,
  }) {
    return approved?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SignaturePending value)? pending,
    TResult Function(_SignatureApproved value)? approved,
    TResult Function(_SignatureRejected value)? rejected,
    required TResult orElse(),
  }) {
    if (approved != null) {
      return approved(this);
    }
    return orElse();
  }
}

abstract class _SignatureApproved implements SignatureStatus {
  const factory _SignatureApproved() = _$SignatureApprovedImpl;
}

/// @nodoc
abstract class _$$SignatureRejectedImplCopyWith<$Res> {
  factory _$$SignatureRejectedImplCopyWith(
    _$SignatureRejectedImpl value,
    $Res Function(_$SignatureRejectedImpl) then,
  ) = __$$SignatureRejectedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SignatureRejectedImplCopyWithImpl<$Res>
    extends _$SignatureStatusCopyWithImpl<$Res, _$SignatureRejectedImpl>
    implements _$$SignatureRejectedImplCopyWith<$Res> {
  __$$SignatureRejectedImplCopyWithImpl(
    _$SignatureRejectedImpl _value,
    $Res Function(_$SignatureRejectedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SignatureStatus
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SignatureRejectedImpl implements _SignatureRejected {
  const _$SignatureRejectedImpl();

  @override
  String toString() {
    return 'SignatureStatus.rejected()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SignatureRejectedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() pending,
    required TResult Function() approved,
    required TResult Function() rejected,
  }) {
    return rejected();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? pending,
    TResult? Function()? approved,
    TResult? Function()? rejected,
  }) {
    return rejected?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? pending,
    TResult Function()? approved,
    TResult Function()? rejected,
    required TResult orElse(),
  }) {
    if (rejected != null) {
      return rejected();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SignaturePending value) pending,
    required TResult Function(_SignatureApproved value) approved,
    required TResult Function(_SignatureRejected value) rejected,
  }) {
    return rejected(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SignaturePending value)? pending,
    TResult? Function(_SignatureApproved value)? approved,
    TResult? Function(_SignatureRejected value)? rejected,
  }) {
    return rejected?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SignaturePending value)? pending,
    TResult Function(_SignatureApproved value)? approved,
    TResult Function(_SignatureRejected value)? rejected,
    required TResult orElse(),
  }) {
    if (rejected != null) {
      return rejected(this);
    }
    return orElse();
  }
}

abstract class _SignatureRejected implements SignatureStatus {
  const factory _SignatureRejected() = _$SignatureRejectedImpl;
}
