import 'dart:io';
import 'package:dio/dio.dart';
import 'package:business_assistant/config/constants/api_endpoints.dart';
import 'package:business_assistant/core/utils/api/api_response.dart';
import 'package:business_assistant/core/utils/api/app_interceptor.dart';

/// Uploads an image file and returns its blob URL — decoupled from any
/// specific entity (Asset, etc.) so it works for create flows too, where
/// there's no asset id yet to attach the image to.
class ImageApiService {
  final Dio dio;

  ImageApiService({Dio? dio}) : dio = dio ?? AppInterceptor().businessDio;

  Future<ApiResponse<String>> uploadImage(File file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
      });
      final response = await dio.post(APIEndpoints.images, data: formData);
      return ApiResponse.completed(response.data.toString());
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
