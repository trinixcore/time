import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../dashboard/ui/dashboard_scaffold.dart';
import '../../../shared/widgets/custom_loader.dart';
import '../providers/task_providers.dart';
import '../../../core/enums/task_status.dart';
import '../../../core/enums/priority_level.dart';
import '../../../core/models/task_model.dart';
import 'task_creation_modal.dart';
import '../../../core/providers/performance_providers.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../core/providers/permission_providers.dart';
import 'dart:html' as html;
import 'dart:convert';

class TaskListPage extends ConsumerStatefulWidget {
  const TaskListPage({super.key});

  @override
  ConsumerState<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends ConsumerState<TaskListPage> {
  String? _selectedDepartment;
  String? _selectedProject;
  TaskStatus? _selectedStatus;
  PriorityLevel? _selectedPriority;
  String? _searchQuery;
  DateTime? _startDate;
  DateTime? _endDate;

  void _openTaskCreationModal() async {
    await showDialog(
      context: context,
      builder: (context) => const TaskCreationModal(),
    );
    // Optionally refresh tasks after creation
    ref.invalidate(filteredTasksProvider);
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder:
          (context) => _TaskExportDialog(
            tasks: ref.read(
              filteredTasksProvider(
                departmentId: _selectedDepartment,
                projectId: _selectedProject,
                status: _selectedStatus,
                priority: _selectedPriority,
                searchQuery: _searchQuery,
                startDate: _startDate,
                endDate: _endDate,
              ),
            ),
          ),
    );
  }

  Future<void> _deleteTask(String taskId, String taskTitle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Task'),
            content: Text(
              'Are you sure you want to delete "$taskTitle"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final deleteProvider = ref.read(taskDeleteProvider.notifier);
      final success = await deleteProvider.deleteTask(taskId);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Task deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to delete task'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _pickEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final departmentsAsync = ref.watch(departmentsProvider);
    final projectsAsync =
        _selectedDepartment != null
            ? ref.watch(projectsByDepartmentProvider(_selectedDepartment!))
            : const AsyncValue.data([]);
    final tasksAsync = ref.watch(
      filteredTasksProvider(
        departmentId: _selectedDepartment,
        projectId: _selectedProject,
        status: _selectedStatus,
        priority: _selectedPriority,
        searchQuery: _searchQuery,
        startDate: _startDate,
        endDate: _endDate,
      ),
    );
    final usersAsync = ref.watch(optimizedUsersDataProvider);

    return DashboardScaffold(
      currentPath: '/tasks',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Task Management'),
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            const SizedBox(width: 16),
            OutlinedButton.icon(
              onPressed: _showExportDialog,
              icon: const Icon(Icons.download),
              label: const Text('Export'),
            ),
            const SizedBox(width: 16),
            // Create Task button with permission check
            Consumer(
              builder: (context, ref, child) {
                final currentUser = ref.watch(currentUserProvider).value;
                final userRole = currentUser?.role;

                if (userRole == null) return const SizedBox.shrink();

                final permissionConfig = ref.watch(
                  permissionConfigProvider(userRole),
                );

                return permissionConfig.when(
                  data: (config) {
                    if (config?.systemConfig.canCreateTasks == true) {
                      return FilledButton.icon(
                        onPressed: _openTaskCreationModal,
                        icon: const Icon(Icons.add_task),
                        label: const Text('Create Task'),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filters
              Row(
                children: [
                  // Department Dropdown
                  departmentsAsync.when(
                    data:
                        (departments) => DropdownButton<String>(
                          value: _selectedDepartment,
                          hint: const Text('Department'),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('All Departments'),
                            ),
                            ...departments.map(
                              (d) => DropdownMenuItem(value: d, child: Text(d)),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedDepartment = value;
                              _selectedProject = null;
                            });
                          },
                        ),
                    loading:
                        () => const SizedBox(
                          width: 120,
                          child: LinearProgressIndicator(),
                        ),
                    error:
                        (_, __) => const SizedBox(
                          width: 120,
                          child: Icon(Icons.error),
                        ),
                  ),
                  const SizedBox(width: 16),
                  // Project Dropdown
                  projectsAsync.when(
                    data:
                        (projects) => DropdownButton<String>(
                          value: _selectedProject,
                          hint: const Text('Project'),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('All Projects'),
                            ),
                            ...projects.map(
                              (p) => DropdownMenuItem(
                                value: p.id,
                                child: Text(p.name),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedProject = value;
                            });
                          },
                        ),
                    loading:
                        () => const SizedBox(
                          width: 120,
                          child: LinearProgressIndicator(),
                        ),
                    error:
                        (_, __) => const SizedBox(
                          width: 120,
                          child: Icon(Icons.error),
                        ),
                  ),
                  const SizedBox(width: 16),
                  // Status Dropdown
                  DropdownButton<TaskStatus?>(
                    value: _selectedStatus,
                    hint: const Text('Status'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Statuses'),
                      ),
                      ...TaskStatus.values.map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.displayName),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                  const SizedBox(width: 16),
                  // Priority Dropdown
                  DropdownButton<PriorityLevel?>(
                    value: _selectedPriority,
                    hint: const Text('Priority'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Priorities'),
                      ),
                      ...PriorityLevel.values.map(
                        (p) => DropdownMenuItem(
                          value: p,
                          child: Text(p.displayName),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPriority = value;
                      });
                    },
                  ),
                  const SizedBox(width: 16),
                  // Search
                  SizedBox(
                    width: 200,
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search tasks...',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Date Range Filter
                  Row(
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.date_range),
                        label: Text(
                          _startDate == null
                              ? 'Start Date'
                              : '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}',
                        ),
                        onPressed: () => _pickStartDate(context),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.date_range),
                        label: Text(
                          _endDate == null
                              ? 'End Date'
                              : '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}',
                        ),
                        onPressed:
                            _startDate != null
                                ? () => _pickEndDate(context)
                                : null,
                      ),
                      if (_startDate != null || _endDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          tooltip: 'Clear date range',
                          onPressed:
                              () => setState(() {
                                _startDate = null;
                                _endDate = null;
                              }),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Task List
              Expanded(
                child: usersAsync.when(
                  data: (usersData) {
                    final activeUsers = usersData['active'] ?? [];
                    final pendingUsers = usersData['pending'] ?? [];
                    final terminatedUsers = usersData['terminated'] ?? [];
                    final allUsers = [
                      ...activeUsers,
                      ...pendingUsers,
                      ...terminatedUsers,
                    ];
                    return tasksAsync.when(
                      data: (tasks) {
                        if (tasks.isEmpty) {
                          return Center(
                            child: Text(
                              'No tasks found. Try adjusting your filters or create a new task.',
                              style: theme.textTheme.bodyLarge,
                            ),
                          );
                        }
                        return ListView.separated(
                          itemCount: tasks.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            // Determine risk color and icon
                            Color riskColor;
                            IconData riskIcon;
                            switch (task.deliveryRisk) {
                              case 'Completed':
                                riskColor = Colors.green;
                                riskIcon = Icons.check_circle;
                                break;
                              case 'On Track':
                                riskColor = Colors.green;
                                riskIcon = Icons.trending_up;
                                break;
                              case 'Low Risk':
                                riskColor = Colors.orange;
                                riskIcon = Icons.warning;
                                break;
                              case 'Medium Risk':
                                riskColor = Colors.deepOrange;
                                riskIcon = Icons.warning;
                                break;
                              case 'High Risk':
                                riskColor = Colors.red;
                                riskIcon = Icons.error;
                                break;
                              case 'Overdue':
                                riskColor = Colors.red;
                                riskIcon = Icons.schedule;
                                break;
                              default:
                                riskColor = Colors.grey;
                                riskIcon = Icons.help;
                            }
                            // Focus highlight: high/medium risk, overdue, or in progress/todo
                            final isFocus =
                                task.deliveryRisk == 'High Risk' ||
                                task.deliveryRisk == 'Overdue' ||
                                task.status == TaskStatus.inProgress ||
                                task.status == TaskStatus.todo;
                            final userDoc = allUsers.firstWhere(
                              (u) => u.id == task.assignedTo,
                              orElse: () => null,
                            );
                            String assignedDisplay;
                            if (userDoc != null) {
                              final userData =
                                  userDoc.data() as Map<String, dynamic>?;
                              final name =
                                  userData?['name'] ??
                                  userData?['displayName'] ??
                                  'Unknown';
                              final employeeId = userData?['employeeId'] ?? '';
                              assignedDisplay =
                                  employeeId.isNotEmpty
                                      ? '$name ($employeeId)'
                                      : name;
                            } else {
                              assignedDisplay = task.assignedTo;
                            }
                            return InkWell(
                              onTap: () => context.go('/tasks/${task.id}'),
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                decoration: BoxDecoration(
                                  color:
                                      isFocus
                                          ? riskColor.withOpacity(0.08)
                                          : theme.cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color:
                                        isFocus
                                            ? riskColor
                                            : theme.dividerColor,
                                    width: isFocus ? 2 : 1,
                                  ),
                                  boxShadow: [
                                    if (isFocus)
                                      BoxShadow(
                                        color: riskColor.withOpacity(0.15),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                  horizontal: 20,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Risk color bar/dot
                                    Container(
                                      width: 8,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: riskColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 18),
                                    // Main info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                task.title,
                                                style: theme
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          isFocus
                                                              ? riskColor
                                                              : null,
                                                    ),
                                              ),
                                              const SizedBox(width: 8),
                                              if (isFocus)
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: riskColor
                                                        .withOpacity(0.15),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        riskIcon,
                                                        color: riskColor,
                                                        size: 16,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        task.deliveryRisk,
                                                        style: TextStyle(
                                                          color: riskColor,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today,
                                                size: 16,
                                                color:
                                                    theme.colorScheme.outline,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Due: ${task.dueDate.toLocal().toString().split(' ')[0]}',
                                                style:
                                                    theme.textTheme.bodySmall,
                                              ),
                                              const SizedBox(width: 16),
                                              Icon(
                                                Icons.flag,
                                                size: 16,
                                                color:
                                                    theme.colorScheme.outline,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Priority: ${task.priority.displayName}',
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color:
                                                      task.priority.displayName ==
                                                                  'High' ||
                                                              task
                                                                      .priority
                                                                      .displayName ==
                                                                  'Urgent' ||
                                                              task
                                                                      .priority
                                                                      .displayName ==
                                                                  'Critical'
                                                          ? Colors.red
                                                          : null,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Icon(
                                                Icons.person,
                                                size: 16,
                                                color:
                                                    theme.colorScheme.outline,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Assigned: $assignedDisplay',
                                                style:
                                                    theme.textTheme.bodySmall,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.trending_up,
                                                size: 16,
                                                color:
                                                    theme.colorScheme.outline,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Status: ${task.status.displayName}',
                                                style:
                                                    theme.textTheme.bodySmall,
                                              ),
                                              const SizedBox(width: 16),
                                              Icon(
                                                riskIcon,
                                                size: 16,
                                                color: riskColor,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Risk: ${task.deliveryRisk}',
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                      color: riskColor,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Delete button with permission check
                                    Consumer(
                                      builder: (context, ref, child) {
                                        final currentUser =
                                            ref
                                                .watch(currentUserProvider)
                                                .value;
                                        final userRole = currentUser?.role;

                                        if (userRole == null)
                                          return const SizedBox.shrink();

                                        final permissionConfig = ref.watch(
                                          permissionConfigProvider(userRole),
                                        );

                                        return permissionConfig.when(
                                          data: (config) {
                                            if (config
                                                    ?.systemConfig
                                                    .canDeleteTasks ==
                                                true) {
                                              return IconButton(
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                ),
                                                color: Colors.red.shade400,
                                                tooltip: 'Delete Task',
                                                onPressed: () {
                                                  _deleteTask(
                                                    task.id,
                                                    task.title,
                                                  );
                                                },
                                              );
                                            } else {
                                              return const SizedBox.shrink();
                                            }
                                          },
                                          loading:
                                              () => const SizedBox.shrink(),
                                          error:
                                              (_, __) =>
                                                  const SizedBox.shrink(),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.chevron_right,
                                      color: theme.colorScheme.outline,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CustomLoader()),
                      error: (err, _) => Center(child: Text('Error: $err')),
                    );
                  },
                  loading: () => const Center(child: CustomLoader()),
                  error:
                      (err, _) =>
                          Center(child: Text('Error loading users: $err')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskExportDialog extends StatefulWidget {
  final AsyncValue<List<TaskModel>> tasks;

  const _TaskExportDialog({required this.tasks});

  @override
  State<_TaskExportDialog> createState() => _TaskExportDialogState();
}

class _TaskExportDialogState extends State<_TaskExportDialog> {
  final Map<String, bool> _selectedFields = {
    'Title': true,
    'Description': true,
    'Status': true,
    'Priority': true,
    'Assigned To': true,
    'Created By': true,
    'Created Date': true,
    'Due Date': true,
    'Progress': true,
    'Risk Level': true,
    'Department': true,
    'Project': true,
    'Category': false,
    'Tags': false,
    'Estimated Hours': false,
    'Actual Hours': false,
  };

  bool _isExporting = false;

  Future<void> _exportTasks() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final tasks = await widget.tasks.when(
        data: (tasks) => tasks,
        loading: () => <TaskModel>[],
        error: (_, __) => <TaskModel>[],
      );

      if (tasks.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No tasks to export')));
        return;
      }

      // Get user data for name lookups
      final usersAsync = ProviderScope.containerOf(
        context,
      ).read(optimizedUsersDataProvider);
      final usersData = await usersAsync.when(
        data: (data) => data,
        loading:
            () => <String, List>{'active': [], 'pending': [], 'terminated': []},
        error:
            (_, __) => <String, List>{
              'active': [],
              'pending': [],
              'terminated': [],
            },
      );

      final allUsers = [
        ...usersData['active'] ?? [],
        ...usersData['pending'] ?? [],
        ...usersData['terminated'] ?? [],
      ];

      // Generate CSV content
      final csvContent = _generateCSV(tasks, allUsers);

      // Create and download file
      final bytes = utf8.encode(csvContent);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor =
          html.AnchorElement(href: url)
            ..setAttribute(
              'download',
              'tasks_export_${DateTime.now().millisecondsSinceEpoch}.csv',
            )
            ..click();
      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported ${tasks.length} tasks successfully')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  String _generateCSV(List<TaskModel> tasks, List<dynamic> allUsers) {
    final selectedFieldNames =
        _selectedFields.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

    // CSV header
    final csvRows = [selectedFieldNames.join(',')];

    // CSV data rows
    for (final task in tasks) {
      final row = <String>[];

      for (final fieldName in selectedFieldNames) {
        final value = _getFieldValue(task, fieldName, allUsers);
        // Escape CSV values (wrap in quotes if contains comma, quote, or newline)
        final escapedValue = _escapeCSVValue(value);
        row.add(escapedValue);
      }

      csvRows.add(row.join(','));
    }

    return csvRows.join('\n');
  }

  String _getFieldValue(
    TaskModel task,
    String fieldName,
    List<dynamic> allUsers,
  ) {
    switch (fieldName) {
      case 'Title':
        return task.title;
      case 'Description':
        return task.description;
      case 'Status':
        return task.status.displayName;
      case 'Priority':
        return task.priority.displayName;
      case 'Assigned To':
        final userDoc = allUsers.firstWhere(
          (u) => u.id == task.assignedTo,
          orElse: () => null,
        );
        if (userDoc != null) {
          final userData = userDoc.data() as Map<String, dynamic>?;
          final name =
              userData?['name'] ?? userData?['displayName'] ?? 'Unknown';
          final employeeId = userData?['employeeId'] ?? '';
          return employeeId.isNotEmpty ? '$name ($employeeId)' : name;
        }
        return task.assignedTo;
      case 'Created By':
        final userDoc = allUsers.firstWhere(
          (u) => u.id == task.createdBy,
          orElse: () => null,
        );
        if (userDoc != null) {
          final userData = userDoc.data() as Map<String, dynamic>?;
          final name =
              userData?['name'] ?? userData?['displayName'] ?? 'Unknown';
          final employeeId = userData?['employeeId'] ?? '';
          return employeeId.isNotEmpty ? '$name ($employeeId)' : name;
        }
        return task.createdBy;
      case 'Created Date':
        return task.createdAt.toLocal().toString().split(' ')[0];
      case 'Due Date':
        return task.dueDate.toLocal().toString().split(' ')[0];
      case 'Progress':
        return '${task.progressPercentage}%';
      case 'Risk Level':
        return task.deliveryRisk;
      case 'Department':
        return task.departmentId;
      case 'Project':
        return task.projectId;
      case 'Category':
        return task.category ?? '';
      case 'Tags':
        return task.tags.join('; ');
      case 'Estimated Hours':
        return task.estimatedHours?.toString() ?? '';
      case 'Actual Hours':
        return task.actualHours?.toString() ?? '';
      default:
        return '';
    }
  }

  String _escapeCSVValue(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasksCount = widget.tasks.when(
      data: (tasks) => tasks.length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    return AlertDialog(
      title: const Text('Export Tasks'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select fields to export (${tasksCount} tasks)',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children:
                      _selectedFields.entries.map((entry) {
                        return CheckboxListTile(
                          title: Text(entry.key),
                          value: entry.value,
                          onChanged: (value) {
                            setState(() {
                              _selectedFields[entry.key] = value ?? false;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed:
              _selectedFields.values.any((selected) => selected) &&
                      !_isExporting
                  ? _exportTasks
                  : null,
          child:
              _isExporting
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Export'),
        ),
      ],
    );
  }
}
