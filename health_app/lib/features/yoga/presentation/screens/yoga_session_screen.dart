import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/colors.dart';
import '../providers/yoga_provider.dart';
import 'yoga_poses_library_screen.dart';
import 'yoga_routines_screen.dart';
import 'yoga_progress_screen.dart';

class YogaSessionScreen extends StatefulWidget {
  const YogaSessionScreen({super.key});

  @override
  State<YogaSessionScreen> createState() => _YogaSessionScreenState();
}

class _YogaSessionScreenState extends State<YogaSessionScreen> {
  Timer? _timer;
  int _sessionDuration = 0;
  bool _sessionActive = false;
  String _selectedRoutine = 'Morning Stretch';

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final yogaProvider = context.watch<YogaProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yoga & Fitness'),
      ),
      body: yogaProvider.isLoading && yogaProvider.yogaSessions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Session Timer Card
                  if (_sessionActive) _buildActiveSessionCard(yogaProvider) else _buildStartSessionCard(),
                  const SizedBox(height: 20),

                  // Quick Actions
                  _buildQuickActions(),
                  const SizedBox(height: 20),

                  // Today's Stats
                  _buildTodayStatsCard(yogaProvider),
                  const SizedBox(height: 20),

                  // Recent Sessions
                  _buildRecentSessionsCard(yogaProvider),
                ],
              ),
            ),
    );
  }

  Widget _buildActiveSessionCard(YogaProvider provider) {
    final minutes = _sessionDuration ~/ 60;
    final seconds = _sessionDuration % 60;

    return Card(
      elevation: 4,
      color: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Active Session',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedRoutine,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pauseSession(),
                  icon: const Icon(Icons.pause),
                  label: const Text('Pause'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _completeSession(provider),
                  icon: const Icon(Icons.stop),
                  label: const Text('Complete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartSessionCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Start Yoga Session',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRoutine,
              decoration: const InputDecoration(
                labelText: 'Select Routine',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Morning Stretch', child: Text('Morning Stretch')),
                DropdownMenuItem(value: 'Evening Relax', child: Text('Evening Relax')),
                DropdownMenuItem(value: 'Power Yoga', child: Text('Power Yoga')),
                DropdownMenuItem(value: 'Meditation', child: Text('Meditation')),
                DropdownMenuItem(value: 'Custom', child: Text('Custom Session')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRoutine = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _startSession(),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Session'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
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
              'Poses Library',
              Icons.self_improvement,
              AppColors.primary,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const YogaPosesLibraryScreen()),
              ),
            ),
            _buildActionButton(
              'Routines',
              Icons.fitness_center,
              AppColors.secondary,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const YogaRoutinesScreen()),
              ),
            ),
            _buildActionButton(
              'Progress',
              Icons.trending_up,
              AppColors.success,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const YogaProgressScreen()),
              ),
            ),
            _buildActionButton(
              'History',
              Icons.history,
              AppColors.accent,
              () => _showFeatureComingSoon('Session history'),
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

  Widget _buildTodayStatsCard(YogaProvider provider) {
    // Mock stats - in real app, calculate from provider data
    final todaySessions = provider.yogaSessions.where((session) {
      final sessionDate = DateTime.parse(session['date']);
      return sessionDate.day == DateTime.now().day &&
          sessionDate.month == DateTime.now().month &&
          sessionDate.year == DateTime.now().year;
    }).length;

    final totalMinutes = provider.yogaSessions.where((session) {
      final sessionDate = DateTime.parse(session['date']);
      return sessionDate.day == DateTime.now().day &&
          sessionDate.month == DateTime.now().month &&
          sessionDate.year == DateTime.now().year;
    }).fold<int>(0, (sum, session) => sum + (session['duration'] as int? ?? 0));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Stats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Sessions',
                  '$todaySessions',
                  Icons.event,
                  AppColors.primary,
                ),
                _buildStatItem(
                  'Minutes',
                  '$totalMinutes',
                  Icons.timer,
                  AppColors.secondary,
                ),
                _buildStatItem(
                  'Calories',
                  '${totalMinutes * 3}', // Approximate calorie burn
                  Icons.local_fire_department,
                  AppColors.accent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSessionsCard(YogaProvider provider) {
    final recentSessions = provider.yogaSessions.take(3).toList();

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
                  'Recent Sessions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const YogaProgressScreen()),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentSessions.isEmpty)
              const Center(
                child: Text('No sessions yet. Start your first session!'),
              )
            else
              ...recentSessions.map((session) => _buildSessionItem(session)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionItem(dynamic session) {
    final date = DateTime.parse(session['date']);
    final formattedDate = '${date.month}/${date.day}/${date.year}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session['routineType'] ?? 'Yoga Session',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(Icons.timer, size: 16, color: AppColors.secondary),
              const SizedBox(width: 4),
              Text(
                '${session['duration'] ?? 0} min',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.local_fire_department, size: 16, color: AppColors.accent),
              const SizedBox(width: 4),
              Text(
                '${session['caloriesBurned'] ?? 0} cal',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _startSession() {
    setState(() {
      _sessionActive = true;
      _sessionDuration = 0;
    });

    // Start timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _sessionDuration++;
      });

      // Update provider
      context.read<YogaProvider>().updateSessionDuration(_sessionDuration);
    });

    // Start session in background
    context.read<YogaProvider>().startYogaSession({
      'routineType': _selectedRoutine,
      'startTime': DateTime.now().toIso8601String(),
    });
  }

  void _pauseSession() {
    _timer?.cancel();
    setState(() {
      _sessionActive = false;
    });
  }

  void _completeSession(YogaProvider provider) {
    _timer?.cancel();
    provider.completeYogaSession('current', {
      'duration': _sessionDuration ~/ 60,
      'caloriesBurned': (_sessionDuration ~/ 60) * 3,
      'completedAt': DateTime.now().toIso8601String(),
    });

    setState(() {
      _sessionActive = false;
      _sessionDuration = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session completed! Great job! 🎉'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showFeatureComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}