import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/services/export_service.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/providers/performance_providers.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../shared/widgets/enhanced_user_hierarchy_dialog.dart';
import '../../dashboard/ui/dashboard_scaffold.dart';
import '../../../core/services/audit_log_service.dart';

// Use optimized provider instead of the old one
final usersDataProvider = optimizedUsersDataProvider;

// Provider for departments data from system_data collection
final departmentsProvider = FutureProvider<List<String>>((ref) async {
  final authService = ref.read(authServiceProvider);
  return await authService.getDepartments();
});

// Provider for departments dropdown (using system data)
final departmentsDropdownProvider = StreamProvider<List<String>>((ref) {
  return FirebaseFirestore.instance
      .collection('system_data')
      .doc('departments')
      .snapshots()
      .map((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          final departments = List<String>.from(data['list'] ?? []);
          departments.sort(); // Sort alphabetically
          return departments;
        }
        return <String>[];
      });
});

class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({super.key});

  @override
  ConsumerState<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedDepartment = 'All';
  UserRole? _selectedRole;
  bool _showFilters = false;
  Set<String> _selectedUsers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      currentPath: '/admin/users',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Management'),
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          actions: [
            // Search toggle
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                _showSearchDialog();
              },
            ),
            // Filter toggle
            IconButton(
              icon: Icon(
                Icons.filter_list,
                color:
                    _hasActiveFilters()
                        ? Theme.of(context).colorScheme.primary
                        : null,
              ),
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
            ),
            // Export menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: _handleMenuAction,
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'export_basic',
                      child: Row(
                        children: [
                          Icon(Icons.download),
                          SizedBox(width: 8),
                          Text('Export All Users (Basic)'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'export_detailed',
                      child: Row(
                        children: [
                          Icon(Icons.download_for_offline),
                          SizedBox(width: 8),
                          Text('Export All Users (Detailed)'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'export_filtered',
                      child: Row(
                        children: [
                          Icon(Icons.filter_alt),
                          SizedBox(width: 8),
                          Text('Export Filtered Users'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'statistics',
                      child: Row(
                        children: [
                          Icon(Icons.analytics),
                          SizedBox(width: 8),
                          Text('View Statistics'),
                        ],
                      ),
                    ),
                  ],
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _showCreateUserDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Create User'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(_showFilters ? 120 : 48),
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'All Users'),
                    Tab(text: 'Active'),
                    Tab(text: 'Pending'),
                    Tab(text: 'Terminated'),
                  ],
                ),
                if (_showFilters) _buildFiltersWidget(),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            // Bulk actions bar
            if (_selectedUsers.isNotEmpty) _buildBulkActionsBar(),

            // Main content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildUsersList('all'),
                  _buildUsersList('active'),
                  _buildUsersList('pending'),
                  _buildUsersList('terminated'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersWidget() {
    return Container(
      height: 72,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final departmentsAsync = ref.watch(departmentsDropdownProvider);

                return departmentsAsync.when(
                  data: (departments) {
                    // Create dropdown items with "All Departments" first, then sorted departments
                    final dropdownItems = <DropdownMenuItem<String>>[
                      const DropdownMenuItem(
                        value: 'All',
                        child: Text('All Departments'),
                      ),
                      ...departments.map(
                        (department) => DropdownMenuItem(
                          value: department,
                          child: Text(department),
                        ),
                      ),
                    ];

                    return DropdownButtonFormField<String>(
                      value: _selectedDepartment,
                      decoration: const InputDecoration(
                        labelText: 'Department',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: dropdownItems,
                      onChanged: (value) {
                        setState(() {
                          _selectedDepartment = value!;
                        });
                      },
                    );
                  },
                  loading:
                      () => DropdownButtonFormField<String>(
                        value: _selectedDepartment,
                        decoration: const InputDecoration(
                          labelText: 'Department',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'All',
                            child: Text('All Departments'),
                          ),
                        ],
                        onChanged: null, // Disabled while loading
                      ),
                  error:
                      (error, stack) => DropdownButtonFormField<String>(
                        value: _selectedDepartment,
                        decoration: const InputDecoration(
                          labelText: 'Department',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'All',
                            child: Text('All Departments'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedDepartment = value!;
                          });
                        },
                      ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<UserRole?>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Roles')),
                ...UserRole.values.map(
                  (role) => DropdownMenuItem(
                    value: role,
                    child: Text(role.displayName),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRole = value;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _clearFilters,
            icon: const Icon(Icons.clear),
            tooltip: 'Clear Filters',
          ),
        ],
      ),
    );
  }

  Widget _buildBulkActionsBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '${_selectedUsers.length} selected',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Spacer(),
          // Export dropdown menu
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'export_basic':
                  _bulkExport();
                  break;
                case 'export_detailed':
                  _bulkExportDetailed();
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'export_basic',
                    child: Row(
                      children: [
                        Icon(Icons.download, size: 18),
                        SizedBox(width: 8),
                        Text('Export Basic'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'export_detailed',
                    child: Row(
                      children: [
                        Icon(Icons.download_for_offline, size: 18),
                        SizedBox(width: 8),
                        Text('Export Detailed'),
                      ],
                    ),
                  ),
                ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.download,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Export',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: _bulkDelete,
            icon: const Icon(Icons.delete, color: Colors.red, size: 18),
            label: const Text('Delete', style: TextStyle(color: Colors.red)),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: _clearSelection,
            icon: const Icon(Icons.clear, size: 18),
            label: const Text('Clear'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList(String filter) {
    final usersDataAsync = ref.watch(usersDataProvider);

    return usersDataAsync.when(
      data: (usersData) {
        final activeUsers = usersData['active'] ?? [];
        final terminatedUsers = usersData['terminated'] ?? [];
        final pendingUsers = usersData['pending'] ?? [];

        List<Map<String, dynamic>> allUsers = [];

        // Add active users
        for (var doc in activeUsers) {
          final userData = doc.data() as Map<String, dynamic>?;
          if (userData != null) {
            allUsers.add({
              'data': userData,
              'id': doc.id,
              'isPending': false,
              'isActive': userData['isActive'] ?? true,
            });
          }
        }

        // Add terminated users
        for (var doc in terminatedUsers) {
          final userData = doc.data() as Map<String, dynamic>?;
          if (userData != null) {
            allUsers.add({
              'data': userData,
              'id': doc.id,
              'isPending': false,
              'isActive': userData['isActive'] ?? false,
            });
          }
        }

        // Add pending users
        for (var doc in pendingUsers) {
          final userData = doc.data() as Map<String, dynamic>?;
          if (userData != null) {
            allUsers.add({
              'data': userData,
              'id': doc.id,
              'isPending': true,
              'isActive': false,
            });
          }
        }

        // Apply filters
        final filteredUsers = _applyFilters(allUsers, filter);

        if (filteredUsers.isEmpty) {
          return _buildEmptyState();
        }

        return _buildRefreshIndicator(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final userInfo = filteredUsers[index];
              return _buildEnhancedUserCard(userInfo);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  List<Map<String, dynamic>> _applyFilters(
    List<Map<String, dynamic>> users,
    String filter,
  ) {
    return users.where((userInfo) {
      final userData = userInfo['data'] as Map<String, dynamic>;
      final isPending = userInfo['isPending'] as bool;
      final isActive = userInfo['isActive'] as bool;

      // Apply tab filter
      switch (filter) {
        case 'active':
          if (isPending || !isActive) return false;
          break;
        case 'pending':
          if (!isPending) return false;
          break;
        case 'terminated':
          if (isPending || isActive) return false;
          break;
        // 'all' shows everything
      }

      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        final displayName =
            (userData['displayName'] ?? '').toString().toLowerCase();
        final email = (userData['email'] ?? '').toString().toLowerCase();
        final employeeId =
            (userData['employeeId'] ?? '').toString().toLowerCase();

        if (!displayName.contains(_searchQuery) &&
            !email.contains(_searchQuery) &&
            !employeeId.contains(_searchQuery)) {
          return false;
        }
      }

      // Apply department filter
      if (_selectedDepartment != 'All') {
        final department = userData['department'] ?? '';
        if (department != _selectedDepartment) return false;
      }

      // Apply role filter
      if (_selectedRole != null) {
        final roleString = userData['role'] ?? '';
        final userRole = UserRole.values.firstWhere(
          (role) => role.toString().split('.').last == roleString,
          orElse: () => UserRole.employee,
        );
        if (userRole != _selectedRole) return false;
      }

      return true;
    }).toList();
  }

  Widget _buildEnhancedUserCard(Map<String, dynamic> userInfo) {
    final userData = userInfo['data'] as Map<String, dynamic>;
    final docId = userInfo['id'] as String;
    final isPending = userInfo['isPending'] as bool;
    final isActive = userInfo['isActive'] as bool;

    final displayName = userData['displayName'] ?? 'No Name';
    final email = userData['email'] ?? 'No Email';
    final employeeId = userData['employeeId'] ?? 'No ID';
    final role = userData['role'] ?? 'employee';
    final department = userData['department'] ?? 'No Department';
    final phoneNumber = userData['phoneNumber'] ?? '';
    final credentialsShared = userData['credentialsShared'] ?? false;
    final tempPassword = userData['tempPassword'] as String?;

    final isSelected = _selectedUsers.contains(docId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      color:
          isSelected
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
              : null,
      child: InkWell(
        onTap: () => _toggleUserSelection(docId),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Selection checkbox
                  Checkbox(
                    value: isSelected,
                    onChanged: (selected) => _toggleUserSelection(docId),
                  ),
                  const SizedBox(width: 8),
                  // Avatar
                  CircleAvatar(
                    backgroundColor: _getStatusColor(isPending, isActive),
                    child: Text(
                      displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          employeeId,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status and actions
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildStatusChip(isPending, isActive, credentialsShared),
                      const SizedBox(height: 4),
                      PopupMenuButton<String>(
                        onSelected:
                            (action) => _handleUserAction(action, userInfo),
                        itemBuilder:
                            (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 16),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'show_hierarchy',
                                child: Row(
                                  children: [
                                    Icon(Icons.account_tree, size: 16),
                                    SizedBox(width: 8),
                                    Text('Show Hierarchy'),
                                  ],
                                ),
                              ),
                              if (isPending && !credentialsShared)
                                const PopupMenuItem(
                                  value: 'share_credentials',
                                  child: Row(
                                    children: [
                                      Icon(Icons.share, size: 16),
                                      SizedBox(width: 8),
                                      Text('Share Credentials'),
                                    ],
                                  ),
                                ),
                              if (tempPassword != null)
                                const PopupMenuItem(
                                  value: 'copy_password',
                                  child: Row(
                                    children: [
                                      Icon(Icons.copy, size: 16),
                                      SizedBox(width: 8),
                                      Text('Copy Password'),
                                    ],
                                  ),
                                ),
                              if (isActive && !isPending)
                                const PopupMenuItem(
                                  value: 'terminate',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.person_off,
                                        size: 16,
                                        color: Colors.orange,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Terminate',
                                        style: TextStyle(color: Colors.orange),
                                      ),
                                    ],
                                  ),
                                ),
                              if (!isActive && !isPending)
                                const PopupMenuItem(
                                  value: 'reactivate',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.person_add,
                                        size: 16,
                                        color: Colors.green,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Reactivate',
                                        style: TextStyle(color: Colors.green),
                                      ),
                                    ],
                                  ),
                                ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      size: 16,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Additional info
              Row(
                children: [
                  Expanded(child: _buildInfoItem(Icons.email, email)),
                  if (phoneNumber.isNotEmpty)
                    Expanded(child: _buildInfoItem(Icons.phone, phoneNumber)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildInfoItem(Icons.business, department)),
                  Expanded(
                    child: _buildInfoItem(Icons.badge, _formatRole(role)),
                  ),
                ],
              ),
              // Credentials info for pending users
              if (isPending) ...[
                const SizedBox(height: 12),
                _buildCredentialsInfo(
                  userData,
                  credentialsShared,
                  tempPassword,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(
    bool isPending,
    bool isActive,
    bool credentialsShared,
  ) {
    String label;
    Color color;

    if (isPending) {
      if (credentialsShared) {
        label = 'SHARED';
        color = Colors.blue;
      } else {
        label = 'PENDING';
        color = Colors.orange;
      }
    } else if (isActive) {
      label = 'ACTIVE';
      color = Colors.green;
    } else {
      label = 'TERMINATED';
      color = Colors.red;
    }

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
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCredentialsInfo(
    Map<String, dynamic> userData,
    bool credentialsShared,
    String? tempPassword,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: credentialsShared ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: credentialsShared ? Colors.green[200]! : Colors.orange[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                credentialsShared ? Icons.check_circle : Icons.pending,
                color:
                    credentialsShared ? Colors.green[700] : Colors.orange[700],
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                credentialsShared
                    ? 'Credentials Shared'
                    : 'Credentials Not Shared',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color:
                      credentialsShared
                          ? Colors.green[700]
                          : Colors.orange[700],
                ),
              ),
            ],
          ),
          if (tempPassword != null && !credentialsShared) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Temp Password: $tempPassword',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _copyToClipboard(tempPassword),
                  icon: const Icon(Icons.copy, size: 16),
                  tooltip: 'Copy password',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first user to get started',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showCreateUserDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Create User'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
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
            'Error loading users',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {}),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getStatusColor(bool isPending, bool isActive) {
    if (isPending) return Colors.orange;
    if (isActive) return Colors.green;
    return Colors.red;
  }

  String _formatRole(String role) {
    switch (role) {
      case 'super_admin':
        return 'Super Admin';
      case 'admin':
        return 'Admin';
      case 'hr':
        return 'HR';
      case 'manager':
        return 'Manager';
      case 'team_lead':
        return 'Team Lead';
      case 'employee':
        return 'Employee';
      default:
        return role;
    }
  }

  bool _hasActiveFilters() {
    return _selectedDepartment != 'All' ||
        _selectedRole != null ||
        _searchQuery.isNotEmpty;
  }

  void _toggleUserSelection(String userId) {
    setState(() {
      if (_selectedUsers.contains(userId)) {
        _selectedUsers.remove(userId);
      } else {
        _selectedUsers.add(userId);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedUsers.clear();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedDepartment = 'All';
      _selectedRole = null;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Search Users'),
            content: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by name, email, or employee ID...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Clear'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ],
          ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export_basic':
        _exportUsers(detailed: false);
        break;
      case 'export_detailed':
        _exportUsers(detailed: true);
        break;
      case 'export_filtered':
        _exportFilteredUsers();
        break;
      case 'statistics':
        _showStatistics();
        break;
    }
  }

  void _handleUserAction(String action, Map<String, dynamic> userInfo) {
    final userData = userInfo['data'] as Map<String, dynamic>;
    final docId = userInfo['id'] as String;
    final isPending = userInfo['isPending'] as bool;

    switch (action) {
      case 'edit':
        _editUser(userInfo);
        break;
      case 'show_hierarchy':
        _showHierarchy(userInfo);
        break;
      case 'share_credentials':
        _markCredentialsShared(userData['employeeId'], docId);
        break;
      case 'copy_password':
        final tempPassword = userData['tempPassword'] as String?;
        if (tempPassword != null) {
          _copyToClipboard(tempPassword);
        }
        break;
      case 'terminate':
        _terminateUser(userInfo);
        break;
      case 'reactivate':
        _reactivateUser(userInfo);
        break;
      case 'delete':
        _deleteUser(userInfo);
        break;
    }
  }

  void _exportUsers({bool detailed = false}) async {
    try {
      final usersDataAsync = ref.read(usersDataProvider);

      await usersDataAsync.when(
        data: (usersData) async {
          final activeUsers = usersData['active'] ?? [];
          final pendingUsers = usersData['pending'] ?? [];

          List<Map<String, dynamic>> allUsers = [];

          // Add active users
          for (var doc in activeUsers) {
            final userData = doc.data() as Map<String, dynamic>?;
            if (userData != null) {
              allUsers.add({
                'data': userData,
                'id': doc.id,
                'isPending': false,
                'isActive': userData['isActive'] ?? true,
              });
            }
          }

          // Add pending users
          for (var doc in pendingUsers) {
            final userData = doc.data() as Map<String, dynamic>?;
            if (userData != null) {
              allUsers.add({
                'data': userData,
                'id': doc.id,
                'isPending': true,
                'isActive': false,
              });
            }
          }

          if (allUsers.isEmpty) {
            _showSnackBar('No users found to export', isError: true);
            return;
          }

          final filename = ExportService.generateFilename(
            detailed ? 'detailed_users_export' : 'users_export',
          );

          if (detailed) {
            ExportService.exportDetailedUsersToCSV(
              users: allUsers,
              filename: filename,
            );
          } else {
            ExportService.exportUsersToCSV(users: allUsers, filename: filename);
          }

          _showSnackBar(
            'Successfully exported ${allUsers.length} users to $filename.csv',
            isError: false,
          );
        },
        loading: () {
          _showSnackBar('Loading users data...', isError: false);
        },
        error: (error, stack) {
          _showSnackBar('Failed to load users data: $error', isError: true);
        },
      );
    } catch (e) {
      _showSnackBar('Export failed: $e', isError: true);
    }
  }

  void _exportFilteredUsers() async {
    try {
      final usersDataAsync = ref.read(usersDataProvider);

      await usersDataAsync.when(
        data: (usersData) async {
          final activeUsers = usersData['active'] ?? [];
          final pendingUsers = usersData['pending'] ?? [];

          List<Map<String, dynamic>> allUsers = [];

          // Add active users
          for (var doc in activeUsers) {
            final userData = doc.data() as Map<String, dynamic>?;
            if (userData != null) {
              allUsers.add({
                'data': userData,
                'id': doc.id,
                'isPending': false,
                'isActive': userData['isActive'] ?? true,
              });
            }
          }

          // Add pending users
          for (var doc in pendingUsers) {
            final userData = doc.data() as Map<String, dynamic>?;
            if (userData != null) {
              allUsers.add({
                'data': userData,
                'id': doc.id,
                'isPending': true,
                'isActive': false,
              });
            }
          }

          // Apply current filters
          final currentTab = _tabController.index;
          final filterType =
              ['all', 'active', 'pending', 'inactive'][currentTab];
          final filteredUsers = _applyFilters(allUsers, filterType);

          if (filteredUsers.isEmpty) {
            _showSnackBar('No users match the current filters', isError: true);
            return;
          }

          final filename = ExportService.generateFilename(
            'filtered_users_export',
          );

          ExportService.exportUsersToCSV(
            users: filteredUsers,
            filename: filename,
          );

          _showSnackBar(
            'Successfully exported ${filteredUsers.length} filtered users to $filename.csv',
            isError: false,
          );
        },
        loading: () {
          _showSnackBar('Loading users data...', isError: false);
        },
        error: (error, stack) {
          _showSnackBar('Failed to load users data: $error', isError: true);
        },
      );
    } catch (e) {
      _showSnackBar('Export failed: $e', isError: true);
    }
  }

  void _showStatistics() {
    // TODO: Implement statistics dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Statistics view coming soon')),
    );
  }

  void _bulkDelete() async {
    if (_selectedUsers.isEmpty) return;

    // Show credential confirmation dialog before bulk deletion
    final confirmed = await _showCredentialConfirmationDialog(
      title: 'Confirm Bulk User Deletion',
      message:
          'You are about to permanently delete ${_selectedUsers.length} selected users. This action cannot be undone and requires password verification for security.\n\nPlease enter your password to confirm this critical operation.',
      actionButtonText: 'Delete ${_selectedUsers.length} Users',
      actionButtonColor: Colors.red,
      icon: Icons.delete_forever,
    );

    if (!confirmed) {
      // User cancelled or password verification failed
      return;
    }

    // Proceed with bulk deletion
    await _performBulkDelete();
  }

  void _bulkExport() async {
    if (_selectedUsers.isEmpty) {
      _showSnackBar('No users selected for export', isError: true);
      return;
    }

    try {
      final usersDataAsync = ref.read(usersDataProvider);

      await usersDataAsync.when(
        data: (usersData) async {
          final activeUsers = usersData['active'] ?? [];
          final pendingUsers = usersData['pending'] ?? [];

          List<Map<String, dynamic>> allUsers = [];

          // Add active users
          for (var doc in activeUsers) {
            final userData = doc.data() as Map<String, dynamic>?;
            if (userData != null) {
              allUsers.add({
                'data': userData,
                'id': doc.id,
                'isPending': false,
                'isActive': userData['isActive'] ?? true,
              });
            }
          }

          // Add pending users
          for (var doc in pendingUsers) {
            final userData = doc.data() as Map<String, dynamic>?;
            if (userData != null) {
              allUsers.add({
                'data': userData,
                'id': doc.id,
                'isPending': true,
                'isActive': false,
              });
            }
          }

          final filename = ExportService.generateFilename(
            'selected_users_export',
          );

          ExportService.exportSelectedUsersToCSV(
            users: allUsers,
            selectedUserIds: _selectedUsers,
            filename: filename,
          );

          _showSnackBar(
            'Successfully exported ${_selectedUsers.length} selected users to $filename.csv',
            isError: false,
          );

          // Clear selection after export
          _clearSelection();
        },
        loading: () {
          _showSnackBar('Loading users data...', isError: false);
        },
        error: (error, stack) {
          _showSnackBar('Failed to load users data: $error', isError: true);
        },
      );
    } catch (e) {
      _showSnackBar('Bulk export failed: $e', isError: true);
    }
  }

  void _bulkExportDetailed() async {
    if (_selectedUsers.isEmpty) {
      _showSnackBar('No users selected for detailed export', isError: true);
      return;
    }

    try {
      final usersDataAsync = ref.read(usersDataProvider);

      await usersDataAsync.when(
        data: (usersData) async {
          final activeUsers = usersData['active'] ?? [];
          final pendingUsers = usersData['pending'] ?? [];

          List<Map<String, dynamic>> allUsers = [];

          // Add active users
          for (var doc in activeUsers) {
            final userData = doc.data() as Map<String, dynamic>?;
            if (userData != null) {
              allUsers.add({
                'data': userData,
                'id': doc.id,
                'isPending': false,
                'isActive': userData['isActive'] ?? true,
              });
            }
          }

          // Add pending users
          for (var doc in pendingUsers) {
            final userData = doc.data() as Map<String, dynamic>?;
            if (userData != null) {
              allUsers.add({
                'data': userData,
                'id': doc.id,
                'isPending': true,
                'isActive': false,
              });
            }
          }

          final filename = ExportService.generateFilename(
            'selected_users_detailed_export',
          );

          ExportService.exportDetailedSelectedUsersToCSV(
            users: allUsers,
            selectedUserIds: _selectedUsers,
            filename: filename,
          );

          _showSnackBar(
            'Successfully exported ${_selectedUsers.length} selected users to $filename.csv',
            isError: false,
          );

          // Clear selection after export
          _clearSelection();
        },
        loading: () {
          _showSnackBar('Loading users data...', isError: false);
        },
        error: (error, stack) {
          _showSnackBar('Failed to load users data: $error', isError: true);
        },
      );
    } catch (e) {
      _showSnackBar('Detailed export failed: $e', isError: true);
    }
  }

  Future<void> _performBulkDelete() async {
    try {
      final usersDataAsync = ref.read(usersDataProvider);

      await usersDataAsync.when(
        data: (usersData) async {
          final activeUsers = usersDataAsync.value?['active'] ?? [];
          final pendingUsers = usersDataAsync.value?['pending'] ?? [];

          List<String> deletedUserNames = [];
          int successCount = 0;
          int errorCount = 0;

          // Process active users
          for (var doc in activeUsers) {
            if (_selectedUsers.contains(doc.id)) {
              try {
                final userData = doc.data() as Map<String, dynamic>?;
                final userName = userData?['displayName'] ?? 'Unknown User';

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(doc.id)
                    .delete();

                // Log the activity
                await FirebaseFirestore.instance
                    .collection('activity_logs')
                    .add({
                      'userId': doc.id,
                      'userName': userName,
                      'action': 'user_deleted',
                      'description': 'User deleted by admin (bulk operation)',
                      'timestamp': FieldValue.serverTimestamp(),
                      'metadata': {'isPending': false, 'bulkOperation': true},
                    });

                deletedUserNames.add(userName);
                successCount++;
              } catch (e) {
                errorCount++;
              }
            }
          }

          // Process pending users
          for (var doc in pendingUsers) {
            if (_selectedUsers.contains(doc.id)) {
              try {
                final userData = doc.data() as Map<String, dynamic>?;
                final userName = userData?['displayName'] ?? 'Unknown User';

                await FirebaseFirestore.instance
                    .collection('pending_users')
                    .doc(doc.id)
                    .delete();

                // Log the activity
                await FirebaseFirestore.instance
                    .collection('activity_logs')
                    .add({
                      'userId': doc.id,
                      'userName': userName,
                      'action': 'user_deleted',
                      'description':
                          'Pending user deleted by admin (bulk operation)',
                      'timestamp': FieldValue.serverTimestamp(),
                      'metadata': {'isPending': true, 'bulkOperation': true},
                    });

                deletedUserNames.add(userName);
                successCount++;
              } catch (e) {
                errorCount++;
              }
            }
          }

          // Audit log for bulk user deletion
          if (successCount > 0) {
            final currentUser = ref.read(currentUserProvider).value;
            await AuditLogService().logEvent(
              action: 'ADMIN_BULK_DELETE_USERS',
              userId: currentUser?.uid,
              userName:
                  currentUser?.displayName ?? currentUser?.email ?? 'Unknown',
              userEmail: currentUser?.email,
              status: 'success',
              targetType: 'users',
              details: {
                'deletedUserCount': successCount,
                'errorCount': errorCount,
                'deletedUserNames': deletedUserNames,
                'selectedUserIds': _selectedUsers.toList(),
                'bulkOperation': true,
              },
            );
          }

          // Refresh the data
          ref.invalidate(usersDataProvider);

          // Show result message
          if (mounted) {
            if (successCount > 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    errorCount > 0
                        ? 'Successfully deleted $successCount users. $errorCount failed.'
                        : 'Successfully deleted $successCount users',
                  ),
                  backgroundColor:
                      errorCount > 0 ? Colors.orange : Colors.green,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to delete any users'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        loading: () {
          _showSnackBar('Loading users data...', isError: false);
        },
        error: (error, stack) {
          _showSnackBar('Failed to load users data: $error', isError: true);
        },
      );
    } catch (e) {
      _showSnackBar('Bulk deletion failed: $e', isError: true);
    }

    _clearSelection();
  }

  void _editUser(Map<String, dynamic> userInfo) {
    final docId = userInfo['id'] as String;
    final isPending = userInfo['isPending'] as bool;

    // Navigate to edit user page with appropriate parameters
    final route = '/admin/users/edit/$docId${isPending ? '?pending=true' : ''}';
    context.go(route);
  }

  Future<void> _deleteUser(Map<String, dynamic> userInfo) async {
    final userData = userInfo['data'] as Map<String, dynamic>;
    final userName = userData['displayName'] ?? 'Unknown User';
    final docId = userInfo['id'] as String;
    final isPending = userInfo['isPending'] ?? false;

    // Show credential confirmation dialog before deletion
    final confirmed = await _showCredentialConfirmationDialog(
      title: 'Confirm User Deletion',
      message:
          'You are about to permanently delete the user "$userName". This action cannot be undone and requires password verification for security.\n\nPlease enter your password to confirm this critical operation.',
      actionButtonText: 'Delete User',
      actionButtonColor: Colors.red,
      icon: Icons.delete_forever,
    );

    if (!confirmed) {
      // User cancelled or password verification failed
      return;
    }

    // Proceed with deletion
    try {
      final collection = isPending ? 'pending_users' : 'users';
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(docId)
          .delete();

      // Log the activity
      await FirebaseFirestore.instance.collection('activity_logs').add({
        'userId': docId,
        'userName': userName,
        'action': 'user_deleted',
        'description': 'User deleted by admin',
        'timestamp': FieldValue.serverTimestamp(),
        'metadata': {'isPending': isPending, 'deletedUserData': userInfo},
      });

      // Audit log for user deletion
      final currentUser = ref.read(currentUserProvider).value;
      await AuditLogService().logEvent(
        action: 'ADMIN_DELETE_USER',
        userId: currentUser?.uid,
        userName: currentUser?.displayName ?? currentUser?.email ?? 'Unknown',
        userEmail: currentUser?.email,
        status: 'success',
        targetType: 'user',
        targetId: docId,
        details: {
          'deletedUserEmail': userData['email'],
          'deletedUserDisplayName': userName,
          'deletedUserRole': userData['role'],
          'deletedUserEmployeeId': userData['employeeId'],
          'isPending': isPending,
          'deletedUserData': userInfo,
        },
      );

      // Refresh the data
      ref.invalidate(usersDataProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User "$userName" deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _markCredentialsShared(String employeeId, String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('pending_users')
          .doc(docId)
          .update({
            'credentialsShared': true,
            'sharedAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Credentials marked as shared for $employeeId'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update credentials status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showHierarchy(Map<String, dynamic> userInfo) {
    final userData = userInfo['data'] as Map<String, dynamic>;
    final docId = userInfo['id'] as String;
    final displayName = userData['displayName'] ?? 'Unknown User';

    showEnhancedUserHierarchyDialog(context, docId, displayName);
  }

  void _showEnhancedUserHierarchy(String docId, String displayName) {
    showEnhancedUserHierarchyDialog(context, docId, displayName);
  }

  Widget _buildRefreshIndicator({required Widget child}) {
    return RefreshIndicator(onRefresh: _refreshData, child: child);
  }

  Future<void> _refreshData() async {
    // Use the optimized refresh helper
    NavigationRefreshHelper.refreshAfterAction(ref, 'user_updated');
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary,
        duration: Duration(seconds: isError ? 4 : 3),
        action:
            isError
                ? SnackBarAction(
                  label: 'Dismiss',
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                )
                : null,
      ),
    );
  }

  Future<bool> _showCredentialConfirmationDialog({
    required String title,
    required String message,
    required String actionButtonText,
    required Color actionButtonColor,
    required IconData icon,
  }) async {
    final TextEditingController passwordController = TextEditingController();
    bool isLoading = false;

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Row(
                    children: [
                      Icon(icon, color: actionButtonColor),
                      const SizedBox(width: 8),
                      Text(title),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(message),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password to confirm',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        enabled: !isLoading,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed:
                          isLoading
                              ? null
                              : () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed:
                          isLoading
                              ? null
                              : () async {
                                if (passwordController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please enter your password',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  isLoading = true;
                                });

                                try {
                                  // Verify password with Firebase Auth
                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  if (user != null) {
                                    final credential =
                                        EmailAuthProvider.credential(
                                          email: user.email!,
                                          password: passwordController.text,
                                        );

                                    await user.reauthenticateWithCredential(
                                      credential,
                                    );

                                    // Password verified successfully
                                    if (context.mounted) {
                                      Navigator.of(context).pop(true);
                                    }
                                  } else {
                                    throw Exception(
                                      'No authenticated user found',
                                    );
                                  }
                                } catch (e) {
                                  setState(() {
                                    isLoading = false;
                                  });

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Password verification failed: ${e.toString()}',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: actionButtonColor,
                        foregroundColor: Colors.white,
                      ),
                      child:
                          isLoading
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Text(actionButtonText),
                    ),
                  ],
                );
              },
            );
          },
        ) ??
        false;
  }

  void _terminateUser(Map<String, dynamic> userInfo) async {
    final userData = userInfo['data'] as Map<String, dynamic>;
    final docId = userInfo['id'] as String;
    final displayName = userData['displayName'] ?? 'Unknown User';
    final employeeId = userData['employeeId'] ?? 'Unknown ID';

    // Show password confirmation dialog first
    final passwordConfirmed = await _showCredentialConfirmationDialog(
      title: 'Confirm Employee Termination',
      message:
          'You are about to terminate $displayName ($employeeId). This action requires password verification for security.',
      actionButtonText: 'Verify & Continue',
      actionButtonColor: Colors.orange,
      icon: Icons.person_off,
    );

    if (!passwordConfirmed) return;

    // Show termination dialog after password verification
    final terminationData = await _showTerminationDialog(
      displayName,
      employeeId,
    );
    if (terminationData == null) return;

    try {
      // Update user status to terminated
      await FirebaseFirestore.instance.collection('users').doc(docId).update({
        'isActive': false,
        'terminationDate': Timestamp.now(),
        'terminationReason': terminationData['reason'],
        'lastWorkingDay':
            terminationData['lastWorkingDay'] != null
                ? Timestamp.fromDate(terminationData['lastWorkingDay'])
                : null,
        'terminatedBy': FirebaseAuth.instance.currentUser?.uid,
        'terminationComments': terminationData['comments'],
        'updatedAt': Timestamp.now(),
      });

      // Audit log for user termination
      final currentUser = ref.read(currentUserProvider).value;
      await AuditLogService().logEvent(
        action: 'ADMIN_TERMINATE_USER',
        userId: currentUser?.uid,
        userName: currentUser?.displayName ?? currentUser?.email ?? 'Unknown',
        userEmail: currentUser?.email,
        status: 'success',
        targetType: 'user',
        targetId: docId,
        details: {
          'terminatedUserEmail': userData['email'],
          'terminatedUserDisplayName': displayName,
          'terminatedUserEmployeeId': employeeId,
          'terminationReason': terminationData['reason'],
          'lastWorkingDay':
              terminationData['lastWorkingDay']?.toIso8601String(),
          'terminationComments': terminationData['comments'],
        },
      );

      _showSnackBar(
        'User $displayName has been terminated successfully',
        isError: false,
      );

      // Clear selection if this user was selected
      if (_selectedUsers.contains(docId)) {
        setState(() {
          _selectedUsers.remove(docId);
        });
      }

      // Refresh users data
      ref.invalidate(usersDataProvider);
    } catch (e) {
      _showSnackBar('Failed to terminate user: $e', isError: true);
    }
  }

  Future<Map<String, dynamic>?> _showTerminationDialog(
    String displayName,
    String employeeId,
  ) async {
    final commentsController = TextEditingController();
    DateTime? lastWorkingDay;
    String selectedReason = 'Resignation';

    final reasons = [
      'Resignation',
      'Termination',
      'Layoff',
      'Retirement',
      'Contract End',
      'Performance Issues',
      'Misconduct',
      'Other',
    ];

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Row(
                    children: [
                      Icon(Icons.person_off, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Terminate Employee'),
                    ],
                  ),
                  content: SizedBox(
                    width: 400,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Employee info
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Employee: $displayName',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('ID: $employeeId'),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),

                        // Termination reason dropdown
                        Text(
                          'Termination Reason *',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: selectedReason,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items:
                              reasons
                                  .map(
                                    (reason) => DropdownMenuItem(
                                      value: reason,
                                      child: Text(reason),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                selectedReason = value;
                              });
                            }
                          },
                        ),
                        SizedBox(height: 16),

                        // Last working day
                        Text(
                          'Last Working Day',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now().subtract(
                                Duration(days: 365),
                              ),
                              lastDate: DateTime.now().add(Duration(days: 90)),
                            );
                            if (date != null) {
                              setDialogState(() {
                                lastWorkingDay = date;
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[400]!),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  lastWorkingDay != null
                                      ? '${lastWorkingDay!.day}/${lastWorkingDay!.month}/${lastWorkingDay!.year}'
                                      : 'Select last working day',
                                  style: TextStyle(
                                    color:
                                        lastWorkingDay != null
                                            ? Colors.black
                                            : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Comments
                        Text(
                          'Comments',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: commentsController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Additional comments or notes...',
                            contentPadding: EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop({
                          'reason': selectedReason,
                          'lastWorkingDay': lastWorkingDay,
                          'comments': commentsController.text.trim(),
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Terminate Employee'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _reactivateUser(Map<String, dynamic> userInfo) async {
    final userData = userInfo['data'] as Map<String, dynamic>;
    final docId = userInfo['id'] as String;
    final displayName = userData['displayName'] ?? 'Unknown User';
    final employeeId = userData['employeeId'] ?? 'Unknown ID';

    // Show password confirmation dialog first
    final passwordConfirmed = await _showCredentialConfirmationDialog(
      title: 'Confirm Employee Reactivation',
      message:
          'You are about to reactivate $displayName ($employeeId). This action requires password verification for security.',
      actionButtonText: 'Verify & Continue',
      actionButtonColor: Colors.green,
      icon: Icons.person_add,
    );

    if (!passwordConfirmed) return;

    // Show reactivation dialog after password verification
    final reactivationData = await _showReactivationDialog(
      displayName,
      employeeId,
    );
    if (reactivationData == null) return;

    try {
      // Update user status to reactivated
      await FirebaseFirestore.instance.collection('users').doc(docId).update({
        'isActive': true,
        'reactivationDate': Timestamp.now(),
        'reactivationReason': reactivationData['reason'],
        'reactivationComments': reactivationData['comments'],
        'reactivatedBy': FirebaseAuth.instance.currentUser?.uid,
        'updatedAt': Timestamp.now(),
        // Clear termination fields
        'terminationDate': null,
        'terminationReason': null,
        'terminationComments': null,
        'terminatedBy': null,
        'lastWorkingDay': null,
      });

      // Audit log for user reactivation
      final currentUser = ref.read(currentUserProvider).value;
      await AuditLogService().logEvent(
        action: 'ADMIN_REACTIVATE_USER',
        userId: currentUser?.uid,
        userName: currentUser?.displayName ?? currentUser?.email ?? 'Unknown',
        userEmail: currentUser?.email,
        status: 'success',
        targetType: 'user',
        targetId: docId,
        details: {
          'reactivatedUserEmail': userData['email'],
          'reactivatedUserDisplayName': displayName,
          'reactivatedUserEmployeeId': employeeId,
          'reactivationReason': reactivationData['reason'],
          'reactivationComments': reactivationData['comments'],
        },
      );

      _showSnackBar(
        'User $displayName has been reactivated successfully',
        isError: false,
      );

      // Clear selection if this user was selected
      if (_selectedUsers.contains(docId)) {
        setState(() {
          _selectedUsers.remove(docId);
        });
      }

      // Refresh users data
      ref.invalidate(usersDataProvider);
    } catch (e) {
      _showSnackBar('Failed to reactivate user: $e', isError: true);
    }
  }

  Future<Map<String, dynamic>?> _showReactivationDialog(
    String displayName,
    String employeeId,
  ) async {
    final commentsController = TextEditingController();
    String selectedReason = 'Return from Leave';

    final reasons = [
      'Return from Leave',
      'Rehire',
      'Contract Renewal',
      'Performance Improvement',
      'Administrative Error',
      'Other',
    ];

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Row(
                    children: [
                      Icon(Icons.person_add, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Reactivate Employee'),
                    ],
                  ),
                  content: SizedBox(
                    width: 400,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Employee info
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Employee: $displayName',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('ID: $employeeId'),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),

                        // Reactivation reason dropdown
                        Text(
                          'Reactivation Reason *',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: selectedReason,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items:
                              reasons
                                  .map(
                                    (reason) => DropdownMenuItem(
                                      value: reason,
                                      child: Text(reason),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                selectedReason = value;
                              });
                            }
                          },
                        ),
                        SizedBox(height: 16),

                        // Comments
                        Text(
                          'Comments',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: commentsController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Additional comments or notes...',
                            contentPadding: EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop({
                          'reason': selectedReason,
                          'comments': commentsController.text.trim(),
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Reactivate Employee'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showCreateUserDialog() {
    // Navigate to create user page or show dialog
    context.go('/admin/users/create');
  }
}
