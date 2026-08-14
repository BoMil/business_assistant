/// Compile-time environment constants — injected via --dart-define-from-file.
///
/// Example values per environment:
///   development: SERVER_ADDRESS = "http://10.0.2.2:5099"  (Android emulator → localhost)
///   staging:     SERVER_ADDRESS = "https://staging-api.businessassistant.com"
///   production:  SERVER_ADDRESS = "https://api.businessassistant.com"
///
/// 10.0.2.2 is the special Android emulator loopback that maps to the host machine's
/// localhost — use this when running the backend locally with Docker.
final class Environment {
  /// Base URL for the API Gateway — the single entrypoint for all backend calls.
  /// The gateway (apps/backend/gateway/Gateway.API) routes by path prefix
  /// (/identity/**, /business/**) to the actual microservices — the app itself
  /// never talks to them directly, see AppInterceptor.
  static const serverAddress =
      String.fromEnvironment('SERVER_ADDRESS', defaultValue: 'http://10.0.2.2:5099');

  /// One of 'DEV', 'STAGING', 'PRODUCTION' — used to suppress debug logs
  /// and enable/disable environment-specific behaviour.
  static const environment =
      String.fromEnvironment('ENVIRONMENT', defaultValue: 'DEV');

  /// Google Places API key for LocationInputField's address autocomplete.
  /// Empty by default — fill in your own key in .env/<tenant>.<environment>.json,
  /// it is intentionally not committed with a real value.
  static const googlePlacesApiKey =
      String.fromEnvironment('GOOGLE_PLACES_API_KEY', defaultValue: '');
}
