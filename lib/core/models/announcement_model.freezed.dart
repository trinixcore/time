// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'announcement_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Announcement _$AnnouncementFromJson(Map<String, dynamic> json) {
  return _Announcement.fromJson(json);
}

/// @nodoc
mixin _$Announcement {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  String get priority =>
      throw _privateConstructorUsedError; // high, medium, low
  List<String> get tags =>
      throw _privateConstructorUsedError; // ['urgent', 'update', 'maintenance', 'celebration']
  String? get category =>
      throw _privateConstructorUsedError; // 'system', 'event', 'maintenance', 'general'
  String? get richContent =>
      throw _privateConstructorUsedError; // HTML/Markdown content
  List<String> get attachments =>
      throw _privateConstructorUsedError; // Links to documents/images
  List<String> get targetDepartments =>
      throw _privateConstructorUsedError; // Specific departments
  List<String> get targetRoles =>
      throw _privateConstructorUsedError; // Specific roles
  bool get isGlobal => throw _privateConstructorUsedError; // Show to all users
  bool get requiresAcknowledgment =>
      throw _privateConstructorUsedError; // Users must mark as read
  List<String> get acknowledgedBy =>
      throw _privateConstructorUsedError; // Track who has seen it
  int? get maxViews =>
      throw _privateConstructorUsedError; // Limit visibility after X views
  int get viewCount => throw _privateConstructorUsedError; // Track total views
  String? get createdByName => throw _privateConstructorUsedError;

  /// Serializes this Announcement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Announcement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnnouncementCopyWith<Announcement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnnouncementCopyWith<$Res> {
  factory $AnnouncementCopyWith(
    Announcement value,
    $Res Function(Announcement) then,
  ) = _$AnnouncementCopyWithImpl<$Res, Announcement>;
  @useResult
  $Res call({
    String id,
    String title,
    String content,
    String createdBy,
    DateTime createdAt,
    @TimestampConverter() DateTime? expiresAt,
    bool isActive,
    String priority,
    List<String> tags,
    String? category,
    String? richContent,
    List<String> attachments,
    List<String> targetDepartments,
    List<String> targetRoles,
    bool isGlobal,
    bool requiresAcknowledgment,
    List<String> acknowledgedBy,
    int? maxViews,
    int viewCount,
    String? createdByName,
  });
}

/// @nodoc
class _$AnnouncementCopyWithImpl<$Res, $Val extends Announcement>
    implements $AnnouncementCopyWith<$Res> {
  _$AnnouncementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Announcement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? content = null,
    Object? createdBy = null,
    Object? createdAt = null,
    Object? expiresAt = freezed,
    Object? isActive = null,
    Object? priority = null,
    Object? tags = null,
    Object? category = freezed,
    Object? richContent = freezed,
    Object? attachments = null,
    Object? targetDepartments = null,
    Object? targetRoles = null,
    Object? isGlobal = null,
    Object? requiresAcknowledgment = null,
    Object? acknowledgedBy = null,
    Object? maxViews = freezed,
    Object? viewCount = null,
    Object? createdByName = freezed,
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
            content:
                null == content
                    ? _value.content
                    : content // ignore: cast_nullable_to_non_nullable
                        as String,
            createdBy:
                null == createdBy
                    ? _value.createdBy
                    : createdBy // ignore: cast_nullable_to_non_nullable
                        as String,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            expiresAt:
                freezed == expiresAt
                    ? _value.expiresAt
                    : expiresAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            isActive:
                null == isActive
                    ? _value.isActive
                    : isActive // ignore: cast_nullable_to_non_nullable
                        as bool,
            priority:
                null == priority
                    ? _value.priority
                    : priority // ignore: cast_nullable_to_non_nullable
                        as String,
            tags:
                null == tags
                    ? _value.tags
                    : tags // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            category:
                freezed == category
                    ? _value.category
                    : category // ignore: cast_nullable_to_non_nullable
                        as String?,
            richContent:
                freezed == richContent
                    ? _value.richContent
                    : richContent // ignore: cast_nullable_to_non_nullable
                        as String?,
            attachments:
                null == attachments
                    ? _value.attachments
                    : attachments // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            targetDepartments:
                null == targetDepartments
                    ? _value.targetDepartments
                    : targetDepartments // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            targetRoles:
                null == targetRoles
                    ? _value.targetRoles
                    : targetRoles // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            isGlobal:
                null == isGlobal
                    ? _value.isGlobal
                    : isGlobal // ignore: cast_nullable_to_non_nullable
                        as bool,
            requiresAcknowledgment:
                null == requiresAcknowledgment
                    ? _value.requiresAcknowledgment
                    : requiresAcknowledgment // ignore: cast_nullable_to_non_nullable
                        as bool,
            acknowledgedBy:
                null == acknowledgedBy
                    ? _value.acknowledgedBy
                    : acknowledgedBy // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            maxViews:
                freezed == maxViews
                    ? _value.maxViews
                    : maxViews // ignore: cast_nullable_to_non_nullable
                        as int?,
            viewCount:
                null == viewCount
                    ? _value.viewCount
                    : viewCount // ignore: cast_nullable_to_non_nullable
                        as int,
            createdByName:
                freezed == createdByName
                    ? _value.createdByName
                    : createdByName // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AnnouncementImplCopyWith<$Res>
    implements $AnnouncementCopyWith<$Res> {
  factory _$$AnnouncementImplCopyWith(
    _$AnnouncementImpl value,
    $Res Function(_$AnnouncementImpl) then,
  ) = __$$AnnouncementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String content,
    String createdBy,
    DateTime createdAt,
    @TimestampConverter() DateTime? expiresAt,
    bool isActive,
    String priority,
    List<String> tags,
    String? category,
    String? richContent,
    List<String> attachments,
    List<String> targetDepartments,
    List<String> targetRoles,
    bool isGlobal,
    bool requiresAcknowledgment,
    List<String> acknowledgedBy,
    int? maxViews,
    int viewCount,
    String? createdByName,
  });
}

/// @nodoc
class __$$AnnouncementImplCopyWithImpl<$Res>
    extends _$AnnouncementCopyWithImpl<$Res, _$AnnouncementImpl>
    implements _$$AnnouncementImplCopyWith<$Res> {
  __$$AnnouncementImplCopyWithImpl(
    _$AnnouncementImpl _value,
    $Res Function(_$AnnouncementImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Announcement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? content = null,
    Object? createdBy = null,
    Object? createdAt = null,
    Object? expiresAt = freezed,
    Object? isActive = null,
    Object? priority = null,
    Object? tags = null,
    Object? category = freezed,
    Object? richContent = freezed,
    Object? attachments = null,
    Object? targetDepartments = null,
    Object? targetRoles = null,
    Object? isGlobal = null,
    Object? requiresAcknowledgment = null,
    Object? acknowledgedBy = null,
    Object? maxViews = freezed,
    Object? viewCount = null,
    Object? createdByName = freezed,
  }) {
    return _then(
      _$AnnouncementImpl(
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
        content:
            null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                    as String,
        createdBy:
            null == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                    as String,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        expiresAt:
            freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        isActive:
            null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                    as bool,
        priority:
            null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                    as String,
        tags:
            null == tags
                ? _value._tags
                : tags // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        category:
            freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                    as String?,
        richContent:
            freezed == richContent
                ? _value.richContent
                : richContent // ignore: cast_nullable_to_non_nullable
                    as String?,
        attachments:
            null == attachments
                ? _value._attachments
                : attachments // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        targetDepartments:
            null == targetDepartments
                ? _value._targetDepartments
                : targetDepartments // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        targetRoles:
            null == targetRoles
                ? _value._targetRoles
                : targetRoles // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        isGlobal:
            null == isGlobal
                ? _value.isGlobal
                : isGlobal // ignore: cast_nullable_to_non_nullable
                    as bool,
        requiresAcknowledgment:
            null == requiresAcknowledgment
                ? _value.requiresAcknowledgment
                : requiresAcknowledgment // ignore: cast_nullable_to_non_nullable
                    as bool,
        acknowledgedBy:
            null == acknowledgedBy
                ? _value._acknowledgedBy
                : acknowledgedBy // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        maxViews:
            freezed == maxViews
                ? _value.maxViews
                : maxViews // ignore: cast_nullable_to_non_nullable
                    as int?,
        viewCount:
            null == viewCount
                ? _value.viewCount
                : viewCount // ignore: cast_nullable_to_non_nullable
                    as int,
        createdByName:
            freezed == createdByName
                ? _value.createdByName
                : createdByName // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AnnouncementImpl extends _Announcement {
  const _$AnnouncementImpl({
    required this.id,
    required this.title,
    required this.content,
    required this.createdBy,
    required this.createdAt,
    @TimestampConverter() this.expiresAt,
    this.isActive = true,
    this.priority = 'medium',
    final List<String> tags = const [],
    this.category,
    this.richContent,
    final List<String> attachments = const [],
    final List<String> targetDepartments = const [],
    final List<String> targetRoles = const [],
    this.isGlobal = true,
    this.requiresAcknowledgment = false,
    final List<String> acknowledgedBy = const [],
    this.maxViews,
    this.viewCount = 0,
    this.createdByName,
  }) : _tags = tags,
       _attachments = attachments,
       _targetDepartments = targetDepartments,
       _targetRoles = targetRoles,
       _acknowledgedBy = acknowledgedBy,
       super._();

  factory _$AnnouncementImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnnouncementImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String content;
  @override
  final String createdBy;
  @override
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime? expiresAt;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final String priority;
  // high, medium, low
  final List<String> _tags;
  // high, medium, low
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  // ['urgent', 'update', 'maintenance', 'celebration']
  @override
  final String? category;
  // 'system', 'event', 'maintenance', 'general'
  @override
  final String? richContent;
  // HTML/Markdown content
  final List<String> _attachments;
  // HTML/Markdown content
  @override
  @JsonKey()
  List<String> get attachments {
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachments);
  }

  // Links to documents/images
  final List<String> _targetDepartments;
  // Links to documents/images
  @override
  @JsonKey()
  List<String> get targetDepartments {
    if (_targetDepartments is EqualUnmodifiableListView)
      return _targetDepartments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_targetDepartments);
  }

  // Specific departments
  final List<String> _targetRoles;
  // Specific departments
  @override
  @JsonKey()
  List<String> get targetRoles {
    if (_targetRoles is EqualUnmodifiableListView) return _targetRoles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_targetRoles);
  }

  // Specific roles
  @override
  @JsonKey()
  final bool isGlobal;
  // Show to all users
  @override
  @JsonKey()
  final bool requiresAcknowledgment;
  // Users must mark as read
  final List<String> _acknowledgedBy;
  // Users must mark as read
  @override
  @JsonKey()
  List<String> get acknowledgedBy {
    if (_acknowledgedBy is EqualUnmodifiableListView) return _acknowledgedBy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_acknowledgedBy);
  }

  // Track who has seen it
  @override
  final int? maxViews;
  // Limit visibility after X views
  @override
  @JsonKey()
  final int viewCount;
  // Track total views
  @override
  final String? createdByName;

  @override
  String toString() {
    return 'Announcement(id: $id, title: $title, content: $content, createdBy: $createdBy, createdAt: $createdAt, expiresAt: $expiresAt, isActive: $isActive, priority: $priority, tags: $tags, category: $category, richContent: $richContent, attachments: $attachments, targetDepartments: $targetDepartments, targetRoles: $targetRoles, isGlobal: $isGlobal, requiresAcknowledgment: $requiresAcknowledgment, acknowledgedBy: $acknowledgedBy, maxViews: $maxViews, viewCount: $viewCount, createdByName: $createdByName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnnouncementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.richContent, richContent) ||
                other.richContent == richContent) &&
            const DeepCollectionEquality().equals(
              other._attachments,
              _attachments,
            ) &&
            const DeepCollectionEquality().equals(
              other._targetDepartments,
              _targetDepartments,
            ) &&
            const DeepCollectionEquality().equals(
              other._targetRoles,
              _targetRoles,
            ) &&
            (identical(other.isGlobal, isGlobal) ||
                other.isGlobal == isGlobal) &&
            (identical(other.requiresAcknowledgment, requiresAcknowledgment) ||
                other.requiresAcknowledgment == requiresAcknowledgment) &&
            const DeepCollectionEquality().equals(
              other._acknowledgedBy,
              _acknowledgedBy,
            ) &&
            (identical(other.maxViews, maxViews) ||
                other.maxViews == maxViews) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount) &&
            (identical(other.createdByName, createdByName) ||
                other.createdByName == createdByName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    title,
    content,
    createdBy,
    createdAt,
    expiresAt,
    isActive,
    priority,
    const DeepCollectionEquality().hash(_tags),
    category,
    richContent,
    const DeepCollectionEquality().hash(_attachments),
    const DeepCollectionEquality().hash(_targetDepartments),
    const DeepCollectionEquality().hash(_targetRoles),
    isGlobal,
    requiresAcknowledgment,
    const DeepCollectionEquality().hash(_acknowledgedBy),
    maxViews,
    viewCount,
    createdByName,
  ]);

  /// Create a copy of Announcement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnnouncementImplCopyWith<_$AnnouncementImpl> get copyWith =>
      __$$AnnouncementImplCopyWithImpl<_$AnnouncementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AnnouncementImplToJson(this);
  }
}

abstract class _Announcement extends Announcement {
  const factory _Announcement({
    required final String id,
    required final String title,
    required final String content,
    required final String createdBy,
    required final DateTime createdAt,
    @TimestampConverter() final DateTime? expiresAt,
    final bool isActive,
    final String priority,
    final List<String> tags,
    final String? category,
    final String? richContent,
    final List<String> attachments,
    final List<String> targetDepartments,
    final List<String> targetRoles,
    final bool isGlobal,
    final bool requiresAcknowledgment,
    final List<String> acknowledgedBy,
    final int? maxViews,
    final int viewCount,
    final String? createdByName,
  }) = _$AnnouncementImpl;
  const _Announcement._() : super._();

  factory _Announcement.fromJson(Map<String, dynamic> json) =
      _$AnnouncementImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get content;
  @override
  String get createdBy;
  @override
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime? get expiresAt;
  @override
  bool get isActive;
  @override
  String get priority; // high, medium, low
  @override
  List<String> get tags; // ['urgent', 'update', 'maintenance', 'celebration']
  @override
  String? get category; // 'system', 'event', 'maintenance', 'general'
  @override
  String? get richContent; // HTML/Markdown content
  @override
  List<String> get attachments; // Links to documents/images
  @override
  List<String> get targetDepartments; // Specific departments
  @override
  List<String> get targetRoles; // Specific roles
  @override
  bool get isGlobal; // Show to all users
  @override
  bool get requiresAcknowledgment; // Users must mark as read
  @override
  List<String> get acknowledgedBy; // Track who has seen it
  @override
  int? get maxViews; // Limit visibility after X views
  @override
  int get viewCount; // Track total views
  @override
  String? get createdByName;

  /// Create a copy of Announcement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnnouncementImplCopyWith<_$AnnouncementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
