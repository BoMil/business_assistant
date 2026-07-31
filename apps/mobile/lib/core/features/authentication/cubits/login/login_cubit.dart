import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:business_assistant/config/constants/secure_storage_keys.dart';
import 'package:business_assistant/core/features/authentication/api_services/auth_api_service.dart';
import 'package:business_assistant/core/features/authentication/models/requests/login_request.dart';
import 'package:business_assistant/core/features/authentication/models/responses/login_response.dart';
import 'package:business_assistant/core/shared/enums/cubit_state.dart';
import 'package:business_assistant/core/utils/api/api_response.dart';

part 'login_state.dart';

/// Manages the in-flight state of a single login attempt.
///
/// This cubit lives only for the duration of the LoginPage — it is provided
/// by LoginPage itself via BlocProvider and disposed when the page is popped.
///
/// All HTTP/DioException handling lives in AuthApiService — this cubit only
/// calls it and translates the resulting ApiResponse into LoginState.
///
/// On success, the LoginPage BlocListener calls
/// AuthCubit.loginUserToApp(state.loginResponse!) to persist tokens and change
/// the global auth state — which triggers GoRouter's redirect.
class LoginCubit extends Cubit<LoginState> {
  final AuthApiService authApiService;

  LoginCubit({AuthApiService? authApiService})
      : authApiService = authApiService ?? AuthApiService(),
        super(const LoginState());

  static const _secureStorage = FlutterSecureStorage();

  /// Whether "Remember me" is currently checked — set by the page's checkbox.
  bool remember = false;

  /// Sends POST /auth/login with [email] and [password].
  Future<void> login({required String email, required String password}) async {
    emit(state.copyWith(currentState: CubitState.loading, errorMessage: null));

    final response = await authApiService.login(LoginRequest(email: email, password: password));

    if (response.status == ResponseStatus.completed) {
      emit(state.copyWith(currentState: CubitState.loaded, loginResponse: response.data));
    }

    if (response.status == ResponseStatus.error) {
      emit(state.copyWith(currentState: CubitState.error, errorMessage: response.message));
    }
  }

  /// Reads previously-remembered credentials from secure storage, if any.
  Future<({String email, String password, bool remember})> loadSavedCredentials() async {
    try {
      final savedEmail = await _secureStorage.read(key: SecureStorageKeys.email) ?? '';
      final savedPassword = await _secureStorage.read(key: SecureStorageKeys.password) ?? '';
      remember = (await _secureStorage.read(key: SecureStorageKeys.rememberMe)) == 'true';
      return (email: savedEmail, password: savedPassword, remember: remember);
    } catch (e) {
      debugPrint('❌ loadSavedCredentials failed: ${e.toString()}');
      return (email: '', password: '', remember: false);
    }
  }

  /// Persists [email]/[password] so they're pre-filled on the next login.
  Future<void> rememberMe({required String email, required String password}) async {
    try {
      await _secureStorage.write(key: SecureStorageKeys.email, value: email);
      await _secureStorage.write(key: SecureStorageKeys.password, value: password);
      await _secureStorage.write(key: SecureStorageKeys.rememberMe, value: remember.toString());
    } catch (e) {
      debugPrint('❌ rememberMe failed: ${e.toString()}');
    }
  }

  /// Clears any previously-remembered credentials.
  Future<void> deleteCredentials() async {
    try {
      await _secureStorage.delete(key: SecureStorageKeys.email);
      await _secureStorage.delete(key: SecureStorageKeys.password);
      await _secureStorage.delete(key: SecureStorageKeys.rememberMe);
    } catch (e) {
      debugPrint('❌ deleteCredentials failed: ${e.toString()}');
    }
  }
}
