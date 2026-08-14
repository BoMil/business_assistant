import 'package:dio/dio.dart';
import 'package:business_assistant/config/constants/api_endpoints.dart';
import 'package:business_assistant/core/features/events/models/enums/event_status.dart';
import 'package:business_assistant/core/features/events/models/requests/create_event_request.dart';
import 'package:business_assistant/core/features/events/models/requests/events_request.dart';
import 'package:business_assistant/core/features/events/models/requests/update_event_request.dart';
import 'package:business_assistant/core/features/events/models/responses/event_asset_response.dart';
import 'package:business_assistant/core/features/events/models/responses/event_response.dart';
import 'package:business_assistant/core/features/events/models/responses/events_paged_response.dart';
import 'package:business_assistant/core/utils/api/api_response.dart';
import 'package:business_assistant/core/utils/api/app_interceptor.dart';

/// Wraps every Business API call for Events (TransactionType.Rental transactions).
///
/// deleteEvent() calls DELETE /transactions/{id}, which does not exist on the
/// Business API yet (only CancelTransaction — a soft cancel — is implemented
/// server-side). It will fail with a 404 until a RemoveTransaction use case
/// is added on the backend.
class EventApiService {
  final Dio dio;

  EventApiService({Dio? dio}) : dio = dio ?? AppInterceptor().dio;

  Future<ApiResponse<EventsPagedResponse>> getEvents(EventsRequest request) async {
    // TODO: temporary mock data for UI testing — remove and let the real
    // Dio call below run once the Business API is reachable.
    await Future.delayed(const Duration(milliseconds: 500));
    return ApiResponse.completed(_mockPagedEvents(request));

    try {
      final response = await dio.get(APIEndpoints.transactions, queryParameters: request.toQueryParameters());
      return ApiResponse.completed(EventsPagedResponse.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResponse.error(_messageFor(e));
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  Future<ApiResponse<EventResponse>> getEventById(String id) async {
    // TODO: temporary mock data for UI testing — remove and let the real
    // Dio call below run once the Business API is reachable.
    await Future.delayed(const Duration(milliseconds: 500));
    final event = _mockEvents().firstWhere((e) => e.id == id, orElse: () => _mockEvents().first);
    return ApiResponse.completed(event);

    try {
      final response = await dio.get(APIEndpoints.transactionById(id));
      return ApiResponse.completed(EventResponse.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResponse.error(_messageFor(e));
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  /// Applies the same search + paging semantics the real endpoint would, over
  /// the in-memory mock list — so pagination/search UX can be tested without
  /// a live backend. Remove alongside _mockEvents() once the API is reachable.
  EventsPagedResponse _mockPagedEvents(EventsRequest request) {
    final query = (request.searchQuery ?? '').trim().toLowerCase();
    final filtered =
        query.isEmpty
            ? _mockEvents()
            : _mockEvents().where((event) {
              if (event.title.toLowerCase().contains(query)) return true;
              return (event.locationAddress ?? '').toLowerCase().contains(query);
            }).toList();

    final start = (request.page - 1) * request.pageSize;
    final end = (start + request.pageSize).clamp(0, filtered.length);
    final pageItems = start >= filtered.length ? <EventResponse>[] : filtered.sublist(start, end);
    final totalPages = (filtered.length / request.pageSize).ceil();

    return EventsPagedResponse(
      pageIndex: request.page,
      count: filtered.length,
      totalPages: totalPages,
      items: pageItems,
      hasPreviousPage: request.page > 1,
      hasNextPage: request.page < totalPages,
    );
  }

  /// Temporary mock data — remove once the Business API is reachable (see
  /// the TODOs in getEvents/getEventById above).
  List<EventResponse> _mockEvents() {
    final now = DateTime(2026, 7, 19);
    return [
      EventResponse(
        id: '11111111-1111-1111-1111-111111111111',
        title: 'Wedding Setup',
        description: 'Full outdoor wedding setup — tables, chairs, lighting.',
        from: now.add(const Duration(days: 5)),
        to: now.add(const Duration(days: 6)),
        locationAddress: 'Sremska 45, Novi Sad',
        locationLatitude: 45.2551,
        locationLongitude: 19.8451,
        status: EventStatus.pending,
        eventAssets: [
          EventAssetResponse(assetId: 'a1', assetName: 'Tiffany Stolice', quantity: 25, price: 50),
          EventAssetResponse(assetId: 'a2', assetName: 'Barski Stolovi', quantity: 5, price: 30),
        ],
      ),
      EventResponse(
        id: '22222222-2222-2222-2222-222222222222',
        title: 'Birthday Party',
        description: 'Backyard birthday party rental.',
        from: now.subtract(const Duration(days: 1)),
        to: now.add(const Duration(days: 1)),
        locationAddress: 'Bulevar Oslobođenja 12, Novi Sad',
        locationLatitude: 45.2496,
        locationLongitude: 19.8419,
        status: EventStatus.inProgress,
        eventAssets: [EventAssetResponse(assetId: 'a2', assetName: 'Barski Stolovi', quantity: 10, price: 30)],
      ),
      EventResponse(
        id: '33333333-3333-3333-3333-333333333333',
        title: 'Corporate Gala',
        description: null,
        from: now.subtract(const Duration(days: 20)),
        to: now.subtract(const Duration(days: 19)),
        locationAddress: 'Trg Slobode 1, Novi Sad',
        locationLatitude: 45.2671,
        locationLongitude: 19.8335,
        status: EventStatus.finished,
        eventAssets: [EventAssetResponse(assetId: 'a1', assetName: 'Tiffany Stolice', quantity: 50, price: 50)],
      ),
      EventResponse(
        id: '44444444-4444-4444-4444-444444444444',
        title: 'Canceled Reunion',
        description: 'Client canceled a week before.',
        from: now.add(const Duration(days: 10)),
        to: now.add(const Duration(days: 10)),
        locationAddress: 'Zeleznicka 8, Novi Sad',
        locationLatitude: 45.2603,
        locationLongitude: 19.8394,
        status: EventStatus.canceled,
        eventAssets: const [],
      ),
    ];
  }

  /// Returns the new event's id on success.
  Future<ApiResponse<String>> createEvent(CreateEventRequest request) async {
    try {
      final response = await dio.post(APIEndpoints.transactions, data: request.toJson());
      return ApiResponse.completed(response.data.toString());
    } on DioException catch (e) {
      return ApiResponse.error(_messageFor(e));
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  Future<ApiResponse<bool>> updateEvent(String id, UpdateEventRequest request) async {
    try {
      await dio.put(APIEndpoints.transactionById(id), data: request.toJson());
      return ApiResponse.completed(true);
    } on DioException catch (e) {
      return ApiResponse.error(_messageFor(e));
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  Future<ApiResponse<bool>> cancelEvent(String id) async {
    try {
      await dio.post(APIEndpoints.cancelTransaction(id));
      return ApiResponse.completed(true);
    } on DioException catch (e) {
      return ApiResponse.error(_messageFor(e));
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  Future<ApiResponse<bool>> deleteEvent(String id) async {
    try {
      await dio.delete(APIEndpoints.transactionById(id));
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
