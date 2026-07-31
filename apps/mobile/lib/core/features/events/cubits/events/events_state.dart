part of 'events_cubit.dart';

class EventsState {
  final CubitState currentState;
  final BaseMultiPageResponse<EventResponse> eventsResponse;
  final String? errorMessage;

  const EventsState({
    this.currentState = CubitState.initial,
    required this.eventsResponse,
    this.errorMessage,
  });

  EventsState copyWith({
    CubitState? currentState,
    BaseMultiPageResponse<EventResponse>? eventsResponse,
    String? errorMessage,
  }) {
    return EventsState(
      currentState: currentState ?? this.currentState,
      eventsResponse: eventsResponse ?? this.eventsResponse,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
