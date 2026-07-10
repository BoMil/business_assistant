/// Compile-time environment constants — injected via --dart-define-from-file.
///
/// Example values per environment:
///   development: SERVER_ADDRESS = "http://10.0.2.2:5100"  (Android emulator → localhost)
///   staging:     SERVER_ADDRESS = "https://staging-api.businessassistant.com"
///   production:  SERVER_ADDRESS = "https://api.businessassistant.com"
///
/// 10.0.2.2 is the special Android emulator loopback that maps to the host machine's
/// localhost — use this when running the backend locally with Docker.
final class Environment {
  /// Base URL for all API calls — no trailing slash.
  static const serverAddress =
      String.fromEnvironment('SERVER_ADDRESS', defaultValue: 'http://10.0.2.2:5100');

  /// One of 'DEV', 'STAGING', 'PRODUCTION' — used to suppress debug logs
  /// and enable/disable environment-specific behaviour.
  static const environment =
      String.fromEnvironment('ENVIRONMENT', defaultValue: 'DEV');
}
