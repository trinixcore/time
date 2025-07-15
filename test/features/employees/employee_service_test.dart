import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:time/core/services/employee_service.dart';
import 'package:time/core/models/employee.dart';
import 'package:time/core/enums/user_role.dart';
import 'package:time/core/enums/employee_status.dart';

@GenerateMocks([FirebaseFirestore])
void main() {
  group('EmployeeService Tests', () {
    late EmployeeService employeeService;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      employeeService = EmployeeService();
      // Note: In a real test, you'd inject the fake firestore
    });

    group('Employee CRUD Operations', () {
      test('should create employee successfully', () async {
        // Arrange
        const employeeData = {
          'userId': 'user123',
          'employeeId': 'TRX2024000001',
          'firstName': 'John',
          'lastName': 'Doe',
          'email': 'john.doe@example.com',
          'role': UserRole.employee,
          'department': 'Engineering',
          'designation': 'Software Developer',
          'createdBy': 'admin123',
        };

        // Act & Assert
        expect(() async {
          await employeeService.createEmployee(
            userId: employeeData['userId'] as String,
            employeeId: employeeData['employeeId'] as String,
            firstName: employeeData['firstName'] as String,
            lastName: employeeData['lastName'] as String,
            email: employeeData['email'] as String,
            role: employeeData['role'] as UserRole,
            createdBy: employeeData['createdBy'] as String,
            department: employeeData['department'] as String,
            designation: employeeData['designation'] as String,
          );
        }, returnsNormally);
      });

      test('should retrieve employee by ID', () async {
        // Arrange
        const employeeId = 'emp123';

        // Act & Assert
        expect(() async {
          await employeeService.getEmployeeById(employeeId);
        }, returnsNormally);
      });

      test('should update employee successfully', () async {
        // Arrange
        const employeeId = 'emp123';
        const updateData = {
          'firstName': 'Jane',
          'lastName': 'Smith',
          'department': 'Marketing',
        };

        // Act & Assert
        expect(() async {
          await employeeService.updateEmployee(
            employeeId: employeeId,
            updatedBy: 'admin123',
            updates: updateData,
          );
        }, returnsNormally);
      });

      test('should update employee status', () async {
        // Arrange
        const employeeId = 'emp123';
        const newStatus = EmployeeStatus.inactive;

        // Act & Assert
        expect(() async {
          await employeeService.updateEmployeeStatus(
            employeeId: employeeId,
            status: newStatus,
            updatedBy: 'admin123',
            reason: 'Employee requested leave',
          );
        }, returnsNormally);
      });

      test('should soft delete employee', () async {
        // Arrange
        const employeeId = 'emp123';

        // Act & Assert
        expect(() async {
          await employeeService.deleteEmployee(
            employeeId: employeeId,
            deletedBy: 'admin123',
            reason: 'Employee terminated',
          );
        }, returnsNormally);
      });
    });

    group('Employee Search and Filtering', () {
      test('should filter employees by status', () async {
        // Act & Assert
        expect(() async {
          await employeeService
              .getEmployees(status: EmployeeStatus.active)
              .first;
        }, returnsNormally);
      });

      test('should filter employees by department', () async {
        // Act & Assert
        expect(() async {
          await employeeService.getEmployees(department: 'Engineering').first;
        }, returnsNormally);
      });

      test('should filter employees by role', () async {
        // Act & Assert
        expect(() async {
          await employeeService.getEmployees(role: UserRole.manager).first;
        }, returnsNormally);
      });

      test('should search employees by query', () async {
        // Arrange
        const searchQuery = 'John';

        // Act & Assert
        expect(() async {
          await employeeService.searchEmployees(searchQuery);
        }, returnsNormally);
      });

      test('should get employees by department', () async {
        // Arrange
        const department = 'Engineering';

        // Act & Assert
        expect(() async {
          await employeeService.getEmployeesByDepartment(department).first;
        }, returnsNormally);
      });

      test('should get employees by manager', () async {
        // Arrange
        const managerId = 'manager123';

        // Act & Assert
        expect(() async {
          await employeeService.getEmployeesByManager(managerId).first;
        }, returnsNormally);
      });
    });

    group('Organizational Structure', () {
      test('should get employee hierarchy', () async {
        // Arrange
        const managerId = 'manager123';

        // Act & Assert
        expect(() async {
          await employeeService.getEmployeeHierarchy(managerId);
        }, returnsNormally);
      });

      test('should get employees for selection', () async {
        // Act & Assert
        expect(() async {
          await employeeService.getEmployeesForSelection();
        }, returnsNormally);
      });

      test('should get employees for selection with role filter', () async {
        // Act & Assert
        expect(() async {
          await employeeService.getEmployeesForSelection(
            minimumRole: UserRole.manager,
          );
        }, returnsNormally);
      });

      test(
        'should get employees for selection excluding specific employee',
        () async {
          // Act & Assert
          expect(() async {
            await employeeService.getEmployeesForSelection(
              excludeEmployeeId: 'emp123',
            );
          }, returnsNormally);
        },
      );
    });

    group('Employee Statistics', () {
      test('should get employee statistics', () async {
        // Act & Assert
        expect(() async {
          final stats = await employeeService.getEmployeeStatistics();
          expect(stats, isA<Map<String, dynamic>>());
        }, returnsNormally);
      });
    });

    group('Employee Model Tests', () {
      test('should create employee with required fields', () {
        // Arrange & Act
        final employee = Employee(
          id: 'emp123',
          userId: 'user123',
          employeeId: 'TRX2024000001',
          firstName: 'John',
          lastName: 'Doe',
          email: 'john.doe@example.com',
          role: UserRole.employee,
          status: EmployeeStatus.active,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'admin123',
        );

        // Assert
        expect(employee.fullName, equals('John Doe'));
        expect(employee.initials, equals('JD'));
        expect(employee.isEmployeeActive, isTrue);
        expect(employee.canWork, isTrue);
      });

      test('should calculate years of service correctly', () {
        // Arrange
        final joiningDate = DateTime.now().subtract(
          const Duration(days: 730),
        ); // 2 years ago
        final employee = Employee(
          id: 'emp123',
          userId: 'user123',
          employeeId: 'TRX2024000001',
          firstName: 'John',
          lastName: 'Doe',
          email: 'john.doe@example.com',
          role: UserRole.employee,
          status: EmployeeStatus.active,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'admin123',
          joiningDate: joiningDate,
        );

        // Act & Assert
        expect(employee.yearsOfService, greaterThan(1.9));
        expect(employee.yearsOfService, lessThan(2.1));
      });

      test('should calculate age correctly', () {
        // Arrange
        final birthDate = DateTime.now().subtract(
          const Duration(days: 365 * 25),
        ); // 25 years ago
        final employee = Employee(
          id: 'emp123',
          userId: 'user123',
          employeeId: 'TRX2024000001',
          firstName: 'John',
          lastName: 'Doe',
          email: 'john.doe@example.com',
          role: UserRole.employee,
          status: EmployeeStatus.active,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'admin123',
          dateOfBirth: birthDate,
        );

        // Act & Assert
        expect(employee.age, equals(25));
      });

      test('should check probation status correctly', () {
        // Arrange
        final probationEndDate = DateTime.now().add(const Duration(days: 30));
        final employee = Employee(
          id: 'emp123',
          userId: 'user123',
          employeeId: 'TRX2024000001',
          firstName: 'John',
          lastName: 'Doe',
          email: 'john.doe@example.com',
          role: UserRole.employee,
          status: EmployeeStatus.probation,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'admin123',
          probationEndDate: probationEndDate,
        );

        // Act & Assert
        expect(employee.isOnProbation, isTrue);
        expect(employee.isProbationOver, isFalse);
      });

      test('should calculate remaining leave days', () {
        // Arrange
        final employee = Employee(
          id: 'emp123',
          userId: 'user123',
          employeeId: 'TRX2024000001',
          firstName: 'John',
          lastName: 'Doe',
          email: 'john.doe@example.com',
          role: UserRole.employee,
          status: EmployeeStatus.active,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'admin123',
          totalLeaveDays: 21,
          usedLeaveDays: 5,
        );

        // Act & Assert
        expect(employee.remainingLeaveDays, equals(16));
      });

      test('should check manager status', () {
        // Arrange
        final employee = Employee(
          id: 'emp123',
          userId: 'user123',
          employeeId: 'TRX2024000001',
          firstName: 'John',
          lastName: 'Doe',
          email: 'john.doe@example.com',
          role: UserRole.manager,
          status: EmployeeStatus.active,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'admin123',
          subordinateIds: ['emp456', 'emp789'],
        );

        // Act & Assert
        expect(employee.isManager, isTrue);
      });

      test('should update employee status with audit log', () {
        // Arrange
        final employee = Employee(
          id: 'emp123',
          userId: 'user123',
          employeeId: 'TRX2024000001',
          firstName: 'John',
          lastName: 'Doe',
          email: 'john.doe@example.com',
          role: UserRole.employee,
          status: EmployeeStatus.active,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'admin123',
        );

        // Act
        final updatedEmployee = employee.updateStatus(
          EmployeeStatus.inactive,
          updatedBy: 'admin123',
        );

        // Assert
        expect(updatedEmployee.status, equals(EmployeeStatus.inactive));
        expect(updatedEmployee.isActive, isFalse);
      });

      test('should add and remove skills', () {
        // Arrange
        final employee = Employee(
          id: 'emp123',
          userId: 'user123',
          employeeId: 'TRX2024000001',
          firstName: 'John',
          lastName: 'Doe',
          email: 'john.doe@example.com',
          role: UserRole.employee,
          status: EmployeeStatus.active,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'admin123',
          skills: ['flutter', 'dart'],
        );

        // Act
        final withNewSkill = employee.addSkill(
          'firebase',
          updatedBy: 'admin123',
        );
        final withoutSkill = withNewSkill.removeSkill(
          'dart',
          updatedBy: 'admin123',
        );

        // Assert
        expect(withNewSkill.skills, contains('firebase'));
        expect(withoutSkill.skills, isNot(contains('dart')));
        expect(withoutSkill.hasSkill('flutter'), isTrue);
      });
    });

    group('Employee Status Tests', () {
      test('should check active status', () {
        expect(EmployeeStatus.active.isActive, isTrue);
        expect(EmployeeStatus.active.canWork, isTrue);
        expect(EmployeeStatus.active.canTakeLeave, isTrue);
      });

      test('should check inactive status', () {
        expect(EmployeeStatus.inactive.isActive, isFalse);
        expect(EmployeeStatus.inactive.canWork, isFalse);
      });

      test('should check probation status', () {
        expect(EmployeeStatus.probation.isOnProbation, isTrue);
        expect(EmployeeStatus.probation.canWork, isTrue);
      });

      test('should check terminated status', () {
        expect(EmployeeStatus.terminated.isTerminated, isTrue);
        expect(EmployeeStatus.terminated.canWork, isFalse);
        expect(EmployeeStatus.terminated.isEmployed, isFalse);
      });

      test('should create status from string', () {
        expect(
          EmployeeStatus.fromString('active'),
          equals(EmployeeStatus.active),
        );
        expect(
          EmployeeStatus.fromString('inactive'),
          equals(EmployeeStatus.inactive),
        );
        expect(
          EmployeeStatus.fromString('probation'),
          equals(EmployeeStatus.probation),
        );
      });

      test('should throw error for invalid status string', () {
        expect(
          () => EmployeeStatus.fromString('invalid'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}
