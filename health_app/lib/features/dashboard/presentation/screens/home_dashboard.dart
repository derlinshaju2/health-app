import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/colors.dart';
import '../providers/dashboard_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final dashboardProvider = context.read<DashboardProvider>();
    await dashboardProvider.fetchDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final dashboardProvider = context.watch<DashboardProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // TODO: Navigate to profile
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: dashboardProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : dashboardProvider.dashboardData == null
                ? _buildEmptyState()
                : _buildDashboardContent(dashboardProvider),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/metrics/input');
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Metrics'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.health_and_safety_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No health data yet',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding your health metrics',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(DashboardProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          _buildWelcomeSection(provider),
          const SizedBox(height: 24),

          // Quick Stats
          _buildQuickStats(provider),
          const SizedBox(height: 24),

          // Latest Metrics
          _buildLatestMetricsCard(provider),
          const SizedBox(height: 16),

          // Risk Analysis
          _buildRiskAnalysisCard(provider),
          const SizedBox(height: 16),

          // Quick Actions
          _buildQuickActions(provider),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(DashboardProvider provider) {
    final user = provider.dashboardData?['user'];
    final name = user?['profile']?['name'] ?? 'User';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, $name! 👋',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Here\'s your health overview',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(DashboardProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'BMI',
            provider.latestMetrics?['bmi']?.toString() ?? 'N/A',
            Icons.monitor_weight,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Blood Sugar',
            '${provider.latestMetrics?['bloodSugar']?.toString() ?? 'N/A'} mg/dL',
            Icons.bloodtype,
            AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestMetricsCard(DashboardProvider provider) {
    final latestMetrics = provider.latestMetrics;

    if (latestMetrics == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Latest Metrics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/metrics/history');
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMetricRow('Blood Pressure', latestMetrics['bloodPressure']),
            const SizedBox(height: 12),
            _buildMetricRow('Blood Sugar', latestMetrics['bloodSugar']),
            const SizedBox(height: 12),
            _buildMetricRow('Cholesterol', latestMetrics['cholesterol']),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, dynamic value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value?.toString() ?? 'N/A',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRiskAnalysisCard(DashboardProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Health Risk Analysis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildRiskItem('Hypertension', 'Low', AppColors.riskLow),
            const SizedBox(height: 12),
            _buildRiskItem('Diabetes', 'Medium', AppColors.riskMedium),
            const SizedBox(height: 12),
            _buildRiskItem('Heart Disease', 'Low', AppColors.riskLow),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/predictions');
              },
              child: const Text('Get AI Prediction'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskItem(String disease, String risk, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          disease,
          style: const TextStyle(fontSize: 16),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            risk,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(DashboardProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildActionButton(
              'Add Metrics',
              Icons.add_circle_outline,
              AppColors.primary,
              () => Navigator.pushNamed(context, '/metrics/input'),
            ),
            _buildActionButton(
              'View History',
              Icons.history,
              AppColors.secondary,
              () => Navigator.pushNamed(context, '/metrics/history'),
            ),
            _buildActionButton(
              'AI Predictions',
              Icons.psychology_outlined,
              AppColors.accent,
              () => Navigator.pushNamed(context, '/predictions'),
            ),
            _buildActionButton(
              'Diet Plan',
              Icons.restaurant_outlined,
              AppColors.success,
              () => Navigator.pushNamed(context, '/diet'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}