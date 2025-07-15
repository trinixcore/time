// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Project _$ProjectFromJson(Map<String, dynamic> json) {
  return _Project.fromJson(json);
}

/// @nodoc
mixin _$Project {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  ProjectStatus get status => throw _privateConstructorUsedError;
  ProjectPriority get priority => throw _privateConstructorUsedError;
  String get managerId => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get startDate => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get endDate => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get actualEndDate => throw _privateConstructorUsedError;
  double get budget => throw _privateConstructorUsedError;
  double get actualCost => throw _privateConstructorUsedError;
  int get progressPercentage => throw _privateConstructorUsedError;
  List<String> get teamMemberIds => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  List<String> get attachments => throw _privateConstructorUsedError;
  String? get clientId => throw _privateConstructorUsedError;
  String? get clientName => throw _privateConstructorUsedError;
  String? get departmentId => throw _privateConstructorUsedError;
  Map<String, dynamic>? get customFields => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String? get createdById => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this Project to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Project
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProjectCopyWith<Project> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProjectCopyWith<$Res> {
  factory $ProjectCopyWith(Project value, $Res Function(Project) then) =
      _$ProjectCopyWithImpl<$Res, Project>;
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    ProjectStatus status,
    ProjectPriority priority,
    String managerId,
    @TimestampConverter() DateTime startDate,
    @TimestampConverter() DateTime? endDate,
    @TimestampConverter() DateTime? actualEndDate,
    double budget,
    double actualCost,
    int progressPercentage,
    List<String> teamMemberIds,
    List<String> tags,
    List<String> attachments,
    String? clientId,
    String? clientName,
    String? departmentId,
    Map<String, dynamic>? customFields,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime updatedAt,
    String? createdById,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$ProjectCopyWithImpl<$Res, $Val extends Project>
    implements $ProjectCopyWith<$Res> {
  _$ProjectCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Project
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? status = null,
    Object? priority = null,
    Object? managerId = null,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? actualEndDate = freezed,
    Object? budget = null,
    Object? actualCost = null,
    Object? progressPercentage = null,
    Object? teamMemberIds = null,
    Object? tags = null,
    Object? attachments = null,
    Object? clientId = freezed,
    Object? clientName = freezed,
    Object? departmentId = freezed,
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
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
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
                        as ProjectStatus,
            priority:
                null == priority
                    ? _value.priority
                    : priority // ignore: cast_nullable_to_non_nullable
                        as ProjectPriority,
            managerId:
                null == managerId
                    ? _value.managerId
                    : managerId // ignore: cast_nullable_to_non_nullable
                        as String,
            startDate:
                null == startDate
                    ? _value.startDate
                    : startDate // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            endDate:
                freezed == endDate
                    ? _value.endDate
                    : endDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            actualEndDate:
                freezed == actualEndDate
                    ? _value.actualEndDate
                    : actualEndDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            budget:
                null == budget
                    ? _value.budget
                    : budget // ignore: cast_nullable_to_non_nullable
                        as double,
            actualCost:
                null == actualCost
                    ? _value.actualCost
                    : actualCost // ignore: cast_nullable_to_non_nullable
                        as double,
            progressPercentage:
                null == progressPercentage
                    ? _value.progressPercentage
                    : progressPercentage // ignore: cast_nullable_to_non_nullable
                        as int,
            teamMemberIds:
                null == teamMemberIds
                    ? _value.teamMemberIds
                    : teamMemberIds // ignore: cast_nullable_to_non_nullable
                        as List<String>,
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
            clientId:
                freezed == clientId
                    ? _value.clientId
                    : clientId // ignore: cast_nullable_to_non_nullable
                        as String?,
            clientName:
                freezed == clientName
                    ? _value.clientName
                    : clientName // ignore: cast_nullable_to_non_nullable
                        as String?,
            departmentId:
                freezed == departmentId
                    ? _value.departmentId
                    : departmentId // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ProjectImplCopyWith<$Res> implements $ProjectCopyWith<$Res> {
  factory _$$ProjectImplCopyWith(
    _$ProjectImpl value,
    $Res Function(_$ProjectImpl) then,
  ) = __$$ProjectImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    ProjectStatus status,
    ProjectPriority priority,
    String managerId,
    @TimestampConverter() DateTime startDate,
    @TimestampConverter() DateTime? endDate,
    @TimestampConverter() DateTime? actualEndDate,
    double budget,
    double actualCost,
    int progressPercentage,
    List<String> teamMemberIds,
    List<String> tags,
    List<String> attachments,
    String? clientId,
    String? clientName,
    String? departmentId,
    Map<String, dynamic>? customFields,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime updatedAt,
    String? createdById,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$ProjectImplCopyWithImpl<$Res>
    extends _$ProjectCopyWithImpl<$Res, _$ProjectImpl>
    implements _$$ProjectImplCopyWith<$Res> {
  __$$ProjectImplCopyWithImpl(
    _$ProjectImpl _value,
    $Res Function(_$ProjectImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Project
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? status = null,
    Object? priority = null,
    Object? managerId = null,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? actualEndDate = freezed,
    Object? budget = null,
    Object? actualCost = null,
    Object? progressPercentage = null,
    Object? teamMemberIds = null,
    Object? tags = null,
    Object? attachments = null,
    Object? clientId = freezed,
    Object? clientName = freezed,
    Object? departmentId = freezed,
    Object? customFields = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? createdById = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$ProjectImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
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
                    as ProjectStatus,
        priority:
            null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                    as ProjectPriority,
        managerId:
            null == managerId
                ? _value.managerId
                : managerId // ignore: cast_nullable_to_non_nullable
                    as String,
        startDate:
            null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        endDate:
            freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        actualEndDate:
            freezed == actualEndDate
                ? _value.actualEndDate
                : actualEndDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        budget:
            null == budget
                ? _value.budget
                : budget // ignore: cast_nullable_to_non_nullable
                    as double,
        actualCost:
            null == actualCost
                ? _value.actualCost
                : actualCost // ignore: cast_nullable_to_non_nullable
                    as double,
        progressPercentage:
            null == progressPercentage
                ? _value.progressPercentage
                : progressPercentage // ignore: cast_nullable_to_non_nullable
                    as int,
        teamMemberIds:
            null == teamMemberIds
                ? _value._teamMemberIds
                : teamMemberIds // ignore: cast_nullable_to_non_nullable
                    as List<String>,
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
        clientId:
            freezed == clientId
                ? _value.clientId
                : clientId // ignore: cast_nullable_to_non_nullable
                    as String?,
        clientName:
            freezed == clientName
                ? _value.clientName
                : clientName // ignore: cast_nullable_to_non_nullable
                    as String?,
        departmentId:
            freezed == departmentId
                ? _value.departmentId
                : departmentId // ignore: cast_nullable_to_non_nullable
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
class _$ProjectImpl extends _Project {
  const _$ProjectImpl({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.priority,
    required this.managerId,
    @TimestampConverter() required this.startDate,
    @TimestampConverter() this.endDate,
    @TimestampConverter() this.actualEndDate,
    this.budget = 0.0,
    this.actualCost = 0.0,
    this.progressPercentage = 0,
    final List<String> teamMemberIds = const [],
    final List<String> tags = const [],
    final List<String> attachments = const [],
    this.clientId,
    this.clientName,
    this.departmentId,
    final Map<String, dynamic>? customFields,
    @TimestampConverter() required this.createdAt,
    @TimestampConverter() required this.updatedAt,
    this.createdById,
    final Map<String, dynamic>? metadata,
  }) : _teamMemberIds = teamMemberIds,
       _tags = tags,
       _attachments = attachments,
       _customFields = customFields,
       _metadata = metadata,
       super._();

  factory _$ProjectImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProjectImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final ProjectStatus status;
  @override
  final ProjectPriority priority;
  @override
  final String managerId;
  @override
  @TimestampConverter()
  final DateTime startDate;
  @override
  @TimestampConverter()
  final DateTime? endDate;
  @override
  @TimestampConverter()
  final DateTime? actualEndDate;
  @override
  @JsonKey()
  final double budget;
  @override
  @JsonKey()
  final double actualCost;
  @override
  @JsonKey()
  final int progressPercentage;
  final List<String> _teamMemberIds;
  @override
  @JsonKey()
  List<String> get teamMemberIds {
    if (_teamMemberIds is EqualUnmodifiableListView) return _teamMemberIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_teamMemberIds);
  }

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

  @override
  final String? clientId;
  @override
  final String? clientName;
  @override
  final String? departmentId;
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
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
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
    return 'Project(id: $id, name: $name, description: $description, status: $status, priority: $priority, managerId: $managerId, startDate: $startDate, endDate: $endDate, actualEndDate: $actualEndDate, budget: $budget, actualCost: $actualCost, progressPercentage: $progressPercentage, teamMemberIds: $teamMemberIds, tags: $tags, attachments: $attachments, clientId: $clientId, clientName: $clientName, departmentId: $departmentId, customFields: $customFields, createdAt: $createdAt, updatedAt: $updatedAt, createdById: $createdById, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProjectImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.managerId, managerId) ||
                other.managerId == managerId) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.actualEndDate, actualEndDate) ||
                other.actualEndDate == actualEndDate) &&
            (identical(other.budget, budget) || other.budget == budget) &&
            (identical(other.actualCost, actualCost) ||
                other.actualCost == actualCost) &&
            (identical(other.progressPercentage, progressPercentage) ||
                other.progressPercentage == progressPercentage) &&
            const DeepCollectionEquality().equals(
              other._teamMemberIds,
              _teamMemberIds,
            ) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality().equals(
              other._attachments,
              _attachments,
            ) &&
            (identical(other.clientId, clientId) ||
                other.clientId == clientId) &&
            (identical(other.clientName, clientName) ||
                other.clientName == clientName) &&
            (identical(other.departmentId, departmentId) ||
                other.departmentId == departmentId) &&
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
    name,
    description,
    status,
    priority,
    managerId,
    startDate,
    endDate,
    actualEndDate,
    budget,
    actualCost,
    progressPercentage,
    const DeepCollectionEquality().hash(_teamMemberIds),
    const DeepCollectionEquality().hash(_tags),
    const DeepCollectionEquality().hash(_attachments),
    clientId,
    clientName,
    departmentId,
    const DeepCollectionEquality().hash(_customFields),
    createdAt,
    updatedAt,
    createdById,
    const DeepCollectionEquality().hash(_metadata),
  ]);

  /// Create a copy of Project
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProjectImplCopyWith<_$ProjectImpl> get copyWith =>
      __$$ProjectImplCopyWithImpl<_$ProjectImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProjectImplToJson(this);
  }
}

abstract class _Project extends Project {
  const factory _Project({
    required final String id,
    required final String name,
    required final String description,
    required final ProjectStatus status,
    required final ProjectPriority priority,
    required final String managerId,
    @TimestampConverter() required final DateTime startDate,
    @TimestampConverter() final DateTime? endDate,
    @TimestampConverter() final DateTime? actualEndDate,
    final double budget,
    final double actualCost,
    final int progressPercentage,
    final List<String> teamMemberIds,
    final List<String> tags,
    final List<String> attachments,
    final String? clientId,
    final String? clientName,
    final String? departmentId,
    final Map<String, dynamic>? customFields,
    @TimestampConverter() required final DateTime createdAt,
    @TimestampConverter() required final DateTime updatedAt,
    final String? createdById,
    final Map<String, dynamic>? metadata,
  }) = _$ProjectImpl;
  const _Project._() : super._();

  factory _Project.fromJson(Map<String, dynamic> json) = _$ProjectImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  ProjectStatus get status;
  @override
  ProjectPriority get priority;
  @override
  String get managerId;
  @override
  @TimestampConverter()
  DateTime get startDate;
  @override
  @TimestampConverter()
  DateTime? get endDate;
  @override
  @TimestampConverter()
  DateTime? get actualEndDate;
  @override
  double get budget;
  @override
  double get actualCost;
  @override
  int get progressPercentage;
  @override
  List<String> get teamMemberIds;
  @override
  List<String> get tags;
  @override
  List<String> get attachments;
  @override
  String? get clientId;
  @override
  String? get clientName;
  @override
  String? get departmentId;
  @override
  Map<String, dynamic>? get customFields;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt;
  @override
  String? get createdById;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of Project
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProjectImplCopyWith<_$ProjectImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
