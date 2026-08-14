import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:business_assistant/core/features/inventory/api_services/asset_api_service.dart';
import 'package:business_assistant/core/features/inventory/api_services/image_api_service.dart';
import 'package:business_assistant/core/features/inventory/models/requests/create_asset_request.dart';
import 'package:business_assistant/core/features/inventory/models/requests/update_asset_request.dart';
import 'package:business_assistant/core/shared/enums/cubit_state.dart';
import 'package:business_assistant/core/utils/api/api_response.dart';

part 'create_edit_asset_state.dart';

/// Drives CreateEditAssetPage — one cubit instance handles both creating a
/// new product (assetId == null) and editing an existing one (assetId set),
/// since the form and its validation are identical either way.
class CreateEditAssetCubit extends Cubit<CreateEditAssetState> {
  final String? assetId;
  final AssetApiService assetApiService;
  final ImageApiService imageApiService;

  CreateEditAssetCubit({this.assetId, AssetApiService? assetApiService, ImageApiService? imageApiService})
      : assetApiService = assetApiService ?? AssetApiService(),
        imageApiService = imageApiService ?? ImageApiService(),
        super(const CreateEditAssetState());

  bool get isEditMode => assetId != null;

  Future<void> loadFormData() async {
    if (!isEditMode) {
      emit(state.copyWith(currentState: CubitState.loaded));
      return;
    }

    emit(state.copyWith(currentState: CubitState.loading));
    final response = await assetApiService.getAssetById(assetId!);
    if (response.status == ResponseStatus.error) {
      emit(state.copyWith(currentState: CubitState.error, errorMessage: response.message));
      return;
    }

    final asset = response.data!;
    emit(state.copyWith(
      currentState: CubitState.loaded,
      name: asset.name,
      category: asset.category,
      description: asset.description ?? '',
      salePrice: asset.salePrice,
      rentalPrice: asset.rentalPrice,
      stockCount: asset.stockCount,
      currentlyReserved: asset.currentlyReserved,
      imgUrl: asset.imgUrl,
    ));
  }

  void setName(String value) => emit(state.copyWith(name: value, isDirty: true));

  void setCategory(String value) => emit(state.copyWith(category: value, isDirty: true));

  void setDescription(String value) => emit(state.copyWith(description: value, isDirty: true));

  void setSalePrice(double? value) =>
      emit(state.copyWith(salePrice: value, clearSalePrice: value == null, isDirty: true));

  void setRentalPrice(double? value) =>
      emit(state.copyWith(rentalPrice: value, clearRentalPrice: value == null, isDirty: true));

  void setStockCount(int value) => emit(state.copyWith(stockCount: value, isDirty: true));

  Future<void> pickAndUploadImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    emit(state.copyWith(isUploadingImage: true, clearError: true));

    final response = await imageApiService.uploadImage(File(pickedFile.path));

    if (response.status == ResponseStatus.completed) {
      emit(state.copyWith(isUploadingImage: false, imgUrl: response.data, isDirty: true));
    } else {
      emit(state.copyWith(isUploadingImage: false, errorMessage: response.message));
    }
  }

  Future<void> save() async {
    if (state.name.trim().isEmpty || state.category.trim().isEmpty) {
      emit(state.copyWith(errorMessage: 'Name and category are required.'));
      return;
    }
    if (state.rentalPrice == null && state.salePrice == null) {
      emit(state.copyWith(errorMessage: 'Rental price or product price is required.'));
      return;
    }

    emit(state.copyWith(isSaving: true, clearError: true));

    final description = state.description.trim().isEmpty ? null : state.description.trim();

    final ApiResponse response;
    if (isEditMode) {
      response = await assetApiService.updateAsset(
        assetId!,
        UpdateAssetRequest(
          name: state.name.trim(),
          category: state.category.trim(),
          description: description,
          salePrice: state.salePrice,
          rentalPrice: state.rentalPrice,
          stockCount: state.stockCount,
          imgUrl: state.imgUrl,
        ),
      );
    } else {
      response = await assetApiService.createAsset(
        CreateAssetRequest(
          name: state.name.trim(),
          category: state.category.trim(),
          description: description,
          salePrice: state.salePrice,
          rentalPrice: state.rentalPrice,
          stockCount: state.stockCount,
          imgUrl: state.imgUrl,
        ),
      );
    }

    if (response.status == ResponseStatus.completed) {
      emit(state.copyWith(isSaving: false, saveSucceeded: true));
    } else {
      emit(state.copyWith(isSaving: false, errorMessage: response.message));
    }
  }

  Future<void> deleteAsset() async {
    if (!isEditMode) return;
    emit(state.copyWith(isDeleting: true, clearError: true));

    final response = await assetApiService.removeAsset(assetId!);

    if (response.status == ResponseStatus.completed) {
      emit(state.copyWith(isDeleting: false, deleteSucceeded: true));
    } else {
      emit(state.copyWith(isDeleting: false, errorMessage: response.message));
    }
  }
}
