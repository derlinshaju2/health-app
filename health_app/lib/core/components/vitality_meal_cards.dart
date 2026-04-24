import 'package:flutter/material.dart';
import '../../../core/themes/vitality_theme.dart';

/// Vitality-style Meal Plan Card
/// Recreates the beautiful meal cards from Vitality app with images
class VitalityMealCard extends StatelessWidget {
  final String mealType;
  final String mealTime;
  final String title;
  final String description;
  final String imageUrl;
  final int calories;
  final String protein;
  final String carbs;
  final String fats;
  final String otherInfo;
  final Color themeColor;

  const VitalityMealCard({
    super.key,
    required this.mealType,
    required this.mealTime,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.otherInfo,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
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
      child: ClipRRect(
        borderRadius: VitalityTheme.borderRadiusXl,
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Meal Image
              Expanded(
                flex: 3,
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
                          size: 64,
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
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Meal Info
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Meal Type Badge & Time
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: themeColor.withOpacity(0.15),
                              borderRadius: VitalityTheme.borderRadiusMd,
                            ),
                            child: Text(
                              mealType,
                              style: VitalityTheme.label.copyWith(
                                color: themeColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: VitalityTheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            mealTime,
                            style: VitalityTheme.bodySmall.copyWith(
                              color: VitalityTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Title
                      Text(
                        title,
                        style: VitalityTheme.h3.copyWith(
                          color: VitalityTheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Description
                      Text(
                        description,
                        style: VitalityTheme.body.copyWith(
                          color: VitalityTheme.onSurfaceVariant,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 24),
                      // Nutrition Info
                      Row(
                        children: [
                          _buildNutritionFact(
                            calories.toString(),
                            'Calories',
                            themeColor,
                          ),
                          const SizedBox(width: 24),
                          Container(
                            height: 32,
                            width: 1,
                            color: VitalityTheme.surfaceVariant,
                          ),
                          const SizedBox(width: 24),
                          _buildNutritionFact(
                            protein,
                            'Protein',
                            themeColor,
                          ),
                          const SizedBox(width: 24),
                          Container(
                            height: 32,
                            width: 1,
                            color: VitalityTheme.surfaceVariant,
                          ),
                          const SizedBox(width: 24),
                          _buildNutritionFact(
                            carbs,
                            'Carbs',
                            themeColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionFact(String value, String label, Color color) {
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
}

/// Vitality-style Health Metric Card
/// Modern card with icon, value, and status
class VitalityMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final String status;
  final IconData icon;
  final Color statusColor;
  final VoidCallback? onTap;

  const VitalityMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.status,
    required this.icon,
    required this.statusColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: VitalityTheme.borderRadiusLg,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: VitalityTheme.surface,
          borderRadius: VitalityTheme.borderRadiusLg,
          border: Border.all(
            color: VitalityTheme.surfaceVariant,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: statusColor, size: 28),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: VitalityTheme.borderRadiusSm,
                  ),
                  child: Text(
                    status,
                    style: VitalityTheme.tiny.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: VitalityTheme.h4.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              unit,
              style: VitalityTheme.bodySmall.copyWith(
                color: VitalityTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: VitalityTheme.bodySmall.copyWith(
                color: VitalityTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Vitality-style Progress Card
/// Modern progress tracking with circular progress
class VitalityProgressCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final int daysCompleted;
  final int totalDays;
  final IconData icon;
  final Color themeColor;

  const VitalityProgressCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.daysCompleted,
    required this.totalDays,
    required this.icon,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: VitalityTheme.surface,
        borderRadius: VitalityTheme.borderRadiusLg,
        border: Border.all(
          color: VitalityTheme.surfaceVariant,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: VitalityTheme.bodySmall.copyWith(
                    color: VitalityTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: VitalityTheme.h4.copyWith(
                    color: VitalityTheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                // Progress bar
                ClipRRect(
                  borderRadius: VitalityTheme.borderRadiusSm,
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: VitalityTheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Circular progress
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: progress,
                  backgroundColor: VitalityTheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                  strokeWidth: 8,
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Text(
                    '${daysCompleted}d',
                    style: VitalityTheme.label.copyWith(
                      color: themeColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}