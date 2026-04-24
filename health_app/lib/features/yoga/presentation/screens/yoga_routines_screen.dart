import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/colors.dart';
import '../providers/yoga_provider.dart';

class YogaRoutinesScreen extends StatefulWidget {
  const YogaRoutinesScreen({super.key});

  @override
  State<YogaRoutinesScreen> createState() => _YogaRoutinesScreenState();
}

class _YogaRoutinesScreenState extends State<YogaRoutinesScreen> {
  @override
  void initState() {
    super.initState();
    _loadRoutines();
  }

  Future<void> _loadRoutines() async {
    final yogaProvider = context.read<YogaProvider>();
    await yogaProvider.fetchYogaRoutines();
  }

  @override
  Widget build(BuildContext context) {
    final yogaProvider = context.watch<YogaProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yoga Routines'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRoutines,
          ),
        ],
      ),
      body: yogaProvider.isLoading && yogaProvider.yogaRoutines.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : yogaProvider.yogaRoutines.isEmpty
              ? _buildEmptyState()
              : _buildRoutinesList(yogaProvider),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No routines available',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your own routine or check back later',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutinesList(YogaProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.yogaRoutines.length,
      itemBuilder: (context, index) {
        final routine = provider.yogaRoutines[index];
        return _buildRoutineCard(routine);
      },
    );
  }

  Widget _buildRoutineCard(dynamic routine) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showRoutineDetails(routine),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Routine Header Image
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getRoutineColor(routine['difficulty'] ?? 'Beginner'),
                    _getRoutineColor(routine['difficulty'] ?? 'Beginner').withOpacity(0.7),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        routine['difficulty'] ?? 'Beginner',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          routine['duration'] ?? '30 min',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Routine Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routine['name'] ?? 'Unknown Routine',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    routine['description'] ?? 'No description available',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Routine Stats
                  Row(
                    children: [
                      _buildRoutineStat(
                        'Poses',
                        '${routine['poseCount'] ?? 5}',
                        Icons.self_improvement,
                      ),
                      const SizedBox(width: 16),
                      _buildRoutineStat(
                        'Calories',
                        '${routine['caloriesBurned'] ?? 100}',
                        Icons.local_fire_department,
                      ),
                      const SizedBox(width: 16),
                      _buildRoutineStat(
                        'Level',
                        routine['difficulty'] ?? 'Beginner',
                        Icons.signal_cellular_alt,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getRoutineColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return AppColors.success;
      case 'intermediate':
        return AppColors.warning;
      case 'advanced':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  void _showRoutineDetails(dynamic routine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(routine['name'] ?? 'Unknown Routine'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Routine Image
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getRoutineColor(routine['difficulty'] ?? 'Beginner'),
                      _getRoutineColor(routine['difficulty'] ?? 'Beginner').withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    Icons.fitness_center,
                    size: 64,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                routine['description'] ?? 'No description available',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),

              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDetailStat('Duration', routine['duration'] ?? '30 min', Icons.timer),
                  _buildDetailStat('Poses', '${routine['poseCount'] ?? 5}', Icons.self_improvement),
                  _buildDetailStat('Calories', '${routine['caloriesBurned'] ?? 100}', Icons.local_fire_department),
                ],
              ),

              // Poses List
              if (routine['poses'] != null && routine['poses'].isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Poses in this routine:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ...((routine['poses'] as List<dynamic>).map((pose) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, size: 6, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              pose.toString(),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ))),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startRoutine(routine);
            },
            child: const Text('Start Routine'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _startRoutine(dynamic routine) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting ${routine['name']} routine...'),
        backgroundColor: AppColors.success,
      ),
    );
    // TODO: Navigate to yoga session screen with pre-selected routine
  }
}