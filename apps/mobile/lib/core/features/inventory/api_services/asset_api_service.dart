import 'package:dio/dio.dart';
import 'package:business_assistant/config/constants/api_endpoints.dart';
import 'package:business_assistant/core/features/inventory/models/responses/asset_response.dart';
import 'package:business_assistant/core/utils/api/api_response.dart';
import 'package:business_assistant/core/utils/api/app_interceptor.dart';

/// Wraps Business API calls for Assets (GET /assets). Only read access is
/// needed for now — it backs the Events feature's "Add product" picker.
class AssetApiService {
  final Dio dio;

  AssetApiService({Dio? dio}) : dio = dio ?? AppInterceptor().businessDio;

  Future<ApiResponse<List<AssetResponse>>> getAssets() async {
    try {
      final response = await dio.get(APIEndpoints.assets);
      final assets = (response.data as List).map((json) => AssetResponse.fromJson(json)).toList();
      return ApiResponse.completed(assets);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        return ApiResponse.error('No internet connection. Check your connection and try again.');
      }
      return ApiResponse.error('Something went wrong. Please try again.');
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }
}
