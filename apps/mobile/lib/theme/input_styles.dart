import 'package:flutter/material.dart';
import 'package:business_assistant/theme/theme_color.dart';

/// Shared input decoration styles and container decorations.
///
/// Centralizing these avoids duplicating border and fill config across
/// every form field in the app.
class InputStyles {
  /// Standard text field decoration with tenant-branded focus border.
  static InputDecoration primaryInputDecoration({
    String lableText = '',
    String hintText = '',
    Color? fillColor,
    Widget? prefixIcon,
    Widget? suffix,
    required EdgeInsetsGeometry contentPadding,
    double borderWidth = 1,
    bool floatLabelToTop = true,
    Color borderColor = Colors.transparent,
    double borderRadius = 12,
  }) {
    return InputDecoration(
      prefixIcon: prefixIcon,
      errorStyle: TextStyle(
        color: AppColors.primaryRed,
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      isDense: true,
      labelText: lableText,
      floatingLabelBehavior:
          floatLabelToTop ? FloatingLabelBehavior.auto : FloatingLabelBehavior.never,
      filled: true,
      fillColor: fillColor ?? Colors.transparent,
      labelStyle: const TextStyle(
        color: AppColors.baseBlack01,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      hintText: hintText,
      hintStyle: const TextStyle(
        color: AppColors.baseBlack01,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      suffixIcon: suffix,
      contentPadding: contentPadding,
      // Focused border uses the accent color (tenant-branded highlight)
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: AppColors.baseYellow, width: borderWidth),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: borderColor, width: borderWidth),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: AppColors.primaryRed, width: borderWidth),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: AppColors.primaryRed, width: borderWidth),
      ),
      errorMaxLines: 3,
    );
  }

  /// Rounded card-like container background — used for form panels.
  static BoxDecoration roundedContainterBackground([Color? color]) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: const BorderRadius.all(Radius.circular(15.0)),
    );
  }
}
