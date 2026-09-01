import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:business_assistant/core/features/inventory/api_services/asset_api_service.dart';
import 'package:business_assistant/core/features/inventory/api_services/category_api_service.dart';
import 'package:business_assistant/core/features/inventory/api_services/image_api_service.dart';
import 'package:business_assistant/core/features/inventory/models/requests/create_asset_request.dart';
import 'package:business_assistant/core/features/inventory/models/requests/update_asset_request.dart';
import 'package:business_assistant/core/features/inventory/models/responses/category_response.dart';
import 'package:business_assistant/core/shared/enums/cubit_state.dart';
import 'package:business_assistant/core/utils/api/api_response.dart';
import 'package:business_assistant/core/utils/safe_emit_cubit_extension.dart';

part 'create_edit_asset_state.dart';

/// Drives CreateEditAssetPage — one cubit instance handles both creating a
/// new product (assetId == null) and editing an existing one (assetId set),
/// since the form and its validation are identical either way.
class CreateEditAssetCubit extends Cubit<CreateEditAssetState> {
  final String? assetId;
  final AssetApiService assetApiService;
  final ImageApiService imageApiService;
  final CategoryApiService categoryApiService;

  CreateEditAssetCubit({
    this.assetId,
    AssetApiService? assetApiService,
    ImageApiService? imageApiService,
    CategoryApiService? categoryApiService,
  }) : assetApiService = assetApiService ?? AssetApiService(),
       imageApiService = imageApiService ?? ImageApiService(),
       categoryApiService = categoryApiService ?? CategoryApiService(),
       super(const CreateEditAssetState());

  bool get isEditMode => assetId != null;

  /// Kicks off the category picker's options and — in edit mode — the
  /// existing asset's data, as two independent calls: one failing doesn't
  /// stop or delay the other.
  Future<void> loadFormData() async {
    unawaited(_loadCategories());
    if (isEditMode) {
      unawaited(_loadAsset());
    } else {
      safeEmit(state.copyWith(currentState: CubitState.loaded));
    }
  }

  Future<void> _loadCategories() async {
    safeEmit(state.copyWith(categoriesState: CubitState.loading));
    final response = await categoryApiService.getCategories();
    if (response.status == ResponseStatus.error) {
      safeEmit(state.copyWith(categoriesState: CubitState.error, errorMessage: response.message));
      return;
    }
    safeEmit(state.copyWith(categoriesState: CubitState.loaded, availableCategories: response.data ?? []));
  }

  Future<void> _loadAsset() async {
    safeEmit(state.copyWith(currentState: CubitState.loading));
    final response = await assetApiService.getAssetById(assetId!);
    if (response.status == ResponseStatus.error) {
      safeEmit(state.copyWith(currentState: CubitState.error, errorMessage: response.message));
      return;
    }

    final asset = response.data!;
    safeEmit(
      state.copyWith(
        currentState: CubitState.loaded,
        name: asset.name,
        categoryId: asset.categoryId,
        description: asset.description ?? '',
        salePrice: asset.salePrice,
        rentalPrice: asset.rentalPrice,
        stockCount: asset.stockCount,
        currentlyReserved: asset.currentlyReserved,
        imgUrl: asset.imgUrl,
      ),
    );
  }

  void setName(String value) => safeEmit(state.copyWith(name: value, isDirty: true));

  void selectCategory(CategoryResponse? category) =>
      safeEmit(state.copyWith(categoryId: category?.id, clearCategoryId: category == null, isDirty: true));

  void setDescription(String value) => safeEmit(state.copyWith(description: value, isDirty: true));

  void setSalePrice(double? value) =>
      safeEmit(state.copyWith(salePrice: value, clearSalePrice: value == null, isDirty: true));

  void setRentalPrice(double? value) =>
      safeEmit(state.copyWith(rentalPrice: value, clearRentalPrice: value == null, isDirty: true));

  void setStockCount(int value) => safeEmit(state.copyWith(stockCount: value, isDirty: true));

  Future<void> pickAndUploadImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    safeEmit(state.copyWith(isUploadingImage: true, clearError: true));

    final response = await imageApiService.uploadImage(File(pickedFile.path));

    if (response.status == ResponseStatus.completed) {
      safeEmit(state.copyWith(isUploadingImage: false, imgUrl: response.data, isDirty: true));
    } else {
      safeEmit(state.copyWith(isUploadingImage: false, errorMessage: response.message));
    }
  }

  Future<void> save() async {
    if (state.name.trim().isEmpty) {
      safeEmit(state.copyWith(errorMessage: 'Name is required.'));
      return;
    }
    if (state.rentalPrice == null && state.salePrice == null) {
      safeEmit(state.copyWith(errorMessage: 'Rental price or product price is required.'));
      return;
    }

    safeEmit(state.copyWith(isSaving: true, clearError: true));

    final description = state.description.trim().isEmpty ? null : state.description.trim();

    final ApiResponse response;
    if (isEditMode) {
      response = await assetApiService.updateAsset(
        assetId!,
        UpdateAssetRequest(
          name: state.name.trim(),
          categoryId: state.categoryId,
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
          categoryId: state.categoryId,
          description: description,
          salePrice: state.salePrice,
          rentalPrice: state.rentalPrice,
          stockCount: state.stockCount,
          imgUrl: state.imgUrl,
        ),
      );
    }

    if (response.status == ResponseStatus.completed) {
      safeEmit(state.copyWith(isSaving: false, saveSucceeded: true));
    } else {
      safeEmit(state.copyWith(isSaving: false, errorMessage: response.message));
    }
  }

  Future<void> deleteAsset() async {
    if (!isEditMode) return;
    safeEmit(state.copyWith(isDeleting: true, clearError: true));

    final response = await assetApiService.removeAsset(assetId!);

    if (response.status == ResponseStatus.completed) {
      safeEmit(state.copyWith(isDeleting: false, deleteSucceeded: true));
    } else {
      safeEmit(state.copyWith(isDeleting: false, errorMessage: response.message));
    }
  }
}
