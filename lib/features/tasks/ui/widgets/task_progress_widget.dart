import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/task_providers.dart';

class TaskProgressWidget extends ConsumerStatefulWidget {
  final String taskId;
  final String taskTitle;
  final int currentProgress;

  const TaskProgressWidget({
    super.key,
    required this.taskId,
    required this.taskTitle,
    required this.currentProgress,
  });

  @override
  ConsumerState<TaskProgressWidget> createState() => _TaskProgressWidgetState();
}

class _TaskProgressWidgetState extends ConsumerState<TaskProgressWidget> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _progressController = TextEditingController();
  double _progressPercentage = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _progressPercentage = widget.currentProgress.toDouble();
    _progressController.text = widget.currentProgress.toString();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _openProgressDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Update Progress'),
            content: ConstrainedBox(
              constraints: BoxConstraints(minWidth: 320, maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Task: ${widget.taskTitle}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Current Progress: ${widget.currentProgress}%',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _progressController,
                      decoration: const InputDecoration(
                        labelText: 'New Progress (%)',
                        hintText: 'Enter a value between 0 and 100',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter progress percentage';
                        }
                        final val = int.tryParse(value);
                        if (val == null || val < 0 || val > 100) {
                          return 'Enter a value between 0 and 100';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        final val = int.tryParse(value);
                        if (val != null && val >= 0 && val <= 100) {
                          setState(() {
                            _progressPercentage = val.toDouble();
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        hintText: 'Describe what was completed...',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    _buildDeliveryRiskIndicator(),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: _isLoading ? null : _submitProgress,
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Update Progress'),
              ),
            ],
          ),
    );
  }

  Widget _buildDeliveryRiskIndicator() {
    // Simple risk calculation based on progress
    final progress = _progressPercentage.round();
    String riskLevel;
    Color riskColor;
    IconData riskIcon;

    if (progress >= 100) {
      riskLevel = 'Completed';
      riskColor = Colors.green;
      riskIcon = Icons.check_circle;
    } else if (progress >= 80) {
      riskLevel = 'On Track';
      riskColor = Colors.green;
      riskIcon = Icons.trending_up;
    } else if (progress >= 60) {
      riskLevel = 'Low Risk';
      riskColor = Colors.orange;
      riskIcon = Icons.warning;
    } else if (progress >= 40) {
      riskLevel = 'Medium Risk';
      riskColor = Colors.deepOrange;
      riskIcon = Icons.warning;
    } else {
      riskLevel = 'High Risk';
      riskColor = Colors.red;
      riskIcon = Icons.error;
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
            child: Text(
              'Delivery Risk: $riskLevel',
              style: TextStyle(color: riskColor, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitProgress() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final progressVal = int.parse(_progressController.text);
      final success = await ref
          .read(taskTimeTrackingProvider.notifier)
          .updateProgress(
            taskId: widget.taskId,
            progressPercentage: progressVal,
            notes:
                _notesController.text.isNotEmpty ? _notesController.text : null,
          );

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Progress updated to ${progressVal}%'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form
        _notesController.clear();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update progress'),
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
      onPressed: _openProgressDialog,
      icon: const Icon(Icons.trending_up),
      label: const Text('Update Progress'),
    );
  }
}
