/// Compile-time feature flags — injected via --dart-define-from-file.
///
/// Each flag maps to a key in the tenant's .env JSON file, e.g.:
///   "FEATURE_BUSINESS": "true"
///
/// Defaults to true so every feature is visible during local development
/// even if the .env file is not provided.
class FeatureFlags {
  static final FeatureFlags _instance = FeatureFlags._internal();
  factory FeatureFlags() => _instance;
  FeatureFlags._internal();

  // ── UI / UX features ──────────────────────────────────────────────────────

  /// Allow users to toggle between light and dark theme in the app.
  final bool themeChange =
      const bool.fromEnvironment('FEATURE_THEME_CHANGE', defaultValue: true);

  /// Allow users to switch the app language (EN / SR).
  final bool language =
      const bool.fromEnvironment('FEATURE_LANGUAGE', defaultValue: true);

  // ── Domain features ───────────────────────────────────────────────────────

  /// Rental management module.
  final bool rental =
      const bool.fromEnvironment('FEATURE_RENTAL', defaultValue: true);

  /// Poultry farm tracking module (flocks, mortality, feed, health events).
  final bool poultry =
      const bool.fromEnvironment('FEATURE_POULTRY', defaultValue: true);

  /// Inventory management module.
  final bool inventory =
      const bool.fromEnvironment('FEATURE_INVENTORY', defaultValue: true);

  /// Reporting module — export and schedule PDF/Excel reports.
  final bool reporting =
      const bool.fromEnvironment('FEATURE_REPORTING', defaultValue: true);
}
