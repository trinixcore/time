import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/permission_config_model.dart';
import '../../../core/enums/document_enums.dart';
import '../../../core/services/permission_management_service.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../shared/widgets/password_confirmation_dialog.dart';
import '../../../shared/providers/page_access_providers.dart';

/// Dialog for editing role permissions
class PermissionEditDialog extends ConsumerStatefulWidget {
  final PermissionConfigModel config;

  const PermissionEditDialog({super.key, required this.config});

  @override
  ConsumerState<PermissionEditDialog> createState() =>
      _PermissionEditDialogState();
}

class _PermissionEditDialogState extends ConsumerState<PermissionEditDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late PermissionConfigModel _editedConfig;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _editedConfig = widget.config;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
        child: Column(
          children: [
            _buildHeader(theme),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDocumentPermissionsTab(theme),
                  _buildSystemPermissionsTab(theme),
                ],
              ),
            ),
            _buildActions(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.admin_panel_settings,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Permissions',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Configure permissions for ${_editedConfig.role.displayName}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.folder), text: 'Document Permissions'),
              Tab(icon: Icon(Icons.settings), text: 'System Permissions'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentPermissionsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(theme, 'Core Document Permissions'),
          const SizedBox(height: 12),
          _buildDocumentCorePermissions(theme),
          const SizedBox(height: 24),
          _buildSectionTitle(theme, 'My Documents Permissions'),
          const SizedBox(height: 12),
          _buildEmployeeDocumentPermissions(theme),
          const SizedBox(height: 24),
          _buildSectionTitle(theme, 'Accessible Categories'),
          const SizedBox(height: 12),
          _buildAccessibleCategories(theme),
          const SizedBox(height: 16),
          _buildUploadableCategories(theme),
          const SizedBox(height: 16),
          _buildDeletableCategories(theme),
          const SizedBox(height: 16),
          _buildFileTypeRestrictions(theme),
          const SizedBox(height: 24),
          _buildSectionTitle(theme, 'File Size Limits'),
          const SizedBox(height: 12),
          _buildFileSizeLimits(theme),
        ],
      ),
    );
  }

  Widget _buildSystemPermissionsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Access Permissions (Primary Level)
          _buildSectionTitle(theme, 'Page Access Control', isPrimary: true),
          const SizedBox(height: 8),
          Text(
            'Control which pages users with this role can access. This is the first-level check before feature permissions.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          _buildPageAccessPermissions(theme),
          const SizedBox(height: 24),

          // Employee ID-Based Access Control
          _buildSectionTitle(theme, 'Employee ID-Based Access Control'),
          const SizedBox(height: 8),
          Text(
            'Additional restrictions based on specific employee IDs. This works in conjunction with page access permissions.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          _buildEmployeeIdAccessControl(theme),
          const SizedBox(height: 32),

          // Divider
          Divider(color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 16),

          // Traditional System Permissions (Secondary Level)
          _buildSectionTitle(
            theme,
            'Feature-Level Permissions',
            isSecondary: true,
          ),
          const SizedBox(height: 8),
          Text(
            'These permissions control specific features within accessible pages. They only apply if the user can access the corresponding page.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionTitle(theme, 'Core System Permissions'),
          const SizedBox(height: 12),
          _buildSystemCorePermissions(theme),
          const SizedBox(height: 24),
          _buildSectionTitle(theme, 'User Management'),
          const SizedBox(height: 12),
          _buildUserManagementPermissions(theme),
          const SizedBox(height: 24),
          _buildSectionTitle(theme, 'Employee Management'),
          const SizedBox(height: 12),
          _buildEmployeeManagementPermissions(theme),
          const SizedBox(height: 24),
          _buildSectionTitle(theme, 'Task & Project Management'),
          const SizedBox(height: 12),
          _buildTaskProjectPermissions(theme),
          const SizedBox(height: 24),
          _buildSectionTitle(theme, 'Signature Management'),
          const SizedBox(height: 12),
          _buildSignatureManagementPermissions(theme),
          const SizedBox(height: 24),
          _buildSectionTitle(theme, 'Reports & Analytics'),
          const SizedBox(height: 12),
          _buildReportsAnalyticsPermissions(theme),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    ThemeData theme,
    String title, {
    bool isPrimary = false,
    bool isSecondary = false,
  }) {
    Color color = theme.colorScheme.primary;
    if (isPrimary) {
      color = theme.colorScheme.error; // Red for primary/most important
    } else if (isSecondary) {
      color = theme.colorScheme.secondary; // Secondary color for feature-level
    }

    return Row(
      children: [
        if (isPrimary)
          Icon(Icons.security, color: color, size: 24)
        else if (isSecondary)
          Icon(Icons.tune, color: color, size: 20)
        else
          Icon(Icons.circle, color: color, size: 8),
        SizedBox(width: isPrimary ? 12 : (isSecondary ? 8 : 6)),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight:
                isPrimary
                    ? FontWeight.bold
                    : (isSecondary ? FontWeight.w600 : FontWeight.w500),
            color: color,
            fontSize: isPrimary ? 18 : (isSecondary ? 16 : 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentCorePermissions(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPermissionSwitch(
              theme,
              'View All Documents',
              'Can view documents in all categories',
              _editedConfig.documentConfig.canViewAll,
              (value) => _updateDocumentConfig(
                _editedConfig.documentConfig.copyWith(canViewAll: value),
              ),
            ),
            _buildPermissionSwitch(
              theme,
              'Upload to All Categories',
              'Can upload documents to any category',
              _editedConfig.documentConfig.canUploadToAll,
              (value) => _updateDocumentConfig(
                _editedConfig.documentConfig.copyWith(canUploadToAll: value),
              ),
            ),
            _buildPermissionSwitch(
              theme,
              'Delete Any Document',
              'Can delete documents uploaded by others',
              _editedConfig.documentConfig.canDeleteAny,
              (value) => _updateDocumentConfig(
                _editedConfig.documentConfig.copyWith(canDeleteAny: value),
              ),
            ),
            _buildPermissionSwitch(
              theme,
              'Manage Permissions',
              'Can modify document access permissions',
              _editedConfig.documentConfig.canManagePermissions,
              (value) => _updateDocumentConfig(
                _editedConfig.documentConfig.copyWith(
                  canManagePermissions: value,
                ),
              ),
            ),
            _buildPermissionSwitch(
              theme,
              'Create Folders',
              'Can create new document folders',
              _editedConfig.documentConfig.canCreateFolders,
              (value) => _updateDocumentConfig(
                _editedConfig.documentConfig.copyWith(canCreateFolders: value),
              ),
            ),
            _buildPermissionSwitch(
              theme,
              'Archive Documents',
              'Can archive and restore documents',
              _editedConfig.documentConfig.canArchiveDocuments,
              (value) => _updateDocumentConfig(
                _editedConfig.documentConfig.copyWith(
                  canArchiveDocuments: value,
                ),
              ),
            ),
            _buildPermissionSwitch(
              theme,
              'Upload to Employee Documents',
              'Can upload documents to employee folders from My Documents page',
              _editedConfig.documentConfig.canUploadToEmployeeDocuments,
              (value) => _updateDocumentConfig(
                _editedConfig.documentConfig.copyWith(
                  canUploadToEmployeeDocuments: value,
                ),
              ),
            ),
            _buildPermissionSwitch(
              theme,
              'View as Employee',
              'Can view documents of other employees in My Documents page',
              _editedConfig.documentConfig.canViewAsEmployee,
              (value) => _updateDocumentConfig(
                _editedConfig.documentConfig.copyWith(canViewAsEmployee: value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeDocumentPermissions(ThemeData theme) {
    // Employee folder structure from the service
    final employeeFolders = [
      {
        'code': '01',
        'name': 'offer-letter',
        'description': 'Offer letter and employment contract',
      },
      {
        'code': '02',
        'name': 'payslips',
        'description': 'Monthly payslips and salary documents',
      },
      {
        'code': '03',
        'name': 'appraisal',
        'description': 'Performance appraisal documents',
      },
      {
        'code': '04',
        'name': 'resignation',
        'description': 'Resignation letter and exit documents',
      },
      {
        'code': '05',
        'name': 'kyc-documents',
        'description': 'KYC and identity verification documents',
      },
      {
        'code': '06',
        'name': 'employment-verification',
        'description': 'Employment verification letters',
      },
      {
        'code': '07',
        'name': 'policies-acknowledged',
        'description': 'Acknowledged company policies',
      },
      {
        'code': '08',
        'name': 'training-certificates',
        'description': 'Training and certification documents',
      },
      {
        'code': '09',
        'name': 'leave-documents',
        'description': 'Leave applications and approvals',
      },
      {
        'code': '10',
        'name': 'loan-agreements',
        'description': 'Loan agreements and financial documents',
      },
      {
        'code': '11',
        'name': 'infra-assets',
        'description': 'Infrastructure and asset allocation documents',
      },
      {
        'code': '12',
        'name': 'performance-warnings',
        'description': 'Performance improvement and warning letters',
      },
      {
        'code': '13',
        'name': 'awards-recognition',
        'description': 'Awards and recognition certificates',
      },
      {
        'code': '14',
        'name': 'feedbacks-surveys',
        'description': 'Feedback forms and survey responses',
      },
      {
        'code': '15',
        'name': 'exit-clearance',
        'description': 'Exit clearance and handover documents',
      },
      {
        'code': '99',
        'name': 'personal',
        'description': 'Personal documents and miscellaneous files',
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.folder_shared,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Employee Folder Permissions:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Control access to specific employee document folders in My Documents page',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Master controls
            Row(
              children: [
                Expanded(
                  child: _buildPermissionSwitch(
                    theme,
                    'View as Employee',
                    'Can view documents of other employees in My Documents page',
                    _editedConfig.documentConfig.canViewAsEmployee,
                    (value) => _updateDocumentConfig(
                      _editedConfig.documentConfig.copyWith(
                        canViewAsEmployee: value,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPermissionSwitch(
                    theme,
                    'Enable All Employee Folders',
                    'Grant access to all employee document folders',
                    _editedConfig.documentConfig.uploadableCategories.contains(
                      DocumentCategory.employee,
                    ),
                    (value) {
                      final categories = List<DocumentCategory>.from(
                        _editedConfig.documentConfig.uploadableCategories,
                      );
                      if (value) {
                        if (!categories.contains(DocumentCategory.employee)) {
                          categories.add(DocumentCategory.employee);
                        }
                      } else {
                        categories.remove(DocumentCategory.employee);
                      }
                      _updateDocumentConfig(
                        _editedConfig.documentConfig.copyWith(
                          uploadableCategories: categories,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Folder-specific permissions table
            Text(
              'Folder-Specific Permissions:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Header row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Expanded(
                    flex: 3,
                    child: Text(
                      'Folder',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Expanded(
                    flex: 1,
                    child: Text(
                      'View',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Expanded(
                    flex: 1,
                    child: Text(
                      'Upload',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Expanded(
                    flex: 1,
                    child: Text(
                      'Delete',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Folder rows
            ...employeeFolders.map(
              (folder) => _buildFolderPermissionRow(
                theme,
                folder['code']!,
                folder['name']!,
                folder['description']!,
              ),
            ),

            const SizedBox(height: 16),

            // Bulk actions
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _setAllFolderPermissions(true, 'view'),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('Enable All View'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade100,
                    foregroundColor: Colors.green.shade800,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _setAllFolderPermissions(true, 'upload'),
                  icon: const Icon(Icons.upload, size: 16),
                  label: const Text('Enable All Upload'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade100,
                    foregroundColor: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _setAllFolderPermissions(true, 'delete'),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Enable All Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade100,
                    foregroundColor: Colors.red.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _setAllFolderPermissions(false, 'all'),
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('Disable All'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFolderPermissionRow(
    ThemeData theme,
    String folderCode,
    String folderName,
    String description,
  ) {
    final folderKey = '${folderCode}_$folderName';

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getFolderIcon(folderCode),
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      folderName.replaceAll('-', ' ').toUpperCase(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Switch(
                value:
                    _editedConfig
                        .documentConfig
                        .employeeFolderViewPermissions[folderKey] ??
                    false,
                onChanged:
                    (value) =>
                        _updateFolderPermission(folderKey, 'view', value),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Switch(
                value:
                    _editedConfig
                        .documentConfig
                        .employeeFolderUploadPermissions[folderKey] ??
                    false,
                onChanged:
                    (value) =>
                        _updateFolderPermission(folderKey, 'upload', value),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Switch(
                value:
                    _editedConfig
                        .documentConfig
                        .employeeFolderDeletePermissions[folderKey] ??
                    false,
                onChanged:
                    (value) =>
                        _updateFolderPermission(folderKey, 'delete', value),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFolderIcon(String folderCode) {
    switch (folderCode) {
      case '01':
        return Icons.assignment;
      case '02':
        return Icons.receipt;
      case '03':
        return Icons.star;
      case '04':
        return Icons.exit_to_app;
      case '05':
        return Icons.verified_user;
      case '06':
        return Icons.work;
      case '07':
        return Icons.policy;
      case '08':
        return Icons.school;
      case '09':
        return Icons.event_available;
      case '10':
        return Icons.account_balance;
      case '11':
        return Icons.devices;
      case '12':
        return Icons.warning;
      case '13':
        return Icons.emoji_events;
      case '14':
        return Icons.feedback;
      case '15':
        return Icons.check_circle;
      case '99':
        return Icons.person;
      default:
        return Icons.folder;
    }
  }

  void _updateFolderPermission(
    String folderKey,
    String permissionType,
    bool value,
  ) {
    Map<String, bool> viewPermissions = Map.from(
      _editedConfig.documentConfig.employeeFolderViewPermissions,
    );
    Map<String, bool> uploadPermissions = Map.from(
      _editedConfig.documentConfig.employeeFolderUploadPermissions,
    );
    Map<String, bool> deletePermissions = Map.from(
      _editedConfig.documentConfig.employeeFolderDeletePermissions,
    );

    switch (permissionType) {
      case 'view':
        viewPermissions[folderKey] = value;
        // If disabling view, also disable upload and delete
        if (!value) {
          uploadPermissions[folderKey] = false;
          deletePermissions[folderKey] = false;
        }
        break;
      case 'upload':
        uploadPermissions[folderKey] = value;
        // If enabling upload, also enable view
        if (value) {
          viewPermissions[folderKey] = true;
        }
        break;
      case 'delete':
        deletePermissions[folderKey] = value;
        // If enabling delete, also enable view (you can't delete what you can't see)
        if (value) {
          viewPermissions[folderKey] = true;
        }
        break;
    }

    _updateDocumentConfig(
      _editedConfig.documentConfig.copyWith(
        employeeFolderViewPermissions: viewPermissions,
        employeeFolderUploadPermissions: uploadPermissions,
        employeeFolderDeletePermissions: deletePermissions,
      ),
    );
  }

  void _setAllFolderPermissions(bool value, String permissionType) {
    final employeeFolders = [
      '01_offer-letter',
      '02_payslips',
      '03_appraisal',
      '04_resignation',
      '05_kyc-documents',
      '06_employment-verification',
      '07_policies-acknowledged',
      '08_training-certificates',
      '09_leave-documents',
      '10_loan-agreements',
      '11_infra-assets',
      '12_performance-warnings',
      '13_awards-recognition',
      '14_feedbacks-surveys',
      '15_exit-clearance',
      '99_personal',
    ];

    Map<String, bool> viewPermissions = Map.from(
      _editedConfig.documentConfig.employeeFolderViewPermissions,
    );
    Map<String, bool> uploadPermissions = Map.from(
      _editedConfig.documentConfig.employeeFolderUploadPermissions,
    );
    Map<String, bool> deletePermissions = Map.from(
      _editedConfig.documentConfig.employeeFolderDeletePermissions,
    );

    for (final folderKey in employeeFolders) {
      switch (permissionType) {
        case 'view':
          viewPermissions[folderKey] = value;
          // If disabling view, also disable upload and delete
          if (!value) {
            uploadPermissions[folderKey] = false;
            deletePermissions[folderKey] = false;
          }
          break;
        case 'upload':
          uploadPermissions[folderKey] = value;
          // If enabling upload, also enable view
          if (value) {
            viewPermissions[folderKey] = true;
          }
          break;
        case 'delete':
          deletePermissions[folderKey] = value;
          // If enabling delete, also enable view
          if (value) {
            viewPermissions[folderKey] = true;
          }
          break;
        case 'all':
          viewPermissions[folderKey] = value;
          uploadPermissions[folderKey] = value;
          deletePermissions[folderKey] = value;
          break;
      }
    }

    _updateDocumentConfig(
      _editedConfig.documentConfig.copyWith(
        employeeFolderViewPermissions: viewPermissions,
        employeeFolderUploadPermissions: uploadPermissions,
        employeeFolderDeletePermissions: deletePermissions,
      ),
    );
  }

  Widget _buildAccessibleCategories(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select accessible document categories:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  DocumentCategory.values.map((category) {
                    final isSelected = _editedConfig
                        .documentConfig
                        .accessibleCategories
                        .contains(category);
                    return FilterChip(
                      label: Text(category.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        final categories = List<DocumentCategory>.from(
                          _editedConfig.documentConfig.accessibleCategories,
                        );
                        if (selected) {
                          categories.add(category);
                        } else {
                          categories.remove(category);
                        }
                        _updateDocumentConfig(
                          _editedConfig.documentConfig.copyWith(
                            accessibleCategories: categories,
                          ),
                        );
                      },
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadableCategories(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select uploadable document categories:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  DocumentCategory.values.map((category) {
                    final isSelected = _editedConfig
                        .documentConfig
                        .uploadableCategories
                        .contains(category);
                    return FilterChip(
                      label: Text(category.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        final categories = List<DocumentCategory>.from(
                          _editedConfig.documentConfig.uploadableCategories,
                        );
                        if (selected) {
                          categories.add(category);
                        } else {
                          categories.remove(category);
                        }
                        _updateDocumentConfig(
                          _editedConfig.documentConfig.copyWith(
                            uploadableCategories: categories,
                          ),
                        );
                      },
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeletableCategories(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select deletable document categories:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  DocumentCategory.values.map((category) {
                    final isSelected = _editedConfig
                        .documentConfig
                        .deletableCategories
                        .contains(category);
                    return FilterChip(
                      label: Text(category.displayName),
                      selected: isSelected,
                      selectedColor: theme.colorScheme.errorContainer,
                      checkmarkColor: theme.colorScheme.onErrorContainer,
                      onSelected: (selected) {
                        final categories = List<DocumentCategory>.from(
                          _editedConfig.documentConfig.deletableCategories,
                        );
                        if (selected) {
                          categories.add(category);
                        } else {
                          categories.remove(category);
                        }
                        _updateDocumentConfig(
                          _editedConfig.documentConfig.copyWith(
                            deletableCategories: categories,
                          ),
                        );
                      },
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileTypeRestrictions(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Allowed file types:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  DocumentFileType.values.map((fileType) {
                    final isSelected = _editedConfig
                        .documentConfig
                        .allowedFileTypes
                        .contains(fileType);
                    return FilterChip(
                      label: Text(fileType.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        final fileTypes = List<DocumentFileType>.from(
                          _editedConfig.documentConfig.allowedFileTypes,
                        );
                        if (selected) {
                          fileTypes.add(fileType);
                        } else {
                          fileTypes.remove(fileType);
                        }
                        _updateDocumentConfig(
                          _editedConfig.documentConfig.copyWith(
                            allowedFileTypes: fileTypes,
                          ),
                        );
                      },
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileSizeLimits(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Maximum file size (MB):',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Slider(
              value: _editedConfig.documentConfig.maxFileSizeMB
                  .toDouble()
                  .clamp(1, 1000),
              min: 1,
              max: 1000,
              divisions: 999,
              label: '${_editedConfig.documentConfig.maxFileSizeMB} MB',
              onChanged: (value) {
                _updateDocumentConfig(
                  _editedConfig.documentConfig.copyWith(
                    maxFileSizeMB: value.round(),
                  ),
                );
              },
            ),
            Text(
              'Current limit: ${_editedConfig.documentConfig.maxFileSizeMB} MB',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemCorePermissions(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPermissionSwitch(
              theme,
              'Manage System',
              'Full system administration access',
              _editedConfig.systemConfig.canManageSystem,
              (value) => _updateSystemConfig(
                _editedConfig.systemConfig.copyWith(canManageSystem: value),
              ),
            ),
            _buildPermissionSwitch(
              theme,
              'Access Admin Panel',
              'Can access administrative interface',
              _editedConfig.systemConfig.canAccessAdminPanel,
              (value) => _updateSystemConfig(
                _editedConfig.systemConfig.copyWith(canAccessAdminPanel: value),
              ),
            ),
            _buildPermissionSwitch(
              theme,
              'Delegate Roles',
              'Can assign roles to other users',
              _editedConfig.systemConfig.canDelegateRoles,
              (value) => _updateSystemConfig(
                _editedConfig.systemConfig.copyWith(canDelegateRoles: value),
              ),
            ),
            _buildPermissionSwitch(
              theme,
              'Manage Company Settings',
              'Can modify company-wide settings',
              _editedConfig.systemConfig.canManageCompanySettings,
              (value) => _updateSystemConfig(
                _editedConfig.systemConfig.copyWith(
                  canManageCompanySettings: value,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserManagementPermissions(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPermissionSwitch(
              theme,
              'Manage Users',
              'Can manage user accounts and access',
              _editedConfig.systemConfig.canManageUsers,
              (value) => _updateSystemConfig(
                _editedConfig.systemConfig.copyWith(canManageUsers: value),
              ),
            ),
            _buildPermissionSwitch(
              theme,
              'Create User Accounts',
              'Can create new user accounts (via Admin/Users page)',
              _editedConfig.systemConfig.canCreateUsers,
              (value) => _updateSystemConfig(
                _editedConfig.systemConfig.copyWith(canCreateUsers: value),
              ),
            ),
            _buildPermissionSwitch(
              theme,
              'Deactivate Users',
              'Can deactivate user accounts',
              _editedConfig.systemConfig.canDeactivateUsers,
              (value) => _updateSystemConfig(
                _editedConfig.systemConfig.copyWith(canDeactivateUsers: value),
              ),
            ),
            _buildPermissionSwitch(
              theme,
              'View All Users',
              'Can view all user profiles and information',
              _editedConfig.systemConfig.canViewAllUsers,
              (value) => _updateSystemConfig(
                _editedConfig.systemConfig.copyWith(canViewAllUsers: value),
              ),
            ),
            _buildPermissionSwitch(
              theme,
              'Assign Roles',
              'Can assign roles to users',
              _editedConfig.systemConfig.canAssignRoles,
              (value) => _updateSystemConfig(
                _editedConfig.systemConfig.copyWith(canAssignRoles: value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeManagementPermissions(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Parent permission
            _buildPermissionSwitch(
              theme,
              'Manage Employees',
              'Master switch for employee management (automatically enabled if specific permissions are granted)',
              _editedConfig.systemConfig.canManageEmployees ||
                  _editedConfig.systemConfig.canAddEmployees ||
                  _editedConfig.systemConfig.canViewEmployeeDetails ||
                  _editedConfig.systemConfig.canEditEmployeeProfiles ||
                  _editedConfig.systemConfig.canManageEmployeeDocuments,
              (value) {
                // When enabling/disabling master switch, update all related permissions
                _updateSystemConfig(
                  _editedConfig.systemConfig.copyWith(
                    canManageEmployees: value,
                    canAddEmployees:
                        value
                            ? _editedConfig.systemConfig.canAddEmployees
                            : false,
                    canViewEmployeeDetails:
                        value
                            ? _editedConfig.systemConfig.canViewEmployeeDetails
                            : false,
                    canEditEmployeeProfiles:
                        value
                            ? _editedConfig.systemConfig.canEditEmployeeProfiles
                            : false,
                    canManageEmployeeDocuments:
                        value
                            ? _editedConfig
                                .systemConfig
                                .canManageEmployeeDocuments
                            : false,
                  ),
                );
              },
            ),
            const Divider(height: 24),
            // Specific permissions
            _buildPermissionSwitch(
              theme,
              'Add New Employees',
              'Can add new employees to the system (via Employees page)',
              _editedConfig.systemConfig.canAddEmployees,
              (value) {
                _updateSystemConfig(
                  _editedConfig.systemConfig.copyWith(
                    canAddEmployees: value,
                    // Auto-enable parent permission if any specific permission is enabled
                    canManageEmployees:
                        value ||
                        _editedConfig.systemConfig.canViewEmployeeDetails ||
                        _editedConfig.systemConfig.canEditEmployeeProfiles ||
                        _editedConfig.systemConfig.canManageEmployeeDocuments,
                  ),
                );
              },
            ),
            _buildPermissionSwitch(
              theme,
              'View Employee Details',
              'Can view detailed employee information',
              _editedConfig.systemConfig.canViewEmployeeDetails,
              (value) {
                _updateSystemConfig(
                  _editedConfig.systemConfig.copyWith(
                    canViewEmployeeDetails: value,
                    // Auto-enable parent permission if any specific permission is enabled
                    canManageEmployees:
                        value ||
                        _editedConfig.systemConfig.canAddEmployees ||
                        _editedConfig.systemConfig.canEditEmployeeProfiles ||
                        _editedConfig.systemConfig.canManageEmployeeDocuments,
                  ),
                );
              },
            ),
            _buildPermissionSwitch(
              theme,
              'Edit Employee Profiles',
              'Can edit employee profile information',
              _editedConfig.systemConfig.canEditEmployeeProfiles,
              (value) {
                _updateSystemConfig(
                  _editedConfig.systemConfig.copyWith(
                    canEditEmployeeProfiles: value,
                    // Auto-enable parent permission if any specific permission is enabled
                    canManageEmployees:
                        value ||
                        _editedConfig.systemConfig.canAddEmployees ||
                        _editedConfig.systemConfig.canViewEmployeeDetails ||
                        _editedConfig.systemConfig.canManageEmployeeDocuments,
                  ),
                );
              },
            ),
            _buildPermissionSwitch(
              theme,
              'Manage Employee Documents',
              'Can manage employee document access',
              _editedConfig.systemConfig.canManageEmployeeDocuments,
              (value) {
                _updateSystemConfig(
                  _editedConfig.systemConfig.copyWith(
                    canManageEmployeeDocuments: value,
                    // Auto-enable parent permission if any specific permission is enabled
                    canManageEmployees:
                        value ||
                        _editedConfig.systemConfig.canAddEmployees ||
                        _editedConfig.systemConfig.canViewEmployeeDetails ||
                        _editedConfig.systemConfig.canEditEmployeeProfiles,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskProjectPermissions(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPermissionSwitch(
              theme,
              'Manage Tasks',
              'Can create and manage tasks',
              _editedConfig.systemConfig.canManageTasks,
              (value) => _updateSystemConfig(
                _editedConfig.systemConfig.copyWith(canManageTasks: value),
              ),
            ),
            _buildPermissionSwitch(
              theme,
              'Create Tasks',
              'Can create new tasks',
              _editedConfig.systemConfig.canCreateTasks,
              (value) => _updateSystemConfig(
                _editedConfig.systemConfig.copyWith(canCreateTasks: value),
              ),
            ),
            _buildPermissionSwitch(
              theme,
              'Delete Tasks',
              'Can delete tasks',
              _editedConfig.systemConfig.canDeleteTasks,
              (value) => _updateSystemConfig(
                _editedConfig.systemConfig.copyWith(canDeleteTasks: value),
              ),
            ),
            _buildPermissionSwitch(
              theme,
              'Delete Task Documents',
              'Can delete documents uploaded to tasks (by default, only document uploader can delete)',
              _editedConfig.systemConfig.canDeleteTaskDocuments,
              (value) => _updateSystemConfig(
                _editedConfig.systemConfig.copyWith(
                  canDeleteTaskDocuments: value,
                ),
              ),
            ),
            _buildPermissionSwitch(
              theme,
              'Assign Tasks',
              'Can assign tasks to team members',
              _editedConfig.systemConfig.canAssignTasks,
              (value) => _updateSystemConfig(
                _editedConfig.systemConfig.copyWith(canAssignTasks: value),
              ),
            ),
            _buildPermissionSwitch(
              theme,
              'View Team Tasks',
              'Can view tasks assigned to team members',
              _editedConfig.systemConfig.canViewTeamTasks,
              (value) => _updateSystemConfig(
                _editedConfig.systemConfig.copyWith(canViewTeamTasks: value),
              ),
            ),
            _buildPermissionSwitch(
              theme,
              'Create Projects',
              'Can create new projects',
              _editedConfig.systemConfig.canCreateProjects,
              (value) => _updateSystemConfig(
                _editedConfig.systemConfig.copyWith(canCreateProjects: value),
              ),
            ),
            _buildPermissionSwitch(
              theme,
              'Manage Projects',
              'Can manage project settings and members',
              _editedConfig.systemConfig.canManageProjects,
              (value) => _updateSystemConfig(
                _editedConfig.systemConfig.copyWith(canManageProjects: value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignatureManagementPermissions(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPermissionSwitch(
              theme,
              'Manage Signatures',
              'Can manage digital signatures and signature workflows',
              _editedConfig.systemConfig.canManageSignatures,
              (value) => _updateSystemConfig(
                _editedConfig.systemConfig.copyWith(canManageSignatures: value),
              ),
            ),
            _buildPermissionSwitch(
              theme,
              'Add Signatures',
              'Can add new digital signatures to the system',
              _editedConfig.systemConfig.canAddSignatures,
              (value) => _updateSystemConfig(
                _editedConfig.systemConfig.copyWith(canAddSignatures: value),
              ),
            ),
            _buildPermissionSwitch(
              theme,
              'Edit Signatures',
              'Can edit existing digital signatures',
              _editedConfig.systemConfig.canEditSignatures,
              (value) => _updateSystemConfig(
                _editedConfig.systemConfig.copyWith(canEditSignatures: value),
              ),
            ),
            _buildPermissionSwitch(
              theme,
              'Delete Signatures',
              'Can delete digital signatures',
              _editedConfig.systemConfig.canDeleteSignatures,
              (value) => _updateSystemConfig(
                _editedConfig.systemConfig.copyWith(canDeleteSignatures: value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsAnalyticsPermissions(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPermissionSwitch(
              theme,
              'View Reports',
              'Can view system and business reports',
              _editedConfig.systemConfig.canViewReports,
              (value) => _updateSystemConfig(
                _editedConfig.systemConfig.copyWith(canViewReports: value),
              ),
            ),
            _buildPermissionSwitch(
              theme,
              'Generate Reports',
              'Can generate custom reports',
              _editedConfig.systemConfig.canGenerateReports,
              (value) => _updateSystemConfig(
                _editedConfig.systemConfig.copyWith(canGenerateReports: value),
              ),
            ),
            _buildPermissionSwitch(
              theme,
              'View Analytics',
              'Can access analytics dashboard',
              _editedConfig.systemConfig.canViewAnalytics,
              (value) => _updateSystemConfig(
                _editedConfig.systemConfig.copyWith(canViewAnalytics: value),
              ),
            ),
            _buildPermissionSwitch(
              theme,
              'Export Data',
              'Can export data and reports',
              _editedConfig.systemConfig.canExportData,
              (value) => _updateSystemConfig(
                _editedConfig.systemConfig.copyWith(canExportData: value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionSwitch(
    ThemeData theme,
    String title,
    String description,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          const Spacer(),
          TextButton(
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _isSaving ? null : _saveChanges,
            child:
                _isSaving
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;

    try {
      // First, show password confirmation dialog
      final confirmed = await showPasswordConfirmationDialog(
        context: context,
        title: 'Confirm Permission Changes',
        message:
            'Please enter your password to confirm these permission changes for ${widget.config.role.displayName} role.',
        actionButtonText: 'Save Changes',
        onConfirmed: () {
          // This callback will be called after successful password verification
          // The actual save logic will be in the main try block
        },
      );

      if (!confirmed) {
        // User cancelled or password was incorrect
        return;
      }

      setState(() {
        _isSaving = true;
      });

      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final permissionService = PermissionManagementService();

      // Save using the correct method signature (3 parameters)
      await permissionService.savePermissionConfig(
        _editedConfig,
        currentUser.uid,
        currentUser.displayName ?? currentUser.email ?? 'Unknown User',
      );

      // Clear page access cache to ensure changes take effect immediately
      ref.read(clearPageAccessCacheProvider)();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Permission settings saved successfully for ${widget.config.role.displayName} role!',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Close the dialog and return true to indicate success
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      print('❌ Error saving permissions: $e');

      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Failed to save permission settings: ${e.toString()}',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _updateDocumentConfig(DocumentPermissionConfig newConfig) {
    setState(() {
      _editedConfig = _editedConfig.copyWith(documentConfig: newConfig);
    });
  }

  void _updateSystemConfig(SystemPermissionConfig newConfig) {
    setState(() {
      _editedConfig = _editedConfig.copyWith(systemConfig: newConfig);
    });
  }

  Widget _buildPageAccessPermissions(ThemeData theme) {
    final pagePerms = _editedConfig.systemConfig.pagePermissions;

    return Card(
      elevation: 2,
      color: theme.colorScheme.errorContainer.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.web, color: theme.colorScheme.error, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Page Access Permissions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Core Pages
            _buildPagePermissionSection(theme, 'Core Pages', Icons.dashboard, [
              _PagePermissionItem(
                'Dashboard',
                'Main dashboard with overview and quick actions',
                Icons.dashboard,
                pagePerms.canAccessDashboard,
                (value) => _updatePagePermissions(
                  pagePerms.copyWith(canAccessDashboard: value),
                ),
              ),
              _PagePermissionItem(
                'Profile',
                'User profile management and settings',
                Icons.person,
                pagePerms.canAccessProfile,
                (value) => _updatePagePermissions(
                  pagePerms.copyWith(canAccessProfile: value),
                ),
              ),
            ]),

            const SizedBox(height: 20),

            // Employee & HR Pages
            _buildPagePermissionSection(
              theme,
              'Employee & HR Pages',
              Icons.people,
              [
                _PagePermissionItem(
                  'Employees',
                  'Employee directory and management',
                  Icons.people,
                  pagePerms.canAccessEmployees,
                  (value) => _updatePagePermissions(
                    pagePerms.copyWith(canAccessEmployees: value),
                  ),
                ),
                _PagePermissionItem(
                  'Org Chart',
                  'Organizational chart and hierarchy',
                  Icons.account_tree,
                  pagePerms.canAccessOrgChart,
                  (value) => _updatePagePermissions(
                    pagePerms.copyWith(canAccessOrgChart: value),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Document Pages
            _buildPagePermissionSection(
              theme,
              'Document Management',
              Icons.folder,
              [
                _PagePermissionItem(
                  'My Documents',
                  'Personal employee document folders',
                  Icons.folder_special,
                  pagePerms.canAccessMyDocuments,
                  (value) => _updatePagePermissions(
                    pagePerms.copyWith(canAccessMyDocuments: value),
                  ),
                ),
                _PagePermissionItem(
                  'Documents',
                  'General document library and shared files',
                  Icons.description,
                  pagePerms.canAccessDocuments,
                  (value) => _updatePagePermissions(
                    pagePerms.copyWith(canAccessDocuments: value),
                  ),
                ),
                // --- Letters & Signatures Toggle ---
                _PagePermissionItem(
                  'Letters & Signatures',
                  'Letter generation, signature workflows, and PDF management',
                  Icons.mail,
                  pagePerms.canAccessLetters,
                  (value) => _updatePagePermissions(
                    pagePerms.copyWith(canAccessLetters: value),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Work Management Pages
            _buildPagePermissionSection(theme, 'Work Management', Icons.work, [
              _PagePermissionItem(
                'Tasks',
                'Task management and project tracking',
                Icons.task,
                pagePerms.canAccessTasks,
                (value) => _updatePagePermissions(
                  pagePerms.copyWith(canAccessTasks: value),
                ),
              ),
              _PagePermissionItem(
                'Leaves',
                'Leave requests and attendance management',
                Icons.event_available,
                pagePerms.canAccessLeaves,
                (value) => _updatePagePermissions(
                  pagePerms.copyWith(canAccessLeaves: value),
                ),
              ),
            ]),

            const SizedBox(height: 20),

            // Admin Pages
            _buildPagePermissionSection(
              theme,
              'Administration',
              Icons.admin_panel_settings,
              [
                _PagePermissionItem(
                  'User Management',
                  'Create and manage user accounts',
                  Icons.manage_accounts,
                  pagePerms.canAccessUserManagement,
                  (value) => _updatePagePermissions(
                    pagePerms.copyWith(canAccessUserManagement: value),
                  ),
                ),
                _PagePermissionItem(
                  'Profile Approvals',
                  'Review and approve user profile changes',
                  Icons.approval,
                  pagePerms.canAccessProfileApprovals,
                  (value) => _updatePagePermissions(
                    pagePerms.copyWith(canAccessProfileApprovals: value),
                  ),
                ),
                _PagePermissionItem(
                  'System Settings',
                  'System configuration and permission management',
                  Icons.settings,
                  pagePerms.canAccessSystemSettings,
                  (value) => _updatePagePermissions(
                    pagePerms.copyWith(canAccessSystemSettings: value),
                  ),
                ),
                _PagePermissionItem(
                  'Moments',
                  'Admin dashboard carousel and announcements',
                  Icons.photo_library,
                  pagePerms.canAccessMoments,
                  (value) => _updatePagePermissions(
                    pagePerms.copyWith(canAccessMoments: value),
                  ),
                ),
                _PagePermissionItem(
                  'Audit Logs',
                  'View and analyze system audit logs',
                  Icons.security,
                  pagePerms.canAccessAuditLogs,
                  (value) => _updatePagePermissions(
                    pagePerms.copyWith(canAccessAuditLogs: value),
                  ),
                ),
                _PagePermissionItem(
                  'Dynamic Config',
                  'Manage Supabase keys and expiry times dynamically',
                  Icons.build,
                  pagePerms.canAccessDynamicConfig,
                  (value) => _updatePagePermissions(
                    pagePerms.copyWith(canAccessDynamicConfig: value),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagePermissionSection(
    ThemeData theme,
    String sectionTitle,
    IconData sectionIcon,
    List<_PagePermissionItem> permissions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(sectionIcon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              sectionTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...permissions.map(
          (permission) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildPagePermissionItem(theme, permission),
          ),
        ),
      ],
    );
  }

  Widget _buildPagePermissionItem(
    ThemeData theme,
    _PagePermissionItem permission,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              permission.enabled
                  ? theme.colorScheme.primary.withOpacity(0.3)
                  : theme.colorScheme.outlineVariant,
          width: permission.enabled ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (permission.enabled
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceVariant)
                  .withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              permission.icon,
              size: 20,
              color:
                  permission.enabled
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  permission.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color:
                        permission.enabled
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  permission.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: permission.enabled,
            onChanged: permission.onChanged,
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeIdAccessControl(ThemeData theme) {
    final pagePerms = _editedConfig.systemConfig.pagePermissions;

    return Card(
      elevation: 2,
      color: theme.colorScheme.secondaryContainer.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.badge, color: theme.colorScheme.secondary, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Employee ID-Based Restrictions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Enable/Disable Employee ID Restrictions
            SwitchListTile(
              title: Text(
                'Use Employee ID Restrictions',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Enable additional access control based on specific employee IDs',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              value: pagePerms.useEmployeeIdRestriction,
              onChanged:
                  (value) => _updatePagePermissions(
                    pagePerms.copyWith(useEmployeeIdRestriction: value),
                  ),
              activeColor: theme.colorScheme.secondary,
            ),

            if (pagePerms.useEmployeeIdRestriction) ...[
              const SizedBox(height: 20),

              // Allowed Employee IDs
              _buildEmployeeIdSection(
                theme,
                'Allowed Employee IDs',
                'Only these employee IDs can access (leave empty to allow all)',
                Icons.check_circle,
                Colors.green,
                pagePerms.allowedEmployeeIds,
                (newList) => _updatePagePermissions(
                  pagePerms.copyWith(allowedEmployeeIds: newList),
                ),
              ),

              const SizedBox(height: 20),

              // Restricted Employee IDs
              _buildEmployeeIdSection(
                theme,
                'Restricted Employee IDs',
                'These employee IDs are explicitly denied access',
                Icons.block,
                Colors.red,
                pagePerms.restrictedEmployeeIds,
                (newList) => _updatePagePermissions(
                  pagePerms.copyWith(restrictedEmployeeIds: newList),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeIdSection(
    ThemeData theme,
    String title,
    String description,
    IconData icon,
    Color color,
    List<String> employeeIds,
    Function(List<String>) onChanged,
  ) {
    final TextEditingController controller = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),

        // Add Employee ID Input
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Employee ID',
                  hintText: 'e.g., TRX2024000001',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person, color: color),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty &&
                      !employeeIds.contains(value.trim())) {
                    onChanged([...employeeIds, value.trim()]);
                    controller.clear();
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isNotEmpty && !employeeIds.contains(value)) {
                  onChanged([...employeeIds, value]);
                  controller.clear();
                }
              },
              icon: Icon(Icons.add, color: color),
              style: IconButton.styleFrom(
                backgroundColor: color.withOpacity(0.1),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Employee ID Chips
        if (employeeIds.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                employeeIds
                    .map(
                      (id) => Chip(
                        label: Text(id),
                        deleteIcon: Icon(Icons.close, size: 18, color: color),
                        onDeleted: () {
                          final newList = List<String>.from(employeeIds);
                          newList.remove(id);
                          onChanged(newList);
                        },
                        backgroundColor: color.withOpacity(0.1),
                        side: BorderSide(color: color.withOpacity(0.3)),
                      ),
                    )
                    .toList(),
          ),

        if (employeeIds.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No employee IDs specified',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _updatePagePermissions(PagePermissionConfig newPagePermissions) {
    setState(() {
      _editedConfig = _editedConfig.copyWith(
        systemConfig: _editedConfig.systemConfig.copyWith(
          pagePermissions: newPagePermissions,
        ),
      );
    });
  }
}

// Helper class for page permission items
class _PagePermissionItem {
  final String title;
  final String description;
  final IconData icon;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _PagePermissionItem(
    this.title,
    this.description,
    this.icon,
    this.enabled,
    this.onChanged,
  );
}
