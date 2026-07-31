import 'package:flutter/material.dart';
import 'package:business_assistant/theme/get_theme_color.dart';

/// A tappable icon inside a rounded, filled container — used for header
/// actions like notifications.
class SelectableIcon extends StatelessWidget {
  final double borderRadius;
  final Widget iconWidget;
  final Function()? itemPressed;
  final Color? backgroundColor;
  final EdgeInsets padding;

  const SelectableIcon({
    super.key,
    required this.iconWidget,
    this.itemPressed,
    this.borderRadius = 100,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Material(
        color: backgroundColor ?? context.colors.secondaryBackground,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: itemPressed != null ? () => itemPressed?.call() : null,
          child: Padding(
            padding: padding,
            child: iconWidget,
          ),
        ),
      ),
    );
  }
}
