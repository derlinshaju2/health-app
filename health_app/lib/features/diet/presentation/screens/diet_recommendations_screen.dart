import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/colors.dart';
import '../providers/diet_provider.dart';
import 'meal_plan_screen.dart';
import 'food_log_screen.dart';
import 'water_tracker_screen.dart';

class DietRecommendationsScreen extends StatefulWidget {
  const DietRecommendationsScreen({super.key});

  @override
  State<DietRecommendationsScreen> createState() => _DietRecommendationsScreenState();
}

class _DietRecommendationsScreenState extends State<DietRecommendationsScreen> {
  @override
  void initState() {
    super.initState();
    _loadDietData();
  }

  Future<void> _loadDietData() async {
    final dietProvider = context.read<DietProvider>();
    await dietProvider.fetchRecommendations();
  }

  @override
  Widget build(BuildContext context) {
    final dietProvider = context.watch<DietProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diet & Nutrition'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDietData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDietData,
        child: dietProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : dietProvider.recommendations == null
                ? _buildEmptyState()
                : _buildDietContent(dietProvider),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No diet data yet',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your profile to get personalized recommendations',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDietContent(DietProvider provider) {
    final recommendations = provider.recommendations!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Daily Calorie Target Card
          _buildCalorieCard(recommendations),
          const SizedBox(height: 20),

          // Macro Nutrients Card
          _buildMacroCard(recommendations),
          const SizedBox(height: 20),

          // Quick Actions
          _buildQuickActions(),
          const SizedBox(height: 20),

          // Diet Recommendations
          _buildRecommendationsCard(recommendations),
          const SizedBox(height: 20),

          // Water Intake Tracker
          _buildWaterIntakeCard(provider),
        ],
      ),
    );
  }

  Widget _buildCalorieCard(Map<String, dynamic> recommendations) {
    final dailyCalories = recommendations['dailyCalories'] ?? 2000;
    final currentCalories = recommendations['currentCalories'] ?? 0;
    final remaining = dailyCalories - currentCalories;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daily Calories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$dailyCalories kcal',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: currentCalories / dailyCalories,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                remaining > 0 ? AppColors.success : AppColors.error,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCalorieStat('Consumed', '$currentCalories', AppColors.primary),
                _buildCalorieStat('Remaining', '$remaining', AppColors.success),
                _buildCalorieStat('Daily', '$dailyCalories', Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroCard(Map<String, dynamic> recommendations) {
    final macros = recommendations['macros'] ?? {};

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Macro Nutrients',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMacroItem(
                    'Protein',
                    macros['protein']?.toString() ?? '0g',
                    AppColors.primary,
                    Icons.fitness_center,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMacroItem(
                    'Carbs',
                    macros['carbs']?.toString() ?? '0g',
                    AppColors.secondary,
                    Icons.grain,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMacroItem(
                    'Fats',
                    macros['fats']?.toString() ?? '0g',
                    AppColors.accent,
                    Icons.water_drop,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroItem(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
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
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
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
              'Meal Plan',
              Icons.calendar_today,
              AppColors.primary,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MealPlanScreen()),
              ),
            ),
            _buildActionButton(
              'Food Log',
              Icons.add_circle,
              AppColors.secondary,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FoodLogScreen()),
              ),
            ),
            _buildActionButton(
              'Water Tracker',
              Icons.local_drink,
              Colors.blue,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WaterTrackerScreen()),
              ),
            ),
            _buildActionButton(
              'Diet Tips',
              Icons.lightbulb_outline,
              AppColors.accent,
              () {
                // Show diet tips dialog
                _showDietTips();
              },
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

  Widget _buildRecommendationsCard(Map<String, dynamic> recommendations) {
    final tips = recommendations['tips'] as List<dynamic>?;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personalized Recommendations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (tips != null && tips.isNotEmpty)
              ...tips.map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tip.toString(),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ))
            else
              const Text('No recommendations available yet.'),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterIntakeCard(DietProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Water Intake',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${provider.waterIntake} glasses',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      provider.incrementWaterIntake();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Glass'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDietTips() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Diet Tips'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TipItem(
                'Eat a variety of foods',
                'Include fruits, vegetables, whole grains, and proteins in your diet.',
              ),
              TipItem(
                'Stay hydrated',
                'Drink at least 8 glasses of water per day.',
              ),
              TipItem(
                'Control portion sizes',
                'Use smaller plates and listen to your body\'s hunger signals.',
              ),
              TipItem(
                'Limit processed foods',
                'Choose fresh, whole foods over packaged alternatives.',
              ),
              TipItem(
                'Plan your meals',
                'Prepare meals in advance to avoid unhealthy choices.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class TipItem extends StatelessWidget {
  final String title;
  final String description;

  const TipItem(this.title, this.description, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}