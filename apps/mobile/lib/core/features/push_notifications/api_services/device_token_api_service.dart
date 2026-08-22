import 'package:dio/dio.dart';
import 'package:business_assistant/config/constants/api_endpoints.dart';
import 'package:business_assistant/core/utils/api/api_response.dart';
import 'package:business_assistant/core/utils/api/app_interceptor.dart';

class DeviceTokenApiService {
  final Dio dio;

  DeviceTokenApiService({Dio? dio}) : dio = dio ?? AppInterceptor().dio;

  Future<ApiResponse<bool>> registerDeviceToken(String token) async {
    try {
      await dio.post(APIEndpoints.deviceTokens, data: {'token': token});
      return ApiResponse.completed(true);
    } on DioException catch (e) {
      return ApiResponse.error(_messageFor(e));
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  Future<ApiResponse<bool>> removeDeviceToken(String token) async {
    try {
      await dio.delete(APIEndpoints.deviceTokens, data: {'token': token});
      return ApiResponse.completed(true);
    } on DioException catch (e) {
      return ApiResponse.error(_messageFor(e));
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  String _messageFor(DioException e) {
    if (e.type == DioExceptionType.connectionError) {
      return 'No internet connection. Check your connection and try again.';
    }
    final detail = e.response?.data is Map ? (e.response?.data['detail'] as String?) : null;
    return detail ?? 'Something went wrong. Please try again.';
  }
}
