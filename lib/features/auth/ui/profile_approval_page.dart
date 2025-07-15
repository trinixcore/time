import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../dashboard/ui/dashboard_scaffold.dart';

class ProfileApprovalPage extends StatefulWidget {
  const ProfileApprovalPage({super.key});

  @override
  State<ProfileApprovalPage> createState() => _ProfileApprovalPageState();
}

class _ProfileApprovalPageState extends State<ProfileApprovalPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _pendingRequests = [];

  @override
  void initState() {
    super.initState();
    _loadPendingRequests();
  }

  Future<void> _loadPendingRequests() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Get pending approval requests where current user is the approver
      // Removed orderBy to avoid composite index requirement
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('profile_approval_requests')
              .where('approverId', isEqualTo: user.uid)
              .where('status', isEqualTo: 'pending')
              .get();

      setState(() {
        _pendingRequests =
            querySnapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList();

        // Sort in memory by requestedAt timestamp (newest first)
        _pendingRequests.sort((a, b) {
          final aTime = a['requestedAt'];
          final bTime = b['requestedAt'];

          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;

          // Handle both Timestamp and String formats
          DateTime aDate;
          DateTime bDate;

          if (aTime is Timestamp) {
            aDate = aTime.toDate();
          } else if (aTime is String) {
            aDate = DateTime.parse(aTime);
          } else {
            return 0;
          }

          if (bTime is Timestamp) {
            bDate = bTime.toDate();
          } else if (bTime is String) {
            bDate = DateTime.parse(bTime);
          } else {
            return 0;
          }

          return bDate.compareTo(aDate); // Descending order (newest first)
        });

        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading requests: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _approveRequest(
    String requestId,
    Map<String, dynamic> requestData,
  ) async {
    try {
      // Update the user's profile with the requested changes
      await FirebaseFirestore.instance
          .collection('users')
          .doc(requestData['userId'])
          .update(requestData['requestedChanges']);

      // Update the approval request status
      await FirebaseFirestore.instance
          .collection('profile_approval_requests')
          .doc(requestId)
          .update({
            'status': 'approved',
            'approvedAt': FieldValue.serverTimestamp(),
            'approvedBy': FirebaseAuth.instance.currentUser?.uid,
          });

      // Remove from local list
      setState(() {
        _pendingRequests.removeWhere((request) => request['id'] == requestId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile update approved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error approving request: $e')));
      }
    }
  }

  Future<void> _rejectRequest(String requestId, String reason) async {
    try {
      // Update the approval request status
      await FirebaseFirestore.instance
          .collection('profile_approval_requests')
          .doc(requestId)
          .update({
            'status': 'rejected',
            'rejectedAt': FieldValue.serverTimestamp(),
            'rejectedBy': FirebaseAuth.instance.currentUser?.uid,
            'rejectionReason': reason,
          });

      // Remove from local list
      setState(() {
        _pendingRequests.removeWhere((request) => request['id'] == requestId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile update request rejected'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error rejecting request: $e')));
      }
    }
  }

  void _showApprovalDialog(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Approve Profile Update'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Employee: ${request['userName']}'),
                Text('Employee ID: ${request['employeeId']}'),
                Text('Department: ${request['department']}'),
                const SizedBox(height: 16),
                const Text(
                  'Requested Changes:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ..._buildChangesList(
                  request['requestedChanges'],
                  request['currentData'],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showRejectionDialog(request['id']);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Reject'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _approveRequest(request['id'], request);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Approve'),
              ),
            ],
          ),
    );
  }

  void _showRejectionDialog(String requestId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reject Profile Update'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Please provide a reason for rejection:'),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Rejection Reason',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (reasonController.text.trim().isNotEmpty) {
                    Navigator.of(context).pop();
                    _rejectRequest(requestId, reasonController.text.trim());
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reject'),
              ),
            ],
          ),
    );
  }

  List<Widget> _buildChangesList(
    Map<String, dynamic>? requested,
    Map<String, dynamic>? current,
  ) {
    if (requested == null || requested.isEmpty) {
      return [const Text('No changes detected')];
    }

    List<Widget> changes = [];

    requested.forEach((key, value) {
      if (key != 'updatedAt' && value != null && value.toString().isNotEmpty) {
        final currentValue = current?[key]?.toString() ?? 'Not set';
        final requestedValue = value.toString();

        if (currentValue != requestedValue) {
          changes.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatFieldName(key),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'From: $currentValue',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    'To: $requestedValue',
                    style: const TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
          );
        }
      }
    });

    return changes.isEmpty ? [const Text('No changes detected')] : changes;
  }

  String _formatFieldName(String fieldName) {
    switch (fieldName) {
      case 'firstName':
        return 'First Name';
      case 'lastName':
        return 'Last Name';
      case 'phone':
        return 'Phone Number';
      case 'emergencyContact':
        return 'Emergency Contact';
      case 'emergencyContactName':
        return 'Emergency Contact Name';
      case 'address':
        return 'Address';
      case 'gender':
        return 'Gender';
      case 'dateOfBirth':
        return 'Date of Birth';
      default:
        return fieldName;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Not set';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      currentPath: '/profile/approvals',
      child: _buildApprovalContent(),
    );
  }

  Widget _buildApprovalContent() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          _buildPageHeader(theme),
          const SizedBox(height: 32),

          // Content
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading approval requests...'),
                ],
              ),
            )
          else if (_pendingRequests.isEmpty)
            _buildEmptyState(theme)
          else
            _buildRequestsList(theme),
        ],
      ),
    );
  }

  Widget _buildPageHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Approvals',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Review and approve employee profile update requests',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimary.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.approval,
            size: 64,
            color: theme.colorScheme.onPrimary.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inbox,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'No Pending Requests',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'There are no profile update requests waiting for your approval.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestsList(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pending Requests (${_pendingRequests.length})',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...(_pendingRequests
            .map(
              (request) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildRequestCard(request),
              ),
            )
            .toList()),
      ],
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    // Safely handle requestedAt field
    DateTime requestedAt;
    try {
      final requestedAtValue = request['requestedAt'];
      if (requestedAtValue is Timestamp) {
        requestedAt = requestedAtValue.toDate();
      } else if (requestedAtValue is String) {
        requestedAt = DateTime.parse(requestedAtValue);
      } else {
        requestedAt = DateTime.now(); // Fallback
      }
    } catch (e) {
      requestedAt = DateTime.now(); // Fallback if parsing fails
    }

    final timeAgo = _getTimeAgo(requestedAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    request['userName']?.substring(0, 1) ?? 'U',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['userName'] ?? 'Unknown User',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ID: ${request['employeeId'] ?? 'N/A'} • ${request['department'] ?? 'N/A'}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'PENDING',
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.edit, size: 16, color: Colors.blue[700]),
                      const SizedBox(width: 4),
                      Text(
                        'Requested Changes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._buildChangesList(
                        request['requestedChanges'] ?? {},
                        request['currentData'] ?? {},
                      )
                      .take(3)
                      .map(
                        (widget) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '• ',
                                style: TextStyle(color: Colors.blue[700]),
                              ),
                              Expanded(child: widget),
                            ],
                          ),
                        ),
                      ),
                  if (_buildChangesList(
                        request['requestedChanges'] ?? {},
                        request['currentData'] ?? {},
                      ).length >
                      3)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        '... and ${_buildChangesList(request['requestedChanges'] ?? {}, request['currentData'] ?? {}).length - 3} more changes',
                        style: TextStyle(color: Colors.blue[700]),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Requested $timeAgo',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _showRejectionDialog(request['id']),
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: const Text('Reject'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showApprovalDialog(request),
                      icon: const Icon(Icons.check),
                      label: const Text('Review'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
