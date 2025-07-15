import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/enums/user_role.dart';
import '../../../core/enums/document_enums.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/employee_folder_service.dart';
import '../../../shared/providers/auth_providers.dart';
import '../providers/document_providers.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../core/services/permission_management_service.dart';

class EmployeeUploadDialog extends ConsumerStatefulWidget {
  final String? defaultEmployeeId;
  final String? folderCode; // e.g., "01" for offer-letter folder

  const EmployeeUploadDialog({
    super.key,
    this.defaultEmployeeId,
    this.folderCode,
  });

  @override
  ConsumerState<EmployeeUploadDialog> createState() =>
      _EmployeeUploadDialogState();
}

class _EmployeeUploadDialogState extends ConsumerState<EmployeeUploadDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();

  File? _selectedFile;
  PlatformFile? _selectedPlatformFile;
  String? _selectedEmployeeId;
  String? _selectedFolderCode;
  bool _requiresApproval = false;

  List<Map<String, dynamic>> _employees = [];
  List<Map<String, String>> _folderTypes = [];
  bool _loadingEmployees = true;

  @override
  void initState() {
    super.initState();
    _selectedEmployeeId = widget.defaultEmployeeId;
    _selectedFolderCode = widget.folderCode ?? '01'; // Default to offer-letter
    _folderTypes = EmployeeFolderService.folderStructureTemplate;
    _loadEmployees();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    try {
      final authService = AuthService();
      final employees = await authService.getActiveUsersForSelection();

      setState(() {
        _employees =
            employees
                .where(
                  (emp) =>
                      emp['employeeId'] != null &&
                      emp['employeeId'].isNotEmpty &&
                      emp['uid'] != null &&
                      emp['uid'].isNotEmpty,
                )
                .toList();

        // Remove duplicates based on uid
        final seenUids = <String>{};
        _employees =
            _employees.where((emp) {
              final uid = emp['uid'] as String;
              if (seenUids.contains(uid)) {
                return false;
              }
              seenUids.add(uid);
              return true;
            }).toList();

        // Validate selected employee still exists
        if (_selectedEmployeeId != null) {
          final selectedExists = _employees.any(
            (emp) => emp['uid'] == _selectedEmployeeId,
          );
          if (!selectedExists) {
            _selectedEmployeeId = null;
          }
        }

        _loadingEmployees = false;
      });
    } catch (e) {
      setState(() {
        _loadingEmployees = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load employees: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uploadState = ref.watch(uploadDocumentProvider);
    final currentUser = ref.watch(currentUserProvider).value;

    // Check if user has permission to upload to employee folders using dynamic permissions
    final canUploadPermission = ref.watch(canUploadToEmployeeFoldersProvider);

    return canUploadPermission.when(
      data: (canUpload) {
        if (!canUpload) {
          return AlertDialog(
            title: const Text('Access Denied'),
            content: const Text(
              'You do not have permission to upload documents to employee folders.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        }

        return _buildUploadDialog(context, theme, uploadState, currentUser);
      },
      loading:
          () => const AlertDialog(
            content: SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      error:
          (error, _) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to check permissions: $error'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Widget _buildUploadDialog(
    BuildContext context,
    ThemeData theme,
    AsyncValue uploadState,
    UserModel? currentUser,
  ) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 600,
          maxHeight: 650, // Further reduced from 700 to 650
        ),
        child: Container(
          width: 600,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fixed header - reduced padding
              Container(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  20,
                  24,
                  12,
                ), // Reduced padding
                child: Row(
                  children: [
                    Icon(Icons.upload_file, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Upload Employee Document',
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
              ),

              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Employee selection
                        _buildEmployeeSelector(theme),

                        const SizedBox(height: 12), // Reduced from 16
                        // Folder type selection
                        _buildFolderTypeSelector(theme),

                        const SizedBox(height: 12), // Reduced from 16
                        // File selection
                        _buildFileSelector(theme),

                        const SizedBox(height: 12), // Reduced from 16
                        // Description field - reduced size
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description (optional)',
                            border: OutlineInputBorder(),
                            hintText: 'Enter document description...',
                            isDense: true, // Make it more compact
                          ),
                          maxLines: 2, // Reduced from 3
                        ),

                        const SizedBox(height: 12), // Reduced from 16
                        // Tags field
                        TextFormField(
                          controller: _tagsController,
                          decoration: const InputDecoration(
                            labelText: 'Tags (optional)',
                            border: OutlineInputBorder(),
                            hintText: 'Enter tags separated by commas...',
                            isDense: true, // Make it more compact
                          ),
                        ),

                        const SizedBox(height: 8), // Reduced from 16
                        // Requires approval checkbox - more compact
                        CheckboxListTile(
                          title: const Text('Requires approval'),
                          subtitle: const Text(
                            'Document will need approval before being accessible to employee',
                            style: TextStyle(fontSize: 12), // Smaller text
                          ),
                          value: _requiresApproval,
                          onChanged: (value) {
                            setState(() {
                              _requiresApproval = value ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          dense: true, // Make it more compact
                        ),

                        // Error message
                        if (uploadState.hasError) ...[
                          const SizedBox(height: 8), // Reduced from 16
                          Container(
                            padding: const EdgeInsets.all(8), // Reduced padding
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error,
                                  color: theme.colorScheme.onErrorContainer,
                                  size: 16, // Smaller icon
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    uploadState.error.toString(),
                                    style: TextStyle(
                                      color: theme.colorScheme.onErrorContainer,
                                      fontSize: 12, // Smaller text
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(
                          height: 16, // Reduced from 24
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Fixed footer with action buttons - reduced padding
              Container(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  12,
                  24,
                  20,
                ), // Reduced padding
                child: Row(
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
                                      _selectedPlatformFile == null) ||
                                  _selectedEmployeeId == null ||
                                  _selectedFolderCode == null
                              ? null
                              : _uploadDocument,
                      child:
                          uploadState.isLoading
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Upload Document'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeSelector(ThemeData theme) {
    if (_loadingEmployees) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            const Flexible(
              child: Text(
                'Loading employees...',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedEmployeeId,
      decoration: const InputDecoration(
        labelText: 'Select Employee',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
        isDense: true, // Make it more compact
      ),
      hint: const Text('Choose employee to upload document for'),
      items:
          _employees.map((employee) {
            return DropdownMenuItem<String>(
              value: employee['uid'],
              child: Text(
                '${employee['displayName'] ?? 'Unknown'} (${employee['employeeId']})',
                style: theme.textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedEmployeeId = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select an employee';
        }
        return null;
      },
    );
  }

  Widget _buildFolderTypeSelector(ThemeData theme) {
    final currentUser = ref.watch(currentUserProvider).value;

    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<List<Map<String, String>>>(
      future: _getFilteredFolders(currentUser.role),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.error, size: 48, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error Loading Folders',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.red[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load available folders. Please try again.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // This will trigger a rebuild and retry the FutureBuilder
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final allowedFolders = snapshot.data ?? [];

        // If no folders are allowed, show a message
        if (allowedFolders.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.block, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No Employee Document Access',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You do not have permission to upload documents to employee folders. Please contact your administrator to enable "Employee Documents" category access in your role permissions.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.blue[600],
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Required: "Enable All Employee Folders" permission',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.blue[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        // Ensure the selected folder code exists in allowed folders
        if (_selectedFolderCode != null) {
          final selectedExists = allowedFolders.any(
            (folder) => folder['code'] == _selectedFolderCode,
          );
          if (!selectedExists && allowedFolders.isNotEmpty) {
            // Reset to first allowed folder if current selection is not allowed
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _selectedFolderCode = allowedFolders.first['code'];
              });
            });
          }
        } else if (allowedFolders.isNotEmpty) {
          // Set default to first allowed folder if none selected
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _selectedFolderCode = allowedFolders.first['code'];
            });
          });
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.folder_special,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Document Type',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedFolderCode,
                  decoration: const InputDecoration(
                    labelText: 'Select folder type',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items:
                      allowedFolders.map((folder) {
                        return DropdownMenuItem(
                          value: folder['code'],
                          child: Text(folder['description']!),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFolderCode = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a folder type';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<Map<String, String>>> _getFilteredFolders(UserRole role) async {
    try {
      final permissionService = PermissionManagementService();

      print(
        '🔍 [EMPLOYEE UPLOAD] Checking folder permissions for role: ${role.value}',
      );

      // Get user permissions
      final permissions = await permissionService.getEffectivePermissionsAsync(
        role,
      );

      print(
        '📋 [EMPLOYEE UPLOAD] User uploadable categories: ${permissions.uploadableCategories.map((c) => c.value).join(', ')}',
      );

      // Check if user has general employee category upload permission
      final hasGeneralEmployeeAccess = permissions.canUploadToCategory(
        DocumentCategory.employee,
      );
      print(
        '📋 [EMPLOYEE UPLOAD] Has general employee category access: $hasGeneralEmployeeAccess',
      );

      // Now check folder-specific permissions
      final allowedFolders = <Map<String, String>>[];

      for (final folder in _folderTypes) {
        bool canUpload = false;

        if (hasGeneralEmployeeAccess) {
          // If user has general access, they can upload to all folders
          canUpload = true;
        } else {
          // If no general access, check folder-specific permissions
          canUpload = await permissionService.canUploadToEmployeeFolder(
            role,
            folder['code']!,
            folder['name']!,
          );
        }

        print(
          '🔍 [EMPLOYEE UPLOAD] Folder ${folder['code']}_${folder['name']}: $canUpload',
        );

        if (canUpload) {
          allowedFolders.add(folder);
        }
      }

      print(
        '✅ [EMPLOYEE UPLOAD] Found ${allowedFolders.length} allowed folders out of ${_folderTypes.length}',
      );

      return allowedFolders;
    } catch (e) {
      print('❌ [EMPLOYEE UPLOAD] Error checking folder permissions: $e');
      return []; // Return empty list on error
    }
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
      padding: const EdgeInsets.all(12), // Reduced from 16
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
              size: 36, // Reduced from 48
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 6), // Reduced from 8
            Text(
              'Select a file to upload',
              style: theme.textTheme.bodyMedium?.copyWith(
                // Changed from bodyLarge
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6), // Reduced from 8
            ElevatedButton.icon(
              onPressed: _selectFile,
              icon: const Icon(Icons.folder_open, size: 16), // Smaller icon
              label: const Text('Browse Files'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ), // Compact padding
              ),
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
                  padding: const EdgeInsets.all(4), // Compact padding
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _selectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.first;

        if (kIsWeb) {
          if (platformFile.bytes != null) {
            setState(() {
              _selectedFile = null;
              _selectedPlatformFile = platformFile;
            });
          }
        } else {
          if (platformFile.path != null) {
            final file = File(platformFile.path!);
            setState(() {
              _selectedFile = file;
              _selectedPlatformFile = null;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error selecting file: $e')));
      }
    }
  }

  Future<void> _uploadDocument() async {
    if (!_formKey.currentState!.validate() ||
        (_selectedFile == null && _selectedPlatformFile == null) ||
        _selectedEmployeeId == null ||
        _selectedFolderCode == null) {
      return;
    }

    final tags =
        _tagsController.text
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList();

    try {
      // Get selected employee info
      final selectedEmployee = _employees.firstWhere(
        (emp) => emp['uid'] == _selectedEmployeeId,
      );

      // Get the actual folder path from employee folder service
      final employeeFolderService = EmployeeFolderService();
      final employeeId = selectedEmployee['employeeId'] as String;
      final fullName = selectedEmployee['displayName'] as String;

      // Get the correct folder path structure
      final folderStructure = await employeeFolderService
          .getEmployeeFolderStructure(employeeId);

      String actualFolderPath;
      if (folderStructure != null &&
          folderStructure['createdFolders'] != null) {
        // Use the actual folder path from the structure
        final createdFolders =
            folderStructure['createdFolders'] as Map<String, dynamic>;
        actualFolderPath =
            createdFolders[_selectedFolderCode] as String? ??
            'employees/${employeeId}_${_sanitizeFolderName(fullName)}/${_selectedFolderCode}_${_folderTypes.firstWhere((f) => f['code'] == _selectedFolderCode)['name']}';
      } else {
        // Fallback: construct the path manually
        actualFolderPath =
            'employees/${employeeId}_${_sanitizeFolderName(fullName)}/${_selectedFolderCode}_${_folderTypes.firstWhere((f) => f['code'] == _selectedFolderCode)['name']}';
      }

      // Use the actual folder path as folderId to bypass the document service path generation
      // We'll pass the full path as folderId and modify the upload to handle this correctly
      final folderId = actualFolderPath;

      if (kIsWeb && _selectedPlatformFile != null) {
        await ref
            .read(uploadDocumentProvider.notifier)
            .uploadFromBytes(
              bytes: _selectedPlatformFile!.bytes!,
              fileName: _selectedPlatformFile!.name,
              category: DocumentCategory.employee,
              accessLevel: DocumentAccessLevel.private,
              description: _descriptionController.text.trim(),
              folderId: folderId,
              tags: tags,
              requiresApproval: _requiresApproval,
            );
      } else if (_selectedFile != null) {
        await ref
            .read(uploadDocumentProvider.notifier)
            .uploadFile(
              file: _selectedFile!,
              category: DocumentCategory.employee,
              accessLevel: DocumentAccessLevel.private,
              description: _descriptionController.text.trim(),
              folderId: folderId,
              tags: tags,
              requiresApproval: _requiresApproval,
            );
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Document uploaded successfully to ${selectedEmployee['displayName']}\'s ${_formatFolderName(_folderTypes.firstWhere((f) => f['code'] == _selectedFolderCode)['name']!)} folder',
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload document: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String _sanitizeFolderName(String name) {
    return name
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .trim();
  }

  String _formatFolderName(String folderName) {
    if (folderName.isEmpty) {
      return 'Unknown Folder';
    }
    return folderName
        .split('-')
        .where((word) => word.isNotEmpty) // Filter out empty words
        .map(
          (word) =>
              word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '',
        )
        .where((word) => word.isNotEmpty) // Filter out empty results
        .join(' ');
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
