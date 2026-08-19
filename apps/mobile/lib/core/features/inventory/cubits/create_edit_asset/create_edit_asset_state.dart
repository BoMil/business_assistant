part of 'create_edit_asset_cubit.dart';

class CreateEditAssetState {
  /// getAssetById status (edit mode only) — CubitState.loaded immediately in
  /// create mode, since there's no asset to fetch.
  final CubitState currentState;
  final CubitState categoriesState;
  final bool isSaving;
  final bool isDeleting;
  final String? errorMessage;
  final bool saveSucceeded;
  final bool deleteSucceeded;

  final String name;
  final String? categoryId;
  final String description;
  final double? salePrice;
  final double? rentalPrice;
  final int stockCount;
  final int? currentlyReserved;
  final String? imgUrl;
  final bool isDirty;
  final bool isUploadingImage;

  final List<CategoryResponse> availableCategories;

  const CreateEditAssetState({
    this.currentState = CubitState.initial,
    this.categoriesState = CubitState.initial,
    this.isSaving = false,
    this.isDeleting = false,
    this.errorMessage,
    this.saveSucceeded = false,
    this.deleteSucceeded = false,
    this.name = '',
    this.categoryId,
    this.description = '',
    this.salePrice,
    this.rentalPrice,
    this.stockCount = 0,
    this.currentlyReserved,
    this.imgUrl,
    this.isDirty = false,
    this.isUploadingImage = false,
    this.availableCategories = const [],
  });

  /// The selected category's name, looked up from availableCategories — kept
  /// as a derived value instead of a stored field so it's always correct
  /// regardless of whether the asset or the category list finishes loading first.
  String? get categoryName {
    for (final category in availableCategories) {
      if (category.id == categoryId) return category.name;
    }
    return null;
  }

  /// getAssetById is still in flight (edit mode only) — gates the form's Skeletonizer.
  bool get isPending => currentState == CubitState.loading || currentState == CubitState.initial;

  bool get isCategoriesPending => categoriesState == CubitState.loading || categoriesState == CubitState.initial;

  /// In edit mode, Save is disabled until something actually changed — no
  /// point re-submitting an untouched asset. Create mode has nothing to
  /// compare against, so it's always allowed (required-field validation
  /// still happens in CreateEditAssetCubit.save()).
  bool canSave(bool isEditMode) => !isEditMode || isDirty;

  CreateEditAssetState copyWith({
    CubitState? currentState,
    CubitState? categoriesState,
    bool? isSaving,
    bool? isDeleting,
    String? errorMessage,
    bool clearError = false,
    bool? saveSucceeded,
    bool? deleteSucceeded,
    String? name,
    String? categoryId,
    bool clearCategoryId = false,
    String? description,
    double? salePrice,
    bool clearSalePrice = false,
    double? rentalPrice,
    bool clearRentalPrice = false,
    int? stockCount,
    int? currentlyReserved,
    String? imgUrl,
    bool? isDirty,
    bool? isUploadingImage,
    List<CategoryResponse>? availableCategories,
  }) {
    return CreateEditAssetState(
      currentState: currentState ?? this.currentState,
      categoriesState: categoriesState ?? this.categoriesState,
      isSaving: isSaving ?? this.isSaving,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      saveSucceeded: saveSucceeded ?? this.saveSucceeded,
      deleteSucceeded: deleteSucceeded ?? this.deleteSucceeded,
      name: name ?? this.name,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      description: description ?? this.description,
      salePrice: clearSalePrice ? null : (salePrice ?? this.salePrice),
      rentalPrice: clearRentalPrice ? null : (rentalPrice ?? this.rentalPrice),
      stockCount: stockCount ?? this.stockCount,
      currentlyReserved: currentlyReserved ?? this.currentlyReserved,
      imgUrl: imgUrl ?? this.imgUrl,
      isDirty: isDirty ?? this.isDirty,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      availableCategories: availableCategories ?? this.availableCategories,
    );
  }
}
