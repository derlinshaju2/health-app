import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/colors.dart';
import '../providers/yoga_provider.dart';

class YogaProgressScreen extends StatefulWidget {
  const YogaProgressScreen({super.key});

  @override
  State<YogaProgressScreen> createState() => _YogaProgressScreenState();
}

class _YogaProgressScreenState extends State<YogaProgressScreen> {
  String _selectedPeriod = 'week';

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    final yogaProvider = context.read<YogaProvider>();
    await yogaProvider.fetchYogaSessions(_selectedPeriod);

    // Fetch progress for current user (mock user ID for now)
    await yogaProvider.fetchYogaProgress('user123');
  }

  @override
  Widget build(BuildContext context) {
    final yogaProvider = context.watch<YogaProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yoga Progress'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (period) {
              setState(() {
                _selectedPeriod = period;
              });
              _loadProgressData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'week', child: Text('This Week')),
              const PopupMenuItem(value: 'month', child: Text('This Month')),
              const PopupMenuItem(value: 'year', child: Text('This Year')),
            ],
          ),
        ],
      ),
      body: yogaProvider.isLoading && yogaProvider.yogaSessions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : yogaProvider.yogaSessions.isEmpty
              ? _buildEmptyState()
              : _buildProgressContent(yogaProvider),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No progress data yet',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your first yoga session to see progress',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressContent(YogaProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Overview Cards
          _buildProgressOverview(provider),
          const SizedBox(height: 20),

          // Achievement Badges
          _buildAchievementsSection(provider),
          const SizedBox(height: 20),

          // Sessions History
          _buildSessionsHistory(provider),
        ],
      ),
    );
  }

  Widget _buildProgressOverview(YogaProvider provider) {
    // Calculate stats from sessions
    int totalSessions = provider.yogaSessions.length;
    int totalMinutes = provider.yogaSessions.fold<int>(
      0,
      (sum, session) => sum + (session['duration'] as int? ?? 0),
    );
    int totalCalories = provider.yogaSessions.fold<int>(
      0,
      (sum, session) => sum + (session['caloriesBurned'] as int? ?? 0),
    );

    // Calculate streak (mock implementation)
    int currentStreak = 3; // Mock streak

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progress Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildStatCard(
              'Total Sessions',
              '$totalSessions',
              Icons.event,
              AppColors.primary,
            ),
            _buildStatCard(
              'Total Minutes',
              '$totalMinutes',
              Icons.timer,
              AppColors.secondary,
            ),
            _buildStatCard(
              'Calories Burned',
              '$totalCalories',
              Icons.local_fire_department,
              AppColors.accent,
            ),
            _buildStatCard(
              'Current Streak',
              '$currentStreak days',
              Icons.whatshot,
              Colors.orange,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(YogaProvider provider) {
    // Mock achievements based on progress
    final achievements = [
      {
        'title': 'First Session',
        'description': 'Completed your first yoga session',
        'icon': Icons.looks_one,
        'color': AppColors.success,
        'unlocked': true,
      },
      {
        'title': 'Week Warrior',
        'description': 'Completed 7 sessions in a week',
        'icon': Icons.calendar_today,
        'color': AppColors.primary,
        'unlocked': provider.yogaSessions.length >= 7,
      },
      {
        'title': 'Month Master',
        'description': 'Practiced yoga for 30 days',
        'icon': Icons.emoji_events,
        'color': AppColors.secondary,
        'unlocked': provider.yogaSessions.length >= 30,
      },
      {
        'title': 'Calorie Crusher',
        'description': 'Burned 1000+ calories',
        'icon': Icons.local_fire_department,
        'color': AppColors.accent,
        'unlocked': provider.yogaSessions.fold<int>(
              0,
              (sum, session) => sum + (session['caloriesBurned'] as int? ?? 0),
            ) >=
            1000,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Achievements',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...achievements.map((achievement) => _buildAchievementCard(achievement)),
      ],
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    final isUnlocked = achievement['unlocked'] as bool;

    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.6,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: (achievement['color'] as Color).withOpacity(isUnlocked ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            achievement['icon'] as IconData,
            color: isUnlocked ? achievement['color'] as Color : Colors.grey,
            size: 28,
          ),
        ),
        title: Text(
          achievement['title'] as String,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isUnlocked ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Text(
          achievement['description'] as String,
          style: TextStyle(
            fontSize: 12,
            color: isUnlocked ? Colors.grey[700] : Colors.grey[500],
          ),
        ),
        trailing: isUnlocked
            ? const Icon(Icons.check_circle, color: AppColors.success)
            : const Icon(Icons.lock, color: Colors.grey),
      ),
      ),
    );
  }

  Widget _buildSessionsHistory(YogaProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Session History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Show full history in a separate screen
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...provider.yogaSessions.take(5).map((session) => _buildSessionHistoryItem(session)),
      ],
    );
  }

  Widget _buildSessionHistoryItem(dynamic session) {
    final date = DateTime.parse(session['date']);
    final formattedDate = '${date.month}/${date.day}/${date.year}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Date Indicator
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${date.day}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    _getMonthAbbreviation(date.month),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Session Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session['routineType'] ?? 'Yoga Session',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
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

            // Stats
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer, size: 14, color: AppColors.secondary),
                    const SizedBox(width: 4),
                    Text(
                      '${session['duration'] ?? 0} min',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department, size: 14, color: AppColors.accent),
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
          ],
        ),
      ),
    );
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}