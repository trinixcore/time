import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audit_log_providers.dart';
import '../models/audit_log_filters.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
// Conditional import for web download
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

enum ChartType { verticalBar, horizontalBar, line, pie }

class AuditLogStats extends ConsumerStatefulWidget {
  final AuditLogFilters dateFilters;

  const AuditLogStats({super.key, required this.dateFilters});

  @override
  ConsumerState<AuditLogStats> createState() => _AuditLogStatsState();
}

class _AuditLogStatsState extends ConsumerState<AuditLogStats> {
  ChartType _selectedChartType = ChartType.verticalBar;
  final Map<String, GlobalKey> _chartKeys = {
    'Status': GlobalKey(),
    'Action': GlobalKey(),
    'Target': GlobalKey(),
    'User': GlobalKey(),
  };

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(auditLogStatsProvider(widget.dateFilters));

    return stats.when(
      data: (data) => _buildStatsContent(context, data),
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Error loading statistics',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: TextStyle(color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildStatsContent(BuildContext context, Map<String, dynamic> stats) {
    // Check if there are any logs
    final totalLogs = stats['totalLogs'] ?? 0;

    if (totalLogs == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Audit Log Statistics',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Statistics will appear here when audit logs are available.',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue[600]),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Audit log statistics are generated from recorded system activities.',
                      style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCards(stats),
          const SizedBox(height: 24),
          _buildChartTypeSelector(),
          const SizedBox(height: 24),
          _buildStatusBreakdown(stats),
          const SizedBox(height: 24),
          _buildActionBreakdown(stats),
          const SizedBox(height: 24),
          _buildTargetTypeBreakdown(stats),
          const SizedBox(height: 24),
          _buildUserActivityBreakdown(stats),
        ],
      ),
    );
  }

  Widget _buildChartTypeSelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chart Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children:
                  ChartType.values.map((chartType) {
                    final isSelected = _selectedChartType == chartType;
                    return FilterChip(
                      selected: isSelected,
                      label: Text(_getChartTypeLabel(chartType)),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedChartType = chartType;
                          });
                        }
                      },
                      selectedColor: const Color(0xFF1565C0).withOpacity(0.2),
                      checkmarkColor: const Color(0xFF1565C0),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _getChartTypeLabel(ChartType chartType) {
    switch (chartType) {
      case ChartType.verticalBar:
        return 'Vertical Bar';
      case ChartType.horizontalBar:
        return 'Horizontal Bar';
      case ChartType.line:
        return 'Line Chart';
      case ChartType.pie:
        return 'Pie Chart';
    }
  }

  Widget _buildOverviewCards(Map<String, dynamic> stats) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Audit Log Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Logs',
                    stats['totalLogs']?.toString() ?? '0',
                    Icons.list_alt,
                    const Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Recent Activity',
                    stats['recentActivity']?.toString() ?? '0',
                    Icons.access_time,
                    const Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Success Rate',
                    _calculateSuccessRate(stats),
                    Icons.check_circle,
                    const Color(0xFF4CAF50),
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

  Future<void> _downloadChart(String chartKey) async {
    try {
      final boundary =
          _chartKeys[chartKey]?.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final pngBytes = byteData.buffer.asUint8List();
      if (kIsWeb) {
        // Web: trigger browser download
        final blob = html.Blob([pngBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor =
            html.AnchorElement(href: url)
              ..setAttribute('download', 'audit_log_chart_$chartKey.png')
              ..click();
        html.Url.revokeObjectUrl(url);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chart download started.')),
        );
      } else {
        // Mobile/Desktop: save to temp directory
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/audit_log_chart_$chartKey.png');
        await file.writeAsBytes(pngBytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chart downloaded: ${file.path}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to download chart: $e')));
    }
  }

  Widget _buildStatusBreakdown(Map<String, dynamic> stats) {
    final statusData = stats['byStatus'] as Map<String, dynamic>? ?? {};
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'By Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1565C0),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  tooltip: 'Download Chart',
                  onPressed: () => _downloadChart('Status'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            RepaintBoundary(
              key: _chartKeys['Status'],
              child: _buildChart(statusData, 'Status'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBreakdown(Map<String, dynamic> stats) {
    final actionData = stats['byAction'] as Map<String, dynamic>? ?? {};
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'By Action Type',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1565C0),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  tooltip: 'Download Chart',
                  onPressed: () => _downloadChart('Action'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            RepaintBoundary(
              key: _chartKeys['Action'],
              child: _buildChart(actionData, 'Action'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetTypeBreakdown(Map<String, dynamic> stats) {
    final targetData = stats['byTargetType'] as Map<String, dynamic>? ?? {};
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'By Target Type',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1565C0),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  tooltip: 'Download Chart',
                  onPressed: () => _downloadChart('Target'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            RepaintBoundary(
              key: _chartKeys['Target'],
              child: _buildChart(targetData, 'Target'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserActivityBreakdown(Map<String, dynamic> stats) {
    final userData = stats['byUser'] as Map<String, dynamic>? ?? {};
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Most Active Users',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1565C0),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  tooltip: 'Download Chart',
                  onPressed: () => _downloadChart('User'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            RepaintBoundary(
              key: _chartKeys['User'],
              child: _buildChart(userData, 'User'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(Map<String, dynamic> data, String category) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    final sortedData =
        data.entries.toList()
          ..sort((a, b) => (b.value as int).compareTo(a.value as int));

    switch (_selectedChartType) {
      case ChartType.verticalBar:
        return _buildVerticalBarChart(sortedData, category);
      case ChartType.horizontalBar:
        return _buildHorizontalBarChart(sortedData, category);
      case ChartType.line:
        return _buildLineChart(sortedData, category);
      case ChartType.pie:
        return _buildPieChart(sortedData, category);
    }
  }

  Widget _buildVerticalBarChart(
    List<MapEntry<String, dynamic>> data,
    String category,
  ) {
    final maxValue = data.isNotEmpty ? data.first.value as int : 1;
    final barColors = [
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
      const Color(0xFF607D8B),
    ];
    final barWidth = 40.0;
    final chartHeight = 220.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Container(
        color: Colors.white, // Ensure white background for PNG
        child: SizedBox(
          height: chartHeight + 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children:
                data.take(5).toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final value = item.value as int;
                  final color = barColors[index % barColors.length];
                  final barHeight =
                      maxValue > 0 ? (value / maxValue) * chartHeight : 0.0;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Value label
                      Text(
                        value.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Bar
                      Container(
                        width: barWidth,
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Category label with tooltip
                      SizedBox(
                        width: barWidth + 8,
                        child: Tooltip(
                          message: item.key,
                          child: Text(
                            item.key,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black, // Black for visibility
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalBarChart(
    List<MapEntry<String, dynamic>> data,
    String category,
  ) {
    final maxValue = data.isNotEmpty ? data.first.value as int : 1;
    final colors = [
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
      const Color(0xFF607D8B),
    ];

    return Column(
      children:
          data.take(8).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final value = item.value as int;
            final percentage = maxValue > 0 ? value / maxValue : 0.0;
            final color = colors[index % colors.length];

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      item.key,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: percentage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 40,
                    child: Text(
                      value.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: color,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildLineChart(
    List<MapEntry<String, dynamic>> data,
    String category,
  ) {
    final colors = [
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
      const Color(0xFF607D8B),
    ];

    return SizedBox(
      height: 200,
      child: CustomPaint(
        size: const Size(double.infinity, 200),
        painter: LineChartPainter(data, colors),
      ),
    );
  }

  Widget _buildPieChart(List<MapEntry<String, dynamic>> data, String category) {
    final total = data.fold<int>(0, (sum, item) => sum + (item.value as int));
    final colors = [
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
      const Color(0xFF607D8B),
    ];

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: CustomPaint(
            size: const Size(200, 200),
            painter: PieChartPainter(data, colors, total),
          ),
        ),
        const SizedBox(height: 16),
        ...data.take(5).toList().asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final value = item.value as int;
          final percentage =
              total > 0 ? (value / total * 100).toStringAsFixed(1) : '0.0';
          final color = colors[index % colors.length];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.key,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '$value ($percentage%)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: color,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  String _calculateSuccessRate(Map<String, dynamic> stats) {
    final total = stats['totalLogs'] ?? 0;
    final success = stats['byStatus']?['success'] ?? 0;
    if (total == 0) return '0%';
    return '${((success / total) * 100).toStringAsFixed(1)}%';
  }
}

class LineChartPainter extends CustomPainter {
  final List<MapEntry<String, dynamic>> data;
  final List<Color> colors;

  LineChartPainter(this.data, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint =
        Paint()
          ..color = colors[0]
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    final path = Path();
    final maxValue = data.first.value as int;
    final pointWidth = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * pointWidth;
      final y = size.height - (data[i].value as int) / maxValue * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw points
    for (int i = 0; i < data.length; i++) {
      final x = i * pointWidth;
      final y = size.height - (data[i].value as int) / maxValue * size.height;

      canvas.drawCircle(Offset(x, y), 4, Paint()..color = colors[0]);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PieChartPainter extends CustomPainter {
  final List<MapEntry<String, dynamic>> data;
  final List<Color> colors;
  final int total;

  PieChartPainter(this.data, this.colors, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    double startAngle = 0;

    for (int i = 0; i < data.length; i++) {
      final value = data[i].value as int;
      final sweepAngle = (value / total) * 2 * 3.14159;

      final paint =
          Paint()
            ..color = colors[i % colors.length]
            ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
