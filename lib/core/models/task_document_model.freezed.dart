// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_document_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TaskDocumentModel _$TaskDocumentModelFromJson(Map<String, dynamic> json) {
  return _TaskDocumentModel.fromJson(json);
}

/// @nodoc
mixin _$TaskDocumentModel {
  String get id => throw _privateConstructorUsedError;
  String get taskId => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  String get originalFileName => throw _privateConstructorUsedError;
  String get supabasePath => throw _privateConstructorUsedError;
  String get firebasePath => throw _privateConstructorUsedError;
  String get fileType => throw _privateConstructorUsedError;
  String get mimeType => throw _privateConstructorUsedError;
  int get fileSizeBytes => throw _privateConstructorUsedError;
  String get uploadedBy => throw _privateConstructorUsedError;
  String get uploadedByName => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get uploadedAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;
  String? get checksum => throw _privateConstructorUsedError;
  bool get isConfidential => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  /// Serializes this TaskDocumentModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TaskDocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskDocumentModelCopyWith<TaskDocumentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskDocumentModelCopyWith<$Res> {
  factory $TaskDocumentModelCopyWith(
    TaskDocumentModel value,
    $Res Function(TaskDocumentModel) then,
  ) = _$TaskDocumentModelCopyWithImpl<$Res, TaskDocumentModel>;
  @useResult
  $Res call({
    String id,
    String taskId,
    String fileName,
    String originalFileName,
    String supabasePath,
    String firebasePath,
    String fileType,
    String mimeType,
    int fileSizeBytes,
    String uploadedBy,
    String uploadedByName,
    @TimestampConverter() DateTime uploadedAt,
    @TimestampConverter() DateTime updatedAt,
    String? description,
    List<String>? tags,
    String? checksum,
    bool isConfidential,
    String status,
  });
}

/// @nodoc
class _$TaskDocumentModelCopyWithImpl<$Res, $Val extends TaskDocumentModel>
    implements $TaskDocumentModelCopyWith<$Res> {
  _$TaskDocumentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaskDocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? fileName = null,
    Object? originalFileName = null,
    Object? supabasePath = null,
    Object? firebasePath = null,
    Object? fileType = null,
    Object? mimeType = null,
    Object? fileSizeBytes = null,
    Object? uploadedBy = null,
    Object? uploadedByName = null,
    Object? uploadedAt = null,
    Object? updatedAt = null,
    Object? description = freezed,
    Object? tags = freezed,
    Object? checksum = freezed,
    Object? isConfidential = null,
    Object? status = null,
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
            fileName:
                null == fileName
                    ? _value.fileName
                    : fileName // ignore: cast_nullable_to_non_nullable
                        as String,
            originalFileName:
                null == originalFileName
                    ? _value.originalFileName
                    : originalFileName // ignore: cast_nullable_to_non_nullable
                        as String,
            supabasePath:
                null == supabasePath
                    ? _value.supabasePath
                    : supabasePath // ignore: cast_nullable_to_non_nullable
                        as String,
            firebasePath:
                null == firebasePath
                    ? _value.firebasePath
                    : firebasePath // ignore: cast_nullable_to_non_nullable
                        as String,
            fileType:
                null == fileType
                    ? _value.fileType
                    : fileType // ignore: cast_nullable_to_non_nullable
                        as String,
            mimeType:
                null == mimeType
                    ? _value.mimeType
                    : mimeType // ignore: cast_nullable_to_non_nullable
                        as String,
            fileSizeBytes:
                null == fileSizeBytes
                    ? _value.fileSizeBytes
                    : fileSizeBytes // ignore: cast_nullable_to_non_nullable
                        as int,
            uploadedBy:
                null == uploadedBy
                    ? _value.uploadedBy
                    : uploadedBy // ignore: cast_nullable_to_non_nullable
                        as String,
            uploadedByName:
                null == uploadedByName
                    ? _value.uploadedByName
                    : uploadedByName // ignore: cast_nullable_to_non_nullable
                        as String,
            uploadedAt:
                null == uploadedAt
                    ? _value.uploadedAt
                    : uploadedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            updatedAt:
                null == updatedAt
                    ? _value.updatedAt
                    : updatedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            description:
                freezed == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String?,
            tags:
                freezed == tags
                    ? _value.tags
                    : tags // ignore: cast_nullable_to_non_nullable
                        as List<String>?,
            checksum:
                freezed == checksum
                    ? _value.checksum
                    : checksum // ignore: cast_nullable_to_non_nullable
                        as String?,
            isConfidential:
                null == isConfidential
                    ? _value.isConfidential
                    : isConfidential // ignore: cast_nullable_to_non_nullable
                        as bool,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TaskDocumentModelImplCopyWith<$Res>
    implements $TaskDocumentModelCopyWith<$Res> {
  factory _$$TaskDocumentModelImplCopyWith(
    _$TaskDocumentModelImpl value,
    $Res Function(_$TaskDocumentModelImpl) then,
  ) = __$$TaskDocumentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String taskId,
    String fileName,
    String originalFileName,
    String supabasePath,
    String firebasePath,
    String fileType,
    String mimeType,
    int fileSizeBytes,
    String uploadedBy,
    String uploadedByName,
    @TimestampConverter() DateTime uploadedAt,
    @TimestampConverter() DateTime updatedAt,
    String? description,
    List<String>? tags,
    String? checksum,
    bool isConfidential,
    String status,
  });
}

/// @nodoc
class __$$TaskDocumentModelImplCopyWithImpl<$Res>
    extends _$TaskDocumentModelCopyWithImpl<$Res, _$TaskDocumentModelImpl>
    implements _$$TaskDocumentModelImplCopyWith<$Res> {
  __$$TaskDocumentModelImplCopyWithImpl(
    _$TaskDocumentModelImpl _value,
    $Res Function(_$TaskDocumentModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TaskDocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? fileName = null,
    Object? originalFileName = null,
    Object? supabasePath = null,
    Object? firebasePath = null,
    Object? fileType = null,
    Object? mimeType = null,
    Object? fileSizeBytes = null,
    Object? uploadedBy = null,
    Object? uploadedByName = null,
    Object? uploadedAt = null,
    Object? updatedAt = null,
    Object? description = freezed,
    Object? tags = freezed,
    Object? checksum = freezed,
    Object? isConfidential = null,
    Object? status = null,
  }) {
    return _then(
      _$TaskDocumentModelImpl(
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
        fileName:
            null == fileName
                ? _value.fileName
                : fileName // ignore: cast_nullable_to_non_nullable
                    as String,
        originalFileName:
            null == originalFileName
                ? _value.originalFileName
                : originalFileName // ignore: cast_nullable_to_non_nullable
                    as String,
        supabasePath:
            null == supabasePath
                ? _value.supabasePath
                : supabasePath // ignore: cast_nullable_to_non_nullable
                    as String,
        firebasePath:
            null == firebasePath
                ? _value.firebasePath
                : firebasePath // ignore: cast_nullable_to_non_nullable
                    as String,
        fileType:
            null == fileType
                ? _value.fileType
                : fileType // ignore: cast_nullable_to_non_nullable
                    as String,
        mimeType:
            null == mimeType
                ? _value.mimeType
                : mimeType // ignore: cast_nullable_to_non_nullable
                    as String,
        fileSizeBytes:
            null == fileSizeBytes
                ? _value.fileSizeBytes
                : fileSizeBytes // ignore: cast_nullable_to_non_nullable
                    as int,
        uploadedBy:
            null == uploadedBy
                ? _value.uploadedBy
                : uploadedBy // ignore: cast_nullable_to_non_nullable
                    as String,
        uploadedByName:
            null == uploadedByName
                ? _value.uploadedByName
                : uploadedByName // ignore: cast_nullable_to_non_nullable
                    as String,
        uploadedAt:
            null == uploadedAt
                ? _value.uploadedAt
                : uploadedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        updatedAt:
            null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        description:
            freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String?,
        tags:
            freezed == tags
                ? _value._tags
                : tags // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
        checksum:
            freezed == checksum
                ? _value.checksum
                : checksum // ignore: cast_nullable_to_non_nullable
                    as String?,
        isConfidential:
            null == isConfidential
                ? _value.isConfidential
                : isConfidential // ignore: cast_nullable_to_non_nullable
                    as bool,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TaskDocumentModelImpl implements _TaskDocumentModel {
  const _$TaskDocumentModelImpl({
    required this.id,
    required this.taskId,
    required this.fileName,
    required this.originalFileName,
    required this.supabasePath,
    required this.firebasePath,
    required this.fileType,
    required this.mimeType,
    required this.fileSizeBytes,
    required this.uploadedBy,
    required this.uploadedByName,
    @TimestampConverter() required this.uploadedAt,
    @TimestampConverter() required this.updatedAt,
    this.description,
    final List<String>? tags,
    this.checksum,
    this.isConfidential = false,
    this.status = 'approved',
  }) : _tags = tags;

  factory _$TaskDocumentModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskDocumentModelImplFromJson(json);

  @override
  final String id;
  @override
  final String taskId;
  @override
  final String fileName;
  @override
  final String originalFileName;
  @override
  final String supabasePath;
  @override
  final String firebasePath;
  @override
  final String fileType;
  @override
  final String mimeType;
  @override
  final int fileSizeBytes;
  @override
  final String uploadedBy;
  @override
  final String uploadedByName;
  @override
  @TimestampConverter()
  final DateTime uploadedAt;
  @override
  @TimestampConverter()
  final DateTime updatedAt;
  @override
  final String? description;
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
  final String? checksum;
  @override
  @JsonKey()
  final bool isConfidential;
  @override
  @JsonKey()
  final String status;

  @override
  String toString() {
    return 'TaskDocumentModel(id: $id, taskId: $taskId, fileName: $fileName, originalFileName: $originalFileName, supabasePath: $supabasePath, firebasePath: $firebasePath, fileType: $fileType, mimeType: $mimeType, fileSizeBytes: $fileSizeBytes, uploadedBy: $uploadedBy, uploadedByName: $uploadedByName, uploadedAt: $uploadedAt, updatedAt: $updatedAt, description: $description, tags: $tags, checksum: $checksum, isConfidential: $isConfidential, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskDocumentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.originalFileName, originalFileName) ||
                other.originalFileName == originalFileName) &&
            (identical(other.supabasePath, supabasePath) ||
                other.supabasePath == supabasePath) &&
            (identical(other.firebasePath, firebasePath) ||
                other.firebasePath == firebasePath) &&
            (identical(other.fileType, fileType) ||
                other.fileType == fileType) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType) &&
            (identical(other.fileSizeBytes, fileSizeBytes) ||
                other.fileSizeBytes == fileSizeBytes) &&
            (identical(other.uploadedBy, uploadedBy) ||
                other.uploadedBy == uploadedBy) &&
            (identical(other.uploadedByName, uploadedByName) ||
                other.uploadedByName == uploadedByName) &&
            (identical(other.uploadedAt, uploadedAt) ||
                other.uploadedAt == uploadedAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.checksum, checksum) ||
                other.checksum == checksum) &&
            (identical(other.isConfidential, isConfidential) ||
                other.isConfidential == isConfidential) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    taskId,
    fileName,
    originalFileName,
    supabasePath,
    firebasePath,
    fileType,
    mimeType,
    fileSizeBytes,
    uploadedBy,
    uploadedByName,
    uploadedAt,
    updatedAt,
    description,
    const DeepCollectionEquality().hash(_tags),
    checksum,
    isConfidential,
    status,
  );

  /// Create a copy of TaskDocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskDocumentModelImplCopyWith<_$TaskDocumentModelImpl> get copyWith =>
      __$$TaskDocumentModelImplCopyWithImpl<_$TaskDocumentModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskDocumentModelImplToJson(this);
  }
}

abstract class _TaskDocumentModel implements TaskDocumentModel {
  const factory _TaskDocumentModel({
    required final String id,
    required final String taskId,
    required final String fileName,
    required final String originalFileName,
    required final String supabasePath,
    required final String firebasePath,
    required final String fileType,
    required final String mimeType,
    required final int fileSizeBytes,
    required final String uploadedBy,
    required final String uploadedByName,
    @TimestampConverter() required final DateTime uploadedAt,
    @TimestampConverter() required final DateTime updatedAt,
    final String? description,
    final List<String>? tags,
    final String? checksum,
    final bool isConfidential,
    final String status,
  }) = _$TaskDocumentModelImpl;

  factory _TaskDocumentModel.fromJson(Map<String, dynamic> json) =
      _$TaskDocumentModelImpl.fromJson;

  @override
  String get id;
  @override
  String get taskId;
  @override
  String get fileName;
  @override
  String get originalFileName;
  @override
  String get supabasePath;
  @override
  String get firebasePath;
  @override
  String get fileType;
  @override
  String get mimeType;
  @override
  int get fileSizeBytes;
  @override
  String get uploadedBy;
  @override
  String get uploadedByName;
  @override
  @TimestampConverter()
  DateTime get uploadedAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt;
  @override
  String? get description;
  @override
  List<String>? get tags;
  @override
  String? get checksum;
  @override
  bool get isConfidential;
  @override
  String get status;

  /// Create a copy of TaskDocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskDocumentModelImplCopyWith<_$TaskDocumentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
