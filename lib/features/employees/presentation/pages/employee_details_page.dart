import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/enums/user_role.dart';
import '../../../../core/providers/performance_providers.dart';
import '../../../../shared/providers/auth_providers.dart';
import '../../../dashboard/ui/dashboard_scaffold.dart';

// Provider to get user by ID using raw Firestore data
final userByIdProvider = FutureProvider.family<Map<String, dynamic>?, String>((
  ref,
  userId,
) async {
  try {
    final usersData = await ref.read(optimizedUsersDataProvider.future);
    final activeUsers = usersData['active'] ?? [];
    final pendingUsers = usersData['pending'] ?? [];

    // Search in active users
    for (var doc in activeUsers) {
      if (doc.id == userId) {
        final userData = doc.data() as Map<String, dynamic>?;
        if (userData != null) {
          return {
            'data': userData,
            'id': doc.id,
            'isPending': false,
            'isActive': userData['isActive'] ?? true,
          };
        }
      }
    }

    // Search in pending users
    for (var doc in pendingUsers) {
      if (doc.id == userId) {
        final userData = doc.data() as Map<String, dynamic>?;
        if (userData != null) {
          return {
            'data': userData,
            'id': doc.id,
            'isPending': true,
            'isActive': false,
          };
        }
      }
    }

    return null;
  } catch (e) {
    return null;
  }
});

// Provider to get creator's name by ID using raw Firestore data
final creatorNameProvider = FutureProvider.family<String, String?>((
  ref,
  creatorId,
) async {
  if (creatorId == null || creatorId.isEmpty) {
    return 'System';
  }

  try {
    final usersData = await ref.read(optimizedUsersDataProvider.future);
    final activeUsers = usersData['active'] ?? [];
    final pendingUsers = usersData['pending'] ?? [];

    // Search in active users
    for (var doc in activeUsers) {
      if (doc.id == creatorId) {
        final userData = doc.data() as Map<String, dynamic>?;
        if (userData != null) {
          return userData['displayName'] ?? 'Unknown User';
        }
      }
    }

    // Search in pending users
    for (var doc in pendingUsers) {
      if (doc.id == creatorId) {
        final userData = doc.data() as Map<String, dynamic>?;
        if (userData != null) {
          return userData['displayName'] ?? 'Unknown User';
        }
      }
    }

    return 'Unknown User';
  } catch (e) {
    return 'Unknown User';
  }
});

class EmployeeDetailsPage extends ConsumerWidget {
  final String employeeId;

  const EmployeeDetailsPage({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userByIdProvider(employeeId));
    final currentUserAsync = ref.watch(currentUserProvider);

    return currentUserAsync.when(
      data:
          (currentUser) => DashboardScaffold(
            currentPath: '/employees/$employeeId',
            child: Scaffold(
              appBar: AppBar(
                title: const Text('User Details'),
                backgroundColor: Theme.of(context).colorScheme.surface,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/employees'),
                ),
              ),
              body: userAsync.when(
                data: (user) {
                  if (user == null) {
                    return _buildNotFoundState(context);
                  }
                  return _buildUserDetails(context, user, currentUser);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, stack) =>
                        _buildErrorState(context, error.toString()),
              ),
            ),
          ),
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (error, stack) =>
              Scaffold(body: Center(child: Text('Error loading user: $error'))),
    );
  }

  Widget _buildUserDetails(
    BuildContext context,
    Map<String, dynamic> user,
    currentUser,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Header Card
          _buildHeaderCard(context, user),
          const SizedBox(height: 24),

          // Personal Information
          _buildSectionCard(context, 'Personal Information', Icons.person, [
            _buildInfoRow(
              'Full Name',
              user['data']['displayName'] ?? 'Not assigned',
            ),
            _buildInfoRow(
              'Employee ID',
              user['data']['employeeId'] ?? 'Not assigned',
            ),
            _buildInfoRow('Email', user['data']['email'] ?? 'Not provided'),
            _buildInfoRow(
              'Phone',
              user['data']['phoneNumber'] ?? 'Not provided',
            ),
          ]),
          const SizedBox(height: 16),

          // Professional Information
          _buildSectionCard(context, 'Professional Information', Icons.work, [
            _buildInfoRow(
              'Department',
              user['data']['department'] ?? 'Not assigned',
            ),
            _buildInfoRow(
              'Position & Role',
              _buildPositionAndRole(user['data']),
            ),
            _buildInfoRow('Status', user['isActive'] ? 'Active' : 'Inactive'),
          ]),
          const SizedBox(height: 16),

          // Contact Information
          _buildSectionCard(
            context,
            'Contact Information',
            Icons.contact_phone,
            [
              _buildInfoRow(
                'Work Email',
                user['data']['email'] ?? 'Not provided',
              ),
              _buildInfoRow(
                'Work Phone',
                user['data']['phoneNumber'] ?? 'Not provided',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // System Information
          _buildSystemInformationCard(context, user),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, Map<String, dynamic> user) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            // User Avatar
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                _getInitials(user['data']['displayName'] ?? ''),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 24),
            // User Basic Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['data']['displayName'] ?? 'No Name',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _buildPositionAndRole(user['data']),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user['data']['department'] ?? 'No Department',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  _buildStatusChip(context, user['isActive']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String displayName) {
    if (displayName.isEmpty) return 'U';
    final parts = displayName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return displayName[0].toUpperCase();
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, bool isActive) {
    Color color;
    String label;

    if (isActive) {
      color = Colors.green;
      label = 'Active';
    } else {
      color = Colors.red;
      label = 'Inactive';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSystemInformationCard(
    BuildContext context,
    Map<String, dynamic> user,
  ) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'System Information',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('User ID', user['id'] ?? ''),
            _buildInfoRow('Created At', _formatDate(user['data']['createdAt'])),
            _buildInfoRow('Updated At', _formatDate(user['data']['updatedAt'])),
            _buildInfoRow('Active', user['isActive'] ? 'Yes' : 'No'),
            if (user['data']['lastLoginAt'] != null)
              _buildInfoRow(
                'Last Login',
                _formatDate(user['data']['lastLoginAt']),
              ),
            if (user['data']['createdBy'] != null)
              _buildCreatedByRow(user['data']['createdBy']),
            if (user['data']['mfaEnabled'] != null)
              _buildInfoRow(
                'MFA Enabled',
                user['data']['mfaEnabled'] ? 'Yes' : 'No',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatedByRow(String creatorId) {
    return Consumer(
      builder: (context, ref, child) {
        final creatorNameAsync = ref.watch(creatorNameProvider(creatorId));

        return creatorNameAsync.when(
          data: (creatorName) => _buildInfoRow('Created By', creatorName),
          loading: () => _buildInfoRow('Created By', 'Loading...'),
          error: (error, stack) => _buildInfoRow('Created By', 'Unknown User'),
        );
      },
    );
  }

  Widget _buildNotFoundState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Employee Not Found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'The requested employee could not be found.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/employees'),
            child: const Text('Back to Employees'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Employee',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/employees'),
            child: const Text('Back to Employees'),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Not available';

    // Debug logging to see the actual date format
    print('DEBUG: Date value: $date, Type: ${date.runtimeType}');

    DateTime dateTime;

    try {
      if (date is Timestamp) {
        // Firestore Timestamp
        print('DEBUG: Parsing as Firestore Timestamp');
        dateTime = date.toDate();
      } else if (date is DateTime) {
        // DateTime object
        print('DEBUG: Already a DateTime object');
        dateTime = date;
      } else if (date is String) {
        // ISO string format
        print('DEBUG: Parsing as ISO string: $date');
        dateTime = DateTime.parse(date);
      } else if (date is int) {
        // Milliseconds since epoch
        print('DEBUG: Parsing as milliseconds since epoch: $date');
        dateTime = DateTime.fromMillisecondsSinceEpoch(date);
      } else if (date is Map && date.containsKey('_seconds')) {
        // Firestore Timestamp as Map (sometimes happens with raw data)
        print('DEBUG: Parsing as Firestore Timestamp Map: $date');
        final seconds = date['_seconds'] as int;
        final nanoseconds = (date['_nanoseconds'] as int?) ?? 0;
        dateTime = DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + (nanoseconds / 1000000).round(),
        );
      } else {
        // Try to convert to string and parse
        print('DEBUG: Trying to parse as string: ${date.toString()}');
        dateTime = DateTime.parse(date.toString());
      }

      print('DEBUG: Successfully parsed date: $dateTime');
    } catch (e) {
      // If all parsing attempts fail, return error message
      print('DEBUG: Failed to parse date: $e');
      return 'Invalid date format: ${date.runtimeType}';
    }

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return 'Not available';

    DateTime dt;

    try {
      if (dateTime is Timestamp) {
        // Firestore Timestamp
        dt = dateTime.toDate();
      } else if (dateTime is DateTime) {
        // DateTime object
        dt = dateTime;
      } else if (dateTime is String) {
        // ISO string format
        dt = DateTime.parse(dateTime);
      } else if (dateTime is int) {
        // Milliseconds since epoch
        dt = DateTime.fromMillisecondsSinceEpoch(dateTime);
      } else if (dateTime is Map && dateTime.containsKey('_seconds')) {
        // Firestore Timestamp as Map (sometimes happens with raw data)
        final seconds = dateTime['_seconds'] as int;
        final nanoseconds = (dateTime['_nanoseconds'] as int?) ?? 0;
        dt = DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + (nanoseconds / 1000000).round(),
        );
      } else {
        // Try to convert to string and parse
        dt = DateTime.parse(dateTime.toString());
      }
    } catch (e) {
      // If all parsing attempts fail, return error message
      return 'Invalid date format';
    }

    return '${dt.day}/${dt.month}/${dt.year} at ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _buildPositionAndRole(Map<String, dynamic> userData) {
    final position = userData['position'] ?? 'Not assigned';
    final roleString = userData['role'] ?? 'employee';
    final userRole = UserRole.fromString(roleString);
    return '$position - ${userRole.displayName}';
  }
}
