// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) {
  return _TaskModel.fromJson(json);
}

/// @nodoc
mixin _$TaskModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @PriorityLevelConverter()
  PriorityLevel get priority => throw _privateConstructorUsedError;
  @TaskStatusConverter()
  TaskStatus get status => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get dueDate => throw _privateConstructorUsedError;
  String get departmentId => throw _privateConstructorUsedError;
  String get projectId => throw _privateConstructorUsedError;
  String get assignedTo => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  List<String> get attachments => throw _privateConstructorUsedError;
  List<String> get watchers => throw _privateConstructorUsedError;
  int get estimatedHours => throw _privateConstructorUsedError;
  int get actualHours => throw _privateConstructorUsedError;
  int get timeSpentMinutes => throw _privateConstructorUsedError;
  int get progressPercentage => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get lastProgressUpdate => throw _privateConstructorUsedError;
  String? get parentTaskId => throw _privateConstructorUsedError;
  List<String> get dependencies => throw _privateConstructorUsedError;
  List<String> get subTaskIds => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get completedAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this TaskModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskModelCopyWith<TaskModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskModelCopyWith<$Res> {
  factory $TaskModelCopyWith(TaskModel value, $Res Function(TaskModel) then) =
      _$TaskModelCopyWithImpl<$Res, TaskModel>;
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    @PriorityLevelConverter() PriorityLevel priority,
    @TaskStatusConverter() TaskStatus status,
    @TimestampConverter() DateTime dueDate,
    String departmentId,
    String projectId,
    String assignedTo,
    String createdBy,
    String? category,
    List<String> tags,
    List<String> attachments,
    List<String> watchers,
    int estimatedHours,
    int actualHours,
    int timeSpentMinutes,
    int progressPercentage,
    @TimestampConverter() DateTime? lastProgressUpdate,
    String? parentTaskId,
    List<String> dependencies,
    List<String> subTaskIds,
    @TimestampConverter() DateTime? completedAt,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime updatedAt,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$TaskModelCopyWithImpl<$Res, $Val extends TaskModel>
    implements $TaskModelCopyWith<$Res> {
  _$TaskModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? priority = null,
    Object? status = null,
    Object? dueDate = null,
    Object? departmentId = null,
    Object? projectId = null,
    Object? assignedTo = null,
    Object? createdBy = null,
    Object? category = freezed,
    Object? tags = null,
    Object? attachments = null,
    Object? watchers = null,
    Object? estimatedHours = null,
    Object? actualHours = null,
    Object? timeSpentMinutes = null,
    Object? progressPercentage = null,
    Object? lastProgressUpdate = freezed,
    Object? parentTaskId = freezed,
    Object? dependencies = null,
    Object? subTaskIds = null,
    Object? completedAt = freezed,
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
            priority:
                null == priority
                    ? _value.priority
                    : priority // ignore: cast_nullable_to_non_nullable
                        as PriorityLevel,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as TaskStatus,
            dueDate:
                null == dueDate
                    ? _value.dueDate
                    : dueDate // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            departmentId:
                null == departmentId
                    ? _value.departmentId
                    : departmentId // ignore: cast_nullable_to_non_nullable
                        as String,
            projectId:
                null == projectId
                    ? _value.projectId
                    : projectId // ignore: cast_nullable_to_non_nullable
                        as String,
            assignedTo:
                null == assignedTo
                    ? _value.assignedTo
                    : assignedTo // ignore: cast_nullable_to_non_nullable
                        as String,
            createdBy:
                null == createdBy
                    ? _value.createdBy
                    : createdBy // ignore: cast_nullable_to_non_nullable
                        as String,
            category:
                freezed == category
                    ? _value.category
                    : category // ignore: cast_nullable_to_non_nullable
                        as String?,
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
            watchers:
                null == watchers
                    ? _value.watchers
                    : watchers // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            estimatedHours:
                null == estimatedHours
                    ? _value.estimatedHours
                    : estimatedHours // ignore: cast_nullable_to_non_nullable
                        as int,
            actualHours:
                null == actualHours
                    ? _value.actualHours
                    : actualHours // ignore: cast_nullable_to_non_nullable
                        as int,
            timeSpentMinutes:
                null == timeSpentMinutes
                    ? _value.timeSpentMinutes
                    : timeSpentMinutes // ignore: cast_nullable_to_non_nullable
                        as int,
            progressPercentage:
                null == progressPercentage
                    ? _value.progressPercentage
                    : progressPercentage // ignore: cast_nullable_to_non_nullable
                        as int,
            lastProgressUpdate:
                freezed == lastProgressUpdate
                    ? _value.lastProgressUpdate
                    : lastProgressUpdate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            parentTaskId:
                freezed == parentTaskId
                    ? _value.parentTaskId
                    : parentTaskId // ignore: cast_nullable_to_non_nullable
                        as String?,
            dependencies:
                null == dependencies
                    ? _value.dependencies
                    : dependencies // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            subTaskIds:
                null == subTaskIds
                    ? _value.subTaskIds
                    : subTaskIds // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            completedAt:
                freezed == completedAt
                    ? _value.completedAt
                    : completedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
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
abstract class _$$TaskModelImplCopyWith<$Res>
    implements $TaskModelCopyWith<$Res> {
  factory _$$TaskModelImplCopyWith(
    _$TaskModelImpl value,
    $Res Function(_$TaskModelImpl) then,
  ) = __$$TaskModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    @PriorityLevelConverter() PriorityLevel priority,
    @TaskStatusConverter() TaskStatus status,
    @TimestampConverter() DateTime dueDate,
    String departmentId,
    String projectId,
    String assignedTo,
    String createdBy,
    String? category,
    List<String> tags,
    List<String> attachments,
    List<String> watchers,
    int estimatedHours,
    int actualHours,
    int timeSpentMinutes,
    int progressPercentage,
    @TimestampConverter() DateTime? lastProgressUpdate,
    String? parentTaskId,
    List<String> dependencies,
    List<String> subTaskIds,
    @TimestampConverter() DateTime? completedAt,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime updatedAt,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$TaskModelImplCopyWithImpl<$Res>
    extends _$TaskModelCopyWithImpl<$Res, _$TaskModelImpl>
    implements _$$TaskModelImplCopyWith<$Res> {
  __$$TaskModelImplCopyWithImpl(
    _$TaskModelImpl _value,
    $Res Function(_$TaskModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? priority = null,
    Object? status = null,
    Object? dueDate = null,
    Object? departmentId = null,
    Object? projectId = null,
    Object? assignedTo = null,
    Object? createdBy = null,
    Object? category = freezed,
    Object? tags = null,
    Object? attachments = null,
    Object? watchers = null,
    Object? estimatedHours = null,
    Object? actualHours = null,
    Object? timeSpentMinutes = null,
    Object? progressPercentage = null,
    Object? lastProgressUpdate = freezed,
    Object? parentTaskId = freezed,
    Object? dependencies = null,
    Object? subTaskIds = null,
    Object? completedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? metadata = freezed,
  }) {
    return _then(
      _$TaskModelImpl(
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
        priority:
            null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                    as PriorityLevel,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as TaskStatus,
        dueDate:
            null == dueDate
                ? _value.dueDate
                : dueDate // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        departmentId:
            null == departmentId
                ? _value.departmentId
                : departmentId // ignore: cast_nullable_to_non_nullable
                    as String,
        projectId:
            null == projectId
                ? _value.projectId
                : projectId // ignore: cast_nullable_to_non_nullable
                    as String,
        assignedTo:
            null == assignedTo
                ? _value.assignedTo
                : assignedTo // ignore: cast_nullable_to_non_nullable
                    as String,
        createdBy:
            null == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                    as String,
        category:
            freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                    as String?,
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
        watchers:
            null == watchers
                ? _value._watchers
                : watchers // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        estimatedHours:
            null == estimatedHours
                ? _value.estimatedHours
                : estimatedHours // ignore: cast_nullable_to_non_nullable
                    as int,
        actualHours:
            null == actualHours
                ? _value.actualHours
                : actualHours // ignore: cast_nullable_to_non_nullable
                    as int,
        timeSpentMinutes:
            null == timeSpentMinutes
                ? _value.timeSpentMinutes
                : timeSpentMinutes // ignore: cast_nullable_to_non_nullable
                    as int,
        progressPercentage:
            null == progressPercentage
                ? _value.progressPercentage
                : progressPercentage // ignore: cast_nullable_to_non_nullable
                    as int,
        lastProgressUpdate:
            freezed == lastProgressUpdate
                ? _value.lastProgressUpdate
                : lastProgressUpdate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        parentTaskId:
            freezed == parentTaskId
                ? _value.parentTaskId
                : parentTaskId // ignore: cast_nullable_to_non_nullable
                    as String?,
        dependencies:
            null == dependencies
                ? _value._dependencies
                : dependencies // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        subTaskIds:
            null == subTaskIds
                ? _value._subTaskIds
                : subTaskIds // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        completedAt:
            freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
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
class _$TaskModelImpl extends _TaskModel {
  const _$TaskModelImpl({
    required this.id,
    required this.title,
    required this.description,
    @PriorityLevelConverter() required this.priority,
    @TaskStatusConverter() this.status = TaskStatus.todo,
    @TimestampConverter() required this.dueDate,
    required this.departmentId,
    required this.projectId,
    required this.assignedTo,
    required this.createdBy,
    this.category,
    final List<String> tags = const [],
    final List<String> attachments = const [],
    final List<String> watchers = const [],
    this.estimatedHours = 0,
    this.actualHours = 0,
    this.timeSpentMinutes = 0,
    this.progressPercentage = 0,
    @TimestampConverter() this.lastProgressUpdate,
    this.parentTaskId,
    final List<String> dependencies = const [],
    final List<String> subTaskIds = const [],
    @TimestampConverter() this.completedAt,
    @TimestampConverter() required this.createdAt,
    @TimestampConverter() required this.updatedAt,
    final Map<String, dynamic>? metadata,
  }) : _tags = tags,
       _attachments = attachments,
       _watchers = watchers,
       _dependencies = dependencies,
       _subTaskIds = subTaskIds,
       _metadata = metadata,
       super._();

  factory _$TaskModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  @PriorityLevelConverter()
  final PriorityLevel priority;
  @override
  @JsonKey()
  @TaskStatusConverter()
  final TaskStatus status;
  @override
  @TimestampConverter()
  final DateTime dueDate;
  @override
  final String departmentId;
  @override
  final String projectId;
  @override
  final String assignedTo;
  @override
  final String createdBy;
  @override
  final String? category;
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

  final List<String> _watchers;
  @override
  @JsonKey()
  List<String> get watchers {
    if (_watchers is EqualUnmodifiableListView) return _watchers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_watchers);
  }

  @override
  @JsonKey()
  final int estimatedHours;
  @override
  @JsonKey()
  final int actualHours;
  @override
  @JsonKey()
  final int timeSpentMinutes;
  @override
  @JsonKey()
  final int progressPercentage;
  @override
  @TimestampConverter()
  final DateTime? lastProgressUpdate;
  @override
  final String? parentTaskId;
  final List<String> _dependencies;
  @override
  @JsonKey()
  List<String> get dependencies {
    if (_dependencies is EqualUnmodifiableListView) return _dependencies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dependencies);
  }

  final List<String> _subTaskIds;
  @override
  @JsonKey()
  List<String> get subTaskIds {
    if (_subTaskIds is EqualUnmodifiableListView) return _subTaskIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subTaskIds);
  }

  @override
  @TimestampConverter()
  final DateTime? completedAt;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
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
    return 'TaskModel(id: $id, title: $title, description: $description, priority: $priority, status: $status, dueDate: $dueDate, departmentId: $departmentId, projectId: $projectId, assignedTo: $assignedTo, createdBy: $createdBy, category: $category, tags: $tags, attachments: $attachments, watchers: $watchers, estimatedHours: $estimatedHours, actualHours: $actualHours, timeSpentMinutes: $timeSpentMinutes, progressPercentage: $progressPercentage, lastProgressUpdate: $lastProgressUpdate, parentTaskId: $parentTaskId, dependencies: $dependencies, subTaskIds: $subTaskIds, completedAt: $completedAt, createdAt: $createdAt, updatedAt: $updatedAt, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.departmentId, departmentId) ||
                other.departmentId == departmentId) &&
            (identical(other.projectId, projectId) ||
                other.projectId == projectId) &&
            (identical(other.assignedTo, assignedTo) ||
                other.assignedTo == assignedTo) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality().equals(
              other._attachments,
              _attachments,
            ) &&
            const DeepCollectionEquality().equals(other._watchers, _watchers) &&
            (identical(other.estimatedHours, estimatedHours) ||
                other.estimatedHours == estimatedHours) &&
            (identical(other.actualHours, actualHours) ||
                other.actualHours == actualHours) &&
            (identical(other.timeSpentMinutes, timeSpentMinutes) ||
                other.timeSpentMinutes == timeSpentMinutes) &&
            (identical(other.progressPercentage, progressPercentage) ||
                other.progressPercentage == progressPercentage) &&
            (identical(other.lastProgressUpdate, lastProgressUpdate) ||
                other.lastProgressUpdate == lastProgressUpdate) &&
            (identical(other.parentTaskId, parentTaskId) ||
                other.parentTaskId == parentTaskId) &&
            const DeepCollectionEquality().equals(
              other._dependencies,
              _dependencies,
            ) &&
            const DeepCollectionEquality().equals(
              other._subTaskIds,
              _subTaskIds,
            ) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
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
    priority,
    status,
    dueDate,
    departmentId,
    projectId,
    assignedTo,
    createdBy,
    category,
    const DeepCollectionEquality().hash(_tags),
    const DeepCollectionEquality().hash(_attachments),
    const DeepCollectionEquality().hash(_watchers),
    estimatedHours,
    actualHours,
    timeSpentMinutes,
    progressPercentage,
    lastProgressUpdate,
    parentTaskId,
    const DeepCollectionEquality().hash(_dependencies),
    const DeepCollectionEquality().hash(_subTaskIds),
    completedAt,
    createdAt,
    updatedAt,
    const DeepCollectionEquality().hash(_metadata),
  ]);

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskModelImplCopyWith<_$TaskModelImpl> get copyWith =>
      __$$TaskModelImplCopyWithImpl<_$TaskModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskModelImplToJson(this);
  }
}

abstract class _TaskModel extends TaskModel {
  const factory _TaskModel({
    required final String id,
    required final String title,
    required final String description,
    @PriorityLevelConverter() required final PriorityLevel priority,
    @TaskStatusConverter() final TaskStatus status,
    @TimestampConverter() required final DateTime dueDate,
    required final String departmentId,
    required final String projectId,
    required final String assignedTo,
    required final String createdBy,
    final String? category,
    final List<String> tags,
    final List<String> attachments,
    final List<String> watchers,
    final int estimatedHours,
    final int actualHours,
    final int timeSpentMinutes,
    final int progressPercentage,
    @TimestampConverter() final DateTime? lastProgressUpdate,
    final String? parentTaskId,
    final List<String> dependencies,
    final List<String> subTaskIds,
    @TimestampConverter() final DateTime? completedAt,
    @TimestampConverter() required final DateTime createdAt,
    @TimestampConverter() required final DateTime updatedAt,
    final Map<String, dynamic>? metadata,
  }) = _$TaskModelImpl;
  const _TaskModel._() : super._();

  factory _TaskModel.fromJson(Map<String, dynamic> json) =
      _$TaskModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  @PriorityLevelConverter()
  PriorityLevel get priority;
  @override
  @TaskStatusConverter()
  TaskStatus get status;
  @override
  @TimestampConverter()
  DateTime get dueDate;
  @override
  String get departmentId;
  @override
  String get projectId;
  @override
  String get assignedTo;
  @override
  String get createdBy;
  @override
  String? get category;
  @override
  List<String> get tags;
  @override
  List<String> get attachments;
  @override
  List<String> get watchers;
  @override
  int get estimatedHours;
  @override
  int get actualHours;
  @override
  int get timeSpentMinutes;
  @override
  int get progressPercentage;
  @override
  @TimestampConverter()
  DateTime? get lastProgressUpdate;
  @override
  String? get parentTaskId;
  @override
  List<String> get dependencies;
  @override
  List<String> get subTaskIds;
  @override
  @TimestampConverter()
  DateTime? get completedAt;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskModelImplCopyWith<_$TaskModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
