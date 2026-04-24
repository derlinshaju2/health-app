import 'package:flutter/material.dart';
import '../themes/shadcn_theme.dart';

/// Shadcn-style Card Component
/// Modern, clean card with rounded corners and subtle shadows
class ShadcnCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final VoidCallback? onTap;
  final Border? border;
  final BorderRadius? borderRadius;

  const ShadcnCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.onTap,
    this.border,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor ?? ShadcnTheme.cardColor(context),
        borderRadius: borderRadius ?? ShadcnTheme.borderRadius,
        border: border ?? Border.all(
          color: ShadcnTheme.borderColor(context),
          width: 1,
        ),
        boxShadow: elevation != null
            ? [BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: elevation!,
                offset: const Offset(0, 2),
              )]
            : ShadcnTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? ShadcnTheme.borderRadius,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Shadcn-style Button Component
/// Modern button with multiple variants
class ShadcnButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ShadcnButtonVariant variant;
  final ShadcnButtonSize size;
  final IconData? icon;
  final bool fullWidth;
  final bool isLoading;

  const ShadcnButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ShadcnButtonVariant.primary,
    this.size = ShadcnButtonSize.medium,
    this.icon,
    this.fullWidth = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: _buildButton(context, enabled),
    );
  }

  Widget _buildButton(BuildContext context, bool enabled) {
    final colors = _getButtonColors(context);
    final dimensions = _getButtonDimensions();

    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.backgroundColor,
        foregroundColor: colors.foregroundColor,
        disabledBackgroundColor: colors.disabledBackgroundColor,
        disabledForegroundColor: colors.disabledForegroundColor,
        padding: dimensions.padding,
        minimumSize: dimensions.minimumSize,
        shape: RoundedRectangleBorder(
          borderRadius: ShadcnTheme.buttonBorderRadius,
          side: BorderSide(
            color: colors.borderColor ?? Colors.transparent,
            width: 1,
          ),
        ),
        elevation: 0,
      ),
      child: isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colors.foregroundColor),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: dimensions.iconSize),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: TextStyle(
                    fontSize: dimensions.fontSize,
                    fontWeight: dimensions.fontWeight,
                  ),
                ),
              ],
            ),
    );
  }

  _ButtonColors _getButtonColors(BuildContext context) {
    switch (variant) {
      case ShadcnButtonVariant.primary:
        return _ButtonColors(
          backgroundColor: ShadcnTheme.primaryColor,
          foregroundColor: ShadcnTheme.primaryForeground,
          disabledBackgroundColor: ShadcnTheme.primaryColor.withOpacity(0.5),
          disabledForegroundColor: ShadcnTheme.primaryForeground.withOpacity(0.5),
        );
      case ShadcnButtonVariant.secondary:
        return _ButtonColors(
          backgroundColor: ShadcnTheme.secondaryColor,
          foregroundColor: ShadcnTheme.secondaryForeground,
          disabledBackgroundColor: ShadcnTheme.secondaryColor.withOpacity(0.5),
          disabledForegroundColor: ShadcnTheme.secondaryForeground.withOpacity(0.5),
        );
      case ShadcnButtonVariant.outline:
        return _ButtonColors(
          backgroundColor: Colors.transparent,
          foregroundColor: ShadcnTheme.foregroundColor,
          borderColor: ShadcnTheme.borderColor(context),
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: ShadcnTheme.mutedColor.withOpacity(0.5),
        );
      case ShadcnButtonVariant.ghost:
        return _ButtonColors(
          backgroundColor: Colors.transparent,
          foregroundColor: ShadcnTheme.foregroundColor,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: ShadcnTheme.mutedColor.withOpacity(0.5),
        );
      case ShadcnButtonVariant.destructive:
        return _ButtonColors(
          backgroundColor: ShadcnTheme.destructiveColor,
          foregroundColor: ShadcnTheme.destructiveForeground,
          disabledBackgroundColor: ShadcnTheme.destructiveColor.withOpacity(0.5),
          disabledForegroundColor: ShadcnTheme.destructiveForeground.withOpacity(0.5),
        );
    }
  }

  _ButtonDimensions _getButtonDimensions() {
    switch (size) {
      case ShadcnButtonSize.small:
        return _ButtonDimensions(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: const Size(64, 32),
          iconSize: 16.0,
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
        );
      case ShadcnButtonSize.medium:
        return _ButtonDimensions(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          minimumSize: const Size(80, 40),
          iconSize: 18.0,
          fontSize: 15.0,
          fontWeight: FontWeight.w500,
        );
      case ShadcnButtonSize.large:
        return _ButtonDimensions(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(96, 48),
          iconSize: 20.0,
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        );
    }
  }
}

enum ShadcnButtonVariant { primary, secondary, outline, ghost, destructive }
enum ShadcnButtonSize { small, medium, large }

class _ButtonColors {
  final Color backgroundColor;
  final Color foregroundColor;
  final Color disabledBackgroundColor;
  final Color disabledForegroundColor;
  final Color? borderColor;

  _ButtonColors({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.disabledBackgroundColor,
    required this.disabledForegroundColor,
    this.borderColor,
  });
}

class _ButtonDimensions {
  final EdgeInsetsGeometry padding;
  final Size minimumSize;
  final double iconSize;
  final double fontSize;
  final FontWeight fontWeight;

  _ButtonDimensions({
    required this.padding,
    required this.minimumSize,
    required this.iconSize,
    required this.fontSize,
    required this.fontWeight,
  });
}