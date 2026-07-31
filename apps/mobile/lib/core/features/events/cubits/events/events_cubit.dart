import 'package:business_assistant/core/features/events/api_services/event_api_service.dart';
import 'package:business_assistant/core/features/events/models/requests/events_request.dart';
import 'package:business_assistant/core/features/events/models/responses/event_response.dart';
import 'package:business_assistant/core/features/pagination/pagination_cubit_base.dart';
import 'package:business_assistant/core/shared/enums/cubit_state.dart';
import 'package:business_assistant/core/shared/models/base_multi_page_response.dart';
import 'package:business_assistant/core/utils/api/api_response.dart';
import 'package:business_assistant/core/utils/safe_emit_cubit_extension.dart';

part 'events_state.dart';

/// Drives the Events list page: a paginated, server-searched list of Rental
/// events. All paging/search mechanics (getNextPage/changeSearch/resetState)
/// live in PaginationCubitBase — this cubit only implements its 4 hooks.
class EventsCubit extends PaginationCubitBase<EventResponse, EventsState> {
  final EventApiService eventApiService;

  EventsCubit({EventApiService? eventApiService})
      : eventApiService = eventApiService ?? EventApiService(),
        super(EventsState(eventsResponse: BaseMultiPageResponse.empty()));

  static const int _pageSize = 20;

  Future<BaseMultiPageResponse<EventResponse>> _fetch({required bool clearOnLoad}) async {
    safeEmit(state.copyWith(
      currentState: CubitState.loading,
      eventsResponse: clearOnLoad ? BaseMultiPageResponse<EventResponse>.empty() : state.eventsResponse,
    ));

    final response = await eventApiService.getEvents(
      EventsRequest(page: page, pageSize: _pageSize, searchQuery: searchTerm.isEmpty ? null : searchTerm),
    );

    if (response.status == ResponseStatus.error) {
      if (page > 1) page--;
      safeEmit(state.copyWith(currentState: CubitState.error, errorMessage: response.message));
    }

    return response.data ?? BaseMultiPageResponse.empty();
  }

  @override
  Future<BaseMultiPageResponse<EventResponse>> getData() => _fetch(clearOnLoad: page == 1);

  @override
  Future<BaseMultiPageResponse<EventResponse>> getDataOnSearchChange() => _fetch(clearOnLoad: true);

  @override
  void emitStateChangeForPagination() {
    safeEmit(state.copyWith(currentState: CubitState.loaded, eventsResponse: data));
  }

  @override
  void emitStateChangeForSearch() {
    safeEmit(state.copyWith(currentState: CubitState.loaded, eventsResponse: data));
  }
}
