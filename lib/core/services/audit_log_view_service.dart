import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/audit_log_model.dart';

class AuditLogViewService {
  static final AuditLogViewService _instance = AuditLogViewService._internal();
  factory AuditLogViewService() => _instance;
  AuditLogViewService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get audit logs with filtering and pagination
  Future<List<AuditLogModel>> getAuditLogs({
    String? action,
    String? targetType,
    String? status,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      print('[AUDIT LOG SERVICE] Starting getAuditLogs');
      // Check if the audit_logs collection exists
      final collectionRef = _firestore.collection('audit_logs');
      print('[AUDIT LOG SERVICE] Before collectionRef.limit(1).get()');
      final collectionSnapshot = await collectionRef.limit(1).get();
      print('[AUDIT LOG SERVICE] After collectionRef.limit(1).get()');

      // If collection doesn't exist or is empty, return empty list
      if (collectionSnapshot.docs.isEmpty) {
        print(
          '📋 [AUDIT LOG SERVICE] No audit logs collection found or collection is empty',
        );
        return [];
      }

      Query query = collectionRef;

      // Apply filters
      if (action != null && action.isNotEmpty) {
        query = query.where('action', isEqualTo: action);
      }

      if (targetType != null && targetType.isNotEmpty) {
        query = query.where('targetType', isEqualTo: targetType);
      }

      if (status != null && status.isNotEmpty) {
        query = query.where('status', isEqualTo: status);
      }

      if (userId != null && userId.isNotEmpty) {
        query = query.where('userId', isEqualTo: userId);
      }

      if (startDate != null) {
        query = query.where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'timestamp',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      // Order by timestamp (most recent first)
      query = query.orderBy('timestamp', descending: true);

      // Apply pagination
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      query = query.limit(limit);

      print('[AUDIT LOG SERVICE] Before query.get()');
      final snapshot = await query.get();
      print('[AUDIT LOG SERVICE] After query.get()');
      return snapshot.docs
          .map(
            (doc) => AuditLogModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      print('❌ [AUDIT LOG SERVICE] Error fetching audit logs: $e');
      // Return empty list instead of throwing error
      return [];
    }
  }

  /// Get audit log statistics
  Future<Map<String, dynamic>> getAuditLogStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      print('[AUDIT LOG SERVICE] Starting getAuditLogStats');
      // Check if the audit_logs collection exists
      final collectionRef = _firestore.collection('audit_logs');
      print('[AUDIT LOG SERVICE] Before collectionRef.limit(1).get()');
      final collectionSnapshot = await collectionRef.limit(1).get();
      print('[AUDIT LOG SERVICE] After collectionRef.limit(1).get()');

      // If collection doesn't exist or is empty, return empty stats
      if (collectionSnapshot.docs.isEmpty) {
        print(
          '📋 [AUDIT LOG SERVICE] No audit logs collection found for stats',
        );
        return {
          'totalLogs': 0,
          'byStatus': {},
          'byAction': {},
          'byTargetType': {},
          'byUser': {},
          'recentActivity': 0,
        };
      }

      Query query = collectionRef;

      if (startDate != null) {
        query = query.where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'timestamp',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      print('[AUDIT LOG SERVICE] Before query.get()');
      final snapshot = await query.get();
      print('[AUDIT LOG SERVICE] After query.get()');
      final logs =
          snapshot.docs
              .map(
                (doc) => AuditLogModel.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();

      // Calculate statistics
      final stats = <String, dynamic>{};

      // Total logs
      stats['totalLogs'] = logs.length;

      // By status
      final statusCounts = <String, int>{};
      for (final log in logs) {
        statusCounts[log.status] = (statusCounts[log.status] ?? 0) + 1;
      }
      stats['byStatus'] = statusCounts;

      // By action
      final actionCounts = <String, int>{};
      for (final log in logs) {
        actionCounts[log.action] = (actionCounts[log.action] ?? 0) + 1;
      }
      stats['byAction'] = actionCounts;

      // By target type
      final targetTypeCounts = <String, int>{};
      for (final log in logs) {
        targetTypeCounts[log.targetType] =
            (targetTypeCounts[log.targetType] ?? 0) + 1;
      }
      stats['byTargetType'] = targetTypeCounts;

      // By user
      final userCounts = <String, int>{};
      for (final log in logs) {
        userCounts[log.userName] = (userCounts[log.userName] ?? 0) + 1;
      }
      stats['byUser'] = userCounts;

      // Recent activity (last 24 hours)
      final last24Hours = DateTime.now().subtract(const Duration(hours: 24));
      final recentLogs =
          logs.where((log) => log.timestamp.isAfter(last24Hours)).length;
      stats['recentActivity'] = recentLogs;

      return stats;
    } catch (e) {
      print('❌ [AUDIT LOG SERVICE] Error fetching audit log statistics: $e');
      // Return empty stats instead of throwing error
      return {
        'totalLogs': 0,
        'byStatus': {},
        'byAction': {},
        'byTargetType': {},
        'byUser': {},
        'recentActivity': 0,
      };
    }
  }

  /// Get available filter options
  Future<Map<String, List<String>>> getFilterOptions() async {
    try {
      print('[AUDIT LOG SERVICE] Starting getFilterOptions');
      // Check if the audit_logs collection exists
      final collectionRef = _firestore.collection('audit_logs');
      print('[AUDIT LOG SERVICE] Before collectionRef.limit(1).get()');
      final collectionSnapshot = await collectionRef.limit(1).get();
      print('[AUDIT LOG SERVICE] After collectionRef.limit(1).get()');

      // If collection doesn't exist or is empty, return empty options
      if (collectionSnapshot.docs.isEmpty) {
        print(
          '📋 [AUDIT LOG SERVICE] No audit logs collection found for filter options',
        );
        return {'actions': [], 'targetTypes': [], 'statuses': [], 'users': []};
      }

      print('[AUDIT LOG SERVICE] Before collectionRef.get()');
      final snapshot = await collectionRef.get();
      print('[AUDIT LOG SERVICE] After collectionRef.get()');
      final logs =
          snapshot.docs
              .map((doc) => AuditLogModel.fromFirestore(doc.data(), doc.id))
              .toList();

      final actions = <String>{};
      final targetTypes = <String>{};
      final statuses = <String>{};
      final users = <String>{};

      for (final log in logs) {
        actions.add(log.action);
        targetTypes.add(log.targetType);
        statuses.add(log.status);
        users.add(log.userName);
      }

      return {
        'actions': actions.toList()..sort(),
        'targetTypes': targetTypes.toList()..sort(),
        'statuses': statuses.toList()..sort(),
        'users': users.toList()..sort(),
      };
    } catch (e) {
      print('❌ [AUDIT LOG SERVICE] Error fetching filter options: $e');
      // Return empty options instead of throwing error
      return {'actions': [], 'targetTypes': [], 'statuses': [], 'users': []};
    }
  }

  /// Export audit logs
  Future<List<Map<String, dynamic>>> exportAuditLogs({
    String? action,
    String? targetType,
    String? status,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final logs = await getAuditLogs(
        action: action,
        targetType: targetType,
        status: status,
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        limit: 10000, // Large limit for export
      );

      return logs
          .map(
            (log) => {
              'ID': log.id,
              'Action': log.actionDisplayName,
              'User': log.userName,
              'User Email': log.userEmail,
              'Timestamp': log.formattedTimestamp,
              'Status': log.statusDisplayName,
              'Target Type': log.targetTypeDisplayName,
              'Target ID': log.targetId,
              'Details': log.details.toString(),
              'IP Address': log.ipAddress ?? 'N/A',
              'User Agent': log.userAgent ?? 'N/A',
              'Session ID': log.sessionId ?? 'N/A',
            },
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to export audit logs: $e');
    }
  }
}
