import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/models/profile_update_request.dart';
import '../../../shared/widgets/common_widgets.dart';

class ProfileApprovalPage extends StatefulWidget {
  const ProfileApprovalPage({super.key});

  @override
  State<ProfileApprovalPage> createState() => _ProfileApprovalPageState();
}

class _ProfileApprovalPageState extends State<ProfileApprovalPage> {
  final ProfileService _profileService = ProfileService();
  List<ProfileUpdateRequest> _pendingRequests = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPendingRequests();
  }

  Future<void> _loadPendingRequests() async {
    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        _profileService.getPendingProfileUpdateRequests(currentUser.uid).listen(
          (requests) {
            setState(() {
              _pendingRequests = requests;
            });
          },
        );
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load pending requests: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approveRequest(
    ProfileUpdateRequest request,
    String? comments,
  ) async {
    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser!;
      final userData = await _profileService.getCurrentUserProfile();

      await _profileService.approveProfileUpdateRequest(
        requestId: request.id,
        approverId: currentUser.uid,
        approverName: userData['displayName'] ?? 'Manager',
        comments: comments,
      );

      _showSuccessSnackBar('Profile update request approved successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to approve request: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _rejectRequest(
    ProfileUpdateRequest request,
    String reason,
    String? comments,
  ) async {
    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser!;
      final userData = await _profileService.getCurrentUserProfile();

      await _profileService.rejectProfileUpdateRequest(
        requestId: request.id,
        approverId: currentUser.uid,
        approverName: userData['displayName'] ?? 'Manager',
        reason: reason,
        comments: comments,
      );

      _showSuccessSnackBar('Profile update request rejected');
    } catch (e) {
      _showErrorSnackBar('Failed to reject request: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showApprovalDialog(ProfileUpdateRequest request) {
    final commentsController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Approve Profile Update'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Employee: ${request.userName}'),
                const SizedBox(height: 8),
                Text('Employee ID: ${request.userEmployeeId}'),
                const SizedBox(height: 16),
                const Text(
                  'Changes:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...request.getAllChangeDescriptions().map(
                  (change) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $change'),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commentsController,
                  decoration: const InputDecoration(
                    labelText: 'Comments (Optional)',
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
                  Navigator.of(context).pop();
                  _approveRequest(
                    request,
                    commentsController.text.trim().isEmpty
                        ? null
                        : commentsController.text.trim(),
                  );
                },
                child: const Text('Approve'),
              ),
            ],
          ),
    );
  }

  void _showRejectionDialog(ProfileUpdateRequest request) {
    final reasonController = TextEditingController();
    final commentsController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reject Profile Update'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Employee: ${request.userName}'),
                const SizedBox(height: 8),
                Text('Employee ID: ${request.userEmployeeId}'),
                const SizedBox(height: 16),
                const Text(
                  'Changes:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...request.getAllChangeDescriptions().map(
                  (change) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $change'),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Rejection Reason *',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commentsController,
                  decoration: const InputDecoration(
                    labelText: 'Additional Comments (Optional)',
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
                  if (reasonController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Rejection reason is required'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  Navigator.of(context).pop();
                  _rejectRequest(
                    request,
                    reasonController.text.trim(),
                    commentsController.text.trim().isEmpty
                        ? null
                        : commentsController.text.trim(),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Reject'),
              ),
            ],
          ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Approval Worklist'),
        actions: [
          IconButton(
            onPressed: _loadPendingRequests,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body:
          _isLoading
              ? const LoadingIndicator(message: 'Loading requests...')
              : _pendingRequests.isEmpty
              ? const EmptyStateWidget(
                title: 'No Pending Requests',
                subtitle: 'All profile update requests have been processed.',
                icon: Icons.check_circle_outline,
              )
              : RefreshIndicator(
                onRefresh: _loadPendingRequests,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pendingRequests.length,
                  itemBuilder: (context, index) {
                    final request = _pendingRequests[index];
                    return _buildRequestCard(request);
                  },
                ),
              ),
    );
  }

  Widget _buildRequestCard(ProfileUpdateRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.1),
                  child: Text(
                    request.userName.isNotEmpty
                        ? request.userName[0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.userName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'ID: ${request.userEmployeeId}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        request.userEmail,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
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
                    color:
                        request.isOverdue
                            ? Colors.red[100]
                            : Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${request.daysSinceRequest} days ago',
                    style: TextStyle(
                      color:
                          request.isOverdue
                              ? Colors.red[800]
                              : Colors.orange[800],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                        'Requested Changes:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...request.getAllChangeDescriptions().map(
                    (change) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: TextStyle(color: Colors.blue[700])),
                          Expanded(
                            child: Text(
                              change,
                              style: TextStyle(color: Colors.blue[700]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRejectionDialog(request),
                    icon: const Icon(Icons.close, color: Colors.red),
                    label: const Text(
                      'Reject',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showApprovalDialog(request),
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
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
}
