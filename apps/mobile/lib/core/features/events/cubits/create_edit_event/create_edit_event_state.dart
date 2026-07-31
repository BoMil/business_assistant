part of 'create_edit_event_cubit.dart';

/// A product line as edited on the form — quantity/price are user-editable,
/// unlike EventLineItemResponse which only reflects what the server has saved.
class EventFormLineItem {
  final String assetId;
  final String assetName;
  final int quantity;
  final double price;

  const EventFormLineItem({
    required this.assetId,
    required this.assetName,
    required this.quantity,
    required this.price,
  });

  EventFormLineItem copyWith({int? quantity, double? price}) {
    return EventFormLineItem(
      assetId: assetId,
      assetName: assetName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }
}

class CreateEditEventState {
  final CubitState currentState;
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
  final String? clientName;
  final List<EventFormLineItem> lineItems;
  final EventStatus? status;
  final bool isDirty;

  final List<AssetResponse> availableAssets;
  final List<ClientResponse> availableClients;

  const CreateEditEventState({
    this.currentState = CubitState.initial,
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
    this.clientName,
    this.lineItems = const [],
    this.status,
    this.isDirty = false,
    this.availableAssets = const [],
    this.availableClients = const [],
  });

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
    String? clientName,
    bool clearClient = false,
    List<EventFormLineItem>? lineItems,
    EventStatus? status,
    bool? isDirty,
    List<AssetResponse>? availableAssets,
    List<ClientResponse>? availableClients,
  }) {
    return CreateEditEventState(
      currentState: currentState ?? this.currentState,
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
      clientName: clearClient ? null : (clientName ?? this.clientName),
      lineItems: lineItems ?? this.lineItems,
      status: status ?? this.status,
      isDirty: isDirty ?? this.isDirty,
      availableAssets: availableAssets ?? this.availableAssets,
      availableClients: availableClients ?? this.availableClients,
    );
  }
}
