import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/hierarchy_service.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../widgets/org_chart_tree.dart';
import '../widgets/org_chart_filters.dart';
import '../widgets/org_chart_stats.dart';
import '../widgets/org_chart_search.dart';

class OrgChartPage extends ConsumerStatefulWidget {
  const OrgChartPage({super.key});

  @override
  ConsumerState<OrgChartPage> createState() => _OrgChartPageState();
}

class _OrgChartPageState extends ConsumerState<OrgChartPage>
    with TickerProviderStateMixin {
  final HierarchyService _hierarchyService = HierarchyService();

  late TabController _tabController;
  String? _selectedDepartment;
  String? _selectedDesignation;
  String _searchQuery = '';
  bool _showStats = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrgChartTab(),
                _buildDepartmentTab(),
                _buildStatsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
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
              Icons.account_tree,
              color: Color(0xFF1565C0),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Organization Chart',
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
          onPressed: () => setState(() => _showStats = !_showStats),
          icon: Icon(
            _showStats ? Icons.visibility_off : Icons.analytics,
            color: const Color(0xFF1565C0),
          ),
          tooltip: _showStats ? 'Hide Statistics' : 'Show Statistics',
        ),
        IconButton(
          onPressed: _refreshData,
          icon: const Icon(Icons.refresh, color: Color(0xFF1565C0)),
          tooltip: 'Refresh Data',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeader() {
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
          // Search and Filters Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: OrgChartSearch(
                  onSearchChanged: (query) {
                    setState(() => _searchQuery = query);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OrgChartFilters(
                  selectedDepartment: _selectedDepartment,
                  selectedDesignation: _selectedDesignation,
                  onDepartmentChanged: (department) {
                    setState(() => _selectedDepartment = department);
                  },
                  onDesignationChanged: (designation) {
                    setState(() => _selectedDesignation = designation);
                  },
                ),
              ),
            ],
          ),

          // Statistics Row (if enabled)
          if (_showStats) ...[
            const SizedBox(height: 16),
            OrgChartStats(
              totalEmployees: 0,
              totalDepartments: 0,
              totalManagers: 0,
              totalDirectors: 0,
              departmentCounts: const {},
              designationCounts: const {},
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF1565C0),
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: const Color(0xFF1565C0),
        indicatorWeight: 3,
        tabs: const [
          Tab(icon: Icon(Icons.account_tree), text: 'Full Hierarchy'),
          Tab(icon: Icon(Icons.business), text: 'By Department'),
          Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildOrgChartTab() {
    return FutureBuilder<OrganizationalHierarchy>(
      future: _hierarchyService.getOrganizationalHierarchy(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: LoadingWidget(
              message: 'Loading organizational hierarchy...',
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: CustomErrorWidget(
              message: snapshot.error.toString(),
              onRetry: _refreshData,
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.rootNodes.isEmpty) {
          return _buildEmptyState();
        }

        return OrgChartTree(
          users: [], // This needs to be populated from the hierarchy
          searchQuery: _searchQuery,
          departmentFilter: _selectedDepartment,
          designationFilter: _selectedDesignation,
        );
      },
    );
  }

  Widget _buildDepartmentTab() {
    if (_selectedDepartment == null) {
      return _buildDepartmentSelector();
    }

    return FutureBuilder<OrganizationalHierarchy>(
      future: _hierarchyService.getDepartmentHierarchy(_selectedDepartment!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: LoadingWidget(message: 'Loading department hierarchy...'),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: CustomErrorWidget(
              message: snapshot.error.toString(),
              onRetry: _refreshData,
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.rootNodes.isEmpty) {
          return _buildEmptyDepartmentState();
        }

        return Column(
          children: [
            _buildDepartmentHeader(),
            Expanded(
              child: OrgChartTree(
                users: [], // This needs to be populated from the hierarchy
                searchQuery: _searchQuery,
                departmentFilter: _selectedDepartment,
                designationFilter: _selectedDesignation,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _hierarchyService.getOrganizationStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: LoadingWidget(message: 'Loading organization statistics...'),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: CustomErrorWidget(
              message: snapshot.error.toString(),
              onRetry: _refreshData,
            ),
          );
        }

        if (!snapshot.hasData) {
          return _buildEmptyState();
        }

        return _buildStatsContent(snapshot.data!);
      },
    );
  }

  Widget _buildDepartmentSelector() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.business, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Select Department',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a department to view its organizational structure',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Show department selection dialog
                  _showDepartmentSelectionDialog();
                },
                icon: const Icon(Icons.business),
                label: const Text('Choose Department'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.business, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$_selectedDepartment Department',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () => setState(() => _selectedDepartment = null),
            icon: const Icon(Icons.close, color: Colors.white, size: 18),
            label: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContent(Map<String, dynamic> stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsOverview(stats),
          const SizedBox(height: 24),
          _buildDesignationBreakdown(stats['byDesignation'] ?? {}),
          const SizedBox(height: 24),
          _buildDepartmentBreakdown(stats['byDepartment'] ?? {}),
          const SizedBox(height: 24),
          _buildRoleBreakdown(stats['byRole'] ?? {}),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(Map<String, dynamic> stats) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Organization Overview',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Employees',
                    stats['totalEmployees']?.toString() ?? '0',
                    Icons.people,
                    const Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Hierarchy Levels',
                    stats['maxHierarchyDepth']?.toString() ?? '0',
                    Icons.layers,
                    const Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Root Positions',
                    stats['rootNodes']?.toString() ?? '0',
                    Icons.account_tree,
                    const Color(0xFFFF9800),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
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
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
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

  Widget _buildDesignationBreakdown(Map<String, int> designations) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'By Designation',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 16),
            ...designations.entries.map(
              (entry) => _buildBreakdownItem(
                entry.key,
                entry.value,
                designations.values.reduce((a, b) => a + b),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentBreakdown(Map<String, int> departments) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'By Department',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 16),
            ...departments.entries.map(
              (entry) => _buildBreakdownItem(
                entry.key,
                entry.value,
                departments.values.reduce((a, b) => a + b),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBreakdown(Map<String, int> roles) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'By Role',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 16),
            ...roles.entries.map(
              (entry) => _buildBreakdownItem(
                entry.key,
                entry.value,
                roles.values.reduce((a, b) => a + b),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownItem(String label, int count, int total) {
    final percentage = (count / total * 100).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: count / total,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF1565C0),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 60,
            child: Text(
              '$count ($percentage%)',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_tree_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Organizational Data',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no employees or organizational structure to display.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDepartmentState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Department Data',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'No employees found in the $_selectedDepartment department.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDepartmentSelectionDialog() {
    // This would show a dialog with available departments
    // For now, we'll use a simple input dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Department'),
            content: const Text('Department selection dialog would go here'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // For demo purposes, set a sample department
                  setState(() => _selectedDepartment = 'Engineering');
                  Navigator.of(context).pop();
                },
                child: const Text('Select'),
              ),
            ],
          ),
    );
  }

  void _refreshData() {
    setState(() {
      // This will trigger a rebuild and refresh the data
    });
  }
}
