import 'package:flutter/material.dart';
import 'package:business_assistant/config/tenant/tenant_config.dart';
import 'theme_color.dart';

/// Defines the light and dark ThemeData instances used by MaterialApp.router.
///
/// Both themes:
///   - Use ZoomPageTransitionsBuilder for smooth page transitions on Android and iOS.
///   - Override colorScheme.primary/secondary/error with the tenant's brand colors
///     so Material widgets (buttons, progress indicators, etc.) automatically use them.
///   - Register the ThemeColor extension so context.colors works everywhere.
class Themes {
  static ThemeData light = ThemeData.light().copyWith(
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
      },
    ),
    colorScheme: ThemeData.light().colorScheme.copyWith(
      primary: TenantConfig().primaryColor,
      secondary: TenantConfig().accentColor,
      error: TenantConfig().errorColor,
    ),
    extensions: <ThemeExtension<dynamic>>[
      lightThemeColors,
    ],
  );

  static ThemeData dark = ThemeData.dark().copyWith(
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
      },
    ),
    colorScheme: ThemeData.dark().colorScheme.copyWith(
      primary: TenantConfig().primaryColor,
      secondary: TenantConfig().accentColor,
      error: TenantConfig().errorColor,
    ),
    extensions: <ThemeExtension<dynamic>>[
      darkThemeColors,
    ],
  );
}
