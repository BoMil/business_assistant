import 'package:flutter/material.dart';
import 'package:business_assistant/config/tenant/tenant_config.dart';

/// ThemeExtension that carries semantic color slots for light and dark themes.
///
/// Why ThemeExtension?
///   Flutter's ThemeData has a colorScheme, but it doesn't have slots like
///   "primaryBackground" or "secondaryBackground". ThemeExtension lets us add
///   our own named colors and access them via Theme.of(context).extension<ThemeColor>().
///
/// Usage:
///   context.colors.primaryBackground   ← via the ThemeColorContext extension below
///   getSelectedThemeColors(context).primaryText
class ThemeColor extends ThemeExtension<ThemeColor> {
  Color primaryBackground;
  Color secondaryBackground;
  Color primaryText;
  Color brandPrimary;
  Color brandAccent;
  Color brandError;

  ThemeColor({
    required this.primaryBackground,
    required this.secondaryBackground,
    required this.primaryText,
    required this.brandPrimary,
    required this.brandAccent,
    required this.brandError,
  });

  /// Required by ThemeExtension — creates a copy with overridden values.
  @override
  ThemeExtension<ThemeColor> copyWith({
    Color? primaryBackground,
    Color? secondaryBackground,
    Color? primaryText,
    Color? brandPrimary,
    Color? brandAccent,
    Color? brandError,
  }) {
    return ThemeColor(
      primaryBackground: primaryBackground ?? this.primaryBackground,
      secondaryBackground: secondaryBackground ?? this.secondaryBackground,
      primaryText: primaryText ?? this.primaryText,
      brandPrimary: brandPrimary ?? this.brandPrimary,
      brandAccent: brandAccent ?? this.brandAccent,
      brandError: brandError ?? this.brandError,
    );
  }

  /// Required by ThemeExtension — interpolates between two ThemeColor instances
  /// during theme animations (e.g. when switching light ↔ dark with a transition).
  @override
  ThemeExtension<ThemeColor> lerp(
      covariant ThemeExtension<ThemeColor>? other, double t) {
    if (other is! ThemeColor) return this;
    return ThemeColor(
      primaryBackground:
          Color.lerp(primaryBackground, other.primaryBackground, t)!,
      secondaryBackground:
          Color.lerp(secondaryBackground, other.secondaryBackground, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      brandPrimary: Color.lerp(brandPrimary, other.brandPrimary, t)!,
      brandAccent: Color.lerp(brandAccent, other.brandAccent, t)!,
      brandError: Color.lerp(brandError, other.brandError, t)!,
    );
  }
}

/// Static color constants that do not change between tenants or themes.
class AppColors {
  // ── Light theme backgrounds ───────────────────────────────────────────────
  static const Color primaryBackground = Color.fromRGBO(245, 245, 245, 1);
  static const Color secondaryBackground = Color.fromRGBO(255, 255, 255, 0.9);
  static const Color primaryText = Color.fromRGBO(15, 15, 15, 1);

  // ── Dark theme backgrounds ────────────────────────────────────────────────
  static const Color primaryBackgroundDark = Color.fromRGBO(15, 15, 15, 1);
  static const Color secondaryBackgroundDark = Color.fromRGBO(23, 23, 23, 1);
  static const Color primaryTextDark = Color.fromRGBO(255, 255, 255, 1);

  // ── Tenant brand colors (delegated to TenantConfig at runtime) ────────────
  static Color get baseYellow => TenantConfig().accentColor;
  static Color get primaryRed => TenantConfig().errorColor;
  static Color get secondaryText => const Color.fromRGBO(15, 15, 15, 0.5);
  static Color get textBlue => TenantConfig().primaryColor;

  // ── Neutral colors — same across all tenants ──────────────────────────────
  static const Color baseBlack01 = Color.fromRGBO(23, 23, 23, 0.1);
  static const Color baseWhite = Color.fromRGBO(255, 255, 255, 1);

  // ── Shadow ────────────────────────────────────────────────────────────────
  static const Color primaryShadowColor = Color.fromRGBO(0, 0, 0, 0.25);
}

/// The light theme's ThemeColor instance — registered as a ThemeExtension in Themes.light.
ThemeColor lightThemeColors = ThemeColor(
  primaryBackground: AppColors.primaryBackground,
  secondaryBackground: AppColors.secondaryBackground,
  primaryText: AppColors.primaryText,
  brandPrimary: TenantConfig().primaryColor,
  brandAccent: TenantConfig().accentColor,
  brandError: TenantConfig().errorColor,
);

/// The dark theme's ThemeColor instance — registered as a ThemeExtension in Themes.dark.
ThemeColor darkThemeColors = ThemeColor(
  primaryBackground: AppColors.primaryBackgroundDark,
  secondaryBackground: AppColors.secondaryBackgroundDark,
  primaryText: AppColors.primaryTextDark,
  brandPrimary: TenantConfig().primaryColor,
  brandAccent: TenantConfig().accentColor,
  brandError: TenantConfig().errorColor,
);

/// Converts a Flutter Color to a CSS-style hex string for display.
///
/// Example: Color(0xFF1A237E) → '#1A237E'
String colorToHex(Color color, {bool includeAlpha = false}) {
  String alpha = color.alpha.toRadixString(16).padLeft(2, '0');
  String red = color.red.toRadixString(16).padLeft(2, '0');
  String green = color.green.toRadixString(16).padLeft(2, '0');
  String blue = color.blue.toRadixString(16).padLeft(2, '0');
  return '#${includeAlpha ? alpha : ''}$red$green$blue'.toUpperCase();
}
