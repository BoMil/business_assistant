part of 'client_events_cubit.dart';

class ClientEventsState {
  final CubitState currentState;
  final List<EventResponse> events;
  final String? errorMessage;

  const ClientEventsState({
    this.currentState = CubitState.initial,
    this.events = const [],
    this.errorMessage,
  });

  ClientEventsState copyWith({
    CubitState? currentState,
    List<EventResponse>? events,
    String? errorMessage,
  }) {
    return ClientEventsState(
      currentState: currentState ?? this.currentState,
      events: events ?? this.events,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
