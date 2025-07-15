import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/user_role.dart';
import '../enums/employee_status.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    required UserRole role,
    required EmployeeStatus status,
    String? phoneNumber,
    String? profileImageUrl,
    String? department,
    String? position,
    String? managerId,
    DateTime? dateOfJoining,
    DateTime? lastLoginAt,
    @Default(true) bool isActive,
    @Default(false) bool isEmailVerified,
    @Default(false) bool isSuperAdmin,
    required DateTime createdAt,
    required DateTime updatedAt,
    Map<String, dynamic>? metadata,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  // Additional methods and getters
  const User._();

  /// Get full name
  String get fullName => '$firstName $lastName';

  /// Get display name (full name or email if name is empty)
  String get displayName {
    final name = fullName.trim();
    return name.isEmpty ? email : name;
  }

  /// Get initials for avatar
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }

  /// Check if user can login
  bool get canLogin => isActive && status.canAccessSystem;

  /// Check if user is currently working
  bool get isWorking => status.canWork && isActive;

  /// Check if user is on leave
  bool get isOnLeave => status.isOnLeave;

  /// Check if user is a manager
  bool get isManager => role.isManager || role.isAdmin || role.isSuperAdmin;

  /// Check if user has admin privileges
  bool get hasAdminPrivileges => role.isAdmin || role.isSuperAdmin;

  /// Check if user can manage other users
  bool get canManageUsers => role.canManageUsers;

  /// Check if user can view reports
  bool get canViewReports => role.canViewReports;

  /// Check if user can manage system settings
  bool get canManageSystem => role.canManageSystem;

  /// Get days since joining
  int? get daysSinceJoining {
    if (dateOfJoining == null) return null;
    return DateTime.now().difference(dateOfJoining!).inDays;
  }

  /// Get days since last login
  int? get daysSinceLastLogin {
    if (lastLoginAt == null) return null;
    return DateTime.now().difference(lastLoginAt!).inDays;
  }

  /// Check if user is new (joined within last 30 days)
  bool get isNewEmployee {
    if (dateOfJoining == null) return false;
    return daysSinceJoining! <= 30;
  }

  /// Check if user has been inactive for long time
  bool get isInactive {
    if (lastLoginAt == null) return true;
    return daysSinceLastLogin! > 30;
  }

  /// Get user's department or default
  String get departmentName => department ?? 'Unassigned';

  /// Get user's position or default
  String get positionTitle => position ?? 'Employee';

  /// Create a copy with updated last login
  User updateLastLogin() {
    return copyWith(lastLoginAt: DateTime.now());
  }

  /// Create a copy with updated status
  User updateStatus(EmployeeStatus newStatus) {
    return copyWith(status: newStatus, updatedAt: DateTime.now());
  }

  /// Create a copy with updated role
  User updateRole(UserRole newRole) {
    return copyWith(role: newRole, updatedAt: DateTime.now());
  }

  /// Create a copy with updated profile
  User updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? department,
    String? position,
    String? profileImageUrl,
  }) {
    return copyWith(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      department: department ?? this.department,
      position: position ?? this.position,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      updatedAt: DateTime.now(),
    );
  }

  /// Convert to map for Firestore
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    // Convert enums to strings for Firestore
    json['role'] = role.value;
    json['status'] = status.value;
    return json;
  }

  /// Create from Firestore document
  factory User.fromFirestore(Map<String, dynamic> data) {
    // Convert string values back to enums
    if (data['role'] is String) {
      data['role'] = UserRole.fromString(data['role']).name;
    }
    if (data['status'] is String) {
      data['status'] = EmployeeStatus.fromString(data['status']).name;
    }
    return User.fromJson(data);
  }
}
