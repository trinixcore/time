// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Task _$TaskFromJson(Map<String, dynamic> json) {
  return _Task.fromJson(json);
}

/// @nodoc
mixin _$Task {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  TaskStatus get status => throw _privateConstructorUsedError;
  PriorityLevel get priority => throw _privateConstructorUsedError;
  String get assignedToId => throw _privateConstructorUsedError;
  String get createdById => throw _privateConstructorUsedError;
  String? get projectId => throw _privateConstructorUsedError;
  String? get parentTaskId => throw _privateConstructorUsedError;
  DateTime? get startDate => throw _privateConstructorUsedError;
  DateTime? get dueDate => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  double get estimatedHours => throw _privateConstructorUsedError;
  double get actualHours => throw _privateConstructorUsedError;
  int get progressPercentage => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  List<String> get attachments => throw _privateConstructorUsedError;
  List<String> get subtaskIds => throw _privateConstructorUsedError;
  List<String> get dependencyIds => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this Task to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskCopyWith<Task> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskCopyWith<$Res> {
  factory $TaskCopyWith(Task value, $Res Function(Task) then) =
      _$TaskCopyWithImpl<$Res, Task>;
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    TaskStatus status,
    PriorityLevel priority,
    String assignedToId,
    String createdById,
    String? projectId,
    String? parentTaskId,
    DateTime? startDate,
    DateTime? dueDate,
    DateTime? completedAt,
    double estimatedHours,
    double actualHours,
    int progressPercentage,
    List<String> tags,
    List<String> attachments,
    List<String> subtaskIds,
    List<String> dependencyIds,
    DateTime createdAt,
    DateTime updatedAt,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$TaskCopyWithImpl<$Res, $Val extends Task>
    implements $TaskCopyWith<$Res> {
  _$TaskCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? status = null,
    Object? priority = null,
    Object? assignedToId = null,
    Object? createdById = null,
    Object? projectId = freezed,
    Object? parentTaskId = freezed,
    Object? startDate = freezed,
    Object? dueDate = freezed,
    Object? completedAt = freezed,
    Object? estimatedHours = null,
    Object? actualHours = null,
    Object? progressPercentage = null,
    Object? tags = null,
    Object? attachments = null,
    Object? subtaskIds = null,
    Object? dependencyIds = null,
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
            title:
                null == title
                    ? _value.title
                    : title // ignore: cast_nullable_to_non_nullable
                        as String,
            description:
                null == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as TaskStatus,
            priority:
                null == priority
                    ? _value.priority
                    : priority // ignore: cast_nullable_to_non_nullable
                        as PriorityLevel,
            assignedToId:
                null == assignedToId
                    ? _value.assignedToId
                    : assignedToId // ignore: cast_nullable_to_non_nullable
                        as String,
            createdById:
                null == createdById
                    ? _value.createdById
                    : createdById // ignore: cast_nullable_to_non_nullable
                        as String,
            projectId:
                freezed == projectId
                    ? _value.projectId
                    : projectId // ignore: cast_nullable_to_non_nullable
                        as String?,
            parentTaskId:
                freezed == parentTaskId
                    ? _value.parentTaskId
                    : parentTaskId // ignore: cast_nullable_to_non_nullable
                        as String?,
            startDate:
                freezed == startDate
                    ? _value.startDate
                    : startDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            dueDate:
                freezed == dueDate
                    ? _value.dueDate
                    : dueDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            completedAt:
                freezed == completedAt
                    ? _value.completedAt
                    : completedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            estimatedHours:
                null == estimatedHours
                    ? _value.estimatedHours
                    : estimatedHours // ignore: cast_nullable_to_non_nullable
                        as double,
            actualHours:
                null == actualHours
                    ? _value.actualHours
                    : actualHours // ignore: cast_nullable_to_non_nullable
                        as double,
            progressPercentage:
                null == progressPercentage
                    ? _value.progressPercentage
                    : progressPercentage // ignore: cast_nullable_to_non_nullable
                        as int,
            tags:
                null == tags
                    ? _value.tags
                    : tags // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            attachments:
                null == attachments
                    ? _value.attachments
                    : attachments // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            subtaskIds:
                null == subtaskIds
                    ? _value.subtaskIds
                    : subtaskIds // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            dependencyIds:
                null == dependencyIds
                    ? _value.dependencyIds
                    : dependencyIds // ignore: cast_nullable_to_non_nullable
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
abstract class _$$TaskImplCopyWith<$Res> implements $TaskCopyWith<$Res> {
  factory _$$TaskImplCopyWith(
    _$TaskImpl value,
    $Res Function(_$TaskImpl) then,
  ) = __$$TaskImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    TaskStatus status,
    PriorityLevel priority,
    String assignedToId,
    String createdById,
    String? projectId,
    String? parentTaskId,
    DateTime? startDate,
    DateTime? dueDate,
    DateTime? completedAt,
    double estimatedHours,
    double actualHours,
    int progressPercentage,
    List<String> tags,
    List<String> attachments,
    List<String> subtaskIds,
    List<String> dependencyIds,
    DateTime createdAt,
    DateTime updatedAt,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$TaskImplCopyWithImpl<$Res>
    extends _$TaskCopyWithImpl<$Res, _$TaskImpl>
    implements _$$TaskImplCopyWith<$Res> {
  __$$TaskImplCopyWithImpl(_$TaskImpl _value, $Res Function(_$TaskImpl) _then)
    : super(_value, _then);

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? status = null,
    Object? priority = null,
    Object? assignedToId = null,
    Object? createdById = null,
    Object? projectId = freezed,
    Object? parentTaskId = freezed,
    Object? startDate = freezed,
    Object? dueDate = freezed,
    Object? completedAt = freezed,
    Object? estimatedHours = null,
    Object? actualHours = null,
    Object? progressPercentage = null,
    Object? tags = null,
    Object? attachments = null,
    Object? subtaskIds = null,
    Object? dependencyIds = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? metadata = freezed,
  }) {
    return _then(
      _$TaskImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        title:
            null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                    as String,
        description:
            null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as TaskStatus,
        priority:
            null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                    as PriorityLevel,
        assignedToId:
            null == assignedToId
                ? _value.assignedToId
                : assignedToId // ignore: cast_nullable_to_non_nullable
                    as String,
        createdById:
            null == createdById
                ? _value.createdById
                : createdById // ignore: cast_nullable_to_non_nullable
                    as String,
        projectId:
            freezed == projectId
                ? _value.projectId
                : projectId // ignore: cast_nullable_to_non_nullable
                    as String?,
        parentTaskId:
            freezed == parentTaskId
                ? _value.parentTaskId
                : parentTaskId // ignore: cast_nullable_to_non_nullable
                    as String?,
        startDate:
            freezed == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        dueDate:
            freezed == dueDate
                ? _value.dueDate
                : dueDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        completedAt:
            freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        estimatedHours:
            null == estimatedHours
                ? _value.estimatedHours
                : estimatedHours // ignore: cast_nullable_to_non_nullable
                    as double,
        actualHours:
            null == actualHours
                ? _value.actualHours
                : actualHours // ignore: cast_nullable_to_non_nullable
                    as double,
        progressPercentage:
            null == progressPercentage
                ? _value.progressPercentage
                : progressPercentage // ignore: cast_nullable_to_non_nullable
                    as int,
        tags:
            null == tags
                ? _value._tags
                : tags // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        attachments:
            null == attachments
                ? _value._attachments
                : attachments // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        subtaskIds:
            null == subtaskIds
                ? _value._subtaskIds
                : subtaskIds // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        dependencyIds:
            null == dependencyIds
                ? _value._dependencyIds
                : dependencyIds // ignore: cast_nullable_to_non_nullable
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
class _$TaskImpl extends _Task {
  const _$TaskImpl({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.assignedToId,
    required this.createdById,
    this.projectId,
    this.parentTaskId,
    this.startDate,
    this.dueDate,
    this.completedAt,
    this.estimatedHours = 0.0,
    this.actualHours = 0.0,
    this.progressPercentage = 0,
    final List<String> tags = const [],
    final List<String> attachments = const [],
    final List<String> subtaskIds = const [],
    final List<String> dependencyIds = const [],
    required this.createdAt,
    required this.updatedAt,
    final Map<String, dynamic>? metadata,
  }) : _tags = tags,
       _attachments = attachments,
       _subtaskIds = subtaskIds,
       _dependencyIds = dependencyIds,
       _metadata = metadata,
       super._();

  factory _$TaskImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final TaskStatus status;
  @override
  final PriorityLevel priority;
  @override
  final String assignedToId;
  @override
  final String createdById;
  @override
  final String? projectId;
  @override
  final String? parentTaskId;
  @override
  final DateTime? startDate;
  @override
  final DateTime? dueDate;
  @override
  final DateTime? completedAt;
  @override
  @JsonKey()
  final double estimatedHours;
  @override
  @JsonKey()
  final double actualHours;
  @override
  @JsonKey()
  final int progressPercentage;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  final List<String> _attachments;
  @override
  @JsonKey()
  List<String> get attachments {
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachments);
  }

  final List<String> _subtaskIds;
  @override
  @JsonKey()
  List<String> get subtaskIds {
    if (_subtaskIds is EqualUnmodifiableListView) return _subtaskIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subtaskIds);
  }

  final List<String> _dependencyIds;
  @override
  @JsonKey()
  List<String> get dependencyIds {
    if (_dependencyIds is EqualUnmodifiableListView) return _dependencyIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dependencyIds);
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
    return 'Task(id: $id, title: $title, description: $description, status: $status, priority: $priority, assignedToId: $assignedToId, createdById: $createdById, projectId: $projectId, parentTaskId: $parentTaskId, startDate: $startDate, dueDate: $dueDate, completedAt: $completedAt, estimatedHours: $estimatedHours, actualHours: $actualHours, progressPercentage: $progressPercentage, tags: $tags, attachments: $attachments, subtaskIds: $subtaskIds, dependencyIds: $dependencyIds, createdAt: $createdAt, updatedAt: $updatedAt, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.assignedToId, assignedToId) ||
                other.assignedToId == assignedToId) &&
            (identical(other.createdById, createdById) ||
                other.createdById == createdById) &&
            (identical(other.projectId, projectId) ||
                other.projectId == projectId) &&
            (identical(other.parentTaskId, parentTaskId) ||
                other.parentTaskId == parentTaskId) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.estimatedHours, estimatedHours) ||
                other.estimatedHours == estimatedHours) &&
            (identical(other.actualHours, actualHours) ||
                other.actualHours == actualHours) &&
            (identical(other.progressPercentage, progressPercentage) ||
                other.progressPercentage == progressPercentage) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality().equals(
              other._attachments,
              _attachments,
            ) &&
            const DeepCollectionEquality().equals(
              other._subtaskIds,
              _subtaskIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._dependencyIds,
              _dependencyIds,
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
    title,
    description,
    status,
    priority,
    assignedToId,
    createdById,
    projectId,
    parentTaskId,
    startDate,
    dueDate,
    completedAt,
    estimatedHours,
    actualHours,
    progressPercentage,
    const DeepCollectionEquality().hash(_tags),
    const DeepCollectionEquality().hash(_attachments),
    const DeepCollectionEquality().hash(_subtaskIds),
    const DeepCollectionEquality().hash(_dependencyIds),
    createdAt,
    updatedAt,
    const DeepCollectionEquality().hash(_metadata),
  ]);

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskImplCopyWith<_$TaskImpl> get copyWith =>
      __$$TaskImplCopyWithImpl<_$TaskImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskImplToJson(this);
  }
}

abstract class _Task extends Task {
  const factory _Task({
    required final String id,
    required final String title,
    required final String description,
    required final TaskStatus status,
    required final PriorityLevel priority,
    required final String assignedToId,
    required final String createdById,
    final String? projectId,
    final String? parentTaskId,
    final DateTime? startDate,
    final DateTime? dueDate,
    final DateTime? completedAt,
    final double estimatedHours,
    final double actualHours,
    final int progressPercentage,
    final List<String> tags,
    final List<String> attachments,
    final List<String> subtaskIds,
    final List<String> dependencyIds,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final Map<String, dynamic>? metadata,
  }) = _$TaskImpl;
  const _Task._() : super._();

  factory _Task.fromJson(Map<String, dynamic> json) = _$TaskImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  TaskStatus get status;
  @override
  PriorityLevel get priority;
  @override
  String get assignedToId;
  @override
  String get createdById;
  @override
  String? get projectId;
  @override
  String? get parentTaskId;
  @override
  DateTime? get startDate;
  @override
  DateTime? get dueDate;
  @override
  DateTime? get completedAt;
  @override
  double get estimatedHours;
  @override
  double get actualHours;
  @override
  int get progressPercentage;
  @override
  List<String> get tags;
  @override
  List<String> get attachments;
  @override
  List<String> get subtaskIds;
  @override
  List<String> get dependencyIds;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskImplCopyWith<_$TaskImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
