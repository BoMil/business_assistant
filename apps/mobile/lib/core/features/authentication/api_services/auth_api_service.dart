import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:business_assistant/config/constants/api_endpoints.dart';
import 'package:business_assistant/core/features/authentication/models/requests/login_request.dart';
import 'package:business_assistant/core/features/authentication/models/responses/login_response.dart';
import 'package:business_assistant/core/utils/api/api_response.dart';
import 'package:business_assistant/core/utils/api/app_interceptor.dart';

/// Wraps every authentication-related HTTP call (POST /auth/login, ...).
///
/// Cubits call this service and only see an ApiResponse — all DioException
/// handling (network errors, invalid credentials, etc.) lives here so cubits
/// stay free of HTTP-specific logic.
class AuthApiService {
  final Dio dio;

  AuthApiService({Dio? dio}) : dio = dio ?? AppInterceptor().dio;

  Future<ApiResponse<LoginResponse>> login(LoginRequest request) async {
    try {
      // await Future.delayed(const Duration(seconds: 2));
      // return ApiResponse.completed(
      //   LoginResponse.fromJson({'accessToken': _mockAccessToken(), 'refreshToken': 'mock-refresh-token'}),
      // );
      final response = await dio.post(APIEndpoints.login, data: request.toJson());
      return ApiResponse.completed(LoginResponse.fromJson(response.data));
    } on DioException catch (e) {
      // 400/401 means invalid credentials — anything else is a server/network error
      if (e.type == DioExceptionType.connectionError) {
        return ApiResponse.error('No internet connection. Check your connection and try again.');
      }
      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        return ApiResponse.error('Invalid email or password. Please try again.');
      }
      return ApiResponse.error('Something went wrong. Please try again.');
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  /// Builds a structurally valid, unsigned JWT for local testing — carries the
  /// claims AuthCubit reads (sub, email, firstName, role, tenantId, exp) with
  /// exp 1 hour out, so token-validity checks pass without a real Identity server.
  String _mockAccessToken() {
    final header = _base64UrlEncodeNoPad({'alg': 'HS256', 'typ': 'JWT'});
    final exp = DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000;
    final payload = _base64UrlEncodeNoPad({
      'sub': '11111111-1111-1111-1111-111111111111',
      'email': 'test@example.com',
      'firstName': 'John',
      'role': 'Owner',
      'tenantId': '22222222-2222-2222-2222-222222222222',
      'exp': exp,
    });
    return '$header.$payload.mock-signature';
  }

  String _base64UrlEncodeNoPad(Map<String, dynamic> json) {
    return base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  }
}
