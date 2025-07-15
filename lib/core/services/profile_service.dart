import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/profile_update_request.dart';
import '../models/user.dart';
import '../constants/firestore_paths.dart';
import 'audit_log_service.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Submit a profile update request
  Future<String> submitProfileUpdateRequest({
    required String userId,
    required Map<String, dynamic> currentData,
    required Map<String, dynamic> proposedChanges,
    required String hiringManagerId,
  }) async {
    try {
      // Get current user data
      final userDoc =
          await _firestore.collection(FirestorePaths.users).doc(userId).get();

      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final userData = userDoc.data()!;

      // Identify changed fields
      final changedFields = <String>[];
      for (final key in proposedChanges.keys) {
        if (currentData[key] != proposedChanges[key]) {
          changedFields.add(key);
        }
      }

      if (changedFields.isEmpty) {
        throw Exception('No changes detected');
      }

      // Create update request
      final requestId =
          _firestore.collection(FirestorePaths.profileUpdateRequests).doc().id;

      final request = ProfileUpdateRequest(
        id: requestId,
        userId: userId,
        userEmployeeId: userData['employeeId'] ?? '',
        userName: userData['displayName'] ?? '',
        userEmail: userData['email'] ?? '',
        currentData: Map<String, dynamic>.from(currentData),
        proposedChanges: Map<String, dynamic>.from(proposedChanges),
        changedFields: changedFields,
        status: ProfileUpdateStatus.pending,
        requestedAt: DateTime.now(),
        requestedBy: userId,
      );

      // Save to Firestore
      await _firestore
          .collection(FirestorePaths.profileUpdateRequests)
          .doc(requestId)
          .set(request.toFirestore());

      // Audit log for profile update request submission
      await AuditLogService().logEvent(
        action: 'PROFILE_UPDATE_REQUEST_SUBMIT',
        userId: userId,
        userName: userData['displayName'] ?? userData['email'] ?? 'Unknown',
        userEmail: userData['email'],
        status: 'success',
        targetType: 'profile_update_request',
        targetId: requestId,
        details: {
          'changedFields': changedFields,
          'proposedChanges': proposedChanges,
          'hiringManagerId': hiringManagerId,
          'requestStatus': ProfileUpdateStatus.pending.value,
        },
      );

      return requestId;
    } catch (e) {
      // Audit log for failed profile update request submission
      await AuditLogService().logEvent(
        action: 'PROFILE_UPDATE_REQUEST_SUBMIT',
        userId: userId,
        userName: 'Unknown',
        userEmail: 'Unknown',
        status: 'failed',
        targetType: 'profile_update_request',
        targetId: '',
        details: {
          'error': e.toString(),
          'proposedChanges': proposedChanges,
          'hiringManagerId': hiringManagerId,
        },
      );
      throw Exception('Failed to submit profile update request: $e');
    }
  }

  /// Get profile update requests for a user
  Stream<List<ProfileUpdateRequest>> getUserProfileUpdateRequests(
    String userId,
  ) {
    return _firestore
        .collection(FirestorePaths.profileUpdateRequests)
        .where('userId', isEqualTo: userId)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ProfileUpdateRequest.fromFirestore(doc.data()))
                  .toList(),
        );
  }

  /// Get pending profile update requests for approval (for managers)
  Stream<List<ProfileUpdateRequest>> getPendingProfileUpdateRequests(
    String managerId,
  ) {
    return _firestore
        .collection(FirestorePaths.profileUpdateRequests)
        .where('status', isEqualTo: ProfileUpdateStatus.pending.value)
        .orderBy('requestedAt', descending: false)
        .snapshots()
        .asyncMap((snapshot) async {
          final requests = <ProfileUpdateRequest>[];

          for (final doc in snapshot.docs) {
            final request = ProfileUpdateRequest.fromFirestore(doc.data());

            // Check if current user is the hiring manager for this request
            final userDoc =
                await _firestore
                    .collection(FirestorePaths.users)
                    .doc(request.userId)
                    .get();

            if (userDoc.exists) {
              final userData = userDoc.data()!;
              final hiringManagerId = userData['hiringManagerId'] as String?;

              if (hiringManagerId == managerId) {
                requests.add(request);
              }
            }
          }

          return requests;
        });
  }

  /// Approve a profile update request
  Future<void> approveProfileUpdateRequest({
    required String requestId,
    required String approverId,
    required String approverName,
    String? comments,
  }) async {
    try {
      final requestDoc =
          await _firestore
              .collection(FirestorePaths.profileUpdateRequests)
              .doc(requestId)
              .get();

      if (!requestDoc.exists) {
        throw Exception('Profile update request not found');
      }

      final request = ProfileUpdateRequest.fromFirestore(requestDoc.data()!);

      if (!request.canBeApproved) {
        throw Exception(
          'Request cannot be approved in current status: ${request.status.displayName}',
        );
      }

      // Update the request status
      final approvedRequest = request.approve(
        approverId: approverId,
        approverName: approverName,
        comments: comments,
      );

      // Update request in Firestore
      await _firestore
          .collection(FirestorePaths.profileUpdateRequests)
          .doc(requestId)
          .update(approvedRequest.toFirestore());

      // Apply changes to user profile
      await _firestore
          .collection(FirestorePaths.users)
          .doc(request.userId)
          .update(request.proposedChanges);

      // Audit log for profile update request approval
      await AuditLogService().logEvent(
        action: 'PROFILE_UPDATE_REQUEST_APPROVE',
        userId: approverId,
        userName: approverName,
        userEmail: 'Unknown',
        status: 'success',
        targetType: 'profile_update_request',
        targetId: requestId,
        details: {
          'requestUserId': request.userId,
          'requestUserName': request.userName,
          'requestUserEmail': request.userEmail,
          'changedFields': request.changedFields,
          'proposedChanges': request.proposedChanges,
          'approverComments': comments,
          'requestStatus': ProfileUpdateStatus.approved.value,
        },
      );
    } catch (e) {
      // Audit log for failed profile update request approval
      await AuditLogService().logEvent(
        action: 'PROFILE_UPDATE_REQUEST_APPROVE',
        userId: approverId,
        userName: approverName,
        userEmail: 'Unknown',
        status: 'failed',
        targetType: 'profile_update_request',
        targetId: requestId,
        details: {'error': e.toString(), 'approverComments': comments},
      );
      throw Exception('Failed to approve profile update request: $e');
    }
  }

  /// Reject a profile update request
  Future<void> rejectProfileUpdateRequest({
    required String requestId,
    required String approverId,
    required String approverName,
    required String reason,
    String? comments,
  }) async {
    try {
      final requestDoc =
          await _firestore
              .collection(FirestorePaths.profileUpdateRequests)
              .doc(requestId)
              .get();

      if (!requestDoc.exists) {
        throw Exception('Profile update request not found');
      }

      final request = ProfileUpdateRequest.fromFirestore(requestDoc.data()!);

      if (!request.canBeRejected) {
        throw Exception(
          'Request cannot be rejected in current status: ${request.status.displayName}',
        );
      }

      // Update the request status
      final rejectedRequest = request.reject(
        approverId: approverId,
        approverName: approverName,
        reason: reason,
        comments: comments,
      );

      // Update request in Firestore
      await _firestore
          .collection(FirestorePaths.profileUpdateRequests)
          .doc(requestId)
          .update(rejectedRequest.toFirestore());

      // Audit log for profile update request rejection
      await AuditLogService().logEvent(
        action: 'PROFILE_UPDATE_REQUEST_REJECT',
        userId: approverId,
        userName: approverName,
        userEmail: 'Unknown',
        status: 'success',
        targetType: 'profile_update_request',
        targetId: requestId,
        details: {
          'requestUserId': request.userId,
          'requestUserName': request.userName,
          'requestUserEmail': request.userEmail,
          'changedFields': request.changedFields,
          'proposedChanges': request.proposedChanges,
          'rejectionReason': reason,
          'approverComments': comments,
          'requestStatus': ProfileUpdateStatus.rejected.value,
        },
      );
    } catch (e) {
      // Audit log for failed profile update request rejection
      await AuditLogService().logEvent(
        action: 'PROFILE_UPDATE_REQUEST_REJECT',
        userId: approverId,
        userName: approverName,
        userEmail: 'Unknown',
        status: 'failed',
        targetType: 'profile_update_request',
        targetId: requestId,
        details: {
          'error': e.toString(),
          'rejectionReason': reason,
          'approverComments': comments,
        },
      );
      throw Exception('Failed to reject profile update request: $e');
    }
  }

  /// Cancel a profile update request (by the user who created it)
  Future<void> cancelProfileUpdateRequest(
    String requestId,
    String userId,
  ) async {
    try {
      final requestDoc =
          await _firestore
              .collection(FirestorePaths.profileUpdateRequests)
              .doc(requestId)
              .get();

      if (!requestDoc.exists) {
        throw Exception('Profile update request not found');
      }

      final request = ProfileUpdateRequest.fromFirestore(requestDoc.data()!);

      // Verify the user owns this request
      if (request.userId != userId) {
        throw Exception('You can only cancel your own requests');
      }

      if (!request.canBeCancelled) {
        throw Exception(
          'Request cannot be cancelled in current status: ${request.status.displayName}',
        );
      }

      // Update the request status
      final cancelledRequest = request.cancel();

      // Update request in Firestore
      await _firestore
          .collection(FirestorePaths.profileUpdateRequests)
          .doc(requestId)
          .update(cancelledRequest.toFirestore());

      // Audit log for profile update request cancellation
      await AuditLogService().logEvent(
        action: 'PROFILE_UPDATE_REQUEST_CANCEL',
        userId: userId,
        userName: request.userName,
        userEmail: request.userEmail,
        status: 'success',
        targetType: 'profile_update_request',
        targetId: requestId,
        details: {
          'changedFields': request.changedFields,
          'proposedChanges': request.proposedChanges,
          'requestStatus': ProfileUpdateStatus.cancelled.value,
        },
      );
    } catch (e) {
      // Audit log for failed profile update request cancellation
      await AuditLogService().logEvent(
        action: 'PROFILE_UPDATE_REQUEST_CANCEL',
        userId: userId,
        userName: 'Unknown',
        userEmail: 'Unknown',
        status: 'failed',
        targetType: 'profile_update_request',
        targetId: requestId,
        details: {'error': e.toString()},
      );
      throw Exception('Failed to cancel profile update request: $e');
    }
  }

  /// Get current user profile data
  Future<Map<String, dynamic>> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user');
    }

    final userDoc =
        await _firestore.collection(FirestorePaths.users).doc(user.uid).get();

    if (!userDoc.exists) {
      throw Exception('User profile not found');
    }

    return userDoc.data()!;
  }

  /// Check if user has pending profile update requests
  Future<bool> hasPendingProfileUpdateRequests(String userId) async {
    final snapshot =
        await _firestore
            .collection(FirestorePaths.profileUpdateRequests)
            .where('userId', isEqualTo: userId)
            .where('status', isEqualTo: ProfileUpdateStatus.pending.value)
            .limit(1)
            .get();

    return snapshot.docs.isNotEmpty;
  }

  /// Get profile update request by ID
  Future<ProfileUpdateRequest?> getProfileUpdateRequest(
    String requestId,
  ) async {
    final doc =
        await _firestore
            .collection(FirestorePaths.profileUpdateRequests)
            .doc(requestId)
            .get();

    if (!doc.exists) {
      return null;
    }

    return ProfileUpdateRequest.fromFirestore(doc.data()!);
  }

  /// Get user's hiring manager information
  Future<Map<String, dynamic>?> getUserHiringManager(String userId) async {
    final userDoc =
        await _firestore.collection(FirestorePaths.users).doc(userId).get();

    if (!userDoc.exists) {
      return null;
    }

    final userData = userDoc.data()!;
    final hiringManagerId = userData['hiringManagerId'] as String?;

    if (hiringManagerId == null) {
      return null;
    }

    final managerDoc =
        await _firestore
            .collection(FirestorePaths.users)
            .doc(hiringManagerId)
            .get();

    if (!managerDoc.exists) {
      return null;
    }

    final managerData = managerDoc.data()!;
    return {
      'id': hiringManagerId,
      'name': managerData['displayName'] ?? '',
      'email': managerData['email'] ?? '',
      'employeeId': managerData['employeeId'] ?? '',
    };
  }
}
