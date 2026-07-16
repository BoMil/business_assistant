/// Compile-time business module toggles — injected via --dart-define-from-file.
///
/// Unlike FeatureFlags (generic UX preferences, same for every tenant), these
/// are tied to the tenant's business domain: seeded from TenantType at
/// creation on the backend (see Identity's TenantModules.CreateDefaults), and
/// drive which tabs exist in the bottom navigation (see bottom_nav_tabs.dart).
///
/// Defaults to true so every module is visible during local development even
/// if the .env file is not provided — every real build's checked-in .env/*.json
/// always sets these explicitly, so the default only matters for ad-hoc
/// `flutter run` without --dart-define-from-file.
class TenantModules {
  static final TenantModules _instance = TenantModules._internal();
  factory TenantModules() => _instance;
  TenantModules._internal();

  final bool events =
      const bool.fromEnvironment('MODULE_EVENTS', defaultValue: true);

  final bool inventory =
      const bool.fromEnvironment('MODULE_INVENTORY', defaultValue: true);

  final bool clients =
      const bool.fromEnvironment('MODULE_CLIENTS', defaultValue: true);
}
