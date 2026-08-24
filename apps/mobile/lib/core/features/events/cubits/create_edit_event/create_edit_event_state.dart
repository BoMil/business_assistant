part of 'create_edit_event_cubit.dart';

/// A product line as edited on the form — quantity/price are user-editable,
/// unlike EventAssetResponse which only reflects what the server has saved.
class EventFormAsset {
  final String assetId;
  final String assetName;
  final int quantity;
  final double price;

  const EventFormAsset({
    required this.assetId,
    required this.assetName,
    required this.quantity,
    required this.price,
  });

  EventFormAsset copyWith({int? quantity, double? price}) {
    return EventFormAsset(
      assetId: assetId,
      assetName: assetName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }
}

/// An additional-cost line as edited on the form. `localId` is a client-only
/// identifier used to address a row in the list (title isn't unique, and a
/// backend id doesn't exist yet for a row the user just added) — it is never
/// sent to the server, since UpdateTransaction fully replaces the cost list.
class EventFormCost {
  final String localId;
  final String title;
  final double cost;
  final bool isIncludedInTotalCost;

  const EventFormCost({
    required this.localId,
    required this.title,
    required this.cost,
    required this.isIncludedInTotalCost,
  });

  EventFormCost copyWith({String? title, double? cost, bool? isIncludedInTotalCost}) {
    return EventFormCost(
      localId: localId,
      title: title ?? this.title,
      cost: cost ?? this.cost,
      isIncludedInTotalCost: isIncludedInTotalCost ?? this.isIncludedInTotalCost,
    );
  }
}

class CreateEditEventState {
  /// getEventById status (edit mode only) — CubitState.loaded immediately in
  /// create mode, since there's no event to fetch.
  final CubitState currentState;
  final CubitState assetsState;
  final CubitState clientState;
  final bool isSaving;
  final bool isCancelling;
  final bool isDeleting;
  final String? errorMessage;
  final bool saveSucceeded;
  final bool cancelSucceeded;
  final bool deleteSucceeded;

  final String title;
  final String description;
  final DateTime? from;
  final DateTime? to;
  final String locationAddress;
  final double? locationLatitude;
  final double? locationLongitude;
  final String? clientId;
  final List<EventFormAsset> eventAssets;
  final List<EventFormCost> eventCosts;
  final EventStatus? status;
  final bool isDirty;

  final List<AssetResponse> availableAssets;
  final List<ClientResponse> availableClients;

  const CreateEditEventState({
    this.currentState = CubitState.initial,
    this.assetsState = CubitState.initial,
    this.clientState = CubitState.initial,
    this.isSaving = false,
    this.isCancelling = false,
    this.isDeleting = false,
    this.errorMessage,
    this.saveSucceeded = false,
    this.cancelSucceeded = false,
    this.deleteSucceeded = false,
    this.title = '',
    this.description = '',
    this.from,
    this.to,
    this.locationAddress = '',
    this.locationLatitude,
    this.locationLongitude,
    this.clientId,
    this.eventAssets = const [],
    this.eventCosts = const [],
    this.status,
    this.isDirty = false,
    this.availableAssets = const [],
    this.availableClients = const [],
  });

  /// The selected client's name, looked up from availableClients — kept as a
  /// derived value instead of a stored field so it's always correct regardless
  /// of whether the event or the client list finishes loading first.
  String? get clientName {
    for (final client in availableClients) {
      if (client.id == clientId) return client.name;
    }
    return null;
  }

  /// Whether each independent form-data load (event, assets, clients) is
  /// still in flight — used to gate each section's Skeletonizer.
  bool get isEventPending => _isPending(currentState);
  bool get isAssetsPending => _isPending(assetsState);
  bool get isClientPending => _isPending(clientState);

  static bool _isPending(CubitState state) => state == CubitState.loading || state == CubitState.initial;

  /// "Add product" is disabled until both dates are picked — an event's
  /// line-item availability depends on the rental date range.
  bool get canAddProduct => from != null && to != null;

  /// Only Rental events have a lifecycle status — Canceled is the only one
  /// that should block further edits/cancellation.
  bool get isCancelled => status == EventStatus.canceled;

  /// In edit mode, Save is disabled until something actually changed — no
  /// point re-submitting an untouched event. Create mode has nothing to
  /// compare against, so it's always allowed (required-field validation
  /// still happens in CreateEditEventCubit.save()).
  bool canSave(bool isEditMode) => !isEditMode || isDirty;

  CreateEditEventState copyWith({
    CubitState? currentState,
    CubitState? assetsState,
    CubitState? clientState,
    bool? isSaving,
    bool? isCancelling,
    bool? isDeleting,
    String? errorMessage,
    bool clearError = false,
    bool? saveSucceeded,
    bool? cancelSucceeded,
    bool? deleteSucceeded,
    String? title,
    String? description,
    DateTime? from,
    bool clearFrom = false,
    DateTime? to,
    bool clearTo = false,
    String? locationAddress,
    double? locationLatitude,
    double? locationLongitude,
    String? clientId,
    bool clearClient = false,
    List<EventFormAsset>? eventAssets,
    List<EventFormCost>? eventCosts,
    EventStatus? status,
    bool? isDirty,
    List<AssetResponse>? availableAssets,
    List<ClientResponse>? availableClients,
  }) {
    return CreateEditEventState(
      currentState: currentState ?? this.currentState,
      assetsState: assetsState ?? this.assetsState,
      clientState: clientState ?? this.clientState,
      isSaving: isSaving ?? this.isSaving,
      isCancelling: isCancelling ?? this.isCancelling,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      saveSucceeded: saveSucceeded ?? this.saveSucceeded,
      cancelSucceeded: cancelSucceeded ?? this.cancelSucceeded,
      deleteSucceeded: deleteSucceeded ?? this.deleteSucceeded,
      title: title ?? this.title,
      description: description ?? this.description,
      from: clearFrom ? null : (from ?? this.from),
      to: clearTo ? null : (to ?? this.to),
      locationAddress: locationAddress ?? this.locationAddress,
      locationLatitude: locationLatitude ?? this.locationLatitude,
      locationLongitude: locationLongitude ?? this.locationLongitude,
      clientId: clearClient ? null : (clientId ?? this.clientId),
      eventAssets: eventAssets ?? this.eventAssets,
      eventCosts: eventCosts ?? this.eventCosts,
      status: status ?? this.status,
      isDirty: isDirty ?? this.isDirty,
      availableAssets: availableAssets ?? this.availableAssets,
      availableClients: availableClients ?? this.availableClients,
    );
  }
}
