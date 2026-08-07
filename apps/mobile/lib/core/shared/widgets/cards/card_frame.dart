import 'package:business_assistant/core/shared/widgets/input_fields/input_label.dart';
import 'package:business_assistant/theme/get_theme_color.dart';
import 'package:flutter/material.dart';

class CardFrame extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double borderRadius;
  final double? borderRadiusTopLeft;
  final double? borderRadiusTopRight;
  final double? borderRadiusBottomLeft;
  final double? borderRadiusBottomRight;
  final String? headerSectionTtitle;
  final Widget? headerSectionRightContent;
  final double horizontalPadding;
  final double verticalPadding;
  final double? paddingTop;
  final double? paddingBottom;
  final double? paddingLeft;
  final double? paddingRight;
  final Color? borderColor;
  final EdgeInsets headerTitlePadding;

  const CardFrame({
    required this.child,
    this.padding,
    this.borderRadius = 22,
    this.borderRadiusTopLeft,
    this.borderRadiusTopRight,
    this.borderRadiusBottomLeft,
    this.borderRadiusBottomRight,
    this.headerSectionTtitle,
    this.headerSectionRightContent,
    this.horizontalPadding = 16,
    this.verticalPadding = 16,
    this.paddingTop,
    this.paddingBottom,
    this.paddingLeft,
    this.paddingRight,
    this.borderColor,
    // this.borderColor = Colors.transparent,
    this.headerTitlePadding = const EdgeInsets.all(0),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadiusTopLeft ?? borderRadius),
          topRight: Radius.circular(borderRadiusTopRight ?? borderRadius),
          bottomLeft: Radius.circular(borderRadiusBottomLeft ?? borderRadius),
          bottomRight: Radius.circular(borderRadiusBottomRight ?? borderRadius),
        ),
        border: Border.all(color: borderColor ?? colors.primaryText.withValues(alpha: 0.08), width: 1),
        shape: BoxShape.rectangle,
        color: colors.secondaryBackground,
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding:
            padding ??
            EdgeInsets.fromLTRB(
              paddingLeft ?? horizontalPadding,
              paddingTop ?? verticalPadding,
              paddingRight ?? horizontalPadding,
              paddingBottom ?? verticalPadding,
            ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            if (headerSectionTtitle != null || headerSectionRightContent != null) ...[
              Padding(
                padding: headerTitlePadding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (headerSectionTtitle != null) ...[
                      Flexible(child: InputLabel(text: headerSectionTtitle!)),
                    ] else ...[
                      const SizedBox.shrink(),
                    ],
                    headerSectionRightContent ?? const SizedBox.shrink(),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Content section
            child,
          ],
        ),
      ),
    );
  }
}
