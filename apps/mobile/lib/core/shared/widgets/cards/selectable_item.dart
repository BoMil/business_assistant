import 'package:flutter/material.dart';
import 'package:business_assistant/theme/get_theme_color.dart';

class SelectableItem extends StatelessWidget {
  final double borderRadius;
  final BorderRadius? customBorderRadius;
  final String title;
  final String? subtitle;
  final Widget? rightContent;
  final Widget? leftIcon;
  final Function()? itemPressed;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color textColor;
  final double fontSize;
  final EdgeInsets padding;
  final MainAxisAlignment mainAxisAlignment;
  final FontWeight fontWeight;

  const SelectableItem({
    super.key,
    required this.title,
    this.leftIcon,
    this.itemPressed,
    this.borderRadius = 12,
    this.customBorderRadius,
    this.rightContent,
    this.backgroundColor,
    this.borderColor,
    required this.textColor,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18),
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    this.fontWeight = FontWeight.w500,
    this.subtitle,
  });

  BorderRadius get _resolvedBorderRadius => customBorderRadius ?? BorderRadius.circular(borderRadius);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: _resolvedBorderRadius,
        border: Border.all(color: borderColor ?? Colors.transparent, width: borderColor == null ? 0 : 1),
      ),
      child: Material(
        color: backgroundColor ?? context.colors.secondaryBackground,
        borderRadius: _resolvedBorderRadius,
        child: InkWell(
          borderRadius: _resolvedBorderRadius,
          onTap: itemPressed != null ? () => itemPressed?.call() : null,
          child: Padding(
            padding: padding,
            child: Row(
              mainAxisAlignment: mainAxisAlignment,
              children: [
                // Left content
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Left icon
                      if (leftIcon != null) ...[leftIcon!, const SizedBox(width: 6)],

                      // Title
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Title
                            Text(
                              title,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: textColor, fontSize: fontSize, fontWeight: fontWeight),
                            ),

                            // Subtitle — one Text per line so a long first line (e.g. an
                            // address) can't swallow the following lines: TextOverflow.ellipsis
                            // without maxLines is unreliable across multiple '\n'-joined lines.
                            if (subtitle != null)
                              ...subtitle!.split('\n').map(
                                (line) => Text(
                                  line,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: context.colors.primaryText.withValues(alpha: 0.5),
                                    fontSize: fontSize - 2,
                                    fontWeight: fontWeight,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Right content
                if (rightContent != null) ...[rightContent!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
