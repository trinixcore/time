import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audit_log_providers.dart';

class AuditLogFilters extends ConsumerWidget {
  final String? selectedAction;
  final String? selectedTargetType;
  final String? selectedStatus;
  final String? selectedUser;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function({
    String? action,
    String? targetType,
    String? status,
    String? user,
    DateTime? startDate,
    DateTime? endDate,
  })
  onFiltersChanged;
  final VoidCallback onClearFilters;

  const AuditLogFilters({
    super.key,
    this.selectedAction,
    this.selectedTargetType,
    this.selectedStatus,
    this.selectedUser,
    this.startDate,
    this.endDate,
    required this.onFiltersChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterOptions = ref.watch(auditLogFilterOptionsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list, color: Color(0xFF1565C0)),
              const SizedBox(width: 8),
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Clear All'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 16),
          filterOptions.when(
            data: (options) => _buildFilterGrid(context, options),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Error loading filter options'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterGrid(
    BuildContext context,
    Map<String, List<String>> options,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDropdownFilter(
                'Action',
                selectedAction,
                options['actions'] ?? [],
                (value) => onFiltersChanged(action: value),
                Icons.security,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdownFilter(
                'Target Type',
                selectedTargetType,
                options['targetTypes'] ?? [],
                (value) => onFiltersChanged(targetType: value),
                Icons.category,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDropdownFilter(
                'Status',
                selectedStatus,
                options['statuses'] ?? [],
                (value) => onFiltersChanged(status: value),
                Icons.info,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdownFilter(
                'User',
                selectedUser,
                options['users'] ?? [],
                (value) => onFiltersChanged(user: value),
                Icons.person,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateFilter(
                'Start Date',
                startDate,
                (date) => onFiltersChanged(startDate: date),
                Icons.calendar_today,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateFilter(
                'End Date',
                endDate,
                (date) => onFiltersChanged(endDate: date),
                Icons.calendar_today,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownFilter(
    String label,
    String? selectedValue,
    List<String> options,
    Function(String?) onChanged,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        items: [
          const DropdownMenuItem<String>(value: null, child: Text('All')),
          ...options.map(
            (option) =>
                DropdownMenuItem<String>(value: option, child: Text(option)),
          ),
        ],
        dropdownColor: Colors.white,
      ),
    );
  }

  Widget _buildDateFilter(
    String label,
    DateTime? selectedDate,
    Function(DateTime?) onChanged,
    IconData icon,
  ) {
    return Builder(
      builder:
          (context) => InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                onChanged(date);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedDate != null
                          ? '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}'
                          : label,
                      style: TextStyle(
                        color:
                            selectedDate != null
                                ? Colors.black87
                                : Colors.grey[600],
                      ),
                    ),
                  ),
                  if (selectedDate != null)
                    IconButton(
                      onPressed: () => onChanged(null),
                      icon: const Icon(Icons.clear, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                    ),
                ],
              ),
            ),
          ),
    );
  }
}
