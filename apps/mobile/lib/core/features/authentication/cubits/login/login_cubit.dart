import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:business_assistant/config/constants/api_endpoints.dart';
import 'package:business_assistant/core/features/authentication/models/requests/login_request.dart';
import 'package:business_assistant/core/features/authentication/models/responses/login_response.dart';
import 'package:business_assistant/core/utils/api/api_response.dart';
import 'package:business_assistant/core/utils/api/app_interceptor.dart';

/// Manages the in-flight state of a single login attempt.
///
/// This cubit lives only for the duration of the LoginPage — it is provided
/// by LoginPage itself via BlocProvider and disposed when the page is popped.
///
/// State type: ApiResponse<LoginResponse>?
///   null       → idle, no request sent yet (initial state)
///   loading    → POST /auth/login is in flight
///   completed  → server returned tokens in a LoginResponse
///   error      → request failed (network or invalid credentials)
///
/// On success, the LoginPage BlocListener calls
/// AuthCubit.loginUserToApp(state.data!) to persist tokens and change
/// the global auth state — which triggers GoRouter's redirect.
class LoginCubit extends Cubit<ApiResponse<LoginResponse>?> {
  LoginCubit() : super(null);

  /// Sends POST /auth/login with [email] and [password].
  ///
  /// Uses the AppInterceptor singleton's Dio instance (base URL + TLS bypass
  /// already configured). Emits loading → completed or error.
  Future<void> login({required String email, required String password}) async {
    emit(ApiResponse.loading(''));

    try {
      final response = await AppInterceptor().dio.post(
        APIEndpoints.login,
        data: LoginRequest(email: email, password: password).toJson(),
      );

      emit(ApiResponse.completed(LoginResponse.fromJson(response.data)));
    } on DioException catch (e) {
      // 400/401 means invalid credentials — anything else is a server/network error
      if (e.type == DioExceptionType.connectionError) {
        emit(ApiResponse.error(
          'No internet connection. Check your connection and try again.',
        ));
      } else if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        emit(ApiResponse.error('Invalid email or password. Please try again.'));
      } else {
        emit(ApiResponse.error('Something went wrong. Please try again.'));
      }
    } catch (e) {
      emit(ApiResponse.error('Something went wrong. Please try again.'));
    }
  }
}
