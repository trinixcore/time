import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/hierarchy_service.dart';
import '../../../core/models/user_model.dart';

class OrgChartTree extends ConsumerWidget {
  final List<UserModel> users;
  final String? searchQuery;
  final String? departmentFilter;
  final String? designationFilter;

  const OrgChartTree({
    super.key,
    required this.users,
    this.searchQuery,
    this.departmentFilter,
    this.designationFilter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hierarchyService = ref.read(hierarchyServiceProvider);

    // Filter users based on search and filters
    final filteredUsers = _filterUsers(users);

    if (filteredUsers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No employees found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Build hierarchy tree
    final hierarchy = hierarchyService.buildHierarchy(filteredUsers);
    final rootNodes =
        hierarchy.where((node) => node.managerId == null).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children:
            rootNodes
                .map((node) => _buildTreeNode(context, node, hierarchy, 0))
                .toList(),
      ),
    );
  }

  List<UserModel> _filterUsers(List<UserModel> users) {
    return users.where((user) {
      // Search filter
      if (searchQuery != null && searchQuery!.isNotEmpty) {
        final query = searchQuery!.toLowerCase();
        final matchesName = user.displayName.toLowerCase().contains(query);
        final matchesEmail = user.email.toLowerCase().contains(query);
        final matchesUid = user.uid.toLowerCase().contains(query);

        if (!matchesName && !matchesEmail && !matchesUid) {
          return false;
        }
      }

      // Department filter (assuming role contains department info)
      if (departmentFilter != null && departmentFilter!.isNotEmpty) {
        // This would need to be adjusted based on how department is stored
        // For now, we'll skip this filter
      }

      // Designation filter (using role as designation)
      if (designationFilter != null && designationFilter!.isNotEmpty) {
        if (user.role.displayName != designationFilter) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Widget _buildTreeNode(
    BuildContext context,
    HierarchyNode node,
    List<HierarchyNode> allNodes,
    int level,
  ) {
    final children = allNodes.where((n) => n.managerId == node.id).toList();
    final hasChildren = children.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: level * 24.0, bottom: 8),
          child: Row(
            children: [
              // Connection lines
              if (level > 0) ...[
                Container(width: 20, height: 2, color: Colors.grey.shade400),
                const SizedBox(width: 4),
              ],

              // Expand/collapse indicator
              if (hasChildren)
                Icon(Icons.account_tree, size: 16, color: Colors.grey.shade600)
              else
                const SizedBox(width: 16),

              const SizedBox(width: 8),

              // User card
              Expanded(child: _buildUserCard(context, node, level)),
            ],
          ),
        ),

        // Children
        if (hasChildren) ...[
          // Vertical line
          if (level >= 0)
            Container(
              margin: EdgeInsets.only(left: (level * 24.0) + 8),
              width: 2,
              height: 16,
              color: Colors.grey.shade400,
            ),

          // Child nodes
          ...children.map(
            (child) => _buildTreeNode(context, child, allNodes, level + 1),
          ),
        ],
      ],
    );
  }

  Widget _buildUserCard(BuildContext context, HierarchyNode node, int level) {
    final cardColor = _getCardColor(node.designation, level);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.1),
        border: Border.all(color: cardColor, width: 1.5),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: cardColor,
            backgroundImage:
                node.profileImageUrl != null
                    ? NetworkImage(node.profileImageUrl!)
                    : null,
            child:
                node.profileImageUrl == null
                    ? Text(
                      _getInitials(node.name),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    )
                    : null,
          ),

          const SizedBox(width: 12),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  node.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  node.designation,
                  style: TextStyle(
                    color: cardColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (node.email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    node.email,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),

          // Action button
          IconButton(
            onPressed: () => _showUserDetails(context, node),
            icon: const Icon(Icons.more_vert, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }

  Color _getCardColor(String designation, int level) {
    // Color coding based on designation/level
    final lowerDesignation = designation.toLowerCase();

    if (lowerDesignation.contains('ceo') ||
        lowerDesignation.contains('president')) {
      return Colors.purple;
    } else if (lowerDesignation.contains('director') ||
        lowerDesignation.contains('cto') ||
        lowerDesignation.contains('cfo')) {
      return Colors.blue;
    } else if (lowerDesignation.contains('manager') ||
        lowerDesignation.contains('lead')) {
      return Colors.orange;
    } else if (lowerDesignation.contains('senior')) {
      return Colors.green;
    } else {
      return Colors.teal;
    }
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }

  void _showUserDetails(BuildContext context, HierarchyNode node) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(node.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Designation: ${node.designation}'),
                if (node.email.isNotEmpty) Text('Email: ${node.email}'),
                Text('Employee ID: ${node.id}'),
              ],
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
}
