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
    // TODO: temporary mock data for UI testing — remove and let the real
    // Dio call below run once the Business API is reachable.
    // await Future.delayed(const Duration(milliseconds: 500));
    // return ApiResponse.completed(_mockAssets());

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
    // TODO: temporary mock data for UI testing — remove and let the real
    // Dio call below run once the Business API is reachable.
    // await Future.delayed(const Duration(milliseconds: 500));
    // final asset = _mockAssets().firstWhere((a) => a.id == id, orElse: () => _mockAssets().first);
    // return ApiResponse.completed(
    //   AssetDetailResponse(
    //     id: asset.id,
    //     name: asset.name,
    //     categoryId: asset.categoryId,
    //     categoryName: asset.categoryName,
    //     description: asset.description,
    //     salePrice: asset.salePrice,
    //     rentalPrice: asset.rentalPrice,
    //     stockCount: asset.stockCount,
    //     currentlyReserved: 0,
    //     imgUrl: asset.imgUrl,
    //   ),
    // );

    try {
      final response = await dio.get(APIEndpoints.assetById(id));
      return ApiResponse.completed(AssetDetailResponse.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResponse.error(DioExceptionHandler().handleError(e, dontDisplayToast: true));
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  /// Temporary mock data — remove once the Business API is reachable (see
  /// the TODOs in getAssets()/getAssetById() above). Ids match the ones used
  /// by EventApiService's mock events (a1/a2).
  List<AssetResponse> _mockAssets() {
    return [
      AssetResponse(
        id: 'a1',
        name: 'Tiffany Stolice',
        categoryName: 'Nameštaj',
        stockCount: 100,
        rentalPrice: 50,
        imgUrl: 'https://picsum.photos/id/1060/400/300',
      ),
      AssetResponse(
        id: 'a2',
        name: 'Barski Stolovi',
        categoryName: 'Nameštaj',
        stockCount: 20,
        rentalPrice: 30,
        imgUrl: 'https://picsum.photos/id/1080/400/300',
      ),
      AssetResponse(
        id: 'a3',
        name: 'Šator 6x12',
        categoryName: 'Šatori',
        stockCount: 4,
        rentalPrice: 400,
        imgUrl: 'https://picsum.photos/id/1074/400/300',
      ),
      AssetResponse(
        id: 'a4',
        name: 'Zvučni sistem',
        categoryName: 'Ozvučenje',
        stockCount: 3,
        rentalPrice: 150,
        imgUrl: 'https://picsum.photos/id/1082/400/300',
      ),
    ];
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
