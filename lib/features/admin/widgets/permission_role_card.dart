import 'package:flutter/material.dart';
import '../../../core/models/permission_config_model.dart';
import '../../../core/enums/user_role.dart';

/// Widget to display role permission configuration
class PermissionRoleCard extends StatelessWidget {
  final PermissionConfigModel config;
  final VoidCallback onEdit;
  final VoidCallback? onReset;

  const PermissionRoleCard({
    super.key,
    required this.config,
    required this.onEdit,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 16),
            _buildPermissionSummary(theme),
            const SizedBox(height: 16),
            _buildActions(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getRoleColor(config.role).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getRoleIcon(config.role),
            color: _getRoleColor(config.role),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                config.role.displayName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getRoleColor(config.role).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Level ${config.role.level}',
                      style: TextStyle(
                        color: _getRoleColor(config.role),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    config.isActive ? Icons.check_circle : Icons.cancel,
                    color: config.isActive ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    config.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: config.isActive ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
                break;
              case 'reset':
                if (onReset != null) onReset!();
                break;
            }
          },
          itemBuilder: (context) {
            final items = <PopupMenuEntry<String>>[
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 16),
                    SizedBox(width: 8),
                    Text('Edit Permissions'),
                  ],
                ),
              ),
            ];
            if (onReset != null) {
              items.add(
                const PopupMenuItem(
                  value: 'reset',
                  child: Row(
                    children: [
                      Icon(Icons.restore, size: 16, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Reset to Defaults'),
                    ],
                  ),
                ),
              );
            }
            return items;
          },
        ),
      ],
    );
  }

  Widget _buildPermissionSummary(ThemeData theme) {
    final documentPerms = config.documentConfig;
    final systemPerms = config.systemConfig;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Permission Summary',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPermissionGroup(
                theme,
                'Document Permissions',
                Icons.folder,
                [
                  _PermissionItem('View All', documentPerms.canViewAll),
                  _PermissionItem(
                    'Upload to All',
                    documentPerms.canUploadToAll,
                  ),
                  _PermissionItem('Delete Any', documentPerms.canDeleteAny),
                  _PermissionItem(
                    'Manage Permissions',
                    documentPerms.canManagePermissions,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPermissionGroup(
                theme,
                'System Permissions',
                Icons.settings,
                [
                  _PermissionItem('Manage System', systemPerms.canManageSystem),
                  _PermissionItem(
                    'Admin Panel',
                    systemPerms.canAccessAdminPanel,
                  ),
                  _PermissionItem('Manage Users', systemPerms.canManageUsers),
                  _PermissionItem('View Reports', systemPerms.canViewReports),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildQuickStats(theme),
      ],
    );
  }

  Widget _buildPermissionGroup(
    ThemeData theme,
    String title,
    IconData icon,
    List<_PermissionItem> items,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                children: [
                  Icon(
                    item.enabled ? Icons.check : Icons.close,
                    size: 12,
                    color: item.enabled ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            item.enabled
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(ThemeData theme) {
    final documentPerms = config.documentConfig;
    final systemPerms = config.systemConfig;

    final docPermCount = _countEnabledDocumentPermissions(documentPerms);
    final sysPermCount = _countEnabledSystemPermissions(systemPerms);
    final totalPermCount = docPermCount + sysPermCount;

    return Row(
      children: [
        _buildStatChip(
          theme,
          'Categories',
          '${documentPerms.accessibleCategories.length}',
          Icons.category,
          Colors.blue,
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          theme,
          'File Types',
          '${documentPerms.allowedFileTypes.length}',
          Icons.insert_drive_file,
          Colors.green,
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          theme,
          'Max Size',
          '${documentPerms.maxFileSizeMB}MB',
          Icons.data_usage,
          Colors.orange,
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          theme,
          'Total Perms',
          '$totalPermCount',
          Icons.security,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatChip(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(label, style: TextStyle(color: color, fontSize: 8)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Row(
      children: [
        Text(
          'Last updated: ${_formatDate(config.updatedAt)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: onReset,
          icon: const Icon(Icons.restore, size: 16),
          label: const Text('Reset'),
          style: TextButton.styleFrom(foregroundColor: Colors.orange),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('Edit'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.sa:
        return Colors.red;
      case UserRole.admin:
        return Colors.orange;
      case UserRole.hr:
        return Colors.blue;
      case UserRole.manager:
        return Colors.green;
      case UserRole.tl:
        return Colors.purple;
      case UserRole.se:
        return Colors.indigo;
      case UserRole.employee:
        return Colors.teal;
      case UserRole.contractor:
        return Colors.amber;
      case UserRole.intern:
        return Colors.cyan;
      case UserRole.vendor:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.sa:
        return Icons.admin_panel_settings;
      case UserRole.admin:
        return Icons.settings;
      case UserRole.hr:
        return Icons.people;
      case UserRole.manager:
        return Icons.manage_accounts;
      case UserRole.tl:
        return Icons.group;
      case UserRole.se:
        return Icons.star;
      case UserRole.employee:
        return Icons.person;
      case UserRole.contractor:
        return Icons.work;
      case UserRole.intern:
        return Icons.school;
      case UserRole.vendor:
        return Icons.business;
      default:
        return Icons.person;
    }
  }

  int _countEnabledDocumentPermissions(DocumentPermissionConfig config) {
    int count = 0;
    if (config.canViewAll) count++;
    if (config.canUploadToAll) count++;
    if (config.canDeleteAny) count++;
    if (config.canManagePermissions) count++;
    if (config.canCreateFolders) count++;
    if (config.canArchiveDocuments) count++;
    return count;
  }

  int _countEnabledSystemPermissions(SystemPermissionConfig config) {
    int count = 0;
    if (config.canManageSystem) count++;
    if (config.canAccessAdminPanel) count++;
    if (config.canManageUsers) count++;
    if (config.canViewReports) count++;
    if (config.canManageEmployees) count++;
    if (config.canManageTasks) count++;
    if (config.canViewAnalytics) count++;
    if (config.canExportData) count++;
    return count;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class _PermissionItem {
  final String name;
  final bool enabled;

  const _PermissionItem(this.name, this.enabled);
}
