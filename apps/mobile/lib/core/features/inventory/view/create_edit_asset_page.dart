import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:business_assistant/config/translations/translation_storage.dart';
import 'package:business_assistant/core/features/authentication/cubits/user_info/user_info_cubit.dart';
import 'package:business_assistant/core/features/inventory/cubits/create_edit_asset/create_edit_asset_cubit.dart';
import 'package:business_assistant/core/features/inventory/models/page_props/create_edit_asset_page_props.dart';
import 'package:business_assistant/core/features/tenant/cubits/tenant_config/tenant_config_cubit.dart';
import 'package:business_assistant/core/shared/models/dropdowns/base_dropdown_item.dart';
import 'package:business_assistant/core/shared/pages/page_frame/page_frame.dart';
import 'package:business_assistant/core/shared/widgets/buttons/button_with_loading_state.dart';
import 'package:business_assistant/core/shared/widgets/buttons/custom_outlined_button.dart';
import 'package:business_assistant/core/shared/widgets/cards/card_frame.dart';
import 'package:business_assistant/core/shared/widgets/images/loaded_image.dart';
import 'package:business_assistant/core/shared/widgets/input_fields/input_label.dart';
import 'package:business_assistant/core/shared/widgets/input_fields/primary_input_field.dart';
import 'package:business_assistant/core/shared/widgets/modals/selection_bottom_modal.dart';
import 'package:business_assistant/core/utils/toast_message.dart';
import 'package:business_assistant/theme/get_theme_color.dart';
import 'package:business_assistant/theme/theme_color.dart';

/// Create/edit form for an Inventory product (Asset) — reused for both flows
/// since the fields and validation are identical; only pageProps.assetId
/// (null → create) and the Remove action (edit-mode only) differ.
class CreateEditAssetPage extends StatelessWidget {
  final CreateEditAssetPageProps? pageProps;

  const CreateEditAssetPage({super.key, this.pageProps});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateEditAssetCubit>(
      create: (_) => CreateEditAssetCubit(assetId: pageProps?.assetId)..loadFormData(),
      child: const _CreateEditAssetPageContent(),
    );
  }
}

class _CreateEditAssetPageContent extends StatefulWidget {
  const _CreateEditAssetPageContent();

  @override
  State<_CreateEditAssetPageContent> createState() => _CreateEditAssetPageContentState();
}

class _CreateEditAssetPageContentState extends State<_CreateEditAssetPageContent> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rentalPriceController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _stockCountController = TextEditingController();
  bool _controllersPopulated = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _rentalPriceController.dispose();
    _salePriceController.dispose();
    _stockCountController.dispose();
    super.dispose();
  }

  String _formatPriceForInput(double? price) {
    if (price == null) return '';
    return price % 1 == 0 ? price.toStringAsFixed(0) : price.toString();
  }

  void _populateControllersOnce(CreateEditAssetState state, bool isEditMode) {
    if (_controllersPopulated) return;
    // In edit mode, wait for the asset to actually load — otherwise this
    // fires once with the still-empty defaults and never gets to run again.
    if (isEditMode && state.isPending) return;
    _controllersPopulated = true;
    _nameController.text = state.name;
    _descriptionController.text = state.description;
    _rentalPriceController.text = _formatPriceForInput(state.rentalPrice);
    _salePriceController.text = _formatPriceForInput(state.salePrice);
    _stockCountController.text = state.stockCount.toString();
  }

  Future<void> _confirm(BuildContext context, {required String message, required VoidCallback onConfirm}) async {
    final t = TranslationStorage.translation;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            content: Text(message),
            actions: [
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(t.no)),
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(t.yes)),
            ],
          ),
    );
    if (confirmed == true) onConfirm();
  }

  void _openCategoryPicker(BuildContext context, CreateEditAssetState state) {
    final t = TranslationStorage.translation;
    final cubit = context.read<CreateEditAssetCubit>();
    final items =
        state.availableCategories.map((category) => BaseDropdownItem(text: category.name, value: category.id)).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => SelectionBottomModal(
            title: t.selectCategoryTitle,
            items: items,
            onItemSelected: (item) {
              final category = state.availableCategories.firstWhere((category) => category.id == item.value);
              cubit.selectCategory(category);
            },
          ),
    ).then((_) => FocusManager.instance.primaryFocus?.unfocus());
  }

  Widget _buildCategoryPicker(BuildContext context, CreateEditAssetState state, ThemeColor theme) {
    final t = TranslationStorage.translation;
    return CardFrame(
      headerSectionTtitle: t.productCategoryLabel,
      child: InkWell(
        onTap: () => _openCategoryPicker(context, state),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                state.categoryName ?? t.productSelectCategoryLabel,
                style: TextStyle(
                  color: state.categoryName != null ? theme.primaryText : theme.primaryText.withValues(alpha: 0.4),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (state.categoryId != null)
              InkWell(
                onTap: () => context.read<CreateEditAssetCubit>().selectCategory(null),
                child: Icon(Icons.close, size: 18, color: theme.primaryText.withValues(alpha: 0.5)),
              )
            else
              Icon(Icons.keyboard_arrow_down_rounded, color: theme.primaryText.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  void _onStateChange(BuildContext context, CreateEditAssetState state) {
    final t = TranslationStorage.translation;

    _populateControllersOnce(state, context.read<CreateEditAssetCubit>().isEditMode);

    if (state.saveSucceeded) {
      ToastMessage().showSuccessToast(text: t.productSavedToast);
      context.pop(true);
      return;
    }
    if (state.deleteSucceeded) {
      ToastMessage().showSuccessToast(text: t.productDeletedToast);
      context.pop(true);
      return;
    }
    if (state.errorMessage != null) {
      ToastMessage().showErrorToast(text: state.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationStorage.translation;
    final theme = context.colors;

    return BlocConsumer<CreateEditAssetCubit, CreateEditAssetState>(
      listenWhen:
          (previous, current) =>
              previous.errorMessage != current.errorMessage ||
              previous.saveSucceeded != current.saveSucceeded ||
              previous.deleteSucceeded != current.deleteSucceeded ||
              previous.isPending != current.isPending,
      listener: _onStateChange,
      builder: (context, state) {
        final cubit = context.read<CreateEditAssetCubit>();
        final isEditMode = cubit.isEditMode;
        final canManageInventory = context.read<UserInfoCubit>().canManageInventory;
        final currencySymbol = context.read<TenantConfigCubit>().state.currencySymbol;

        return PageFrame(
          headerActionIcon: Icons.close,
          title: Text(
            t.productDetailsTitle,
            style: TextStyle(color: theme.primaryText, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          pageBody: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Skeletonizer(
                  enabled: isEditMode && state.isPending,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CardFrame(
                        padding: EdgeInsets.zero,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: SizedBox(
                            height: 180,
                            width: double.infinity,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                LoadedImage(
                                  imageUrl: state.imgUrl ?? '',
                                  fit: BoxFit.cover,
                                  alternativeWidget: Container(
                                    color: theme.secondaryBackground,
                                    child: Center(
                                      child: Icon(
                                        Icons.image_outlined,
                                        size: 48,
                                        color: theme.primaryText.withValues(alpha: 0.3),
                                      ),
                                    ),
                                  ),
                                ),
                                if (state.isUploadingImage)
                                  Container(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    child: const Center(child: CircularProgressIndicator()),
                                  ),
                                Positioned(
                                  bottom: 12,
                                  right: 12,
                                  child: InkWell(
                                    onTap: state.isUploadingImage ? null : cubit.pickAndUploadImage,
                                    customBorder: const CircleBorder(),
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: theme.baseWhite,
                                      child: Icon(Icons.edit, size: 18, color: theme.primaryText),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      CardFrame(
                        headerSectionTtitle: t.productNameLabel,
                        child: PrimaryInputField(
                          controller: _nameController,
                          showValidationError: false,
                          onChanged: cubit.setName,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Skeletonizer(
                        enabled: state.isCategoriesPending,
                        child: _buildCategoryPicker(context, state, theme),
                      ),
                      const SizedBox(height: 12),
                      CardFrame(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InputLabel(text: t.productRentalPriceLabel),
                                  const SizedBox(height: 4),
                                  PrimaryInputField(
                                    controller: _rentalPriceController,
                                    showValidationError: false,
                                    minContainerHeight: 0,
                                    keyboardType: TextInputType.number,
                                    isCurrency: true,
                                    sufixIcon: Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: Text(
                                        currencySymbol,
                                        style: TextStyle(
                                          color: theme.primaryText,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) => cubit.setRentalPrice(double.tryParse(value)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InputLabel(text: t.productSalePriceLabel),
                                  const SizedBox(height: 4),
                                  PrimaryInputField(
                                    controller: _salePriceController,
                                    showValidationError: false,
                                    minContainerHeight: 0,
                                    keyboardType: TextInputType.number,
                                    isCurrency: true,
                                    sufixIcon: Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: Text(
                                        currencySymbol,
                                        style: TextStyle(
                                          color: theme.primaryText,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) => cubit.setSalePrice(double.tryParse(value)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      CardFrame(
                        headerSectionTtitle: t.productStockCountLabel,
                        child: PrimaryInputField(
                          controller: _stockCountController,
                          showValidationError: false,
                          minContainerHeight: 0,
                          keyboardType: TextInputType.number,
                          onChanged: (value) => cubit.setStockCount(int.tryParse(value) ?? 0),
                        ),
                      ),
                      if (isEditMode) ...[
                        const SizedBox(height: 12),
                        CardFrame(
                          headerSectionTtitle: t.productCurrentlyReservedLabel,
                          child: Text(
                            '${state.currentlyReserved ?? 0} ${t.productStockUnitLabel}',
                            style: TextStyle(color: theme.primaryText.withValues(alpha: 0.7), fontSize: 14),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                CardFrame(
                  headerSectionTtitle: t.productDescriptionLabel,
                  child: PrimaryInputField(
                    controller: _descriptionController,
                    areaField: 3,
                    showValidationError: false,
                    onChanged: cubit.setDescription,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 28),

                if (canManageInventory) ...[
                  if (isEditMode) ...[
                    CustomOutlinedButton(
                      title: t.removeProductButton,
                      backgroundColor: Colors.transparent,
                      borderColor: theme.brandError,
                      color: theme.brandError,
                      onClick: () => _confirm(context, message: t.confirmDeleteProduct, onConfirm: cubit.deleteAsset),
                    ),
                    const SizedBox(height: 10),
                  ],
                  ButtonWithLoadingState(
                    buttonText: isEditMode ? t.saveChangesButton : t.createProductButton,
                    loading: state.isSaving,
                    buttonPressed: state.canSave(isEditMode) ? cubit.save : null,
                    backgroundColor: theme.brandPrimary,
                    textColor: Colors.white,
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
