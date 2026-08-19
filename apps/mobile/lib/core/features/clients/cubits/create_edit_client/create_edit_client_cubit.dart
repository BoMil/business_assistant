import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:business_assistant/core/features/clients/api_services/client_api_service.dart';
import 'package:business_assistant/core/features/clients/models/requests/create_client_request.dart';
import 'package:business_assistant/core/features/clients/models/requests/update_client_request.dart';
import 'package:business_assistant/core/shared/enums/cubit_state.dart';
import 'package:business_assistant/core/shared/widgets/input_fields/location_input_field.dart';
import 'package:business_assistant/core/utils/api/api_response.dart';

part 'create_edit_client_state.dart';

/// Drives CreateEditClientPage — one cubit instance handles both creating a
/// new client (clientId == null) and editing an existing one (clientId set),
/// since the form and its validation are identical either way.
class CreateEditClientCubit extends Cubit<CreateEditClientState> {
  final String? clientId;
  final ClientApiService clientApiService;

  CreateEditClientCubit({this.clientId, ClientApiService? clientApiService})
      : clientApiService = clientApiService ?? ClientApiService(),
        super(const CreateEditClientState());

  bool get isEditMode => clientId != null;

  Future<void> loadFormData() async {
    if (!isEditMode) {
      emit(state.copyWith(currentState: CubitState.loaded));
      return;
    }

    emit(state.copyWith(currentState: CubitState.loading));
    final response = await clientApiService.getClientById(clientId!);
    if (response.status == ResponseStatus.error) {
      emit(state.copyWith(currentState: CubitState.error, errorMessage: response.message));
      return;
    }

    final client = response.data!;
    emit(state.copyWith(
      currentState: CubitState.loaded,
      name: client.name,
      phoneNumber: client.phoneNumber,
      email: client.email,
      description: client.description ?? '',
      locationAddress: client.locationAddress ?? '',
      locationLatitude: client.locationLatitude,
      locationLongitude: client.locationLongitude,
    ));
  }

  void setName(String value) => emit(state.copyWith(name: value, isDirty: true));

  void setPhoneNumber(String value) => emit(state.copyWith(phoneNumber: value, isDirty: true));

  void setEmail(String value) => emit(state.copyWith(email: value, isDirty: true));

  void setDescription(String value) => emit(state.copyWith(description: value, isDirty: true));

  void setLocation(LocationOutput location) => emit(state.copyWith(
        locationAddress: location.address,
        locationLatitude: location.latitude,
        locationLongitude: location.longitude,
        isDirty: true,
      ));

  Future<void> save() async {
    if (state.name.trim().isEmpty ||
        state.phoneNumber.trim().isEmpty ||
        state.email.trim().isEmpty ||
        state.locationAddress.trim().isEmpty) {
      emit(state.copyWith(errorMessage: 'Name, phone number, email and location are required.'));
      return;
    }

    emit(state.copyWith(isSaving: true, clearError: true));

    final description = state.description.trim().isEmpty ? null : state.description.trim();

    final ApiResponse response;
    if (isEditMode) {
      response = await clientApiService.updateClient(
        clientId!,
        UpdateClientRequest(
          name: state.name.trim(),
          phoneNumber: state.phoneNumber.trim(),
          email: state.email.trim(),
          locationAddress: state.locationAddress.trim(),
          locationLatitude: state.locationLatitude,
          locationLongitude: state.locationLongitude,
          description: description,
        ),
      );
    } else {
      response = await clientApiService.createClient(
        CreateClientRequest(
          name: state.name.trim(),
          phoneNumber: state.phoneNumber.trim(),
          email: state.email.trim(),
          locationAddress: state.locationAddress.trim(),
          locationLatitude: state.locationLatitude,
          locationLongitude: state.locationLongitude,
          description: description,
        ),
      );
    }

    if (response.status == ResponseStatus.completed) {
      emit(state.copyWith(isSaving: false, saveSucceeded: true));
    } else {
      emit(state.copyWith(isSaving: false, errorMessage: response.message));
    }
  }

  Future<void> deleteClient() async {
    if (!isEditMode) return;
    emit(state.copyWith(isDeleting: true, clearError: true));

    final response = await clientApiService.removeClient(clientId!);

    if (response.status == ResponseStatus.completed) {
      emit(state.copyWith(isDeleting: false, deleteSucceeded: true));
    } else {
      emit(state.copyWith(isDeleting: false, errorMessage: response.message));
    }
  }
}
