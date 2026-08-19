import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:business_assistant/core/features/clients/api_services/client_api_service.dart';
import 'package:business_assistant/core/features/events/models/responses/event_response.dart';
import 'package:business_assistant/core/shared/enums/cubit_state.dart';
import 'package:business_assistant/core/utils/api/api_response.dart';

part 'client_events_state.dart';

/// Drives ClientEventsPage — a plain, read-only list of one client's events
/// (GET /clients/{id}/transactions).
class ClientEventsCubit extends Cubit<ClientEventsState> {
  final String clientId;
  final ClientApiService clientApiService;

  ClientEventsCubit({required this.clientId, ClientApiService? clientApiService})
      : clientApiService = clientApiService ?? ClientApiService(),
        super(const ClientEventsState());

  Future<void> loadEvents() async {
    emit(state.copyWith(currentState: CubitState.loading));

    final response = await clientApiService.getClientEvents(clientId);

    if (response.status == ResponseStatus.error) {
      emit(state.copyWith(currentState: CubitState.error, errorMessage: response.message));
      return;
    }

    emit(state.copyWith(currentState: CubitState.loaded, events: response.data ?? []));
  }
}
