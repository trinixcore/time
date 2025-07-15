import 'package:flutter/material.dart';
import '../../../../core/models/employee.dart';
import '../../../../core/enums/employee_status.dart';

class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final bool isSelected;
  final VoidCallback? onTap;
  final Function(bool)? onSelect;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(EmployeeStatus)? onStatusChange;

  const EmployeeCard({
    super.key,
    required this.employee,
    this.isSelected = false,
    this.onTap,
    this.onSelect,
    this.onEdit,
    this.onDelete,
    this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 4 : 1,
      color:
          isSelected
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
              : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (onSelect != null)
                    Checkbox(
                      value: isSelected,
                      onChanged: (value) => onSelect!(value ?? false),
                    ),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: _getStatusColor(employee.status),
                    child: Text(
                      employee.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.fullName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          employee.employeeId,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(),
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder:
                          (context) => [
                            if (onEdit != null)
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 16),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                            if (onDelete != null)
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      size: 16,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildInfoItem(Icons.email, employee.email)),
                  if (employee.phoneNumber != null)
                    Expanded(
                      child: _buildInfoItem(Icons.phone, employee.phoneNumber!),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.business,
                      employee.department ?? 'No Department',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.work,
                      employee.designation ?? 'No Designation',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.badge,
                      employee.role.displayName,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.calendar_today,
                      employee.joiningDate != null
                          ? 'Joined ${_formatDate(employee.joiningDate!)}'
                          : 'No joining date',
                    ),
                  ),
                ],
              ),
              if (onStatusChange != null) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Status:',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        spacing: 4,
                        children:
                            EmployeeStatus.values.map((status) {
                              final isSelected = status == employee.status;
                              return FilterChip(
                                label: Text(
                                  status.displayName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected ? Colors.white : null,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected && status != employee.status) {
                                    onStatusChange!(status);
                                  }
                                },
                                backgroundColor: _getStatusColor(
                                  status,
                                ).withOpacity(0.1),
                                selectedColor: _getStatusColor(status),
                              );
                            }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(employee.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor(employee.status), width: 1),
      ),
      child: Text(
        employee.status.displayName,
        style: TextStyle(
          color: _getStatusColor(employee.status),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(EmployeeStatus status) {
    switch (status) {
      case EmployeeStatus.active:
        return Colors.green;
      case EmployeeStatus.inactive:
        return Colors.grey;
      case EmployeeStatus.onLeave:
        return Colors.orange;
      case EmployeeStatus.terminated:
        return Colors.red;
      case EmployeeStatus.probation:
        return Colors.blue;
      case EmployeeStatus.suspended:
        return Colors.purple;
      case EmployeeStatus.notice:
        return Colors.amber;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }
}
