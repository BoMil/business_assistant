import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:business_assistant/config/constants/secure_storage_keys.dart';
import 'package:business_assistant/core/features/authentication/models/enums/user_role.dart';
import 'package:business_assistant/core/features/authentication/models/responses/login_response.dart';
import 'package:jwt_decode/jwt_decode.dart';
part 'auth_state.dart';

/// Manages the app-wide authentication state.
///
/// Flow:
///   1. App starts → initAuthState() reads the stored token.
///   2. Token valid (exists + not expired) → emit Authenticated().
///   3. Token missing or expired → logout() → emit Unauthenticated().
///   4. User logs in → loginUserToApp() saves tokens → emit Authenticated().
///   5. User logs out → logout() clears tokens → emit Unauthenticated().
///
/// GoRouter listens to this cubit's stream via StreamToListenable and re-runs
/// its redirect logic every time the state changes.
class AuthCubit extends Cubit<AuthState> {
  final FlutterSecureStorage secureStorage;

  AuthCubit({required this.secureStorage}) : super(AuthInitial());

  /// Used by GoRouter's redirect to know whether to redirect to homePage
  /// on the very first Authenticated emission (avoids a redundant redirect loop).
  bool redirectToHomeInitialy = true;

  /// First name parsed from the JWT's 'firstName' claim — used for header greetings.
  String? currentUserFirstName;

  /// Role parsed from the JWT's 'role' claim — used to gate Owner/Admin-only actions.
  UserRole? currentUserRole;

  /// Owner and Admin can add/edit/delete Inventory products — Member is view-only.
  bool get canManageInventory => currentUserRole == UserRole.owner || currentUserRole == UserRole.admin;

  /// Called once in MyApp.initState() — checks the stored token and emits
  /// Authenticated or Unauthenticated accordingly.
  Future<void> initAuthState() async {
    redirectToHomeInitialy = true;
    bool isValid = await _isTokenValidAndNotExpired();
    debugPrint('[AuthCubit] initAuthState — token valid: $isValid');

    if (isValid) {
      emit(Authenticated());
    } else {
      logout();
    }
  }

  /// Called after a successful POST /auth/login response.
  ///
  /// Saves both tokens to secure storage and validates the access token before
  /// emitting Authenticated, so a malformed server response can't bypass auth.
  Future<void> loginUserToApp(LoginResponse loginResponse) async {
    bool isValid = false;
    try {
      await secureStorage.write(
        key: SecureStorageKeys.tokenKey,
        value: loginResponse.accessToken,
      );
      await secureStorage.write(
        key: SecureStorageKeys.refreshTokenKey,
        value: loginResponse.refreshToken,
      );
      isValid = await _isTokenValidAndNotExpired();
    } catch (e) {
      debugPrint('[AuthCubit] loginUserToApp — failed to save tokens: $e');
    }

    if (isValid) {
      emit(Authenticated());
    } else {
      logout();
    }
  }

  /// Clears stored tokens and emits Unauthenticated.
  /// GoRouter's redirect will send the user to landing_page.
  Future<void> logout() async {
    redirectToHomeInitialy = true;
    currentUserFirstName = null;
    currentUserRole = null;
    await _clearStorage();
    emit(Unauthenticated());
  }

  Future<void> _clearStorage() async {
    try {
      await secureStorage.delete(key: SecureStorageKeys.tokenKey);
      await secureStorage.delete(key: SecureStorageKeys.refreshTokenKey);
    } catch (e) {
      debugPrint('[AuthCubit] _clearStorage — failed: $e');
    }
  }

  /// Returns true if a token exists in storage AND its 'exp' claim is in the future.
  ///
  /// JWT payload from the Identity service contains:
  ///   sub       → user ID (GUID)
  ///   email     → user email
  ///   firstName → user's first name, shown in header greetings
  ///   role      → user role string (e.g. "Owner")
  ///   tenantId  → tenant GUID
  ///   exp       → Unix timestamp of expiry (standard JWT claim)
  ///
  /// We only check existence + expiry here. Role-based access control is
  /// enforced by the API — the app trusts that any non-expired token is valid.
  Future<bool> _isTokenValidAndNotExpired() async {
    try {
      String? token = await secureStorage.read(key: SecureStorageKeys.tokenKey);

      if (token == null || token.isEmpty) return false;

      Map<String, dynamic> payload = Jwt.parseJwt(token);

      // 'exp' is a Unix timestamp in seconds. Jwt.isExpired() wraps this check.
      if (Jwt.isExpired(token)) {
        debugPrint('[AuthCubit] Token is expired.');
        return false;
      }

      // Sanity check — make sure 'sub' (user ID) is present
      if (payload['sub'] == null) {
        debugPrint('[AuthCubit] Token missing sub claim.');
        return false;
      }

      try {
        currentUserFirstName = payload['firstName'] as String?;
      } catch (e) {
        debugPrint('[AuthCubit] Failed to parse first name error: $e');
      }

      try {
        currentUserRole = userRoleFromString(payload['role'] as String?);
      } catch (e) {
        debugPrint('[AuthCubit] Failed to parse role error: $e');
      }

      return true;
    } catch (e) {
      debugPrint('[AuthCubit] _isTokenValidAndNotExpired error: $e');
      return false;
    }
  }
}
