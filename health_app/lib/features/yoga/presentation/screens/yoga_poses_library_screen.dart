import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/colors.dart';
import '../providers/yoga_provider.dart';

class YogaPosesLibraryScreen extends StatefulWidget {
  const YogaPosesLibraryScreen({super.key});

  @override
  State<YogaPosesLibraryScreen> createState() => _YogaPosesLibraryScreenState();
}

class _YogaPosesLibraryScreenState extends State<YogaPosesLibraryScreen> {
  @override
  void initState() {
    super.initState();
    _loadYogaPoses();
  }

  Future<void> _loadYogaPoses() async {
    final yogaProvider = context.read<YogaProvider>();
    await yogaProvider.fetchYogaPoses();
  }

  @override
  Widget build(BuildContext context) {
    final yogaProvider = context.watch<YogaProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yoga Poses Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadYogaPoses,
          ),
        ],
      ),
      body: yogaProvider.isLoading && yogaProvider.yogaPoses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : yogaProvider.yogaPoses.isEmpty
              ? _buildEmptyState()
              : _buildPosesGrid(yogaProvider),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.self_improvement,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No poses available',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for more yoga poses',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosesGrid(YogaProvider provider) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: provider.yogaPoses.length,
      itemBuilder: (context, index) {
        final pose = provider.yogaPoses[index];
        return _buildPoseCard(pose);
      },
    );
  }

  Widget _buildPoseCard(dynamic pose) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showPoseDetails(pose),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pose Image Placeholder
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.8),
                      AppColors.secondary.withOpacity(0.6),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.self_improvement,
                    size: 48,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ),

            // Pose Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pose['name'] ?? 'Unknown Pose',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildDifficultyBadge(pose['difficulty'] ?? 'Beginner'),
                      const SizedBox(width: 8),
                      _buildDurationBadge(pose['duration'] ?? '30s'),
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

  Widget _buildDifficultyBadge(String difficulty) {
    Color color;
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        color = AppColors.success;
        break;
      case 'intermediate':
        color = AppColors.warning;
        break;
      case 'advanced':
        color = AppColors.error;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDurationBadge(String duration) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        duration,
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showPoseDetails(dynamic pose) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(pose['name'] ?? 'Unknown Pose'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pose Image Placeholder
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.8),
                      AppColors.secondary.withOpacity(0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.self_improvement,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Difficulty and Duration
              Row(
                children: [
                  _buildDifficultyBadge(pose['difficulty'] ?? 'Beginner'),
                  const SizedBox(width: 8),
                  _buildDurationBadge(pose['duration'] ?? '30s'),
                ],
              ),
              const SizedBox(height: 16),

              // Description
              const Text(
                'Description',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                pose['description'] ?? 'No description available',
                style: const TextStyle(fontSize: 12),
              ),

              // Benefits
              if (pose['benefits'] != null && pose['benefits'].isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Benefits',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ...((pose['benefits'] as List<dynamic>).map((benefit) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle, size: 16, color: AppColors.success),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              benefit.toString(),
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
              _showFeatureComingSoon('Pose tutorial');
            },
            child: const Text('View Tutorial'),
          ),
        ],
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