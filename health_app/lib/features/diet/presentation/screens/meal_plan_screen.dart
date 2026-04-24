import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/colors.dart';
import '../providers/diet_provider.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadMealPlan();
  }

  Future<void> _loadMealPlan() async {
    final dateString = _selectedDate.toIso8601String().split('T')[0];
    final dietProvider = context.read<DietProvider>();
    await dietProvider.fetchMealPlan(dateString);
  }

  @override
  Widget build(BuildContext context) {
    final dietProvider = context.watch<DietProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: dietProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : dietProvider.mealPlan == null
              ? _buildEmptyState()
              : _buildMealPlanContent(dietProvider),
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
            'No meal plan for this date',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try selecting a different date or check back later',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealPlanContent(DietProvider provider) {
    final mealPlan = provider.mealPlan!;
    final meals = mealPlan['meals'] as List<dynamic>?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Header
          _buildDateHeader(),
          const SizedBox(height: 20),

          // Daily Summary
          _buildDailySummary(mealPlan),
          const SizedBox(height: 20),

          // Meals List
          if (meals != null && meals.isNotEmpty)
            ...meals.map((meal) => _buildMealCard(meal)).toList()
          else
            const Center(
              child: Text('No meals planned for this date'),
            ),
        ],
      ),
    );
  }

  Widget _buildDateHeader() {
    return Card(
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meal Plan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(_selectedDate),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.calendar_today, color: Colors.white),
              onPressed: _selectDate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailySummary(Map<String, dynamic> mealPlan) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  'Calories',
                  '${mealPlan['totalCalories'] ?? 0} kcal',
                  Icons.local_fire_department,
                  AppColors.primary,
                ),
                _buildSummaryItem(
                  'Protein',
                  '${mealPlan['totalProtein'] ?? 0}g',
                  Icons.fitness_center,
                  AppColors.secondary,
                ),
                _buildSummaryItem(
                  'Carbs',
                  '${mealPlan['totalCarbs'] ?? 0}g',
                  Icons.grain,
                  AppColors.accent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
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
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard(dynamic meal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  meal['name'] ?? 'Meal',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getMealTypeColor(meal['type']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    meal['type'] ?? 'Meal',
                    style: TextStyle(
                      color: _getMealTypeColor(meal['type']),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              meal['description'] ?? 'No description available',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildNutrientChip('Calories', '${meal['calories'] ?? 0} kcal'),
                _buildNutrientChip('Protein', '${meal['protein'] ?? 0}g'),
                _buildNutrientChip('Carbs', '${meal['carbs'] ?? 0}g'),
                _buildNutrientChip('Fats', '${meal['fats'] ?? 0}g'),
              ],
            ),
            if (meal['foods'] != null && meal['foods'].isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Foods:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              ...((meal['foods'] as List<dynamic>).map((food) => Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 6, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            food.toString(),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ))),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Color _getMealTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return Colors.green;
      case 'dinner':
        return Colors.purple;
      case 'snack':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadMealPlan();
    }
  }
}