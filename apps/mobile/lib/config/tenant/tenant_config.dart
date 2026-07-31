import 'package:business_assistant/config/tenant/tenant_type.dart';

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

  /// Path to the tenant's SVG logo inside the Flutter asset bundle.
  String get logoPath => 'assets/tenants/$tenantId/logo.svg';

  /// What kind of business this tenant runs — see tenant_type.dart.
  static const String _tenantTypeRaw =
      String.fromEnvironment('TENANT_TYPE', defaultValue: 'Rental');
  final TenantType tenantType = tenantTypeFromString(_tenantTypeRaw);
}
