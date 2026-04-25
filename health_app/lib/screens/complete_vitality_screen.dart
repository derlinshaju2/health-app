import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/vitality_theme.dart';
import '../../../core/components/vitality_cards.dart';
import '../../../core/components/vitality_meal_cards.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';

/// Health Monitor App with Vitality-inspired Design
/// Modern health monitoring interface with clean, professional design
class HealthMonitorScreen extends StatefulWidget {
  const HealthMonitorScreen({super.key});

  @override
  State<HealthMonitorScreen> createState() => _HealthMonitorScreenState();
}

class _HealthMonitorScreenState extends State<HealthMonitorScreen> {
  int _selectedIndex = 2; // Start on diet tab (like in Vitality app)

  // Show logout confirmation dialog
  Future<void> _showLogoutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: VitalityTheme.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VitalityTheme.background,
      body: Column(
        children: [
          // Modern App Bar (like Vitality)
          _buildAppBar(),
          // Main Content
          Expanded(
            child: _buildSelectedTab(),
          ),
          // Bottom Navigation (Vitality style)
          _buildBottomNavigationBar(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // User Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: VitalityTheme.primary.withOpacity(0.1),
              child: Icon(
                Icons.person,
                color: VitalityTheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            // App Name
            Text(
              'health_app',
              style: VitalityTheme.h2.copyWith(
                color: VitalityTheme.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
            // Logout Button
            IconButton(
              onPressed: () => _showLogoutDialog(),
              icon: Icon(
                Icons.logout,
                color: VitalityTheme.primary,
                size: 20,
              ),
              tooltip: 'Logout',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedTab() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildPredictTab();
      case 2:
        return _buildDietTab();
      case 3:
        return _buildYogaTab();
      case 4:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  // HOME TAB - BMI Hero + Health Metrics
  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BMI Hero Section (exact Vitality design)
          VitalityHeroCard(
            title: 'Current Status',
            subtitle: 'Health Overview',
            mainValue: '24.2',
            unit: 'BMI',
            status: 'Healthy Weight',
            mainIcon: Icons.monitor_weight,
            statusColor: VitalityTheme.healthy,
            metrics: [
              VitalityMetric(
                value: '2,150',
                label: 'Daily Calories',
                icon: Icons.local_fire_department,
                color: VitalityTheme.primary,
              ),
              VitalityMetric(
                value: '2.8L',
                label: 'Hydration Goal',
                icon: Icons.water_drop,
                color: VitalityTheme.accent,
              ),
            ],
            description: 'You\'re in the optimal range. Your personalized plan focuses on maintaining lean mass and consistent energy levels.',
          ),
          const SizedBox(height: 32),

          // Personalized Diet Plan Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Personalized Diet Plan',
                style: VitalityTheme.h2,
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.chevron_right),
                label: const Text('Full Weekly View'),
                style: TextButton.styleFrom(
                  foregroundColor: VitalityTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Meal Cards (Vitality style)
          _buildMealCard(
            mealType: 'Breakfast',
            mealTime: '08:00 AM',
            title: 'Avocado & Poached Egg Sourdough',
            description: 'High-fiber complex carbs paired with healthy fats and protein to kickstart your metabolism without the mid-morning slump.',
            imageUrl: 'https://images.unsplash.com/photo-1525351480169-2122917112e6?w=500',
            calories: 420,
            protein: '18g',
            carbs: '24g',
            fats: '22g',
            otherInfo: 'Healthy Fats',
            themeColor: VitalityTheme.primary,
          ),
          const SizedBox(height: 24),

          _buildMealCard(
            mealType: 'Lunch',
            mealTime: '01:30 PM',
            title: 'Mediterranean Power Bowl',
            description: 'A vibrant mix of grilled chicken, quinoa, and fresh greens. Rich in micronutrients and steady-release energy for your afternoon peak.',
            imageUrl: 'https://images.unsplash.com/photo-1512621776951-aad1ca488eac?w=500',
            calories: 580,
            protein: '42g',
            carbs: '55g',
            fats: '28g',
            otherInfo: 'Healthy Fats',
            themeColor: VitalityTheme.accent,
          ),
          const SizedBox(height: 24),

          _buildMealCard(
            mealType: 'Dinner',
            mealTime: '07:30 PM',
            title: 'Wild Salmon & Charred Asparagus',
            description: 'Light yet satisfying. High in Omega-3 fatty acids to support brain health and recovery during sleep. Low-carb to prevent insulin spikes before bed.',
            imageUrl: 'https://images.unsplash.com/photo-14670039095857-04f61c6efdce?w=500',
            calories: 490,
            protein: '34g',
            carbs: '12g',
            fats: '26g',
            otherInfo: 'Omega-3s',
            themeColor: const Color(0xFFFF9E0B),
          ),
          const SizedBox(height: 32),

          // Health Metrics Grid
          Text(
            'Health Metrics',
            style: VitalityTheme.h2,
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: [
              VitalityMetricCard(
                title: 'Blood Pressure',
                value: '120/80',
                unit: 'mmHg',
                status: 'Normal',
                icon: Icons.favorite,
                statusColor: VitalityTheme.healthExcellent,
              ),
              VitalityMetricCard(
                title: 'Blood Sugar',
                value: '95',
                unit: 'mg/dL',
                status: 'Optimal',
                icon: Icons.bloodtype,
                statusColor: VitalityTheme.healthExcellent,
              ),
              VitalityMetricCard(
                title: 'Cholesterol',
                value: '190',
                unit: 'mg/dL',
                status: 'Elevated',
                icon: Icons.water_drop,
                statusColor: VitalityTheme.warning,
              ),
              VitalityMetricCard(
                title: 'Weight',
                value: '70',
                unit: 'kg',
                status: 'On Track',
                icon: Icons.monitor_weight,
                statusColor: VitalityTheme.healthExcellent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard({
    required String mealType,
    required String mealTime,
    required String title,
    required String description,
    required String imageUrl,
    required int calories,
    required String protein,
    required String carbs,
    required String fats,
    required String otherInfo,
    required Color themeColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: VitalityTheme.background,
        borderRadius: VitalityTheme.borderRadiusXl,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Section
          SizedBox(
            height: 200,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: themeColor.withOpacity(0.1),
                      child: Center(
                        child: Icon(
                          _getMealIcon(mealType),
                          size: 48,
                          color: themeColor,
                        ),
                      ),
                    );
                  },
                ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.2),
                      ],
                    ),
                  ),
                ),
                // Meal Type Badge
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.9),
                      borderRadius: VitalityTheme.borderRadiusMd,
                    ),
                    child: Text(
                      mealType,
                      style: VitalityTheme.label.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Time Badge
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: VitalityTheme.borderRadiusSm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          mealTime,
                          style: VitalityTheme.tiny.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Info Section
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: VitalityTheme.h3.copyWith(
                    color: VitalityTheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: VitalityTheme.body.copyWith(
                    color: VitalityTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                // Nutrition Facts
                Row(
                  children: [
                    _buildNutrientInfo(calories.toString(), 'Calories', themeColor),
                    const SizedBox(width: 32),
                    _buildNutrientInfo(protein, 'Protein', themeColor),
                    const SizedBox(width: 32),
                    _buildNutrientInfo(carbs, 'Carbs', themeColor),
                    const SizedBox(width: 32),
                    _buildNutrientInfo(fats, otherInfo, themeColor),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientInfo(String value, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: VitalityTheme.tiny.copyWith(
            color: VitalityTheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.wb_sunny;
      case 'lunch':
        return Icons.restaurant;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.cookie;
      default:
        return Icons.fastfood;
    }
  }

  // PREDICT TAB
  Widget _buildPredictTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Predictions Hero
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: VitalityTheme.healthGradient,
              borderRadius: VitalityTheme.borderRadiusXl,
              boxShadow: VitalityTheme.shadowMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'AI Disease Risk Analysis',
                  style: VitalityTheme.h2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Get personalized predictions powered by machine learning',
                  style: VitalityTheme.body.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: VitalityTheme.healthy,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: VitalityTheme.borderRadiusMd,
                    ),
                  ),
                  child: Text(
                    'Generate Predictions',
                    style: VitalityTheme.label.copyWith(
                      color: VitalityTheme.healthy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Health Stats
          Text(
            'Your Health Risk Profile',
            style: VitalityTheme.h2,
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
              _buildRiskCard('Hypertension', 35, 'Medium Risk', Icons.favorite, VitalityTheme.warning),
              _buildRiskCard('Diabetes', 25, 'Low Risk', Icons.bloodtype, VitalityTheme.healthExcellent),
              _buildRiskCard('Heart Disease', 20, 'Low Risk', Icons.favorite_border, VitalityTheme.healthExcellent),
              _buildRiskCard('Obesity', 40, 'Elevated', Icons.monitor_weight, VitalityTheme.warning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiskCard(String disease, int risk, String status, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: VitalityTheme.surface,
        borderRadius: VitalityTheme.borderRadiusLg,
        border: Border.all(
          color: VitalityTheme.surfaceVariant,
          width: 1,
        ),
        boxShadow: VitalityTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            disease,
            style: VitalityTheme.h4.copyWith(
              color: VitalityTheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$risk% Risk Score',
            style: VitalityTheme.body.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            status,
            style: VitalityTheme.bodySmall.copyWith(
              color: VitalityTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // DIET TAB
  Widget _buildDietTab() {
    return _buildDietTab(); // Use the same comprehensive diet tab
  }

  // YOGA TAB
  Widget _buildYogaTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Yoga Progress Hero
          VitalityProgressCard(
            title: '30 Day Consistency',
            subtitle: 'Your Yoga Journey',
            progress: 0.4,
            daysCompleted: 12,
            totalDays: 30,
            icon: Icons.self_improvement,
            themeColor: VitalityTheme.primary,
          ),
          const SizedBox(height: 32),
          // Yoga Stats
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: [
              _buildYogaStat('Sessions Completed', '12', Icons.check_circle, VitalityTheme.healthy),
              _buildYogaStat('Total Minutes', '360', Icons.timer, VitalityTheme.primary),
              _buildYogaStat('Calories Burned', '2,150', Icons.local_fire_department, VitalityTheme.accent),
              _buildYogaStat('Current Streak', '7 days', Icons.trending_up, VitalityTheme.healthExcellent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYogaStat(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: VitalityTheme.surface,
        borderRadius: VitalityTheme.borderRadiusLg,
        border: Border.all(
          color: VitalityTheme.surfaceVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: VitalityTheme.h4.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
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

  // PROFILE TAB
  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: VitalityTheme.surface,
              borderRadius: VitalityTheme.borderRadiusXl,
              boxShadow: VitalityTheme.shadowMd,
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: VitalityTheme.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    color: VitalityTheme.primary,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your Profile',
                  style: VitalityTheme.h3.copyWith(
                    color: VitalityTheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your health information and preferences',
                  style: VitalityTheme.bodySmall.copyWith(
                    color: VitalityTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Profile Stats
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: [
              _buildProfileStat('Age', '28 years', Icons.cake, VitalityTheme.primary),
              _buildProfileStat('Height', '175 cm', Icons.height, VitalityTheme.accent),
              _buildProfileStat('Weight', '70 kg', Icons.monitor_weight, VitalityTheme.healthy),
              _buildProfileStat('BMI', '22.9', Icons.fitness_center, VitalityTheme.healthExcellent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: VitalityTheme.borderRadiusLg,
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: VitalityTheme.h4.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: VitalityTheme.bodySmall.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Vitality-Style Bottom Navigation
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -8),
            spreadRadius: 0,
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, 'Home', 0),
              _buildNavItem(Icons.health_and_safety_outlined, 'Predict', 1),
              _buildNavItem(Icons.restaurant, 'Diet', 2, isActive: true), // Active state
              _buildNavItem(Icons.self_improvement_outlined, 'Yoga', 3),
              _buildNavItem(Icons.person_outline, 'Profile', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, {bool isActive = false}) {
    final isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      borderRadius: VitalityTheme.borderRadiusLg,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? VitalityTheme.primary
                  : VitalityTheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: VitalityTheme.label.copyWith(
                color: isSelected
                    ? VitalityTheme.primary
                    : VitalityTheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}