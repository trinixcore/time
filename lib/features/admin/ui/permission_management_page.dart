import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/permission_config_model.dart';
import '../../../core/services/permission_management_service.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/enums/document_enums.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/password_confirmation_dialog.dart';
import '../widgets/permission_role_card.dart';
import '../widgets/permission_edit_dialog.dart';
import '../../dashboard/ui/dashboard_scaffold.dart';
import '../../../shared/providers/page_access_providers.dart';
import '../../../core/services/audit_log_service.dart';

/// Permission Management Page - Super Admin Only
class PermissionManagementPage extends ConsumerStatefulWidget {
  const PermissionManagementPage({super.key});

  @override
  ConsumerState<PermissionManagementPage> createState() =>
      _PermissionManagementPageState();
}

class _PermissionManagementPageState
    extends ConsumerState<PermissionManagementPage>
    with TickerProviderStateMixin {
  final PermissionManagementService _permissionService =
      PermissionManagementService();
  final AuthService _authService = AuthService();

  List<PermissionConfigModel> _permissionConfigs = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  UserRole? _selectedRole;

  late TabController _tabController;

  // Add state for audit logs
  List<Map<String, dynamic>> _auditLogs = [];
  bool _isLoadingAuditLogs = false;
  String? _auditLogsError;
  DocumentSnapshot? _lastAuditLogDoc;
  bool _hasMoreAuditLogs = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPermissionConfigs();
    _loadAuditLogs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPermissionConfigs() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final configs = await _permissionService.getAllPermissionConfigs();

      // If no configs exist, initialize defaults
      if (configs.isEmpty) {
        final currentUser = ref.read(currentFirebaseUserProvider);
        if (currentUser != null) {
          await _permissionService.initializeDefaultConfigs(
            currentUser.uid,
            currentUser.displayName ?? currentUser.email ?? 'System',
          );
          // Reload after initialization
          final newConfigs = await _permissionService.getAllPermissionConfigs();
          setState(() {
            _permissionConfigs = newConfigs;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _permissionConfigs = configs;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _editPermissions(PermissionConfigModel config) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PermissionEditDialog(config: config),
    );

    // If the dialog returned true, it means the save was successful
    // and the dialog already handled the save operation and showed messages
    if (result == true) {
      // Reload the configs to reflect the changes
      await _loadPermissionConfigs();
    }
  }

  Future<void> _savePermissionConfig(PermissionConfigModel config) async {
    try {
      // Show password confirmation
      final confirmed = await _showPasswordConfirmation(
        'Confirm Permission Changes',
        'Please enter your password to confirm changes to ${config.role.displayName} permissions.',
      );

      if (!confirmed) return;

      final currentUser = ref.read(currentFirebaseUserProvider);
      if (currentUser == null) return;

      await _permissionService.savePermissionConfig(
        config,
        currentUser.uid,
        currentUser.displayName ?? currentUser.email ?? 'Unknown',
      );

      // Audit log for permission update
      await AuditLogService().logEvent(
        action: 'ADMIN_UPDATE_PERMISSIONS',
        userId: currentUser.uid,
        userName: currentUser.displayName ?? currentUser.email ?? 'Unknown',
        userEmail: currentUser.email,
        status: 'success',
        targetType: 'permission_config',
        targetId: config.role.value,
        details: {
          'roleName': config.role.displayName,
          'roleValue': config.role.value,
          'systemConfig': config.systemConfig.toJson(),
          'documentConfig': config.documentConfig.toJson(),
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Permissions updated for ${config.role.displayName}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

      await _loadPermissionConfigs();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to update permissions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resetToDefaults(PermissionConfigModel config) async {
    try {
      // Show confirmation dialog
      final confirmed =
          await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Reset to Defaults'),
                  content: Text(
                    'Are you sure you want to reset ${config.role.displayName} permissions to default values? This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
          ) ??
          false;

      if (!confirmed) return;

      // Show password confirmation
      final passwordConfirmed = await _showPasswordConfirmation(
        'Confirm Reset to Defaults',
        'Please enter your password to confirm resetting ${config.role.displayName} permissions.',
      );

      if (!passwordConfirmed) return;

      setState(() => _isLoading = true);

      final currentUser = ref.read(currentFirebaseUserProvider);
      if (currentUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      await _permissionService.resetToDefault(
        config.role,
        currentUser.uid,
        currentUser.displayName ?? currentUser.email ?? 'Unknown',
      );

      // Audit log for permission reset
      await AuditLogService().logEvent(
        action: 'ADMIN_RESET_PERMISSIONS',
        userId: currentUser.uid,
        userName: currentUser.displayName ?? currentUser.email ?? 'Unknown',
        userEmail: currentUser.email,
        status: 'success',
        targetType: 'permission_config',
        targetId: config.role.value,
        details: {
          'roleName': config.role.displayName,
          'roleValue': config.role.value,
          'resetToDefaults': true,
        },
      );

      await _loadPermissionConfigs();

      if (mounted) {
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Success'),
                content: Text(
                  '✅ ${config.role.displayName} permissions have been reset to defaults.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
        // Refresh the settings page
        if (mounted) context.go('/admin/settings');
      }
    } catch (e) {
      if (mounted) {
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Error'),
                content: Text('❌ Failed to reset permissions: $e'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _showPasswordConfirmation(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => PasswordConfirmationDialog(
                title: title,
                message: message,
                actionButtonText: 'Confirm',
                onConfirmed: () => Navigator.of(context).pop(true),
              ),
        ) ??
        false;
  }

  List<PermissionConfigModel> get _filteredConfigs {
    var configs = _permissionConfigs;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      configs =
          configs.where((config) {
            return config.role.displayName.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                config.role.value.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
          }).toList();
    }

    // Filter by selected role
    if (_selectedRole != null) {
      configs =
          configs.where((config) => config.role == _selectedRole).toList();
    }

    // Sort by role level (highest to lowest)
    configs.sort((a, b) => b.role.level.compareTo(a.role.level));

    return configs;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canAccessSystemSettings = ref.watch(canAccessSystemSettingsProvider);

    return canAccessSystemSettings.when(
      data: (canAccess) {
        if (!canAccess) {
          return DashboardScaffold(
            currentPath: '/admin/settings',
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.security,
                          size: 64,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Access Denied',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You do not have permission to access System Settings.',
                          style: theme.textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return DashboardScaffold(
          currentPath: '/admin/settings',
          child: Container(
            color: theme.colorScheme.surfaceContainerLowest,
            child: Column(
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.admin_panel_settings,
                              color: theme.colorScheme.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Permission Management',
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Configure role-based access control and permissions',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Action buttons
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: _loadPermissionConfigs,
                                tooltip: 'Refresh',
                              ),
                              const SizedBox(width: 8),
                              if (_permissionConfigs.isEmpty)
                                ElevatedButton.icon(
                                  onPressed: _createDefaultConfigs,
                                  icon: const Icon(Icons.add_circle_outline),
                                  label: const Text('Create Default Configs'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor:
                                        theme.colorScheme.onPrimary,
                                  ),
                                ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.help_outline),
                                onPressed: () => _showHelpDialog(),
                                tooltip: 'Help',
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Tab Bar
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(
                            0.3,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          labelColor: theme.colorScheme.onPrimary,
                          unselectedLabelColor:
                              theme.colorScheme.onSurfaceVariant,
                          tabs: const [
                            Tab(
                              icon: Icon(Icons.admin_panel_settings),
                              text: 'Role Permissions',
                            ),
                            Tab(icon: Icon(Icons.history), text: 'Audit Logs'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Content Section
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPermissionsTab(theme),
                      _buildAuditLogsTab(theme),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading:
          () => DashboardScaffold(
            currentPath: '/admin/settings',
            child: const Center(child: LoadingWidget()),
          ),
      error:
          (error, stackTrace) => DashboardScaffold(
            currentPath: '/admin/settings',
            child: Center(
              child: CustomErrorWidget(
                message: error.toString(),
                onRetry: () => ref.refresh(canAccessSystemSettingsProvider),
              ),
            ),
          ),
    );
  }

  Widget _buildPermissionsTab(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: LoadingWidget());
    }

    if (_error != null) {
      return Center(
        child: CustomErrorWidget(
          message: _error!,
          onRetry: _loadPermissionConfigs,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildSearchAndFilters(theme),
          const SizedBox(height: 24),
          Expanded(child: _buildPermissionsList(theme)),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search & Filters',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search roles...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceVariant.withOpacity(
                        0.3,
                      ),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<UserRole?>(
                    value: _selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Filter by Role',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceVariant.withOpacity(
                        0.3,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<UserRole?>(
                        value: null,
                        child: Text('All Roles'),
                      ),
                      ...UserRole.values.map(
                        (role) => DropdownMenuItem<UserRole?>(
                          value: role,
                          child: Text(role.displayName),
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(() => _selectedRole = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_filteredConfigs.length} roles found',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    _permissionService.clearCache();
                    _loadPermissionConfigs();
                  },
                  icon: const Icon(Icons.cached, size: 16),
                  label: const Text('Clear Cache'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionsList(ThemeData theme) {
    final filteredConfigs = _filteredConfigs;

    if (filteredConfigs.isEmpty) {
      return Center(
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.security,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _permissionConfigs.isEmpty
                      ? 'No Permission Configurations Found'
                      : 'No roles found',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _permissionConfigs.isEmpty
                      ? 'Click "Create Default Configs" to initialize permission configurations for all roles.'
                      : 'Try adjusting your search or filters',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_permissionConfigs.isEmpty) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _createDefaultConfigs,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Create Default Configs'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: filteredConfigs.length,
      itemBuilder: (context, index) {
        final config = filteredConfigs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PermissionRoleCard(
            config: config,
            onEdit: () => _editPermissions(config),
            // onReset: () => _resetToDefaults(config), // Remove reset button
          ),
        );
      },
    );
  }

  Widget _buildAuditLogsTab(ThemeData theme) {
    final canViewAuditLogs = ref
        .watch(userSystemPermissionsProvider)
        .maybeWhen(
          data: (perms) => perms?.canViewAuditLogs ?? false,
          orElse: () => false,
        );
    if (!canViewAuditLogs) {
      return Center(
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 24),
                Text(
                  'Access Denied',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You do not have permission to view audit logs.',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (_isLoadingAuditLogs) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_auditLogsError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'Failed to load audit logs',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(_auditLogsError!, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _loadAuditLogs(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_auditLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              'No Audit Logs Found',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No permission changes or audit events have been recorded yet.',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Audit Logs',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (_auditLogs.isEmpty)
                OutlinedButton.icon(
                  onPressed: _createSampleAuditLogs,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Sample Logs'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                  ),
                ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: _loadAuditLogs,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Scrollbar(
              child: ListView.separated(
                itemCount: _auditLogs.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final log = _auditLogs[index];
                  final role = log['role'] ?? '-';
                  final action = log['action'] ?? '-';
                  final userName = log['userName'] ?? '-';
                  final userId = log['userId'] ?? '-';
                  final timestamp =
                      log['timestamp'] is Timestamp
                          ? (log['timestamp'] as Timestamp).toDate()
                          : (log['timestamp'] is DateTime
                              ? log['timestamp']
                              : null);
                  final details = log['details'] ?? {};

                  // Get action-specific icon and description
                  final actionInfo = _getActionInfo(action);

                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: _getRoleColor(
                          UserRole.fromString(role),
                        ).withOpacity(0.1),
                        child: Icon(
                          actionInfo['icon'] as IconData,
                          color: _getRoleColor(UserRole.fromString(role)),
                          size: 20,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              actionInfo['description'] as String,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getRoleColor(
                                UserRole.fromString(role),
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              role.toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: _getRoleColor(UserRole.fromString(role)),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'By: $userName',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                timestamp != null
                                    ? DateFormat(
                                      'MMM dd, yyyy HH:mm',
                                    ).format(timestamp)
                                    : 'Unknown time',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant.withOpacity(
                              0.3,
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow(
                                'Action Type',
                                action.toUpperCase(),
                                theme,
                              ),
                              _buildDetailRow('User ID', userId, theme),
                              if (log['ipAddress'] != null)
                                _buildDetailRow(
                                  'IP Address',
                                  log['ipAddress'].toString(),
                                  theme,
                                ),
                              if (log['location'] != null)
                                _buildDetailRow(
                                  'Location',
                                  log['location'].toString(),
                                  theme,
                                ),
                              if (log['sessionId'] != null)
                                _buildDetailRow(
                                  'Session ID',
                                  log['sessionId'].toString(),
                                  theme,
                                ),
                              if (timestamp != null)
                                _buildDetailRow(
                                  'Full Timestamp',
                                  DateFormat(
                                    'yyyy-MM-dd HH:mm:ss',
                                  ).format(timestamp),
                                  theme,
                                ),
                              if (details is Map && details.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                if (details['fieldChanges'] is Map &&
                                    (details['fieldChanges'] as Map)
                                        .isNotEmpty) ...[
                                  Text(
                                    'Changed Fields:',
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.primary,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Table(
                                    columnWidths: const {
                                      0: IntrinsicColumnWidth(),
                                      1: FlexColumnWidth(),
                                      2: FlexColumnWidth(),
                                    },
                                    border: TableBorder.all(
                                      color: theme.dividerColor.withOpacity(
                                        0.2,
                                      ),
                                    ),
                                    children: [
                                      TableRow(
                                        decoration: BoxDecoration(
                                          color: theme
                                              .colorScheme
                                              .surfaceVariant
                                              .withOpacity(0.2),
                                        ),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(6),
                                            child: Text(
                                              'Field',
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(6),
                                            child: Text(
                                              'Old Value',
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(6),
                                            child: Text(
                                              'New Value',
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      ...((details['fieldChanges'] as Map)
                                          .entries
                                          .map((entry) {
                                            final field = entry.key;
                                            final oldVal = entry.value['old'];
                                            final newVal = entry.value['new'];
                                            return TableRow(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    6,
                                                  ),
                                                  child: Text(
                                                    _formatDetailKey(field),
                                                    style:
                                                        theme
                                                            .textTheme
                                                            .bodySmall,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    6,
                                                  ),
                                                  child: Text(
                                                    _formatAuditValue(oldVal),
                                                    style: theme
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color:
                                                              theme
                                                                  .colorScheme
                                                                  .error,
                                                        ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    6,
                                                  ),
                                                  child: Text(
                                                    _formatAuditValue(newVal),
                                                    style: theme
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color:
                                                              theme
                                                                  .colorScheme
                                                                  .primary,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          })
                                          .toList()),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          if (_hasMoreAuditLogs)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: OutlinedButton.icon(
                  onPressed: () => _loadAuditLogs(loadMore: true),
                  icon: const Icon(Icons.expand_more),
                  label: const Text('Load More'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDetailKey(String key) {
    // Page permission mapping
    if (key.startsWith('systemConfig.pagePermissions.')) {
      final page = key.split('.').last;
      switch (page) {
        case 'tasks':
          return 'Tasks Page Access';
        case 'dashboard':
          return 'Dashboard Page Access';
        case 'employees':
          return 'Employees Page Access';
        case 'documents':
          return 'Documents Page Access';
        case 'leaves':
          return 'Leaves Page Access';
        case 'userManagement':
          return 'User Management Page Access';
        case 'profileApprovals':
          return 'Profile Approvals Page Access';
        case 'systemSettings':
          return 'System Settings Page Access';
        case 'profile':
          return 'Profile Page Access';
        case 'orgChart':
          return 'Org Chart Page Access';
        case 'moments':
          return 'Moments Page Access';
        case 'myDocuments':
          return 'My Documents Page Access';
        default:
          return '${page[0].toUpperCase()}${page.substring(1)} Page Access';
      }
    }
    switch (key) {
      case 'configId':
        return 'Config ID';
      case 'roleDisplayName':
        return 'Role Name';
      case 'roleLevel':
        return 'Role Level';
      case 'actionDescription':
        return 'Action Description';
      case 'sessionId':
        return 'Session ID';
      case 'severity':
        return 'Severity';
      case 'changes':
        return 'Changes';
      case 'updatedFields':
        return 'Updated Fields';
      case 'defaultPermissions':
        return 'Default Permissions';
      case 'rolesInitialized':
        return 'Roles Initialized';
      case 'rolesCreated':
        return 'Roles Created';
      case 'totalConfigs':
        return 'Total Configs';
      case 'reason':
        return 'Reason';
      case 'documentPermissions':
        return 'Document Permissions';
      case 'systemPermissions':
        return 'System Permissions';
      case 'existingConfigsDeleted':
        return 'Existing Configs Deleted';
      // Document config mapping
      case 'documentConfig.allowedFileTypes':
        return 'Document Config.allowed File Types';
      case 'documentConfig.uploadableCategories':
        return 'Document Config.uploadable Categories';
      case 'documentConfig.deletableCategories':
        return 'Document Config.deletable Categories';
      case 'documentConfig.accessibleCategories':
        return 'Document Config.accessible Categories';
      // Add more as needed
      default:
        // Fallback: split camelCase and snake_case
        return key
            .replaceAll('_', ' ')
            .replaceAllMapped(
              RegExp(r'([a-z])([A-Z])'),
              (m) => '${m[1]} ${m[2]}',
            )
            .replaceFirst(key[0], key[0].toUpperCase());
    }
  }

  String _formatAuditValue(dynamic value) {
    if (value is bool) {
      return value ? 'Allowed' : 'Not Allowed';
    }
    if (value is List) {
      return value.isEmpty ? 'None' : value.join(', ');
    }
    return value?.toString() ?? '-';
  }

  Map<String, dynamic> _getActionInfo(String action) {
    switch (action.toLowerCase()) {
      case 'create':
        return {
          'icon': Icons.add_circle,
          'description': 'Permission configuration created',
        };
      case 'update':
        return {
          'icon': Icons.edit,
          'description': 'Permission configuration updated',
        };
      case 'reset':
        return {
          'icon': Icons.restore,
          'description': 'Permission configuration reset to defaults',
        };
      case 'initialize_defaults':
        return {
          'icon': Icons.settings_backup_restore,
          'description': 'Default permission configurations initialized',
        };
      case 'manual_create_all':
        return {
          'icon': Icons.build,
          'description': 'All permission configurations manually created',
        };
      case 'delete':
        return {
          'icon': Icons.delete,
          'description': 'Permission configuration deleted',
        };
      case 'activate':
        return {
          'icon': Icons.check_circle,
          'description': 'Permission configuration activated',
        };
      case 'deactivate':
        return {
          'icon': Icons.cancel,
          'description': 'Permission configuration deactivated',
        };
      default:
        return {
          'icon': Icons.security,
          'description':
              'Permission action: ${action.replaceAll('_', ' ').toUpperCase()}',
        };
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Permission Management Help'),
            content: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Role-Based Access Control',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Each role has specific permissions for documents and system features\n'
                    '• Higher-level roles inherit permissions from lower levels\n'
                    '• Changes require password confirmation for security\n'
                    '• All changes are logged for audit purposes',
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Permission Categories',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Document Permissions: File access, upload, delete rights\n'
                    '• System Permissions: Admin panel, user management\n'
                    '• Feature Permissions: Tasks, reports, analytics access\n'
                    '• Security Permissions: Audit logs, compliance reports',
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Best Practices',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Follow principle of least privilege\n'
                    '• Regularly review and audit permissions\n'
                    '• Test changes in a controlled environment\n'
                    '• Document permission changes for compliance',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
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
        return Colors.teal;
      case UserRole.se:
        return Colors.purple;
      case UserRole.employee:
        return Colors.indigo;
      case UserRole.contractor:
        return Colors.brown;
      case UserRole.intern:
        return Colors.cyan;
      case UserRole.vendor:
        return Colors.deepOrange;
      case UserRole.inactive:
        return Colors.grey;
    }
  }

  Future<void> _createDefaultConfigs() async {
    try {
      setState(() => _isLoading = true);

      print('🚀 [PERMISSION PAGE] Starting default config creation...');

      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Initialize default configurations
      await _permissionService.initializeDefaultConfigs(
        currentUser.uid,
        currentUser.displayName ?? 'System',
      );

      print('✅ [PERMISSION PAGE] Default configs created successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '✅ Default permission configurations created successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Reload the configurations
      await _loadPermissionConfigs();
    } catch (e) {
      print('❌ [PERMISSION PAGE] Error creating default configs: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to create default configurations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _clearCache() async {
    try {
      _permissionService.clearCache();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Cache cleared'),
            backgroundColor: Colors.green,
          ),
        );
      }

      await _loadPermissionConfigs();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to clear cache: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatRoleName(UserRole role) {
    switch (role) {
      case UserRole.sa:
        return 'Super Admin';
      case UserRole.admin:
        return 'Admin';
      case UserRole.tl:
        return 'Team Lead';
      case UserRole.se:
        return 'Senior Employee';
      case UserRole.hr:
        return 'HR';
      case UserRole.manager:
        return 'Manager';
      case UserRole.employee:
        return 'Employee';
      case UserRole.contractor:
        return 'Contractor';
      case UserRole.intern:
        return 'Intern';
      case UserRole.vendor:
        return 'Vendor';
      case UserRole.inactive:
        return 'Inactive';
    }
  }

  Future<void> _loadAuditLogs({bool loadMore = false}) async {
    if (_isLoadingAuditLogs || (!_hasMoreAuditLogs && loadMore)) return;
    setState(() {
      _isLoadingAuditLogs = true;
      _auditLogsError = null;
    });
    try {
      final logs = await _permissionService.fetchPermissionAuditLogs(
        limit: 50,
        startAfter: loadMore ? _lastAuditLogDoc : null,
      );
      setState(() {
        if (loadMore) {
          _auditLogs.addAll(logs);
        } else {
          _auditLogs = logs;
        }
        _hasMoreAuditLogs = logs.length == 50;
        if (logs.isNotEmpty) {
          _lastAuditLogDoc =
              null; // Not used for now, can be set for real pagination
        }
      });
    } catch (e) {
      setState(() {
        _auditLogsError = e.toString();
      });
    } finally {
      setState(() {
        _isLoadingAuditLogs = false;
      });
    }
  }

  Future<void> _createSampleAuditLogs() async {
    try {
      setState(() => _isLoading = true);

      print('🚀 [PERMISSION PAGE] Starting sample audit logs creation...');

      final currentUser = ref.read(currentFirebaseUserProvider);
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Create sample audit logs
      await _permissionService.createSampleAuditLogs(
        currentUser.uid,
        currentUser.displayName ?? 'System',
      );

      print('✅ [PERMISSION PAGE] Sample audit logs created successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Sample audit logs created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Reload the audit logs
      await _loadAuditLogs();
    } catch (e) {
      print('❌ [PERMISSION PAGE] Error creating sample audit logs: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to create sample audit logs: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
