import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/vitality_theme.dart';
import '../../../core/components/shadcn_card.dart';
import '../../../core/components/shadcn_button.dart';
import '../../../core/components/shadcn_badge.dart';
import '../../../core/components/shadcn_progress.dart';
import '../../../core/components/shadcn_input.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../dashboard/presentation/providers/dashboard_provider.dart';

/// Vitality-inspired Modern Home Dashboard
/// Clean, professional healthcare app interface
class VitalityHomeScreen extends StatefulWidget {
  const VitalityHomeScreen({super.key});

  @override
  State<VitalityHomeScreen> createState() => _VitalityHomeScreenState();
}

class _VitalityHomeScreenState extends State<VitalityHomeScreen> {
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
      backgroundColor: VitalityTheme.background,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vitality',
                    style: VitalityTheme.h3.copyWith(
                      color: VitalityTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Health Monitoring',
                    style: VitalityTheme.bodySmall.copyWith(
                      color: VitalityTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
                color: VitalityTheme.primary,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: VitalityTheme.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      color: VitalityTheme.primary,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BMI Hero Section
                  _buildBMIHeroSection(),
                  const SizedBox(height: 24),

                  // Health Metrics Grid
                  _buildHealthMetricsGrid(),
                  const SizedBox(height: 24),

                  // Quick Actions
                  _buildQuickActions(),
                  const SizedBox(height: 24),

                  // Recent Activity
                  _buildRecentSection(),
                  const SizedBox(height: 24),

                  // AI Predictions Card
                  _buildAIPredictionsCard(),
                  const SizedBox(height: 100), // Bottom nav space
                ],
              ),
            ),
          ),
        ],
      ),
      // Bottom Navigation
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBMIHeroSection() {
    return Container(
      decoration: BoxDecoration(
        color: VitalityTheme.surface,
        borderRadius: VitalityTheme.borderRadiusXl,
        boxShadow: VitalityTheme.shadowMd,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Health Status',
                      style: VitalityTheme.label.copyWith(
                        color: VitalityTheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '24.2',
                          style: VitalityTheme.h1.copyWith(
                            color: VitalityTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'BMI',
                          style: VitalityTheme.h3.copyWith(
                            color: VitalityTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: VitalityTheme.secondary.withOpacity(0.2),
                    borderRadius: VitalityTheme.borderRadiusMd,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: VitalityTheme.healthy,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Healthy Weight',
                        style: VitalityTheme.label.copyWith(
                          color: VitalityTheme.healthy,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'You\'re in the optimal range. Your personalized plan focuses on maintaining lean mass and consistent energy levels.',
              style: VitalityTheme.bodySmall.copyWith(
                color: VitalityTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildMetricStat(
                    '2,150',
                    'Daily Calories',
                    Icons.local_fire_department,
                    VitalityTheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricStat(
                    '2.8L',
                    'Hydration Goal',
                    Icons.water_drop,
                    VitalityTheme.accent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricStat(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: VitalityTheme.borderRadiusLg,
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: VitalityTheme.h4.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: VitalityTheme.bodySmall.copyWith(
              color: VitalityTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetricsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Health Metrics',
              style: VitalityTheme.h2,
            ),
            ShadcnButton(
              text: 'View All',
              variant: ShadcnButtonVariant.ghost,
              icon: Icons.chevron_right,
              onPressed: () => Navigator.pushNamed(context, '/metrics/input'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildHealthCard(
              'Blood Pressure',
              '120/80 mmHg',
              Icons.favorite,
              VitalityTheme.healthExcellent,
              'Normal',
            ),
            _buildHealthCard(
              'Blood Sugar',
              '95 mg/dL',
              Icons.bloodtype,
              VitalityTheme.healthExcellent,
              'Optimal',
            ),
            _buildHealthCard(
              'Cholesterol',
              '190 mg/dL',
              Icons.water_drop,
              VitalityTheme.warning,
              'Elevated',
            ),
            _buildHealthCard(
              'Weight',
              '70 kg',
              Icons.monitor_weight,
              VitalityTheme.healthExcellent,
              'On Track',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthCard(String title, String value, IconData icon, Color color, String status) {
    return ShadcnCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 28),
              ShadcnBadge(
                label: status,
                variant: color == VitalityTheme.healthExcellent
                    ? ShadcnBadgeVariant.success
                    : ShadcnBadgeVariant.warning,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: VitalityTheme.h4.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: VitalityTheme.bodySmall.copyWith(
              color: VitalityTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: VitalityTheme.h2,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Add Metrics',
                Icons.add_circle_outline,
                VitalityTheme.primary,
                () => Navigator.pushNamed(context, '/metrics/input'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'AI Predict',
                Icons.psychology,
                VitalityTheme.accent,
                () => Navigator.pushNamed(context, '/predictions'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Diet Plan',
                Icons.restaurant,
                VitalityTheme.healthy,
                () => Navigator.pushNamed(context, '/diet'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: VitalityTheme.borderRadiusLg,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: VitalityTheme.borderRadiusLg,
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: VitalityTheme.label.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: VitalityTheme.h2,
        ),
        const SizedBox(height: 16),
        ShadcnCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildActivityItem('Logged blood pressure', '2 hours ago', Icons.favorite),
              const Divider(height: 32),
              _buildActivityItem('Generated AI predictions', 'Yesterday', Icons.psychology),
              const Divider(height: 32),
              _buildActivityItem('Updated diet plan', '2 days ago', Icons.restaurant),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: VitalityTheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: VitalityTheme.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: VitalityTheme.body.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                time,
                style: VitalityTheme.bodySmall.copyWith(
                  color: VitalityTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.chevron_right,
          color: VitalityTheme.onSurfaceVariant,
          size: 20,
        ),
      ],
    );
  }

  Widget _buildAIPredictionsCard() {
    return ShadcnCard(
      onTap: () => Navigator.pushNamed(context, '/predictions'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: VitalityTheme.healthGradient,
                borderRadius: VitalityTheme.borderRadiusLg,
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Health Analysis',
                    style: VitalityTheme.h4.copyWith(
                      color: VitalityTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Get personalized disease risk predictions and health recommendations powered by AI',
                    style: VitalityTheme.bodySmall.copyWith(
                      color: VitalityTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: VitalityTheme.primary,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', true, () {}),
              _buildNavItem(Icons.health_and_safety, 'Predict', false, () => Navigator.pushNamed(context, '/predictions')),
              _buildNavItem(Icons.restaurant, 'Diet', false, () => Navigator.pushNamed(context, '/diet')),
              _buildNavItem(Icons.self_improvement, 'Yoga', false, () => Navigator.pushNamed(context, '/yoga')),
              _buildNavItem(Icons.person, 'Profile', false, () => Navigator.pushNamed(context, '/profile')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: VitalityTheme.borderRadiusMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? VitalityTheme.primary : VitalityTheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: VitalityTheme.label.copyWith(
                color: isActive ? VitalityTheme.primary : VitalityTheme.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}