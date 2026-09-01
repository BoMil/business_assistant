import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:business_assistant/core/features/clients/api_services/client_api_service.dart';
import 'package:business_assistant/core/features/clients/models/responses/client_response.dart';
import 'package:business_assistant/core/features/events/api_services/event_api_service.dart';
import 'package:business_assistant/core/features/events/models/enums/event_status.dart';
import 'package:business_assistant/core/features/events/models/requests/create_event_request.dart';
import 'package:business_assistant/core/features/events/models/requests/event_asset_request.dart';
import 'package:business_assistant/core/features/events/models/requests/event_cost_request.dart';
import 'package:business_assistant/core/features/events/models/requests/update_event_request.dart';
import 'package:business_assistant/core/features/events/models/responses/event_response.dart';
import 'package:business_assistant/core/features/inventory/api_services/asset_api_service.dart';
import 'package:business_assistant/core/features/inventory/models/responses/asset_response.dart';
import 'package:business_assistant/core/shared/enums/cubit_state.dart';
import 'package:business_assistant/core/shared/widgets/input_fields/location_input_field.dart';
import 'package:business_assistant/core/utils/api/api_response.dart';
import 'package:business_assistant/core/utils/safe_emit_cubit_extension.dart';

part 'create_edit_event_state.dart';

/// Drives CreateEditEventPage — one cubit instance handles both creating a
/// new event (eventId == null) and editing an existing one (eventId set),
/// since the form and its validation are identical either way.
class CreateEditEventCubit extends Cubit<CreateEditEventState> {
  final String? eventId;
  final EventResponse? initialEvent;
  final EventApiService eventApiService;
  final AssetApiService assetApiService;
  final ClientApiService clientApiService;

  /// Preselects the client picker when opened from a Client Details page's
  /// "Add new event" button. Only relevant in create mode — edit mode
  /// overwrites clientId from the loaded event anyway.
  ///
  /// [initialEvent], when the caller already has the event (e.g. opened from
  /// EventPreviewPage), lets edit mode populate the form from it directly
  /// instead of re-fetching it via [_loadEvent].
  CreateEditEventCubit({
    this.eventId,
    this.initialEvent,
    String? initialClientId,
    EventApiService? eventApiService,
    AssetApiService? assetApiService,
    ClientApiService? clientApiService,
  })  : eventApiService = eventApiService ?? EventApiService(),
        assetApiService = assetApiService ?? AssetApiService(),
        clientApiService = clientApiService ?? ClientApiService(),
        super(CreateEditEventState(clientId: initialClientId));

  bool get isEditMode => eventId != null;

  /// Kicks off the asset/client pickers' options and — in edit mode — the
  /// existing event's data, as three independent calls: one failing doesn't
  /// stop or delay the others.
  Future<void> loadFormData() async {
    unawaited(_loadAssets());
    unawaited(_loadClients());
    if (initialEvent != null) {
      _populateFromEvent(initialEvent!);
    } else if (isEditMode) {
      unawaited(_loadEvent());
    } else {
      safeEmit(state.copyWith(currentState: CubitState.loaded));
    }
  }

  Future<void> _loadAssets() async {
    safeEmit(state.copyWith(assetsState: CubitState.loading));
    final response = await assetApiService.getAssets();
    if (response.status == ResponseStatus.error) {
      safeEmit(state.copyWith(assetsState: CubitState.error, errorMessage: response.message));
      return;
    }
    safeEmit(state.copyWith(assetsState: CubitState.loaded, availableAssets: response.data ?? []));
  }

  Future<void> _loadClients() async {
    safeEmit(state.copyWith(clientState: CubitState.loading));
    final response = await clientApiService.getClients();
    if (response.status == ResponseStatus.error) {
      safeEmit(state.copyWith(clientState: CubitState.error, errorMessage: response.message));
      return;
    }
    safeEmit(state.copyWith(clientState: CubitState.loaded, availableClients: response.data ?? []));
  }

  Future<void> _loadEvent() async {
    safeEmit(state.copyWith(currentState: CubitState.loading));
    final response = await eventApiService.getEventById(eventId!);
    if (response.status == ResponseStatus.error) {
      safeEmit(state.copyWith(currentState: CubitState.error, errorMessage: response.message));
      return;
    }
    _populateFromEvent(response.data!);
  }

  void _populateFromEvent(EventResponse event) {
    safeEmit(state.copyWith(
      currentState: CubitState.loaded,
      title: event.title,
      description: event.description ?? '',
      from: event.from,
      to: event.to,
      locationAddress: event.locationAddress ?? '',
      locationLatitude: event.locationLatitude,
      locationLongitude: event.locationLongitude,
      clientId: event.clientId,
      eventAssets: event.eventAssets
          .map((asset) => EventFormAsset(assetId: asset.assetId, assetName: asset.assetName, quantity: asset.quantity, price: asset.price))
          .toList(),
      eventCosts: event.eventCosts
          .map((cost) => EventFormCost(
                localId: cost.id,
                title: cost.title,
                cost: cost.cost,
                isIncludedInTotalCost: cost.isIncludedInTotalCost,
              ))
          .toList(),
      status: event.status,
    ));
  }

  void setTitle(String value) => safeEmit(state.copyWith(title: value, isDirty: true));

  void setDescription(String value) => safeEmit(state.copyWith(description: value, isDirty: true));

  void setFrom(DateTime? value) =>
      safeEmit(state.copyWith(from: value, clearFrom: value == null, isDirty: true));

  void setTo(DateTime? value) => safeEmit(state.copyWith(to: value, clearTo: value == null, isDirty: true));

  void setLocation(LocationOutput location) => safeEmit(state.copyWith(
        locationAddress: location.address,
        locationLatitude: location.latitude,
        locationLongitude: location.longitude,
        isDirty: true,
      ));

  void selectClient(ClientResponse? client) => safeEmit(state.copyWith(
        clientId: client?.id,
        clearClient: client == null,
        isDirty: true,
      ));

  void addEventAsset(AssetResponse asset) {
    if (state.eventAssets.any((ea) => ea.assetId == asset.id)) return;
    final newAsset = EventFormAsset(
      assetId: asset.id,
      assetName: asset.name,
      quantity: 1,
      price: asset.rentalPrice ?? 0,
    );
    safeEmit(state.copyWith(eventAssets: [...state.eventAssets, newAsset], isDirty: true));
  }

  void removeEventAsset(String assetId) {
    safeEmit(state.copyWith(
      eventAssets: state.eventAssets.where((ea) => ea.assetId != assetId).toList(),
      isDirty: true,
    ));
  }

  void updateEventAssetQuantity(String assetId, int quantity) {
    safeEmit(state.copyWith(
      eventAssets: state.eventAssets.map((ea) => ea.assetId == assetId ? ea.copyWith(quantity: quantity) : ea).toList(),
      isDirty: true,
    ));
  }

  void updateEventAssetPrice(String assetId, double price) {
    safeEmit(state.copyWith(
      eventAssets: state.eventAssets.map((ea) => ea.assetId == assetId ? ea.copyWith(price: price) : ea).toList(),
      isDirty: true,
    ));
  }

  void addEventCost() {
    final newCost = EventFormCost(
      localId: DateTime.now().microsecondsSinceEpoch.toString(),
      title: '',
      cost: 0,
      isIncludedInTotalCost: false,
    );
    safeEmit(state.copyWith(eventCosts: [...state.eventCosts, newCost], isDirty: true));
  }

  void removeEventCost(String localId) {
    safeEmit(state.copyWith(
      eventCosts: state.eventCosts.where((ec) => ec.localId != localId).toList(),
      isDirty: true,
    ));
  }

  void updateEventCostTitle(String localId, String title) {
    safeEmit(state.copyWith(
      eventCosts: state.eventCosts.map((ec) => ec.localId == localId ? ec.copyWith(title: title) : ec).toList(),
      isDirty: true,
    ));
  }

  void updateEventCostAmount(String localId, double cost) {
    safeEmit(state.copyWith(
      eventCosts: state.eventCosts.map((ec) => ec.localId == localId ? ec.copyWith(cost: cost) : ec).toList(),
      isDirty: true,
    ));
  }

  void updateEventCostIncluded(String localId, bool isIncludedInTotalCost) {
    safeEmit(state.copyWith(
      eventCosts: state.eventCosts
          .map((ec) => ec.localId == localId ? ec.copyWith(isIncludedInTotalCost: isIncludedInTotalCost) : ec)
          .toList(),
      isDirty: true,
    ));
  }

  Future<void> save() async {
    if (state.title.trim().isEmpty ||
        state.from == null ||
        state.to == null ||
        state.locationAddress.trim().isEmpty) {
      safeEmit(state.copyWith(errorMessage: 'Title, dates and location are required.'));
      return;
    }
    if (state.eventCosts.any((cost) => cost.title.trim().isEmpty || cost.cost < 0)) {
      safeEmit(state.copyWith(errorMessage: 'Each additional cost needs a name and a non-negative amount.'));
      return;
    }

    safeEmit(state.copyWith(isSaving: true, clearError: true));

    final eventAssets = state.eventAssets
        .map((asset) => EventAssetRequest(assetId: asset.assetId, quantity: asset.quantity, price: asset.price))
        .toList();
    final eventCosts = state.eventCosts
        .map((cost) => EventCostRequest(title: cost.title.trim(), cost: cost.cost, isIncludedInTotalCost: cost.isIncludedInTotalCost))
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
          eventAssets: eventAssets,
          eventCosts: eventCosts,
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
          eventAssets: eventAssets,
          eventCosts: eventCosts,
        ),
      );
    }

    if (response.status == ResponseStatus.completed) {
      safeEmit(state.copyWith(isSaving: false, saveSucceeded: true));
    } else {
      safeEmit(state.copyWith(isSaving: false, errorMessage: response.message));
    }
  }

  Future<void> cancelEvent() async {
    if (!isEditMode) return;
    safeEmit(state.copyWith(isCancelling: true, clearError: true));

    final response = await eventApiService.cancelEvent(eventId!);

    if (response.status == ResponseStatus.completed) {
      safeEmit(state.copyWith(isCancelling: false, cancelSucceeded: true));
    } else {
      safeEmit(state.copyWith(isCancelling: false, errorMessage: response.message));
    }
  }

  /// DELETE /transactions/{id} — not yet implemented server-side, see
  /// EventApiService.deleteEvent doc comment.
  Future<void> deleteEvent() async {
    if (!isEditMode) return;
    safeEmit(state.copyWith(isDeleting: true, clearError: true));

    final response = await eventApiService.deleteEvent(eventId!);

    if (response.status == ResponseStatus.completed) {
      safeEmit(state.copyWith(isDeleting: false, deleteSucceeded: true));
    } else {
      safeEmit(state.copyWith(isDeleting: false, errorMessage: response.message));
    }
  }
}
