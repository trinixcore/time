import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/providers/performance_providers.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../core/services/auth_service.dart';

// Optimized provider for total employees count with refresh triggers
final totalEmployeesProvider = FutureProvider<int>((ref) async {
  // Watch for refresh triggers
  ref.watch(globalRefreshProvider.select((state) => state['users'] ?? 0));

  try {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('isActive', isEqualTo: true)
            .get();

    return snapshot.docs.length;
  } catch (e) {
    rethrow;
  }
});

// Provider for user's active tasks count (created by or assigned to current user)
final userActiveTasksProvider = FutureProvider<int>((ref) async {
  // Watch for refresh triggers
  ref.watch(globalRefreshProvider.select((state) => state['tasks'] ?? 0));

  try {
    // Get current user
    final currentUser = ref.read(currentUserProvider);
    final user = currentUser.value;

    if (user == null) {
      return 0;
    }

    // Get tasks where current user is creator or assignee, and status is not completed
    // Using the correct TaskStatus enum values
    final snapshot =
        await FirebaseFirestore.instance
            .collection('tasks')
            .where(
              'status',
              whereIn: [
                'todo',
                'in_progress',
                'review',
                'testing',
                'on_hold',
                'blocked',
              ],
            )
            .get();

    // Filter tasks for current user
    final userTasks =
        snapshot.docs.where((doc) {
          final data = doc.data();
          final createdBy = data['createdBy'] as String?;
          final assignedTo =
              data['assignedTo'] as String?; // Use assignedTo (singular)

          return createdBy == user.uid || assignedTo == user.uid;
        }).length;

    return userTasks;
  } catch (e) {
    rethrow;
  }
});

// Provider for pending profile approvals (global count)
final pendingProfileApprovalsProvider = FutureProvider<int>((ref) async {
  // Watch for refresh triggers
  ref.watch(globalRefreshProvider.select((state) => state['approvals'] ?? 0));

  try {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('profile_approval_requests')
            .where('status', isEqualTo: 'pending')
            .get();

    return snapshot.docs.length;
  } catch (e) {
    rethrow;
  }
});

// Optimized provider for pending leaves with refresh triggers
final pendingLeavesProvider = FutureProvider<int>((ref) async {
  // Watch for refresh triggers
  ref.watch(globalRefreshProvider.select((state) => state['leaves'] ?? 0));

  try {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('leaves')
            .where('status', isEqualTo: 'pending')
            .get();

    return snapshot.docs.length;
  } catch (e) {
    rethrow;
  }
});

// Optimized provider for documents count with refresh triggers
final documentsCountProvider = FutureProvider<int>((ref) async {
  // Watch for refresh triggers
  ref.watch(globalRefreshProvider.select((state) => state['documents'] ?? 0));

  try {
    final snapshot =
        await FirebaseFirestore.instance.collection('documents').get();

    return snapshot.docs.length;
  } catch (e) {
    rethrow;
  }
});

// Optimized provider for recent activity with refresh triggers
final recentActivityProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  // Watch for refresh triggers
  ref.watch(globalRefreshProvider.select((state) => state['activity'] ?? 0));

  try {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('activity_logs')
            .orderBy('timestamp', descending: true)
            .limit(10)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  } catch (e) {
    rethrow;
  }
});

final onlineUserCountProvider = FutureProvider<int>((ref) async {
  try {
    // Cleanup stale users first
    await AuthService().cleanupStaleUsers();

    // Count only users active in the last 2 minutes
    final twoMinutesAgo = DateTime.now().subtract(const Duration(minutes: 2));
    final snapshot =
        await FirebaseFirestore.instance
            .collection('user_status')
            .where('status', isEqualTo: 'online')
            .where('lastSeen', isGreaterThan: Timestamp.fromDate(twoMinutesAgo))
            .get();

    // Filter out docs where lastSeen is not a Timestamp (to avoid query errors)
    final validDocs =
        snapshot.docs.where((doc) {
          final lastSeen = doc['lastSeen'];
          return lastSeen is Timestamp;
        }).toList();

    print(
      '[DEBUG] onlineUserCountProvider: validDocs.length = ${validDocs.length}',
    );
    return validDocs.length;
  } catch (e, stack) {
    print('[ERROR] onlineUserCountProvider: ${e.toString()}');
    print(stack);
    rethrow;
  }
});

final currentUserStatusProvider = FutureProvider<Map<String, dynamic>?>((
  ref,
) async {
  final currentUser = ref.read(currentUserProvider);
  final user = currentUser.maybeWhen(data: (u) => u, orElse: () => null);
  if (user == null) return null;
  final doc =
      await FirebaseFirestore.instance
          .collection('user_status')
          .doc(user.uid)
          .get();
  return doc.exists ? doc.data() : null;
});

// Provider to periodically cleanup stale users
final cleanupStaleUsersProvider = FutureProvider<void>((ref) async {
  await AuthService().cleanupStaleUsers();
});
