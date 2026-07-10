import 'package:flutter/material.dart';
import 'package:business_assistant/theme/theme_color.dart';

/// Returns the ThemeColor extension from the current theme.
///
/// The ThemeColor extension is registered in Themes.light and Themes.dark.
/// This function is the long form — use the extension below for brevity.
ThemeColor getSelectedThemeColors(BuildContext context) {
  return Theme.of(context).extension<ThemeColor>()!;
}

/// Shorthand extension so you can write context.colors.primaryBackground
/// instead of Theme.of(context).extension<ThemeColor>()!.primaryBackground.
extension ThemeColorContext on BuildContext {
  ThemeColor get colors => Theme.of(this).extension<ThemeColor>()!;
}
