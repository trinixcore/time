import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/employee.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/enums/employee_status.dart';
import '../../../../core/providers/employee_provider.dart';
import '../../../../shared/providers/auth_providers.dart';
import '../../../../core/services/audit_log_service.dart';

class EmployeeFormDialog extends ConsumerStatefulWidget {
  final Employee? employee;

  const EmployeeFormDialog({super.key, this.employee});

  @override
  ConsumerState<EmployeeFormDialog> createState() => _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends ConsumerState<EmployeeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _departmentController = TextEditingController();
  final _designationController = TextEditingController();

  UserRole _selectedRole = UserRole.employee;
  EmployeeStatus _selectedStatus = EmployeeStatus.active;
  DateTime? _joiningDate;
  DateTime? _dateOfBirth;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      _loadEmployeeData();
    }
  }

  void _loadEmployeeData() {
    final employee = widget.employee!;
    _firstNameController.text = employee.firstName;
    _lastNameController.text = employee.lastName;
    _emailController.text = employee.email;
    _phoneController.text = employee.phoneNumber ?? '';
    _employeeIdController.text = employee.employeeId;
    _departmentController.text = employee.department ?? '';
    _designationController.text = employee.designation ?? '';
    _selectedRole = employee.role;
    _selectedStatus = employee.status;
    _joiningDate = employee.joiningDate;
    _dateOfBirth = employee.dateOfBirth;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _employeeIdController.dispose();
    _departmentController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.employee != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Employee' : 'Add Employee'),
      content: SizedBox(
        width: 500,
        height: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Information
                Text(
                  'Basic Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'First name is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Last name is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _employeeIdController,
                        decoration: const InputDecoration(
                          labelText: 'Employee ID *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Employee ID is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Work Information
                Text(
                  'Work Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _departmentController,
                        decoration: const InputDecoration(
                          labelText: 'Department',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _designationController,
                        decoration: const InputDecoration(
                          labelText: 'Designation',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<UserRole>(
                        value: _selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Role *',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            UserRole.values.map((role) {
                              return DropdownMenuItem(
                                value: role,
                                child: Text(role.displayName),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedRole = value;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<EmployeeStatus>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status *',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            EmployeeStatus.values.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(status.displayName),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedStatus = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Date Fields
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, true),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Joining Date',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            _joiningDate != null
                                ? '${_joiningDate!.day}/${_joiningDate!.month}/${_joiningDate!.year}'
                                : 'Select Date',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, false),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date of Birth',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            _dateOfBirth != null
                                ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                                : 'Select Date',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveEmployee,
          child:
              _isLoading
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : Text(isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isJoiningDate) async {
    final initialDate = isJoiningDate ? _joiningDate : _dateOfBirth;
    final firstDate = isJoiningDate ? DateTime(1900) : DateTime(1900);
    final lastDate =
        isJoiningDate
            ? DateTime.now().add(const Duration(days: 365))
            : DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (date != null) {
      setState(() {
        if (isJoiningDate) {
          _joiningDate = date;
        } else {
          _dateOfBirth = date;
        }
      });
    }
  }

  Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = ref.read(currentUserProvider).valueOrNull;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final employeeManagement = ref.read(employeeManagementProvider.notifier);

      if (widget.employee == null) {
        // Create new employee
        final employee = await employeeManagement.createEmployee(
          userId: currentUser.uid,
          employeeId: _employeeIdController.text.trim(),
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          role: _selectedRole,
          createdBy: currentUser.uid,
          phoneNumber:
              _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
          department:
              _departmentController.text.trim().isEmpty
                  ? null
                  : _departmentController.text.trim(),
          designation:
              _designationController.text.trim().isEmpty
                  ? null
                  : _designationController.text.trim(),
          joiningDate: _joiningDate,
          additionalData: {
            'dateOfBirth': _dateOfBirth?.toIso8601String(),
            'status': _selectedStatus.value,
          },
        );

        if (employee != null) {
          // Audit log for employee creation
          await AuditLogService().logEvent(
            action: 'EMPLOYEE_CREATE',
            userId: currentUser.uid,
            userName: currentUser.displayName ?? currentUser.email ?? 'Unknown',
            userEmail: currentUser.email,
            status: 'success',
            targetType: 'employee',
            targetId: employee.id,
            details: {
              'employeeId': employee.employeeId,
              'firstName': employee.firstName,
              'lastName': employee.lastName,
              'email': employee.email,
              'role': employee.role.value,
              'department': employee.department,
              'designation': employee.designation,
              'joiningDate': employee.joiningDate?.toIso8601String(),
              'status': employee.status.value,
            },
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Employee created successfully')),
            );
            Navigator.of(context).pop(employee);
          }
        } else {
          throw Exception('Failed to create employee');
        }
      } else {
        // Update existing employee
        final updates = <String, dynamic>{
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phoneNumber':
              _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
          'department':
              _departmentController.text.trim().isEmpty
                  ? null
                  : _departmentController.text.trim(),
          'designation':
              _designationController.text.trim().isEmpty
                  ? null
                  : _designationController.text.trim(),
          'role': _selectedRole.value,
          'joiningDate': _joiningDate?.toIso8601String(),
          'dateOfBirth': _dateOfBirth?.toIso8601String(),
          'status': _selectedStatus.value,
        };

        final employee = await employeeManagement.updateEmployee(
          employeeId: widget.employee!.id,
          updatedBy: currentUser.uid,
          updates: updates,
        );

        if (employee != null) {
          // Audit log for employee update
          await AuditLogService().logEvent(
            action: 'EMPLOYEE_UPDATE',
            userId: currentUser.uid,
            userName: currentUser.displayName ?? currentUser.email ?? 'Unknown',
            userEmail: currentUser.email,
            status: 'success',
            targetType: 'employee',
            targetId: employee.id,
            details: updates,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Employee updated successfully')),
            );
            Navigator.of(context).pop(employee);
          }
        } else {
          throw Exception('Failed to update employee');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
