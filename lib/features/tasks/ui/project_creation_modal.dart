import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_providers.dart';
import '../../../core/enums/project_priority.dart';
import '../../../core/models/user_model.dart';
import '../../../shared/providers/auth_providers.dart';

class ProjectCreationModal extends ConsumerStatefulWidget {
  final String departmentId;
  const ProjectCreationModal({super.key, required this.departmentId});

  @override
  ConsumerState<ProjectCreationModal> createState() =>
      _ProjectCreationModalState();
}

class _ProjectCreationModalState extends ConsumerState<ProjectCreationModal> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _description;
  ProjectPriority? _priority = ProjectPriority.medium;
  bool _submitting = false;
  String? _error;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_submitting) return; // Prevent double submission

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      _formKey.currentState!.save();

      // Reset the provider state before creating
      ref.invalidate(projectCreationProvider);

      final creation = ref.read(projectCreationProvider.notifier);
      final currentUser =
          await ref.read(currentUserProvider.future) as UserModel?;
      if (!mounted) return;

      final result = await creation.createProject(
        name: _name!,
        description: _description ?? '',
        departmentId: widget.departmentId,
        managerId: currentUser?.uid ?? '',
        priority: _priority!,
      );

      if (!mounted) return;

      if (result != null) {
        Navigator.of(context).pop(result);
      } else {
        setState(() {
          _submitting = false;
          _error = 'Failed to create project.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create Project', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 16),
                // Department (read-only)
                Text(
                  'Department: ${widget.departmentId}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                // Project Name
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Project Name'),
                  onSaved: (v) => _name = v,
                  validator:
                      (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                // Description
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Description'),
                  onSaved: (v) => _description = v,
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                // Priority
                DropdownButtonFormField<ProjectPriority>(
                  value: _priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items:
                      ProjectPriority.values
                          .map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Text(p.displayName),
                            ),
                          )
                          .toList(),
                  onChanged: (value) => setState(() => _priority = value),
                  validator: (value) => value == null ? 'Required' : null,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
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
                      onPressed: _submitting ? null : _submit,
                      child:
                          _submitting
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Create Project'),
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
