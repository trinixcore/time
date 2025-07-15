// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'time_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TimeEntry _$TimeEntryFromJson(Map<String, dynamic> json) {
  return _TimeEntry.fromJson(json);
}

/// @nodoc
mixin _$TimeEntry {
  String get id => throw _privateConstructorUsedError;
  String get employeeId => throw _privateConstructorUsedError;
  String? get taskId => throw _privateConstructorUsedError;
  String? get projectId => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime? get endTime => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get durationMinutes => throw _privateConstructorUsedError;
  bool get isManualEntry => throw _privateConstructorUsedError;
  bool get isApproved => throw _privateConstructorUsedError;
  String? get approvedById => throw _privateConstructorUsedError;
  DateTime? get approvedAt => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  Map<String, dynamic>? get customFields => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String? get createdById => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this TimeEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimeEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimeEntryCopyWith<TimeEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeEntryCopyWith<$Res> {
  factory $TimeEntryCopyWith(TimeEntry value, $Res Function(TimeEntry) then) =
      _$TimeEntryCopyWithImpl<$Res, TimeEntry>;
  @useResult
  $Res call({
    String id,
    String employeeId,
    String? taskId,
    String? projectId,
    DateTime startTime,
    DateTime? endTime,
    String? description,
    int durationMinutes,
    bool isManualEntry,
    bool isApproved,
    String? approvedById,
    DateTime? approvedAt,
    List<String> tags,
    String? location,
    Map<String, dynamic>? customFields,
    DateTime createdAt,
    DateTime updatedAt,
    String? createdById,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$TimeEntryCopyWithImpl<$Res, $Val extends TimeEntry>
    implements $TimeEntryCopyWith<$Res> {
  _$TimeEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimeEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? employeeId = null,
    Object? taskId = freezed,
    Object? projectId = freezed,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? description = freezed,
    Object? durationMinutes = null,
    Object? isManualEntry = null,
    Object? isApproved = null,
    Object? approvedById = freezed,
    Object? approvedAt = freezed,
    Object? tags = null,
    Object? location = freezed,
    Object? customFields = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? createdById = freezed,
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
            taskId:
                freezed == taskId
                    ? _value.taskId
                    : taskId // ignore: cast_nullable_to_non_nullable
                        as String?,
            projectId:
                freezed == projectId
                    ? _value.projectId
                    : projectId // ignore: cast_nullable_to_non_nullable
                        as String?,
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
            approvedById:
                freezed == approvedById
                    ? _value.approvedById
                    : approvedById // ignore: cast_nullable_to_non_nullable
                        as String?,
            approvedAt:
                freezed == approvedAt
                    ? _value.approvedAt
                    : approvedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            tags:
                null == tags
                    ? _value.tags
                    : tags // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            location:
                freezed == location
                    ? _value.location
                    : location // ignore: cast_nullable_to_non_nullable
                        as String?,
            customFields:
                freezed == customFields
                    ? _value.customFields
                    : customFields // ignore: cast_nullable_to_non_nullable
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
            createdById:
                freezed == createdById
                    ? _value.createdById
                    : createdById // ignore: cast_nullable_to_non_nullable
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
abstract class _$$TimeEntryImplCopyWith<$Res>
    implements $TimeEntryCopyWith<$Res> {
  factory _$$TimeEntryImplCopyWith(
    _$TimeEntryImpl value,
    $Res Function(_$TimeEntryImpl) then,
  ) = __$$TimeEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String employeeId,
    String? taskId,
    String? projectId,
    DateTime startTime,
    DateTime? endTime,
    String? description,
    int durationMinutes,
    bool isManualEntry,
    bool isApproved,
    String? approvedById,
    DateTime? approvedAt,
    List<String> tags,
    String? location,
    Map<String, dynamic>? customFields,
    DateTime createdAt,
    DateTime updatedAt,
    String? createdById,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$TimeEntryImplCopyWithImpl<$Res>
    extends _$TimeEntryCopyWithImpl<$Res, _$TimeEntryImpl>
    implements _$$TimeEntryImplCopyWith<$Res> {
  __$$TimeEntryImplCopyWithImpl(
    _$TimeEntryImpl _value,
    $Res Function(_$TimeEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimeEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? employeeId = null,
    Object? taskId = freezed,
    Object? projectId = freezed,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? description = freezed,
    Object? durationMinutes = null,
    Object? isManualEntry = null,
    Object? isApproved = null,
    Object? approvedById = freezed,
    Object? approvedAt = freezed,
    Object? tags = null,
    Object? location = freezed,
    Object? customFields = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? createdById = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$TimeEntryImpl(
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
        taskId:
            freezed == taskId
                ? _value.taskId
                : taskId // ignore: cast_nullable_to_non_nullable
                    as String?,
        projectId:
            freezed == projectId
                ? _value.projectId
                : projectId // ignore: cast_nullable_to_non_nullable
                    as String?,
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
        approvedById:
            freezed == approvedById
                ? _value.approvedById
                : approvedById // ignore: cast_nullable_to_non_nullable
                    as String?,
        approvedAt:
            freezed == approvedAt
                ? _value.approvedAt
                : approvedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        tags:
            null == tags
                ? _value._tags
                : tags // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        location:
            freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                    as String?,
        customFields:
            freezed == customFields
                ? _value._customFields
                : customFields // ignore: cast_nullable_to_non_nullable
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
        createdById:
            freezed == createdById
                ? _value.createdById
                : createdById // ignore: cast_nullable_to_non_nullable
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
class _$TimeEntryImpl extends _TimeEntry {
  const _$TimeEntryImpl({
    required this.id,
    required this.employeeId,
    this.taskId,
    this.projectId,
    required this.startTime,
    this.endTime,
    this.description,
    this.durationMinutes = 0,
    this.isManualEntry = false,
    this.isApproved = false,
    this.approvedById,
    this.approvedAt,
    final List<String> tags = const [],
    this.location,
    final Map<String, dynamic>? customFields,
    required this.createdAt,
    required this.updatedAt,
    this.createdById,
    final Map<String, dynamic>? metadata,
  }) : _tags = tags,
       _customFields = customFields,
       _metadata = metadata,
       super._();

  factory _$TimeEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String employeeId;
  @override
  final String? taskId;
  @override
  final String? projectId;
  @override
  final DateTime startTime;
  @override
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
  final String? approvedById;
  @override
  final DateTime? approvedAt;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final String? location;
  final Map<String, dynamic>? _customFields;
  @override
  Map<String, dynamic>? get customFields {
    final value = _customFields;
    if (value == null) return null;
    if (_customFields is EqualUnmodifiableMapView) return _customFields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String? createdById;
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
    return 'TimeEntry(id: $id, employeeId: $employeeId, taskId: $taskId, projectId: $projectId, startTime: $startTime, endTime: $endTime, description: $description, durationMinutes: $durationMinutes, isManualEntry: $isManualEntry, isApproved: $isApproved, approvedById: $approvedById, approvedAt: $approvedAt, tags: $tags, location: $location, customFields: $customFields, createdAt: $createdAt, updatedAt: $updatedAt, createdById: $createdById, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.projectId, projectId) ||
                other.projectId == projectId) &&
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
            (identical(other.approvedById, approvedById) ||
                other.approvedById == approvedById) &&
            (identical(other.approvedAt, approvedAt) ||
                other.approvedAt == approvedAt) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality().equals(
              other._customFields,
              _customFields,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.createdById, createdById) ||
                other.createdById == createdById) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    employeeId,
    taskId,
    projectId,
    startTime,
    endTime,
    description,
    durationMinutes,
    isManualEntry,
    isApproved,
    approvedById,
    approvedAt,
    const DeepCollectionEquality().hash(_tags),
    location,
    const DeepCollectionEquality().hash(_customFields),
    createdAt,
    updatedAt,
    createdById,
    const DeepCollectionEquality().hash(_metadata),
  ]);

  /// Create a copy of TimeEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeEntryImplCopyWith<_$TimeEntryImpl> get copyWith =>
      __$$TimeEntryImplCopyWithImpl<_$TimeEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeEntryImplToJson(this);
  }
}

abstract class _TimeEntry extends TimeEntry {
  const factory _TimeEntry({
    required final String id,
    required final String employeeId,
    final String? taskId,
    final String? projectId,
    required final DateTime startTime,
    final DateTime? endTime,
    final String? description,
    final int durationMinutes,
    final bool isManualEntry,
    final bool isApproved,
    final String? approvedById,
    final DateTime? approvedAt,
    final List<String> tags,
    final String? location,
    final Map<String, dynamic>? customFields,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final String? createdById,
    final Map<String, dynamic>? metadata,
  }) = _$TimeEntryImpl;
  const _TimeEntry._() : super._();

  factory _TimeEntry.fromJson(Map<String, dynamic> json) =
      _$TimeEntryImpl.fromJson;

  @override
  String get id;
  @override
  String get employeeId;
  @override
  String? get taskId;
  @override
  String? get projectId;
  @override
  DateTime get startTime;
  @override
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
  String? get approvedById;
  @override
  DateTime? get approvedAt;
  @override
  List<String> get tags;
  @override
  String? get location;
  @override
  Map<String, dynamic>? get customFields;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String? get createdById;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of TimeEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimeEntryImplCopyWith<_$TimeEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
