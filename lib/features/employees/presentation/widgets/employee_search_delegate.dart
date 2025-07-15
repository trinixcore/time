import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/employee.dart';
import '../../../../core/providers/employee_provider.dart';

class EmployeeSearchDelegate extends SearchDelegate<Employee?> {
  final WidgetRef ref;

  EmployeeSearchDelegate(this.ref);

  @override
  String get searchFieldLabel => 'Search employees...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Start typing to search employees...'));
    }
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return Consumer(
      builder: (context, ref, child) {
        final employeesAsync = ref.watch(
          employeeListProvider(const EmployeeFilters()),
        );

        return employeesAsync.when(
          data: (employees) {
            final filteredEmployees =
                employees.where((employee) {
                  final searchLower = query.toLowerCase();
                  return employee.fullName.toLowerCase().contains(
                        searchLower,
                      ) ||
                      employee.email.toLowerCase().contains(searchLower) ||
                      employee.employeeId.toLowerCase().contains(searchLower) ||
                      (employee.department?.toLowerCase().contains(
                            searchLower,
                          ) ??
                          false) ||
                      (employee.designation?.toLowerCase().contains(
                            searchLower,
                          ) ??
                          false);
                }).toList();

            if (filteredEmployees.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No employees found for "$query"',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: filteredEmployees.length,
              itemBuilder: (context, index) {
                final employee = filteredEmployees[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        employee.profileImageUrl != null
                            ? NetworkImage(employee.profileImageUrl!)
                            : null,
                    child:
                        employee.profileImageUrl == null
                            ? Text(employee.initials)
                            : null,
                  ),
                  title: Text(employee.fullName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(employee.employeeId),
                      if (employee.department != null)
                        Text(
                          '${employee.department} • ${employee.designation ?? 'N/A'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(
                      employee.status.displayName,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor:
                        employee.status.isActive
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                  ),
                  onTap: () {
                    close(context, employee);
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (error, stack) =>
                  Center(child: Text('Error searching employees: $error')),
        );
      },
    );
  }
}
