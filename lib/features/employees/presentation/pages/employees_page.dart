import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/enums/employee_status.dart';
import '../../../../core/providers/employee_provider.dart';
import '../../../../core/providers/performance_providers.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/services/export_service.dart';
import '../../../../shared/providers/auth_providers.dart';
import '../../../../shared/widgets/enhanced_user_hierarchy_dialog.dart';
import '../widgets/employee_filters_widget.dart';
import '../widgets/employee_form_dialog.dart';
import '../../../dashboard/ui/dashboard_scaffold.dart';

// Use the optimized users provider instead of allUsersProvider to get raw Firestore data
final employeesDataProvider = optimizedUsersDataProvider;

class EmployeesPage extends ConsumerStatefulWidget {
  final String? action;

  const EmployeesPage({super.key, this.action});

  @override
  ConsumerState<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends ConsumerState<EmployeesPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;
  String _searchQuery = '';
  Set<String> _selectedEmployees = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Handle create action from dashboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.action == 'create') {
        context.push('/admin/users/create');
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final managementState = ref.watch(employeeManagementProvider);

    return currentUserAsync.when(
      data:
          (currentUser) => DashboardScaffold(
            currentPath: '/employees',
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Employee Management'),
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
                  // Enhanced Export menu
                  if (_canExport(currentUser?.role))
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) => _handleMenuAction(value, context),
                      itemBuilder:
                          (context) => [
                            const PopupMenuItem(
                              value: 'export_basic',
                              child: Row(
                                children: [
                                  Icon(Icons.download),
                                  SizedBox(width: 8),
                                  Text('Export All Employees (Basic)'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'export_detailed',
                              child: Row(
                                children: [
                                  Icon(Icons.download_for_offline),
                                  SizedBox(width: 8),
                                  Text('Export All Employees (Detailed)'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'export_filtered',
                              child: Row(
                                children: [
                                  Icon(Icons.filter_alt),
                                  SizedBox(width: 8),
                                  Text('Export Filtered Employees'),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            const PopupMenuItem(
                              value: 'import',
                              child: Row(
                                children: [
                                  Icon(Icons.upload),
                                  SizedBox(width: 8),
                                  Text('Import Employees'),
                                ],
                              ),
                            ),
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
                  if (_canCreateEmployee(currentUser?.role))
                    ElevatedButton.icon(
                      onPressed: () => context.push('/admin/users/create'),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Employee'),
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
                          Tab(text: 'All Employees'),
                          Tab(text: 'Active'),
                          Tab(text: 'Pending'),
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
                  if (_selectedEmployees.isNotEmpty) _buildBulkActionsBar(),

                  // Error display
                  if (managementState.hasError)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              managementState.error!,
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              ref
                                  .read(employeeManagementProvider.notifier)
                                  .clearError();
                            },
                          ),
                        ],
                      ),
                    ),

                  // Main content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildEmployeesList('all'),
                        _buildEmployeesList('active'),
                        _buildEmployeesList('pending'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (error, stack) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(currentUserProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
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
          Expanded(child: const EmployeeFiltersWidget()),
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
    final currentUser = ref.read(currentUserProvider).valueOrNull;

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
            '${_selectedEmployees.length} selected',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Spacer(),
          // Enhanced Export dropdown menu
          if (_canExport(currentUser?.role))
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
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
                    Icon(
                      Icons.arrow_drop_down,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          if (_canExport(currentUser?.role)) const SizedBox(width: 8),
          TextButton.icon(
            onPressed: _clearSelection,
            icon: const Icon(Icons.clear),
            label: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeesList(String filter) {
    final usersAsync = ref.watch(optimizedUsersDataProvider);
    final filters = ref.watch(employeeFiltersProvider);

    return usersAsync.when(
      data: (usersData) {
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

        final filteredUsers = _applyRawDataFilters(allUsers, filter, filters);

        if (filteredUsers.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(optimizedUsersDataProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              return _buildEnhancedEmployeeCardFromRawData(
                filteredUsers[index],
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 16),
                Text('Error loading employees: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(optimizedUsersDataProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
    );
  }

  List<Map<String, dynamic>> _applyRawDataFilters(
    List<Map<String, dynamic>> users,
    String filter,
    EmployeeFilters filters,
  ) {
    return users.where((userWrapper) {
      final userData = userWrapper['data'] as Map<String, dynamic>;
      final isPending = userWrapper['isPending'] as bool;
      final isActive = userWrapper['isActive'] as bool;

      // Apply tab filter
      switch (filter) {
        case 'active':
          if (!isActive || isPending) return false;
          break;
        case 'pending':
          if (!isPending) return false;
          break;
        // 'all' shows everything
      }

      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        final name = (userData['displayName'] ?? '').toString().toLowerCase();
        final email = (userData['email'] ?? '').toString().toLowerCase();
        final employeeId =
            (userData['employeeId'] ?? '').toString().toLowerCase();

        if (!name.contains(_searchQuery) &&
            !email.contains(_searchQuery) &&
            !employeeId.contains(_searchQuery)) {
          return false;
        }
      }

      // Apply status filter from dropdown
      if (filters.status != null) {
        switch (filters.status!) {
          case EmployeeStatus.active:
            if (!isActive || isPending) return false;
            break;
          case EmployeeStatus.inactive:
            if (isActive && !isPending) return false;
            break;
          case EmployeeStatus.terminated:
            // For now, treat terminated as inactive since UserModel doesn't have terminated status
            if (isActive && !isPending) return false;
            break;
          case EmployeeStatus.suspended:
            // For now, treat suspended as inactive since UserModel doesn't have suspended status
            if (isActive && !isPending) return false;
            break;
          case EmployeeStatus.probation:
            // For now, treat probation as active since UserModel doesn't have probation status
            if (!isActive || isPending) return false;
            break;
          case EmployeeStatus.notice:
            // For now, treat notice period as active since UserModel doesn't have notice status
            if (!isActive || isPending) return false;
            break;
          case EmployeeStatus.onLeave:
            // This would need additional logic if you have leave status in UserModel
            break;
        }
      }

      // Apply role filter from dropdown
      if (filters.role != null) {
        final roleString = userData['role'] ?? 'employee';
        final userRole = UserRole.fromString(roleString);
        if (userRole != filters.role!) return false;
      }

      // Apply department filter if needed (currently not in the UI but available in the filter)
      if (filters.department != null && filters.department!.isNotEmpty) {
        final userDepartment =
            (userData['department'] ?? '').toString().toLowerCase();
        if (userDepartment != filters.department!.toLowerCase()) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Widget _buildEnhancedEmployeeCardFromRawData(
    Map<String, dynamic> userWrapper,
  ) {
    final userData = userWrapper['data'] as Map<String, dynamic>;
    final userId = userWrapper['id'] as String;
    final isSelected = _selectedEmployees.contains(userId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      color:
          isSelected
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
              : null,
      child: InkWell(
        onTap: () => _toggleEmployeeSelection(userId),
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
                    onChanged: (value) => _toggleEmployeeSelection(userId),
                  ),
                  const SizedBox(width: 12),
                  // Employee avatar
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      _getInitials(userData['displayName'] ?? ''),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Employee info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData['displayName'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (userData['employeeId'] != null)
                          Text(
                            userData['employeeId']!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Actions menu (removed status chip)
                  PopupMenuButton<String>(
                    onSelected:
                        (action) =>
                            _handleEmployeeAction(action, userData, userId),
                    itemBuilder:
                        (context) => [
                          // View option - always available
                          const PopupMenuItem(
                            value: 'view',
                            child: Row(
                              children: [
                                Icon(Icons.visibility),
                                SizedBox(width: 8),
                                Text('View Details'),
                              ],
                            ),
                          ),
                          // Show Hierarchy option - always available
                          const PopupMenuItem(
                            value: 'hierarchy',
                            child: Row(
                              children: [
                                Icon(Icons.account_tree),
                                SizedBox(width: 8),
                                Text('Show Hierarchy'),
                              ],
                            ),
                          ),
                        ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Employee details
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(Icons.email, userData['email'] ?? ''),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      Icons.business,
                      userData['department'] ?? 'No Department',
                    ),
                  ),
                ],
              ),
              if (userData['phoneNumber'] != null) ...[
                const SizedBox(height: 8),
                _buildInfoChip(Icons.phone, userData['phoneNumber']!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String displayName) {
    if (displayName.isEmpty) return 'U';
    final parts = displayName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return displayName[0].toUpperCase();
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
            'No employees found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first employee to get started',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.push('/admin/users/create'),
            icon: const Icon(Icons.person_add),
            label: const Text('Add Employee'),
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
            'Error loading employees',
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
            onPressed: () {
              ref.invalidate(allUsersProvider);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Search Employees'),
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

  void _handleMenuAction(String action, BuildContext context) {
    switch (action) {
      case 'export_basic':
        _exportEmployees(detailed: false);
        break;
      case 'export_detailed':
        _exportEmployees(detailed: true);
        break;
      case 'export_filtered':
        _exportFilteredEmployees();
        break;
      case 'import':
        _importEmployees();
        break;
      case 'statistics':
        _showStatistics();
        break;
    }
  }

  void _handleEmployeeAction(
    String action,
    Map<String, dynamic> userData,
    String userId,
  ) {
    switch (action) {
      case 'view':
        context.push('/employees/${userId}');
        break;
      case 'hierarchy':
        showDialog(
          context: context,
          builder:
              (context) => EnhancedUserHierarchyDialog(
                userId: userId,
                userName: userData['displayName'] ?? '',
              ),
        );
        break;
      default:
        break;
    }
  }

  void _exportEmployees({bool detailed = false}) async {
    try {
      // Use the same provider as admin/users page to get raw Firestore data
      final usersDataAsync = ref.read(optimizedUsersDataProvider);

      await usersDataAsync.when(
        data: (usersData) async {
          final activeUsers = usersData['active'] ?? [];
          final pendingUsers = usersData['pending'] ?? [];

          List<Map<String, dynamic>> allUsers = [];

          // Add active users - same approach as admin/users page
          for (var doc in activeUsers) {
            final userData = doc.data() as Map<String, dynamic>?;
            if (userData != null) {
              allUsers.add({
                'data':
                    userData, // Raw Firestore data with all fields including joiningDate
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
                'data': userData, // Raw Firestore data with all fields
                'id': doc.id,
                'isPending': true,
                'isActive': false,
              });
            }
          }

          if (allUsers.isEmpty) {
            _showSnackBar('No employees found to export', isError: true);
            return;
          }

          final filename = ExportService.generateFilename(
            detailed ? 'detailed_employees_export' : 'employees_export',
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
            'Successfully exported ${allUsers.length} employees to $filename.csv',
            isError: false,
          );
        },
        loading: () {
          _showSnackBar('Loading employee data...', isError: false);
        },
        error: (error, stack) {
          _showSnackBar('Failed to load employee data: $error', isError: true);
        },
      );
    } catch (e) {
      _showSnackBar('Export failed: $e', isError: true);
    }
  }

  void _exportFilteredEmployees() async {
    try {
      // Use raw Firestore data for export
      final usersDataAsync = ref.read(optimizedUsersDataProvider);

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

          // Apply current filters (need to adapt filtering for raw data)
          final currentTab = _tabController.index;
          final filterType = ['all', 'active', 'pending'][currentTab];
          final filters = ref.read(employeeFiltersProvider);
          final filteredUsers = _applyRawDataFilters(
            allUsers,
            filterType,
            filters,
          );

          if (filteredUsers.isEmpty) {
            _showSnackBar(
              'No employees match the current filters',
              isError: true,
            );
            return;
          }

          final filename = ExportService.generateFilename(
            'filtered_employees_export',
          );

          ExportService.exportUsersToCSV(
            users: filteredUsers,
            filename: filename,
          );

          _showSnackBar(
            'Successfully exported ${filteredUsers.length} filtered employees to $filename.csv',
            isError: false,
          );
        },
        loading: () {
          _showSnackBar('Loading employee data...', isError: false);
        },
        error: (error, stack) {
          _showSnackBar('Failed to load employee data: $error', isError: true);
        },
      );
    } catch (e) {
      _showSnackBar('Export failed: $e', isError: true);
    }
  }

  void _bulkExport() async {
    if (_selectedEmployees.isEmpty) {
      _showSnackBar('No employees selected for export', isError: true);
      return;
    }

    try {
      // Use raw Firestore data for export
      final usersDataAsync = ref.read(optimizedUsersDataProvider);

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
            'selected_employees_export',
          );

          ExportService.exportSelectedUsersToCSV(
            users: allUsers,
            selectedUserIds: _selectedEmployees,
            filename: filename,
          );

          _showSnackBar(
            'Successfully exported ${_selectedEmployees.length} selected employees to $filename.csv',
            isError: false,
          );

          // Clear selection after export
          _clearSelection();
        },
        loading: () {
          _showSnackBar('Loading employee data...', isError: false);
        },
        error: (error, stack) {
          _showSnackBar('Failed to load employee data: $error', isError: true);
        },
      );
    } catch (e) {
      _showSnackBar('Bulk export failed: $e', isError: true);
    }
  }

  void _bulkExportDetailed() async {
    if (_selectedEmployees.isEmpty) {
      _showSnackBar('No employees selected for detailed export', isError: true);
      return;
    }

    try {
      // Use raw Firestore data for export
      final usersDataAsync = ref.read(optimizedUsersDataProvider);

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
            'selected_employees_detailed_export',
          );

          ExportService.exportDetailedSelectedUsersToCSV(
            users: allUsers,
            selectedUserIds: _selectedEmployees,
            filename: filename,
          );

          _showSnackBar(
            'Successfully exported ${_selectedEmployees.length} selected employees to $filename.csv',
            isError: false,
          );

          // Clear selection after export
          _clearSelection();
        },
        loading: () {
          _showSnackBar('Loading employee data...', isError: false);
        },
        error: (error, stack) {
          _showSnackBar('Failed to load employee data: $error', isError: true);
        },
      );
    } catch (e) {
      _showSnackBar('Detailed export failed: $e', isError: true);
    }
  }

  void _importEmployees() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import functionality coming soon')),
    );
  }

  void _showStatistics() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Statistics view coming soon')),
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: Duration(seconds: isError ? 4 : 3),
        ),
      );
    }
  }

  bool _hasActiveFilters() {
    final filters = ref.read(employeeFiltersProvider);
    return filters.hasFilters || _searchQuery.isNotEmpty;
  }

  void _toggleEmployeeSelection(String employeeId) {
    setState(() {
      if (_selectedEmployees.contains(employeeId)) {
        _selectedEmployees.remove(employeeId);
      } else {
        _selectedEmployees.add(employeeId);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedEmployees.clear();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
    ref.read(employeeFiltersProvider.notifier).clearFilters();
  }

  void _showCreateEmployeeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const EmployeeFormDialog(),
    ).then((result) {
      if (result != null) {
        // Refresh the employee list
        ref.invalidate(allUsersProvider);
        ref.invalidate(employeeListProvider);
      }
    });
  }

  // Permission checks
  bool _canCreateEmployee(UserRole? role) {
    // Only allow creating employees from admin panel
    return false;
  }

  bool _canChangeStatus(Map<String, dynamic> userData) {
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) return false;

    final userRole = UserRole.fromString(userData['role'] ?? 'employee');
    return currentUser.role == UserRole.sa ||
        currentUser.role == UserRole.admin ||
        currentUser.role == UserRole.hr;
  }

  bool _canExport(UserRole? role) {
    return role == UserRole.sa || role == UserRole.admin || role == UserRole.hr;
  }
}
