import 'package:flutter/material.dart';
import 'package:business_assistant/theme/theme_color.dart';

/// Shared box shadow definitions.
class AppBoxShadows {
  List<BoxShadow> primaryBoxShadow = [
    const BoxShadow(
      color: AppColors.primaryShadowColor,
      offset: Offset(0, 4),
      blurRadius: 4,
    ),
  ];
}
