import 'package:flutter/material.dart';
import '../../../core/themes/vitality_theme.dart';

/// Vitality-style Hero Card Component
/// Recreates the beautiful bento-style hero sections from Vitality app
class VitalityHeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String mainValue;
  final String unit;
  final String status;
  final IconData mainIcon;
  final Color statusColor;
  final List<VitalityMetric> metrics;
  final String description;

  const VitalityHeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.mainValue,
    required this.unit,
    required this.status,
    required this.mainIcon,
    required this.statusColor,
    required this.metrics,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: VitalityTheme.surface,
        borderRadius: VitalityTheme.borderRadiusXl,
        boxShadow: VitalityTheme.shadowMd,
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Opacity(
              opacity: 0.05,
              child: Icon(
                mainIcon,
                size: 120,
                color: VitalityTheme.primary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: VitalityTheme.label.copyWith(
                    color: VitalityTheme.onSurfaceVariant,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      mainValue,
                      style: VitalityTheme.h1.copyWith(
                        color: VitalityTheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 56,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      unit,
                      style: VitalityTheme.h3.copyWith(
                        color: VitalityTheme.onSurfaceVariant,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: VitalityTheme.borderRadiusMd,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        status,
                        style: VitalityTheme.label.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  description,
                  style: VitalityTheme.body.copyWith(
                    color: VitalityTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: metrics.map((metric) {
                    return Expanded(
                      child: _buildMetricStat(
                        metric.value,
                        metric.label,
                        metric.icon,
                        metric.color,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricStat(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: VitalityTheme.borderRadiusLg,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 16),
          Text(
            value,
            style: VitalityTheme.h4.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: VitalityTheme.bodySmall.copyWith(
              color: VitalityTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class VitalityMetric {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  VitalityMetric({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
}