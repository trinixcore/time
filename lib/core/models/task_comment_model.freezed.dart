// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_comment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TaskCommentModel _$TaskCommentModelFromJson(Map<String, dynamic> json) {
  return _TaskCommentModel.fromJson(json);
}

/// @nodoc
mixin _$TaskCommentModel {
  String get id => throw _privateConstructorUsedError;
  String get taskId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String get authorId => throw _privateConstructorUsedError;
  String get authorName => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String? get parentCommentId => throw _privateConstructorUsedError;
  List<String> get replies => throw _privateConstructorUsedError;
  List<String> get attachments => throw _privateConstructorUsedError;
  List<String> get mentions => throw _privateConstructorUsedError;
  bool get isEdited => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;
  String? get editedBy => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get editedAt => throw _privateConstructorUsedError;
  String? get deletedBy => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this TaskCommentModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TaskCommentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskCommentModelCopyWith<TaskCommentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskCommentModelCopyWith<$Res> {
  factory $TaskCommentModelCopyWith(
    TaskCommentModel value,
    $Res Function(TaskCommentModel) then,
  ) = _$TaskCommentModelCopyWithImpl<$Res, TaskCommentModel>;
  @useResult
  $Res call({
    String id,
    String taskId,
    String content,
    String authorId,
    String authorName,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime updatedAt,
    String? parentCommentId,
    List<String> replies,
    List<String> attachments,
    List<String> mentions,
    bool isEdited,
    bool isDeleted,
    String? editedBy,
    @TimestampConverter() DateTime? editedAt,
    String? deletedBy,
    @TimestampConverter() DateTime? deletedAt,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$TaskCommentModelCopyWithImpl<$Res, $Val extends TaskCommentModel>
    implements $TaskCommentModelCopyWith<$Res> {
  _$TaskCommentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaskCommentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? content = null,
    Object? authorId = null,
    Object? authorName = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? parentCommentId = freezed,
    Object? replies = null,
    Object? attachments = null,
    Object? mentions = null,
    Object? isEdited = null,
    Object? isDeleted = null,
    Object? editedBy = freezed,
    Object? editedAt = freezed,
    Object? deletedBy = freezed,
    Object? deletedAt = freezed,
    Object? metadata = freezed,
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
            content:
                null == content
                    ? _value.content
                    : content // ignore: cast_nullable_to_non_nullable
                        as String,
            authorId:
                null == authorId
                    ? _value.authorId
                    : authorId // ignore: cast_nullable_to_non_nullable
                        as String,
            authorName:
                null == authorName
                    ? _value.authorName
                    : authorName // ignore: cast_nullable_to_non_nullable
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
            parentCommentId:
                freezed == parentCommentId
                    ? _value.parentCommentId
                    : parentCommentId // ignore: cast_nullable_to_non_nullable
                        as String?,
            replies:
                null == replies
                    ? _value.replies
                    : replies // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            attachments:
                null == attachments
                    ? _value.attachments
                    : attachments // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            mentions:
                null == mentions
                    ? _value.mentions
                    : mentions // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            isEdited:
                null == isEdited
                    ? _value.isEdited
                    : isEdited // ignore: cast_nullable_to_non_nullable
                        as bool,
            isDeleted:
                null == isDeleted
                    ? _value.isDeleted
                    : isDeleted // ignore: cast_nullable_to_non_nullable
                        as bool,
            editedBy:
                freezed == editedBy
                    ? _value.editedBy
                    : editedBy // ignore: cast_nullable_to_non_nullable
                        as String?,
            editedAt:
                freezed == editedAt
                    ? _value.editedAt
                    : editedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            deletedBy:
                freezed == deletedBy
                    ? _value.deletedBy
                    : deletedBy // ignore: cast_nullable_to_non_nullable
                        as String?,
            deletedAt:
                freezed == deletedAt
                    ? _value.deletedAt
                    : deletedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
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
abstract class _$$TaskCommentModelImplCopyWith<$Res>
    implements $TaskCommentModelCopyWith<$Res> {
  factory _$$TaskCommentModelImplCopyWith(
    _$TaskCommentModelImpl value,
    $Res Function(_$TaskCommentModelImpl) then,
  ) = __$$TaskCommentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String taskId,
    String content,
    String authorId,
    String authorName,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime updatedAt,
    String? parentCommentId,
    List<String> replies,
    List<String> attachments,
    List<String> mentions,
    bool isEdited,
    bool isDeleted,
    String? editedBy,
    @TimestampConverter() DateTime? editedAt,
    String? deletedBy,
    @TimestampConverter() DateTime? deletedAt,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$TaskCommentModelImplCopyWithImpl<$Res>
    extends _$TaskCommentModelCopyWithImpl<$Res, _$TaskCommentModelImpl>
    implements _$$TaskCommentModelImplCopyWith<$Res> {
  __$$TaskCommentModelImplCopyWithImpl(
    _$TaskCommentModelImpl _value,
    $Res Function(_$TaskCommentModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TaskCommentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? content = null,
    Object? authorId = null,
    Object? authorName = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? parentCommentId = freezed,
    Object? replies = null,
    Object? attachments = null,
    Object? mentions = null,
    Object? isEdited = null,
    Object? isDeleted = null,
    Object? editedBy = freezed,
    Object? editedAt = freezed,
    Object? deletedBy = freezed,
    Object? deletedAt = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$TaskCommentModelImpl(
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
        content:
            null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                    as String,
        authorId:
            null == authorId
                ? _value.authorId
                : authorId // ignore: cast_nullable_to_non_nullable
                    as String,
        authorName:
            null == authorName
                ? _value.authorName
                : authorName // ignore: cast_nullable_to_non_nullable
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
        parentCommentId:
            freezed == parentCommentId
                ? _value.parentCommentId
                : parentCommentId // ignore: cast_nullable_to_non_nullable
                    as String?,
        replies:
            null == replies
                ? _value._replies
                : replies // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        attachments:
            null == attachments
                ? _value._attachments
                : attachments // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        mentions:
            null == mentions
                ? _value._mentions
                : mentions // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        isEdited:
            null == isEdited
                ? _value.isEdited
                : isEdited // ignore: cast_nullable_to_non_nullable
                    as bool,
        isDeleted:
            null == isDeleted
                ? _value.isDeleted
                : isDeleted // ignore: cast_nullable_to_non_nullable
                    as bool,
        editedBy:
            freezed == editedBy
                ? _value.editedBy
                : editedBy // ignore: cast_nullable_to_non_nullable
                    as String?,
        editedAt:
            freezed == editedAt
                ? _value.editedAt
                : editedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        deletedBy:
            freezed == deletedBy
                ? _value.deletedBy
                : deletedBy // ignore: cast_nullable_to_non_nullable
                    as String?,
        deletedAt:
            freezed == deletedAt
                ? _value.deletedAt
                : deletedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
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
class _$TaskCommentModelImpl extends _TaskCommentModel {
  const _$TaskCommentModelImpl({
    required this.id,
    required this.taskId,
    required this.content,
    required this.authorId,
    required this.authorName,
    @TimestampConverter() required this.createdAt,
    @TimestampConverter() required this.updatedAt,
    this.parentCommentId,
    final List<String> replies = const [],
    final List<String> attachments = const [],
    final List<String> mentions = const [],
    this.isEdited = false,
    this.isDeleted = false,
    this.editedBy,
    @TimestampConverter() this.editedAt,
    this.deletedBy,
    @TimestampConverter() this.deletedAt,
    final Map<String, dynamic>? metadata,
  }) : _replies = replies,
       _attachments = attachments,
       _mentions = mentions,
       _metadata = metadata,
       super._();

  factory _$TaskCommentModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskCommentModelImplFromJson(json);

  @override
  final String id;
  @override
  final String taskId;
  @override
  final String content;
  @override
  final String authorId;
  @override
  final String authorName;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime updatedAt;
  @override
  final String? parentCommentId;
  final List<String> _replies;
  @override
  @JsonKey()
  List<String> get replies {
    if (_replies is EqualUnmodifiableListView) return _replies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_replies);
  }

  final List<String> _attachments;
  @override
  @JsonKey()
  List<String> get attachments {
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachments);
  }

  final List<String> _mentions;
  @override
  @JsonKey()
  List<String> get mentions {
    if (_mentions is EqualUnmodifiableListView) return _mentions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mentions);
  }

  @override
  @JsonKey()
  final bool isEdited;
  @override
  @JsonKey()
  final bool isDeleted;
  @override
  final String? editedBy;
  @override
  @TimestampConverter()
  final DateTime? editedAt;
  @override
  final String? deletedBy;
  @override
  @TimestampConverter()
  final DateTime? deletedAt;
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
    return 'TaskCommentModel(id: $id, taskId: $taskId, content: $content, authorId: $authorId, authorName: $authorName, createdAt: $createdAt, updatedAt: $updatedAt, parentCommentId: $parentCommentId, replies: $replies, attachments: $attachments, mentions: $mentions, isEdited: $isEdited, isDeleted: $isDeleted, editedBy: $editedBy, editedAt: $editedAt, deletedBy: $deletedBy, deletedAt: $deletedAt, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskCommentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.parentCommentId, parentCommentId) ||
                other.parentCommentId == parentCommentId) &&
            const DeepCollectionEquality().equals(other._replies, _replies) &&
            const DeepCollectionEquality().equals(
              other._attachments,
              _attachments,
            ) &&
            const DeepCollectionEquality().equals(other._mentions, _mentions) &&
            (identical(other.isEdited, isEdited) ||
                other.isEdited == isEdited) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.editedBy, editedBy) ||
                other.editedBy == editedBy) &&
            (identical(other.editedAt, editedAt) ||
                other.editedAt == editedAt) &&
            (identical(other.deletedBy, deletedBy) ||
                other.deletedBy == deletedBy) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    taskId,
    content,
    authorId,
    authorName,
    createdAt,
    updatedAt,
    parentCommentId,
    const DeepCollectionEquality().hash(_replies),
    const DeepCollectionEquality().hash(_attachments),
    const DeepCollectionEquality().hash(_mentions),
    isEdited,
    isDeleted,
    editedBy,
    editedAt,
    deletedBy,
    deletedAt,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of TaskCommentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskCommentModelImplCopyWith<_$TaskCommentModelImpl> get copyWith =>
      __$$TaskCommentModelImplCopyWithImpl<_$TaskCommentModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskCommentModelImplToJson(this);
  }
}

abstract class _TaskCommentModel extends TaskCommentModel {
  const factory _TaskCommentModel({
    required final String id,
    required final String taskId,
    required final String content,
    required final String authorId,
    required final String authorName,
    @TimestampConverter() required final DateTime createdAt,
    @TimestampConverter() required final DateTime updatedAt,
    final String? parentCommentId,
    final List<String> replies,
    final List<String> attachments,
    final List<String> mentions,
    final bool isEdited,
    final bool isDeleted,
    final String? editedBy,
    @TimestampConverter() final DateTime? editedAt,
    final String? deletedBy,
    @TimestampConverter() final DateTime? deletedAt,
    final Map<String, dynamic>? metadata,
  }) = _$TaskCommentModelImpl;
  const _TaskCommentModel._() : super._();

  factory _TaskCommentModel.fromJson(Map<String, dynamic> json) =
      _$TaskCommentModelImpl.fromJson;

  @override
  String get id;
  @override
  String get taskId;
  @override
  String get content;
  @override
  String get authorId;
  @override
  String get authorName;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt;
  @override
  String? get parentCommentId;
  @override
  List<String> get replies;
  @override
  List<String> get attachments;
  @override
  List<String> get mentions;
  @override
  bool get isEdited;
  @override
  bool get isDeleted;
  @override
  String? get editedBy;
  @override
  @TimestampConverter()
  DateTime? get editedAt;
  @override
  String? get deletedBy;
  @override
  @TimestampConverter()
  DateTime? get deletedAt;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of TaskCommentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskCommentModelImplCopyWith<_$TaskCommentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
