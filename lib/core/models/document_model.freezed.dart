// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DocumentModel _$DocumentModelFromJson(Map<String, dynamic> json) {
  return _DocumentModel.fromJson(json);
}

/// @nodoc
mixin _$DocumentModel {
  String get id => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  String get originalFileName => throw _privateConstructorUsedError;
  String get supabasePath => throw _privateConstructorUsedError;
  String get firebasePath => throw _privateConstructorUsedError;
  DocumentCategory get category => throw _privateConstructorUsedError;
  DocumentFileType get fileType => throw _privateConstructorUsedError;
  DocumentStatus get status => throw _privateConstructorUsedError;
  DocumentAccessLevel get accessLevel => throw _privateConstructorUsedError;
  String get uploadedBy => throw _privateConstructorUsedError;
  String get uploadedByName => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get uploadedAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;
  int get fileSizeBytes => throw _privateConstructorUsedError;
  List<String> get accessRoles => throw _privateConstructorUsedError;
  List<String> get accessUserIds => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get version => throw _privateConstructorUsedError;
  String? get folderId => throw _privateConstructorUsedError;
  String? get folderPath => throw _privateConstructorUsedError;
  String? get mimeType => throw _privateConstructorUsedError;
  String? get checksum => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;
  String? get approvedBy => throw _privateConstructorUsedError;
  String? get approvedByName => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get approvedAt => throw _privateConstructorUsedError;
  String? get rejectedBy => throw _privateConstructorUsedError;
  String? get rejectedByName => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get rejectedAt => throw _privateConstructorUsedError;
  String? get rejectionReason => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get archivedAt => throw _privateConstructorUsedError;
  String? get archivedBy => throw _privateConstructorUsedError;
  String? get archivedByName => throw _privateConstructorUsedError;
  String? get archiveReason => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  bool? get isConfidential => throw _privateConstructorUsedError;
  bool? get requiresApproval => throw _privateConstructorUsedError;
  int? get downloadCount => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get lastAccessedAt => throw _privateConstructorUsedError;
  String? get lastAccessedBy => throw _privateConstructorUsedError;

  /// Serializes this DocumentModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DocumentModelCopyWith<DocumentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DocumentModelCopyWith<$Res> {
  factory $DocumentModelCopyWith(
    DocumentModel value,
    $Res Function(DocumentModel) then,
  ) = _$DocumentModelCopyWithImpl<$Res, DocumentModel>;
  @useResult
  $Res call({
    String id,
    String fileName,
    String originalFileName,
    String supabasePath,
    String firebasePath,
    DocumentCategory category,
    DocumentFileType fileType,
    DocumentStatus status,
    DocumentAccessLevel accessLevel,
    String uploadedBy,
    String uploadedByName,
    @TimestampConverter() DateTime uploadedAt,
    @TimestampConverter() DateTime updatedAt,
    int fileSizeBytes,
    List<String> accessRoles,
    List<String> accessUserIds,
    String? description,
    String? version,
    String? folderId,
    String? folderPath,
    String? mimeType,
    String? checksum,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    String? approvedBy,
    String? approvedByName,
    @TimestampConverter() DateTime? approvedAt,
    String? rejectedBy,
    String? rejectedByName,
    @TimestampConverter() DateTime? rejectedAt,
    String? rejectionReason,
    @TimestampConverter() DateTime? archivedAt,
    String? archivedBy,
    String? archivedByName,
    String? archiveReason,
    @TimestampConverter() DateTime? expiresAt,
    bool? isConfidential,
    bool? requiresApproval,
    int? downloadCount,
    @TimestampConverter() DateTime? lastAccessedAt,
    String? lastAccessedBy,
  });
}

/// @nodoc
class _$DocumentModelCopyWithImpl<$Res, $Val extends DocumentModel>
    implements $DocumentModelCopyWith<$Res> {
  _$DocumentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fileName = null,
    Object? originalFileName = null,
    Object? supabasePath = null,
    Object? firebasePath = null,
    Object? category = null,
    Object? fileType = null,
    Object? status = null,
    Object? accessLevel = null,
    Object? uploadedBy = null,
    Object? uploadedByName = null,
    Object? uploadedAt = null,
    Object? updatedAt = null,
    Object? fileSizeBytes = null,
    Object? accessRoles = null,
    Object? accessUserIds = null,
    Object? description = freezed,
    Object? version = freezed,
    Object? folderId = freezed,
    Object? folderPath = freezed,
    Object? mimeType = freezed,
    Object? checksum = freezed,
    Object? metadata = freezed,
    Object? tags = freezed,
    Object? approvedBy = freezed,
    Object? approvedByName = freezed,
    Object? approvedAt = freezed,
    Object? rejectedBy = freezed,
    Object? rejectedByName = freezed,
    Object? rejectedAt = freezed,
    Object? rejectionReason = freezed,
    Object? archivedAt = freezed,
    Object? archivedBy = freezed,
    Object? archivedByName = freezed,
    Object? archiveReason = freezed,
    Object? expiresAt = freezed,
    Object? isConfidential = freezed,
    Object? requiresApproval = freezed,
    Object? downloadCount = freezed,
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
            category:
                null == category
                    ? _value.category
                    : category // ignore: cast_nullable_to_non_nullable
                        as DocumentCategory,
            fileType:
                null == fileType
                    ? _value.fileType
                    : fileType // ignore: cast_nullable_to_non_nullable
                        as DocumentFileType,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as DocumentStatus,
            accessLevel:
                null == accessLevel
                    ? _value.accessLevel
                    : accessLevel // ignore: cast_nullable_to_non_nullable
                        as DocumentAccessLevel,
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
            fileSizeBytes:
                null == fileSizeBytes
                    ? _value.fileSizeBytes
                    : fileSizeBytes // ignore: cast_nullable_to_non_nullable
                        as int,
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
            description:
                freezed == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String?,
            version:
                freezed == version
                    ? _value.version
                    : version // ignore: cast_nullable_to_non_nullable
                        as String?,
            folderId:
                freezed == folderId
                    ? _value.folderId
                    : folderId // ignore: cast_nullable_to_non_nullable
                        as String?,
            folderPath:
                freezed == folderPath
                    ? _value.folderPath
                    : folderPath // ignore: cast_nullable_to_non_nullable
                        as String?,
            mimeType:
                freezed == mimeType
                    ? _value.mimeType
                    : mimeType // ignore: cast_nullable_to_non_nullable
                        as String?,
            checksum:
                freezed == checksum
                    ? _value.checksum
                    : checksum // ignore: cast_nullable_to_non_nullable
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
            rejectedBy:
                freezed == rejectedBy
                    ? _value.rejectedBy
                    : rejectedBy // ignore: cast_nullable_to_non_nullable
                        as String?,
            rejectedByName:
                freezed == rejectedByName
                    ? _value.rejectedByName
                    : rejectedByName // ignore: cast_nullable_to_non_nullable
                        as String?,
            rejectedAt:
                freezed == rejectedAt
                    ? _value.rejectedAt
                    : rejectedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            rejectionReason:
                freezed == rejectionReason
                    ? _value.rejectionReason
                    : rejectionReason // ignore: cast_nullable_to_non_nullable
                        as String?,
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
            expiresAt:
                freezed == expiresAt
                    ? _value.expiresAt
                    : expiresAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            isConfidential:
                freezed == isConfidential
                    ? _value.isConfidential
                    : isConfidential // ignore: cast_nullable_to_non_nullable
                        as bool?,
            requiresApproval:
                freezed == requiresApproval
                    ? _value.requiresApproval
                    : requiresApproval // ignore: cast_nullable_to_non_nullable
                        as bool?,
            downloadCount:
                freezed == downloadCount
                    ? _value.downloadCount
                    : downloadCount // ignore: cast_nullable_to_non_nullable
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
abstract class _$$DocumentModelImplCopyWith<$Res>
    implements $DocumentModelCopyWith<$Res> {
  factory _$$DocumentModelImplCopyWith(
    _$DocumentModelImpl value,
    $Res Function(_$DocumentModelImpl) then,
  ) = __$$DocumentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String fileName,
    String originalFileName,
    String supabasePath,
    String firebasePath,
    DocumentCategory category,
    DocumentFileType fileType,
    DocumentStatus status,
    DocumentAccessLevel accessLevel,
    String uploadedBy,
    String uploadedByName,
    @TimestampConverter() DateTime uploadedAt,
    @TimestampConverter() DateTime updatedAt,
    int fileSizeBytes,
    List<String> accessRoles,
    List<String> accessUserIds,
    String? description,
    String? version,
    String? folderId,
    String? folderPath,
    String? mimeType,
    String? checksum,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    String? approvedBy,
    String? approvedByName,
    @TimestampConverter() DateTime? approvedAt,
    String? rejectedBy,
    String? rejectedByName,
    @TimestampConverter() DateTime? rejectedAt,
    String? rejectionReason,
    @TimestampConverter() DateTime? archivedAt,
    String? archivedBy,
    String? archivedByName,
    String? archiveReason,
    @TimestampConverter() DateTime? expiresAt,
    bool? isConfidential,
    bool? requiresApproval,
    int? downloadCount,
    @TimestampConverter() DateTime? lastAccessedAt,
    String? lastAccessedBy,
  });
}

/// @nodoc
class __$$DocumentModelImplCopyWithImpl<$Res>
    extends _$DocumentModelCopyWithImpl<$Res, _$DocumentModelImpl>
    implements _$$DocumentModelImplCopyWith<$Res> {
  __$$DocumentModelImplCopyWithImpl(
    _$DocumentModelImpl _value,
    $Res Function(_$DocumentModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fileName = null,
    Object? originalFileName = null,
    Object? supabasePath = null,
    Object? firebasePath = null,
    Object? category = null,
    Object? fileType = null,
    Object? status = null,
    Object? accessLevel = null,
    Object? uploadedBy = null,
    Object? uploadedByName = null,
    Object? uploadedAt = null,
    Object? updatedAt = null,
    Object? fileSizeBytes = null,
    Object? accessRoles = null,
    Object? accessUserIds = null,
    Object? description = freezed,
    Object? version = freezed,
    Object? folderId = freezed,
    Object? folderPath = freezed,
    Object? mimeType = freezed,
    Object? checksum = freezed,
    Object? metadata = freezed,
    Object? tags = freezed,
    Object? approvedBy = freezed,
    Object? approvedByName = freezed,
    Object? approvedAt = freezed,
    Object? rejectedBy = freezed,
    Object? rejectedByName = freezed,
    Object? rejectedAt = freezed,
    Object? rejectionReason = freezed,
    Object? archivedAt = freezed,
    Object? archivedBy = freezed,
    Object? archivedByName = freezed,
    Object? archiveReason = freezed,
    Object? expiresAt = freezed,
    Object? isConfidential = freezed,
    Object? requiresApproval = freezed,
    Object? downloadCount = freezed,
    Object? lastAccessedAt = freezed,
    Object? lastAccessedBy = freezed,
  }) {
    return _then(
      _$DocumentModelImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
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
        category:
            null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                    as DocumentCategory,
        fileType:
            null == fileType
                ? _value.fileType
                : fileType // ignore: cast_nullable_to_non_nullable
                    as DocumentFileType,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as DocumentStatus,
        accessLevel:
            null == accessLevel
                ? _value.accessLevel
                : accessLevel // ignore: cast_nullable_to_non_nullable
                    as DocumentAccessLevel,
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
        fileSizeBytes:
            null == fileSizeBytes
                ? _value.fileSizeBytes
                : fileSizeBytes // ignore: cast_nullable_to_non_nullable
                    as int,
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
        description:
            freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String?,
        version:
            freezed == version
                ? _value.version
                : version // ignore: cast_nullable_to_non_nullable
                    as String?,
        folderId:
            freezed == folderId
                ? _value.folderId
                : folderId // ignore: cast_nullable_to_non_nullable
                    as String?,
        folderPath:
            freezed == folderPath
                ? _value.folderPath
                : folderPath // ignore: cast_nullable_to_non_nullable
                    as String?,
        mimeType:
            freezed == mimeType
                ? _value.mimeType
                : mimeType // ignore: cast_nullable_to_non_nullable
                    as String?,
        checksum:
            freezed == checksum
                ? _value.checksum
                : checksum // ignore: cast_nullable_to_non_nullable
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
        rejectedBy:
            freezed == rejectedBy
                ? _value.rejectedBy
                : rejectedBy // ignore: cast_nullable_to_non_nullable
                    as String?,
        rejectedByName:
            freezed == rejectedByName
                ? _value.rejectedByName
                : rejectedByName // ignore: cast_nullable_to_non_nullable
                    as String?,
        rejectedAt:
            freezed == rejectedAt
                ? _value.rejectedAt
                : rejectedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        rejectionReason:
            freezed == rejectionReason
                ? _value.rejectionReason
                : rejectionReason // ignore: cast_nullable_to_non_nullable
                    as String?,
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
        expiresAt:
            freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        isConfidential:
            freezed == isConfidential
                ? _value.isConfidential
                : isConfidential // ignore: cast_nullable_to_non_nullable
                    as bool?,
        requiresApproval:
            freezed == requiresApproval
                ? _value.requiresApproval
                : requiresApproval // ignore: cast_nullable_to_non_nullable
                    as bool?,
        downloadCount:
            freezed == downloadCount
                ? _value.downloadCount
                : downloadCount // ignore: cast_nullable_to_non_nullable
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
class _$DocumentModelImpl implements _DocumentModel {
  const _$DocumentModelImpl({
    required this.id,
    required this.fileName,
    required this.originalFileName,
    required this.supabasePath,
    required this.firebasePath,
    required this.category,
    required this.fileType,
    required this.status,
    required this.accessLevel,
    required this.uploadedBy,
    required this.uploadedByName,
    @TimestampConverter() required this.uploadedAt,
    @TimestampConverter() required this.updatedAt,
    required this.fileSizeBytes,
    required final List<String> accessRoles,
    required final List<String> accessUserIds,
    this.description,
    this.version,
    this.folderId,
    this.folderPath,
    this.mimeType,
    this.checksum,
    final Map<String, dynamic>? metadata,
    final List<String>? tags,
    this.approvedBy,
    this.approvedByName,
    @TimestampConverter() this.approvedAt,
    this.rejectedBy,
    this.rejectedByName,
    @TimestampConverter() this.rejectedAt,
    this.rejectionReason,
    @TimestampConverter() this.archivedAt,
    this.archivedBy,
    this.archivedByName,
    this.archiveReason,
    @TimestampConverter() this.expiresAt,
    this.isConfidential,
    this.requiresApproval,
    this.downloadCount,
    @TimestampConverter() this.lastAccessedAt,
    this.lastAccessedBy,
  }) : _accessRoles = accessRoles,
       _accessUserIds = accessUserIds,
       _metadata = metadata,
       _tags = tags;

  factory _$DocumentModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DocumentModelImplFromJson(json);

  @override
  final String id;
  @override
  final String fileName;
  @override
  final String originalFileName;
  @override
  final String supabasePath;
  @override
  final String firebasePath;
  @override
  final DocumentCategory category;
  @override
  final DocumentFileType fileType;
  @override
  final DocumentStatus status;
  @override
  final DocumentAccessLevel accessLevel;
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
  final int fileSizeBytes;
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
  final String? description;
  @override
  final String? version;
  @override
  final String? folderId;
  @override
  final String? folderPath;
  @override
  final String? mimeType;
  @override
  final String? checksum;
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
  final String? approvedBy;
  @override
  final String? approvedByName;
  @override
  @TimestampConverter()
  final DateTime? approvedAt;
  @override
  final String? rejectedBy;
  @override
  final String? rejectedByName;
  @override
  @TimestampConverter()
  final DateTime? rejectedAt;
  @override
  final String? rejectionReason;
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
  @TimestampConverter()
  final DateTime? expiresAt;
  @override
  final bool? isConfidential;
  @override
  final bool? requiresApproval;
  @override
  final int? downloadCount;
  @override
  @TimestampConverter()
  final DateTime? lastAccessedAt;
  @override
  final String? lastAccessedBy;

  @override
  String toString() {
    return 'DocumentModel(id: $id, fileName: $fileName, originalFileName: $originalFileName, supabasePath: $supabasePath, firebasePath: $firebasePath, category: $category, fileType: $fileType, status: $status, accessLevel: $accessLevel, uploadedBy: $uploadedBy, uploadedByName: $uploadedByName, uploadedAt: $uploadedAt, updatedAt: $updatedAt, fileSizeBytes: $fileSizeBytes, accessRoles: $accessRoles, accessUserIds: $accessUserIds, description: $description, version: $version, folderId: $folderId, folderPath: $folderPath, mimeType: $mimeType, checksum: $checksum, metadata: $metadata, tags: $tags, approvedBy: $approvedBy, approvedByName: $approvedByName, approvedAt: $approvedAt, rejectedBy: $rejectedBy, rejectedByName: $rejectedByName, rejectedAt: $rejectedAt, rejectionReason: $rejectionReason, archivedAt: $archivedAt, archivedBy: $archivedBy, archivedByName: $archivedByName, archiveReason: $archiveReason, expiresAt: $expiresAt, isConfidential: $isConfidential, requiresApproval: $requiresApproval, downloadCount: $downloadCount, lastAccessedAt: $lastAccessedAt, lastAccessedBy: $lastAccessedBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DocumentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.originalFileName, originalFileName) ||
                other.originalFileName == originalFileName) &&
            (identical(other.supabasePath, supabasePath) ||
                other.supabasePath == supabasePath) &&
            (identical(other.firebasePath, firebasePath) ||
                other.firebasePath == firebasePath) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.fileType, fileType) ||
                other.fileType == fileType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.accessLevel, accessLevel) ||
                other.accessLevel == accessLevel) &&
            (identical(other.uploadedBy, uploadedBy) ||
                other.uploadedBy == uploadedBy) &&
            (identical(other.uploadedByName, uploadedByName) ||
                other.uploadedByName == uploadedByName) &&
            (identical(other.uploadedAt, uploadedAt) ||
                other.uploadedAt == uploadedAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.fileSizeBytes, fileSizeBytes) ||
                other.fileSizeBytes == fileSizeBytes) &&
            const DeepCollectionEquality().equals(
              other._accessRoles,
              _accessRoles,
            ) &&
            const DeepCollectionEquality().equals(
              other._accessUserIds,
              _accessUserIds,
            ) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.folderId, folderId) ||
                other.folderId == folderId) &&
            (identical(other.folderPath, folderPath) ||
                other.folderPath == folderPath) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType) &&
            (identical(other.checksum, checksum) ||
                other.checksum == checksum) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.approvedBy, approvedBy) ||
                other.approvedBy == approvedBy) &&
            (identical(other.approvedByName, approvedByName) ||
                other.approvedByName == approvedByName) &&
            (identical(other.approvedAt, approvedAt) ||
                other.approvedAt == approvedAt) &&
            (identical(other.rejectedBy, rejectedBy) ||
                other.rejectedBy == rejectedBy) &&
            (identical(other.rejectedByName, rejectedByName) ||
                other.rejectedByName == rejectedByName) &&
            (identical(other.rejectedAt, rejectedAt) ||
                other.rejectedAt == rejectedAt) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
            (identical(other.archivedAt, archivedAt) ||
                other.archivedAt == archivedAt) &&
            (identical(other.archivedBy, archivedBy) ||
                other.archivedBy == archivedBy) &&
            (identical(other.archivedByName, archivedByName) ||
                other.archivedByName == archivedByName) &&
            (identical(other.archiveReason, archiveReason) ||
                other.archiveReason == archiveReason) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.isConfidential, isConfidential) ||
                other.isConfidential == isConfidential) &&
            (identical(other.requiresApproval, requiresApproval) ||
                other.requiresApproval == requiresApproval) &&
            (identical(other.downloadCount, downloadCount) ||
                other.downloadCount == downloadCount) &&
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
    fileName,
    originalFileName,
    supabasePath,
    firebasePath,
    category,
    fileType,
    status,
    accessLevel,
    uploadedBy,
    uploadedByName,
    uploadedAt,
    updatedAt,
    fileSizeBytes,
    const DeepCollectionEquality().hash(_accessRoles),
    const DeepCollectionEquality().hash(_accessUserIds),
    description,
    version,
    folderId,
    folderPath,
    mimeType,
    checksum,
    const DeepCollectionEquality().hash(_metadata),
    const DeepCollectionEquality().hash(_tags),
    approvedBy,
    approvedByName,
    approvedAt,
    rejectedBy,
    rejectedByName,
    rejectedAt,
    rejectionReason,
    archivedAt,
    archivedBy,
    archivedByName,
    archiveReason,
    expiresAt,
    isConfidential,
    requiresApproval,
    downloadCount,
    lastAccessedAt,
    lastAccessedBy,
  ]);

  /// Create a copy of DocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DocumentModelImplCopyWith<_$DocumentModelImpl> get copyWith =>
      __$$DocumentModelImplCopyWithImpl<_$DocumentModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DocumentModelImplToJson(this);
  }
}

abstract class _DocumentModel implements DocumentModel {
  const factory _DocumentModel({
    required final String id,
    required final String fileName,
    required final String originalFileName,
    required final String supabasePath,
    required final String firebasePath,
    required final DocumentCategory category,
    required final DocumentFileType fileType,
    required final DocumentStatus status,
    required final DocumentAccessLevel accessLevel,
    required final String uploadedBy,
    required final String uploadedByName,
    @TimestampConverter() required final DateTime uploadedAt,
    @TimestampConverter() required final DateTime updatedAt,
    required final int fileSizeBytes,
    required final List<String> accessRoles,
    required final List<String> accessUserIds,
    final String? description,
    final String? version,
    final String? folderId,
    final String? folderPath,
    final String? mimeType,
    final String? checksum,
    final Map<String, dynamic>? metadata,
    final List<String>? tags,
    final String? approvedBy,
    final String? approvedByName,
    @TimestampConverter() final DateTime? approvedAt,
    final String? rejectedBy,
    final String? rejectedByName,
    @TimestampConverter() final DateTime? rejectedAt,
    final String? rejectionReason,
    @TimestampConverter() final DateTime? archivedAt,
    final String? archivedBy,
    final String? archivedByName,
    final String? archiveReason,
    @TimestampConverter() final DateTime? expiresAt,
    final bool? isConfidential,
    final bool? requiresApproval,
    final int? downloadCount,
    @TimestampConverter() final DateTime? lastAccessedAt,
    final String? lastAccessedBy,
  }) = _$DocumentModelImpl;

  factory _DocumentModel.fromJson(Map<String, dynamic> json) =
      _$DocumentModelImpl.fromJson;

  @override
  String get id;
  @override
  String get fileName;
  @override
  String get originalFileName;
  @override
  String get supabasePath;
  @override
  String get firebasePath;
  @override
  DocumentCategory get category;
  @override
  DocumentFileType get fileType;
  @override
  DocumentStatus get status;
  @override
  DocumentAccessLevel get accessLevel;
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
  int get fileSizeBytes;
  @override
  List<String> get accessRoles;
  @override
  List<String> get accessUserIds;
  @override
  String? get description;
  @override
  String? get version;
  @override
  String? get folderId;
  @override
  String? get folderPath;
  @override
  String? get mimeType;
  @override
  String? get checksum;
  @override
  Map<String, dynamic>? get metadata;
  @override
  List<String>? get tags;
  @override
  String? get approvedBy;
  @override
  String? get approvedByName;
  @override
  @TimestampConverter()
  DateTime? get approvedAt;
  @override
  String? get rejectedBy;
  @override
  String? get rejectedByName;
  @override
  @TimestampConverter()
  DateTime? get rejectedAt;
  @override
  String? get rejectionReason;
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
  @TimestampConverter()
  DateTime? get expiresAt;
  @override
  bool? get isConfidential;
  @override
  bool? get requiresApproval;
  @override
  int? get downloadCount;
  @override
  @TimestampConverter()
  DateTime? get lastAccessedAt;
  @override
  String? get lastAccessedBy;

  /// Create a copy of DocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DocumentModelImplCopyWith<_$DocumentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
