import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:business_assistant/core/features/clients/api_services/client_api_service.dart';
import 'package:business_assistant/core/features/clients/models/responses/client_response.dart';
import 'package:business_assistant/core/shared/enums/cubit_state.dart';
import 'package:business_assistant/core/utils/api/api_response.dart';
import 'package:business_assistant/core/utils/safe_emit_cubit_extension.dart';

part 'clients_state.dart';

/// Drives the Clients list page: an unpaginated (GET /clients returns
/// everything at once), client-side-searched list of Clients.
class ClientsCubit extends Cubit<ClientsState> {
  final ClientApiService clientApiService;

  ClientsCubit({ClientApiService? clientApiService})
      : clientApiService = clientApiService ?? ClientApiService(),
        super(const ClientsState());

  Future<void> loadClients() async {
    emit(state.copyWith(currentState: CubitState.loading));

    final response = await clientApiService.getClients();

    if (response.status == ResponseStatus.error) {
      safeEmit(state.copyWith(currentState: CubitState.error, errorMessage: response.message));
      return;
    }

    safeEmit(state.copyWith(currentState: CubitState.loaded, clients: response.data ?? []));
  }

  void changeSearch(String term) => safeEmit(state.copyWith(searchTerm: term));

  void resetState() {
    emit(const ClientsState());
    loadClients();
  }
}
