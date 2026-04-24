import 'package:flutter/material.dart';
import '../themes/shadcn_theme.dart';

/// Shadcn-style Badge Component
/// Small status indicators and labels
class ShadcnBadge extends StatelessWidget {
  final String label;
  final ShadcnBadgeVariant variant;
  final bool outline;
  final IconData? icon;
  final VoidCallback? onTap;

  const ShadcnBadge({
    super.key,
    required this.label,
    this.variant = ShadcnBadgeVariant.default_,
    this.outline = false,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getBadgeColors();

    Widget badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: outline ? Colors.transparent : colors.backgroundColor,
        border: Border.all(
          color: colors.borderColor,
          width: 1,
        ),
        borderRadius: ShadcnTheme.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: colors.textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: ShadcnTheme.tiny.copyWith(
              color: colors.textColor,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: ShadcnTheme.borderRadiusSm,
          child: badge,
        ),
      );
    }

    return badge;
  }

  _BadgeColors _getBadgeColors() {
    switch (variant) {
      case ShadcnBadgeVariant.default_:
        return _BadgeColors(
          backgroundColor: ShadcnTheme.primary,
          textColor: ShadcnTheme.primaryForeground,
          borderColor: ShadcnTheme.primary,
        );
      case ShadcnBadgeVariant.secondary:
        return _BadgeColors(
          backgroundColor: ShadcnTheme.secondary,
          textColor: ShadcnTheme.secondaryForeground,
          borderColor: ShadcnTheme.secondary,
        );
      case ShadcnBadgeVariant.success:
        return _BadgeColors(
          backgroundColor: ShadcnTheme.healthExcellent,
          textColor: ShadcnTheme.destructiveForeground,
          borderColor: ShadcnTheme.healthExcellent,
        );
      case ShadcnBadgeVariant.warning:
        return _BadgeColors(
          backgroundColor: ShadcnTheme.warning,
          textColor: ShadcnTheme.destructiveForeground,
          borderColor: ShadcnTheme.warning,
        );
      case ShadcnBadgeVariant.destructive:
        return _BadgeColors(
          backgroundColor: ShadcnTheme.destructive,
          textColor: ShadcnTheme.destructiveForeground,
          borderColor: ShadcnTheme.destructive,
        );
      case ShadcnBadgeVariant.outline:
        return _BadgeColors(
          backgroundColor: Colors.transparent,
          textColor: ShadcnTheme.foreground,
          borderColor: ShadcnTheme.border,
        );
    }
  }
}

enum ShadcnBadgeVariant { default_, secondary, success, warning, destructive, outline }

class _BadgeColors {
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  _BadgeColors({
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });
}

/// Shadcn-style Avatar Component
class ShadcnAvatar extends StatelessWidget {
  final String? name;
  final String? imageUrl;
  final double size;
  final Color? backgroundColor;

  const ShadcnAvatar({
    super.key,
    this.name,
    this.imageUrl,
    this.size = 40,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? ShadcnTheme.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: imageUrl != null
          ? ClipOval(
              child: Image.network(
                imageUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildInitials();
                },
              ),
            )
          : _buildInitials(),
    );
  }

  Widget _buildInitials() {
    if (name == null || name!.isEmpty) {
      return Icon(
        Icons.person,
        size: size * 0.6,
        color: ShadcnTheme.primary.withOpacity(0.6),
      );
    }

    final initials = name!
        .split(' ')
        .take(2)
        .map((word) => word[0].toUpperCase())
        .join();

    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: ShadcnTheme.primary,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Shadcn-style Progress Indicator
class ShadcnProgress extends StatelessWidget {
  final double value;
  final String? label;
  final String? description;
  final ShadcnProgressVariant variant;

  const ShadcnProgress({
    super.key,
    required this.value,
    this.label,
    this.description,
    this.variant = ShadcnProgressVariant.default_,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getProgressColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label!,
                style: ShadcnTheme.small.copyWith(
                  fontWeight: FontWeight.w500,
                  color: ShadcnTheme.foregroundColor(context),
                ),
              ),
              Text(
                '${(value * 100).toInt()}%',
                style: ShadcnTheme.small.copyWith(
                  color: ShadcnTheme.mutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        ClipRRect(
          borderRadius: ShadcnTheme.borderRadiusSm,
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: ShadcnTheme.input,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 8),
          Text(
            description!,
            style: ShadcnTheme.tiny.copyWith(
              color: ShadcnTheme.mutedForeground,
            ),
          ),
        ],
      ],
    );
  }

  Color _getProgressColor() {
    switch (variant) {
      case ShadcnProgressVariant.default_:
        return ShadcnTheme.primary;
      case ShadcnProgressVariant.success:
        return ShadcnTheme.healthExcellent;
      case ShadcnProgressVariant.warning:
        return ShadcnTheme.warning;
      case ShadcnProgressVariant.destructive:
        return ShadcnTheme.destructive;
    }
  }
}

enum ShadcnProgressVariant { default_, success, warning, destructive }

/// Shadcn-style Separator
class ShadcnSeparator extends StatelessWidget {
  final String? label;
  final bool horizontal;

  const ShadcnSeparator({
    super.key,
    this.label,
    this.horizontal = true,
  });

  @override
  Widget build(BuildContext context) {
    if (label != null) {
      return Row(
        children: [
          Expanded(child: _buildLine(context)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              label!,
              style: ShadcnTheme.small.copyWith(
                color: ShadcnTheme.mutedForeground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: _buildLine(context)),
        ],
      );
    }

    return _buildLine(context);
  }

  Widget _buildLine(BuildContext context) {
    return Container(
      height: horizontal ? 1 : null,
      width: horizontal ? null : 1,
      decoration: BoxDecoration(
        color: ShadcnTheme.borderColor(context),
        border: Border.all(
          width: horizontal ? 0 : 1,
          color: ShadcnTheme.borderColor(context),
        ),
      ),
    );
  }
}