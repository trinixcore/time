import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/user_model.dart';
import '../enums/user_role.dart';
import '../services/firebase_service.dart';

final Logger _logger = Logger();
final FirebaseFirestore _firestore = FirebaseService().firestore;

/// Check if a user is a Super-Admin
bool isSuperAdmin(UserModel user) {
  return user.role.isSuperAdmin && user.isActive;
}

/// Delegate admin privileges to another user (Super-Admin only)
Future<void> delegateAdmin(
  UserModel caller,
  UserModel target,
  UserRole newRole,
) async {
  // Validate caller permissions
  if (!isSuperAdmin(caller)) {
    _logger.w('Unauthorized delegation attempt by ${caller.uid}');
    throw UnauthorizedException('Only Super-Admin can delegate roles');
  }

  // Validate target role
  if (newRole == UserRole.superAdmin) {
    throw InvalidRoleException('Cannot delegate Super-Admin role');
  }

  if (newRole == UserRole.inactive) {
    throw InvalidRoleException('Use deactivateUser() to deactivate users');
  }

  try {
    _logger.i(
      'Delegating role ${newRole.value} to ${target.uid} by ${caller.uid}',
    );

    // Update target user role
    await _firestore.collection('users').doc(target.uid).update({
      'role': newRole.value,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Log the delegation action
    await _logSuperAdminAction(caller.uid, 'ROLE_DELEGATED', {
      'targetUid': target.uid,
      'targetEmail': target.email,
      'oldRole': target.role.value,
      'newRole': newRole.value,
      'timestamp': DateTime.now().toIso8601String(),
    });

    _logger.i('Role delegation completed successfully');
  } catch (e) {
    _logger.e('Failed to delegate role: $e');
    rethrow;
  }
}

/// Create a new admin user (Super-Admin only)
Future<UserModel> createAdminUser(
  UserModel caller, {
  required String email,
  required String displayName,
  required UserRole role,
  String? department,
  String? position,
}) async {
  // Validate caller permissions
  if (!isSuperAdmin(caller)) {
    throw UnauthorizedException('Only Super-Admin can create admin users');
  }

  // Validate role
  if (role == UserRole.superAdmin) {
    throw InvalidRoleException('Cannot create additional Super-Admin users');
  }

  try {
    _logger.i('Creating admin user: $email with role: ${role.value}');

    final now = DateTime.now();
    final newUser = UserModel(
      uid: 'pending_${now.millisecondsSinceEpoch}', // Temporary UID
      email: email,
      displayName: displayName,
      role: role,
      createdAt: now,
      updatedAt: now,
      isActive: true,
      mfaEnabled: false,
      createdBy: caller.uid,
      department: department,
      position: position,
    );

    // TODO: Send invitation email to user
    // For now, save as pending user
    await _firestore
        .collection('pending_users')
        .doc(newUser.uid)
        .set(newUser.toJson());

    // Log the creation
    await _logSuperAdminAction(caller.uid, 'ADMIN_USER_CREATED', {
      'targetEmail': email,
      'role': role.value,
      'department': department,
      'position': position,
      'timestamp': now.toIso8601String(),
    });

    _logger.i('Admin user created successfully: ${newUser.uid}');
    return newUser;
  } catch (e) {
    _logger.e('Failed to create admin user: $e');
    rethrow;
  }
}

/// Deactivate a user (Super-Admin only)
Future<void> deactivateUser(UserModel caller, UserModel target) async {
  // Validate caller permissions
  if (!isSuperAdmin(caller)) {
    throw UnauthorizedException('Only Super-Admin can deactivate users');
  }

  // Prevent deactivating another Super-Admin
  if (target.role.isSuperAdmin) {
    throw InvalidOperationException('Cannot deactivate Super-Admin users');
  }

  // Prevent self-deactivation
  if (caller.uid == target.uid) {
    throw InvalidOperationException('Cannot deactivate yourself');
  }

  try {
    _logger.i('Deactivating user: ${target.uid}');

    await _firestore.collection('users').doc(target.uid).update({
      'isActive': false,
      'role': UserRole.inactive.value,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Log the deactivation
    await _logSuperAdminAction(caller.uid, 'USER_DEACTIVATED', {
      'targetUid': target.uid,
      'targetEmail': target.email,
      'previousRole': target.role.value,
      'timestamp': DateTime.now().toIso8601String(),
    });

    _logger.i('User deactivated successfully: ${target.uid}');
  } catch (e) {
    _logger.e('Failed to deactivate user: $e');
    rethrow;
  }
}

/// Log Super-Admin actions for audit trail
Future<void> _logSuperAdminAction(
  String uid,
  String action,
  Map<String, dynamic> details,
) async {
  try {
    final timestamp = DateTime.now();
    await _firestore
        .collection('logs')
        .doc('superAdmin')
        .collection(uid)
        .doc(timestamp.millisecondsSinceEpoch.toString())
        .set({
          'action': action,
          'details': details,
          'timestamp': FieldValue.serverTimestamp(),
          'uid': uid,
        });
  } catch (e) {
    _logger.e('Failed to log super admin action: $e');
    // Don't rethrow - logging failure shouldn't break the main flow
  }
}

/// Custom exceptions
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);

  @override
  String toString() => 'UnauthorizedException: $message';
}

class InvalidRoleException implements Exception {
  final String message;
  InvalidRoleException(this.message);

  @override
  String toString() => 'InvalidRoleException: $message';
}

class InvalidOperationException implements Exception {
  final String message;
  InvalidOperationException(this.message);

  @override
  String toString() => 'InvalidOperationException: $message';
}
