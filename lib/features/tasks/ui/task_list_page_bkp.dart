import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../dashboard/ui/dashboard_scaffold.dart';
import '../../../shared/widgets/custom_loader.dart';
import '../providers/task_providers.dart';
import '../../../core/enums/task_status.dart';
import '../../../core/enums/priority_level.dart';
import 'task_creation_modal.dart';

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

  void _openTaskCreationModal() async {
    await showDialog(
      context: context,
      builder: (context) => const TaskCreationModal(),
    );
    // Optionally refresh tasks after creation
    ref.invalidate(filteredTasksProvider);
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
      ),
    );

    return DashboardScaffold(
      currentPath: '/tasks',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Task Management'),
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            TextButton.icon(
              onPressed: () => context.go('/tasks/calendar'),
              icon: const Icon(Icons.calendar_today),
              label: const Text('Calendar'),
            ),
            TextButton.icon(
              onPressed: () => context.go('/tasks/analytics'),
              icon: const Icon(Icons.analytics),
              label: const Text('Analytics'),
            ),
            const SizedBox(width: 16),
            FilledButton.icon(
              onPressed: _openTaskCreationModal,
              icon: const Icon(Icons.add_task),
              label: const Text('Create Task'),
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
                ],
              ),
              const SizedBox(height: 24),
              // Task List
              Expanded(
                child: tasksAsync.when(
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
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return ListTile(
                          leading: Icon(
                            Icons.task_alt,
                            color: theme.colorScheme.primary,
                          ),
                          title: Text(
                            task.title,
                            style: theme.textTheme.titleMedium,
                          ),
                          subtitle: Text(
                            'Due: ${task.dueDate.toLocal().toString().split(' ')[0]} | Priority: ${task.priority.displayName} | Status: ${task.status.displayName}',
                          ),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () {
                            context.go('/tasks/${task.id}');
                          },
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CustomLoader()),
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
