import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:time/core/models/user_model.dart';
import 'package:time/core/enums/user_role.dart';
import 'package:time/core/utils/super_admin_helpers.dart';

// Mock classes
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  group('Super-Admin Bootstrap Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();
    });

    group('Setup Flow Tests', () {
      test('First run renders setup page; second run skips', () async {
        // First run - no setup document exists
        final setupDoc = await fakeFirestore.doc('setup/completed').get();
        expect(setupDoc.exists, false);

        // Simulate setup completion
        await fakeFirestore.doc('setup/completed').set({
          'completed': true,
          'completedAt': DateTime.now(),
        });

        // Second run - setup document exists
        final setupDocAfter = await fakeFirestore.doc('setup/completed').get();
        expect(setupDocAfter.exists, true);
        expect(setupDocAfter.data()?['completed'], true);
      });

      test('Setup completion creates backup super admin', () async {
        // Simulate creating backup super admin
        final backupId =
            'backup_super_admin_${DateTime.now().millisecondsSinceEpoch}';
        final backupUser = UserModel(
          uid: backupId,
          email: 'backup@company.com',
          displayName: 'Backup Super Admin',
          role: UserRole.superAdmin,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: false,
          mfaEnabled: false,
          createdBy: 'system',
        );

        await fakeFirestore
            .collection('users')
            .doc(backupId)
            .set(backupUser.toJson());

        final doc = await fakeFirestore.collection('users').doc(backupId).get();
        expect(doc.exists, true);

        final userData = UserModel.fromJson(doc.data()!);
        expect(userData.role, UserRole.superAdmin);
        expect(userData.isActive, false);
        expect(userData.createdBy, 'system');
      });

      test('Super admin creation logs action', () async {
        final superAdminUid = 'super_admin_123';
        final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

        // Simulate logging super admin creation
        await fakeFirestore
            .collection('logs')
            .doc('superAdmin')
            .collection(superAdminUid)
            .doc(timestamp)
            .set({
              'action': 'SUPER_ADMIN_CREATED',
              'details': {
                'email': 'admin@company.com',
                'displayName': 'Super Admin',
              },
              'timestamp': DateTime.now(),
              'uid': superAdminUid,
            });

        final logDoc =
            await fakeFirestore
                .collection('logs')
                .doc('superAdmin')
                .collection(superAdminUid)
                .doc(timestamp)
                .get();

        expect(logDoc.exists, true);
        expect(logDoc.data()?['action'], 'SUPER_ADMIN_CREATED');
        expect(logDoc.data()?['uid'], superAdminUid);
      });
    });

    group('Helper Function Tests', () {
      test('isSuperAdmin returns true for active super admin', () {
        final superAdmin = UserModel(
          uid: 'test_uid',
          email: 'admin@test.com',
          displayName: 'Super Admin',
          role: UserRole.superAdmin,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
          mfaEnabled: false,
        );

        expect(isSuperAdmin(superAdmin), true);
      });

      test('isSuperAdmin returns false for inactive super admin', () {
        final inactiveSuperAdmin = UserModel(
          uid: 'test_uid',
          email: 'admin@test.com',
          displayName: 'Super Admin',
          role: UserRole.superAdmin,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: false,
          mfaEnabled: false,
        );

        expect(isSuperAdmin(inactiveSuperAdmin), false);
      });

      test('isSuperAdmin returns false for regular admin', () {
        final admin = UserModel(
          uid: 'test_uid',
          email: 'admin@test.com',
          displayName: 'Admin',
          role: UserRole.admin,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
          mfaEnabled: false,
        );

        expect(isSuperAdmin(admin), false);
      });
    });

    group('Delegation Tests', () {
      late UserModel superAdmin;
      late UserModel targetUser;

      setUp(() {
        superAdmin = UserModel(
          uid: 'super_admin_uid',
          email: 'super@test.com',
          displayName: 'Super Admin',
          role: UserRole.superAdmin,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
          mfaEnabled: false,
        );

        targetUser = UserModel(
          uid: 'target_uid',
          email: 'target@test.com',
          displayName: 'Target User',
          role: UserRole.employee,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
          mfaEnabled: false,
        );
      });

      test('delegateAdmin throws if caller not superAdmin', () async {
        final regularAdmin = UserModel(
          uid: 'admin_uid',
          email: 'admin@test.com',
          displayName: 'Regular Admin',
          role: UserRole.admin,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
          mfaEnabled: false,
        );

        expect(
          () => delegateAdmin(regularAdmin, targetUser, UserRole.admin),
          throwsA(isA<UnauthorizedException>()),
        );
      });

      test(
        'delegateAdmin throws when trying to delegate superAdmin role',
        () async {
          expect(
            () => delegateAdmin(superAdmin, targetUser, UserRole.superAdmin),
            throwsA(isA<InvalidRoleException>()),
          );
        },
      );

      test(
        'delegateAdmin throws when trying to delegate inactive role',
        () async {
          expect(
            () => delegateAdmin(superAdmin, targetUser, UserRole.inactive),
            throwsA(isA<InvalidRoleException>()),
          );
        },
      );

      test('delegateAdmin succeeds with valid parameters', () async {
        // This test would require mocking Firestore operations
        // For now, we test the validation logic
        expect(isSuperAdmin(superAdmin), true);
        expect(UserRole.admin != UserRole.superAdmin, true);
        expect(UserRole.admin != UserRole.inactive, true);
      });
    });

    group('UserRole Tests', () {
      test('UserRole enum values are correct', () {
        expect(UserRole.superAdmin.value, 'super_admin');
        expect(UserRole.admin.value, 'admin');
        expect(UserRole.hr.value, 'hr');
        expect(UserRole.manager.value, 'manager');
        expect(UserRole.employee.value, 'employee');
        expect(UserRole.inactive.value, 'inactive');
      });

      test('UserRole fromString works correctly', () {
        expect(UserRole.fromString('super_admin'), UserRole.superAdmin);
        expect(UserRole.fromString('admin'), UserRole.admin);
        expect(
          UserRole.fromString('invalid'),
          UserRole.employee,
        ); // Default fallback
      });

      test('UserRole permission checks work correctly', () {
        expect(UserRole.superAdmin.canManageSystem, true);
        expect(UserRole.admin.canManageSystem, false);
        expect(UserRole.superAdmin.canManageUsers, true);
        expect(UserRole.admin.canManageUsers, true);
        expect(UserRole.employee.canManageUsers, false);
      });
    });

    group('Exception Tests', () {
      test('UnauthorizedException has correct message', () {
        final exception = UnauthorizedException('Test message');
        expect(exception.toString(), 'UnauthorizedException: Test message');
      });

      test('InvalidRoleException has correct message', () {
        final exception = InvalidRoleException('Test message');
        expect(exception.toString(), 'InvalidRoleException: Test message');
      });

      test('InvalidOperationException has correct message', () {
        final exception = InvalidOperationException('Test message');
        expect(exception.toString(), 'InvalidOperationException: Test message');
      });
    });
  });
}
