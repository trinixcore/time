import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/audit_log_model.dart';
import '../providers/audit_log_providers.dart';
import '../widgets/audit_log_filters.dart';
import '../widgets/audit_log_stats.dart';
import '../widgets/audit_log_list.dart';
import '../widgets/audit_log_details_dialog.dart';
import '../models/audit_log_filters.dart' as filters_model;
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import '../../dashboard/ui/dashboard_scaffold.dart';

class AuditLogPage extends ConsumerStatefulWidget {
  const AuditLogPage({super.key});

  @override
  ConsumerState<AuditLogPage> createState() => _AuditLogPageState();
}

class _AuditLogPageState extends ConsumerState<AuditLogPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Filter state
  String? _selectedAction;
  String? _selectedTargetType;
  String? _selectedStatus;
  String? _selectedUser;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  filters_model.AuditLogFilters get _currentFilters =>
      filters_model.AuditLogFilters(
        action: _selectedAction,
        targetType: _selectedTargetType,
        status: _selectedStatus,
        userId: _selectedUser,
        startDate: _startDate,
        endDate: _endDate,
      );

  filters_model.AuditLogFilters get _dateFilters =>
      filters_model.AuditLogFilters(startDate: _startDate, endDate: _endDate);

  void _updateFilters({
    String? action,
    String? targetType,
    String? status,
    String? user,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    setState(() {
      _selectedAction = action ?? _selectedAction;
      _selectedTargetType = targetType ?? _selectedTargetType;
      _selectedStatus = status ?? _selectedStatus;
      _selectedUser = user ?? _selectedUser;
      _startDate = startDate ?? _startDate;
      _endDate = endDate ?? _endDate;
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedAction = null;
      _selectedTargetType = null;
      _selectedStatus = null;
      _selectedUser = null;
      _startDate = null;
      _endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DashboardScaffold(
      currentPath: '/admin/audit-logs',
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: _buildAppBar(theme),
        body: Column(
          children: [
            _buildHeader(theme),
            _buildTabBar(theme),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildLogsTab(theme), _buildStatsTab(theme)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1565C0),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.security,
              color: Color(0xFF1565C0),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Audit Logs',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => setState(() => _showFilters = !_showFilters),
          icon: Icon(
            _showFilters ? Icons.filter_list : Icons.filter_list_outlined,
            color: const Color(0xFF1565C0),
          ),
          tooltip: _showFilters ? 'Hide Filters' : 'Show Filters',
        ),
        IconButton(
          onPressed: _exportLogs,
          icon: const Icon(Icons.download, color: Color(0xFF1565C0)),
          tooltip: 'Export Logs',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Quick stats row
          Row(
            children: [
              Expanded(
                child: _buildQuickStatCard(
                  'Total Logs',
                  ref
                      .watch(auditLogStatsProvider(_dateFilters))
                      .when(
                        data: (stats) => stats['totalLogs']?.toString() ?? '0',
                        loading: () => '...',
                        error: (_, __) => '0',
                      ),
                  Icons.list_alt,
                  const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStatCard(
                  'Recent Activity',
                  ref
                      .watch(auditLogStatsProvider(_dateFilters))
                      .when(
                        data:
                            (stats) =>
                                stats['recentActivity']?.toString() ?? '0',
                        loading: () => '...',
                        error: (_, __) => '0',
                      ),
                  Icons.access_time,
                  const Color(0xFF2196F3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStatCard(
                  'Success Rate',
                  ref
                      .watch(auditLogStatsProvider(_dateFilters))
                      .when(
                        data: (stats) {
                          final total = stats['totalLogs'] ?? 0;
                          final success = stats['byStatus']?['success'] ?? 0;
                          if (total == 0) return '0%';
                          return '${((success / total) * 100).toStringAsFixed(1)}%';
                        },
                        loading: () => '...',
                        error: (_, __) => '0%',
                      ),
                  Icons.check_circle,
                  const Color(0xFF4CAF50),
                ),
              ),
            ],
          ),

          // Filters section
          if (_showFilters) ...[
            const SizedBox(height: 16),
            AuditLogFilters(
              selectedAction: _selectedAction,
              selectedTargetType: _selectedTargetType,
              selectedStatus: _selectedStatus,
              selectedUser: _selectedUser,
              startDate: _startDate,
              endDate: _endDate,
              onFiltersChanged: _updateFilters,
              onClearFilters: _clearFilters,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF1565C0),
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: const Color(0xFF1565C0),
        indicatorWeight: 3,
        tabs: const [
          Tab(icon: Icon(Icons.list_alt), text: 'Audit Logs'),
          Tab(icon: Icon(Icons.analytics), text: 'Statistics'),
        ],
      ),
    );
  }

  Widget _buildLogsTab(ThemeData theme) {
    return AuditLogList(filters: _currentFilters, onLogTap: _showLogDetails);
  }

  Widget _buildStatsTab(ThemeData theme) {
    return AuditLogStats(dateFilters: _dateFilters);
  }

  void _showLogDetails(AuditLogModel log) {
    showDialog(
      context: context,
      builder: (context) => AuditLogDetailsDialog(auditLog: log),
    );
  }

  Future<void> _exportLogs() async {
    final notifier = ref.read(auditLogExportProvider.notifier);
    await notifier.exportLogs(
      action: _selectedAction,
      targetType: _selectedTargetType,
      status: _selectedStatus,
      userId: _selectedUser,
      startDate: _startDate,
      endDate: _endDate,
    );
    final logs = ref
        .read(auditLogExportProvider)
        .maybeWhen(data: (data) => data, orElse: () => []);
    if (logs.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No logs to export.')));
      return;
    }
    // Convert logs to CSV
    final headers = logs.first.keys.toList();
    final List<List<dynamic>> rows = [
      headers,
      ...logs.map((log) => headers.map((h) => log[h] ?? '').toList()),
    ];
    final csvString = const ListToCsvConverter().convert(rows);
    final fileName = 'audit_logs_export.csv';
    if (kIsWeb) {
      final bytes = utf8.encode(csvString);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor =
          html.AnchorElement(href: url)
            ..setAttribute('download', fileName)
            ..click();
      html.Url.revokeObjectUrl(url);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Export started.')));
    } else {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csvString);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Exported to: ${file.path}')));
    }
  }
}
