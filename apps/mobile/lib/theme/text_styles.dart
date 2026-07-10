import 'package:flutter/material.dart';

/// Shared text style factories used across shared widgets (buttons, inputs).
class AppTextStyles {
  TextStyle buttonsText({
    Color color = Colors.black,
    double fontSize = 14.0,
    FontWeight fontWeight = FontWeight.w600,
    double? lineHeight,
  }) {
    return TextStyle(
      height: lineHeight,
      color: color,
      fontSize: fontSize,
      letterSpacing: 0,
      fontFamily: 'Inter',
      fontWeight: fontWeight,
    );
  }

  TextStyle secondaryText({
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w500,
    TextDecoration? decoration,
    required Color color,
  }) {
    return TextStyle(
      decoration: decoration,
      color: color,
      fontSize: fontSize,
      letterSpacing: 0,
      fontFamily: 'Inter',
      fontWeight: fontWeight,
    );
  }
}
