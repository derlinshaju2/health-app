import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/yoga_model.dart';

/// Example Yoga Recommendation Screen
/// Demonstrates yoga recommendation API usage
class YogaRecommendationScreen extends StatefulWidget {
  const YogaRecommendationScreen({super.key});

  @override
  State<YogaRecommendationScreen> createState() => _YogaRecommendationScreenState();
}

class _YogaRecommendationScreenState extends State<YogaRecommendationScreen> {
  final _apiService = ApiService();
  final _ageController = TextEditingController(text: '30');
  String _selectedLevel = 'beginner';
  String _selectedGoal = 'general';

  bool _isLoading = false;
  YogaRecommendation? _recommendation;

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _getRecommendation() async {
    setState(() => _isLoading = true);

    try {
      final response = await _apiService.getYogaRecommendations(
        fitnessLevel: _selectedLevel,
        age: int.parse(_ageController.text),
        goal: _selectedGoal,
      );

      if (response.isSuccess && response.data != null) {
        setState(() {
          _recommendation = YogaRecommendation.fromJson(
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
        title: const Text('Yoga Recommendations'),
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
                      'Your Fitness Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _ageController,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    const Text('Fitness Level:'),
                    Row(
                      children: ['beginner', 'intermediate', 'advanced'].map((level) {
                        return Expanded(
                          child: RadioListTile<String>(
                            title: Text(level.capitalize()),
                            value: level,
                            groupValue: _selectedLevel,
                            onChanged: (value) {
                              setState(() => _selectedLevel = value!);
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
                        DropdownMenuItem(value: 'general', child: Text('General Wellness')),
                        DropdownMenuItem(value: 'flexibility', child: Text('Improve Flexibility')),
                        DropdownMenuItem(value: 'strength', child: Text('Build Strength')),
                        DropdownMenuItem(value: 'weight_loss', child: Text('Weight Loss')),
                        DropdownMenuItem(value: 'stress_relief', child: Text('Stress Relief')),
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
                            : const Text('Get Yoga Plan'),
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
                          const Icon(Icons.self_improvement, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Yoga Routine - ${_recommendation!.fitnessLevel.capitalize()} Level',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Duration: ${_recommendation!.routine.totalDurationMinutes} minutes',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPoseSection('Warm-up', _recommendation!.routine.warmup),
                      _buildPoseSection('Main Poses', _recommendation!.routine.mainPoses),
                      _buildBreathingSection('Breathing Exercises', _recommendation!.routine.breathing),
                      _buildPoseSection('Cool-down', _recommendation!.routine.cooldown),
                      const SizedBox(height: 16),
                      const Text(
                        'Weekly Schedule:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ..._recommendation!.weeklySchedule.map((day) => Padding(
                            padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                            child: Text('• $day'),
                          )),
                      const SizedBox(height: 16),
                      const Text(
                        'Precautions:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      ..._recommendation!.precautions.take(3).map((precaution) => Padding(
                            padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                            child: Text('• $precaution'),
                          )),
                      const SizedBox(height: 16),
                      const Text(
                        'Practice Tips:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      ..._recommendation!.tips.take(3).map((tip) => Padding(
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

  Widget _buildPoseSection(String title, List<YogaPose> poses) {
    if (poses.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ExpansionTile(
        title: Text('$title (${poses.length} exercises)'),
        children: poses.map((pose) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pose.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${pose.description} • ${pose.duration}',
                  style: const TextStyle(fontSize: 14),
                ),
                if (pose.benefits.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Benefits: ${pose.benefits.join(", ")}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBreathingSection(String title, List<BreathingExercise> exercises) {
    if (exercises.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ExpansionTile(
        title: Text('$title (${exercises.length} exercises)'),
        children: exercises.map((exercise) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${exercise.description} • ${exercise.durationSeconds} seconds',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
