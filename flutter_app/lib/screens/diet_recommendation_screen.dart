import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/diet_model.dart';

/// Example Diet Recommendation Screen
/// Demonstrates diet recommendation API usage
class DietRecommendationScreen extends StatefulWidget {
  const DietRecommendationScreen({super.key});

  @override
  State<DietRecommendationScreen> createState() => _DietRecommendationScreenState();
}

class _DietRecommendationScreenState extends State<DietRecommendationScreen> {
  final _apiService = ApiService();
  final _bmiController = TextEditingController();
  final _ageController = TextEditingController(text: '30');
  String _selectedGender = 'male';
  String _selectedGoal = 'maintenance';

  bool _isLoading = false;
  DietRecommendation? _recommendation;

  @override
  void dispose() {
    _bmiController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _getRecommendation() async {
    if (_bmiController.text.isEmpty) {
      _showError('Please enter your BMI');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.getDietRecommendations(
        bmi: double.parse(_bmiController.text),
        age: int.parse(_ageController.text),
        gender: _selectedGender,
        goal: _selectedGoal,
      );

      if (response.isSuccess && response.data != null) {
        setState(() {
          _recommendation = DietRecommendation.fromJson(
            response.data?['recommendation'] ?? response.data?['data'],
          );
        });
      } else {
        _showError(response.error ?? 'Failed to get recommendation');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diet Recommendations'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _bmiController,
                      decoration: const InputDecoration(
                        labelText: 'BMI',
                        border: OutlineInputBorder(),
                        hintText: '22.5',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _ageController,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    const Text('Gender:'),
                    Row(
                      children: ['male', 'female', 'other'].map((gender) {
                        return Expanded(
                          child: RadioListTile<String>(
                            title: Text(gender.capitalize()),
                            value: gender,
                            groupValue: _selectedGender,
                            onChanged: (value) {
                              setState(() => _selectedGender = value!);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    const Text('Goal:'),
                    DropdownButtonFormField<String>(
                      value: _selectedGoal,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'maintenance',
                          child: Text('Maintain Weight'),
                        ),
                        DropdownMenuItem(
                          value: 'weight_loss',
                          child: Text('Lose Weight'),
                        ),
                        DropdownMenuItem(
                          value: 'weight_gain',
                          child: Text('Gain Weight'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedGoal = value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _getRecommendation,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Get Diet Plan'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Recommendation Result
            if (_recommendation != null) ...[
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.restaurant, size: 32),
                          const SizedBox(width: 12),
                          Text(
                            'Diet Type: ${_recommendation!.dietType.capitalize()}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Daily Calories: ${_recommendation!.dailyCalorieTarget}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        'Water: ${_recommendation!.waterIntakeGlasses} glasses/day',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      _buildMealSection('Breakfast', _recommendation!.mealPlan.breakfast),
                      _buildMealSection('Lunch', _recommendation!.mealPlan.lunch),
                      _buildMealSection('Dinner', _recommendation!.mealPlan.dinner),
                      _buildMealSection('Snacks', _recommendation!.mealPlan.snacks),
                      const SizedBox(height: 16),
                      const Text(
                        'Food Guidelines:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildFoodList('To Eat', _recommendation!.foodGuidelines.toEat, Colors.green),
                      _buildFoodList('To Limit', _recommendation!.foodGuidelines.toLimit, Colors.orange),
                      _buildFoodList('To Avoid', _recommendation!.foodGuidelines.toAvoid, Colors.red),
                      const SizedBox(height: 16),
                      const Text(
                        'Daily Tips:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ..._recommendation!.tips.map((tip) => Padding(
                            padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                            child: Text('• $tip'),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMealSection(String title, Meal meal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ExpansionTile(
        title: Text('$title (${meal.calories} cal)'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(meal.description),
                const SizedBox(height: 8),
                ...meal.items.map((item) => Text('• $item')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodList(String title, List<String> items, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          ...items.take(3).map((item) => Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 2.0),
                child: Text('• $item', style: TextStyle(color: color)),
              )),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
