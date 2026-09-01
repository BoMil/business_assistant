part of 'event_preview_page_cubit.dart';

class EventPreviewPageState {
  final CubitState clientState;
  final ClientResponse? client;
  final String? errorMessage;

  const EventPreviewPageState({this.clientState = CubitState.initial, this.client, this.errorMessage});

  EventPreviewPageState copyWith({CubitState? clientState, ClientResponse? client, String? errorMessage}) {
    return EventPreviewPageState(
      clientState: clientState ?? this.clientState,
      client: client ?? this.client,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
