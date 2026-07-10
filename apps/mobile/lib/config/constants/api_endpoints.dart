/// All API endpoint paths used by Dio.
///
/// These are relative paths — the base URL comes from Environment.serverAddress.
/// Dio prepends it automatically via BaseOptions.baseUrl.
///
/// Identity microservice endpoints:
///   POST /auth/login           → returns accessToken + refreshToken
///   POST /auth/refresh-token   → exchanges refreshToken for a new accessToken
class APIEndpoints {
  static String login = '/auth/login';
  static String refreshToken = '/auth/refresh-token';
}
