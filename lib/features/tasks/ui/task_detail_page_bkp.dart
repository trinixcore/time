import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../dashboard/ui/dashboard_scaffold.dart';
import '../../../shared/widgets/custom_loader.dart';
import '../providers/task_providers.dart';
import '../../../core/enums/task_status.dart';
import '../../../core/models/task_model.dart';
import 'widgets/task_comments_widget.dart';
import 'widgets/task_watchers_widget.dart';
import 'widgets/task_time_logging_widget.dart';
import 'widgets/task_progress_widget.dart';
import 'widgets/task_document_upload_widget.dart';
import '../../../core/providers/performance_providers.dart';

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
          title: const Text('Task Details'),
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            TextButton.icon(
              onPressed: () => context.go('/tasks'),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to List'),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: canAccessAsync.when(
          data: (canAccess) {
            if (!canAccess) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 64,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Access Denied',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You don\'t have permission to view this task.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => context.go('/tasks'),
                      child: const Text('Back to Tasks'),
                    ),
                  ],
                ),
              );
            }

            return taskAsync.when(
              data: (task) {
                if (task == null) {
                  return const Center(child: Text('Task not found.'));
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Task Header
                      Row(
                        children: [
                          Icon(
                            Icons.task_alt,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              task.title,
                              style: theme.textTheme.headlineSmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Task Info Cards
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Main Task Info
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                // Task Details Card
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Task Information',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(height: 12),
                                        _InfoRow(
                                          label: 'Status',
                                          value: task.status.displayName,
                                          valueColor: _getStatusColor(
                                            task.status,
                                            theme,
                                          ),
                                        ),
                                        _InfoRow(
                                          label: 'Priority',
                                          value: task.priority.displayName,
                                          valueColor: _getPriorityColor(
                                            task.priority,
                                            theme,
                                          ),
                                        ),
                                        _InfoRow(
                                          label: 'Due Date',
                                          value:
                                              task.dueDate
                                                  .toLocal()
                                                  .toString()
                                                  .split(' ')[0],
                                          valueColor:
                                              task.isOverdue
                                                  ? theme.colorScheme.error
                                                  : null,
                                        ),
                                        // Assigned to (show name and employeeId)
                                        Consumer(
                                          builder: (context, ref, _) {
                                            final usersAsync = ref.watch(
                                              optimizedUsersDataProvider,
                                            );
                                            return usersAsync.when(
                                              data: (usersData) {
                                                final activeUsers =
                                                    usersData['active'] ?? [];
                                                final allUsers = [
                                                  ...activeUsers,
                                                  ...(usersData['pending'] ??
                                                      []),
                                                  ...(usersData['terminated'] ??
                                                      []),
                                                ];
                                                final userDoc = allUsers
                                                    .firstWhere(
                                                      (u) =>
                                                          u.id ==
                                                          task.assignedTo,
                                                      orElse: () => null,
                                                    );
                                                if (userDoc != null) {
                                                  final userData =
                                                      userDoc.data()
                                                          as Map<
                                                            String,
                                                            dynamic
                                                          >?;
                                                  final name =
                                                      userData?['name'] ??
                                                      userData?['displayName'] ??
                                                      'Unknown';
                                                  final employeeId =
                                                      userData?['employeeId'] ??
                                                      '';
                                                  return _InfoRow(
                                                    label: 'Assigned to',
                                                    value:
                                                        employeeId.isNotEmpty
                                                            ? '$name ($employeeId)'
                                                            : name,
                                                  );
                                                } else {
                                                  return _InfoRow(
                                                    label: 'Assigned to',
                                                    value: task.assignedTo,
                                                  );
                                                }
                                              },
                                              loading:
                                                  () => _InfoRow(
                                                    label: 'Assigned to',
                                                    value: 'Loading...',
                                                  ),
                                              error:
                                                  (err, _) => _InfoRow(
                                                    label: 'Assigned to',
                                                    value: 'Error',
                                                  ),
                                            );
                                          },
                                        ),
                                        if (task.category != null)
                                          _InfoRow(
                                            label: 'Category',
                                            value: task.category!,
                                          ),
                                        if (task.estimatedHours > 0)
                                          _InfoRow(
                                            label: 'Estimated Hours',
                                            value: '${task.estimatedHours}h',
                                          ),
                                        if (task.actualHours > 0)
                                          _InfoRow(
                                            label: 'Actual Hours',
                                            value: '${task.actualHours}h',
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Progress and Delivery Risk Card
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Progress & Delivery Risk',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(height: 12),
                                        // Progress Bar
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Progress',
                                                  style:
                                                      theme
                                                          .textTheme
                                                          .bodyMedium,
                                                ),
                                                Text(
                                                  '${task.progressPercentage}%',
                                                  style: theme
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            LinearProgressIndicator(
                                              value:
                                                  task.progressPercentage / 100,
                                              backgroundColor:
                                                  theme
                                                      .colorScheme
                                                      .surfaceVariant,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    task.progressPercentage >=
                                                            100
                                                        ? Colors.green
                                                        : theme
                                                            .colorScheme
                                                            .primary,
                                                  ),
                                            ),
                                            const SizedBox(height: 16),
                                            // Delivery Risk Indicator
                                            _buildDeliveryRiskIndicator(
                                              task,
                                              theme,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Task Description Card
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Description',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          task.description,
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Task Actions Card
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Actions',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            // Status Update
                                            Expanded(
                                              child: DropdownButtonFormField<
                                                TaskStatus
                                              >(
                                                value: task.status,
                                                decoration:
                                                    const InputDecoration(
                                                      labelText: 'Status',
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                                items:
                                                    TaskStatus.values
                                                        .map(
                                                          (s) =>
                                                              DropdownMenuItem(
                                                                value: s,
                                                                child: Text(
                                                                  s.displayName,
                                                                ),
                                                              ),
                                                        )
                                                        .toList(),
                                                onChanged: (newStatus) {
                                                  if (newStatus != null &&
                                                      newStatus !=
                                                          task.status) {
                                                    ref
                                                        .read(
                                                          taskStatusUpdateProvider
                                                              .notifier,
                                                        )
                                                        .updateStatus(
                                                          task.id,
                                                          newStatus,
                                                        );
                                                  }
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            // Manual Time Logging and Progress Tracking
                                            TaskTimeLoggingWidget(
                                              taskId: task.id,
                                              taskTitle: task.title,
                                            ),
                                            const SizedBox(width: 16),
                                            TaskProgressWidget(
                                              taskId: task.id,
                                              taskTitle: task.title,
                                              currentProgress:
                                                  task.progressPercentage
                                                      .toInt(),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Time Logs Card
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        timeLogsAsync.when(
                                          data:
                                              (logs) =>
                                                  logs.isEmpty
                                                      ? Text(
                                                        'No time logs yet.',
                                                        style: theme
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.copyWith(
                                                              color:
                                                                  theme
                                                                      .colorScheme
                                                                      .outline,
                                                            ),
                                                      )
                                                      : Column(
                                                        children:
                                                            logs
                                                                .map(
                                                                  (
                                                                    log,
                                                                  ) => Container(
                                                                    margin:
                                                                        const EdgeInsets.only(
                                                                          bottom:
                                                                              8,
                                                                        ),
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                          12,
                                                                        ),
                                                                    decoration: BoxDecoration(
                                                                      color: theme
                                                                          .colorScheme
                                                                          .surfaceVariant
                                                                          .withOpacity(
                                                                            0.5,
                                                                          ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            8,
                                                                          ),
                                                                    ),
                                                                    child: Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .timer,
                                                                          size:
                                                                              16,
                                                                          color:
                                                                              theme.colorScheme.primary,
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              8,
                                                                        ),
                                                                        Expanded(
                                                                          child: Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                log.userName,
                                                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                                                  fontWeight:
                                                                                      FontWeight.w500,
                                                                                ),
                                                                              ),
                                                                              Text(
                                                                                'Start: ${log.startTime.toLocal().toString().split('.')[0]}',
                                                                                style:
                                                                                    theme.textTheme.bodySmall,
                                                                              ),
                                                                              if (log.endTime !=
                                                                                  null)
                                                                                Text(
                                                                                  'Duration: ${log.formattedDuration}',
                                                                                  style: theme.textTheme.bodySmall?.copyWith(
                                                                                    color:
                                                                                        theme.colorScheme.primary,
                                                                                    fontWeight:
                                                                                        FontWeight.w500,
                                                                                  ),
                                                                                )
                                                                              else
                                                                                Text(
                                                                                  'Active',
                                                                                  style: theme.textTheme.bodySmall?.copyWith(
                                                                                    color:
                                                                                        theme.colorScheme.primary,
                                                                                    fontWeight:
                                                                                        FontWeight.w500,
                                                                                  ),
                                                                                ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                )
                                                                .toList(),
                                                      ),
                                          loading:
                                              () =>
                                                  const LinearProgressIndicator(),
                                          error:
                                              (err, _) => Text(
                                                'Error: $err',
                                                style: TextStyle(
                                                  color:
                                                      theme.colorScheme.error,
                                                ),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Sidebar
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                // Task Watchers Widget
                                TaskWatchersWidget(task: task),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Comments Section
                      TaskCommentsWidget(taskId: task.id),

                      const SizedBox(height: 24),

                      // Task Documents Section
                      TaskDocumentUploadWidget(
                        taskId: task.id,
                        taskTitle: task.title,
                      ),
                    ],
                  ),
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: valueColor,
                fontWeight: valueColor != null ? FontWeight.w500 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
