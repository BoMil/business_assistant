part of 'clients_cubit.dart';

class ClientsState {
  final CubitState currentState;
  final List<ClientResponse> clients;
  final String searchTerm;
  final String? errorMessage;

  const ClientsState({
    this.currentState = CubitState.initial,
    this.clients = const [],
    this.searchTerm = '',
    this.errorMessage,
  });

  /// Case-insensitive match on name/phoneNumber/email/locationAddress —
  /// filtered client-side since GET /clients has no search query param.
  List<ClientResponse> get filteredClients {
    final query = searchTerm.trim().toLowerCase();
    if (query.isEmpty) return clients;

    return clients.where((client) {
      return client.name.toLowerCase().contains(query) ||
          client.phoneNumber.toLowerCase().contains(query) ||
          client.email.toLowerCase().contains(query) ||
          (client.locationAddress ?? '').toLowerCase().contains(query);
    }).toList();
  }

  ClientsState copyWith({
    CubitState? currentState,
    List<ClientResponse>? clients,
    String? searchTerm,
    String? errorMessage,
  }) {
    return ClientsState(
      currentState: currentState ?? this.currentState,
      clients: clients ?? this.clients,
      searchTerm: searchTerm ?? this.searchTerm,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
