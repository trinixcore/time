import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/enums/user_role.dart';

// Provider for hierarchy data
final hierarchyDataProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
      try {
        // Get all users data
        final usersSnapshot =
            await FirebaseFirestore.instance.collection('users').get();
        final pendingSnapshot =
            await FirebaseFirestore.instance.collection('pending_users').get();

        final allUsers = <String, Map<String, dynamic>>{};

        // Add active users
        for (final doc in usersSnapshot.docs) {
          final data = doc.data();
          allUsers[doc.id] = {...data, 'id': doc.id, 'isPending': false};
        }

        // Add pending users
        for (final doc in pendingSnapshot.docs) {
          final data = doc.data();
          allUsers[doc.id] = {...data, 'id': doc.id, 'isPending': true};
        }

        // Find the target user
        final targetUser = allUsers[userId];
        if (targetUser == null) {
          throw Exception('User not found');
        }

        // Build hierarchy tree
        final hierarchy = _buildHierarchyTree(allUsers, userId);

        return {
          'targetUser': targetUser,
          'hierarchy': hierarchy,
          'allUsers': allUsers,
        };
      } catch (e) {
        throw Exception('Failed to load hierarchy: $e');
      }
    });

Map<String, dynamic> _buildHierarchyTree(
  Map<String, Map<String, dynamic>> allUsers,
  String targetUserId,
) {
  final targetUser = allUsers[targetUserId]!;

  // Find reporting manager
  final reportingManagerId = targetUser['reportingManagerId'] as String?;
  Map<String, dynamic>? manager;
  if (reportingManagerId != null && allUsers.containsKey(reportingManagerId)) {
    manager = allUsers[reportingManagerId];
  }

  // Find direct reports
  final directReports = <Map<String, dynamic>>[];
  for (final user in allUsers.values) {
    if (user['reportingManagerId'] == targetUserId) {
      directReports.add(user);
    }
  }

  // Find peers (same reporting manager)
  final peers = <Map<String, dynamic>>[];
  if (reportingManagerId != null) {
    for (final user in allUsers.values) {
      if (user['reportingManagerId'] == reportingManagerId &&
          user['id'] != targetUserId) {
        peers.add(user);
      }
    }
  }

  // Find manager's manager (grandparent)
  Map<String, dynamic>? grandManager;
  if (manager != null) {
    final grandManagerId = manager['reportingManagerId'] as String?;
    if (grandManagerId != null && allUsers.containsKey(grandManagerId)) {
      grandManager = allUsers[grandManagerId];
    }
  }

  return {
    'targetUser': targetUser,
    'manager': manager,
    'grandManager': grandManager,
    'directReports': directReports,
    'peers': peers,
  };
}

class UserHierarchyDialog extends ConsumerWidget {
  final String userId;
  final String userName;

  const UserHierarchyDialog({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hierarchyAsync = ref.watch(hierarchyDataProvider(userId));

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
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
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF1565C0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_tree, color: Colors.white, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Organizational Hierarchy',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Hierarchy for $userName',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: hierarchyAsync.when(
                data: (data) => _buildHierarchyView(context, data),
                loading: () => _buildLoadingState(),
                error: (error, stack) => _buildErrorState(error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              color: Color(0xFF3B82F6),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading organizational hierarchy...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Failed to load hierarchy',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error.toString(),
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHierarchyView(BuildContext context, Map<String, dynamic> data) {
    final hierarchy = data['hierarchy'] as Map<String, dynamic>;
    final targetUser = hierarchy['targetUser'] as Map<String, dynamic>;
    final manager = hierarchy['manager'] as Map<String, dynamic>?;
    final grandManager = hierarchy['grandManager'] as Map<String, dynamic>?;
    final directReports =
        hierarchy['directReports'] as List<Map<String, dynamic>>;
    final peers = hierarchy['peers'] as List<Map<String, dynamic>>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Grand Manager (Top Level)
          if (grandManager != null) ...[
            _buildUserCard(context, grandManager, isGrandManager: true),
            _buildVerticalConnector(),
          ],

          // Manager
          if (manager != null) ...[
            _buildUserCard(context, manager, isManager: true),
            _buildVerticalConnector(),
          ],

          // Peers Section
          if (peers.isNotEmpty) ...[
            _buildPeersSection(context, hierarchy),
            const SizedBox(height: 32),
          ],

          // Target User (Center)
          _buildUserCard(context, targetUser, isTarget: true),

          // Direct Reports
          if (directReports.isNotEmpty) ...[
            const SizedBox(height: 32),
            _buildDirectReportsSection(context, hierarchy),
          ],
        ],
      ),
    );
  }

  Widget _buildPeersSection(
    BuildContext context,
    Map<String, dynamic> hierarchy,
  ) {
    final peers = hierarchy['peers'] as List;

    if (peers.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        // Horizontal line to peers
        Container(height: 2, width: 200, color: const Color(0xFF1565C0)),
        const SizedBox(height: 16),
        // Peers row
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children:
              peers
                  .map((peer) => _buildUserCard(context, peer, isPeer: true))
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildDirectReportsSection(
    BuildContext context,
    Map<String, dynamic> hierarchy,
  ) {
    final directReports = hierarchy['directReports'] as List;

    if (directReports.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        // Vertical connector down
        _buildVerticalConnector(),
        // Horizontal distribution line
        Container(height: 2, width: 400, color: const Color(0xFF1565C0)),
        const SizedBox(height: 16),
        // Direct reports
        Wrap(
          spacing: 24,
          runSpacing: 24,
          alignment: WrapAlignment.center,
          children:
              directReports
                  .map((report) => _buildDirectReportColumn(context, report))
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildDirectReportColumn(
    BuildContext context,
    Map<String, dynamic> report,
  ) {
    final subordinates = report['subordinates'] as List<dynamic>? ?? [];

    return Column(
      children: [
        // Vertical line up to distribution line
        Container(width: 2, height: 16, color: const Color(0xFF1565C0)),
        // Direct report card
        _buildUserCard(context, report, isDirectReport: true),
        // Subordinates
        if (subordinates.isNotEmpty) ...[
          const SizedBox(height: 16),
          // Vertical connector
          Container(width: 2, height: 20, color: const Color(0xFF4CAF50)),
          const SizedBox(height: 8),
          // Subordinates
          ...subordinates
              .map(
                (sub) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildUserCard(context, sub, isSubordinate: true),
                ),
              )
              .toList(),
        ],
      ],
    );
  }

  Widget _buildUserCard(
    BuildContext context,
    Map<String, dynamic> user, {
    bool isTarget = false,
    bool isManager = false,
    bool isGrandManager = false,
    bool isPeer = false,
    bool isDirectReport = false,
    bool isSubordinate = false,
  }) {
    Color cardColor;
    Color roleColor;

    if (isTarget) {
      cardColor = const Color(0xFFFFF3E0);
      roleColor = const Color(0xFFFF9800);
    } else if (isGrandManager) {
      cardColor = const Color(0xFFE3F2FD);
      roleColor = const Color(0xFF1565C0);
    } else if (isManager) {
      cardColor = const Color(0xFFFFF3E0);
      roleColor = const Color(0xFFFF9800);
    } else if (isPeer) {
      cardColor = const Color(0xFFE8F5E8);
      roleColor = const Color(0xFF4CAF50);
    } else if (isDirectReport) {
      cardColor = const Color(0xFFE8F5E8);
      roleColor = const Color(0xFF4CAF50);
    } else {
      cardColor = const Color(0xFFE8F5E8);
      roleColor = const Color(0xFF4CAF50);
    }

    return GestureDetector(
      onTap: () => _showUserDetails(context, user),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isTarget ? const Color(0xFFFF9800) : Colors.grey.shade300,
            width: isTarget ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: roleColor,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 8),
            // Role badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: roleColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                user['role'] ?? 'N/A',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            // Name
            Text(
              user['displayName'] ?? 'Unknown',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalConnector() {
    return Container(width: 2, height: 32, color: const Color(0xFF1565C0));
  }

  void _showUserDetails(BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => UserDetailsDialog(user: user),
    );
  }
}

class UserDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserDetailsDialog({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 25,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with gradient
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1565C0).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar with shadow
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: Icon(
                        user['gender'] == 'Female'
                            ? Icons.person_2_rounded
                            : Icons.person_rounded,
                        size: 40,
                        color: const Color(0xFF1565C0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['displayName'] ?? 'Unknown User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user['role'] ?? 'No Role',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection('Personal Information', [
                      _buildDetailRow('Email', user['email']),
                      _buildDetailRow('Phone', user['phone']),
                      _buildDetailRow('Gender', user['gender']),
                      _buildDetailRow('Date of Birth', user['dateOfBirth']),
                      _buildDetailRow('Address', user['address']),
                      _buildDetailRow(
                        'Emergency Contact',
                        user['emergencyContact'],
                      ),
                    ]),
                    const SizedBox(height: 32),
                    _buildSection('Professional Information', [
                      _buildDetailRow('Department', user['department']),
                      _buildDetailRow('Designation', user['designation']),
                      _buildDetailRow('Joining Date', user['joiningDate']),
                      _buildDetailRow(
                        'Reporting Manager ID',
                        user['reportingManagerId'],
                      ),
                    ]),
                    const SizedBox(height: 32),
                    _buildSection('Account Information', [
                      _buildDetailRow(
                        'Account Status',
                        null,
                        customWidget: _buildStatusChip(user['accountStatus']),
                      ),
                      _buildDetailRow('Created At', user['createdAt']),
                      _buildDetailRow('Last Login', user['lastLogin']),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value, {Widget? customWidget}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF37474F),
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child:
                customWidget ??
                Text(
                  value ?? 'Not provided',
                  style: TextStyle(
                    color:
                        value != null ? const Color(0xFF263238) : Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    Color backgroundColor;
    Color textColor;

    switch (status?.toLowerCase()) {
      case 'pending':
        backgroundColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFE65100);
        break;
      case 'active':
        backgroundColor = const Color(0xFFE8F5E8);
        textColor = const Color(0xFF2E7D32);
        break;
      case 'inactive':
        backgroundColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        break;
      default:
        backgroundColor = const Color(0xFFF5F5F5);
        textColor = const Color(0xFF757575);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: textColor.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        status ?? 'Unknown',
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

// Helper function to show the hierarchy dialog
void showUserHierarchyDialog(
  BuildContext context,
  String userId,
  String userName,
) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder:
        (context) => UserHierarchyDialog(userId: userId, userName: userName),
  );
}
