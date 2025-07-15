import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../dashboard/ui/dashboard_scaffold.dart';
import '../../../shared/widgets/custom_loader.dart';
import '../providers/task_providers.dart';
import '../../../core/enums/task_status.dart';
import '../../../core/models/task_model.dart';
import '../../../core/models/task_time_log_model.dart';
import 'widgets/task_comments_widget.dart';
import 'widgets/task_watchers_widget.dart';
import 'widgets/task_time_logging_widget.dart';
import 'widgets/task_progress_widget.dart';
import 'widgets/task_document_upload_widget.dart';
import '../../../core/providers/performance_providers.dart';
import '../../../shared/providers/auth_providers.dart';

class TaskDetailPage extends ConsumerWidget {
  final String taskId;
  const TaskDetailPage({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final taskAsync = ref.watch(taskByIdProvider(taskId));
    final canAccessAsync = ref.watch(canAccessTaskProvider(taskId));
    final timeLogsAsync = ref.watch(taskTimeLogsProvider(taskId));

    return DashboardScaffold(
      currentPath: '/tasks/$taskId',
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(Icons.task_alt, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              const Text('Task Details'),
            ],
          ),
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            OutlinedButton.icon(
              onPressed: () => context.go('/tasks'),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to List'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                side: BorderSide(color: theme.colorScheme.primary),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: canAccessAsync.when(
          data: (canAccess) {
            if (!canAccess) {
              return const Center(child: Text('Access denied.'));
            }
            return taskAsync.when(
              data: (task) {
                if (task == null) {
                  return const Center(child: Text('Task not found.'));
                }
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 1100;
                    final mainContent =
                        isWide
                            ? SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(minWidth: 1100),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // LEFT COLUMN (2/3)
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 800,
                                      ),
                                      child: SizedBox(
                                        width: 800,
                                        child: _TaskDetailsLeftColumn(
                                          task: task,
                                          theme: theme,
                                          ref: ref,
                                          timeLogsAsync:
                                              timeLogsAsync
                                                  as AsyncValue<
                                                    List<TaskTimeLogModel>
                                                  >,
                                          getStatusColor: _getStatusColor,
                                          getPriorityColor: _getPriorityColor,
                                          buildDeliveryRiskIndicator:
                                              _buildDeliveryRiskIndicator,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 32),
                                    // RIGHT COLUMN (1/3)
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 370,
                                        minWidth: 320,
                                      ),
                                      child: SizedBox(
                                        width: 370,
                                        child: _TaskDetailsRightColumn(
                                          task: task,
                                          theme: theme,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _TaskDetailsLeftColumn(
                                  task: task,
                                  theme: theme,
                                  ref: ref,
                                  timeLogsAsync:
                                      timeLogsAsync
                                          as AsyncValue<List<TaskTimeLogModel>>,
                                  getStatusColor: _getStatusColor,
                                  getPriorityColor: _getPriorityColor,
                                  buildDeliveryRiskIndicator:
                                      _buildDeliveryRiskIndicator,
                                ),
                                const SizedBox(height: 24),
                                _TaskDetailsRightColumn(
                                  task: task,
                                  theme: theme,
                                ),
                              ],
                            );
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      scrollDirection: Axis.vertical,
                      child: mainContent,
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
              (err, _) => Center(
                child: Text(
                  'Error checking access: $err',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
        ),
      ),
    );
  }

  Color _getStatusColor(TaskStatus status, ThemeData theme) {
    switch (status) {
      case TaskStatus.todo:
        return theme.colorScheme.outline;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.cancelled:
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.outline;
    }
  }

  Color _getPriorityColor(dynamic priority, ThemeData theme) {
    final priorityStr = priority.toString().split('.').last;
    switch (priorityStr) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'critical':
      case 'urgent':
        return Colors.red.shade700;
      default:
        return theme.colorScheme.outline;
    }
  }

  Widget _buildDeliveryRiskIndicator(TaskModel task, ThemeData theme) {
    final riskLevel = task.deliveryRisk;
    Color riskColor;
    IconData riskIcon;

    switch (riskLevel) {
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: riskColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: riskColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(riskIcon, color: riskColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery Risk: $riskLevel',
                  style: TextStyle(
                    color: riskColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (task.lastProgressUpdate != null)
                  Text(
                    'Last updated: ${task.lastProgressUpdate!.toLocal().toString().split('.')[0]}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _InfoChip({required this.label, required this.value, this.color});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
      backgroundColor:
          color?.withOpacity(0.1) ?? theme.colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }
}

class _TaskDetailsLeftColumn extends ConsumerWidget {
  final TaskModel task;
  final ThemeData theme;
  final WidgetRef ref;
  final AsyncValue<List<TaskTimeLogModel>> timeLogsAsync;
  final Color Function(TaskStatus, ThemeData) getStatusColor;
  final Color Function(dynamic, ThemeData) getPriorityColor;
  final Widget Function(TaskModel, ThemeData) buildDeliveryRiskIndicator;
  const _TaskDetailsLeftColumn({
    Key? key,
    required this.task,
    required this.theme,
    required this.ref,
    required this.timeLogsAsync,
    required this.getStatusColor,
    required this.getPriorityColor,
    required this.buildDeliveryRiskIndicator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Task Title & Subtitle
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.task, color: theme.colorScheme.primary, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Task ID: ${task.id}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Task Info Grid
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Task Information',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 32,
                  runSpacing: 12,
                  children: [
                    _InfoChip(
                      label: 'Status',
                      value: task.status.displayName,
                      color: getStatusColor(task.status, theme),
                    ),
                    _InfoChip(
                      label: 'Priority',
                      value: task.priority.displayName,
                      color: getPriorityColor(task.priority, theme),
                    ),
                    _InfoChip(
                      label: 'Due Date',
                      value: task.dueDate.toLocal().toString().split(' ')[0],
                      color: task.isOverdue ? theme.colorScheme.error : null,
                    ),
                    _InfoChip(
                      label: 'Category',
                      value: task.category ?? '-',
                      color: theme.colorScheme.primaryContainer,
                    ),
                    _InfoChip(
                      label: 'Estimated Hours',
                      value:
                          task.estimatedHours > 0
                              ? '${task.estimatedHours}h'
                              : '-',
                      color: theme.colorScheme.surfaceVariant,
                    ),
                    _InfoChip(
                      label: 'Actual Hours',
                      value:
                          task.actualHours > 0 ? '${task.actualHours}h' : '-',
                      color: theme.colorScheme.surfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Assigned to (show name and employeeId)
                Row(
                  children: [
                    Icon(Icons.person, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ref
                          .watch(optimizedUsersDataProvider)
                          .when(
                            data: (usersData) {
                              final activeUsers = usersData['active'] ?? [];
                              final pendingUsers = usersData['pending'] ?? [];
                              final terminatedUsers =
                                  usersData['terminated'] ?? [];
                              final allUsers = [
                                ...activeUsers,
                                ...pendingUsers,
                                ...terminatedUsers,
                              ];
                              final userDoc = allUsers.firstWhere(
                                (u) => u.id == task.assignedTo,
                                orElse: () => null,
                              );
                              if (userDoc != null) {
                                final userData =
                                    userDoc.data() as Map<String, dynamic>?;
                                final name =
                                    userData?['name'] ??
                                    userData?['displayName'] ??
                                    'Unknown';
                                final employeeId =
                                    userData?['employeeId'] ?? '';
                                return Text(
                                  employeeId.isNotEmpty
                                      ? '$name ($employeeId)'
                                      : name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              } else {
                                return Text(
                                  task.assignedTo,
                                  style: theme.textTheme.bodyMedium,
                                );
                              }
                            },
                            loading:
                                () => Text(
                                  'Loading...',
                                  style: theme.textTheme.bodyMedium,
                                ),
                            error:
                                (err, _) => Text(
                                  'Error',
                                  style: theme.textTheme.bodyMedium,
                                ),
                          ),
                    ),
                    Consumer(
                      builder: (context, ref, _) {
                        final currentUserAsync = ref.watch(currentUserProvider);
                        return currentUserAsync.when(
                          data: (currentUser) {
                            if (currentUser != null &&
                                currentUser.uid == task.createdBy) {
                              return IconButton(
                                icon: const Icon(Icons.swap_horiz),
                                tooltip: 'Reassign Task',
                                onPressed: () async {
                                  final newAssignee = await showDialog<String>(
                                    context: context,
                                    builder:
                                        (context) => _ReassignTaskDialog(
                                          taskId: task.id,
                                          currentAssignee: task.assignedTo,
                                        ),
                                  );
                                  if (newAssignee != null &&
                                      newAssignee != task.assignedTo) {
                                    await ref
                                        .read(
                                          taskAssigneeUpdateProvider.notifier,
                                        )
                                        .updateAssignee(task.id, newAssignee);
                                  }
                                },
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Progress & Delivery Risk
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.trending_up, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Progress & Delivery Risk',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Progress', style: theme.textTheme.bodyMedium),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: task.progressPercentage / 100,
                            backgroundColor: theme.colorScheme.surfaceVariant,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              task.progressPercentage >= 100
                                  ? Colors.green
                                  : theme.colorScheme.primary,
                            ),
                            minHeight: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${task.progressPercentage}%',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                buildDeliveryRiskIndicator(task, theme),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Description
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.description, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Description',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(task.description, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Actions
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.settings, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Actions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<TaskStatus>(
                        value: task.status,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items:
                            TaskStatus.values
                                .map(
                                  (status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status.displayName),
                                  ),
                                )
                                .toList(),
                        onChanged: (newStatus) {
                          if (newStatus != null && newStatus != task.status) {
                            ref
                                .read(taskStatusUpdateProvider.notifier)
                                .updateStatus(task.id, newStatus);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    TaskTimeLoggingWidget(
                      taskId: task.id,
                      taskTitle: task.title,
                    ),
                    const SizedBox(width: 16),
                    TaskProgressWidget(
                      taskId: task.id,
                      taskTitle: task.title,
                      currentProgress: task.progressPercentage.toInt(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Time Logs
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Time Logs',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                timeLogsAsync.when(
                  data:
                      (logs) =>
                          logs.isEmpty
                              ? Text(
                                'No time logs yet.',
                                style: theme.textTheme.bodyMedium,
                              )
                              : Column(
                                children:
                                    logs.map((log) {
                                      final timeLog = log as TaskTimeLogModel;
                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: theme
                                              .colorScheme
                                              .surfaceVariant
                                              .withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              size: 18,
                                              color: theme.colorScheme.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                '${(timeLog.durationMinutes / 60).toStringAsFixed(1)}h - ${timeLog.description ?? ''}',
                                                style:
                                                    theme.textTheme.bodyMedium,
                                              ),
                                            ),
                                            Text(
                                              timeLog.userName,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color:
                                                        theme
                                                            .colorScheme
                                                            .outline,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                              ),
                  loading: () => const LinearProgressIndicator(),
                  error:
                      (err, _) => Text(
                        'Error: $err',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Comments
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.comment, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Comments',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TaskCommentsWidget(taskId: task.id),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TaskDetailsRightColumn extends ConsumerWidget {
  final TaskModel task;
  final ThemeData theme;
  const _TaskDetailsRightColumn({
    Key? key,
    required this.task,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Observers
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.visibility, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Observers',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TaskWatchersWidget(task: task),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Documents
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.attach_file, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Documents',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TaskDocumentUploadWidget(
                  taskId: task.id,
                  taskTitle: task.title,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReassignTaskDialog extends ConsumerStatefulWidget {
  final String taskId;
  final String currentAssignee;
  const _ReassignTaskDialog({
    required this.taskId,
    required this.currentAssignee,
  });

  @override
  ConsumerState<_ReassignTaskDialog> createState() =>
      _ReassignTaskDialogState();
}

class _ReassignTaskDialogState extends ConsumerState<_ReassignTaskDialog> {
  String? _selectedAssignee;
  String _search = '';
  bool _showDropdown = false;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(activeUsersProvider);
    return AlertDialog(
      title: const Text('Reassign Task'),
      content: usersAsync.when(
        data: (users) {
          final filtered =
              users.where((u) {
                final uid = u['uid'] ?? u['id'] ?? '';
                final name =
                    (u['name'] ?? u['displayName'] ?? '')
                        .toString()
                        .toLowerCase();
                final email = (u['email'] ?? '').toString().toLowerCase();
                final empId = (u['employeeId'] ?? '').toString().toLowerCase();
                return (name.contains(_search) ||
                        email.contains(_search) ||
                        empId.contains(_search)) &&
                    uid != widget.currentAssignee;
              }).toList();
          return SizedBox(
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Search user',
                    hintText: 'Type name, email, or employee ID',
                  ),
                  onChanged: (val) {
                    setState(() {
                      _search = val.toLowerCase();
                      _showDropdown = val.isNotEmpty;
                    });
                  },
                ),
                if (_showDropdown)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child:
                        filtered.isEmpty
                            ? const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('No users found'),
                            )
                            : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filtered.length,
                              itemBuilder: (context, idx) {
                                final user = filtered[idx];
                                final uid = user['uid'] ?? user['id'] ?? '';
                                final name =
                                    user['name'] ??
                                    user['displayName'] ??
                                    'Unknown';
                                final empId = user['employeeId'] ?? '';
                                final email = user['email'] ?? '';
                                return ListTile(
                                  title: Text(
                                    empId.isNotEmpty ? '$name ($empId)' : name,
                                  ),
                                  subtitle: Text(email),
                                  onTap: () {
                                    setState(() {
                                      _selectedAssignee = uid;
                                      _controller.text = name;
                                      _showDropdown = false;
                                    });
                                  },
                                  selected: _selectedAssignee == uid,
                                );
                              },
                            ),
                  ),
              ],
            ),
          );
        },
        loading:
            () => const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            ),
        error:
            (_, __) => const SizedBox(
              height: 120,
              child: Center(child: Text('Error loading users')),
            ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
              _selectedAssignee != null
                  ? () => Navigator.of(context).pop(_selectedAssignee)
                  : null,
          child: const Text('Reassign'),
        ),
      ],
    );
  }
}
