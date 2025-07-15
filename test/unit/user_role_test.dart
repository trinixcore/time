import 'package:flutter_test/flutter_test.dart';
import 'package:time/core/models/user_model.dart';
import 'package:time/core/utils/super_admin_helpers.dart';
import 'package:time/core/enums/user_role.dart';

void main() {
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
      expect(UserRole.fromString('hr'), UserRole.hr);
      expect(UserRole.fromString('manager'), UserRole.manager);
      expect(UserRole.fromString('employee'), UserRole.employee);
      expect(UserRole.fromString('inactive'), UserRole.inactive);
      expect(
        UserRole.fromString('invalid'),
        UserRole.employee,
      ); // Default fallback
    });

    test('UserRole permission checks work correctly', () {
      expect(UserRole.superAdmin.canManageSystem, true);
      expect(UserRole.admin.canManageSystem, false);
      expect(UserRole.hr.canManageSystem, false);
      expect(UserRole.manager.canManageSystem, false);
      expect(UserRole.employee.canManageSystem, false);
      expect(UserRole.inactive.canManageSystem, false);

      expect(UserRole.superAdmin.canManageUsers, true);
      expect(UserRole.admin.canManageUsers, true);
      expect(UserRole.hr.canManageUsers, false);
      expect(UserRole.manager.canManageUsers, false);
      expect(UserRole.employee.canManageUsers, false);
      expect(UserRole.inactive.canManageUsers, false);

      expect(UserRole.superAdmin.canViewReports, true);
      expect(UserRole.admin.canViewReports, true);
      expect(UserRole.hr.canViewReports, true);
      expect(UserRole.manager.canViewReports, true);
      expect(UserRole.employee.canViewReports, false);
      expect(UserRole.inactive.canViewReports, false);
    });

    test('UserRole boolean getters work correctly', () {
      expect(UserRole.superAdmin.isSuperAdmin, true);
      expect(UserRole.admin.isSuperAdmin, false);

      expect(UserRole.admin.isAdmin, true);
      expect(UserRole.superAdmin.isAdmin, false);

      expect(UserRole.hr.isHR, true);
      expect(UserRole.admin.isHR, false);

      expect(UserRole.manager.isManager, true);
      expect(UserRole.employee.isManager, false);

      expect(UserRole.employee.isEmployee, true);
      expect(UserRole.manager.isEmployee, false);

      expect(UserRole.inactive.isInactive, true);
      expect(UserRole.employee.isInactive, false);
    });
  });

  group('Super Admin Helper Tests', () {
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

    test('isSuperAdmin returns false for regular employee', () {
      final employee = UserModel(
        uid: 'test_uid',
        email: 'employee@test.com',
        displayName: 'Employee',
        role: UserRole.employee,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        mfaEnabled: false,
      );

      expect(isSuperAdmin(employee), false);
    });
  });

  group('UserModel Extension Tests', () {
    test('UserModel extensions work correctly', () {
      final superAdmin = UserModel(
        uid: 'super_uid',
        email: 'super@test.com',
        displayName: 'Super Admin',
        role: UserRole.superAdmin,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        mfaEnabled: false,
      );

      final admin = UserModel(
        uid: 'admin_uid',
        email: 'admin@test.com',
        displayName: 'Admin',
        role: UserRole.admin,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        mfaEnabled: false,
      );

      final employee = UserModel(
        uid: 'emp_uid',
        email: 'emp@test.com',
        displayName: 'Employee',
        role: UserRole.employee,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        mfaEnabled: false,
      );

      expect(superAdmin.isSuperAdmin, true);
      expect(admin.isSuperAdmin, false);
      expect(employee.isSuperAdmin, false);

      expect(superAdmin.isAdmin, false);
      expect(admin.isAdmin, true);
      expect(employee.isAdmin, false);

      expect(superAdmin.canManageUsers, true);
      expect(admin.canManageUsers, true);
      expect(employee.canManageUsers, false);

      expect(superAdmin.canManageSystem, true);
      expect(admin.canManageSystem, false);
      expect(employee.canManageSystem, false);
    });
  });

  group('Exception Tests', () {
    test('Custom exceptions have correct messages', () {
      final unauthorizedException = UnauthorizedException(
        'Test unauthorized message',
      );
      expect(
        unauthorizedException.toString(),
        'UnauthorizedException: Test unauthorized message',
      );

      final invalidRoleException = InvalidRoleException(
        'Test invalid role message',
      );
      expect(
        invalidRoleException.toString(),
        'InvalidRoleException: Test invalid role message',
      );

      final invalidOperationException = InvalidOperationException(
        'Test invalid operation message',
      );
      expect(
        invalidOperationException.toString(),
        'InvalidOperationException: Test invalid operation message',
      );
    });
  });
}
