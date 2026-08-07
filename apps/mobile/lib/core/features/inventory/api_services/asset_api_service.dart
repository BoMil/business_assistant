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
    // TODO: temporary mock data for UI testing — remove and let the real
    // Dio call below run once the Business API is reachable.
    await Future.delayed(const Duration(milliseconds: 500));
    return ApiResponse.completed(_mockAssets());

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

  /// Temporary mock data — remove once the Business API is reachable (see
  /// the TODO in getAssets() above). Ids match the ones used by
  /// EventApiService's mock events (a1/a2).
  List<AssetResponse> _mockAssets() {
    return [
      AssetResponse(id: 'a1', name: 'Tiffany Stolice', category: 'Nameštaj', stockCount: 100, rentalPrice: 50),
      AssetResponse(id: 'a2', name: 'Barski Stolovi', category: 'Nameštaj', stockCount: 20, rentalPrice: 30),
      AssetResponse(id: 'a3', name: 'Šator 6x12', category: 'Šatori', stockCount: 4, rentalPrice: 400),
      AssetResponse(id: 'a4', name: 'Zvučni sistem', category: 'Ozvučenje', stockCount: 3, rentalPrice: 150),
    ];
  }
}
