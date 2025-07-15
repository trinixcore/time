import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../dashboard/ui/dashboard_scaffold.dart';
import '../providers/task_providers.dart';

class TaskAnalyticsPage extends ConsumerWidget {
  const TaskAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final analyticsAsync = ref.watch(taskAnalyticsProvider());

    return DashboardScaffold(
      currentPath: '/tasks/analytics',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Task Analytics'),
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            TextButton.icon(
              onPressed: () => context.go('/tasks'),
              icon: const Icon(Icons.list),
              label: const Text('Task List'),
            ),
            TextButton.icon(
              onPressed: () => context.go('/tasks/calendar'),
              icon: const Icon(Icons.calendar_today),
              label: const Text('Calendar'),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: analyticsAsync.when(
            data: (data) {
              if (data.isEmpty) {
                return const Center(
                  child: Text('No analytics data available.'),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: [
                      _AnalyticsCard(
                        title: 'Total Tasks',
                        value: data['totalTasks'].toString(),
                        icon: Icons.list_alt,
                        color: theme.colorScheme.primary,
                      ),
                      _AnalyticsCard(
                        title: 'Completed',
                        value: data['completedTasks'].toString(),
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                      _AnalyticsCard(
                        title: 'Overdue',
                        value: data['overdueTasks'].toString(),
                        icon: Icons.warning,
                        color: Colors.red,
                      ),
                      _AnalyticsCard(
                        title: 'In Progress',
                        value: data['inProgressTasks'].toString(),
                        icon: Icons.timelapse,
                        color: Colors.orange,
                      ),
                      _AnalyticsCard(
                        title: 'Pending',
                        value: data['pendingTasks'].toString(),
                        icon: Icons.hourglass_empty,
                        color: Colors.blueGrey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Completion Rate
                  Text('Completion Rate', style: theme.textTheme.titleMedium),
                  LinearProgressIndicator(
                    value: (data['completionRate'] ?? 0) / 100.0,
                    minHeight: 12,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    color: Colors.green,
                  ),
                  Text('${(data['completionRate'] ?? 0).toStringAsFixed(1)}%'),
                  const SizedBox(height: 24),
                  // Overdue Rate
                  Text('Overdue Rate', style: theme.textTheme.titleMedium),
                  LinearProgressIndicator(
                    value: (data['overdueRate'] ?? 0) / 100.0,
                    minHeight: 12,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    color: Colors.red,
                  ),
                  Text('${(data['overdueRate'] ?? 0).toStringAsFixed(1)}%'),
                  const SizedBox(height: 24),
                  // Time Spent
                  Text(
                    'Time Spent (Actual / Estimated Hours)',
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    '${data['totalActualHours']} / ${data['totalEstimatedHours']} hours',
                  ),
                  const SizedBox(height: 24),
                  // Priority Distribution
                  Text(
                    'Priority Distribution',
                    style: theme.textTheme.titleMedium,
                  ),
                  ...((data['priorityDistribution'] as Map<String, int>?)
                          ?.entries
                          .map(
                            (e) => Row(
                              children: [
                                SizedBox(width: 120, child: Text(e.key)),
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value:
                                        (e.value / (data['totalTasks'] ?? 1)),
                                    minHeight: 8,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(e.value.toString()),
                              ],
                            ),
                          ) ??
                      []),
                  const SizedBox(height: 24),
                  // Status Distribution
                  Text(
                    'Status Distribution',
                    style: theme.textTheme.titleMedium,
                  ),
                  ...((data['statusDistribution'] as Map<String, int>?)?.entries
                          .map(
                            (e) => Row(
                              children: [
                                SizedBox(width: 120, child: Text(e.key)),
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value:
                                        (e.value / (data['totalTasks'] ?? 1)),
                                    minHeight: 8,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(e.value.toString()),
                              ],
                            ),
                          ) ??
                      []),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ),
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title, style: theme.textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
