import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/letter_template_model.dart';
import '../providers/letter_template_providers.dart';

class TemplateManagementWidget extends ConsumerStatefulWidget {
  const TemplateManagementWidget({super.key});

  @override
  ConsumerState<TemplateManagementWidget> createState() =>
      _TemplateManagementWidgetState();
}

class _TemplateManagementWidgetState
    extends ConsumerState<TemplateManagementWidget> {
  String _searchQuery = '';
  String _selectedCategory = 'all';
  String _selectedType = 'all';

  final List<String> _categories = [
    'all',
    'HR',
    'Management',
    'Legal',
    'Finance',
    'Operations',
  ];

  final List<String> _types = [
    'all',
    'Offer Letter',
    'Appointment Letter',
    'Experience Certificate',
    'Relieving Letter',
    'Promotion Letter',
    'Leave Approval',
    'Warning Letter',
    'Custom Letter',
  ];

  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(letterTemplateNotifierProvider);

    return Column(
      children: [
        // Header with search and filters
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search and Add Button
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search templates...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateTemplateModal(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Template'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Filters
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                      ),
                      items:
                          _categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(
                                category == 'all' ? 'All Categories' : category,
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                      ),
                      items:
                          _types.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type == 'all' ? 'All Types' : type),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Templates List
        Expanded(
          child: templatesAsync.when(
            data: (templates) {
              // Filter templates
              final filteredTemplates =
                  templates.where((template) {
                    final matchesSearch =
                        _searchQuery.isEmpty ||
                        template.name.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ||
                        template.type.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ||
                        template.description?.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ) ==
                            true;

                    final matchesCategory =
                        _selectedCategory == 'all' ||
                        template.category == _selectedCategory;

                    final matchesType =
                        _selectedType == 'all' ||
                        template.type == _selectedType;

                    return matchesSearch && matchesCategory && matchesType;
                  }).toList();

              if (filteredTemplates.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.description,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No templates found',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your first template to get started',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: filteredTemplates.length,
                itemBuilder: (context, index) {
                  final template = filteredTemplates[index];
                  return _buildTemplateCard(template);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading templates',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateCard(LetterTemplate template) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        template.type,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (template.description != null)
                        Text(
                          template.description!,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                _buildStatusChip(template.isActive),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (template.category != null) ...[
                  _buildInfoChip('Category', template.category!),
                  const SizedBox(width: 8),
                ],
                if (template.variables.isNotEmpty) ...[
                  _buildInfoChip('Variables', '${template.variables.length}'),
                  const SizedBox(width: 8),
                ],
                if (template.requiresSignature) ...[
                  _buildInfoChip('Signature', 'Required'),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Created: ${_formatDate(template.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _previewTemplate(template),
                      icon: const Icon(Icons.visibility),
                      tooltip: 'Preview',
                    ),
                    IconButton(
                      onPressed: () => _editTemplate(template),
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      onPressed: () => _toggleTemplateActive(template),
                      icon: Icon(
                        template.isActive
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      tooltip: template.isActive ? 'Deactivate' : 'Activate',
                    ),
                    IconButton(
                      onPressed: () => _deleteTemplate(template),
                      icon: const Icon(Icons.delete),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    final color = isActive ? Colors.green : Colors.grey;
    final label = isActive ? 'Active' : 'Inactive';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showCreateTemplateModal(BuildContext context) {
    // TODO: Implement create template modal
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create template modal coming soon')),
    );
  }

  void _previewTemplate(LetterTemplate template) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Template Preview: ${template.name}'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Type: ${template.type}'),
                  if (template.category != null)
                    Text('Category: ${template.category}'),
                  if (template.description != null)
                    Text('Description: ${template.description}'),
                  const SizedBox(height: 16),
                  Text(
                    'Content:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      template.content,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  if (template.variables.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Variables:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children:
                          template.variables.map((variable) {
                            return Chip(
                              label: Text(variable),
                              backgroundColor:
                                  Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                            );
                          }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _editTemplate(LetterTemplate template) {
    // TODO: Implement edit template modal
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Edit template: ${template.name}')));
  }

  void _toggleTemplateActive(LetterTemplate template) async {
    try {
      final notifier = ref.read(letterTemplateNotifierProvider.notifier);
      await notifier.setTemplateActive(template.id, !template.isActive);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Template ${template.isActive ? 'deactivated' : 'activated'} successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating template: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteTemplate(LetterTemplate template) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Template'),
            content: Text(
              'Are you sure you want to delete "${template.name}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    final notifier = ref.read(
                      letterTemplateNotifierProvider.notifier,
                    );
                    await notifier.deleteTemplate(template.id);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Template "${template.name}" deleted successfully',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error deleting template: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
