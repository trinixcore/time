import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/task_providers.dart';

class TaskTimeLoggingWidget extends ConsumerStatefulWidget {
  final String taskId;
  final String taskTitle;

  const TaskTimeLoggingWidget({
    super.key,
    required this.taskId,
    required this.taskTitle,
  });

  @override
  ConsumerState<TaskTimeLoggingWidget> createState() =>
      _TaskTimeLoggingWidgetState();
}

class _TaskTimeLoggingWidgetState extends ConsumerState<TaskTimeLoggingWidget> {
  final _formKey = GlobalKey<FormState>();
  final _hoursController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _hoursController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _openTimeLogDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Log Time Worked'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Task: ${widget.taskTitle}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _hoursController,
                    decoration: const InputDecoration(
                      labelText: 'Hours Worked',
                      hintText: 'e.g., 2.5',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter hours worked';
                      }
                      final hours = double.tryParse(value);
                      if (hours == null || hours <= 0) {
                        return 'Please enter a valid number of hours';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'What did you work on?',
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please describe what you worked on';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Work Date'),
                    subtitle: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 365),
                        ),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDate = date;
                        });
                      }
                    },
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
                onPressed: _isLoading ? null : _submitTimeLog,
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Log Time'),
              ),
            ],
          ),
    );
  }

  Future<void> _submitTimeLog() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final hours = double.parse(_hoursController.text);
      final success = await ref
          .read(taskTimeTrackingProvider.notifier)
          .logTimeWorked(
            taskId: widget.taskId,
            hoursWorked: hours.round(),
            description: _descriptionController.text,
            workDate: _selectedDate,
          );

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully logged ${hours} hours'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form
        _hoursController.clear();
        _descriptionController.clear();
        _selectedDate = DateTime.now();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to log time'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: _openTimeLogDialog,
      icon: const Icon(Icons.timer),
      label: const Text('Log Time'),
    );
  }
}
