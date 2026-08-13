/// All named route paths in the app.
///
/// go_router uses these string paths for navigation and redirect logic.
/// The router reads the auth state from AuthCubit and redirects accordingly:
///   - Unauthenticated → landingPage (or signupPage / loginPage / resetPassword)
///   - Authenticated   → first visible bottom nav tab (see bottom_nav_tabs.dart)
class RouteNames {
  // Splash screen shown while AuthCubit is initializing (AuthInitial state)
  static const String initialScreen = '/initial_screen';

  // ── Unauthenticated routes ────────────────────────────────────────────────
  static const String landingPage = '/landing_page';
  static const String signupPage = '/signup_page';
  static const String loginPage = '/login_page';
  static const String resetPassword = '/reset_password_page';

  // ── Authenticated routes (bottom navigation tabs) ─────────────────────────
  // Which of these are actually reachable depends on FeatureFlags — see
  // bottom_nav_tabs.dart.
  static const String eventsPage = '/events';
  static const String inventoryPage = '/inventory';
  static const String clientsPage = '/clients';

  // Always visible regardless of TenantModules — see bottom_nav_tabs.dart.
  static const String accountPage = '/account';

  // ── Event detail (pushed full-screen on top of the Events tab) ───────────
  static const String createEventPage = '/events/create';
  // Appended with '/:id' in routes.dart — use editEventPagePath(id) to build a
  // concrete path for navigation.
  static const String editEventPage = '/events/edit';
  static String editEventPagePath(String id) => '$editEventPage/$id';

  // ── Product detail (pushed full-screen on top of the Inventory tab) ─────
  static const String createAssetPage = '/inventory/create';
  // Appended with '/:id' in routes.dart — use editAssetPagePath(id) to build a
  // concrete path for navigation.
  static const String editAssetPage = '/inventory/edit';
  static String editAssetPagePath(String id) => '$editAssetPage/$id';
}
