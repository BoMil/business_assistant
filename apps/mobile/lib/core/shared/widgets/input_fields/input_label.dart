import 'package:flutter/material.dart';
import 'package:business_assistant/theme/get_theme_color.dart';
import 'package:business_assistant/theme/text_styles.dart';

class InputLabel extends StatelessWidget {
  final String text;
  const InputLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.left,
      style: AppTextStyles().buttonsText(
        color: context.colors.primaryText.withValues(alpha: 0.7),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
