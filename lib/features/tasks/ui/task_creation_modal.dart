import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_providers.dart';
import '../../../core/enums/priority_level.dart';
import '../../../core/models/project.dart';
import 'project_creation_modal.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../core/models/user_model.dart';

class TaskCreationModal extends ConsumerStatefulWidget {
  const TaskCreationModal({super.key});

  @override
  ConsumerState<TaskCreationModal> createState() => _TaskCreationModalState();
}

class _TaskCreationModalState extends ConsumerState<TaskCreationModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedDepartment;
  String? _selectedProject;
  String? _selectedAssignee;
  String? _selectedCategory;
  PriorityLevel _selectedPriority = PriorityLevel.medium;
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 7));
  int _estimatedHours = 0;
  List<String> _selectedWatchers = [];
  String? _selectedObserver;

  final TextEditingController _userSearchController = TextEditingController();
  bool _showUserDropdown = false;
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _creatingProject = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _userSearchController.dispose();
    super.dispose();
  }

  void _filterUsers(List<Map<String, dynamic>> allUsers, String query) {
    if (query.isEmpty) {
      _filteredUsers = allUsers;
    } else {
      _filteredUsers =
          allUsers.where((user) {
            final name = user['name']?.toString().toLowerCase() ?? '';
            final email = user['email']?.toString().toLowerCase() ?? '';
            final employeeId =
                user['employeeId']?.toString().toLowerCase() ?? '';
            final searchQuery = query.toLowerCase();

            return name.contains(searchQuery) ||
                email.contains(searchQuery) ||
                employeeId.contains(searchQuery);
          }).toList();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _openProjectCreationModal(String departmentId) async {
    setState(() => _creatingProject = true);
    final project = await showDialog<Project?>(
      context: context,
      builder: (context) => ProjectCreationModal(departmentId: departmentId),
    );
    setState(() => _creatingProject = false);
    if (project != null) {
      setState(() {
        _selectedProject = project.id;
      });
      ref.invalidate(projectsByDepartmentProvider(departmentId));
    }
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDepartment == null) {
      _showError('Please select a department');
      return;
    }
    if (_selectedProject == null) {
      _showError('Please select a project');
      return;
    }
    if (_selectedAssignee == null) {
      _showError('Please select an assignee');
      return;
    }

    final task = await ref
        .read(taskCreationProvider.notifier)
        .createTask(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _selectedPriority,
          dueDate: _selectedDueDate,
          departmentId: _selectedDepartment!,
          projectId: _selectedProject!,
          assignedTo: _selectedAssignee!,
          category: _selectedCategory,
          estimatedHours: _estimatedHours > 0 ? _estimatedHours : null,
          watchers: _selectedWatchers,
        );

    if (task != null && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task created successfully!')),
      );
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
    final usersAsync = ref.watch(activeUsersProvider);
    final categories = ref.watch(taskCategoriesProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create Task', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 16),
                // Department Dropdown
                departmentsAsync.when(
                  data:
                      (departments) => DropdownButtonFormField<String>(
                        value: _selectedDepartment,
                        decoration: const InputDecoration(
                          labelText: 'Department',
                        ),
                        items:
                            departments
                                .map(
                                  (d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(d),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDepartment = value;
                            _selectedProject = null;
                          });
                        },
                        validator: (value) => value == null ? 'Required' : null,
                      ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('Error loading departments'),
                ),
                const SizedBox(height: 12),
                // Project Dropdown
                projectsAsync.when(
                  data: (projects) {
                    if (projects.isEmpty) {
                      return Row(
                        children: [
                          const Text('No projects available.'),
                          const SizedBox(width: 8),
                          if (_selectedDepartment != null)
                            TextButton(
                              onPressed:
                                  _creatingProject
                                      ? null
                                      : () => _openProjectCreationModal(
                                        _selectedDepartment!,
                                      ),
                              child: const Text('Create Project'),
                            ),
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value:
                                projects.any((p) => p.id == _selectedProject)
                                    ? _selectedProject
                                    : null,
                            decoration: const InputDecoration(
                              labelText: 'Project',
                            ),
                            items:
                                projects
                                    .map(
                                      (p) => DropdownMenuItem<String>(
                                        value: p.id,
                                        child: Text(p.name),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedProject = value;
                              });
                            },
                            validator:
                                (value) => value == null ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_selectedDepartment != null)
                          TextButton(
                            onPressed:
                                _creatingProject
                                    ? null
                                    : () => _openProjectCreationModal(
                                      _selectedDepartment!,
                                    ),
                            child: const Text('Create Project'),
                          ),
                      ],
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('Error loading projects'),
                ),
                const SizedBox(height: 12),
                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator:
                      (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                // Priority
                DropdownButtonFormField<PriorityLevel>(
                  value: _selectedPriority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items:
                      PriorityLevel.values
                          .map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Text(p.displayName),
                            ),
                          )
                          .toList(),
                  onChanged:
                      (value) => setState(
                        () => _selectedPriority = value ?? PriorityLevel.medium,
                      ),
                  validator: (value) => value == null ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                // Due Date
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null)
                      setState(() => _selectedDueDate = picked);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Due Date'),
                    child: Text(
                      _selectedDueDate.toLocal().toString().split(' ')[0],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Estimated Hours
                TextFormField(
                  initialValue:
                      _estimatedHours > 0 ? _estimatedHours.toString() : '',
                  decoration: const InputDecoration(
                    labelText: 'Estimated Hours',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    final n = int.tryParse(v);
                    if (n == null || n < 0) return 'Enter a valid number';
                    return null;
                  },
                  onChanged: (v) {
                    setState(() {
                      _estimatedHours = int.tryParse(v) ?? 0;
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items:
                      categories
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                  onChanged:
                      (value) => setState(() => _selectedCategory = value),
                ),
                const SizedBox(height: 12),
                // User Assignment - Searchable Dropdown
                usersAsync.when(
                  data:
                      (users) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _userSearchController,
                            decoration: InputDecoration(
                              labelText: 'Assign to',
                              hintText: 'Search by name, email, or employee ID',
                              suffixIcon:
                                  _selectedAssignee != null
                                      ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          setState(() {
                                            _selectedAssignee = null;
                                            _userSearchController.clear();
                                            _showUserDropdown = false;
                                          });
                                        },
                                      )
                                      : const Icon(Icons.search),
                            ),
                            onChanged: (value) {
                              _filterUsers(users, value);
                              setState(() {
                                _showUserDropdown = value.isNotEmpty;
                              });
                            },
                            onTap: () {
                              _filterUsers(users, _userSearchController.text);
                              setState(() {
                                _showUserDropdown = true;
                              });
                            },
                            readOnly: _selectedAssignee != null,
                          ),
                          if (_showUserDropdown && _selectedAssignee == null)
                            Container(
                              constraints: const BoxConstraints(maxHeight: 200),
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _filteredUsers.length,
                                itemBuilder: (context, index) {
                                  final user = _filteredUsers[index];
                                  return ListTile(
                                    dense: true,
                                    title: Text(user['name'] ?? 'Unknown'),
                                    subtitle: Text(
                                      '${user['email'] ?? ''} • ${user['employeeId'] ?? 'No ID'}',
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _selectedAssignee = user['uid'];
                                        _userSearchController.text =
                                            user['name'] ?? '';
                                        _showUserDropdown = false;
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('Error loading users'),
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _createTask,
                      child: const Text('Create Task'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
