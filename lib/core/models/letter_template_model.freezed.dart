// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'letter_template_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LetterTemplate _$LetterTemplateFromJson(Map<String, dynamic> json) {
  return _LetterTemplate.fromJson(json);
}

/// @nodoc
mixin _$LetterTemplate {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get type =>
      throw _privateConstructorUsedError; // 'Offer Letter', 'Appointment Letter', etc.
  String get content => throw _privateConstructorUsedError;
  List<String> get variables =>
      throw _privateConstructorUsedError; // ['employeeName', 'department', etc.]
  Map<String, String> get defaultValues => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get category =>
      throw _privateConstructorUsedError; // 'HR', 'Management', 'Legal'
  List<String> get requiredFields => throw _privateConstructorUsedError;
  List<String> get optionalFields => throw _privateConstructorUsedError;
  String? get signatureId =>
      throw _privateConstructorUsedError; // Default signature for this template
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Serializes this LetterTemplate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LetterTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LetterTemplateCopyWith<LetterTemplate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LetterTemplateCopyWith<$Res> {
  factory $LetterTemplateCopyWith(
    LetterTemplate value,
    $Res Function(LetterTemplate) then,
  ) = _$LetterTemplateCopyWithImpl<$Res, LetterTemplate>;
  @useResult
  $Res call({
    String id,
    String name,
    String type,
    String content,
    List<String> variables,
    Map<String, String> defaultValues,
    bool isActive,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime updatedAt,
    String createdBy,
    String? description,
    String? category,
    List<String> requiredFields,
    List<String> optionalFields,
    String? signatureId,
    Map<String, dynamic> metadata,
  });
}

/// @nodoc
class _$LetterTemplateCopyWithImpl<$Res, $Val extends LetterTemplate>
    implements $LetterTemplateCopyWith<$Res> {
  _$LetterTemplateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LetterTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? content = null,
    Object? variables = null,
    Object? defaultValues = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? createdBy = null,
    Object? description = freezed,
    Object? category = freezed,
    Object? requiredFields = null,
    Object? optionalFields = null,
    Object? signatureId = freezed,
    Object? metadata = null,
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
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as String,
            content:
                null == content
                    ? _value.content
                    : content // ignore: cast_nullable_to_non_nullable
                        as String,
            variables:
                null == variables
                    ? _value.variables
                    : variables // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            defaultValues:
                null == defaultValues
                    ? _value.defaultValues
                    : defaultValues // ignore: cast_nullable_to_non_nullable
                        as Map<String, String>,
            isActive:
                null == isActive
                    ? _value.isActive
                    : isActive // ignore: cast_nullable_to_non_nullable
                        as bool,
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
            createdBy:
                null == createdBy
                    ? _value.createdBy
                    : createdBy // ignore: cast_nullable_to_non_nullable
                        as String,
            description:
                freezed == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String?,
            category:
                freezed == category
                    ? _value.category
                    : category // ignore: cast_nullable_to_non_nullable
                        as String?,
            requiredFields:
                null == requiredFields
                    ? _value.requiredFields
                    : requiredFields // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            optionalFields:
                null == optionalFields
                    ? _value.optionalFields
                    : optionalFields // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            signatureId:
                freezed == signatureId
                    ? _value.signatureId
                    : signatureId // ignore: cast_nullable_to_non_nullable
                        as String?,
            metadata:
                null == metadata
                    ? _value.metadata
                    : metadata // ignore: cast_nullable_to_non_nullable
                        as Map<String, dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LetterTemplateImplCopyWith<$Res>
    implements $LetterTemplateCopyWith<$Res> {
  factory _$$LetterTemplateImplCopyWith(
    _$LetterTemplateImpl value,
    $Res Function(_$LetterTemplateImpl) then,
  ) = __$$LetterTemplateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String type,
    String content,
    List<String> variables,
    Map<String, String> defaultValues,
    bool isActive,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime updatedAt,
    String createdBy,
    String? description,
    String? category,
    List<String> requiredFields,
    List<String> optionalFields,
    String? signatureId,
    Map<String, dynamic> metadata,
  });
}

/// @nodoc
class __$$LetterTemplateImplCopyWithImpl<$Res>
    extends _$LetterTemplateCopyWithImpl<$Res, _$LetterTemplateImpl>
    implements _$$LetterTemplateImplCopyWith<$Res> {
  __$$LetterTemplateImplCopyWithImpl(
    _$LetterTemplateImpl _value,
    $Res Function(_$LetterTemplateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LetterTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? content = null,
    Object? variables = null,
    Object? defaultValues = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? createdBy = null,
    Object? description = freezed,
    Object? category = freezed,
    Object? requiredFields = null,
    Object? optionalFields = null,
    Object? signatureId = freezed,
    Object? metadata = null,
  }) {
    return _then(
      _$LetterTemplateImpl(
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
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as String,
        content:
            null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                    as String,
        variables:
            null == variables
                ? _value._variables
                : variables // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        defaultValues:
            null == defaultValues
                ? _value._defaultValues
                : defaultValues // ignore: cast_nullable_to_non_nullable
                    as Map<String, String>,
        isActive:
            null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                    as bool,
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
        createdBy:
            null == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                    as String,
        description:
            freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String?,
        category:
            freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                    as String?,
        requiredFields:
            null == requiredFields
                ? _value._requiredFields
                : requiredFields // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        optionalFields:
            null == optionalFields
                ? _value._optionalFields
                : optionalFields // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        signatureId:
            freezed == signatureId
                ? _value.signatureId
                : signatureId // ignore: cast_nullable_to_non_nullable
                    as String?,
        metadata:
            null == metadata
                ? _value._metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                    as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LetterTemplateImpl extends _LetterTemplate {
  const _$LetterTemplateImpl({
    required this.id,
    required this.name,
    required this.type,
    required this.content,
    final List<String> variables = const [],
    final Map<String, String> defaultValues = const {},
    this.isActive = true,
    @TimestampConverter() required this.createdAt,
    @TimestampConverter() required this.updatedAt,
    required this.createdBy,
    this.description,
    this.category,
    final List<String> requiredFields = const [],
    final List<String> optionalFields = const [],
    this.signatureId,
    final Map<String, dynamic> metadata = const {},
  }) : _variables = variables,
       _defaultValues = defaultValues,
       _requiredFields = requiredFields,
       _optionalFields = optionalFields,
       _metadata = metadata,
       super._();

  factory _$LetterTemplateImpl.fromJson(Map<String, dynamic> json) =>
      _$$LetterTemplateImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String type;
  // 'Offer Letter', 'Appointment Letter', etc.
  @override
  final String content;
  final List<String> _variables;
  @override
  @JsonKey()
  List<String> get variables {
    if (_variables is EqualUnmodifiableListView) return _variables;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_variables);
  }

  // ['employeeName', 'department', etc.]
  final Map<String, String> _defaultValues;
  // ['employeeName', 'department', etc.]
  @override
  @JsonKey()
  Map<String, String> get defaultValues {
    if (_defaultValues is EqualUnmodifiableMapView) return _defaultValues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_defaultValues);
  }

  @override
  @JsonKey()
  final bool isActive;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime updatedAt;
  @override
  final String createdBy;
  @override
  final String? description;
  @override
  final String? category;
  // 'HR', 'Management', 'Legal'
  final List<String> _requiredFields;
  // 'HR', 'Management', 'Legal'
  @override
  @JsonKey()
  List<String> get requiredFields {
    if (_requiredFields is EqualUnmodifiableListView) return _requiredFields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_requiredFields);
  }

  final List<String> _optionalFields;
  @override
  @JsonKey()
  List<String> get optionalFields {
    if (_optionalFields is EqualUnmodifiableListView) return _optionalFields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_optionalFields);
  }

  @override
  final String? signatureId;
  // Default signature for this template
  final Map<String, dynamic> _metadata;
  // Default signature for this template
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'LetterTemplate(id: $id, name: $name, type: $type, content: $content, variables: $variables, defaultValues: $defaultValues, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, createdBy: $createdBy, description: $description, category: $category, requiredFields: $requiredFields, optionalFields: $optionalFields, signatureId: $signatureId, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LetterTemplateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(
              other._variables,
              _variables,
            ) &&
            const DeepCollectionEquality().equals(
              other._defaultValues,
              _defaultValues,
            ) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality().equals(
              other._requiredFields,
              _requiredFields,
            ) &&
            const DeepCollectionEquality().equals(
              other._optionalFields,
              _optionalFields,
            ) &&
            (identical(other.signatureId, signatureId) ||
                other.signatureId == signatureId) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    type,
    content,
    const DeepCollectionEquality().hash(_variables),
    const DeepCollectionEquality().hash(_defaultValues),
    isActive,
    createdAt,
    updatedAt,
    createdBy,
    description,
    category,
    const DeepCollectionEquality().hash(_requiredFields),
    const DeepCollectionEquality().hash(_optionalFields),
    signatureId,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of LetterTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LetterTemplateImplCopyWith<_$LetterTemplateImpl> get copyWith =>
      __$$LetterTemplateImplCopyWithImpl<_$LetterTemplateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LetterTemplateImplToJson(this);
  }
}

abstract class _LetterTemplate extends LetterTemplate {
  const factory _LetterTemplate({
    required final String id,
    required final String name,
    required final String type,
    required final String content,
    final List<String> variables,
    final Map<String, String> defaultValues,
    final bool isActive,
    @TimestampConverter() required final DateTime createdAt,
    @TimestampConverter() required final DateTime updatedAt,
    required final String createdBy,
    final String? description,
    final String? category,
    final List<String> requiredFields,
    final List<String> optionalFields,
    final String? signatureId,
    final Map<String, dynamic> metadata,
  }) = _$LetterTemplateImpl;
  const _LetterTemplate._() : super._();

  factory _LetterTemplate.fromJson(Map<String, dynamic> json) =
      _$LetterTemplateImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get type; // 'Offer Letter', 'Appointment Letter', etc.
  @override
  String get content;
  @override
  List<String> get variables; // ['employeeName', 'department', etc.]
  @override
  Map<String, String> get defaultValues;
  @override
  bool get isActive;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt;
  @override
  String get createdBy;
  @override
  String? get description;
  @override
  String? get category; // 'HR', 'Management', 'Legal'
  @override
  List<String> get requiredFields;
  @override
  List<String> get optionalFields;
  @override
  String? get signatureId; // Default signature for this template
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of LetterTemplate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LetterTemplateImplCopyWith<_$LetterTemplateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
