import 'package:dio/dio.dart';
import 'package:business_assistant/config/constants/api_endpoints.dart';
import 'package:business_assistant/core/features/clients/models/requests/create_client_request.dart';
import 'package:business_assistant/core/features/clients/models/requests/update_client_request.dart';
import 'package:business_assistant/core/features/clients/models/responses/client_response.dart';
import 'package:business_assistant/core/features/events/models/responses/event_response.dart';
import 'package:business_assistant/core/utils/api/api_response.dart';
import 'package:business_assistant/core/utils/api/app_interceptor.dart';
import 'package:business_assistant/core/utils/api/dio_exception_handler.dart';

/// Wraps every Business API call for Clients.
class ClientApiService {
  final Dio dio;

  ClientApiService({Dio? dio}) : dio = dio ?? AppInterceptor().dio;

  Future<ApiResponse<List<ClientResponse>>> getClients() async {
    // TODO: temporary mock data for UI testing — remove and let the real
    // Dio call below run once the Business API is reachable.
    // await Future.delayed(const Duration(milliseconds: 500));
    // return ApiResponse.completed(_mockClients());

    try {
      final response = await dio.get(APIEndpoints.clients);
      final clients = (response.data as List).map((json) => ClientResponse.fromJson(json)).toList();
      return ApiResponse.completed(clients);
    } on DioException catch (e) {
      return ApiResponse.error(DioExceptionHandler().handleError(e, dontDisplayToast: true));
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  Future<ApiResponse<ClientResponse>> getClientById(String id) async {
    try {
      final response = await dio.get(APIEndpoints.clientById(id));
      return ApiResponse.completed(ClientResponse.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResponse.error(DioExceptionHandler().handleError(e, dontDisplayToast: true));
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  /// Returns the new client's id on success.
  Future<ApiResponse<String>> createClient(CreateClientRequest request) async {
    try {
      final response = await dio.post(APIEndpoints.clients, data: request.toJson());
      return ApiResponse.completed(response.data.toString());
    } on DioException catch (e) {
      return ApiResponse.error(DioExceptionHandler().handleError(e, dontDisplayToast: true));
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  Future<ApiResponse<bool>> updateClient(String id, UpdateClientRequest request) async {
    try {
      await dio.put(APIEndpoints.clientById(id), data: request.toJson());
      return ApiResponse.completed(true);
    } on DioException catch (e) {
      return ApiResponse.error(DioExceptionHandler().handleError(e, dontDisplayToast: true));
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  Future<ApiResponse<bool>> removeClient(String id) async {
    try {
      await dio.delete(APIEndpoints.clientById(id));
      return ApiResponse.completed(true);
    } on DioException catch (e) {
      return ApiResponse.error(DioExceptionHandler().handleError(e, dontDisplayToast: true));
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  Future<ApiResponse<List<EventResponse>>> getClientEvents(String id) async {
    try {
      final response = await dio.get(APIEndpoints.clientTransactions(id));
      final events = (response.data as List).map((json) => EventResponse.fromJson(json)).toList();
      return ApiResponse.completed(events);
    } on DioException catch (e) {
      return ApiResponse.error(DioExceptionHandler().handleError(e, dontDisplayToast: true));
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }
}
