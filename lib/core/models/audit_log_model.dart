import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuditLogModel {
  final String id;
  final String action;
  final String userId;
  final String userName;
  final String userEmail;
  final DateTime timestamp;
  final String status;
  final String targetType;
  final String targetId;
  final Map<String, dynamic> details;
  final String? ipAddress;
  final String? userAgent;
  final String? sessionId;
  final String? location;

  AuditLogModel({
    required this.id,
    required this.action,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.timestamp,
    required this.status,
    required this.targetType,
    required this.targetId,
    required this.details,
    this.ipAddress,
    this.userAgent,
    this.sessionId,
    this.location,
  });

  factory AuditLogModel.fromFirestore(Map<String, dynamic> data, String id) {
    DateTime parsedTimestamp;
    final rawTimestamp = data['timestamp'];
    if (rawTimestamp is Timestamp) {
      parsedTimestamp = rawTimestamp.toDate();
    } else if (rawTimestamp is String) {
      parsedTimestamp = DateTime.tryParse(rawTimestamp) ?? DateTime.now();
    } else {
      parsedTimestamp = DateTime.now();
    }

    return AuditLogModel(
      id: id,
      action: data['action'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      timestamp: parsedTimestamp,
      status: data['status'] ?? '',
      targetType: data['targetType'] ?? '',
      targetId: data['targetId'] ?? '',
      details: Map<String, dynamic>.from(data['details'] ?? {}),
      ipAddress: data['ipAddress'],
      userAgent: data['userAgent'],
      sessionId: data['sessionId'],
      location: data['location'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'action': action,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status,
      'targetType': targetType,
      'targetId': targetId,
      'details': details,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'sessionId': sessionId,
      'location': location,
    };
  }

  // Helper methods for UI display
  String get actionDisplayName {
    switch (action) {
      case 'LOGIN':
        return 'User Login';
      case 'LOGOUT':
        return 'User Logout';
      case 'PASSWORD_CHANGE':
        return 'Password Change';
      case 'ACCOUNT_CREATE':
        return 'Account Creation';
      case 'ACCOUNT_DELETE':
        return 'Account Deletion';
      case 'PROFILE_UPDATE':
        return 'Profile Update';
      case 'USER_CREATE':
        return 'User Creation';
      case 'USER_UPDATE':
        return 'User Update';
      case 'USER_DELETE':
        return 'User Deletion';
      case 'USER_TERMINATE':
        return 'User Termination';
      case 'USER_REACTIVATE':
        return 'User Reactivation';
      case 'PERMISSION_UPDATE':
        return 'Permission Update';
      case 'ROLE_ASSIGN':
        return 'Role Assignment';
      case 'DOCUMENT_UPLOAD':
        return 'Document Upload';
      case 'DOCUMENT_DOWNLOAD':
        return 'Document Download';
      case 'DOCUMENT_DELETE':
        return 'Document Deletion';
      case 'DOCUMENT_APPROVE':
        return 'Document Approval';
      case 'DOCUMENT_REJECT':
        return 'Document Rejection';
      case 'DOCUMENT_ACCESS':
        return 'Document Access';
      case 'EMPLOYEE_CREATE':
        return 'Employee Creation';
      case 'EMPLOYEE_UPDATE':
        return 'Employee Update';
      case 'EMPLOYEE_STATUS_CHANGE':
        return 'Employee Status Change';
      case 'EMPLOYEE_DELETE':
        return 'Employee Deletion';
      case 'BULK_EMPLOYEE_UPDATE':
        return 'Bulk Employee Update';
      case 'TASK_CREATE':
        return 'Task Creation';
      case 'TASK_STATUS_UPDATE':
        return 'Task Status Update';
      case 'TASK_ASSIGNMENT_UPDATE':
        return 'Task Assignment Update';
      case 'TASK_TIME_LOG':
        return 'Task Time Log';
      case 'TASK_PROGRESS_UPDATE':
        return 'Task Progress Update';
      case 'TASK_COMMENT_ADD':
        return 'Task Comment Addition';
      case 'TASK_DELETE':
        return 'Task Deletion';
      case 'TASK_DOCUMENT_UPLOAD':
        return 'Task Document Upload';
      case 'PROFILE_UPDATE_REQUEST_SUBMIT':
        return 'Profile Update Request Submission';
      case 'PROFILE_UPDATE_REQUEST_APPROVE':
        return 'Profile Update Request Approval';
      case 'PROFILE_UPDATE_REQUEST_REJECT':
        return 'Profile Update Request Rejection';
      case 'PROFILE_UPDATE_REQUEST_CANCEL':
        return 'Profile Update Request Cancellation';
      case 'HIERARCHY_REPORTING_RELATIONSHIP_UPDATE':
        return 'Hierarchy Relationship Update';
      default:
        // Handle empty or null action
        if (action.isEmpty) {
          return 'Unknown Action';
        }
        return action
            .replaceAll('_', ' ')
            .toLowerCase()
            .split(' ')
            .where((word) => word.isNotEmpty) // Filter out empty words
            .map(
              (word) =>
                  word.isNotEmpty
                      ? word[0].toUpperCase() + word.substring(1)
                      : '',
            )
            .where((word) => word.isNotEmpty) // Filter out empty results
            .join(' ');
    }
  }

  String get targetTypeDisplayName {
    switch (targetType) {
      case 'user':
        return 'User';
      case 'document':
        return 'Document';
      case 'task':
        return 'Task';
      case 'employee':
        return 'Employee';
      case 'profile_update_request':
        return 'Profile Update Request';
      case 'permission_config':
        return 'Permission Configuration';
      default:
        // Handle empty or null targetType
        if (targetType.isEmpty) {
          return 'Unknown Target';
        }
        return targetType
            .replaceAll('_', ' ')
            .toLowerCase()
            .split(' ')
            .where((word) => word.isNotEmpty) // Filter out empty words
            .map(
              (word) =>
                  word.isNotEmpty
                      ? word[0].toUpperCase() + word.substring(1)
                      : '',
            )
            .where((word) => word.isNotEmpty) // Filter out empty results
            .join(' ');
    }
  }

  String get statusDisplayName {
    switch (status) {
      case 'success':
        return 'Success';
      case 'failed':
        return 'Failed';
      default:
        return status.toUpperCase();
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

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

  String get formattedTimestamp {
    return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  Color get statusColor {
    switch (status) {
      case 'success':
        return Colors.green;
      case 'failed':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Color get actionColor {
    switch (action.split('_').first) {
      case 'LOGIN':
      case 'LOGOUT':
        return Colors.blue;
      case 'USER':
      case 'ACCOUNT':
        return Colors.purple;
      case 'DOCUMENT':
        return Colors.orange;
      case 'EMPLOYEE':
        return Colors.teal;
      case 'TASK':
        return Colors.indigo;
      case 'PROFILE':
        return Colors.pink;
      case 'HIERARCHY':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }
}
