import 'package:flutter/material.dart';

class OrgChartStats extends StatelessWidget {
  final int totalEmployees;
  final int totalDepartments;
  final int totalManagers;
  final int totalDirectors;
  final Map<String, int> departmentCounts;
  final Map<String, int> designationCounts;

  const OrgChartStats({
    super.key,
    required this.totalEmployees,
    required this.totalDepartments,
    required this.totalManagers,
    required this.totalDirectors,
    required this.departmentCounts,
    required this.designationCounts,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCards(),
          const SizedBox(height: 24),
          _buildDepartmentBreakdown(),
          const SizedBox(height: 24),
          _buildDesignationBreakdown(),
        ],
      ),
    );
  }

  Widget _buildOverviewCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Employees',
            totalEmployees.toString(),
            Icons.people,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Departments',
            totalDepartments.toString(),
            Icons.business,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Managers',
            totalManagers.toString(),
            Icons.supervisor_account,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Directors',
            totalDirectors.toString(),
            Icons.account_balance,
            Colors.purple,
          ),
        ),
      ],
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.business, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Department Breakdown',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...departmentCounts.entries.map(
            (entry) => _buildBreakdownItem(
              entry.key,
              entry.value,
              totalEmployees,
              Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesignationBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.work, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Designation Breakdown',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...designationCounts.entries.map(
            (entry) => _buildBreakdownItem(
              entry.key,
              entry.value,
              totalEmployees,
              Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(String label, int count, int total, Color color) {
    final percentage =
        total > 0 ? (count / total * 100).toStringAsFixed(1) : '0.0';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 2,
            child: LinearProgressIndicator(
              value: total > 0 ? count / total : 0,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 60,
            child: Text(
              '$count ($percentage%)',
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
