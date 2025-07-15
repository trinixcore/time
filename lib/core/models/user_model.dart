import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/user_role.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

// Custom converter for handling Firestore Timestamp and String dates
class TimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const TimestampConverter();

  @override
  DateTime? fromJson(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is String) {
      return DateTime.parse(value);
    }

    throw ArgumentError('Cannot convert $value to DateTime');
  }

  @override
  dynamic toJson(DateTime? dateTime) {
    return dateTime?.toIso8601String();
  }
}

// Custom converter for handling UserRole values
class UserRoleConverter implements JsonConverter<UserRole, String> {
  const UserRoleConverter();

  @override
  UserRole fromJson(String value) => UserRole.fromString(value);

  @override
  String toJson(UserRole role) => role.value; // Always use simplified values in storage
}

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String email,
    required String displayName,
    @UserRoleConverter() required UserRole role,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
    required bool isActive,
    String? photoUrl,
    String? phoneNumber,
    String? department,
    String? position,
    String? employeeId,
    @TimestampConverter() DateTime? lastLoginAt,
    bool? mfaEnabled,
    String? createdBy,
    // Optional termination fields
    @TimestampConverter() DateTime? terminationDate,
    String? terminationReason,
    String? terminationComments,
    String? terminatedBy,
    @TimestampConverter() DateTime? lastWorkingDay,
    @TimestampConverter() DateTime? reactivationDate,
    String? reactivationReason,
    String? reactivationComments,
    String? reactivatedBy,
    // NEW FIELD
    String? candidateId,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

// Extension for helper methods
extension UserModelX on UserModel {
  bool get isSuperAdmin => role.isSuperAdmin;
  bool get isAdmin => role.isAdmin;
  bool get canManageUsers => role.canManageUsers;
  bool get canManageSystem => role.canManageSystem;
}
