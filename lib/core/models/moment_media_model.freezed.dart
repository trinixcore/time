// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'moment_media_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MomentMedia _$MomentMediaFromJson(Map<String, dynamic> json) {
  return _MomentMedia.fromJson(json);
}

/// @nodoc
mixin _$MomentMedia {
  String get id => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  String get fileUrl => throw _privateConstructorUsedError;
  MediaType get mediaType => throw _privateConstructorUsedError;
  int get displayOrder => throw _privateConstructorUsedError;
  String get uploadedBy => throw _privateConstructorUsedError;
  DateTime get uploadedAt => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  String? get signedUrl => throw _privateConstructorUsedError;

  /// Serializes this MomentMedia to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MomentMedia
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MomentMediaCopyWith<MomentMedia> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MomentMediaCopyWith<$Res> {
  factory $MomentMediaCopyWith(
    MomentMedia value,
    $Res Function(MomentMedia) then,
  ) = _$MomentMediaCopyWithImpl<$Res, MomentMedia>;
  @useResult
  $Res call({
    String id,
    String fileName,
    String fileUrl,
    MediaType mediaType,
    int displayOrder,
    String uploadedBy,
    DateTime uploadedAt,
    String? title,
    String? description,
    bool isActive,
    @JsonKey(ignore: true) String? signedUrl,
  });
}

/// @nodoc
class _$MomentMediaCopyWithImpl<$Res, $Val extends MomentMedia>
    implements $MomentMediaCopyWith<$Res> {
  _$MomentMediaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MomentMedia
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fileName = null,
    Object? fileUrl = null,
    Object? mediaType = null,
    Object? displayOrder = null,
    Object? uploadedBy = null,
    Object? uploadedAt = null,
    Object? title = freezed,
    Object? description = freezed,
    Object? isActive = null,
    Object? signedUrl = freezed,
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
            fileUrl:
                null == fileUrl
                    ? _value.fileUrl
                    : fileUrl // ignore: cast_nullable_to_non_nullable
                        as String,
            mediaType:
                null == mediaType
                    ? _value.mediaType
                    : mediaType // ignore: cast_nullable_to_non_nullable
                        as MediaType,
            displayOrder:
                null == displayOrder
                    ? _value.displayOrder
                    : displayOrder // ignore: cast_nullable_to_non_nullable
                        as int,
            uploadedBy:
                null == uploadedBy
                    ? _value.uploadedBy
                    : uploadedBy // ignore: cast_nullable_to_non_nullable
                        as String,
            uploadedAt:
                null == uploadedAt
                    ? _value.uploadedAt
                    : uploadedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            title:
                freezed == title
                    ? _value.title
                    : title // ignore: cast_nullable_to_non_nullable
                        as String?,
            description:
                freezed == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String?,
            isActive:
                null == isActive
                    ? _value.isActive
                    : isActive // ignore: cast_nullable_to_non_nullable
                        as bool,
            signedUrl:
                freezed == signedUrl
                    ? _value.signedUrl
                    : signedUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MomentMediaImplCopyWith<$Res>
    implements $MomentMediaCopyWith<$Res> {
  factory _$$MomentMediaImplCopyWith(
    _$MomentMediaImpl value,
    $Res Function(_$MomentMediaImpl) then,
  ) = __$$MomentMediaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String fileName,
    String fileUrl,
    MediaType mediaType,
    int displayOrder,
    String uploadedBy,
    DateTime uploadedAt,
    String? title,
    String? description,
    bool isActive,
    @JsonKey(ignore: true) String? signedUrl,
  });
}

/// @nodoc
class __$$MomentMediaImplCopyWithImpl<$Res>
    extends _$MomentMediaCopyWithImpl<$Res, _$MomentMediaImpl>
    implements _$$MomentMediaImplCopyWith<$Res> {
  __$$MomentMediaImplCopyWithImpl(
    _$MomentMediaImpl _value,
    $Res Function(_$MomentMediaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MomentMedia
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fileName = null,
    Object? fileUrl = null,
    Object? mediaType = null,
    Object? displayOrder = null,
    Object? uploadedBy = null,
    Object? uploadedAt = null,
    Object? title = freezed,
    Object? description = freezed,
    Object? isActive = null,
    Object? signedUrl = freezed,
  }) {
    return _then(
      _$MomentMediaImpl(
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
        fileUrl:
            null == fileUrl
                ? _value.fileUrl
                : fileUrl // ignore: cast_nullable_to_non_nullable
                    as String,
        mediaType:
            null == mediaType
                ? _value.mediaType
                : mediaType // ignore: cast_nullable_to_non_nullable
                    as MediaType,
        displayOrder:
            null == displayOrder
                ? _value.displayOrder
                : displayOrder // ignore: cast_nullable_to_non_nullable
                    as int,
        uploadedBy:
            null == uploadedBy
                ? _value.uploadedBy
                : uploadedBy // ignore: cast_nullable_to_non_nullable
                    as String,
        uploadedAt:
            null == uploadedAt
                ? _value.uploadedAt
                : uploadedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        title:
            freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                    as String?,
        description:
            freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String?,
        isActive:
            null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                    as bool,
        signedUrl:
            freezed == signedUrl
                ? _value.signedUrl
                : signedUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MomentMediaImpl implements _MomentMedia {
  const _$MomentMediaImpl({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.mediaType,
    required this.displayOrder,
    required this.uploadedBy,
    required this.uploadedAt,
    this.title,
    this.description,
    this.isActive = true,
    @JsonKey(ignore: true) this.signedUrl = null,
  });

  factory _$MomentMediaImpl.fromJson(Map<String, dynamic> json) =>
      _$$MomentMediaImplFromJson(json);

  @override
  final String id;
  @override
  final String fileName;
  @override
  final String fileUrl;
  @override
  final MediaType mediaType;
  @override
  final int displayOrder;
  @override
  final String uploadedBy;
  @override
  final DateTime uploadedAt;
  @override
  final String? title;
  @override
  final String? description;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey(ignore: true)
  final String? signedUrl;

  @override
  String toString() {
    return 'MomentMedia(id: $id, fileName: $fileName, fileUrl: $fileUrl, mediaType: $mediaType, displayOrder: $displayOrder, uploadedBy: $uploadedBy, uploadedAt: $uploadedAt, title: $title, description: $description, isActive: $isActive, signedUrl: $signedUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MomentMediaImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType) &&
            (identical(other.displayOrder, displayOrder) ||
                other.displayOrder == displayOrder) &&
            (identical(other.uploadedBy, uploadedBy) ||
                other.uploadedBy == uploadedBy) &&
            (identical(other.uploadedAt, uploadedAt) ||
                other.uploadedAt == uploadedAt) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.signedUrl, signedUrl) ||
                other.signedUrl == signedUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    fileName,
    fileUrl,
    mediaType,
    displayOrder,
    uploadedBy,
    uploadedAt,
    title,
    description,
    isActive,
    signedUrl,
  );

  /// Create a copy of MomentMedia
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MomentMediaImplCopyWith<_$MomentMediaImpl> get copyWith =>
      __$$MomentMediaImplCopyWithImpl<_$MomentMediaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MomentMediaImplToJson(this);
  }
}

abstract class _MomentMedia implements MomentMedia {
  const factory _MomentMedia({
    required final String id,
    required final String fileName,
    required final String fileUrl,
    required final MediaType mediaType,
    required final int displayOrder,
    required final String uploadedBy,
    required final DateTime uploadedAt,
    final String? title,
    final String? description,
    final bool isActive,
    @JsonKey(ignore: true) final String? signedUrl,
  }) = _$MomentMediaImpl;

  factory _MomentMedia.fromJson(Map<String, dynamic> json) =
      _$MomentMediaImpl.fromJson;

  @override
  String get id;
  @override
  String get fileName;
  @override
  String get fileUrl;
  @override
  MediaType get mediaType;
  @override
  int get displayOrder;
  @override
  String get uploadedBy;
  @override
  DateTime get uploadedAt;
  @override
  String? get title;
  @override
  String? get description;
  @override
  bool get isActive;
  @override
  @JsonKey(ignore: true)
  String? get signedUrl;

  /// Create a copy of MomentMedia
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MomentMediaImplCopyWith<_$MomentMediaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
