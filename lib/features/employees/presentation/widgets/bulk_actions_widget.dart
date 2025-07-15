import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/enums/employee_status.dart';
import '../../../../core/providers/employee_provider.dart';
import '../../../../shared/providers/auth_providers.dart';
import '../../../../core/services/audit_log_service.dart';

class BulkActionsWidget extends ConsumerWidget {
  final int selectedCount;
  final VoidCallback onClearSelection;
  final List<String> selectedEmployeeIds;

  const BulkActionsWidget({
    super.key,
    required this.selectedCount,
    required this.onClearSelection,
    required this.selectedEmployeeIds,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Text(
            '$selectedCount employee${selectedCount > 1 ? 's' : ''} selected',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onClearSelection,
            child: Text(
              'Clear',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            onSelected: (value) => _handleBulkAction(context, ref, value),
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        Icon(Icons.download),
                        SizedBox(width: 8),
                        Text('Export Selected'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'activate',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Activate'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'deactivate',
                    child: Row(
                      children: [
                        Icon(Icons.pause_circle, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Deactivate'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'update_department',
                    child: Row(
                      children: [
                        Icon(Icons.business),
                        SizedBox(width: 8),
                        Text('Update Department'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'Delete Selected',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleBulkAction(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) {
      _showError(context, 'User not authenticated');
      return;
    }

    final employeeManagement = ref.read(employeeManagementProvider.notifier);

    switch (action) {
      case 'export':
        await _exportSelected(context, ref);
        break;
      case 'activate':
        await _updateStatus(
          context,
          employeeManagement,
          EmployeeStatus.active,
          currentUser.uid,
        );
        break;
      case 'deactivate':
        await _updateStatus(
          context,
          employeeManagement,
          EmployeeStatus.inactive,
          currentUser.uid,
        );
        break;
      case 'update_department':
        await _showUpdateDepartmentDialog(
          context,
          employeeManagement,
          currentUser.uid,
        );
        break;
      case 'delete':
        await _showDeleteConfirmation(
          context,
          employeeManagement,
          currentUser.uid,
        );
        break;
    }
  }

  Future<void> _exportSelected(BuildContext context, WidgetRef ref) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Exporting employees...'),
                ],
              ),
            ),
      );

      // TODO: Implement actual export functionality
      await Future.delayed(const Duration(seconds: 2));

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported $selectedCount employees successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showError(context, 'Failed to export employees: $e');
      }
    }
  }

  Future<void> _updateStatus(
    BuildContext context,
    EmployeeManagementNotifier employeeManagement,
    EmployeeStatus status,
    String updatedBy,
  ) async {
    final confirmed = await _showConfirmationDialog(
      context,
      'Update Status',
      'Are you sure you want to ${status.value} $selectedCount employee${selectedCount > 1 ? 's' : ''}?',
    );

    if (!confirmed) return;

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Updating employee status...'),
                ],
              ),
            ),
      );

      // Update each employee's status
      int successCount = 0;
      for (final employeeId in selectedEmployeeIds) {
        final success = await employeeManagement.updateEmployeeStatus(
          employeeId: employeeId,
          status: status,
          updatedBy: updatedBy,
          reason: 'Bulk status update',
        );
        if (success) successCount++;
        // Audit log for employee status update
        if (success) {
          await AuditLogService().logEvent(
            action: 'EMPLOYEE_STATUS_UPDATE',
            userId: updatedBy,
            status: 'success',
            targetType: 'employee',
            targetId: employeeId,
            details: {
              'newStatus': status.value,
              'reason': 'Bulk status update',
            },
          );
        }
      }

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        if (successCount == selectedEmployeeIds.length) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Updated status for $successCount employees'),
              backgroundColor: Colors.green,
            ),
          );
          onClearSelection();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Updated $successCount out of ${selectedEmployeeIds.length} employees',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showError(context, 'Failed to update employee status: $e');
      }
    }
  }

  Future<void> _showUpdateDepartmentDialog(
    BuildContext context,
    EmployeeManagementNotifier employeeManagement,
    String updatedBy,
  ) async {
    final departmentController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Update Department'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Update department for $selectedCount employee${selectedCount > 1 ? 's' : ''}:',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: departmentController,
                  decoration: const InputDecoration(
                    labelText: 'New Department',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final department = departmentController.text.trim();
                  if (department.isNotEmpty) {
                    Navigator.of(context).pop(department);
                  }
                },
                child: const Text('Update'),
              ),
            ],
          ),
    );

    if (result != null && result.isNotEmpty) {
      await _bulkUpdateDepartment(
        context,
        employeeManagement,
        result,
        updatedBy,
      );
    }
  }

  Future<void> _bulkUpdateDepartment(
    BuildContext context,
    EmployeeManagementNotifier employeeManagement,
    String department,
    String updatedBy,
  ) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Updating departments...'),
                ],
              ),
            ),
      );

      final success = await employeeManagement.bulkUpdateEmployees(
        employeeIds: selectedEmployeeIds,
        updates: {'department': department},
        updatedBy: updatedBy,
      );
      // Audit log for department update (bulk)
      if (success) {
        for (final employeeId in selectedEmployeeIds) {
          await AuditLogService().logEvent(
            action: 'EMPLOYEE_DEPARTMENT_UPDATE',
            userId: updatedBy,
            status: 'success',
            targetType: 'employee',
            targetId: employeeId,
            details: {
              'newDepartment': department,
              'reason': 'Bulk department update',
            },
          );
        }
      }

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Updated department for $selectedCount employees'),
              backgroundColor: Colors.green,
            ),
          );
          onClearSelection();
        } else {
          _showError(context, 'Failed to update departments');
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showError(context, 'Failed to update departments: $e');
      }
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    EmployeeManagementNotifier employeeManagement,
    String deletedBy,
  ) async {
    final confirmed = await _showConfirmationDialog(
      context,
      'Delete Employees',
      'Are you sure you want to delete $selectedCount employee${selectedCount > 1 ? 's' : ''}? This action cannot be undone.',
      isDestructive: true,
    );

    if (!confirmed) return;

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Deleting employees...'),
                ],
              ),
            ),
      );

      // Delete each employee
      int successCount = 0;
      for (final employeeId in selectedEmployeeIds) {
        final success = await employeeManagement.deleteEmployee(
          employeeId: employeeId,
          deletedBy: deletedBy,
          reason: 'Bulk deletion',
        );
        if (success) successCount++;
        // Audit log for employee deletion
        if (success) {
          await AuditLogService().logEvent(
            action: 'EMPLOYEE_DELETE',
            userId: deletedBy,
            status: 'success',
            targetType: 'employee',
            targetId: employeeId,
            details: {'reason': 'Bulk deletion'},
          );
        }
      }

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        if (successCount == selectedEmployeeIds.length) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deleted $successCount employees'),
              backgroundColor: Colors.green,
            ),
          );
          onClearSelection();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Deleted $successCount out of ${selectedEmployeeIds.length} employees',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showError(context, 'Failed to delete employees: $e');
      }
    }
  }

  Future<bool> _showConfirmationDialog(
    BuildContext context,
    String title,
    String message, {
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style:
                    isDestructive
                        ? ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        )
                        : null,
                child: Text(isDestructive ? 'Delete' : 'Confirm'),
              ),
            ],
          ),
    );

    return result ?? false;
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
