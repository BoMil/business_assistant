import 'package:flutter/material.dart';

/// Singleton that exposes compile-time tenant customization.
///
/// Values are baked in at build time via:
///   flutter run --dart-define-from-file=.env/demo.development.json
///
/// Each tenant (demo, acme, …) has its own JSON file in .env/ and its own
/// asset folder in assets/tenants/<tenantId>/.
/// On CI, set_tenant_branding.sh selects the right file before the build.
class TenantConfig {
  // Singleton boilerplate — only one instance exists for the lifetime of the app.
  static final TenantConfig _instance = TenantConfig._internal();
  factory TenantConfig() => _instance;
  TenantConfig._internal();

  /// Unique tenant slug — used to look up assets and sent to the API.
  /// Defaults to 'demo' so local runs without a .env file still work.
  final String tenantId =
      const String.fromEnvironment('TENANT_ID', defaultValue: 'demo');

  /// Display name shown in the app bar, splash screen, etc.
  final String appName =
      const String.fromEnvironment('APP_NAME', defaultValue: 'Business Assistant');

  /// Android applicationId — must match what was used to sign the APK.
  final String packageName = const String.fromEnvironment(
    'PACKAGE_NAME',
    defaultValue: 'com.businessassistant.demo',
  );

  // Color hex strings must be static const so they can be used in Color() at
  // field initializer time (before the constructor body runs).
  static const String _primaryColorHex =
      String.fromEnvironment('PRIMARY_COLOR', defaultValue: 'FF1A237E');
  static const String _accentColorHex =
      String.fromEnvironment('ACCENT_COLOR', defaultValue: 'FF00BCD4');
  static const String _errorColorHex =
      String.fromEnvironment('ERROR_COLOR', defaultValue: 'FFEB2E25');

  /// Deep navy blue — used for buttons, active states, primary brand elements.
  final Color primaryColor = Color(int.parse(_primaryColorHex, radix: 16));

  /// Cyan accent — used for highlights and secondary interactive elements.
  final Color accentColor = Color(int.parse(_accentColorHex, radix: 16));

  /// Red error — used for error states and destructive actions.
  final Color errorColor = Color(int.parse(_errorColorHex, radix: 16));

  /// Path to the tenant's SVG logo inside the Flutter asset bundle.
  String get logoPath => 'assets/tenants/$tenantId/logo.svg';
}
