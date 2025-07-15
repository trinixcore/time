import 'dart:convert';
import 'dart:html' as html;
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';

class ExportService {
  static const String _dateFormat = 'yyyy-MM-dd HH:mm:ss';

  /// Export users to CSV format
  static void exportUsersToCSV({
    required List<Map<String, dynamic>> users,
    String filename = 'users_export',
  }) {
    try {
      // Prepare CSV headers
      final headers = [
        'Employee ID',
        'Display Name',
        'Email',
        'Role',
        'Department',
        'Position',
        'Phone Number',
        'Status',
        'Is Active',
        'Created At',
        'Last Login',
        'Credentials Shared',
        'Manager',
        'Reporting Manager',
      ];

      // Prepare CSV rows
      final rows = <List<String>>[headers];

      for (final userInfo in users) {
        final userData = userInfo['data'] as Map<String, dynamic>;
        final isPending = userInfo['isPending'] as bool? ?? false;
        final isActive = userInfo['isActive'] as bool? ?? true;

        final row = [
          userData['employeeId']?.toString() ?? '',
          userData['displayName']?.toString() ?? '',
          userData['email']?.toString() ?? '',
          _formatRole(userData['role']?.toString()),
          userData['department']?.toString() ?? '',
          userData['position']?.toString() ??
              userData['designation']?.toString() ??
              '',
          userData['phoneNumber']?.toString() ??
              userData['phone']?.toString() ??
              '',
          isPending ? 'Pending' : (isActive ? 'Active' : 'Inactive'),
          isActive.toString(),
          _formatTimestamp(userData['createdAt']),
          _formatTimestamp(userData['lastLogin'] ?? userData['lastLoginAt']),
          (userData['credentialsShared'] ?? false).toString(),
          userData['manager']?.toString() ??
              userData['reportingManager']?.toString() ??
              '',
          _resolveReportingManager(userData, users),
        ];

        rows.add(row);
      }

      // Convert to CSV string
      final csvString = const ListToCsvConverter().convert(rows);

      // Create and download file
      _downloadFile(csvString, '$filename.csv', 'text/csv');
    } catch (e) {
      throw Exception('Failed to export users to CSV: $e');
    }
  }

  /// Export selected users with additional filtering options
  static void exportSelectedUsersToCSV({
    required List<Map<String, dynamic>> users,
    required Set<String> selectedUserIds,
    String filename = 'selected_users_export',
  }) {
    final selectedUsers =
        users
            .where((userInfo) => selectedUserIds.contains(userInfo['id']))
            .toList();

    exportUsersToCSV(users: selectedUsers, filename: filename);
  }

  /// Export users with detailed information including custom fields
  static void exportDetailedUsersToCSV({
    required List<Map<String, dynamic>> users,
    String filename = 'detailed_users_export',
  }) {
    try {
      // Extended headers for detailed export
      final headers = [
        'Employee ID',
        'Display Name',
        'First Name',
        'Last Name',
        'Email',
        'Role',
        'Department',
        'Position',
        'Phone Number',
        'Emergency Contact',
        'Emergency Phone',
        'Address',
        'Date of Birth',
        'Date of Joining',
        'Status',
        'Is Active',
        'Created At',
        'Updated At',
        'Last Login',
        'Credentials Shared',
        'Shared At',
        'Manager',
        'Reporting Manager',
        'Salary',
        'Employee Type',
        'Work Location',
        'Skills',
        'Notes',
      ];

      final rows = <List<String>>[headers];

      for (final userInfo in users) {
        final userData = userInfo['data'] as Map<String, dynamic>;
        final isPending = userInfo['isPending'] as bool? ?? false;
        final isActive = userInfo['isActive'] as bool? ?? true;

        final row = [
          userData['employeeId']?.toString() ?? '',
          userData['displayName']?.toString() ?? '',
          userData['firstName']?.toString() ?? '',
          userData['lastName']?.toString() ?? '',
          userData['email']?.toString() ?? '',
          _formatRole(userData['role']?.toString()),
          userData['department']?.toString() ?? '',
          userData['position']?.toString() ??
              userData['designation']?.toString() ??
              '',
          userData['phoneNumber']?.toString() ??
              userData['phone']?.toString() ??
              '',
          userData['emergencyContactName']?.toString() ??
              userData['emergencyContact']?.toString() ??
              '',
          userData['emergencyContactPhone']?.toString() ??
              userData['emergencyPhone']?.toString() ??
              '',
          userData['address']?.toString() ?? '',
          _formatTimestamp(userData['dateOfBirth']),
          _formatTimestamp(userData['joiningDate']),
          isPending ? 'Pending' : (isActive ? 'Active' : 'Inactive'),
          isActive.toString(),
          _formatTimestamp(userData['createdAt']),
          _formatTimestamp(userData['updatedAt']),
          _formatTimestamp(userData['lastLogin'] ?? userData['lastLoginAt']),
          (userData['credentialsShared'] ?? false).toString(),
          _formatTimestamp(
            userData['sharedAt'] ?? userData['credentialsSharedAt'],
          ),
          userData['manager']?.toString() ??
              userData['reportingManager']?.toString() ??
              '',
          _resolveReportingManager(userData, users),
          userData['salary']?.toString() ?? '',
          userData['employeeType']?.toString() ?? '',
          userData['workLocation']?.toString() ?? '',
          _formatList(userData['skills']),
          userData['notes']?.toString() ?? '',
        ];

        rows.add(row);
      }

      final csvString = const ListToCsvConverter().convert(rows);
      _downloadFile(csvString, '$filename.csv', 'text/csv');
    } catch (e) {
      throw Exception('Failed to export detailed users to CSV: $e');
    }
  }

  /// Export user statistics summary
  static void exportUserStatisticsToCSV({
    required Map<String, dynamic> statistics,
    String filename = 'user_statistics_export',
  }) {
    try {
      final headers = ['Metric', 'Value', 'Percentage'];
      final rows = <List<String>>[headers];

      // Add statistics rows
      statistics.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          value.forEach((subKey, subValue) {
            rows.add([
              '$key - $subKey',
              subValue.toString(),
              '', // Percentage can be calculated if needed
            ]);
          });
        } else {
          rows.add([key, value.toString(), '']);
        }
      });

      final csvString = const ListToCsvConverter().convert(rows);
      _downloadFile(csvString, '$filename.csv', 'text/csv');
    } catch (e) {
      throw Exception('Failed to export statistics to CSV: $e');
    }
  }

  /// Helper method to format role names
  static String _formatRole(String? role) {
    if (role == null) return 'Employee';

    switch (role) {
      case 'superAdmin':
        return 'Super Admin';
      case 'admin':
        return 'Admin';
      case 'hr':
        return 'HR';
      case 'manager':
        return 'Manager';
      case 'team_lead':
        return 'Team Lead';
      case 'senior_employee':
        return 'Senior Employee';
      case 'employee':
        return 'Employee';
      case 'contractor':
        return 'Contractor';
      case 'intern':
        return 'Intern';
      case 'vendor':
        return 'Vendor';
      case 'inactive':
        return 'Inactive';
      default:
        return role;
    }
  }

  /// Helper method to format timestamps
  static String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';

    try {
      DateTime dateTime;
      if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } else if (timestamp.runtimeType.toString().contains('Timestamp')) {
        // Handle Firestore Timestamp
        dateTime = timestamp.toDate();
      } else if (timestamp is DateTime) {
        dateTime = timestamp;
      } else {
        return timestamp.toString();
      }

      return DateFormat(_dateFormat).format(dateTime);
    } catch (e) {
      return timestamp.toString();
    }
  }

  /// Helper method to format lists
  static String _formatList(dynamic list) {
    if (list == null) return '';
    if (list is List) {
      return list.join(', ');
    }
    return list.toString();
  }

  /// Helper method to resolve reporting manager name from ID
  static String _resolveReportingManager(
    Map<String, dynamic> userData,
    List<Map<String, dynamic>> allUsers,
  ) {
    // First check if reportingManagerName is already available
    if (userData['reportingManagerName'] != null &&
        userData['reportingManagerName'].toString().isNotEmpty) {
      return userData['reportingManagerName'].toString();
    }

    // Try to resolve from reportingManagerId
    final managerId = userData['reportingManagerId']?.toString();
    if (managerId == null || managerId.isEmpty) {
      return '';
    }

    // Search for the manager in the users list
    for (final userInfo in allUsers) {
      final user = userInfo['data'] as Map<String, dynamic>? ?? {};
      final userId = userInfo['id']?.toString() ?? user['id']?.toString();

      if (userId == managerId) {
        return user['displayName']?.toString() ??
            user['name']?.toString() ??
            'Manager ID: $managerId';
      }
    }

    // If not found, return the ID with a label
    return 'Manager ID: $managerId';
  }

  /// Helper method to download file in web environment
  static void _downloadFile(String content, String filename, String mimeType) {
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor =
        html.AnchorElement(href: url)
          ..setAttribute('download', filename)
          ..click();

    html.Url.revokeObjectUrl(url);
  }

  /// Generate filename with timestamp
  static String generateFilename(String baseName) {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return '${baseName}_$timestamp';
  }

  /// Export detailed information for selected users to CSV
  static void exportDetailedSelectedUsersToCSV({
    required List<Map<String, dynamic>> users,
    required Set<String> selectedUserIds,
    required String filename,
  }) {
    try {
      // Filter users to only include selected ones
      final selectedUsers =
          users.where((user) {
            final userId = user['id'] as String?;
            return userId != null && selectedUserIds.contains(userId);
          }).toList();

      if (selectedUsers.isEmpty) {
        throw Exception('No selected users found to export');
      }

      // Create detailed CSV headers
      final headers = [
        'User ID',
        'Display Name',
        'Email',
        'Phone',
        'Department',
        'Position',
        'Role',
        'Status',
        'Account Type',
        'Date of Joining',
        'Created Date',
        'Last Login',
        'Email Verified',
        'Profile Complete',
        'Address',
        'Emergency Contact',
        'Reporting Manager',
        'Skills',
        'Notes',
      ];

      // Create CSV rows
      final rows = <List<String>>[];
      rows.add(headers);

      for (final user in selectedUsers) {
        final userData = user['data'] as Map<String, dynamic>? ?? {};
        final isPending = user['isPending'] as bool? ?? false;
        final isActive = user['isActive'] as bool? ?? true;

        final row = [
          user['id']?.toString() ?? '',
          userData['displayName']?.toString() ?? '',
          userData['email']?.toString() ?? '',
          userData['phoneNumber']?.toString() ??
              userData['phone']?.toString() ??
              '',
          userData['department']?.toString() ?? '',
          userData['position']?.toString() ??
              userData['designation']?.toString() ??
              '',
          _formatRole(userData['role']?.toString()),
          isPending ? 'Pending' : (isActive ? 'Active' : 'Inactive'),
          userData['accountType']?.toString() ?? '',
          _formatTimestamp(userData['joiningDate']),
          _formatTimestamp(userData['createdAt']),
          _formatTimestamp(userData['lastLogin'] ?? userData['lastLoginAt']),
          (userData['emailVerified'] == true) ? 'Yes' : 'No',
          (userData['profileComplete'] == true) ? 'Yes' : 'No',
          userData['address']?.toString() ?? '',
          userData['emergencyContactName']?.toString() ??
              userData['emergencyContact']?.toString() ??
              '',
          _resolveReportingManager(userData, selectedUsers),
          _formatList(userData['skills']),
          userData['notes']?.toString() ?? '',
        ];
        rows.add(row);
      }

      // Convert to CSV and download
      final csvData = const ListToCsvConverter().convert(rows);
      _downloadFile(csvData, '$filename.csv', 'text/csv');
    } catch (e) {
      throw Exception('Failed to export detailed selected users: $e');
    }
  }
}
