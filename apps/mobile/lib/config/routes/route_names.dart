/// All named route paths in the app.
///
/// go_router uses these string paths for navigation and redirect logic.
/// The router reads the auth state from AuthCubit and redirects accordingly:
///   - Unauthenticated → landingPage (or signupPage / loginPage / resetPassword)
///   - Authenticated   → homePage
class RouteNames {
  // Splash screen shown while AuthCubit is initializing (AuthInitial state)
  static const String initialScreen = '/initial_screen';

  // ── Unauthenticated routes ────────────────────────────────────────────────
  static const String landingPage = '/landing_page';
  static const String signupPage = '/signup_page';
  static const String loginPage = '/login_page';
  static const String resetPassword = '/reset_password_page';

  // ── Authenticated routes ──────────────────────────────────────────────────
  static const String homePage = '/home_page';
}
