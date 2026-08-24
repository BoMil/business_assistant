import 'package:dio/dio.dart';
import 'package:business_assistant/config/constants/api_endpoints.dart';
import 'package:business_assistant/core/utils/api/api_response.dart';
import 'package:business_assistant/core/utils/api/app_interceptor.dart';
import 'package:business_assistant/core/utils/api/dio_exception_handler.dart';

class DeviceTokenApiService {
  final Dio dio;

  DeviceTokenApiService({Dio? dio}) : dio = dio ?? AppInterceptor().dio;

  Future<ApiResponse<bool>> registerDeviceToken(String token) async {
    try {
      await dio.post(APIEndpoints.deviceTokens, data: {'token': token});
      return ApiResponse.completed(true);
    } on DioException catch (e) {
      return ApiResponse.error(DioExceptionHandler().handleError(e, dontDisplayToast: true));
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  Future<ApiResponse<bool>> removeDeviceToken(String token) async {
    try {
      await dio.delete(APIEndpoints.deviceTokens, data: {'token': token});
      return ApiResponse.completed(true);
    } on DioException catch (e) {
      return ApiResponse.error(DioExceptionHandler().handleError(e, dontDisplayToast: true));
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }
}
