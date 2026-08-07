import 'package:dio/dio.dart';
import 'package:business_assistant/config/constants/api_endpoints.dart';
import 'package:business_assistant/core/features/clients/models/responses/client_response.dart';
import 'package:business_assistant/core/utils/api/api_response.dart';
import 'package:business_assistant/core/utils/api/app_interceptor.dart';

/// Wraps Business API calls for Clients (GET /clients). Only read access is
/// needed for now — it backs the Events feature's optional client picker.
class ClientApiService {
  final Dio dio;

  ClientApiService({Dio? dio}) : dio = dio ?? AppInterceptor().businessDio;

  Future<ApiResponse<List<ClientResponse>>> getClients() async {
    // TODO: temporary mock data for UI testing — remove and let the real
    // Dio call below run once the Business API is reachable.
    await Future.delayed(const Duration(milliseconds: 500));
    return ApiResponse.completed(_mockClients());

    try {
      final response = await dio.get(APIEndpoints.clients);
      final clients = (response.data as List).map((json) => ClientResponse.fromJson(json)).toList();
      return ApiResponse.completed(clients);
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
  /// the TODO in getClients() above).
  List<ClientResponse> _mockClients() {
    return [
      ClientResponse(id: 'c1', name: 'Marko Marković', phoneNumber: '+381641234567', email: 'marko@example.com'),
      ClientResponse(id: 'c2', name: 'Jovana Jovanović', phoneNumber: '+381621234567', email: 'jovana@example.com'),
      ClientResponse(id: 'c3', name: 'Firma Petrović DOO', phoneNumber: '+381631234567', email: 'office@petrovic.rs'),
    ];
  }
}
