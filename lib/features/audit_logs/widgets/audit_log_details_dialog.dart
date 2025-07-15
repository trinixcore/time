import 'package:flutter/material.dart';
import '../../../core/models/audit_log_model.dart';
import 'package:geocoding/geocoding.dart';

class AuditLogDetailsDialog extends StatelessWidget {
  final AuditLogModel auditLog;

  const AuditLogDetailsDialog({super.key, required this.auditLog});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfo(),
                    const SizedBox(height: 24),
                    _buildDetailsSection(),
                    const SizedBox(height: 24),
                    _buildTechnicalInfo(),
                  ],
                ),
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: auditLog.actionColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: auditLog.actionColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getActionIcon(auditLog.action),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auditLog.actionDisplayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'by ${auditLog.userName}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: auditLog.statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: auditLog.statusColor.withOpacity(0.3)),
            ),
            child: Text(
              auditLog.statusDisplayName,
              style: TextStyle(
                color: auditLog.statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Action', auditLog.actionDisplayName),
            _buildInfoRow('User', auditLog.userName),
            _buildInfoRow('User Email', auditLog.userEmail),
            _buildInfoRow('Target Type', auditLog.targetTypeDisplayName),
            _buildInfoRow('Target ID', auditLog.targetId),
            _buildInfoRow('Timestamp', auditLog.formattedTimestamp),
            _buildInfoRow('Time Ago', auditLog.timeAgo),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Action Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 16),
            if (auditLog.details.isNotEmpty) ...[
              ...auditLog.details.entries.map(
                (entry) => _buildDetailRow(entry.key, entry.value.toString()),
              ),
            ] else ...[
              Text(
                'No additional details available',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicalInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Technical Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Log ID', auditLog.id),
            if (auditLog.ipAddress != null)
              _buildInfoRow('IP Address', auditLog.ipAddress!),
            if (auditLog.location != null)
              _buildLocationWithPlaceName(auditLog.location!),
            if (auditLog.userAgent != null)
              _buildInfoRow('User Agent', auditLog.userAgent!),
            if (auditLog.sessionId != null)
              _buildInfoRow('Session ID', auditLog.sessionId!),
            if (auditLog.ipAddress == null &&
                auditLog.userAgent == null &&
                auditLog.sessionId == null)
              Text(
                'No technical information available',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationWithPlaceName(String location) {
    if (!location.contains(',')) {
      // Not coordinates, just show the string
      return _buildInfoRow('Location', location);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Location', location),
        FutureBuilder<String?>(
          future: _getPlaceName(location),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.only(left: 120, top: 2),
                child: SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
            if (snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data!.trim().isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(left: 120, top: 2),
                child: Text(
                  snapshot.data!,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Future<String?> _getPlaceName(String? location) async {
    if (location == null || !location.contains(',')) return null;
    final parts = location.split(',');
    if (parts.length != 2) return null;
    final lat = double.tryParse(parts[0]);
    final lng = double.tryParse(parts[1]);
    if (lat == null || lng == null) return null;
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        // Only include non-null, non-empty values
        final fields =
            [p.locality, p.administrativeArea, p.country]
                .whereType<String>()
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
        return fields.isNotEmpty ? fields.join(', ') : null;
      }
    } catch (_) {}
    return null;
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
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

  Widget _buildDetailRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '${_formatKey(key)}:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
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

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  IconData _getActionIcon(String action) {
    switch (action.split('_').first) {
      case 'LOGIN':
      case 'LOGOUT':
        return Icons.login;
      case 'USER':
      case 'ACCOUNT':
        return Icons.person;
      case 'DOCUMENT':
        return Icons.description;
      case 'EMPLOYEE':
        return Icons.people;
      case 'TASK':
        return Icons.assignment;
      case 'PROFILE':
        return Icons.account_circle;
      case 'HIERARCHY':
        return Icons.account_tree;
      default:
        return Icons.security;
    }
  }

  String _formatKey(String key) {
    if (key.isEmpty) {
      return 'Unknown Key';
    }
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty) // Filter out empty words
        .map(
          (word) =>
              word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '',
        )
        .where((word) => word.isNotEmpty) // Filter out empty results
        .join(' ');
  }
}
