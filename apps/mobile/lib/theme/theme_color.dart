import 'package:flutter/material.dart';

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
  Color baseWhite;

  /// Event status colors — fixed semantic colors (not tenant-branded), used by
  /// EventStatusBadge. InProgress reuses brandPrimary and Canceled reuses
  /// brandError since those already carry the right meaning.
  Color statusPending;
  Color statusFinished;

  ThemeColor({
    required this.primaryBackground,
    required this.secondaryBackground,
    required this.primaryText,
    required this.brandPrimary,
    required this.brandAccent,
    required this.brandError,
    required this.baseWhite,
    required this.statusPending,
    required this.statusFinished,
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
    Color? baseWhite,
    Color? statusPending,
    Color? statusFinished,
  }) {
    return ThemeColor(
      primaryBackground: primaryBackground ?? this.primaryBackground,
      secondaryBackground: secondaryBackground ?? this.secondaryBackground,
      primaryText: primaryText ?? this.primaryText,
      brandPrimary: brandPrimary ?? this.brandPrimary,
      brandAccent: brandAccent ?? this.brandAccent,
      brandError: brandError ?? this.brandError,
      baseWhite: baseWhite ?? this.baseWhite,
      statusPending: statusPending ?? this.statusPending,
      statusFinished: statusFinished ?? this.statusFinished,
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
      baseWhite: Color.lerp(baseWhite, other.baseWhite, t)!,
      statusPending: Color.lerp(statusPending, other.statusPending, t)!,
      statusFinished: Color.lerp(statusFinished, other.statusFinished, t)!,
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

  // ── Tenant brand colors — injected at build time via --dart-define-from-file ──
  // Color hex strings must be static const so they can be used in Color() at
  // field initializer time (before any constructor body runs).
  static const String _primaryColorHex =
      String.fromEnvironment('PRIMARY_COLOR', defaultValue: 'FF1A237E');
  static const String _accentColorHex =
      String.fromEnvironment('ACCENT_COLOR', defaultValue: 'FF00BCD4');
  static const String _errorColorHex =
      String.fromEnvironment('ERROR_COLOR', defaultValue: 'FFEB2E25');

  static final Color brandPrimary = Color(int.parse(_primaryColorHex, radix: 16));
  static final Color brandAccent = Color(int.parse(_accentColorHex, radix: 16));
  static final Color brandError = Color(int.parse(_errorColorHex, radix: 16));

  static Color get baseYellow => brandAccent;
  static Color get primaryRed => brandError;
  static Color get secondaryText => const Color.fromRGBO(15, 15, 15, 0.5);
  static Color get textBlue => brandPrimary;

  // ── Neutral colors — same across all tenants ──────────────────────────────
  static const Color baseBlack01 = Color.fromRGBO(23, 23, 23, 0.4);
  static const Color baseWhite = Color.fromRGBO(255, 255, 255, 1);
  static const Color baseWhiteDark = primaryText;

  // ── Event status colors — fixed, not tenant-branded (see EventStatusBadge) ──
  static const Color statusPending = Color.fromRGBO(217, 119, 6, 1);
  static const Color statusPendingDark = Color.fromRGBO(251, 191, 36, 1);
  static const Color statusFinished = Color.fromRGBO(22, 163, 74, 1);
  static const Color statusFinishedDark = Color.fromRGBO(34, 197, 94, 1);

  // ── Shadow ────────────────────────────────────────────────────────────────
  static const Color primaryShadowColor = Color.fromRGBO(0, 0, 0, 0.25);
}

/// The light theme's ThemeColor instance — registered as a ThemeExtension in Themes.light.
ThemeColor lightThemeColors = ThemeColor(
  primaryBackground: AppColors.primaryBackground,
  secondaryBackground: AppColors.secondaryBackground,
  primaryText: AppColors.primaryText,
  brandPrimary: AppColors.brandPrimary,
  brandAccent: AppColors.brandAccent,
  brandError: AppColors.brandError,
  baseWhite: AppColors.baseWhite,
  statusPending: AppColors.statusPending,
  statusFinished: AppColors.statusFinished,
);

/// The dark theme's ThemeColor instance — registered as a ThemeExtension in Themes.dark.
ThemeColor darkThemeColors = ThemeColor(
  primaryBackground: AppColors.primaryBackgroundDark,
  secondaryBackground: AppColors.secondaryBackgroundDark,
  primaryText: AppColors.primaryTextDark,
  brandPrimary: AppColors.brandPrimary,
  brandAccent: AppColors.brandAccent,
  brandError: AppColors.brandError,
  baseWhite: AppColors.baseWhiteDark,
  statusPending: AppColors.statusPendingDark,
  statusFinished: AppColors.statusFinishedDark,
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
