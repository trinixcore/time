import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/employee_provider.dart';

class EmployeeStatsWidget extends ConsumerWidget {
  const EmployeeStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(employeeStatisticsProvider);

    return Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics),
              const SizedBox(width: 8),
              Text(
                'Employee Statistics',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          statsAsync.when(
            data: (stats) => _buildStatsContent(context, stats),
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (error, stack) =>
                    Center(child: Text('Error loading statistics: $error')),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContent(BuildContext context, Map<String, dynamic> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall stats
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overview',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem('Total', stats['total'] ?? 0, Colors.blue),
                    _buildStatItem(
                      'Active',
                      stats['active'] ?? 0,
                      Colors.green,
                    ),
                    _buildStatItem(
                      'Inactive',
                      stats['inactive'] ?? 0,
                      Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Status breakdown
        if (stats['onLeave'] != null || stats['terminated'] != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status Breakdown',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (stats['onLeave'] != null)
                    _buildStatRow('On Leave', stats['onLeave'], Colors.orange),
                  if (stats['terminated'] != null)
                    _buildStatRow(
                      'Terminated',
                      stats['terminated'],
                      Colors.red,
                    ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 16),

        // Department stats
        if (stats['byDepartment'] != null &&
            (stats['byDepartment'] as Map).isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'By Department',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...(stats['byDepartment'] as Map<String, dynamic>).entries
                      .map(
                        (entry) => _buildStatRow(
                          entry.key,
                          entry.value,
                          Colors.purple,
                        ),
                      ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildStatRow(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value.toString(),
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
