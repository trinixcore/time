// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'leave_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LeaveRequest _$LeaveRequestFromJson(Map<String, dynamic> json) {
  return _LeaveRequest.fromJson(json);
}

/// @nodoc
mixin _$LeaveRequest {
  String get id => throw _privateConstructorUsedError;
  String get employeeId => throw _privateConstructorUsedError;
  String get leaveType => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  LeaveStatus get status => throw _privateConstructorUsedError;
  String? get approvedById => throw _privateConstructorUsedError;
  String? get rejectedById => throw _privateConstructorUsedError;
  DateTime? get approvedAt => throw _privateConstructorUsedError;
  DateTime? get rejectedAt => throw _privateConstructorUsedError;
  String? get approverComments => throw _privateConstructorUsedError;
  String? get rejectionReason => throw _privateConstructorUsedError;
  bool get isHalfDay => throw _privateConstructorUsedError;
  bool get isEmergency => throw _privateConstructorUsedError;
  double get totalDays => throw _privateConstructorUsedError;
  List<String> get attachments => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this LeaveRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeaveRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeaveRequestCopyWith<LeaveRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeaveRequestCopyWith<$Res> {
  factory $LeaveRequestCopyWith(
    LeaveRequest value,
    $Res Function(LeaveRequest) then,
  ) = _$LeaveRequestCopyWithImpl<$Res, LeaveRequest>;
  @useResult
  $Res call({
    String id,
    String employeeId,
    String leaveType,
    DateTime startDate,
    DateTime endDate,
    String reason,
    LeaveStatus status,
    String? approvedById,
    String? rejectedById,
    DateTime? approvedAt,
    DateTime? rejectedAt,
    String? approverComments,
    String? rejectionReason,
    bool isHalfDay,
    bool isEmergency,
    double totalDays,
    List<String> attachments,
    DateTime createdAt,
    DateTime updatedAt,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$LeaveRequestCopyWithImpl<$Res, $Val extends LeaveRequest>
    implements $LeaveRequestCopyWith<$Res> {
  _$LeaveRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeaveRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? employeeId = null,
    Object? leaveType = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? reason = null,
    Object? status = null,
    Object? approvedById = freezed,
    Object? rejectedById = freezed,
    Object? approvedAt = freezed,
    Object? rejectedAt = freezed,
    Object? approverComments = freezed,
    Object? rejectionReason = freezed,
    Object? isHalfDay = null,
    Object? isEmergency = null,
    Object? totalDays = null,
    Object? attachments = null,
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
            employeeId:
                null == employeeId
                    ? _value.employeeId
                    : employeeId // ignore: cast_nullable_to_non_nullable
                        as String,
            leaveType:
                null == leaveType
                    ? _value.leaveType
                    : leaveType // ignore: cast_nullable_to_non_nullable
                        as String,
            startDate:
                null == startDate
                    ? _value.startDate
                    : startDate // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            endDate:
                null == endDate
                    ? _value.endDate
                    : endDate // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            reason:
                null == reason
                    ? _value.reason
                    : reason // ignore: cast_nullable_to_non_nullable
                        as String,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as LeaveStatus,
            approvedById:
                freezed == approvedById
                    ? _value.approvedById
                    : approvedById // ignore: cast_nullable_to_non_nullable
                        as String?,
            rejectedById:
                freezed == rejectedById
                    ? _value.rejectedById
                    : rejectedById // ignore: cast_nullable_to_non_nullable
                        as String?,
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
            approverComments:
                freezed == approverComments
                    ? _value.approverComments
                    : approverComments // ignore: cast_nullable_to_non_nullable
                        as String?,
            rejectionReason:
                freezed == rejectionReason
                    ? _value.rejectionReason
                    : rejectionReason // ignore: cast_nullable_to_non_nullable
                        as String?,
            isHalfDay:
                null == isHalfDay
                    ? _value.isHalfDay
                    : isHalfDay // ignore: cast_nullable_to_non_nullable
                        as bool,
            isEmergency:
                null == isEmergency
                    ? _value.isEmergency
                    : isEmergency // ignore: cast_nullable_to_non_nullable
                        as bool,
            totalDays:
                null == totalDays
                    ? _value.totalDays
                    : totalDays // ignore: cast_nullable_to_non_nullable
                        as double,
            attachments:
                null == attachments
                    ? _value.attachments
                    : attachments // ignore: cast_nullable_to_non_nullable
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
abstract class _$$LeaveRequestImplCopyWith<$Res>
    implements $LeaveRequestCopyWith<$Res> {
  factory _$$LeaveRequestImplCopyWith(
    _$LeaveRequestImpl value,
    $Res Function(_$LeaveRequestImpl) then,
  ) = __$$LeaveRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String employeeId,
    String leaveType,
    DateTime startDate,
    DateTime endDate,
    String reason,
    LeaveStatus status,
    String? approvedById,
    String? rejectedById,
    DateTime? approvedAt,
    DateTime? rejectedAt,
    String? approverComments,
    String? rejectionReason,
    bool isHalfDay,
    bool isEmergency,
    double totalDays,
    List<String> attachments,
    DateTime createdAt,
    DateTime updatedAt,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$LeaveRequestImplCopyWithImpl<$Res>
    extends _$LeaveRequestCopyWithImpl<$Res, _$LeaveRequestImpl>
    implements _$$LeaveRequestImplCopyWith<$Res> {
  __$$LeaveRequestImplCopyWithImpl(
    _$LeaveRequestImpl _value,
    $Res Function(_$LeaveRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeaveRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? employeeId = null,
    Object? leaveType = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? reason = null,
    Object? status = null,
    Object? approvedById = freezed,
    Object? rejectedById = freezed,
    Object? approvedAt = freezed,
    Object? rejectedAt = freezed,
    Object? approverComments = freezed,
    Object? rejectionReason = freezed,
    Object? isHalfDay = null,
    Object? isEmergency = null,
    Object? totalDays = null,
    Object? attachments = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? metadata = freezed,
  }) {
    return _then(
      _$LeaveRequestImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        employeeId:
            null == employeeId
                ? _value.employeeId
                : employeeId // ignore: cast_nullable_to_non_nullable
                    as String,
        leaveType:
            null == leaveType
                ? _value.leaveType
                : leaveType // ignore: cast_nullable_to_non_nullable
                    as String,
        startDate:
            null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        endDate:
            null == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        reason:
            null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                    as String,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as LeaveStatus,
        approvedById:
            freezed == approvedById
                ? _value.approvedById
                : approvedById // ignore: cast_nullable_to_non_nullable
                    as String?,
        rejectedById:
            freezed == rejectedById
                ? _value.rejectedById
                : rejectedById // ignore: cast_nullable_to_non_nullable
                    as String?,
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
        approverComments:
            freezed == approverComments
                ? _value.approverComments
                : approverComments // ignore: cast_nullable_to_non_nullable
                    as String?,
        rejectionReason:
            freezed == rejectionReason
                ? _value.rejectionReason
                : rejectionReason // ignore: cast_nullable_to_non_nullable
                    as String?,
        isHalfDay:
            null == isHalfDay
                ? _value.isHalfDay
                : isHalfDay // ignore: cast_nullable_to_non_nullable
                    as bool,
        isEmergency:
            null == isEmergency
                ? _value.isEmergency
                : isEmergency // ignore: cast_nullable_to_non_nullable
                    as bool,
        totalDays:
            null == totalDays
                ? _value.totalDays
                : totalDays // ignore: cast_nullable_to_non_nullable
                    as double,
        attachments:
            null == attachments
                ? _value._attachments
                : attachments // ignore: cast_nullable_to_non_nullable
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
class _$LeaveRequestImpl extends _LeaveRequest {
  const _$LeaveRequestImpl({
    required this.id,
    required this.employeeId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    this.approvedById,
    this.rejectedById,
    this.approvedAt,
    this.rejectedAt,
    this.approverComments,
    this.rejectionReason,
    this.isHalfDay = false,
    this.isEmergency = false,
    this.totalDays = 0.0,
    final List<String> attachments = const [],
    required this.createdAt,
    required this.updatedAt,
    final Map<String, dynamic>? metadata,
  }) : _attachments = attachments,
       _metadata = metadata,
       super._();

  factory _$LeaveRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeaveRequestImplFromJson(json);

  @override
  final String id;
  @override
  final String employeeId;
  @override
  final String leaveType;
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  final String reason;
  @override
  final LeaveStatus status;
  @override
  final String? approvedById;
  @override
  final String? rejectedById;
  @override
  final DateTime? approvedAt;
  @override
  final DateTime? rejectedAt;
  @override
  final String? approverComments;
  @override
  final String? rejectionReason;
  @override
  @JsonKey()
  final bool isHalfDay;
  @override
  @JsonKey()
  final bool isEmergency;
  @override
  @JsonKey()
  final double totalDays;
  final List<String> _attachments;
  @override
  @JsonKey()
  List<String> get attachments {
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachments);
  }

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
    return 'LeaveRequest(id: $id, employeeId: $employeeId, leaveType: $leaveType, startDate: $startDate, endDate: $endDate, reason: $reason, status: $status, approvedById: $approvedById, rejectedById: $rejectedById, approvedAt: $approvedAt, rejectedAt: $rejectedAt, approverComments: $approverComments, rejectionReason: $rejectionReason, isHalfDay: $isHalfDay, isEmergency: $isEmergency, totalDays: $totalDays, attachments: $attachments, createdAt: $createdAt, updatedAt: $updatedAt, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeaveRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.leaveType, leaveType) ||
                other.leaveType == leaveType) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.approvedById, approvedById) ||
                other.approvedById == approvedById) &&
            (identical(other.rejectedById, rejectedById) ||
                other.rejectedById == rejectedById) &&
            (identical(other.approvedAt, approvedAt) ||
                other.approvedAt == approvedAt) &&
            (identical(other.rejectedAt, rejectedAt) ||
                other.rejectedAt == rejectedAt) &&
            (identical(other.approverComments, approverComments) ||
                other.approverComments == approverComments) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
            (identical(other.isHalfDay, isHalfDay) ||
                other.isHalfDay == isHalfDay) &&
            (identical(other.isEmergency, isEmergency) ||
                other.isEmergency == isEmergency) &&
            (identical(other.totalDays, totalDays) ||
                other.totalDays == totalDays) &&
            const DeepCollectionEquality().equals(
              other._attachments,
              _attachments,
            ) &&
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
    employeeId,
    leaveType,
    startDate,
    endDate,
    reason,
    status,
    approvedById,
    rejectedById,
    approvedAt,
    rejectedAt,
    approverComments,
    rejectionReason,
    isHalfDay,
    isEmergency,
    totalDays,
    const DeepCollectionEquality().hash(_attachments),
    createdAt,
    updatedAt,
    const DeepCollectionEquality().hash(_metadata),
  ]);

  /// Create a copy of LeaveRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeaveRequestImplCopyWith<_$LeaveRequestImpl> get copyWith =>
      __$$LeaveRequestImplCopyWithImpl<_$LeaveRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeaveRequestImplToJson(this);
  }
}

abstract class _LeaveRequest extends LeaveRequest {
  const factory _LeaveRequest({
    required final String id,
    required final String employeeId,
    required final String leaveType,
    required final DateTime startDate,
    required final DateTime endDate,
    required final String reason,
    required final LeaveStatus status,
    final String? approvedById,
    final String? rejectedById,
    final DateTime? approvedAt,
    final DateTime? rejectedAt,
    final String? approverComments,
    final String? rejectionReason,
    final bool isHalfDay,
    final bool isEmergency,
    final double totalDays,
    final List<String> attachments,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final Map<String, dynamic>? metadata,
  }) = _$LeaveRequestImpl;
  const _LeaveRequest._() : super._();

  factory _LeaveRequest.fromJson(Map<String, dynamic> json) =
      _$LeaveRequestImpl.fromJson;

  @override
  String get id;
  @override
  String get employeeId;
  @override
  String get leaveType;
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;
  @override
  String get reason;
  @override
  LeaveStatus get status;
  @override
  String? get approvedById;
  @override
  String? get rejectedById;
  @override
  DateTime? get approvedAt;
  @override
  DateTime? get rejectedAt;
  @override
  String? get approverComments;
  @override
  String? get rejectionReason;
  @override
  bool get isHalfDay;
  @override
  bool get isEmergency;
  @override
  double get totalDays;
  @override
  List<String> get attachments;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of LeaveRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeaveRequestImplCopyWith<_$LeaveRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
