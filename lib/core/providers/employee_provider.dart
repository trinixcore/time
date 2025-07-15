import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../models/employee.dart';
import '../services/employee_service.dart';
import '../enums/user_role.dart';
import '../enums/employee_status.dart';
import 'performance_providers.dart';

// Employee service provider
final employeeServiceProvider = Provider<EmployeeService>((ref) {
  return EmployeeService();
});

// Optimized all employees provider with caching
final allEmployeesProvider = FutureProvider<List<Employee>>((ref) async {
  // Watch for refresh triggers
  ref.watch(globalRefreshProvider.select((state) => state['employees'] ?? 0));

  try {
    final employeeService = ref.watch(employeeServiceProvider);
    final employees = await employeeService.getAllEmployees().first;
    return employees;
  } catch (e) {
    throw e;
  }
});

// Optimized employee list provider with filters and caching
final employeeListProvider = FutureProvider.family<
  List<Employee>,
  EmployeeFilters
>((ref, filters) async {
  // Watch for refresh triggers
  ref.watch(globalRefreshProvider.select((state) => state['employees'] ?? 0));

  try {
    final employeeService = ref.watch(employeeServiceProvider);
    final employees =
        await employeeService
            .getEmployees(
              status: filters.status,
              department: filters.department,
              role: filters.role,
              searchQuery: filters.searchQuery,
              limit: filters.limit,
            )
            .first;

    return employees;
  } catch (e) {
    throw e;
  }
});

// Employee by ID provider
final employeeByIdProvider = FutureProvider.family<Employee?, String>((
  ref,
  employeeId,
) {
  final employeeService = ref.watch(employeeServiceProvider);
  return employeeService.getEmployeeById(employeeId);
});

// Employee by employee ID provider
final employeeByEmployeeIdProvider = FutureProvider.family<Employee?, String>((
  ref,
  employeeId,
) {
  final employeeService = ref.watch(employeeServiceProvider);
  return employeeService.getEmployeeByEmployeeId(employeeId);
});

// Employees by department provider
final employeesByDepartmentProvider =
    StreamProvider.family<List<Employee>, String>((ref, department) {
      final employeeService = ref.watch(employeeServiceProvider);
      return employeeService.getEmployeesByDepartment(department);
    });

// Employees by manager provider
final employeesByManagerProvider =
    StreamProvider.family<List<Employee>, String>((ref, managerId) {
      final employeeService = ref.watch(employeeServiceProvider);
      return employeeService.getEmployeesByManager(managerId);
    });

// Employee hierarchy provider
final employeeHierarchyProvider = FutureProvider.family<List<Employee>, String>(
  (ref, managerId) {
    final employeeService = ref.watch(employeeServiceProvider);
    return employeeService.getEmployeeHierarchy(managerId);
  },
);

// Employee statistics provider
final employeeStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  final employeeService = ref.watch(employeeServiceProvider);
  return employeeService.getEmployeeStatistics();
});

// Employee search provider
final employeeSearchProvider = FutureProvider.family<List<Employee>, String>((
  ref,
  query,
) {
  final employeeService = ref.watch(employeeServiceProvider);
  return employeeService.searchEmployees(query);
});

// Employees for selection provider
final employeesForSelectionProvider =
    FutureProvider.family<List<Map<String, dynamic>>, SelectionFilters>((
      ref,
      filters,
    ) {
      final employeeService = ref.watch(employeeServiceProvider);
      return employeeService.getEmployeesForSelection(
        minimumRole: filters.minimumRole,
        excludeEmployeeId: filters.excludeEmployeeId,
      );
    });

// Employee management state provider
final employeeManagementProvider =
    StateNotifierProvider<EmployeeManagementNotifier, EmployeeManagementState>((
      ref,
    ) {
      final employeeService = ref.watch(employeeServiceProvider);
      return EmployeeManagementNotifier(employeeService);
    });

// Employee filters state provider
final employeeFiltersProvider =
    StateNotifierProvider<EmployeeFiltersNotifier, EmployeeFilters>((ref) {
      return EmployeeFiltersNotifier();
    });

// Employee selection state provider
final employeeSelectionProvider =
    StateNotifierProvider<EmployeeSelectionNotifier, Set<String>>((ref) {
      return EmployeeSelectionNotifier();
    });

// Employee form state provider
final employeeFormProvider =
    StateNotifierProvider<EmployeeFormNotifier, EmployeeFormState>((ref) {
      return EmployeeFormNotifier();
    });

// Data classes for filters and state
class EmployeeFilters {
  final EmployeeStatus? status;
  final String? department;
  final UserRole? role;
  final String? searchQuery;
  final int? limit;

  const EmployeeFilters({
    this.status,
    this.department,
    this.role,
    this.searchQuery,
    this.limit,
  });

  EmployeeFilters copyWith({
    EmployeeStatus? status,
    String? department,
    UserRole? role,
    String? searchQuery,
    int? limit,
  }) {
    return EmployeeFilters(
      status: status ?? this.status,
      department: department ?? this.department,
      role: role ?? this.role,
      searchQuery: searchQuery ?? this.searchQuery,
      limit: limit ?? this.limit,
    );
  }

  EmployeeFilters clearFilters() {
    return const EmployeeFilters();
  }

  bool get hasFilters =>
      status != null ||
      department != null ||
      role != null ||
      (searchQuery != null && searchQuery!.isNotEmpty);
}

class SelectionFilters {
  final UserRole? minimumRole;
  final String? excludeEmployeeId;

  const SelectionFilters({this.minimumRole, this.excludeEmployeeId});
}

class EmployeeManagementState {
  final bool isLoading;
  final String? error;
  final Employee? selectedEmployee;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;

  const EmployeeManagementState({
    this.isLoading = false,
    this.error,
    this.selectedEmployee,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
  });

  EmployeeManagementState copyWith({
    bool? isLoading,
    String? error,
    Employee? selectedEmployee,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
  }) {
    return EmployeeManagementState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedEmployee: selectedEmployee ?? this.selectedEmployee,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  bool get hasError => error != null;
  bool get isProcessing => isCreating || isUpdating || isDeleting;
}

class EmployeeFormState {
  final Map<String, dynamic> formData;
  final Map<String, String> errors;
  final bool isValid;
  final bool isDirty;

  const EmployeeFormState({
    this.formData = const {},
    this.errors = const {},
    this.isValid = false,
    this.isDirty = false,
  });

  EmployeeFormState copyWith({
    Map<String, dynamic>? formData,
    Map<String, String>? errors,
    bool? isValid,
    bool? isDirty,
  }) {
    return EmployeeFormState(
      formData: formData ?? this.formData,
      errors: errors ?? this.errors,
      isValid: isValid ?? this.isValid,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  bool get hasErrors => errors.isNotEmpty;
}

// State notifiers
class EmployeeManagementNotifier
    extends StateNotifier<EmployeeManagementState> {
  final EmployeeService _employeeService;
  static final Logger _logger = Logger();

  EmployeeManagementNotifier(this._employeeService)
    : super(const EmployeeManagementState());

  void selectEmployee(Employee? employee) {
    state = state.copyWith(selectedEmployee: employee);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<Employee?> createEmployee({
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
      state = state.copyWith(isCreating: true, error: null);

      final employee = await _employeeService.createEmployee(
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
        departmentId: departmentId,
        joiningDate: joiningDate,
        additionalData: additionalData,
      );

      state = state.copyWith(isCreating: false, selectedEmployee: employee);
      _logger.i('Employee created successfully: ${employee.employeeId}');
      return employee;
    } catch (e) {
      state = state.copyWith(isCreating: false, error: e.toString());
      _logger.e('Failed to create employee: $e');
      return null;
    }
  }

  Future<Employee?> updateEmployee({
    required String employeeId,
    required String updatedBy,
    Map<String, dynamic>? updates,
  }) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final employee = await _employeeService.updateEmployee(
        employeeId: employeeId,
        updatedBy: updatedBy,
        updates: updates,
      );

      state = state.copyWith(isUpdating: false, selectedEmployee: employee);
      _logger.i('Employee updated successfully: $employeeId');
      return employee;
    } catch (e) {
      state = state.copyWith(isUpdating: false, error: e.toString());
      _logger.e('Failed to update employee: $e');
      return null;
    }
  }

  Future<bool> updateEmployeeStatus({
    required String employeeId,
    required EmployeeStatus status,
    required String updatedBy,
    String? reason,
  }) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final employee = await _employeeService.updateEmployeeStatus(
        employeeId: employeeId,
        status: status,
        updatedBy: updatedBy,
        reason: reason,
      );

      state = state.copyWith(isUpdating: false, selectedEmployee: employee);
      _logger.i('Employee status updated successfully: $employeeId');
      return true;
    } catch (e) {
      state = state.copyWith(isUpdating: false, error: e.toString());
      _logger.e('Failed to update employee status: $e');
      return false;
    }
  }

  Future<bool> deleteEmployee({
    required String employeeId,
    required String deletedBy,
    String? reason,
  }) async {
    try {
      state = state.copyWith(isDeleting: true, error: null);

      await _employeeService.deleteEmployee(
        employeeId: employeeId,
        deletedBy: deletedBy,
        reason: reason,
      );

      state = state.copyWith(isDeleting: false, selectedEmployee: null);
      _logger.i('Employee deleted successfully: $employeeId');
      return true;
    } catch (e) {
      state = state.copyWith(isDeleting: false, error: e.toString());
      _logger.e('Failed to delete employee: $e');
      return false;
    }
  }

  Future<bool> bulkUpdateEmployees({
    required List<String> employeeIds,
    required Map<String, dynamic> updates,
    required String updatedBy,
  }) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      await _employeeService.bulkUpdateEmployees(
        employeeIds: employeeIds,
        updates: updates,
        updatedBy: updatedBy,
      );

      state = state.copyWith(isUpdating: false);
      _logger.i('Bulk update completed successfully');
      return true;
    } catch (e) {
      state = state.copyWith(isUpdating: false, error: e.toString());
      _logger.e('Failed to bulk update employees: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> exportEmployees({
    EmployeeStatus? status,
    String? department,
    UserRole? role,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final data = await _employeeService.exportEmployees(
        status: status,
        department: department,
        role: role,
      );

      state = state.copyWith(isLoading: false);
      _logger.i('Employee data exported successfully');
      return data;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      _logger.e('Failed to export employees: $e');
      return [];
    }
  }
}

class EmployeeFiltersNotifier extends StateNotifier<EmployeeFilters> {
  EmployeeFiltersNotifier() : super(const EmployeeFilters());

  void updateStatus(EmployeeStatus? status) {
    state = state.copyWith(status: status);
  }

  void updateDepartment(String? department) {
    state = state.copyWith(department: department);
  }

  void updateRole(UserRole? role) {
    state = state.copyWith(role: role);
  }

  void updateSearchQuery(String? searchQuery) {
    state = state.copyWith(searchQuery: searchQuery);
  }

  void updateLimit(int? limit) {
    state = state.copyWith(limit: limit);
  }

  void clearFilters() {
    state = state.clearFilters();
  }

  void applyFilters({
    EmployeeStatus? status,
    String? department,
    UserRole? role,
    String? searchQuery,
    int? limit,
  }) {
    state = EmployeeFilters(
      status: status,
      department: department,
      role: role,
      searchQuery: searchQuery,
      limit: limit,
    );
  }
}

class EmployeeSelectionNotifier extends StateNotifier<Set<String>> {
  EmployeeSelectionNotifier() : super(<String>{});

  void selectEmployee(String employeeId) {
    state = {...state, employeeId};
  }

  void deselectEmployee(String employeeId) {
    state = state.where((id) => id != employeeId).toSet();
  }

  void toggleEmployee(String employeeId) {
    if (state.contains(employeeId)) {
      deselectEmployee(employeeId);
    } else {
      selectEmployee(employeeId);
    }
  }

  void selectAll(List<String> employeeIds) {
    state = employeeIds.toSet();
  }

  void clearSelection() {
    state = <String>{};
  }

  bool isSelected(String employeeId) {
    return state.contains(employeeId);
  }

  int get selectedCount => state.length;
  bool get hasSelection => state.isNotEmpty;
  List<String> get selectedIds => state.toList();
}

class EmployeeFormNotifier extends StateNotifier<EmployeeFormState> {
  EmployeeFormNotifier() : super(const EmployeeFormState());

  void updateField(String key, dynamic value) {
    final updatedFormData = Map<String, dynamic>.from(state.formData);
    updatedFormData[key] = value;

    final updatedErrors = Map<String, String>.from(state.errors);
    updatedErrors.remove(key); // Clear error for this field

    state = state.copyWith(
      formData: updatedFormData,
      errors: updatedErrors,
      isDirty: true,
      isValid: _validateForm(updatedFormData),
    );
  }

  void setError(String key, String error) {
    final updatedErrors = Map<String, String>.from(state.errors);
    updatedErrors[key] = error;

    state = state.copyWith(errors: updatedErrors, isValid: false);
  }

  void clearError(String key) {
    final updatedErrors = Map<String, String>.from(state.errors);
    updatedErrors.remove(key);

    state = state.copyWith(
      errors: updatedErrors,
      isValid: _validateForm(state.formData),
    );
  }

  void clearAllErrors() {
    state = state.copyWith(errors: {}, isValid: _validateForm(state.formData));
  }

  void resetForm() {
    state = const EmployeeFormState();
  }

  void loadEmployee(Employee employee) {
    final formData = {
      'firstName': employee.firstName,
      'lastName': employee.lastName,
      'email': employee.email,
      'phoneNumber': employee.phoneNumber,
      'department': employee.department,
      'designation': employee.designation,
      'role': employee.role,
      'reportingManagerId': employee.reportingManagerId,
      'hiringManagerId': employee.hiringManagerId,
      'departmentId': employee.departmentId,
      'joiningDate': employee.joiningDate,
      'address': employee.address,
      'city': employee.city,
      'state': employee.state,
      'country': employee.country,
      'postalCode': employee.postalCode,
      'gender': employee.gender,
      'dateOfBirth': employee.dateOfBirth,
      'nationality': employee.nationality,
      'maritalStatus': employee.maritalStatus,
      'employmentType': employee.employmentType,
      'workLocation': employee.workLocation,
      'salary': employee.salary,
      'salaryGrade': employee.salaryGrade,
      'emergencyContactName': employee.emergencyContactName,
      'emergencyContactPhone': employee.emergencyContactPhone,
      'personalEmail': employee.personalEmail,
    };

    state = state.copyWith(
      formData: formData,
      isValid: _validateForm(formData),
      isDirty: false,
    );
  }

  bool _validateForm(Map<String, dynamic> formData) {
    // Basic validation - can be extended
    final firstName = formData['firstName'] as String?;
    final lastName = formData['lastName'] as String?;
    final email = formData['email'] as String?;
    final role = formData['role'] as UserRole?;

    return firstName != null &&
        firstName.isNotEmpty &&
        lastName != null &&
        lastName.isNotEmpty &&
        email != null &&
        email.isNotEmpty &&
        email.contains('@') &&
        role != null;
  }

  Map<String, dynamic> get formData => state.formData;
  Map<String, String> get errors => state.errors;
  bool get isValid => state.isValid;
  bool get isDirty => state.isDirty;
  bool get hasErrors => state.hasErrors;
}
