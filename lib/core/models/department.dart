import 'package:freezed_annotation/freezed_annotation.dart';

part 'department.freezed.dart';
part 'department.g.dart';

@freezed
class Department with _$Department {
  const factory Department({
    required String id,
    required String name,
    required String description,
    String? managerId,
    String? parentDepartmentId,
    @Default([]) List<String> employeeIds,
    @Default([]) List<String> subDepartmentIds,
    @Default(0.0) double budget,
    @Default(0.0) double actualSpending,
    @Default(true) bool isActive,
    String? location,
    String? contactEmail,
    String? contactPhone,
    Map<String, dynamic>? customFields,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? createdById,
    Map<String, dynamic>? metadata,
  }) = _Department;

  factory Department.fromJson(Map<String, dynamic> json) =>
      _$DepartmentFromJson(json);

  // Additional methods and getters
  const Department._();

  /// Get total number of employees
  int get employeeCount => employeeIds.length;

  /// Get total number of sub-departments
  int get subDepartmentCount => subDepartmentIds.length;

  /// Check if department has manager
  bool get hasManager => managerId != null && managerId!.isNotEmpty;

  /// Check if department is a root department (no parent)
  bool get isRootDepartment => parentDepartmentId == null;

  /// Check if department has sub-departments
  bool get hasSubDepartments => subDepartmentIds.isNotEmpty;

  /// Check if department has employees
  bool get hasEmployees => employeeIds.isNotEmpty;

  /// Get budget utilization percentage
  double get budgetUtilization {
    if (budget <= 0) return 0.0;
    return (actualSpending / budget * 100).clamp(0, double.infinity);
  }

  /// Check if department is over budget
  bool get isOverBudget => actualSpending > budget && budget > 0;

  /// Get remaining budget
  double get remainingBudget => budget - actualSpending;

  /// Check if user is department manager
  bool isManager(String userId) => managerId == userId;

  /// Check if user is in this department
  bool hasEmployee(String employeeId) => employeeIds.contains(employeeId);

  /// Get department hierarchy level (0 for root, 1 for first level, etc.)
  int getHierarchyLevel(List<Department> allDepartments) {
    if (isRootDepartment) return 0;

    final parent = allDepartments.firstWhere(
      (dept) => dept.id == parentDepartmentId,
      orElse: () => throw StateError('Parent department not found'),
    );

    return 1 + parent.getHierarchyLevel(allDepartments);
  }

  /// Get all ancestor department IDs
  List<String> getAncestorIds(List<Department> allDepartments) {
    if (isRootDepartment) return [];

    final parent = allDepartments.firstWhere(
      (dept) => dept.id == parentDepartmentId,
      orElse: () => throw StateError('Parent department not found'),
    );

    return [parent.id, ...parent.getAncestorIds(allDepartments)];
  }

  /// Get all descendant department IDs (recursive)
  List<String> getDescendantIds(List<Department> allDepartments) {
    final descendants = <String>[];

    for (final subDeptId in subDepartmentIds) {
      descendants.add(subDeptId);

      final subDept = allDepartments.firstWhere(
        (dept) => dept.id == subDeptId,
        orElse: () => throw StateError('Sub-department not found'),
      );

      descendants.addAll(subDept.getDescendantIds(allDepartments));
    }

    return descendants;
  }

  /// Get total employee count including sub-departments
  int getTotalEmployeeCount(List<Department> allDepartments) {
    int total = employeeCount;

    for (final subDeptId in subDepartmentIds) {
      final subDept = allDepartments.firstWhere(
        (dept) => dept.id == subDeptId,
        orElse: () => throw StateError('Sub-department not found'),
      );

      total += subDept.getTotalEmployeeCount(allDepartments);
    }

    return total;
  }

  /// Get department path (e.g., "Engineering > Frontend > UI Team")
  String getDepartmentPath(List<Department> allDepartments) {
    if (isRootDepartment) return name;

    final parent = allDepartments.firstWhere(
      (dept) => dept.id == parentDepartmentId,
      orElse: () => throw StateError('Parent department not found'),
    );

    return '${parent.getDepartmentPath(allDepartments)} > $name';
  }

  /// Create a copy with updated manager
  Department updateManager(String? newManagerId) {
    return copyWith(managerId: newManagerId, updatedAt: DateTime.now());
  }

  /// Create a copy with updated budget
  Department updateBudget({double? budget, double? actualSpending}) {
    return copyWith(
      budget: budget ?? this.budget,
      actualSpending: actualSpending ?? this.actualSpending,
      updatedAt: DateTime.now(),
    );
  }

  /// Add employee to department
  Department addEmployee(String employeeId) {
    if (employeeIds.contains(employeeId)) return this;
    return copyWith(
      employeeIds: [...employeeIds, employeeId],
      updatedAt: DateTime.now(),
    );
  }

  /// Remove employee from department
  Department removeEmployee(String employeeId) {
    return copyWith(
      employeeIds: employeeIds.where((id) => id != employeeId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// Add sub-department
  Department addSubDepartment(String subDepartmentId) {
    if (subDepartmentIds.contains(subDepartmentId)) return this;
    return copyWith(
      subDepartmentIds: [...subDepartmentIds, subDepartmentId],
      updatedAt: DateTime.now(),
    );
  }

  /// Remove sub-department
  Department removeSubDepartment(String subDepartmentId) {
    return copyWith(
      subDepartmentIds:
          subDepartmentIds.where((id) => id != subDepartmentId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// Update department status
  Department updateStatus(bool isActive) {
    return copyWith(isActive: isActive, updatedAt: DateTime.now());
  }

  /// Update contact information
  Department updateContact({String? email, String? phone, String? location}) {
    return copyWith(
      contactEmail: email ?? contactEmail,
      contactPhone: phone ?? contactPhone,
      location: location ?? this.location,
      updatedAt: DateTime.now(),
    );
  }

  /// Update custom field
  Department updateCustomField(String key, dynamic value) {
    final updatedFields = Map<String, dynamic>.from(customFields ?? {});
    updatedFields[key] = value;

    return copyWith(customFields: updatedFields, updatedAt: DateTime.now());
  }

  /// Remove custom field
  Department removeCustomField(String key) {
    if (customFields == null || !customFields!.containsKey(key)) return this;

    final updatedFields = Map<String, dynamic>.from(customFields!);
    updatedFields.remove(key);

    return copyWith(
      customFields: updatedFields.isEmpty ? null : updatedFields,
      updatedAt: DateTime.now(),
    );
  }

  /// Convert to map for Firestore
  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  /// Create from Firestore document
  factory Department.fromFirestore(Map<String, dynamic> data) {
    return Department.fromJson(data);
  }
}
