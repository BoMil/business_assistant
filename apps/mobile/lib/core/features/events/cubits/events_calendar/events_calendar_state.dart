part of 'events_calendar_cubit.dart';

class EventsCalendarState {
  final CubitState currentState;
  final DateTime focusedMonth;
  final Map<DateTime, List<EventResponse>> eventsByDay;
  final String? errorMessage;

  const EventsCalendarState({
    this.currentState = CubitState.initial,
    required this.focusedMonth,
    this.eventsByDay = const {},
    this.errorMessage,
  });

  EventsCalendarState copyWith({
    CubitState? currentState,
    DateTime? focusedMonth,
    Map<DateTime, List<EventResponse>>? eventsByDay,
    String? errorMessage,
  }) {
    return EventsCalendarState(
      currentState: currentState ?? this.currentState,
      focusedMonth: focusedMonth ?? this.focusedMonth,
      eventsByDay: eventsByDay ?? this.eventsByDay,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
