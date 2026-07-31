import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:business_assistant/core/features/clients/api_services/client_api_service.dart';
import 'package:business_assistant/core/features/clients/models/responses/client_response.dart';
import 'package:business_assistant/core/features/events/api_services/event_api_service.dart';
import 'package:business_assistant/core/features/events/models/enums/event_status.dart';
import 'package:business_assistant/core/features/events/models/requests/create_event_request.dart';
import 'package:business_assistant/core/features/events/models/requests/event_line_item_request.dart';
import 'package:business_assistant/core/features/events/models/requests/update_event_request.dart';
import 'package:business_assistant/core/features/inventory/api_services/asset_api_service.dart';
import 'package:business_assistant/core/features/inventory/models/responses/asset_response.dart';
import 'package:business_assistant/core/shared/enums/cubit_state.dart';
import 'package:business_assistant/core/shared/widgets/input_fields/location_input_field.dart';
import 'package:business_assistant/core/utils/api/api_response.dart';

part 'create_edit_event_state.dart';

/// Drives CreateEditEventPage — one cubit instance handles both creating a
/// new event (eventId == null) and editing an existing one (eventId set),
/// since the form and its validation are identical either way.
class CreateEditEventCubit extends Cubit<CreateEditEventState> {
  final String? eventId;
  final EventApiService eventApiService;
  final AssetApiService assetApiService;
  final ClientApiService clientApiService;

  CreateEditEventCubit({
    this.eventId,
    EventApiService? eventApiService,
    AssetApiService? assetApiService,
    ClientApiService? clientApiService,
  })  : eventApiService = eventApiService ?? EventApiService(),
        assetApiService = assetApiService ?? AssetApiService(),
        clientApiService = clientApiService ?? ClientApiService(),
        super(const CreateEditEventState());

  bool get isEditMode => eventId != null;

  /// Loads the asset/client pickers' options, and — in edit mode — the
  /// existing event's data to pre-fill the form.
  Future<void> loadFormData() async {
    emit(state.copyWith(currentState: CubitState.loading));

    final assetsResponse = await assetApiService.getAssets();
    if (assetsResponse.status == ResponseStatus.error) {
      emit(state.copyWith(currentState: CubitState.error, errorMessage: assetsResponse.message));
      return;
    }

    final clientsResponse = await clientApiService.getClients();
    if (clientsResponse.status == ResponseStatus.error) {
      emit(state.copyWith(currentState: CubitState.error, errorMessage: clientsResponse.message));
      return;
    }

    final availableAssets = assetsResponse.data ?? [];
    final availableClients = clientsResponse.data ?? [];

    if (!isEditMode) {
      emit(state.copyWith(
        currentState: CubitState.loaded,
        availableAssets: availableAssets,
        availableClients: availableClients,
      ));
      return;
    }

    final eventResponse = await eventApiService.getEventById(eventId!);
    if (eventResponse.status == ResponseStatus.error) {
      emit(state.copyWith(currentState: CubitState.error, errorMessage: eventResponse.message));
      return;
    }

    final event = eventResponse.data!;
    ClientResponse? matchedClient;
    for (final client in availableClients) {
      if (client.id == event.clientId) {
        matchedClient = client;
        break;
      }
    }

    emit(state.copyWith(
      currentState: CubitState.loaded,
      availableAssets: availableAssets,
      availableClients: availableClients,
      title: event.title,
      description: event.description ?? '',
      from: event.from,
      to: event.to,
      locationAddress: event.locationAddress ?? '',
      locationLatitude: event.locationLatitude,
      locationLongitude: event.locationLongitude,
      clientId: event.clientId,
      clientName: matchedClient?.name,
      lineItems: event.lineItems
          .map((li) => EventFormLineItem(assetId: li.assetId, assetName: li.assetName, quantity: li.quantity, price: li.price))
          .toList(),
      status: event.status,
    ));
  }

  void setTitle(String value) => emit(state.copyWith(title: value, isDirty: true));

  void setDescription(String value) => emit(state.copyWith(description: value, isDirty: true));

  void setFrom(DateTime? value) =>
      emit(state.copyWith(from: value, clearFrom: value == null, isDirty: true));

  void setTo(DateTime? value) => emit(state.copyWith(to: value, clearTo: value == null, isDirty: true));

  void setLocation(LocationOutput location) => emit(state.copyWith(
        locationAddress: location.address,
        locationLatitude: location.latitude,
        locationLongitude: location.longitude,
        isDirty: true,
      ));

  void selectClient(ClientResponse? client) => emit(state.copyWith(
        clientId: client?.id,
        clientName: client?.name,
        clearClient: client == null,
        isDirty: true,
      ));

  void addLineItem(AssetResponse asset) {
    if (state.lineItems.any((li) => li.assetId == asset.id)) return;
    final newItem = EventFormLineItem(
      assetId: asset.id,
      assetName: asset.name,
      quantity: 1,
      price: asset.rentalPrice ?? 0,
    );
    emit(state.copyWith(lineItems: [...state.lineItems, newItem], isDirty: true));
  }

  void removeLineItem(String assetId) {
    emit(state.copyWith(
      lineItems: state.lineItems.where((li) => li.assetId != assetId).toList(),
      isDirty: true,
    ));
  }

  void updateLineItemQuantity(String assetId, int quantity) {
    emit(state.copyWith(
      lineItems: state.lineItems.map((li) => li.assetId == assetId ? li.copyWith(quantity: quantity) : li).toList(),
      isDirty: true,
    ));
  }

  void updateLineItemPrice(String assetId, double price) {
    emit(state.copyWith(
      lineItems: state.lineItems.map((li) => li.assetId == assetId ? li.copyWith(price: price) : li).toList(),
      isDirty: true,
    ));
  }

  Future<void> save() async {
    if (state.title.trim().isEmpty ||
        state.from == null ||
        state.to == null ||
        state.locationAddress.trim().isEmpty) {
      emit(state.copyWith(errorMessage: 'Title, dates and location are required.'));
      return;
    }

    emit(state.copyWith(isSaving: true, clearError: true));

    final lineItems = state.lineItems
        .map((li) => EventLineItemRequest(assetId: li.assetId, quantity: li.quantity, price: li.price))
        .toList();
    final description = state.description.trim().isEmpty ? null : state.description.trim();

    final ApiResponse response;
    if (isEditMode) {
      response = await eventApiService.updateEvent(
        eventId!,
        UpdateEventRequest(
          title: state.title.trim(),
          description: description,
          from: state.from!,
          to: state.to!,
          locationAddress: state.locationAddress.trim(),
          locationLatitude: state.locationLatitude,
          locationLongitude: state.locationLongitude,
          clientId: state.clientId,
          lineItems: lineItems,
        ),
      );
    } else {
      response = await eventApiService.createEvent(
        CreateEventRequest(
          title: state.title.trim(),
          description: description,
          from: state.from!,
          to: state.to!,
          locationAddress: state.locationAddress.trim(),
          locationLatitude: state.locationLatitude,
          locationLongitude: state.locationLongitude,
          clientId: state.clientId,
          lineItems: lineItems,
        ),
      );
    }

    if (response.status == ResponseStatus.completed) {
      emit(state.copyWith(isSaving: false, saveSucceeded: true));
    } else {
      emit(state.copyWith(isSaving: false, errorMessage: response.message));
    }
  }

  Future<void> cancelEvent() async {
    if (!isEditMode) return;
    emit(state.copyWith(isCancelling: true, clearError: true));

    final response = await eventApiService.cancelEvent(eventId!);

    if (response.status == ResponseStatus.completed) {
      emit(state.copyWith(isCancelling: false, cancelSucceeded: true));
    } else {
      emit(state.copyWith(isCancelling: false, errorMessage: response.message));
    }
  }

  /// DELETE /transactions/{id} — not yet implemented server-side, see
  /// EventApiService.deleteEvent doc comment.
  Future<void> deleteEvent() async {
    if (!isEditMode) return;
    emit(state.copyWith(isDeleting: true, clearError: true));

    final response = await eventApiService.deleteEvent(eventId!);

    if (response.status == ResponseStatus.completed) {
      emit(state.copyWith(isDeleting: false, deleteSucceeded: true));
    } else {
      emit(state.copyWith(isDeleting: false, errorMessage: response.message));
    }
  }
}
