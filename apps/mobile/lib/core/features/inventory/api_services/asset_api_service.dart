import 'package:dio/dio.dart';
import 'package:business_assistant/config/constants/api_endpoints.dart';
import 'package:business_assistant/core/features/inventory/models/requests/assets_request.dart';
import 'package:business_assistant/core/features/inventory/models/requests/create_asset_request.dart';
import 'package:business_assistant/core/features/inventory/models/requests/update_asset_request.dart';
import 'package:business_assistant/core/features/inventory/models/responses/asset_detail_response.dart';
import 'package:business_assistant/core/features/inventory/models/responses/asset_response.dart';
import 'package:business_assistant/core/features/inventory/models/responses/assets_paged_response.dart';
import 'package:business_assistant/core/utils/api/api_response.dart';
import 'package:business_assistant/core/utils/api/app_interceptor.dart';
import 'package:business_assistant/core/utils/api/dio_exception_handler.dart';

/// Wraps every Business API call for Assets (Inventory products) — also
/// backs the Events feature's "Add product" picker (getAssets()).
class AssetApiService {
  final Dio dio;

  AssetApiService({Dio? dio}) : dio = dio ?? AppInterceptor().dio;

  /// Full, unpaginated list — used by the Events feature's "Add product" picker.
  Future<ApiResponse<List<AssetResponse>>> getAssets() async {
    try {
      final response = await dio.get(APIEndpoints.assets);
      final assets = (response.data as List).map((json) => AssetResponse.fromJson(json)).toList();
      return ApiResponse.completed(assets);
    } on DioException catch (e) {
      return ApiResponse.error(DioExceptionHandler().handleError(e, dontDisplayToast: true));
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  /// Paginated, server-searched list — used by the Inventory list page.
  Future<ApiResponse<AssetsPagedResponse>> getAssetsPaged(AssetsRequest request) async {
    try {
      final response = await dio.get(APIEndpoints.assetsPaged, queryParameters: request.toQueryParameters());
      return ApiResponse.completed(AssetsPagedResponse.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResponse.error(DioExceptionHandler().handleError(e, dontDisplayToast: true));
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  Future<ApiResponse<AssetDetailResponse>> getAssetById(String id) async {
    try {
      final response = await dio.get(APIEndpoints.assetById(id));
      return ApiResponse.completed(AssetDetailResponse.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResponse.error(DioExceptionHandler().handleError(e, dontDisplayToast: true));
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  /// Returns the new asset's id on success.
  Future<ApiResponse<String>> createAsset(CreateAssetRequest request) async {
    try {
      final response = await dio.post(APIEndpoints.assets, data: request.toJson());
      return ApiResponse.completed(response.data.toString());
    } on DioException catch (e) {
      return ApiResponse.error(DioExceptionHandler().handleError(e, dontDisplayToast: true));
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  Future<ApiResponse<bool>> updateAsset(String id, UpdateAssetRequest request) async {
    try {
      await dio.put(APIEndpoints.assetById(id), data: request.toJson());
      return ApiResponse.completed(true);
    } on DioException catch (e) {
      return ApiResponse.error(DioExceptionHandler().handleError(e, dontDisplayToast: true));
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  Future<ApiResponse<bool>> removeAsset(String id) async {
    try {
      await dio.delete(APIEndpoints.assetById(id));
      return ApiResponse.completed(true);
    } on DioException catch (e) {
      return ApiResponse.error(DioExceptionHandler().handleError(e, dontDisplayToast: true));
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }
}
