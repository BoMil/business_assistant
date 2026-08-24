import 'dart:io';
import 'package:dio/dio.dart';
import 'package:business_assistant/config/constants/api_endpoints.dart';
import 'package:business_assistant/core/utils/api/api_response.dart';
import 'package:business_assistant/core/utils/api/app_interceptor.dart';
import 'package:business_assistant/core/utils/api/dio_exception_handler.dart';

/// Uploads an image file and returns its blob URL — decoupled from any
/// specific entity (Asset, etc.) so it works for create flows too, where
/// there's no asset id yet to attach the image to.
class ImageApiService {
  final Dio dio;

  ImageApiService({Dio? dio}) : dio = dio ?? AppInterceptor().dio;

  Future<ApiResponse<String>> uploadImage(File file, {String? endpoint}) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
      });
      final response = await dio.post(endpoint ?? APIEndpoints.images, data: formData);
      return ApiResponse.completed(response.data.toString());
    } on DioException catch (e) {
      return ApiResponse.error(DioExceptionHandler().handleError(e, dontDisplayToast: true));
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }
}
