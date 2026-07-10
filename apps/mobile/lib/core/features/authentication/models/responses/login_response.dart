/// Response body from POST /auth/login and POST /auth/refresh-token.
///
/// The Identity API returns:
///   { "accessToken": "...", "refreshToken": "..." }
///
/// Note: the template app uses 'token' as the field name — our backend uses
/// 'accessToken'. Both are stored under SecureStorageKeys.tokenKey locally
/// so the rest of the app doesn't need to know the API field name.
class LoginResponse {
  late String accessToken;
  late String refreshToken;

  LoginResponse.fromJson(Map<String, dynamic> json) {
    accessToken = json['accessToken'] ?? '';
    refreshToken = json['refreshToken'] ?? '';
  }
}
