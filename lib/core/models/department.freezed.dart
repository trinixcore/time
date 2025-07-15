// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'department.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Department _$DepartmentFromJson(Map<String, dynamic> json) {
  return _Department.fromJson(json);
}

/// @nodoc
mixin _$Department {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get managerId => throw _privateConstructorUsedError;
  String? get parentDepartmentId => throw _privateConstructorUsedError;
  List<String> get employeeIds => throw _privateConstructorUsedError;
  List<String> get subDepartmentIds => throw _privateConstructorUsedError;
  double get budget => throw _privateConstructorUsedError;
  double get actualSpending => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  String? get contactEmail => throw _privateConstructorUsedError;
  String? get contactPhone => throw _privateConstructorUsedError;
  Map<String, dynamic>? get customFields => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String? get createdById => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this Department to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Department
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DepartmentCopyWith<Department> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DepartmentCopyWith<$Res> {
  factory $DepartmentCopyWith(
    Department value,
    $Res Function(Department) then,
  ) = _$DepartmentCopyWithImpl<$Res, Department>;
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    String? managerId,
    String? parentDepartmentId,
    List<String> employeeIds,
    List<String> subDepartmentIds,
    double budget,
    double actualSpending,
    bool isActive,
    String? location,
    String? contactEmail,
    String? contactPhone,
    Map<String, dynamic>? customFields,
    DateTime createdAt,
    DateTime updatedAt,
    String? createdById,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$DepartmentCopyWithImpl<$Res, $Val extends Department>
    implements $DepartmentCopyWith<$Res> {
  _$DepartmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Department
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? managerId = freezed,
    Object? parentDepartmentId = freezed,
    Object? employeeIds = null,
    Object? subDepartmentIds = null,
    Object? budget = null,
    Object? actualSpending = null,
    Object? isActive = null,
    Object? location = freezed,
    Object? contactEmail = freezed,
    Object? contactPhone = freezed,
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
            managerId:
                freezed == managerId
                    ? _value.managerId
                    : managerId // ignore: cast_nullable_to_non_nullable
                        as String?,
            parentDepartmentId:
                freezed == parentDepartmentId
                    ? _value.parentDepartmentId
                    : parentDepartmentId // ignore: cast_nullable_to_non_nullable
                        as String?,
            employeeIds:
                null == employeeIds
                    ? _value.employeeIds
                    : employeeIds // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            subDepartmentIds:
                null == subDepartmentIds
                    ? _value.subDepartmentIds
                    : subDepartmentIds // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            budget:
                null == budget
                    ? _value.budget
                    : budget // ignore: cast_nullable_to_non_nullable
                        as double,
            actualSpending:
                null == actualSpending
                    ? _value.actualSpending
                    : actualSpending // ignore: cast_nullable_to_non_nullable
                        as double,
            isActive:
                null == isActive
                    ? _value.isActive
                    : isActive // ignore: cast_nullable_to_non_nullable
                        as bool,
            location:
                freezed == location
                    ? _value.location
                    : location // ignore: cast_nullable_to_non_nullable
                        as String?,
            contactEmail:
                freezed == contactEmail
                    ? _value.contactEmail
                    : contactEmail // ignore: cast_nullable_to_non_nullable
                        as String?,
            contactPhone:
                freezed == contactPhone
                    ? _value.contactPhone
                    : contactPhone // ignore: cast_nullable_to_non_nullable
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
abstract class _$$DepartmentImplCopyWith<$Res>
    implements $DepartmentCopyWith<$Res> {
  factory _$$DepartmentImplCopyWith(
    _$DepartmentImpl value,
    $Res Function(_$DepartmentImpl) then,
  ) = __$$DepartmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    String? managerId,
    String? parentDepartmentId,
    List<String> employeeIds,
    List<String> subDepartmentIds,
    double budget,
    double actualSpending,
    bool isActive,
    String? location,
    String? contactEmail,
    String? contactPhone,
    Map<String, dynamic>? customFields,
    DateTime createdAt,
    DateTime updatedAt,
    String? createdById,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$DepartmentImplCopyWithImpl<$Res>
    extends _$DepartmentCopyWithImpl<$Res, _$DepartmentImpl>
    implements _$$DepartmentImplCopyWith<$Res> {
  __$$DepartmentImplCopyWithImpl(
    _$DepartmentImpl _value,
    $Res Function(_$DepartmentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Department
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? managerId = freezed,
    Object? parentDepartmentId = freezed,
    Object? employeeIds = null,
    Object? subDepartmentIds = null,
    Object? budget = null,
    Object? actualSpending = null,
    Object? isActive = null,
    Object? location = freezed,
    Object? contactEmail = freezed,
    Object? contactPhone = freezed,
    Object? customFields = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? createdById = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$DepartmentImpl(
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
        managerId:
            freezed == managerId
                ? _value.managerId
                : managerId // ignore: cast_nullable_to_non_nullable
                    as String?,
        parentDepartmentId:
            freezed == parentDepartmentId
                ? _value.parentDepartmentId
                : parentDepartmentId // ignore: cast_nullable_to_non_nullable
                    as String?,
        employeeIds:
            null == employeeIds
                ? _value._employeeIds
                : employeeIds // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        subDepartmentIds:
            null == subDepartmentIds
                ? _value._subDepartmentIds
                : subDepartmentIds // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        budget:
            null == budget
                ? _value.budget
                : budget // ignore: cast_nullable_to_non_nullable
                    as double,
        actualSpending:
            null == actualSpending
                ? _value.actualSpending
                : actualSpending // ignore: cast_nullable_to_non_nullable
                    as double,
        isActive:
            null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                    as bool,
        location:
            freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                    as String?,
        contactEmail:
            freezed == contactEmail
                ? _value.contactEmail
                : contactEmail // ignore: cast_nullable_to_non_nullable
                    as String?,
        contactPhone:
            freezed == contactPhone
                ? _value.contactPhone
                : contactPhone // ignore: cast_nullable_to_non_nullable
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
class _$DepartmentImpl extends _Department {
  const _$DepartmentImpl({
    required this.id,
    required this.name,
    required this.description,
    this.managerId,
    this.parentDepartmentId,
    final List<String> employeeIds = const [],
    final List<String> subDepartmentIds = const [],
    this.budget = 0.0,
    this.actualSpending = 0.0,
    this.isActive = true,
    this.location,
    this.contactEmail,
    this.contactPhone,
    final Map<String, dynamic>? customFields,
    required this.createdAt,
    required this.updatedAt,
    this.createdById,
    final Map<String, dynamic>? metadata,
  }) : _employeeIds = employeeIds,
       _subDepartmentIds = subDepartmentIds,
       _customFields = customFields,
       _metadata = metadata,
       super._();

  factory _$DepartmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$DepartmentImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final String? managerId;
  @override
  final String? parentDepartmentId;
  final List<String> _employeeIds;
  @override
  @JsonKey()
  List<String> get employeeIds {
    if (_employeeIds is EqualUnmodifiableListView) return _employeeIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_employeeIds);
  }

  final List<String> _subDepartmentIds;
  @override
  @JsonKey()
  List<String> get subDepartmentIds {
    if (_subDepartmentIds is EqualUnmodifiableListView)
      return _subDepartmentIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subDepartmentIds);
  }

  @override
  @JsonKey()
  final double budget;
  @override
  @JsonKey()
  final double actualSpending;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final String? location;
  @override
  final String? contactEmail;
  @override
  final String? contactPhone;
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
  final DateTime createdAt;
  @override
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
    return 'Department(id: $id, name: $name, description: $description, managerId: $managerId, parentDepartmentId: $parentDepartmentId, employeeIds: $employeeIds, subDepartmentIds: $subDepartmentIds, budget: $budget, actualSpending: $actualSpending, isActive: $isActive, location: $location, contactEmail: $contactEmail, contactPhone: $contactPhone, customFields: $customFields, createdAt: $createdAt, updatedAt: $updatedAt, createdById: $createdById, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DepartmentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.managerId, managerId) ||
                other.managerId == managerId) &&
            (identical(other.parentDepartmentId, parentDepartmentId) ||
                other.parentDepartmentId == parentDepartmentId) &&
            const DeepCollectionEquality().equals(
              other._employeeIds,
              _employeeIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._subDepartmentIds,
              _subDepartmentIds,
            ) &&
            (identical(other.budget, budget) || other.budget == budget) &&
            (identical(other.actualSpending, actualSpending) ||
                other.actualSpending == actualSpending) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.contactEmail, contactEmail) ||
                other.contactEmail == contactEmail) &&
            (identical(other.contactPhone, contactPhone) ||
                other.contactPhone == contactPhone) &&
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
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    managerId,
    parentDepartmentId,
    const DeepCollectionEquality().hash(_employeeIds),
    const DeepCollectionEquality().hash(_subDepartmentIds),
    budget,
    actualSpending,
    isActive,
    location,
    contactEmail,
    contactPhone,
    const DeepCollectionEquality().hash(_customFields),
    createdAt,
    updatedAt,
    createdById,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of Department
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DepartmentImplCopyWith<_$DepartmentImpl> get copyWith =>
      __$$DepartmentImplCopyWithImpl<_$DepartmentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DepartmentImplToJson(this);
  }
}

abstract class _Department extends Department {
  const factory _Department({
    required final String id,
    required final String name,
    required final String description,
    final String? managerId,
    final String? parentDepartmentId,
    final List<String> employeeIds,
    final List<String> subDepartmentIds,
    final double budget,
    final double actualSpending,
    final bool isActive,
    final String? location,
    final String? contactEmail,
    final String? contactPhone,
    final Map<String, dynamic>? customFields,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final String? createdById,
    final Map<String, dynamic>? metadata,
  }) = _$DepartmentImpl;
  const _Department._() : super._();

  factory _Department.fromJson(Map<String, dynamic> json) =
      _$DepartmentImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  String? get managerId;
  @override
  String? get parentDepartmentId;
  @override
  List<String> get employeeIds;
  @override
  List<String> get subDepartmentIds;
  @override
  double get budget;
  @override
  double get actualSpending;
  @override
  bool get isActive;
  @override
  String? get location;
  @override
  String? get contactEmail;
  @override
  String? get contactPhone;
  @override
  Map<String, dynamic>? get customFields;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String? get createdById;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of Department
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DepartmentImplCopyWith<_$DepartmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
