import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:business_assistant/core/features/clients/api_services/client_api_service.dart';
import 'package:business_assistant/core/features/clients/models/responses/client_response.dart';
import 'package:business_assistant/core/shared/enums/cubit_state.dart';
import 'package:business_assistant/core/utils/api/api_response.dart';
import 'package:business_assistant/core/utils/safe_emit_cubit_extension.dart';

part 'event_preview_page_state.dart';

/// Fetches the event's client by id when EventPreviewPage's caller didn't
/// already pass the client's name (e.g. opened from EventsPage, unlike
/// ClientEventsPage which already knows it and skips this fetch).
class EventPreviewPageCubit extends Cubit<EventPreviewPageState> {
  final ClientApiService clientApiService;

  EventPreviewPageCubit({ClientApiService? clientApiService})
      : clientApiService = clientApiService ?? ClientApiService(),
        super(const EventPreviewPageState());

  Future<void> loadClient(String clientId) async {
    safeEmit(state.copyWith(clientState: CubitState.loading));
    final response = await clientApiService.getClientById(clientId);
    if (response.status == ResponseStatus.error) {
      safeEmit(state.copyWith(clientState: CubitState.error, errorMessage: response.message));
      return;
    }
    safeEmit(state.copyWith(clientState: CubitState.loaded, client: response.data));
  }
}
