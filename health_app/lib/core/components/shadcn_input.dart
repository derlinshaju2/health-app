import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../themes/shadcn_theme.dart';

/// Shadcn-style Text Input Component
/// Modern input field with focus states and validation
class ShadcnInput extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? value;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final String? helperText;
  final TextEditingController? controller;

  const ShadcnInput({
    super.key,
    this.label,
    this.hint,
    this.value,
    this.onChanged,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.helperText,
    this.controller,
  });

  @override
  State<ShadcnInput> createState() => _ShadcnInputState();
}

class _ShadcnInputState extends State<ShadcnInput> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: ShadcnTheme.small.copyWith(
              fontWeight: FontWeight.w500,
              color: ShadcnTheme.foregroundColor(context),
            ),
          ),
          const SizedBox(height: ShadcnTheme.spacingXs),
        ],
        Container(
          decoration: BoxDecoration(
            color: widget.enabled
                ? ShadcnTheme.cardColor(context)
                : ShadcnTheme.mutedColor.withOpacity(0.3),
            borderRadius: ShadcnTheme.borderRadiusMd,
            border: Border.all(
              color: _getBorderColor(context),
              width: _isFocused ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: widget.obscureText,
            enabled: widget.enabled,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            focusNode: _focusNode,
            style: ShadcnTheme.body.copyWith(
              color: ShadcnTheme.foregroundColor(context),
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: ShadcnTheme.body.copyWith(
                color: ShadcnTheme.mutedForeground,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      size: 20,
                      color: _isFocused
                          ? ShadcnTheme.primary
                          : ShadcnTheme.mutedForeground,
                    )
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? IconButton(
                      icon: Icon(widget.suffixIcon, size: 20),
                      onPressed: widget.onSuffixIconPressed,
                      color: _adaptiveColor(context, ShadcnTheme.mutedForeground),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              counterText: '', // Hide default counter
            ),
            onChanged: widget.onChanged,
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: ShadcnTheme.spacingXs),
          Text(
            widget.errorText!,
            style: ShadcnTheme.tiny.copyWith(
              color: ShadcnTheme.destructive,
            ),
          ),
        ] else if (widget.helperText != null) ...[
          const SizedBox(height: ShadcnTheme.spacingXs),
          Text(
            widget.helperText!,
            style: ShadcnTheme.tiny.copyWith(
              color: ShadcnTheme.mutedForeground,
            ),
          ),
        ],
      ],
    );
  }

  Color _getBorderColor(BuildContext context) {
    if (!widget.enabled) {
      return ShadcnTheme.borderColor(context).withOpacity(0.5);
    }
    if (widget.errorText != null) {
      return ShadcnTheme.destructive;
    }
    return _isFocused
        ? ShadcnTheme.ring
        : ShadcnTheme.borderColor(context);
  }

  Color _adaptiveColor(BuildContext context, Color lightColor) {
    return Theme.of(context).brightness == Brightness.dark
        ? lightColor.withOpacity(0.8)
        : lightColor;
  }
}

/// Shadcn-style Select/Dropdown Component
class ShadcnSelect<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<ShadcnSelectOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final String? hint;
  final bool enabled;
  final String? errorText;
  final IconData? prefixIcon;

  const ShadcnSelect({
    super.key,
    required this.label,
    this.value,
    required this.options,
    this.onChanged,
    this.hint,
    this.enabled = true,
    this.errorText,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: ShadcnTheme.small.copyWith(
            fontWeight: FontWeight.w500,
            color: ShadcnTheme.foregroundColor(context),
          ),
        ),
        const SizedBox(height: ShadcnTheme.spacingXs),
        Container(
          decoration: BoxDecoration(
            color: enabled
                ? ShadcnTheme.cardColor(context)
                : ShadcnTheme.mutedColor.withOpacity(0.3),
            borderRadius: ShadcnTheme.borderRadiusMd,
            border: Border.all(
              color: errorText != null
                  ? ShadcnTheme.destructive
                  : ShadcnTheme.borderColor(context),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<T>(
                value: value,
                hint: Text(
                  hint ?? 'Select...',
                  style: ShadcnTheme.body.copyWith(
                    color: ShadcnTheme.mutedForeground,
                  ),
                ),
                onChanged: enabled ? onChanged : null,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: ShadcnTheme.mutedForeground,
                ),
                style: ShadcnTheme.body.copyWith(
                  color: ShadcnTheme.foregroundColor(context),
                ),
                items: options.map((option) {
                  return DropdownMenuItem<T>(
                    value: option.value,
                    child: Row(
                      children: [
                        if (option.icon != null) ...[
                          Icon(
                            option.icon,
                            size: 18,
                            color: ShadcnTheme.mutedForeground,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(option.label),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: ShadcnTheme.spacingXs),
          Text(
            errorText!,
            style: ShadcnTheme.tiny.copyWith(
              color: ShadcnTheme.destructive,
            ),
          ),
        ],
      ],
    );
  }
}

class ShadcnSelectOption<T> {
  final String label;
  final T value;
  final IconData? icon;

  ShadcnSelectOption({
    required this.label,
    required this.value,
    this.icon,
  });
}

/// Shadcn-style Checkbox Component
class ShadcnCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;
  final String? description;

  const ShadcnCheckbox({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
    this.enabled = true,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => onChanged?.call(!value) : null,
      borderRadius: ShadcnTheme.borderRadiusMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: value,
                onChanged: enabled ? (v) => onChanged?.call(v ?? false) : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: BorderSide(
                  color: ShadcnTheme.borderColor(context),
                  width: 1.5,
                ),
                activeColor: ShadcnTheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: ShadcnTheme.body.copyWith(
                      color: enabled
                          ? ShadcnTheme.foregroundColor(context)
                          : ShadcnTheme.mutedForeground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (description != null)
                    Text(
                      description!,
                      style: ShadcnTheme.small.copyWith(
                        color: ShadcnTheme.mutedForeground,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}