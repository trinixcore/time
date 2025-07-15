import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/enums/document_enums.dart';
import '../../../core/utils/document_permissions.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../core/services/permission_management_service.dart';
import '../providers/document_providers.dart';

class UploadDocumentDialog extends ConsumerStatefulWidget {
  final String? folderId;

  const UploadDocumentDialog({super.key, this.folderId});

  @override
  ConsumerState<UploadDocumentDialog> createState() =>
      _UploadDocumentDialogState();
}

class _UploadDocumentDialogState extends ConsumerState<UploadDocumentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();

  File? _selectedFile;
  PlatformFile? _selectedPlatformFile;
  DocumentCategory _selectedCategory = DocumentCategory.shared;
  DocumentAccessLevel _selectedAccessLevel = DocumentAccessLevel.restricted;
  bool _requiresApproval = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uploadState = ref.watch(uploadDocumentProvider);

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
                  Icon(Icons.upload_file, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Upload Document',
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

              // File selection
              _buildFileSelector(theme),

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
                  hintText: 'Enter document description...',
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

              const SizedBox(height: 16),

              // Requires approval checkbox
              CheckboxListTile(
                title: const Text('Requires approval'),
                subtitle: const Text(
                  'Document will need approval before being accessible',
                ),
                value: _requiresApproval,
                onChanged: (value) {
                  setState(() {
                    _requiresApproval = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        uploadState.isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed:
                        uploadState.isLoading ||
                                (_selectedFile == null &&
                                    _selectedPlatformFile == null)
                            ? null
                            : _uploadDocument,
                    child:
                        uploadState.isLoading
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Upload'),
                  ),
                ],
              ),

              // Error message
              if (uploadState.hasError) ...[
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
                          uploadState.error.toString(),
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

  Widget _buildFileSelector(ThemeData theme) {
    final hasFile = _selectedFile != null || _selectedPlatformFile != null;
    final fileName =
        _selectedFile?.path.split('/').last ??
        _selectedPlatformFile?.name ??
        '';
    final fileSize =
        _selectedFile?.lengthSync() ?? _selectedPlatformFile?.size ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color:
              hasFile ? theme.colorScheme.primary : theme.colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          if (!hasFile) ...[
            Icon(
              Icons.cloud_upload,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              'Select a file to upload',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _selectFile,
              icon: const Icon(Icons.folder_open),
              label: const Text('Browse Files'),
            ),
          ] else ...[
            Row(
              children: [
                Icon(Icons.insert_drive_file, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatFileSize(fileSize),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedFile = null;
                      _selectedPlatformFile = null;
                    });
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown(ThemeData theme) {
    final currentUser = ref.watch(currentUserProvider).value;
    final permissionsAsync =
        currentUser != null
            ? ref
                .watch(permissionManagementServiceProvider)
                .getEffectivePermissionsAsync(currentUser.role)
            : Future.value(null);

    return FutureBuilder<DocumentAccessMatrix?>(
      future: permissionsAsync,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null || currentUser == null) {
          return const Text('Error loading categories');
        }

        final permissions = snapshot.data!;
        final uploadableCategories =
            permissions.canUploadToAll
                ? permissions.accessibleCategories
                : permissions.uploadableCategories;

        // If current selected category is not in uploadable categories, reset it
        if (!uploadableCategories.contains(_selectedCategory)) {
          _selectedCategory = uploadableCategories.first;
        }

        return DropdownButtonFormField<DocumentCategory>(
          value: _selectedCategory,
          decoration: const InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(),
          ),
          items:
              uploadableCategories.map((category) {
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

  Future<void> _selectFile() async {
    try {
      print('🔍 Starting file selection...');

      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      print('📁 File picker result: $result');

      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.first;
        print('✅ File selected: ${platformFile.name}');
        print('📊 File size: ${platformFile.size} bytes');

        if (kIsWeb) {
          // On web, use bytes instead of file path
          print('🌐 Web platform detected, using bytes');
          if (platformFile.bytes != null) {
            print('✅ File bytes available');
            setState(() {
              _selectedFile = null;
              _selectedPlatformFile = platformFile;
            });
            print('✅ File selection completed successfully (web)');
          } else {
            print('❌ File bytes are null');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error: File bytes are null')),
              );
            }
          }
        } else {
          // On mobile/desktop, use file path
          print('📱 Mobile/Desktop platform detected, using file path');
          if (platformFile.path != null) {
            final file = File(platformFile.path!);
            print('🗂️ File object created successfully');
            setState(() {
              _selectedFile = file;
              _selectedPlatformFile = null;
            });
            print('✅ File selection completed successfully (mobile/desktop)');
          } else {
            print('❌ File path is null');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error: File path is null')),
              );
            }
          }
        }
      } else {
        print('❌ No file selected or result is null');
      }
    } catch (e, stackTrace) {
      print('💥 Error selecting file: $e');
      print('📚 Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error selecting file: $e')));
      }
    }
  }

  Future<void> _uploadDocument() async {
    print('🚀 Starting document upload...');

    if (!_formKey.currentState!.validate() ||
        (_selectedFile == null && _selectedPlatformFile == null)) {
      print('❌ Form validation failed or no file selected');
      return;
    }

    print('✅ Form validation passed');

    final tags =
        _tagsController.text
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList();

    print('🏷️ Tags: $tags');
    print('✅ Requires approval: $_requiresApproval');

    try {
      print('📤 Calling upload provider...');

      if (kIsWeb && _selectedPlatformFile != null) {
        // Web upload using bytes
        print('🌐 Web upload using bytes');
        print('📁 Selected file: ${_selectedPlatformFile!.name}');
        print('📂 Category: ${_selectedCategory.displayName}');
        print('🔒 Access level: ${_selectedAccessLevel.displayName}');
        print('📝 Description: ${_descriptionController.text.trim()}');
        print('🏷️ Folder ID: ${widget.folderId}');

        await ref
            .read(uploadDocumentProvider.notifier)
            .uploadFromBytes(
              bytes: _selectedPlatformFile!.bytes!,
              fileName: _selectedPlatformFile!.name,
              category: _selectedCategory,
              accessLevel: _selectedAccessLevel,
              description:
                  _descriptionController.text.trim().isEmpty
                      ? null
                      : _descriptionController.text.trim(),
              folderId: widget.folderId,
              tags: tags.isEmpty ? null : tags,
              requiresApproval: _requiresApproval,
            );
      } else if (_selectedFile != null) {
        // Mobile/Desktop upload using file
        print('📱 Mobile/Desktop upload using file');
        print('📁 Selected file: ${_selectedFile!.path}');
        print('📂 Category: ${_selectedCategory.displayName}');
        print('🔒 Access level: ${_selectedAccessLevel.displayName}');
        print('📝 Description: ${_descriptionController.text.trim()}');
        print('🏷️ Folder ID: ${widget.folderId}');

        await ref
            .read(uploadDocumentProvider.notifier)
            .uploadFile(
              file: _selectedFile!,
              category: _selectedCategory,
              accessLevel: _selectedAccessLevel,
              description:
                  _descriptionController.text.trim().isEmpty
                      ? null
                      : _descriptionController.text.trim(),
              folderId: widget.folderId,
              tags: tags.isEmpty ? null : tags,
              requiresApproval: _requiresApproval,
            );
      }

      // Check if upload was successful by checking the provider state
      final uploadState = ref.read(uploadDocumentProvider);

      if (uploadState.hasError) {
        print('❌ Upload failed with error: ${uploadState.error}');
        // Don't close dialog or show success message - let user see the error
        return;
      }

      print('✅ Upload completed successfully');

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('💥 Upload error: $e');
      print('📚 Stack trace: $stackTrace');
      // Error is handled by the provider, don't close dialog
      // Let user see the error message in the dialog
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

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
