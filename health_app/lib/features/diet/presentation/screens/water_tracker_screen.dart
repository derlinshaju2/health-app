import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/colors.dart';
import '../providers/diet_provider.dart';

class WaterTrackerScreen extends StatefulWidget {
  const WaterTrackerScreen({super.key});

  @override
  State<WaterTrackerScreen> createState() => _WaterTrackerScreenState();
}

class _WaterTrackerScreenState extends State<WaterTrackerScreen> {
  static const int dailyGoal = 8;

  @override
  Widget build(BuildContext context) {
    final dietProvider = context.watch<DietProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Tracker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Water Intake Visualization
            _buildWaterIntakeWidget(dietProvider.waterIntake),
            const SizedBox(height: 40),

            // Current Intake Text
            Text(
              '${dietProvider.waterIntake}/$dailyGoal glasses',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),

            // Progress Text
            Text(
              _getProgressMessage(dietProvider.waterIntake),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Add/Remove Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: Icons.remove,
                  color: Colors.red,
                  onPressed: dietProvider.waterIntake > 0
                      ? () => _removeWater(dietProvider)
                      : null,
                ),
                const SizedBox(width: 40),
                _buildControlButton(
                  icon: Icons.add,
                  color: Colors.blue,
                  onPressed: () => _addWater(dietProvider),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Goal Progress
            _buildGoalProgress(dietProvider.waterIntake),
            const SizedBox(height: 40),

            // Reset Button
            ElevatedButton.icon(
              onPressed: () => _resetWater(dietProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Today\'s Progress'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[400],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterIntakeWidget(int intake) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background Circle
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue[50],
            border: Border.all(
              color: Colors.blue[200]!,
              width: 2,
            ),
          ),
        ),

        // Water Fill
        SizedBox(
          width: 200,
          height: 200,
          child: CircularProgressIndicator(
            value: intake / dailyGoal,
            strokeWidth: 15,
            backgroundColor: Colors.blue[50],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressColor(intake),
            ),
          ),
        ),

        // Center Icon and Text
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_drink,
              size: 60,
              color: _getProgressColor(intake),
            ),
            const SizedBox(height: 8),
            Text(
              '$intake',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: _getProgressColor(intake),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
        border: Border.all(
          color: color,
          width: 2,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, size: 40),
        color: color,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildGoalProgress(int intake) {
    final progress = intake / dailyGoal;
    final percentage = (progress * 100).toInt();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daily Goal Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getProgressColor(intake),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(intake),
              ),
              minHeight: 10,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '0 glasses',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '$dailyGoal glasses',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(int intake) {
    final progress = intake / dailyGoal;
    if (progress < 0.25) return Colors.red;
    if (progress < 0.5) return Colors.orange;
    if (progress < 0.75) return Colors.yellow[700]!;
    return Colors.green;
  }

  String _getProgressMessage(int intake) {
    final progress = intake / dailyGoal;
    if (progress == 0) return 'Start tracking your water intake!';
    if (progress < 0.25) return 'Good start! Keep drinking water.';
    if (progress < 0.5) return 'You\'re making progress!';
    if (progress < 0.75) return 'Great job! Almost there!';
    if (progress < 1.0) return 'Just a few more glasses to go!';
    return 'Congratulations! You\'ve reached your daily goal! 🎉';
  }

  void _addWater(DietProvider provider) {
    if (provider.waterIntake < dailyGoal) {
      provider.incrementWaterIntake();
      _showFeedback('Water added!', Colors.blue);
    } else {
      _showFeedback('Daily goal reached! 🎉', Colors.green);
    }
  }

  void _removeWater(DietProvider provider) {
    if (provider.waterIntake > 0) {
      provider.updateWaterIntake(provider.waterIntake - 1);
      _showFeedback('Water removed', Colors.red);
    }
  }

  void _resetWater(DietProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Water Intake'),
        content: const Text('Are you sure you want to reset today\'s progress?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.updateWaterIntake(0);
              Navigator.pop(context);
              _showFeedback('Progress reset', Colors.grey);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showFeedback(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}