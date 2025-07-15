import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuditLogService {
  static final AuditLogService _instance = AuditLogService._internal();
  factory AuditLogService() => _instance;
  AuditLogService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Log an audit event with a unified structure
  Future<void> logEvent({
    required String
    action, // e.g. 'LOGIN', 'UPDATE_PROFILE', 'DELETE_USER', etc.
    String? userId,
    String? userName,
    String? userEmail,
    String? userRole,
    String? targetType, // e.g. 'user', 'document', 'task', etc.
    String? targetId,
    Map<String, dynamic>? details, // Additional details (before/after, etc.)
    String? ipAddress,
    String? device,
    String? location,
    String? sessionId,
    String status = 'success', // 'success', 'failure', 'denied', etc.
    String? errorMessage,
    DateTime? timestamp,
  }) async {
    try {
      final now = timestamp ?? DateTime.now();
      final currentUser = _auth.currentUser;
      final log = <String, dynamic>{
        'action': action,
        'timestamp': now.toIso8601String(),
        'userId': userId ?? currentUser?.uid,
        'userName': userName ?? currentUser?.displayName,
        'userEmail': userEmail ?? currentUser?.email,
        'userRole': userRole,
        'targetType': targetType,
        'targetId': targetId,
        'details': details,
        'ipAddress': ipAddress,
        'device': device,
        'location': location,
        'sessionId': sessionId,
        'status': status,
        'errorMessage': errorMessage,
        'createdAt': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('audit_logs').add(log);
    } catch (e) {
      print('[AuditLogService] Failed to log event: $e');
      // Do not throw; logging failure should not break main flow
    }
  }
}
