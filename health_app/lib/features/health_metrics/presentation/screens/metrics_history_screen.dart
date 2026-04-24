import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/themes/colors.dart';
import '../providers/metrics_provider.dart';

class MetricsHistoryScreen extends StatefulWidget {
  const MetricsHistoryScreen({super.key});

  @override
  State<MetricsHistoryScreen> createState() => _MetricsHistoryScreenState();
}

class _MetricsHistoryScreenState extends State<MetricsHistoryScreen> {
  String _selectedPeriod = 'month';
  final List<String> _periods = ['week', 'month', 'quarter', 'year'];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final provider = Provider.of<MetricsProvider>(context, listen: false);
    await provider.fetchMetricsHistory(_selectedPeriod);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metrics History'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<MetricsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadHistory,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (provider.metricsHistory.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.show_chart,
                    size: 64,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No metrics history available',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start tracking your health metrics to see trends',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadHistory,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodSelector(),
                  const SizedBox(height: 24),
                  _buildStatisticsCards(provider),
                  const SizedBox(height: 24),
                  _buildWeightChart(provider),
                  const SizedBox(height: 24),
                  _buildBloodPressureChart(provider),
                  const SizedBox(height: 24),
                  _buildBloodSugarChart(provider),
                  const SizedBox(height: 24),
                  _buildMetricsList(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPeriod,
          isExpanded: true,
          items: _periods.map((period) {
            return DropdownMenuItem(
              value: period,
              child: Text(_formatPeriod(period)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedPeriod = value;
              });
              _loadHistory();
            }
          },
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(MetricsProvider provider) {
    final metrics = provider.metricsHistory;
    if (metrics.isEmpty) return const SizedBox.shrink();

    // Calculate averages
    double avgWeight = 0;
    double avgSystolic = 0;
    double avgDiastolic = 0;
    double avgBloodSugar = 0;
    int count = 0;

    for (var metric in metrics) {
      if (metric['metrics'] != null) {
        final metricsData = metric['metrics'];
        if (metricsData['weight'] != null) {
          avgWeight += (metricsData['weight'] as num).toDouble();
        }
        if (metricsData['bloodPressure'] != null) {
          final bp = metricsData['bloodPressure'];
          avgSystolic += (bp['systolic'] as num).toDouble();
          avgDiastolic += (bp['diastolic'] as num).toDouble();
        }
        if (metricsData['bloodSugar'] != null) {
          avgBloodSugar += (metricsData['bloodSugar'] as num).toDouble();
        }
        count++;
      }
    }

    if (count > 0) {
      avgWeight /= count;
      avgSystolic /= count;
      avgDiastolic /= count;
      avgBloodSugar /= count;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Avg Weight',
                '${avgWeight.toStringAsFixed(1)} kg',
                Icons.line_weight,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Avg BP',
                '${avgSystolic.toInt()}/${avgDiastolic.toInt()}',
                Icons.favorite,
                AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Avg Sugar',
                '${avgBloodSugar.toStringAsFixed(0)} mg/dL',
                Icons.bloodtype,
                AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Total Entries',
                '$count',
                Icons.analytics,
                AppColors.info,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChart(MetricsProvider provider) {
    final metrics = provider.metricsHistory.reversed.toList();
    if (metrics.isEmpty) return const SizedBox.shrink();

    final spots = <FlSpot>[];
    for (int i = 0; i < metrics.length; i++) {
      final metric = metrics[i];
      if (metric['metrics']?['weight'] != null) {
        final weight = (metric['metrics']['weight'] as num).toDouble();
        spots.add(FlSpot(i.toDouble(), weight));
      }
    }

    if (spots.isEmpty) return const SizedBox.shrink();

    return _buildChartCard(
      'Weight Trend',
      spots,
      AppColors.primary,
      'kg',
      metrics.length,
    );
  }

  Widget _buildBloodPressureChart(MetricsProvider provider) {
    final metrics = provider.metricsHistory.reversed.toList();
    if (metrics.isEmpty) return const SizedBox.shrink();

    final systolicSpots = <FlSpot>[];
    final diastolicSpots = <FlSpot>[];

    for (int i = 0; i < metrics.length; i++) {
      final metric = metrics[i];
      if (metric['metrics']?['bloodPressure'] != null) {
        final bp = metric['metrics']['bloodPressure'];
        systolicSpots.add(FlSpot(i.toDouble(), (bp['systolic'] as num).toDouble()));
        diastolicSpots.add(FlSpot(i.toDouble(), (bp['diastolic'] as num).toDouble()));
      }
    }

    if (systolicSpots.isEmpty && diastolicSpots.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildMultiLineChartCard(
      'Blood Pressure Trend',
      [
        LineData(systolicSpots, AppColors.error, 'Systolic'),
        LineData(diastolicSpots, AppColors.warning, 'Diastolic'),
      ],
      'mmHg',
      metrics.length,
    );
  }

  Widget _buildBloodSugarChart(MetricsProvider provider) {
    final metrics = provider.metricsHistory.reversed.toList();
    if (metrics.isEmpty) return const SizedBox.shrink();

    final spots = <FlSpot>[];
    for (int i = 0; i < metrics.length; i++) {
      final metric = metrics[i];
      if (metric['metrics']?['bloodSugar'] != null) {
        final sugar = (metric['metrics']['bloodSugar'] as num).toDouble();
        spots.add(FlSpot(i.toDouble(), sugar));
      }
    }

    if (spots.isEmpty) return const SizedBox.shrink();

    return _buildChartCard(
      'Blood Sugar Trend',
      spots,
      AppColors.warning,
      'mg/dL',
      metrics.length,
    );
  }

  Widget _buildChartCard(
    String title,
    List<FlSpot> spots,
    Color color,
    String unit,
    int dataPointCount,
  ) {
    if (spots.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: spots.isEmpty
                      ? 1
                      : _calculateInterval(spots.map((s) => s.y).toList()),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < dataPointCount) {
                          return Text(
                            _formatChartDate(value.toInt()),
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 60,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(0),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: AppColors.border),
                ),
                minX: 0,
                maxX: (dataPointCount - 1).toDouble(),
                minY: _calculateMinY(spots.map((s) => s.y).toList()),
                maxY: _calculateMaxY(spots.map((s) => s.y).toList()),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: color,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            unit,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiLineChartCard(
    String title,
    List<LineData> lineData,
    String unit,
    int dataPointCount,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            children: lineData.map((data) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: data.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    data.label,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < dataPointCount) {
                          return Text(
                            _formatChartDate(value.toInt()),
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 60,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(0),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: AppColors.border),
                ),
                minX: 0,
                maxX: (dataPointCount - 1).toDouble(),
                minY: 0,
                maxY: 200,
                lineBarsData: lineData.map((data) {
                  return LineChartBarData(
                    spots: data.spots,
                    isCurved: true,
                    color: data.color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsList(MetricsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Entries',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...provider.metricsHistory.reversed.take(10).map((metric) {
          return _buildMetricCard(metric);
        }).toList(),
      ],
    );
  }

  Widget _buildMetricCard(dynamic metric) {
    final date = metric['date'] != null
        ? DateTime.parse(metric['date']).toString().split(' ')[0]
        : 'Unknown date';
    final metricsData = metric['metrics'] ?? {};

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (metric['categories']?['bloodPressure'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(
                        metric['categories']['bloodPressure'],
                      ).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      metric['categories']['bloodPressure'],
                      style: TextStyle(
                        fontSize: 12,
                        color: _getCategoryColor(
                          metric['categories']['bloodPressure'],
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (metricsData['bloodPressure'] != null)
              _buildMetricRow(
                'Blood Pressure',
                '${metricsData['bloodPressure']['systolic']}/${metricsData['bloodPressure']['diastolic']} mmHg',
                Icons.favorite,
              ),
            if (metricsData['bloodSugar'] != null)
              _buildMetricRow(
                'Blood Sugar',
                '${metricsData['bloodSugar']} mg/dL',
                Icons.bloodtype,
              ),
            if (metricsData['weight'] != null)
              _buildMetricRow(
                'Weight',
                '${metricsData['weight']} kg',
                Icons.line_weight,
              ),
            if (metricsData['cholesterol'] != null)
              _buildMetricRow(
                'Cholesterol',
                '${metricsData['cholesterol']['total']} mg/dL',
                Icons.water_drop,
              ),
            if (metric['notes'] != null && metric['notes'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Note: ${metric['notes']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'normal':
      case 'optimal':
      case 'desirable':
        return AppColors.healthExcellent;
      case 'elevated':
      case 'high normal':
        return AppColors.healthGood;
      case 'high':
      case 'borderline high':
        return AppColors.healthFair;
      case 'very high':
      case 'hypertension':
        return AppColors.healthPoor;
      default:
        return AppColors.healthCritical;
    }
  }

  String _formatPeriod(String period) {
    switch (period) {
      case 'week':
        return 'Last Week';
      case 'month':
        return 'Last Month';
      case 'quarter':
        return 'Last Quarter';
      case 'year':
        return 'Last Year';
      default:
        return period;
    }
  }

  String _formatChartDate(int index) {
    // Simple date formatter - in real app, use actual dates from data
    final now = DateTime.now();
    final date = now.subtract(Duration(days: index));
    return '${date.day}/${date.month}';
  }

  double _calculateMinY(List<double> values) {
    if (values.isEmpty) return 0;
    final min = values.reduce((a, b) => a < b ? a : b);
    return (min - 10).clamp(0, double.infinity);
  }

  double _calculateMaxY(List<double> values) {
    if (values.isEmpty) return 100;
    final max = values.reduce((a, b) => a > b ? a : b);
    return max + 10;
  }

  double _calculateInterval(List<double> values) {
    if (values.isEmpty) return 10;
    final range = _calculateMaxY(values) - _calculateMinY(values);
    return (range / 5).ceil().toDouble();
  }
}

class LineData {
  final List<FlSpot> spots;
  final Color color;
  final String label;

  LineData(this.spots, this.color, this.label);
}