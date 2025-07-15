// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_time_log_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TaskTimeLogModel _$TaskTimeLogModelFromJson(Map<String, dynamic> json) {
  return _TaskTimeLogModel.fromJson(json);
}

/// @nodoc
mixin _$TaskTimeLogModel {
  String get id => throw _privateConstructorUsedError;
  String get taskId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get startTime => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get endTime => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get durationMinutes => throw _privateConstructorUsedError;
  bool get isManualEntry => throw _privateConstructorUsedError;
  bool get isApproved => throw _privateConstructorUsedError;
  String? get approvedBy => throw _privateConstructorUsedError;
  String? get approvedByName => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get approvedAt => throw _privateConstructorUsedError;
  String? get rejectionReason => throw _privateConstructorUsedError;
  List<String> get attachments => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this TaskTimeLogModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TaskTimeLogModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskTimeLogModelCopyWith<TaskTimeLogModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskTimeLogModelCopyWith<$Res> {
  factory $TaskTimeLogModelCopyWith(
    TaskTimeLogModel value,
    $Res Function(TaskTimeLogModel) then,
  ) = _$TaskTimeLogModelCopyWithImpl<$Res, TaskTimeLogModel>;
  @useResult
  $Res call({
    String id,
    String taskId,
    String userId,
    String userName,
    @TimestampConverter() DateTime startTime,
    @TimestampConverter() DateTime? endTime,
    String? description,
    int durationMinutes,
    bool isManualEntry,
    bool isApproved,
    String? approvedBy,
    String? approvedByName,
    @TimestampConverter() DateTime? approvedAt,
    String? rejectionReason,
    List<String> attachments,
    Map<String, dynamic>? metadata,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime updatedAt,
  });
}

/// @nodoc
class _$TaskTimeLogModelCopyWithImpl<$Res, $Val extends TaskTimeLogModel>
    implements $TaskTimeLogModelCopyWith<$Res> {
  _$TaskTimeLogModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaskTimeLogModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? userId = null,
    Object? userName = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? description = freezed,
    Object? durationMinutes = null,
    Object? isManualEntry = null,
    Object? isApproved = null,
    Object? approvedBy = freezed,
    Object? approvedByName = freezed,
    Object? approvedAt = freezed,
    Object? rejectionReason = freezed,
    Object? attachments = null,
    Object? metadata = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            taskId:
                null == taskId
                    ? _value.taskId
                    : taskId // ignore: cast_nullable_to_non_nullable
                        as String,
            userId:
                null == userId
                    ? _value.userId
                    : userId // ignore: cast_nullable_to_non_nullable
                        as String,
            userName:
                null == userName
                    ? _value.userName
                    : userName // ignore: cast_nullable_to_non_nullable
                        as String,
            startTime:
                null == startTime
                    ? _value.startTime
                    : startTime // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            endTime:
                freezed == endTime
                    ? _value.endTime
                    : endTime // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            description:
                freezed == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String?,
            durationMinutes:
                null == durationMinutes
                    ? _value.durationMinutes
                    : durationMinutes // ignore: cast_nullable_to_non_nullable
                        as int,
            isManualEntry:
                null == isManualEntry
                    ? _value.isManualEntry
                    : isManualEntry // ignore: cast_nullable_to_non_nullable
                        as bool,
            isApproved:
                null == isApproved
                    ? _value.isApproved
                    : isApproved // ignore: cast_nullable_to_non_nullable
                        as bool,
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
            approvedAt:
                freezed == approvedAt
                    ? _value.approvedAt
                    : approvedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            rejectionReason:
                freezed == rejectionReason
                    ? _value.rejectionReason
                    : rejectionReason // ignore: cast_nullable_to_non_nullable
                        as String?,
            attachments:
                null == attachments
                    ? _value.attachments
                    : attachments // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            metadata:
                freezed == metadata
                    ? _value.metadata
                    : metadata // ignore: cast_nullable_to_non_nullable
                        as Map<String, dynamic>?,
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
}

/// @nodoc
abstract class _$$TaskTimeLogModelImplCopyWith<$Res>
    implements $TaskTimeLogModelCopyWith<$Res> {
  factory _$$TaskTimeLogModelImplCopyWith(
    _$TaskTimeLogModelImpl value,
    $Res Function(_$TaskTimeLogModelImpl) then,
  ) = __$$TaskTimeLogModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String taskId,
    String userId,
    String userName,
    @TimestampConverter() DateTime startTime,
    @TimestampConverter() DateTime? endTime,
    String? description,
    int durationMinutes,
    bool isManualEntry,
    bool isApproved,
    String? approvedBy,
    String? approvedByName,
    @TimestampConverter() DateTime? approvedAt,
    String? rejectionReason,
    List<String> attachments,
    Map<String, dynamic>? metadata,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime updatedAt,
  });
}

/// @nodoc
class __$$TaskTimeLogModelImplCopyWithImpl<$Res>
    extends _$TaskTimeLogModelCopyWithImpl<$Res, _$TaskTimeLogModelImpl>
    implements _$$TaskTimeLogModelImplCopyWith<$Res> {
  __$$TaskTimeLogModelImplCopyWithImpl(
    _$TaskTimeLogModelImpl _value,
    $Res Function(_$TaskTimeLogModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TaskTimeLogModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? userId = null,
    Object? userName = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? description = freezed,
    Object? durationMinutes = null,
    Object? isManualEntry = null,
    Object? isApproved = null,
    Object? approvedBy = freezed,
    Object? approvedByName = freezed,
    Object? approvedAt = freezed,
    Object? rejectionReason = freezed,
    Object? attachments = null,
    Object? metadata = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$TaskTimeLogModelImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        taskId:
            null == taskId
                ? _value.taskId
                : taskId // ignore: cast_nullable_to_non_nullable
                    as String,
        userId:
            null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                    as String,
        userName:
            null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                    as String,
        startTime:
            null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        endTime:
            freezed == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        description:
            freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String?,
        durationMinutes:
            null == durationMinutes
                ? _value.durationMinutes
                : durationMinutes // ignore: cast_nullable_to_non_nullable
                    as int,
        isManualEntry:
            null == isManualEntry
                ? _value.isManualEntry
                : isManualEntry // ignore: cast_nullable_to_non_nullable
                    as bool,
        isApproved:
            null == isApproved
                ? _value.isApproved
                : isApproved // ignore: cast_nullable_to_non_nullable
                    as bool,
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
        approvedAt:
            freezed == approvedAt
                ? _value.approvedAt
                : approvedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        rejectionReason:
            freezed == rejectionReason
                ? _value.rejectionReason
                : rejectionReason // ignore: cast_nullable_to_non_nullable
                    as String?,
        attachments:
            null == attachments
                ? _value._attachments
                : attachments // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        metadata:
            freezed == metadata
                ? _value._metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                    as Map<String, dynamic>?,
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
class _$TaskTimeLogModelImpl extends _TaskTimeLogModel {
  const _$TaskTimeLogModelImpl({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.userName,
    @TimestampConverter() required this.startTime,
    @TimestampConverter() this.endTime,
    this.description,
    this.durationMinutes = 0,
    this.isManualEntry = false,
    this.isApproved = false,
    this.approvedBy,
    this.approvedByName,
    @TimestampConverter() this.approvedAt,
    this.rejectionReason,
    final List<String> attachments = const [],
    final Map<String, dynamic>? metadata,
    @TimestampConverter() required this.createdAt,
    @TimestampConverter() required this.updatedAt,
  }) : _attachments = attachments,
       _metadata = metadata,
       super._();

  factory _$TaskTimeLogModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskTimeLogModelImplFromJson(json);

  @override
  final String id;
  @override
  final String taskId;
  @override
  final String userId;
  @override
  final String userName;
  @override
  @TimestampConverter()
  final DateTime startTime;
  @override
  @TimestampConverter()
  final DateTime? endTime;
  @override
  final String? description;
  @override
  @JsonKey()
  final int durationMinutes;
  @override
  @JsonKey()
  final bool isManualEntry;
  @override
  @JsonKey()
  final bool isApproved;
  @override
  final String? approvedBy;
  @override
  final String? approvedByName;
  @override
  @TimestampConverter()
  final DateTime? approvedAt;
  @override
  final String? rejectionReason;
  final List<String> _attachments;
  @override
  @JsonKey()
  List<String> get attachments {
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachments);
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

  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime updatedAt;

  @override
  String toString() {
    return 'TaskTimeLogModel(id: $id, taskId: $taskId, userId: $userId, userName: $userName, startTime: $startTime, endTime: $endTime, description: $description, durationMinutes: $durationMinutes, isManualEntry: $isManualEntry, isApproved: $isApproved, approvedBy: $approvedBy, approvedByName: $approvedByName, approvedAt: $approvedAt, rejectionReason: $rejectionReason, attachments: $attachments, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskTimeLogModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.isManualEntry, isManualEntry) ||
                other.isManualEntry == isManualEntry) &&
            (identical(other.isApproved, isApproved) ||
                other.isApproved == isApproved) &&
            (identical(other.approvedBy, approvedBy) ||
                other.approvedBy == approvedBy) &&
            (identical(other.approvedByName, approvedByName) ||
                other.approvedByName == approvedByName) &&
            (identical(other.approvedAt, approvedAt) ||
                other.approvedAt == approvedAt) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
            const DeepCollectionEquality().equals(
              other._attachments,
              _attachments,
            ) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    taskId,
    userId,
    userName,
    startTime,
    endTime,
    description,
    durationMinutes,
    isManualEntry,
    isApproved,
    approvedBy,
    approvedByName,
    approvedAt,
    rejectionReason,
    const DeepCollectionEquality().hash(_attachments),
    const DeepCollectionEquality().hash(_metadata),
    createdAt,
    updatedAt,
  );

  /// Create a copy of TaskTimeLogModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskTimeLogModelImplCopyWith<_$TaskTimeLogModelImpl> get copyWith =>
      __$$TaskTimeLogModelImplCopyWithImpl<_$TaskTimeLogModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskTimeLogModelImplToJson(this);
  }
}

abstract class _TaskTimeLogModel extends TaskTimeLogModel {
  const factory _TaskTimeLogModel({
    required final String id,
    required final String taskId,
    required final String userId,
    required final String userName,
    @TimestampConverter() required final DateTime startTime,
    @TimestampConverter() final DateTime? endTime,
    final String? description,
    final int durationMinutes,
    final bool isManualEntry,
    final bool isApproved,
    final String? approvedBy,
    final String? approvedByName,
    @TimestampConverter() final DateTime? approvedAt,
    final String? rejectionReason,
    final List<String> attachments,
    final Map<String, dynamic>? metadata,
    @TimestampConverter() required final DateTime createdAt,
    @TimestampConverter() required final DateTime updatedAt,
  }) = _$TaskTimeLogModelImpl;
  const _TaskTimeLogModel._() : super._();

  factory _TaskTimeLogModel.fromJson(Map<String, dynamic> json) =
      _$TaskTimeLogModelImpl.fromJson;

  @override
  String get id;
  @override
  String get taskId;
  @override
  String get userId;
  @override
  String get userName;
  @override
  @TimestampConverter()
  DateTime get startTime;
  @override
  @TimestampConverter()
  DateTime? get endTime;
  @override
  String? get description;
  @override
  int get durationMinutes;
  @override
  bool get isManualEntry;
  @override
  bool get isApproved;
  @override
  String? get approvedBy;
  @override
  String? get approvedByName;
  @override
  @TimestampConverter()
  DateTime? get approvedAt;
  @override
  String? get rejectionReason;
  @override
  List<String> get attachments;
  @override
  Map<String, dynamic>? get metadata;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt;

  /// Create a copy of TaskTimeLogModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskTimeLogModelImplCopyWith<_$TaskTimeLogModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
