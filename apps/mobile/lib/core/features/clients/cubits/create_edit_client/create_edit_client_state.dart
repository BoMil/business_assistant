part of 'create_edit_client_cubit.dart';

class CreateEditClientState {
  /// getClientById status (edit mode only) — CubitState.loaded immediately in
  /// create mode, since there's no client to fetch.
  final CubitState currentState;
  final bool isSaving;
  final bool isDeleting;
  final String? errorMessage;
  final bool saveSucceeded;
  final bool deleteSucceeded;

  final String name;
  final String phoneNumber;
  final String email;
  final String description;
  final String locationAddress;
  final double? locationLatitude;
  final double? locationLongitude;
  final bool isDirty;

  const CreateEditClientState({
    this.currentState = CubitState.initial,
    this.isSaving = false,
    this.isDeleting = false,
    this.errorMessage,
    this.saveSucceeded = false,
    this.deleteSucceeded = false,
    this.name = '',
    this.phoneNumber = '',
    this.email = '',
    this.description = '',
    this.locationAddress = '',
    this.locationLatitude,
    this.locationLongitude,
    this.isDirty = false,
  });

  /// getClientById is still in flight (edit mode only) — gates the form's Skeletonizer.
  bool get isPending => currentState == CubitState.loading || currentState == CubitState.initial;

  /// In edit mode, Save is disabled until something actually changed — no
  /// point re-submitting an untouched client. Create mode has nothing to
  /// compare against, so it's always allowed (required-field validation
  /// still happens in CreateEditClientCubit.save()).
  bool canSave(bool isEditMode) => !isEditMode || isDirty;

  CreateEditClientState copyWith({
    CubitState? currentState,
    bool? isSaving,
    bool? isDeleting,
    String? errorMessage,
    bool clearError = false,
    bool? saveSucceeded,
    bool? deleteSucceeded,
    String? name,
    String? phoneNumber,
    String? email,
    String? description,
    String? locationAddress,
    double? locationLatitude,
    double? locationLongitude,
    bool? isDirty,
  }) {
    return CreateEditClientState(
      currentState: currentState ?? this.currentState,
      isSaving: isSaving ?? this.isSaving,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      saveSucceeded: saveSucceeded ?? this.saveSucceeded,
      deleteSucceeded: deleteSucceeded ?? this.deleteSucceeded,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      description: description ?? this.description,
      locationAddress: locationAddress ?? this.locationAddress,
      locationLatitude: locationLatitude ?? this.locationLatitude,
      locationLongitude: locationLongitude ?? this.locationLongitude,
      isDirty: isDirty ?? this.isDirty,
    );
  }
}
