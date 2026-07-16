/// Compile-time UX preferences — injected via --dart-define-from-file.
///
/// These are generic app-behavior toggles, the same regardless of tenant type —
/// unlike TenantModules (tenant_modules.dart), which controls which business
/// modules/tabs exist and is seeded differently per TenantType.
///
/// Defaults to true so both are available during local development even if the
/// .env file is not provided.
class FeatureFlags {
  static final FeatureFlags _instance = FeatureFlags._internal();
  factory FeatureFlags() => _instance;
  FeatureFlags._internal();

  /// Allow users to toggle between light and dark theme in the app.
  final bool themeChange =
      const bool.fromEnvironment('FEATURE_THEME_CHANGE', defaultValue: true);

  /// Allow users to switch the app language (EN / SR).
  final bool language =
      const bool.fromEnvironment('FEATURE_LANGUAGE', defaultValue: true);
}
