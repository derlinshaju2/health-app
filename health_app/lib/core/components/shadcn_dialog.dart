import 'package:flutter/material.dart';
import '../themes/shadcn_theme.dart';
import 'shadcn_card.dart';
import 'shadcn_input.dart';

/// Shadcn-style Dialog/Alert Component
/// Modern dialog with clean design and smooth animations
class ShadcnDialog extends StatelessWidget {
  final String title;
  final String? description;
  final List<Widget> actions;
  final Widget? content;
  final IconData? icon;
  final Color? iconColor;

  const ShadcnDialog({
    super.key,
    required this.title,
    this.description,
    required this.actions,
    this.content,
    this.icon,
    this.iconColor,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? description,
    required List<Widget> actions,
    Widget? content,
    IconData? icon,
    Color? iconColor,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => ShadcnDialog(
        title: title,
        description: description,
        actions: actions,
        content: content,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: ShadcnCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (iconColor ?? ShadcnTheme.info).withOpacity(0.1),
                        borderRadius: ShadcnTheme.borderRadiusMd,
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: iconColor ?? ShadcnTheme.info,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: ShadcnTheme.h3.copyWith(
                            color: ShadcnTheme.foregroundColor(context),
                          ),
                        ),
                        if (description != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            description!,
                            style: ShadcnTheme.small.copyWith(
                              color: ShadcnTheme.mutedForeground,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => Navigator.of(context).pop(),
                    color: ShadcnTheme.mutedForeground,
                    padding: const EdgeInsets.all(4),
                  ),
                ],
              ),
              if (content != null) ...[
                const SizedBox(height: 20),
                content!,
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions.map((action) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: action,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shadcn-style Alert/Banner Component
class ShadcnAlert extends StatelessWidget {
  final String title;
  final String? description;
  final ShadcnAlertVariant variant;
  final IconData? icon;
  final List<Widget>? actions;

  const ShadcnAlert({
    super.key,
    required this.title,
    this.description,
    this.variant = ShadcnAlertVariant.default_,
    this.icon,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getAlertColors();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        border: Border.all(
          color: colors.borderColor,
          width: 1,
        ),
        borderRadius: ShadcnTheme.borderRadius,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colors.iconBackgroundColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              icon ?? _getDefaultIcon(),
              size: 16,
              color: colors.iconColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ShadcnTheme.small.copyWith(
                    color: colors.textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: ShadcnTheme.tiny.copyWith(
                      color: colors.textColor,
                    ),
                  ),
                ],
                if (actions != null) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: actions!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  _AlertColors _getAlertColors() {
    switch (variant) {
      case ShadcnAlertVariant.default_:
        return _AlertColors(
          backgroundColor: ShadcnTheme.background,
          borderColor: ShadcnTheme.border,
          iconBackgroundColor: ShadcnTheme.muted,
          iconColor: ShadcnTheme.foreground,
          textColor: ShadcnTheme.foreground,
        );
      case ShadcnAlertVariant.destructive:
        return _AlertColors(
          backgroundColor: ShadcnTheme.destructive.withOpacity(0.1),
          borderColor: ShadcnTheme.destructive,
          iconBackgroundColor: ShadcnTheme.destructive.withOpacity(0.2),
          iconColor: ShadcnTheme.destructive,
          textColor: ShadcnTheme.destructive,
        );
      case ShadcnAlertVariant.success:
        return _AlertColors(
          backgroundColor: ShadcnTheme.healthExcellent.withOpacity(0.1),
          borderColor: ShadcnTheme.healthExcellent,
          iconBackgroundColor: ShadcnTheme.healthExcellent.withOpacity(0.2),
          iconColor: ShadcnTheme.healthExcellent,
          textColor: ShadcnTheme.healthExcellent,
        );
      case ShadcnAlertVariant.warning:
        return _AlertColors(
          backgroundColor: ShadcnTheme.warning.withOpacity(0.1),
          borderColor: ShadcnTheme.warning,
          iconBackgroundColor: ShadcnTheme.warning.withOpacity(0.2),
          iconColor: ShadcnTheme.warning,
          textColor: ShadcnTheme.warning,
        );
    }
  }

  IconData _getDefaultIcon() {
    switch (variant) {
      case ShadcnAlertVariant.default_:
        return Icons.info_outline;
      case ShadcnAlertVariant.destructive:
        return Icons.error_outline;
      case ShadcnAlertVariant.success:
        return Icons.check_circle_outline;
      case ShadcnAlertVariant.warning:
        return Icons.warning_amber_outlined;
    }
  }
}

enum ShadcnAlertVariant { default_, destructive, success, warning }

class _AlertColors {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final Color textColor;

  _AlertColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.textColor,
  });
}

/// Shadcn-style Bottom Sheet Component
class ShadcnBottomSheet extends StatelessWidget {
  final String title;
  final String? description;
  final List<Widget> children;
  final Widget? action;

  const ShadcnBottomSheet({
    super.key,
    required this.title,
    this.description,
    required this.children,
    this.action,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? description,
    required List<Widget> children,
    Widget? action,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ShadcnBottomSheet(
        title: title,
        description: description,
        children: children,
        action: action,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ShadcnTheme.cardColor(context),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ShadcnTheme.input,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ShadcnTheme.h4.copyWith(
                      color: ShadcnTheme.foregroundColor(context),
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      description!,
                      style: ShadcnTheme.small.copyWith(
                        color: ShadcnTheme.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 32),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: children,
                ),
              ),
            ),
            if (action != null) ...[
              const Divider(height: 32),
              Padding(
                padding: const EdgeInsets.all(24),
                child: action,
              ),
            ],
          ],
        ),
      ),
    );
  }
}