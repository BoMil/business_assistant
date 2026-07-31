/// Keys used to read/write from FlutterSecureStorage.
///
/// FlutterSecureStorage stores values in:
///   Android: Android Keystore-backed EncryptedSharedPreferences
///   iOS:     iOS Keychain
///
/// These string constants are the keys — the stored values are the tokens.
class SecureStorageKeys {
  /// The JWT access token returned by POST /auth/login or POST /auth/refresh-token.
  static const String tokenKey = 'token';

  /// The opaque refresh token used to get a new access token when the current one expires.
  static const String refreshTokenKey = 'refreshToken';

  /// Persisted theme preference — value is ThemeMode.name ('light' or 'dark').
  static const String themeMode = 'theme_mode';

  /// Saved login email — only written when the user checks "Remember me".
  static const String email = 'email';

  /// Saved login password — only written when the user checks "Remember me".
  static const String password = 'password';

  /// Whether the last login was saved with "Remember me" checked — value is 'true'/'false'.
  static const String rememberMe = 'rememberMe';
}
