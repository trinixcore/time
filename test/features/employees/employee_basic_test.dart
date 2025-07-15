import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:time/core/models/employee.dart';
import 'package:time/core/enums/employee_status.dart';
import 'package:time/core/enums/user_role.dart';
import 'package:time/features/employees/presentation/widgets/employee_card.dart';
import 'package:time/features/employees/presentation/widgets/bulk_actions_widget.dart';

void main() {
  group('Employee Basic Tests', () {
    group('Employee Model Tests', () {
      test('should create employee with required fields', () {
        final employee = Employee(
          id: 'emp_001',
          userId: 'user_001',
          employeeId: 'EMP001',
          firstName: 'John',
          lastName: 'Doe',
          email: 'john.doe@company.com',
          phoneNumber: '+1234567890',
          role: UserRole.employee,
          status: EmployeeStatus.active,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'admin_001',
        );

        expect(employee.id, 'emp_001');
        expect(employee.fullName, 'John Doe');
        expect(employee.initials, 'JD');
        expect(employee.isEmployeeActive, true);
      });

      test('should handle optional fields correctly', () {
        final employee = Employee(
          id: 'emp_002',
          userId: 'user_002',
          employeeId: 'EMP002',
          firstName: 'Jane',
          lastName: 'Smith',
          email: 'jane.smith@company.com',
          role: UserRole.manager,
          status: EmployeeStatus.active,
          department: 'Engineering',
          designation: 'Senior Developer',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'admin_001',
        );

        expect(employee.department, 'Engineering');
        expect(employee.designation, 'Senior Developer');
        expect(employee.phoneNumber, isNull);
      });

      test('should convert to and from JSON correctly', () {
        final now = DateTime.now();
        final employee = Employee(
          id: 'emp_003',
          userId: 'user_003',
          employeeId: 'EMP003',
          firstName: 'Bob',
          lastName: 'Johnson',
          email: 'bob.johnson@company.com',
          role: UserRole.admin,
          status: EmployeeStatus.inactive,
          createdAt: now,
          updatedAt: now,
          createdBy: 'admin_001',
        );

        final json = employee.toJson();
        final fromJson = Employee.fromJson(json);

        expect(fromJson.id, employee.id);
        expect(fromJson.firstName, employee.firstName);
        expect(fromJson.lastName, employee.lastName);
        expect(fromJson.email, employee.email);
        expect(fromJson.role, employee.role);
        expect(fromJson.status, employee.status);
      });
    });

    group('Employee Widget Tests', () {
      testWidgets('EmployeeCard should display employee information', (
        tester,
      ) async {
        final employee = Employee(
          id: 'emp_001',
          userId: 'user_001',
          employeeId: 'EMP001',
          firstName: 'John',
          lastName: 'Doe',
          email: 'john.doe@company.com',
          phoneNumber: '+1234567890',
          role: UserRole.employee,
          status: EmployeeStatus.active,
          department: 'Engineering',
          designation: 'Developer',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'admin_001',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EmployeeCard(employee: employee, onTap: () {}),
            ),
          ),
        );

        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('EMP001'), findsOneWidget);
        expect(find.text('john.doe@company.com'), findsOneWidget);
        expect(find.text('+1234567890'), findsOneWidget);
        expect(find.text('Engineering'), findsOneWidget);
        expect(find.text('Developer'), findsOneWidget);
      });

      testWidgets('EmployeeCard should handle selection', (tester) async {
        final employee = Employee(
          id: 'emp_001',
          userId: 'user_001',
          employeeId: 'EMP001',
          firstName: 'John',
          lastName: 'Doe',
          email: 'john.doe@company.com',
          role: UserRole.employee,
          status: EmployeeStatus.active,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'admin_001',
        );

        bool? selectionChanged;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EmployeeCard(
                employee: employee,
                isSelected: false,
                onSelect: (selected) {
                  selectionChanged = selected;
                },
                onTap: () {},
              ),
            ),
          ),
        );

        // Find and tap the checkbox
        final checkbox = find.byType(Checkbox);
        expect(checkbox, findsOneWidget);

        await tester.tap(checkbox);
        await tester.pump();

        expect(selectionChanged, true);
      });

      testWidgets('BulkActionsWidget should display selected count', (
        tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: BulkActionsWidget(
                  selectedCount: 5,
                  selectedEmployeeIds: ['1', '2', '3', '4', '5'],
                  onClearSelection: () {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('5 selected'), findsOneWidget);
        expect(find.byIcon(Icons.delete), findsOneWidget);
        expect(find.byIcon(Icons.edit), findsOneWidget);
        expect(find.byIcon(Icons.clear), findsOneWidget);
      });
    });
  });
}
