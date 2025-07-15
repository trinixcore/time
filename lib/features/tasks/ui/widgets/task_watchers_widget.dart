import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/custom_loader.dart';
import '../../providers/task_providers.dart';
import '../../../../core/models/task_model.dart';
import '../../../../shared/providers/auth_providers.dart';

class TaskWatchersWidget extends ConsumerStatefulWidget {
  final TaskModel task;

  const TaskWatchersWidget({super.key, required this.task});

  @override
  ConsumerState<TaskWatchersWidget> createState() => _TaskWatchersWidgetState();
}

class _TaskWatchersWidgetState extends ConsumerState<TaskWatchersWidget> {
  bool _isExpanded = false;
  String? _selectedUserId;

  bool _canManageWatchers() {
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    if (currentUser == null) return false;

    // Only creator and assignee can manage watchers
    return widget.task.createdBy == currentUser.uid ||
        widget.task.assignedTo == currentUser.uid;
  }

  Future<void> _addWatcher() async {
    if (_selectedUserId == null) return;

    final success = await ref
        .read(taskWatchersManagementProvider.notifier)
        .addWatcher(widget.task.id, _selectedUserId!);

    if (success && mounted) {
      setState(() {
        _selectedUserId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Observer added successfully')),
      );
    }
  }

  Future<void> _removeWatcher(String userId) async {
    final success = await ref
        .read(taskWatchersManagementProvider.notifier)
        .removeWatcher(widget.task.id, userId);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Observer removed successfully')),
      );
    }
  }

  void _openMultiSelectDialog(List<Map<String, dynamic>> availableUsers) async {
    final selected = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        Set<String> tempSelected = {};
        TextEditingController searchController = TextEditingController();
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setState) {
            final filteredUsers =
                availableUsers.where((user) {
                  final name = (user['name'] ?? '').toLowerCase();
                  final email = (user['email'] ?? '').toLowerCase();
                  return name.contains(searchQuery.toLowerCase()) ||
                      email.contains(searchQuery.toLowerCase());
                }).toList();
            return AlertDialog(
              title: const Text('Select Observers'),
              content: SizedBox(
                width: 400,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search user',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child:
                          filteredUsers.isEmpty
                              ? Center(
                                child: Text(
                                  'No users available to add as observers.',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                              )
                              : ListView(
                                children:
                                    filteredUsers.map((user) {
                                      final userId = user['uid'] ?? user['id'];
                                      final userName =
                                          user['name'] ?? 'Unknown';
                                      final userEmail = user['email'] ?? '';
                                      return CheckboxListTile(
                                        value: tempSelected.contains(userId),
                                        title: Text(userName),
                                        subtitle:
                                            userEmail.isNotEmpty
                                                ? Text(userEmail)
                                                : null,
                                        onChanged: (checked) {
                                          setState(() {
                                            if (checked == true) {
                                              tempSelected.add(userId);
                                            } else {
                                              tempSelected.remove(userId);
                                            }
                                          });
                                        },
                                      );
                                    }).toList(),
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
                      () => Navigator.of(context).pop(tempSelected.toList()),
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
    if (selected != null && selected.isNotEmpty) {
      for (final userId in selected) {
        await _addWatcherById(userId);
      }
    }
  }

  Future<void> _addWatcherById(String userId) async {
    final success = await ref
        .read(taskWatchersManagementProvider.notifier)
        .addWatcher(widget.task.id, userId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Observer added successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usersAsync = ref.watch(activeUsersProvider);
    final watchersState = ref.watch(taskWatchersManagementProvider);
    final canManage = _canManageWatchers();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Row(
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Observers (${widget.task.watchers.length})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.outline,
                  ),
                ],
              ),
            ),

            if (_isExpanded) ...[
              const SizedBox(height: 16),

              // Add Observer Section (only for creator and assignee)
              if (canManage) ...[
                Text(
                  'Add Observers',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                usersAsync.when(
                  data: (users) {
                    final availableUsers =
                        users.where((user) {
                          final userId = user['uid'] ?? user['id'];
                          return userId != widget.task.createdBy &&
                              userId != widget.task.assignedTo &&
                              !widget.task.watchers.contains(userId);
                        }).toList();
                    return Row(
                      children: [
                        Flexible(
                          child: FilledButton.icon(
                            icon: const Icon(Icons.group_add),
                            label: const Text('Select Observers'),
                            onPressed:
                                () => _openMultiSelectDialog(availableUsers),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error:
                      (error, _) => Text(
                        'Error loading users: $error',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
              ],

              // Current Watchers List
              Text(
                'Current Observers',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              if (widget.task.watchers.isEmpty)
                Text(
                  'No observers added yet',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                )
              else
                usersAsync.when(
                  data: (users) {
                    return Column(
                      children:
                          widget.task.watchers.map((watcherId) {
                            final user = users.firstWhere(
                              (u) => (u['uid'] ?? u['id']) == watcherId,
                              orElse: () => <String, dynamic>{},
                            );

                            final userName = user['name'] ?? 'Unknown User';
                            final userEmail = user['email'] ?? '';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceVariant
                                    .withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor:
                                        theme.colorScheme.secondary,
                                    child: Text(
                                      userName.substring(0, 1).toUpperCase(),
                                      style: TextStyle(
                                        color: theme.colorScheme.onSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userName,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                        if (userEmail.isNotEmpty)
                                          Text(
                                            userEmail,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color:
                                                      theme.colorScheme.outline,
                                                ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (canManage)
                                    IconButton(
                                      onPressed:
                                          watchersState.isLoading
                                              ? null
                                              : () => _removeWatcher(watcherId),
                                      icon: Icon(
                                        Icons.remove_circle_outline,
                                        color: theme.colorScheme.error,
                                      ),
                                      tooltip: 'Remove observer',
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                    );
                  },
                  loading: () => const Center(child: CustomLoader()),
                  error:
                      (error, _) => Text(
                        'Error loading observer details: $error',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                ),

              const SizedBox(height: 8),

              // Info Text
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Observers can view this task and receive updates. Only the task creator and assignee can manage observers.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
