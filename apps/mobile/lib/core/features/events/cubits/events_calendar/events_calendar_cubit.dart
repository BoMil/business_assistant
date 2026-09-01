import 'package:business_assistant/core/features/events/api_services/event_api_service.dart';
import 'package:business_assistant/core/features/events/models/responses/event_response.dart';
import 'package:business_assistant/core/shared/enums/cubit_state.dart';
import 'package:business_assistant/core/utils/api/api_response.dart';
import 'package:business_assistant/core/utils/safe_emit_cubit_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'events_calendar_state.dart';

/// Drives the Events tab's Calendar view: fetches all events overlapping the
/// currently visible month (unpaginated — see EventApiService.getEventsByDateRange)
/// and groups them by day (a multi-day event appears under every day it spans)
/// for TableCalendar's per-cell rendering.
class EventsCalendarCubit extends Cubit<EventsCalendarState> {
  final EventApiService eventApiService;

  EventsCalendarCubit({EventApiService? eventApiService})
      : eventApiService = eventApiService ?? EventApiService(),
        super(EventsCalendarState(focusedMonth: DateTime.now()));

  Future<void> loadMonth(DateTime month) async {
    safeEmit(state.copyWith(currentState: CubitState.loading, focusedMonth: month));

    final from = DateTime(month.year, month.month, 1);
    final to = DateTime(month.year, month.month + 1, 1).subtract(const Duration(seconds: 1));

    final response = await eventApiService.getEventsByDateRange(from, to);

    if (response.status == ResponseStatus.error) {
      safeEmit(state.copyWith(currentState: CubitState.error, errorMessage: response.message));
      return;
    }

    final eventsByDay = <DateTime, List<EventResponse>>{};
    for (final event in response.data ?? <EventResponse>[]) {
      final start = event.from;
      final end = event.to ?? event.from;
      if (start == null || end == null) continue;

      var day = DateTime(start.year, start.month, start.day);
      final lastDay = DateTime(end.year, end.month, end.day);
      while (!day.isAfter(lastDay)) {
        eventsByDay.putIfAbsent(day, () => []).add(event);
        day = day.add(const Duration(days: 1));
      }
    }

    safeEmit(state.copyWith(currentState: CubitState.loaded, eventsByDay: eventsByDay));
  }
}
