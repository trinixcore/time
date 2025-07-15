// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'folder_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FolderModel _$FolderModelFromJson(Map<String, dynamic> json) {
  return _FolderModel.fromJson(json);
}

/// @nodoc
mixin _$FolderModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get path => throw _privateConstructorUsedError;
  DocumentCategory get category => throw _privateConstructorUsedError;
  DocumentAccessLevel get accessLevel => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  String get createdByName => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;
  List<String> get accessRoles => throw _privateConstructorUsedError;
  List<String> get accessUserIds => throw _privateConstructorUsedError;
  String? get parentId => throw _privateConstructorUsedError;
  String? get parentPath => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;
  bool? get isArchived => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get archivedAt => throw _privateConstructorUsedError;
  String? get archivedBy => throw _privateConstructorUsedError;
  String? get archivedByName => throw _privateConstructorUsedError;
  String? get archiveReason => throw _privateConstructorUsedError;
  int? get documentCount => throw _privateConstructorUsedError;
  int? get subfolderCount => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get lastAccessedAt => throw _privateConstructorUsedError;
  String? get lastAccessedBy => throw _privateConstructorUsedError;

  /// Serializes this FolderModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FolderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FolderModelCopyWith<FolderModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FolderModelCopyWith<$Res> {
  factory $FolderModelCopyWith(
    FolderModel value,
    $Res Function(FolderModel) then,
  ) = _$FolderModelCopyWithImpl<$Res, FolderModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String path,
    DocumentCategory category,
    DocumentAccessLevel accessLevel,
    String createdBy,
    String createdByName,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime updatedAt,
    List<String> accessRoles,
    List<String> accessUserIds,
    String? parentId,
    String? parentPath,
    String? description,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    bool? isArchived,
    @TimestampConverter() DateTime? archivedAt,
    String? archivedBy,
    String? archivedByName,
    String? archiveReason,
    int? documentCount,
    int? subfolderCount,
    @TimestampConverter() DateTime? lastAccessedAt,
    String? lastAccessedBy,
  });
}

/// @nodoc
class _$FolderModelCopyWithImpl<$Res, $Val extends FolderModel>
    implements $FolderModelCopyWith<$Res> {
  _$FolderModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FolderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? path = null,
    Object? category = null,
    Object? accessLevel = null,
    Object? createdBy = null,
    Object? createdByName = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? accessRoles = null,
    Object? accessUserIds = null,
    Object? parentId = freezed,
    Object? parentPath = freezed,
    Object? description = freezed,
    Object? metadata = freezed,
    Object? tags = freezed,
    Object? isArchived = freezed,
    Object? archivedAt = freezed,
    Object? archivedBy = freezed,
    Object? archivedByName = freezed,
    Object? archiveReason = freezed,
    Object? documentCount = freezed,
    Object? subfolderCount = freezed,
    Object? lastAccessedAt = freezed,
    Object? lastAccessedBy = freezed,
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
            path:
                null == path
                    ? _value.path
                    : path // ignore: cast_nullable_to_non_nullable
                        as String,
            category:
                null == category
                    ? _value.category
                    : category // ignore: cast_nullable_to_non_nullable
                        as DocumentCategory,
            accessLevel:
                null == accessLevel
                    ? _value.accessLevel
                    : accessLevel // ignore: cast_nullable_to_non_nullable
                        as DocumentAccessLevel,
            createdBy:
                null == createdBy
                    ? _value.createdBy
                    : createdBy // ignore: cast_nullable_to_non_nullable
                        as String,
            createdByName:
                null == createdByName
                    ? _value.createdByName
                    : createdByName // ignore: cast_nullable_to_non_nullable
                        as String,
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
            accessRoles:
                null == accessRoles
                    ? _value.accessRoles
                    : accessRoles // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            accessUserIds:
                null == accessUserIds
                    ? _value.accessUserIds
                    : accessUserIds // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            parentId:
                freezed == parentId
                    ? _value.parentId
                    : parentId // ignore: cast_nullable_to_non_nullable
                        as String?,
            parentPath:
                freezed == parentPath
                    ? _value.parentPath
                    : parentPath // ignore: cast_nullable_to_non_nullable
                        as String?,
            description:
                freezed == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String?,
            metadata:
                freezed == metadata
                    ? _value.metadata
                    : metadata // ignore: cast_nullable_to_non_nullable
                        as Map<String, dynamic>?,
            tags:
                freezed == tags
                    ? _value.tags
                    : tags // ignore: cast_nullable_to_non_nullable
                        as List<String>?,
            isArchived:
                freezed == isArchived
                    ? _value.isArchived
                    : isArchived // ignore: cast_nullable_to_non_nullable
                        as bool?,
            archivedAt:
                freezed == archivedAt
                    ? _value.archivedAt
                    : archivedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            archivedBy:
                freezed == archivedBy
                    ? _value.archivedBy
                    : archivedBy // ignore: cast_nullable_to_non_nullable
                        as String?,
            archivedByName:
                freezed == archivedByName
                    ? _value.archivedByName
                    : archivedByName // ignore: cast_nullable_to_non_nullable
                        as String?,
            archiveReason:
                freezed == archiveReason
                    ? _value.archiveReason
                    : archiveReason // ignore: cast_nullable_to_non_nullable
                        as String?,
            documentCount:
                freezed == documentCount
                    ? _value.documentCount
                    : documentCount // ignore: cast_nullable_to_non_nullable
                        as int?,
            subfolderCount:
                freezed == subfolderCount
                    ? _value.subfolderCount
                    : subfolderCount // ignore: cast_nullable_to_non_nullable
                        as int?,
            lastAccessedAt:
                freezed == lastAccessedAt
                    ? _value.lastAccessedAt
                    : lastAccessedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            lastAccessedBy:
                freezed == lastAccessedBy
                    ? _value.lastAccessedBy
                    : lastAccessedBy // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FolderModelImplCopyWith<$Res>
    implements $FolderModelCopyWith<$Res> {
  factory _$$FolderModelImplCopyWith(
    _$FolderModelImpl value,
    $Res Function(_$FolderModelImpl) then,
  ) = __$$FolderModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String path,
    DocumentCategory category,
    DocumentAccessLevel accessLevel,
    String createdBy,
    String createdByName,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime updatedAt,
    List<String> accessRoles,
    List<String> accessUserIds,
    String? parentId,
    String? parentPath,
    String? description,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    bool? isArchived,
    @TimestampConverter() DateTime? archivedAt,
    String? archivedBy,
    String? archivedByName,
    String? archiveReason,
    int? documentCount,
    int? subfolderCount,
    @TimestampConverter() DateTime? lastAccessedAt,
    String? lastAccessedBy,
  });
}

/// @nodoc
class __$$FolderModelImplCopyWithImpl<$Res>
    extends _$FolderModelCopyWithImpl<$Res, _$FolderModelImpl>
    implements _$$FolderModelImplCopyWith<$Res> {
  __$$FolderModelImplCopyWithImpl(
    _$FolderModelImpl _value,
    $Res Function(_$FolderModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FolderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? path = null,
    Object? category = null,
    Object? accessLevel = null,
    Object? createdBy = null,
    Object? createdByName = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? accessRoles = null,
    Object? accessUserIds = null,
    Object? parentId = freezed,
    Object? parentPath = freezed,
    Object? description = freezed,
    Object? metadata = freezed,
    Object? tags = freezed,
    Object? isArchived = freezed,
    Object? archivedAt = freezed,
    Object? archivedBy = freezed,
    Object? archivedByName = freezed,
    Object? archiveReason = freezed,
    Object? documentCount = freezed,
    Object? subfolderCount = freezed,
    Object? lastAccessedAt = freezed,
    Object? lastAccessedBy = freezed,
  }) {
    return _then(
      _$FolderModelImpl(
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
        path:
            null == path
                ? _value.path
                : path // ignore: cast_nullable_to_non_nullable
                    as String,
        category:
            null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                    as DocumentCategory,
        accessLevel:
            null == accessLevel
                ? _value.accessLevel
                : accessLevel // ignore: cast_nullable_to_non_nullable
                    as DocumentAccessLevel,
        createdBy:
            null == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                    as String,
        createdByName:
            null == createdByName
                ? _value.createdByName
                : createdByName // ignore: cast_nullable_to_non_nullable
                    as String,
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
        accessRoles:
            null == accessRoles
                ? _value._accessRoles
                : accessRoles // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        accessUserIds:
            null == accessUserIds
                ? _value._accessUserIds
                : accessUserIds // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        parentId:
            freezed == parentId
                ? _value.parentId
                : parentId // ignore: cast_nullable_to_non_nullable
                    as String?,
        parentPath:
            freezed == parentPath
                ? _value.parentPath
                : parentPath // ignore: cast_nullable_to_non_nullable
                    as String?,
        description:
            freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String?,
        metadata:
            freezed == metadata
                ? _value._metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                    as Map<String, dynamic>?,
        tags:
            freezed == tags
                ? _value._tags
                : tags // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
        isArchived:
            freezed == isArchived
                ? _value.isArchived
                : isArchived // ignore: cast_nullable_to_non_nullable
                    as bool?,
        archivedAt:
            freezed == archivedAt
                ? _value.archivedAt
                : archivedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        archivedBy:
            freezed == archivedBy
                ? _value.archivedBy
                : archivedBy // ignore: cast_nullable_to_non_nullable
                    as String?,
        archivedByName:
            freezed == archivedByName
                ? _value.archivedByName
                : archivedByName // ignore: cast_nullable_to_non_nullable
                    as String?,
        archiveReason:
            freezed == archiveReason
                ? _value.archiveReason
                : archiveReason // ignore: cast_nullable_to_non_nullable
                    as String?,
        documentCount:
            freezed == documentCount
                ? _value.documentCount
                : documentCount // ignore: cast_nullable_to_non_nullable
                    as int?,
        subfolderCount:
            freezed == subfolderCount
                ? _value.subfolderCount
                : subfolderCount // ignore: cast_nullable_to_non_nullable
                    as int?,
        lastAccessedAt:
            freezed == lastAccessedAt
                ? _value.lastAccessedAt
                : lastAccessedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        lastAccessedBy:
            freezed == lastAccessedBy
                ? _value.lastAccessedBy
                : lastAccessedBy // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FolderModelImpl implements _FolderModel {
  const _$FolderModelImpl({
    required this.id,
    required this.name,
    required this.path,
    required this.category,
    required this.accessLevel,
    required this.createdBy,
    required this.createdByName,
    @TimestampConverter() required this.createdAt,
    @TimestampConverter() required this.updatedAt,
    required final List<String> accessRoles,
    required final List<String> accessUserIds,
    this.parentId,
    this.parentPath,
    this.description,
    final Map<String, dynamic>? metadata,
    final List<String>? tags,
    this.isArchived,
    @TimestampConverter() this.archivedAt,
    this.archivedBy,
    this.archivedByName,
    this.archiveReason,
    this.documentCount,
    this.subfolderCount,
    @TimestampConverter() this.lastAccessedAt,
    this.lastAccessedBy,
  }) : _accessRoles = accessRoles,
       _accessUserIds = accessUserIds,
       _metadata = metadata,
       _tags = tags;

  factory _$FolderModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FolderModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String path;
  @override
  final DocumentCategory category;
  @override
  final DocumentAccessLevel accessLevel;
  @override
  final String createdBy;
  @override
  final String createdByName;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime updatedAt;
  final List<String> _accessRoles;
  @override
  List<String> get accessRoles {
    if (_accessRoles is EqualUnmodifiableListView) return _accessRoles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_accessRoles);
  }

  final List<String> _accessUserIds;
  @override
  List<String> get accessUserIds {
    if (_accessUserIds is EqualUnmodifiableListView) return _accessUserIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_accessUserIds);
  }

  @override
  final String? parentId;
  @override
  final String? parentPath;
  @override
  final String? description;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<String>? _tags;
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final bool? isArchived;
  @override
  @TimestampConverter()
  final DateTime? archivedAt;
  @override
  final String? archivedBy;
  @override
  final String? archivedByName;
  @override
  final String? archiveReason;
  @override
  final int? documentCount;
  @override
  final int? subfolderCount;
  @override
  @TimestampConverter()
  final DateTime? lastAccessedAt;
  @override
  final String? lastAccessedBy;

  @override
  String toString() {
    return 'FolderModel(id: $id, name: $name, path: $path, category: $category, accessLevel: $accessLevel, createdBy: $createdBy, createdByName: $createdByName, createdAt: $createdAt, updatedAt: $updatedAt, accessRoles: $accessRoles, accessUserIds: $accessUserIds, parentId: $parentId, parentPath: $parentPath, description: $description, metadata: $metadata, tags: $tags, isArchived: $isArchived, archivedAt: $archivedAt, archivedBy: $archivedBy, archivedByName: $archivedByName, archiveReason: $archiveReason, documentCount: $documentCount, subfolderCount: $subfolderCount, lastAccessedAt: $lastAccessedAt, lastAccessedBy: $lastAccessedBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FolderModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.accessLevel, accessLevel) ||
                other.accessLevel == accessLevel) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdByName, createdByName) ||
                other.createdByName == createdByName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(
              other._accessRoles,
              _accessRoles,
            ) &&
            const DeepCollectionEquality().equals(
              other._accessUserIds,
              _accessUserIds,
            ) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            (identical(other.parentPath, parentPath) ||
                other.parentPath == parentPath) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.isArchived, isArchived) ||
                other.isArchived == isArchived) &&
            (identical(other.archivedAt, archivedAt) ||
                other.archivedAt == archivedAt) &&
            (identical(other.archivedBy, archivedBy) ||
                other.archivedBy == archivedBy) &&
            (identical(other.archivedByName, archivedByName) ||
                other.archivedByName == archivedByName) &&
            (identical(other.archiveReason, archiveReason) ||
                other.archiveReason == archiveReason) &&
            (identical(other.documentCount, documentCount) ||
                other.documentCount == documentCount) &&
            (identical(other.subfolderCount, subfolderCount) ||
                other.subfolderCount == subfolderCount) &&
            (identical(other.lastAccessedAt, lastAccessedAt) ||
                other.lastAccessedAt == lastAccessedAt) &&
            (identical(other.lastAccessedBy, lastAccessedBy) ||
                other.lastAccessedBy == lastAccessedBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    name,
    path,
    category,
    accessLevel,
    createdBy,
    createdByName,
    createdAt,
    updatedAt,
    const DeepCollectionEquality().hash(_accessRoles),
    const DeepCollectionEquality().hash(_accessUserIds),
    parentId,
    parentPath,
    description,
    const DeepCollectionEquality().hash(_metadata),
    const DeepCollectionEquality().hash(_tags),
    isArchived,
    archivedAt,
    archivedBy,
    archivedByName,
    archiveReason,
    documentCount,
    subfolderCount,
    lastAccessedAt,
    lastAccessedBy,
  ]);

  /// Create a copy of FolderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FolderModelImplCopyWith<_$FolderModelImpl> get copyWith =>
      __$$FolderModelImplCopyWithImpl<_$FolderModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FolderModelImplToJson(this);
  }
}

abstract class _FolderModel implements FolderModel {
  const factory _FolderModel({
    required final String id,
    required final String name,
    required final String path,
    required final DocumentCategory category,
    required final DocumentAccessLevel accessLevel,
    required final String createdBy,
    required final String createdByName,
    @TimestampConverter() required final DateTime createdAt,
    @TimestampConverter() required final DateTime updatedAt,
    required final List<String> accessRoles,
    required final List<String> accessUserIds,
    final String? parentId,
    final String? parentPath,
    final String? description,
    final Map<String, dynamic>? metadata,
    final List<String>? tags,
    final bool? isArchived,
    @TimestampConverter() final DateTime? archivedAt,
    final String? archivedBy,
    final String? archivedByName,
    final String? archiveReason,
    final int? documentCount,
    final int? subfolderCount,
    @TimestampConverter() final DateTime? lastAccessedAt,
    final String? lastAccessedBy,
  }) = _$FolderModelImpl;

  factory _FolderModel.fromJson(Map<String, dynamic> json) =
      _$FolderModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get path;
  @override
  DocumentCategory get category;
  @override
  DocumentAccessLevel get accessLevel;
  @override
  String get createdBy;
  @override
  String get createdByName;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt;
  @override
  List<String> get accessRoles;
  @override
  List<String> get accessUserIds;
  @override
  String? get parentId;
  @override
  String? get parentPath;
  @override
  String? get description;
  @override
  Map<String, dynamic>? get metadata;
  @override
  List<String>? get tags;
  @override
  bool? get isArchived;
  @override
  @TimestampConverter()
  DateTime? get archivedAt;
  @override
  String? get archivedBy;
  @override
  String? get archivedByName;
  @override
  String? get archiveReason;
  @override
  int? get documentCount;
  @override
  int? get subfolderCount;
  @override
  @TimestampConverter()
  DateTime? get lastAccessedAt;
  @override
  String? get lastAccessedBy;

  /// Create a copy of FolderModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FolderModelImplCopyWith<_$FolderModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
