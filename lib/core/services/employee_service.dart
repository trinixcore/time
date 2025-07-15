import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/employee.dart';
import '../models/user_model.dart';
import '../models/department.dart';
import '../enums/user_role.dart';
import '../enums/employee_status.dart';
import '../constants/firestore_paths.dart';
import 'firebase_service.dart';

class EmployeeService {
  static final EmployeeService _instance = EmployeeService._internal();
  factory EmployeeService() => _instance;
  EmployeeService._internal();

  final FirebaseService _firebaseService = FirebaseService();
  static final Logger _logger = Logger();

  FirebaseFirestore get _firestore => _firebaseService.firestore;

  /// Get all employees with optional filtering
  Stream<List<Employee>> getEmployees({
    EmployeeStatus? status,
    String? department,
    UserRole? role,
    String? searchQuery,
    int? limit,
  }) {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(
        FirestorePaths.employees,
      );

      // Count the number of filters to determine query strategy
      int filterCount = 0;
      if (status != null) filterCount++;
      if (department != null && department.isNotEmpty) filterCount++;
      if (role != null) filterCount++;

      // If multiple filters are applied, we need to be careful about indexes
      // For now, let's use a simpler approach to avoid index issues
      if (filterCount <= 1) {
        // Apply single filter if any
        if (status != null) {
          query = query.where('status', isEqualTo: status.value);
        } else if (department != null && department.isNotEmpty) {
          query = query.where('department', isEqualTo: department);
        } else if (role != null) {
          query = query.where('role', isEqualTo: role.value);
        }

        // Order by creation date only when we have 0-1 filters
        query = query.orderBy('createdAt', descending: true);
      } else {
        // For multiple filters, we'll do client-side filtering to avoid index issues
        // Just order by createdAt for now
        query = query.orderBy('createdAt', descending: true);
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) {
        var employees =
            snapshot.docs
                .map((doc) => Employee.fromFirestore(doc.data()))
                .toList();

        // Apply client-side filtering for multiple filters
        if (filterCount > 1) {
          employees =
              employees.where((employee) {
                bool matches = true;

                if (status != null && employee.status != status) {
                  matches = false;
                }

                if (department != null &&
                    department.isNotEmpty &&
                    employee.department != department) {
                  matches = false;
                }

                if (role != null && employee.role != role) {
                  matches = false;
                }

                return matches;
              }).toList();
        }

        // Apply search filter if provided
        if (searchQuery != null && searchQuery.isNotEmpty) {
          final searchLower = searchQuery.toLowerCase();
          employees =
              employees.where((employee) {
                return employee.fullName.toLowerCase().contains(searchLower) ||
                    employee.employeeId.toLowerCase().contains(searchLower) ||
                    employee.email.toLowerCase().contains(searchLower) ||
                    (employee.department?.toLowerCase().contains(searchLower) ??
                        false) ||
                    (employee.designation?.toLowerCase().contains(
                          searchLower,
                        ) ??
                        false);
              }).toList();
        }

        return employees;
      });
    } catch (e) {
      _logger.e('Failed to get employees: $e');
      // Return empty stream on error instead of crashing
      return Stream.value([]);
    }
  }

  /// Get all employees without complex filtering (for initial load)
  Stream<List<Employee>> getAllEmployees({int? limit}) {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(
        FirestorePaths.employees,
      );

      // Simple query with just ordering - no WHERE clauses to avoid index issues
      query = query.orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => Employee.fromFirestore(doc.data()))
            .toList();
      });
    } catch (e) {
      _logger.e('Failed to get all employees: $e');
      return Stream.value([]);
    }
  }

  /// Get employee by ID
  Future<Employee?> getEmployeeById(String employeeId) async {
    try {
      final doc =
          await _firestore
              .collection(FirestorePaths.employees)
              .doc(employeeId)
              .get();

      if (!doc.exists) {
        return null;
      }

      return Employee.fromFirestore(doc.data()!);
    } catch (e) {
      _logger.e('Failed to get employee by ID: $e');
      return null;
    }
  }

  /// Get employee by employee ID (TRX format)
  Future<Employee?> getEmployeeByEmployeeId(String employeeId) async {
    try {
      final query =
          await _firestore
              .collection(FirestorePaths.employees)
              .where('employeeId', isEqualTo: employeeId)
              .limit(1)
              .get();

      if (query.docs.isEmpty) {
        return null;
      }

      return Employee.fromFirestore(query.docs.first.data());
    } catch (e) {
      _logger.e('Failed to get employee by employee ID: $e');
      return null;
    }
  }

  /// Create new employee
  Future<Employee> createEmployee({
    required String userId,
    required String employeeId,
    required String firstName,
    required String lastName,
    required String email,
    required UserRole role,
    required String createdBy,
    String? phoneNumber,
    String? department,
    String? designation,
    String? reportingManagerId,
    String? hiringManagerId,
    String? departmentId,
    DateTime? joiningDate,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      _logger.i('Creating employee: $employeeId');

      final employee = Employee.fromUserModel(
        userId: userId,
        employeeId: employeeId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        role: role,
        createdBy: createdBy,
        phoneNumber: phoneNumber,
        department: department,
        designation: designation,
        reportingManagerId: reportingManagerId,
        hiringManagerId: hiringManagerId,
        joiningDate: joiningDate,
      );

      // Add additional data if provided
      Employee finalEmployee = employee;
      if (additionalData != null) {
        finalEmployee = employee.copyWith(
          departmentId: additionalData['departmentId'] as String?,
          address: additionalData['address'] as String?,
          city: additionalData['city'] as String?,
          state: additionalData['state'] as String?,
          country: additionalData['country'] as String?,
          postalCode: additionalData['postalCode'] as String?,
          gender: additionalData['gender'] as String?,
          dateOfBirth: additionalData['dateOfBirth'] as DateTime?,
          nationality: additionalData['nationality'] as String?,
          maritalStatus: additionalData['maritalStatus'] as String?,
          employmentType: additionalData['employmentType'] as String?,
          workLocation: additionalData['workLocation'] as String?,
          salary: additionalData['salary'] as double?,
          salaryGrade: additionalData['salaryGrade'] as String?,
          emergencyContactName:
              additionalData['emergencyContactName'] as String?,
          emergencyContactPhone:
              additionalData['emergencyContactPhone'] as String?,
          personalEmail: additionalData['personalEmail'] as String?,
        );
      }

      // Save to Firestore
      await _firestore
          .collection(FirestorePaths.employees)
          .doc(userId)
          .set(finalEmployee.toFirestore());

      // Update department employee count if department is specified
      if (departmentId != null) {
        await _updateDepartmentEmployeeCount(departmentId, 1);
      }

      // Update manager's subordinates list
      if (reportingManagerId != null) {
        await _addSubordinateToManager(reportingManagerId, userId);
      }

      _logger.i('Employee created successfully: $employeeId');
      return finalEmployee;
    } catch (e) {
      _logger.e('Failed to create employee: $e');
      rethrow;
    }
  }

  /// Update employee
  Future<Employee> updateEmployee({
    required String employeeId,
    required String updatedBy,
    Map<String, dynamic>? updates,
  }) async {
    try {
      _logger.i('Updating employee: $employeeId');

      final currentEmployee = await getEmployeeById(employeeId);
      if (currentEmployee == null) {
        throw Exception('Employee not found');
      }

      // Create updated employee
      final updatedEmployee = currentEmployee.copyWith(
        firstName:
            updates?['firstName'] as String? ?? currentEmployee.firstName,
        lastName: updates?['lastName'] as String? ?? currentEmployee.lastName,
        phoneNumber:
            updates?['phoneNumber'] as String? ?? currentEmployee.phoneNumber,
        department:
            updates?['department'] as String? ?? currentEmployee.department,
        designation:
            updates?['designation'] as String? ?? currentEmployee.designation,
        position: updates?['position'] as String? ?? currentEmployee.position,
        reportingManagerId:
            updates?['reportingManagerId'] as String? ??
            currentEmployee.reportingManagerId,
        hiringManagerId:
            updates?['hiringManagerId'] as String? ??
            currentEmployee.hiringManagerId,
        departmentId:
            updates?['departmentId'] as String? ?? currentEmployee.departmentId,
        address: updates?['address'] as String? ?? currentEmployee.address,
        city: updates?['city'] as String? ?? currentEmployee.city,
        state: updates?['state'] as String? ?? currentEmployee.state,
        country: updates?['country'] as String? ?? currentEmployee.country,
        postalCode:
            updates?['postalCode'] as String? ?? currentEmployee.postalCode,
        gender: updates?['gender'] as String? ?? currentEmployee.gender,
        dateOfBirth:
            updates?['dateOfBirth'] as DateTime? ?? currentEmployee.dateOfBirth,
        nationality:
            updates?['nationality'] as String? ?? currentEmployee.nationality,
        maritalStatus:
            updates?['maritalStatus'] as String? ??
            currentEmployee.maritalStatus,
        employmentType:
            updates?['employmentType'] as String? ??
            currentEmployee.employmentType,
        workLocation:
            updates?['workLocation'] as String? ?? currentEmployee.workLocation,
        salary: updates?['salary'] as double? ?? currentEmployee.salary,
        salaryGrade:
            updates?['salaryGrade'] as String? ?? currentEmployee.salaryGrade,
        emergencyContactName:
            updates?['emergencyContactName'] as String? ??
            currentEmployee.emergencyContactName,
        emergencyContactPhone:
            updates?['emergencyContactPhone'] as String? ??
            currentEmployee.emergencyContactPhone,
        personalEmail:
            updates?['personalEmail'] as String? ??
            currentEmployee.personalEmail,
        updatedAt: DateTime.now(),
        updatedBy: updatedBy,
      );

      // Add audit log entry
      final auditEmployee = updatedEmployee.addAuditLogEntry(
        'EMPLOYEE_UPDATED',
        updatedBy,
        details: updates ?? {},
      );

      // Save to Firestore
      await _firestore
          .collection(FirestorePaths.employees)
          .doc(employeeId)
          .set(auditEmployee.toFirestore());

      // Handle department changes
      if (updates?['departmentId'] != null &&
          updates!['departmentId'] != currentEmployee.departmentId) {
        // Remove from old department
        if (currentEmployee.departmentId != null) {
          await _updateDepartmentEmployeeCount(
            currentEmployee.departmentId!,
            -1,
          );
        }
        // Add to new department
        await _updateDepartmentEmployeeCount(
          updates['departmentId'] as String,
          1,
        );
      }

      // Handle manager changes
      if (updates?['reportingManagerId'] != null &&
          updates!['reportingManagerId'] !=
              currentEmployee.reportingManagerId) {
        // Remove from old manager
        if (currentEmployee.reportingManagerId != null) {
          await _removeSubordinateFromManager(
            currentEmployee.reportingManagerId!,
            employeeId,
          );
        }
        // Add to new manager
        await _addSubordinateToManager(
          updates['reportingManagerId'] as String,
          employeeId,
        );
      }

      _logger.i('Employee updated successfully: $employeeId');
      return auditEmployee;
    } catch (e) {
      _logger.e('Failed to update employee: $e');
      rethrow;
    }
  }

  /// Update employee status
  Future<Employee> updateEmployeeStatus({
    required String employeeId,
    required EmployeeStatus status,
    required String updatedBy,
    String? reason,
  }) async {
    try {
      _logger.i('Updating employee status: $employeeId to ${status.value}');

      final currentEmployee = await getEmployeeById(employeeId);
      if (currentEmployee == null) {
        throw Exception('Employee not found');
      }

      final updatedEmployee = currentEmployee
          .updateStatus(status, updatedBy: updatedBy)
          .addAuditLogEntry(
            'STATUS_UPDATED',
            updatedBy,
            details: {
              'oldStatus': currentEmployee.status.value,
              'newStatus': status.value,
              'reason': reason,
            },
          );

      // Save to Firestore
      await _firestore
          .collection(FirestorePaths.employees)
          .doc(employeeId)
          .set(updatedEmployee.toFirestore());

      // Update user model status as well
      await _firestore.collection(FirestorePaths.users).doc(employeeId).update({
        'isActive': status.canWork,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      _logger.i('Employee status updated successfully: $employeeId');
      return updatedEmployee;
    } catch (e) {
      _logger.e('Failed to update employee status: $e');
      rethrow;
    }
  }

  /// Delete employee (soft delete)
  Future<void> deleteEmployee({
    required String employeeId,
    required String deletedBy,
    String? reason,
  }) async {
    try {
      _logger.i('Deleting employee: $employeeId');

      await updateEmployeeStatus(
        employeeId: employeeId,
        status: EmployeeStatus.terminated,
        updatedBy: deletedBy,
        reason: reason ?? 'Employee deleted',
      );

      _logger.i('Employee deleted successfully: $employeeId');
    } catch (e) {
      _logger.e('Failed to delete employee: $e');
      rethrow;
    }
  }

  /// Get employees by department
  Stream<List<Employee>> getEmployeesByDepartment(String department) {
    return getEmployees(department: department);
  }

  /// Get employees by manager
  Stream<List<Employee>> getEmployeesByManager(String managerId) {
    try {
      return _firestore
          .collection(FirestorePaths.employees)
          .where('reportingManagerId', isEqualTo: managerId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => Employee.fromFirestore(doc.data()))
                    .toList(),
          );
    } catch (e) {
      _logger.e('Failed to get employees by manager: $e');
      return Stream.value([]);
    }
  }

  /// Get employee hierarchy (subordinates)
  Future<List<Employee>> getEmployeeHierarchy(String managerId) async {
    try {
      final directReports =
          await _firestore
              .collection(FirestorePaths.employees)
              .where('reportingManagerId', isEqualTo: managerId)
              .get();

      final employees = <Employee>[];

      for (final doc in directReports.docs) {
        final employee = Employee.fromFirestore(doc.data());
        employees.add(employee);

        // Recursively get subordinates
        final subordinates = await getEmployeeHierarchy(employee.id);
        employees.addAll(subordinates);
      }

      return employees;
    } catch (e) {
      _logger.e('Failed to get employee hierarchy: $e');
      return [];
    }
  }

  /// Get employee statistics
  Future<Map<String, dynamic>> getEmployeeStatistics() async {
    try {
      final allEmployees =
          await _firestore.collection(FirestorePaths.employees).get();

      final employees =
          allEmployees.docs
              .map((doc) => Employee.fromFirestore(doc.data()))
              .toList();

      final stats = <String, dynamic>{
        'total': employees.length,
        'active': employees.where((e) => e.status.isActive).length,
        'inactive': employees.where((e) => e.status.isInactive).length,
        'onLeave': employees.where((e) => e.status.isOnLeave).length,
        'terminated': employees.where((e) => e.status.isTerminated).length,
        'onProbation': employees.where((e) => e.status.isOnProbation).length,
        'byDepartment': <String, int>{},
        'byRole': <String, int>{},
        'averageYearsOfService': 0.0,
      };

      // Department statistics
      final departmentCounts = <String, int>{};
      for (final employee in employees) {
        if (employee.department != null) {
          departmentCounts[employee.department!] =
              (departmentCounts[employee.department!] ?? 0) + 1;
        }
      }
      stats['byDepartment'] = departmentCounts;

      // Role statistics
      final roleCounts = <String, int>{};
      for (final employee in employees) {
        roleCounts[employee.role.displayName] =
            (roleCounts[employee.role.displayName] ?? 0) + 1;
      }
      stats['byRole'] = roleCounts;

      // Average years of service
      if (employees.isNotEmpty) {
        final totalYears = employees
            .map((e) => e.yearsOfService)
            .reduce((a, b) => a + b);
        stats['averageYearsOfService'] = totalYears / employees.length;
      }

      return stats;
    } catch (e) {
      _logger.e('Failed to get employee statistics: $e');
      return {};
    }
  }

  /// Search employees
  Future<List<Employee>> searchEmployees(String query) async {
    try {
      if (query.isEmpty) return [];

      final allEmployees =
          await _firestore.collection(FirestorePaths.employees).get();

      final employees =
          allEmployees.docs
              .map((doc) => Employee.fromFirestore(doc.data()))
              .toList();

      final searchLower = query.toLowerCase();
      return employees.where((employee) {
        return employee.fullName.toLowerCase().contains(searchLower) ||
            employee.employeeId.toLowerCase().contains(searchLower) ||
            employee.email.toLowerCase().contains(searchLower) ||
            (employee.department?.toLowerCase().contains(searchLower) ??
                false) ||
            (employee.designation?.toLowerCase().contains(searchLower) ??
                false) ||
            employee.skills.any(
              (skill) => skill.toLowerCase().contains(searchLower),
            );
      }).toList();
    } catch (e) {
      _logger.e('Failed to search employees: $e');
      return [];
    }
  }

  /// Get employees for selection (dropdown/picker)
  Future<List<Map<String, dynamic>>> getEmployeesForSelection({
    UserRole? minimumRole,
    String? excludeEmployeeId,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(FirestorePaths.employees)
          .where('status', isEqualTo: EmployeeStatus.active.value);

      final snapshot = await query.get();
      var employees =
          snapshot.docs
              .map((doc) => Employee.fromFirestore(doc.data()))
              .toList();

      // Filter by minimum role if specified
      if (minimumRole != null) {
        employees =
            employees
                .where((emp) => emp.role.hasLevelOrAbove(minimumRole))
                .toList();
      }

      // Exclude specific employee if specified
      if (excludeEmployeeId != null) {
        employees =
            employees.where((emp) => emp.id != excludeEmployeeId).toList();
      }

      return employees
          .map(
            (emp) => {
              'id': emp.id,
              'employeeId': emp.employeeId,
              'name': emp.fullName,
              'email': emp.email,
              'department': emp.department ?? '',
              'designation': emp.designation ?? '',
              'role': emp.role.displayName,
            },
          )
          .toList();
    } catch (e) {
      _logger.e('Failed to get employees for selection: $e');
      return [];
    }
  }

  /// Update department employee count
  Future<void> _updateDepartmentEmployeeCount(
    String departmentId,
    int change,
  ) async {
    try {
      final departmentRef = _firestore
          .collection(FirestorePaths.departments)
          .doc(departmentId);

      await _firestore.runTransaction((transaction) async {
        final departmentDoc = await transaction.get(departmentRef);
        if (departmentDoc.exists) {
          final department = Department.fromFirestore(departmentDoc.data()!);
          final updatedDepartment = department.copyWith(
            employeeIds:
                change > 0
                    ? [
                      ...department.employeeIds,
                      'placeholder',
                    ] // This would be the actual employee ID
                    : department.employeeIds
                        .take(department.employeeIds.length - 1)
                        .toList(),
            updatedAt: DateTime.now(),
          );
          transaction.set(departmentRef, updatedDepartment.toFirestore());
        }
      });
    } catch (e) {
      _logger.e('Failed to update department employee count: $e');
      // Don't rethrow - this is not critical
    }
  }

  /// Add subordinate to manager
  Future<void> _addSubordinateToManager(
    String managerId,
    String subordinateId,
  ) async {
    try {
      final managerRef = _firestore
          .collection(FirestorePaths.employees)
          .doc(managerId);

      await _firestore.runTransaction((transaction) async {
        final managerDoc = await transaction.get(managerRef);
        if (managerDoc.exists) {
          final manager = Employee.fromFirestore(managerDoc.data()!);
          final updatedManager = manager.addSubordinate(subordinateId);
          transaction.set(managerRef, updatedManager.toFirestore());
        }
      });
    } catch (e) {
      _logger.e('Failed to add subordinate to manager: $e');
      // Don't rethrow - this is not critical
    }
  }

  /// Remove subordinate from manager
  Future<void> _removeSubordinateFromManager(
    String managerId,
    String subordinateId,
  ) async {
    try {
      final managerRef = _firestore
          .collection(FirestorePaths.employees)
          .doc(managerId);

      await _firestore.runTransaction((transaction) async {
        final managerDoc = await transaction.get(managerRef);
        if (managerDoc.exists) {
          final manager = Employee.fromFirestore(managerDoc.data()!);
          final updatedManager = manager.removeSubordinate(subordinateId);
          transaction.set(managerRef, updatedManager.toFirestore());
        }
      });
    } catch (e) {
      _logger.e('Failed to remove subordinate from manager: $e');
      // Don't rethrow - this is not critical
    }
  }

  /// Bulk update employees
  Future<void> bulkUpdateEmployees({
    required List<String> employeeIds,
    required Map<String, dynamic> updates,
    required String updatedBy,
  }) async {
    try {
      _logger.i('Bulk updating ${employeeIds.length} employees');

      final batch = _firestore.batch();

      for (final employeeId in employeeIds) {
        final employeeRef = _firestore
            .collection(FirestorePaths.employees)
            .doc(employeeId);

        final updateData = {
          ...updates,
          'updatedAt': DateTime.now().toIso8601String(),
          'updatedBy': updatedBy,
        };

        batch.update(employeeRef, updateData);
      }

      await batch.commit();
      _logger.i('Bulk update completed successfully');
    } catch (e) {
      _logger.e('Failed to bulk update employees: $e');
      rethrow;
    }
  }

  /// Export employees data
  Future<List<Map<String, dynamic>>> exportEmployees({
    EmployeeStatus? status,
    String? department,
    UserRole? role,
  }) async {
    try {
      final employees =
          await getEmployees(
            status: status,
            department: department,
            role: role,
          ).first;

      return employees
          .map(
            (employee) => {
              'Employee ID': employee.employeeId,
              'Full Name': employee.fullName,
              'Email': employee.email,
              'Phone': employee.phoneNumber ?? '',
              'Department': employee.department ?? '',
              'Designation': employee.designation ?? '',
              'Role': employee.role.displayName,
              'Status': employee.status.displayName,
              'Joining Date': employee.joiningDate?.toIso8601String() ?? '',
              'Years of Service': employee.yearsOfService.toStringAsFixed(1),
              'Reporting Manager': employee.reportingManagerId ?? '',
              'Employment Type': employee.employmentType ?? '',
              'Work Location': employee.workLocation ?? '',
              'Total Leave Days': employee.totalLeaveDays ?? 0,
              'Used Leave Days': employee.usedLeaveDays ?? 0,
              'Remaining Leave Days': employee.remainingLeaveDays,
              'Performance Rating': employee.performanceRating ?? 0.0,
              'Created At': employee.createdAt.toIso8601String(),
              'Updated At': employee.updatedAt.toIso8601String(),
            },
          )
          .toList();
    } catch (e) {
      _logger.e('Failed to export employees: $e');
      return [];
    }
  }

  /// Create sample employee data for testing
  Future<void> createSampleEmployees() async {
    try {
      _logger.i('Creating sample employee data...');

      final sampleEmployees = [
        {
          'userId': 'sample_user_1',
          'employeeId': 'TRX2025000001',
          'firstName': 'John',
          'lastName': 'Doe',
          'email': 'john.doe@trinix.com',
          'role': UserRole.employee,
          'department': 'Engineering',
          'designation': 'Software Developer',
          'status': EmployeeStatus.active,
        },
        {
          'userId': 'sample_user_2',
          'employeeId': 'TRX2025000002',
          'firstName': 'Jane',
          'lastName': 'Smith',
          'email': 'jane.smith@trinix.com',
          'role': UserRole.manager,
          'department': 'Engineering',
          'designation': 'Engineering Manager',
          'status': EmployeeStatus.active,
        },
        {
          'userId': 'sample_user_3',
          'employeeId': 'TRX2025000003',
          'firstName': 'Bob',
          'lastName': 'Johnson',
          'email': 'bob.johnson@trinix.com',
          'role': UserRole.hr,
          'department': 'Human Resources',
          'designation': 'HR Manager',
          'status': EmployeeStatus.active,
        },
        {
          'userId': 'sample_user_4',
          'employeeId': 'TRX2025000004',
          'firstName': 'Alice',
          'lastName': 'Brown',
          'email': 'alice.brown@trinix.com',
          'role': UserRole.employee,
          'department': 'Marketing',
          'designation': 'Marketing Specialist',
          'status': EmployeeStatus.inactive,
        },
      ];

      for (final employeeData in sampleEmployees) {
        final employee = Employee.fromUserModel(
          userId: employeeData['userId'] as String,
          employeeId: employeeData['employeeId'] as String,
          firstName: employeeData['firstName'] as String,
          lastName: employeeData['lastName'] as String,
          email: employeeData['email'] as String,
          role: employeeData['role'] as UserRole,
          createdBy: 'system',
          department: employeeData['department'] as String?,
          designation: employeeData['designation'] as String?,
        ).copyWith(status: employeeData['status'] as EmployeeStatus);

        await _firestore
            .collection(FirestorePaths.employees)
            .doc(employeeData['userId'] as String)
            .set(employee.toFirestore());
      }

      _logger.i('Sample employee data created successfully');
    } catch (e) {
      _logger.e('Failed to create sample employees: $e');
      rethrow;
    }
  }
}
