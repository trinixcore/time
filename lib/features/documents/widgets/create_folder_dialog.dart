import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/document_enums.dart';
import '../providers/document_providers.dart';

class CreateFolderDialog extends ConsumerStatefulWidget {
  final String? parentId;

  const CreateFolderDialog({super.key, this.parentId});

  @override
  ConsumerState<CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends ConsumerState<CreateFolderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();

  DocumentCategory _selectedCategory = DocumentCategory.shared;
  DocumentAccessLevel _selectedAccessLevel = DocumentAccessLevel.restricted;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final createState = ref.watch(createFolderProvider);

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.create_new_folder,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Create Folder',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Folder name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Folder Name',
                  border: OutlineInputBorder(),
                  hintText: 'Enter folder name...',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a folder name';
                  }
                  if (value.trim().length < 2) {
                    return 'Folder name must be at least 2 characters';
                  }
                  return null;
                },
                autofocus: true,
              ),

              const SizedBox(height: 16),

              // Category selection
              _buildCategoryDropdown(theme),

              const SizedBox(height: 16),

              // Access level selection
              _buildAccessLevelDropdown(theme),

              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Enter folder description...',
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              // Tags field
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Enter tags separated by commas...',
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        createState.isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: createState.isLoading ? null : _createFolder,
                    child:
                        createState.isLoading
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Create'),
                  ),
                ],
              ),

              // Error message
              if (createState.hasError) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error,
                        color: theme.colorScheme.onErrorContainer,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          createState.error.toString(),
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
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
      ),
    );
  }

  Widget _buildCategoryDropdown(ThemeData theme) {
    return DropdownButtonFormField<DocumentCategory>(
      value: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
      ),
      items:
          DocumentCategory.values.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(category.displayName),
            );
          }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedCategory = value;
          });
        }
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a category';
        }
        return null;
      },
    );
  }

  Widget _buildAccessLevelDropdown(ThemeData theme) {
    return DropdownButtonFormField<DocumentAccessLevel>(
      value: _selectedAccessLevel,
      decoration: const InputDecoration(
        labelText: 'Access Level',
        border: OutlineInputBorder(),
      ),
      items:
          DocumentAccessLevel.values.map((level) {
            return DropdownMenuItem(
              value: level,
              child: Row(
                children: [
                  Icon(
                    Icons.security,
                    size: 16,
                    color: _getAccessLevelColor(level),
                  ),
                  const SizedBox(width: 8),
                  Text(level.displayName),
                ],
              ),
            );
          }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedAccessLevel = value;
          });
        }
      },
      validator: (value) {
        if (value == null) {
          return 'Please select an access level';
        }
        return null;
      },
    );
  }

  Future<void> _createFolder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final tags =
        _tagsController.text
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList();

    try {
      await ref
          .read(createFolderProvider.notifier)
          .create(
            name: _nameController.text.trim(),
            category: _selectedCategory,
            accessLevel: _selectedAccessLevel,
            parentId: widget.parentId,
            description:
                _descriptionController.text.trim().isEmpty
                    ? null
                    : _descriptionController.text.trim(),
            tags: tags.isEmpty ? null : tags,
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Folder created successfully')),
        );
      }
    } catch (e) {
      // Error is handled by the provider
    }
  }

  Color _getAccessLevelColor(DocumentAccessLevel accessLevel) {
    switch (accessLevel) {
      case DocumentAccessLevel.public:
        return Colors.green;
      case DocumentAccessLevel.restricted:
        return Colors.orange;
      case DocumentAccessLevel.confidential:
        return Colors.red;
      case DocumentAccessLevel.private:
        return Colors.purple;
    }
  }
}
