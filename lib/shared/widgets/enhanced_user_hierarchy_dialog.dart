import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/enums/user_role.dart';
import '../../core/services/hierarchy_service.dart';
import '../../core/providers/performance_providers.dart';
import '../../features/org_chart/widgets/org_chart_search.dart';
import '../../features/org_chart/widgets/org_chart_filters.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/error_widget.dart';
import 'dart:math' as math;

// Use optimized provider from performance_providers.dart
final enhancedHierarchyDataProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
      // Watch for refresh triggers
      ref.watch(globalRefreshProvider);

      try {
        // Use optimized users data
        final usersData = await ref.watch(optimizedUsersDataProvider.future);
        final allUsers = <String, Map<String, dynamic>>{};

        // Process active users - convert QueryDocumentSnapshot to Map
        for (final doc in usersData['active'] ?? []) {
          final userData = doc.data() as Map<String, dynamic>;
          final docId = doc.id;
          allUsers[docId] = {
            ...userData,
            'id': docId,
            'isPending': false,
            'displayName': userData['displayName'] ?? 'Unknown User',
            'role': userData['role'] ?? 'Employee',
            'department': userData['department'] ?? 'Unassigned',
          };
        }

        // Process pending users - convert QueryDocumentSnapshot to Map
        for (final doc in usersData['pending'] ?? []) {
          final userData = doc.data() as Map<String, dynamic>;
          final docId = doc.id;
          allUsers[docId] = {
            ...userData,
            'id': docId,
            'isPending': true,
            'displayName': userData['displayName'] ?? 'Unknown User',
            'role': userData['role'] ?? 'Employee',
            'department': userData['department'] ?? 'Unassigned',
          };
        }

        // Find the target user
        final targetUser = allUsers[userId];
        if (targetUser == null) {
          throw Exception('User not found');
        }

        // Build optimized hierarchy tree
        final hierarchy = _buildEnhancedHierarchyTree(allUsers, userId);

        // Get basic organization stats (cached)
        final orgStats = await _getOrganizationStats(allUsers);

        return {
          'targetUser': targetUser,
          'hierarchy': hierarchy,
          'allUsers': allUsers,
          'orgStats': orgStats,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
      } catch (e) {
        throw Exception('Failed to load hierarchy: $e');
      }
    });

// Optimized hierarchy tree builder - Enhanced for tree view
Map<String, dynamic> _buildEnhancedHierarchyTree(
  Map<String, Map<String, dynamic>> allUsers,
  String targetUserId,
) {
  final targetUser = allUsers[targetUserId]!;

  // Build complete hierarchy tree starting from the top
  final hierarchyTree = _buildCompleteHierarchyTree(allUsers, targetUserId);

  return {
    'targetUser': targetUser,
    'hierarchyTree': hierarchyTree,
    'allUsers': allUsers,
  };
}

// Build complete hierarchy tree for tree view
Map<String, dynamic> _buildCompleteHierarchyTree(
  Map<String, Map<String, dynamic>> allUsers,
  String targetUserId,
) {
  // Find the root of the hierarchy (CEO/top-level manager)
  final targetUser = allUsers[targetUserId]!;
  String? currentUserId = targetUserId;

  // Traverse up to find the root
  final pathToRoot = <String>[];
  while (currentUserId != null) {
    pathToRoot.add(currentUserId);
    final user = allUsers[currentUserId];
    if (user == null) break;

    final managerId = user['reportingManagerId'] as String?;
    if (managerId == null || !allUsers.containsKey(managerId)) {
      break;
    }
    currentUserId = managerId;
  }

  // The last user in pathToRoot is the root
  final rootUserId = pathToRoot.last;

  // Build tree structure recursively from root
  return _buildTreeNode(allUsers, rootUserId, targetUserId, pathToRoot.toSet());
}

// Recursively build tree nodes
Map<String, dynamic> _buildTreeNode(
  Map<String, Map<String, dynamic>> allUsers,
  String userId,
  String targetUserId,
  Set<String> pathToTarget,
) {
  final user = allUsers[userId]!;

  // Find ALL direct reports (not just those in path)
  final directReports = <Map<String, dynamic>>[];
  for (final otherUser in allUsers.values) {
    if (otherUser['reportingManagerId'] == userId) {
      // Include ALL direct reports to show complete hierarchy
      directReports.add(
        _buildTreeNode(
          allUsers,
          otherUser['id'] as String,
          targetUserId,
          pathToTarget,
        ),
      );
    }
  }

  // Sort direct reports by name for consistent display
  directReports.sort((a, b) {
    final nameA =
        (a['user'] as Map<String, dynamic>)['displayName'] as String? ?? '';
    final nameB =
        (b['user'] as Map<String, dynamic>)['displayName'] as String? ?? '';
    return nameA.compareTo(nameB);
  });

  return {
    'user': user,
    'isTarget': userId == targetUserId,
    'isInPath': pathToTarget.contains(userId),
    'directReports': directReports,
    'level': _calculateLevel(allUsers, userId),
  };
}

// Calculate hierarchy level
int _calculateLevel(Map<String, Map<String, dynamic>> allUsers, String userId) {
  int level = 0;
  String? currentUserId = userId;

  while (currentUserId != null) {
    final user = allUsers[currentUserId];
    if (user == null) break;

    final managerId = user['reportingManagerId'] as String?;
    if (managerId == null || !allUsers.containsKey(managerId)) {
      break;
    }
    level++;
    currentUserId = managerId;
  }

  return level;
}

// Cached organization stats
Future<Map<String, dynamic>> _getOrganizationStats(
  Map<String, Map<String, dynamic>> allUsers,
) async {
  final departmentCounts = <String, int>{};
  final roleCounts = <String, int>{};
  var maxDepth = 0;

  for (final user in allUsers.values) {
    // Count by department
    final dept = user['department'] as String? ?? 'Unassigned';
    departmentCounts[dept] = (departmentCounts[dept] ?? 0) + 1;

    // Count by role
    final role = user['role'] as String? ?? 'Employee';
    roleCounts[role] = (roleCounts[role] ?? 0) + 1;
  }

  return {
    'totalEmployees': allUsers.length,
    'byDepartment': departmentCounts,
    'byRole': roleCounts,
    'maxHierarchyDepth': maxDepth,
  };
}

class EnhancedUserHierarchyDialog extends ConsumerStatefulWidget {
  final String userId;
  final String userName;

  const EnhancedUserHierarchyDialog({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  ConsumerState<EnhancedUserHierarchyDialog> createState() =>
      _EnhancedUserHierarchyDialogState();
}

class _EnhancedUserHierarchyDialogState
    extends ConsumerState<EnhancedUserHierarchyDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _departmentFilter = 'All';
  String _roleFilter = 'All';
  bool _showOnlyDirectReports = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hierarchyAsync = ref.watch(
      enhancedHierarchyDataProvider(widget.userId),
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.98,
        height: MediaQuery.of(context).size.height * 0.92,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(context),
            _buildTabBar(),
            Expanded(
              child: hierarchyAsync.when(
                data: (data) => _buildContent(context, data),
                loading:
                    () => const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading organizational hierarchy...'),
                        ],
                      ),
                    ),
                error:
                    (error, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading hierarchy',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.toString(),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              // Use new performance provider refresh
                              ref
                                  .read(globalRefreshProvider.notifier)
                                  .refreshData('users');
                              ref.refresh(
                                enhancedHierarchyDataProvider(widget.userId),
                              );
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_tree, color: Colors.white, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Organizational Hierarchy',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Viewing hierarchy for ${widget.userName}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Theme.of(context).primaryColor,
        tabs: const [
          Tab(icon: Icon(Icons.account_tree), text: 'Tree View'),
          Tab(icon: Icon(Icons.business), text: 'Department'),
          Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, Map<String, dynamic> data) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildTreeHierarchy(context, data),
        _buildDepartmentView(context, data),
        _buildAnalyticsView(context, data),
      ],
    );
  }

  // NEW: Tree-like hierarchy view
  Widget _buildTreeHierarchy(BuildContext context, Map<String, dynamic> data) {
    final hierarchyTree =
        data['hierarchy']['hierarchyTree'] as Map<String, dynamic>;

    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tree view header - more compact
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_tree,
                      color: Theme.of(context).primaryColor,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Complete Organizational Tree',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Shows the complete hierarchy with all levels. Click +/- to expand/collapse branches.',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor.withOpacity(0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tree structure with improved scrolling and centering
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.all(
                        20,
                      ), // Padding for better spacing
                      child: Center(
                        // Center the tree horizontally
                        child: HierarchyTreeWidget(
                          node: hierarchyTree,
                          onUserTap: _showUserDetails,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentView(BuildContext context, Map<String, dynamic> data) {
    final allUsers = data['allUsers'] as Map<String, Map<String, dynamic>>;
    final targetUser = data['hierarchy']['targetUser'] as Map<String, dynamic>;
    final department = targetUser['department'] as String?;

    if (department == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_center, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No Department Information',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final departmentUsers =
        allUsers.values
            .where((user) => user['department'] == department)
            .take(20) // Limit for performance
            .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDepartmentHeader(department, departmentUsers.length),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: departmentUsers.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildUserCard(departmentUsers[index]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsView(BuildContext context, Map<String, dynamic> data) {
    final orgStats = data['orgStats'] as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalyticsHeader(),
          const SizedBox(height: 16),
          _buildStatsGrid(orgStats),
        ],
      ),
    );
  }

  Widget _buildDepartmentHeader(String department, int userCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.business, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  department,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$userCount employees',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.analytics, color: Colors.white, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Organization Analytics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Key metrics and insights',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> orgStats) {
    final totalEmployees = orgStats['totalEmployees'] ?? 0;
    final byDepartment =
        orgStats['byDepartment'] as Map<String, dynamic>? ?? {};
    final byRole = orgStats['byRole'] as Map<String, dynamic>? ?? {};

    return Column(
      children: [
        // Summary cards
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Employees',
                totalEmployees.toString(),
                Icons.people,
                Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Departments',
                byDepartment.length.toString(),
                Icons.business,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Department breakdown
        if (byDepartment.isNotEmpty) ...[
          _buildSectionTitle('Department Distribution'),
          const SizedBox(height: 8),
          ...byDepartment.entries
              .take(5)
              .map(
                (entry) =>
                    _buildProgressItem(entry.key, entry.value, totalEmployees),
              ),
        ],
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, dynamic value, int total) {
    final count = value is int ? value : 0;
    final percentage = total > 0 ? (count / total * 100) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              Text(
                '$count (${percentage.toStringAsFixed(1)}%)',
                style: TextStyle(color: Colors.grey[600], fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => UserDetailsDialog(user: user),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'ceo':
      case 'cto':
      case 'cfo':
        return Colors.purple;
      case 'director':
      case 'manager':
        return Colors.blue;
      case 'senior':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'
        .toUpperCase();
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final isPending = user['isPending'] as bool? ?? false;
    final isTarget = user['id'] == widget.userId;

    return Card(
      elevation: isTarget ? 4 : 1, // Reduced elevation
      color: isTarget ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      child: InkWell(
        onTap: () => _showUserDetails(user),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8), // Reduced padding from 12 to 8
          child: IntrinsicWidth(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar - smaller size
                CircleAvatar(
                  radius: 16, // Reduced from 20 to 16
                  backgroundColor: _getRoleColor(
                    user['role'] as String? ?? 'Employee',
                  ),
                  child: Text(
                    _getInitials(user['displayName'] as String? ?? 'Unknown'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10, // Reduced font size
                    ),
                  ),
                ),
                const SizedBox(width: 8), // Reduced spacing
                // User info - dynamic width based on content
                Flexible(
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 120, // Minimum readable width
                      maxWidth: 200, // Maximum to prevent excessive stretching
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                user['displayName'] as String? ??
                                    'Unknown User',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  // Changed from titleSmall to bodyMedium
                                  fontWeight:
                                      isTarget
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                  fontSize: 12, // Explicit smaller font size
                                ),
                                maxLines: 1, // Prevent text overflow
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4), // Reduced spacing
                            if (isTarget)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3, // Further reduced padding
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'YOU',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 7, // Further reduced font size
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (isPending && !isTarget)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3, // Further reduced padding
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'PENDING',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 7, // Further reduced font size
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2), // Reduced spacing
                        Text(
                          user['designation'] as String? ?? 'No Designation',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 10, // Reduced font size
                          ),
                          maxLines: 1, // Prevent text overflow
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (user['department'] != null) ...[
                          const SizedBox(height: 1), // Reduced spacing
                          Text(
                            user['department'] as String,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontSize: 9, // Reduced font size
                            ),
                            maxLines: 1, // Prevent text overflow
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4), // Reduced spacing
                // Chevron icon - smaller
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 14,
                ), // Reduced size
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UserDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserDetailsDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 350, // Reduced from 400 to 350
        padding: const EdgeInsets.all(16), // Reduced padding from 20 to 16
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 32, // Reduced from 40 to 32
              backgroundColor: _getRoleColor(
                user['role'] as String? ?? 'Employee',
              ),
              child: Text(
                _getInitials(user['displayName'] as String? ?? 'Unknown'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20, // Reduced from 24 to 20
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12), // Reduced spacing
            Text(
              user['displayName'] as String? ?? 'Unknown User',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 18, // Explicit smaller font size
              ),
              textAlign: TextAlign.center,
              maxLines: 2, // Prevent overflow
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6), // Reduced spacing
            Text(
              user['designation'] as String? ?? 'No Designation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).primaryColor,
                fontSize: 14, // Explicit font size
              ),
              textAlign: TextAlign.center,
              maxLines: 1, // Prevent overflow
              overflow: TextOverflow.ellipsis,
            ),
            if (user['department'] != null) ...[
              const SizedBox(height: 3), // Reduced spacing
              Text(
                user['department'] as String,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12, // Explicit font size
                ),
                textAlign: TextAlign.center,
                maxLines: 1, // Prevent overflow
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (user['email'] != null) ...[
              const SizedBox(height: 6), // Reduced spacing
              Text(
                user['email'] as String,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11, // Explicit font size
                ),
                textAlign: TextAlign.center,
                maxLines: 1, // Prevent overflow
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 16), // Reduced spacing
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ), // Compact button
              ),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'ceo':
      case 'cto':
      case 'cfo':
        return Colors.purple;
      case 'director':
      case 'manager':
        return Colors.blue;
      case 'senior':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'
        .toUpperCase();
  }
}

// Tree Widget for displaying hierarchical structure
class HierarchyTreeWidget extends StatefulWidget {
  final Map<String, dynamic> node;
  final Function(Map<String, dynamic>) onUserTap;

  const HierarchyTreeWidget({
    super.key,
    required this.node,
    required this.onUserTap,
  });

  @override
  State<HierarchyTreeWidget> createState() => _HierarchyTreeWidgetState();
}

class _HierarchyTreeWidgetState extends State<HierarchyTreeWidget> {
  bool _isExpanded = false; // Start collapsed by default

  @override
  void initState() {
    super.initState();
    // Auto-expand if this node is in the path to target user
    final isInPath = widget.node['isInPath'] as bool? ?? false;
    final isTarget = widget.node['isTarget'] as bool? ?? false;
    _isExpanded = isInPath || isTarget; // Expand path to target
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.node['user'] as Map<String, dynamic>;
    final isTarget = widget.node['isTarget'] as bool? ?? false;
    final isInPath = widget.node['isInPath'] as bool? ?? false;
    final directReports = widget.node['directReports'] as List<dynamic>? ?? [];
    final level = widget.node['level'] as int? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // User node - centered
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.0), // Reduced margin
          child: Column(
            children: [
              // Expand/collapse button for nodes with children (above the card)
              if (directReports.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Container(
                    width: 20, // Reduced size
                    height: 20,
                    margin: const EdgeInsets.only(bottom: 4), // Reduced margin
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      _isExpanded ? Icons.remove : Icons.add,
                      size: 14, // Reduced icon size
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),

              // User card - dynamic width based on content
              IntrinsicWidth(
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 180, // Minimum width to ensure readability
                    maxWidth:
                        280, // Maximum width to prevent excessive stretching
                  ),
                  child: _buildTreeUserCard(user, isTarget, isInPath),
                ),
              ),
            ],
          ),
        ),

        // Connection line down (if has children and expanded)
        if (_isExpanded && directReports.isNotEmpty) ...[
          Container(
            width: 2,
            height: 16, // Reduced height
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            margin: const EdgeInsets.symmetric(vertical: 2), // Reduced margin
          ),
        ],

        // Children count when collapsed
        if (!_isExpanded && directReports.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.only(top: 4), // Reduced margin
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ), // Reduced padding
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
            child: Text(
              '${directReports.length} direct report${directReports.length == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 10, // Reduced font size
              ),
            ),
          ),
        ],

        // Children (direct reports) - displayed horizontally when expanded
        if (_isExpanded && directReports.isNotEmpty) ...[
          // Vertical line down from parent
          Container(
            width: 2,
            height: 16,
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            margin: const EdgeInsets.symmetric(vertical: 2),
          ),

          // Direct reports in horizontal layout with connecting lines
          IntrinsicHeight(
            child: Stack(
              children: [
                // Horizontal connector line across all children
                if (directReports.length > 1)
                  Positioned(
                    top: 20, // Position at the top of vertical lines
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                  ),

                // Children nodes
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      directReports.asMap().entries.map((entry) {
                        final index = entry.key;
                        final childNode = entry.value as Map<String, dynamic>;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Vertical line down to child
                              Container(
                                width: 2,
                                height: 20,
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.3),
                                margin: const EdgeInsets.only(bottom: 6),
                              ),
                              // Child node
                              HierarchyTreeWidget(
                                node: childNode,
                                onUserTap: widget.onUserTap,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTreeUserCard(
    Map<String, dynamic> user,
    bool isTarget,
    bool isInPath,
  ) {
    final isPending = user['isPending'] as bool? ?? false;

    return Card(
      elevation: isTarget ? 6 : (isInPath ? 3 : 1), // Reduced elevation
      color:
          isTarget
              ? Theme.of(context).primaryColor.withOpacity(0.15)
              : isInPath
              ? Theme.of(context).primaryColor.withOpacity(0.05)
              : null,
      child: InkWell(
        onTap: () => widget.onUserTap(user),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8), // Reduced padding from 12 to 8
          child: IntrinsicWidth(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar - smaller size
                CircleAvatar(
                  radius: 16, // Reduced from 20 to 16
                  backgroundColor: _getRoleColor(
                    user['role'] as String? ?? 'Employee',
                  ),
                  child: Text(
                    _getInitials(user['displayName'] as String? ?? 'Unknown'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10, // Reduced font size
                    ),
                  ),
                ),
                const SizedBox(width: 8), // Reduced spacing
                // User info - dynamic width based on content
                Flexible(
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 120, // Minimum readable width
                      maxWidth: 200, // Maximum to prevent excessive stretching
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                user['displayName'] as String? ??
                                    'Unknown User',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  // Changed from titleSmall to bodyMedium
                                  fontWeight:
                                      isTarget
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                  fontSize: 12, // Explicit smaller font size
                                ),
                                maxLines: 1, // Prevent text overflow
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4), // Reduced spacing
                            if (isTarget)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3, // Further reduced padding
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'YOU',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 7, // Further reduced font size
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (isPending && !isTarget)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3, // Further reduced padding
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'PENDING',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 7, // Further reduced font size
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2), // Reduced spacing
                        Text(
                          user['designation'] as String? ?? 'No Designation',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 10, // Reduced font size
                          ),
                          maxLines: 1, // Prevent text overflow
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (user['department'] != null) ...[
                          const SizedBox(height: 1), // Reduced spacing
                          Text(
                            user['department'] as String,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontSize: 9, // Reduced font size
                            ),
                            maxLines: 1, // Prevent text overflow
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4), // Reduced spacing
                // Chevron icon - smaller
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 14,
                ), // Reduced size
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'ceo':
      case 'cto':
      case 'cfo':
        return Colors.purple;
      case 'director':
      case 'manager':
        return Colors.blue;
      case 'senior':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'
        .toUpperCase();
  }
}

// Show function for the enhanced dialog
void showEnhancedUserHierarchyDialog(
  BuildContext context,
  String userId,
  String userName,
) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder:
        (context) =>
            EnhancedUserHierarchyDialog(userId: userId, userName: userName),
  );
}
