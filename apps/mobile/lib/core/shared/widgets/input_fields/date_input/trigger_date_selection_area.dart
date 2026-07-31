import 'package:flutter/material.dart';
import 'package:business_assistant/theme/get_theme_color.dart';

/// The tappable "field" shown by DateInputField — a label on the left,
/// the chosen date (or a placeholder) and a calendar icon on the right.
class TriggerDateSelectionArea extends StatelessWidget {
  final String title;
  final String infoTitle;
  final Function() itemPressed;
  final Function() closePressed;
  final bool isCloseVisible;
  final Color? borderColor;

  const TriggerDateSelectionArea({
    super.key,
    required this.title,
    required this.infoTitle,
    required this.itemPressed,
    required this.closePressed,
    this.isCloseVisible = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;
    return Stack(
      children: [
        GestureDetector(
          onTap: itemPressed,
          child: Container(
            decoration: BoxDecoration(
              color: theme.baseWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor ?? theme.primaryText.withValues(alpha: 0.15), width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 16, right: 10, top: 14, bottom: 14),
                    child: Text(
                      infoTitle,
                      style: TextStyle(color: theme.primaryText.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 20, top: 14, bottom: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(color: theme.primaryText, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Icon(Icons.calendar_today_outlined, size: 18, color: theme.primaryText.withValues(alpha: 0.4)),
                          if (isCloseVisible) const SizedBox(width: 27),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isCloseVisible)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: InkWell(
              onTap: closePressed,
              borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.close, size: 17, color: theme.primaryText.withValues(alpha: 0.5)),
              ),
            ),
          ),
      ],
    );
  }
}
