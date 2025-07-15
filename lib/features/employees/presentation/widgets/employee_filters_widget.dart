import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/employee_provider.dart';
import '../../../../core/enums/employee_status.dart';
import '../../../../core/enums/user_role.dart';

class EmployeeFiltersWidget extends ConsumerWidget {
  const EmployeeFiltersWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(employeeFiltersProvider);
    final filtersNotifier = ref.read(employeeFiltersProvider.notifier);

    return Row(
      children: [
        // Status filter
        Expanded(
          child: DropdownButtonFormField<EmployeeStatus?>(
            value: filters.status,
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: [
              const DropdownMenuItem<EmployeeStatus?>(
                value: null,
                child: Text('All Statuses'),
              ),
              ...EmployeeStatus.values.map(
                (status) => DropdownMenuItem(
                  value: status,
                  child: Text(status.displayName),
                ),
              ),
            ],
            onChanged: filtersNotifier.updateStatus,
          ),
        ),
        const SizedBox(width: 8),

        // Role filter
        Expanded(
          child: DropdownButtonFormField<UserRole?>(
            value: filters.role,
            decoration: const InputDecoration(
              labelText: 'Role',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: [
              const DropdownMenuItem<UserRole?>(
                value: null,
                child: Text('All Roles'),
              ),
              ...UserRole.values.map(
                (role) => DropdownMenuItem(
                  value: role,
                  child: Text(role.displayName),
                ),
              ),
            ],
            onChanged: filtersNotifier.updateRole,
          ),
        ),
        const SizedBox(width: 8),

        // Clear filters button
        if (filters.hasFilters)
          IconButton(
            onPressed: filtersNotifier.clearFilters,
            icon: const Icon(Icons.clear),
            tooltip: 'Clear filters',
          ),
      ],
    );
  }
}
