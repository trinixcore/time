import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../dashboard/ui/dashboard_scaffold.dart';
import '../providers/task_providers.dart';

class TaskCalendarPage extends ConsumerStatefulWidget {
  const TaskCalendarPage({super.key});

  @override
  ConsumerState<TaskCalendarPage> createState() => _TaskCalendarPageState();
}

class _TaskCalendarPageState extends ConsumerState<TaskCalendarPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasksAsync = ref.watch(allTasksProvider);

    return DashboardScaffold(
      currentPath: '/tasks/calendar',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Task Calendar'),
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
              onPressed: () => context.go('/tasks/analytics'),
              icon: const Icon(Icons.analytics),
              label: const Text('Analytics'),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Calendar (simple grid for now)
              CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                onDateChanged: (date) {
                  setState(() => _selectedDate = date);
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Tasks Due on ${_selectedDate.toLocal().toString().split(' ')[0]}',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: tasksAsync.when(
                  data: (tasks) {
                    final dueTasks =
                        tasks
                            .where(
                              (t) =>
                                  t.dueDate.year == _selectedDate.year &&
                                  t.dueDate.month == _selectedDate.month &&
                                  t.dueDate.day == _selectedDate.day,
                            )
                            .toList();
                    if (dueTasks.isEmpty) {
                      return const Center(
                        child: Text('No tasks due on this day.'),
                      );
                    }
                    return ListView.separated(
                      itemCount: dueTasks.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final task = dueTasks[index];
                        return ListTile(
                          leading: Icon(
                            Icons.task,
                            color: theme.colorScheme.primary,
                          ),
                          title: Text(task.title),
                          subtitle: Text(
                            'Priority: ${task.priority.displayName} | Status: ${task.status.displayName}',
                          ),
                          onTap: () {
                            context.go('/tasks/${task.id}');
                          },
                        );
                      },
                    );
                  },
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Error: $err')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
