import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:business_assistant/config/translations/translation_storage.dart';
import 'package:business_assistant/core/features/events/cubits/create_edit_event/create_edit_event_cubit.dart';
import 'package:business_assistant/core/features/events/models/page_props/create_edit_event_page_props.dart';
import 'package:business_assistant/core/features/events/view/widgets/event_asset_tile.dart';
import 'package:business_assistant/core/features/events/view/widgets/event_cost_tile.dart';
import 'package:business_assistant/core/features/tenant/cubits/tenant_config/tenant_config_cubit.dart';
import 'package:business_assistant/core/shared/models/dropdowns/base_dropdown_item.dart';
import 'package:business_assistant/core/shared/pages/page_frame/page_frame.dart';
import 'package:business_assistant/core/shared/widgets/buttons/button_with_loading_state.dart';
import 'package:business_assistant/core/shared/widgets/cards/card_frame.dart';
import 'package:business_assistant/core/shared/widgets/cards/date_selection_card.dart';
import 'package:business_assistant/core/shared/widgets/buttons/custom_outlined_button.dart';
import 'package:business_assistant/core/shared/widgets/input_fields/location_input_field.dart';
import 'package:business_assistant/core/shared/widgets/input_fields/primary_input_field.dart';
import 'package:business_assistant/core/shared/widgets/modals/selection_bottom_modal.dart';
import 'package:business_assistant/core/utils/launcher.dart';
import 'package:business_assistant/core/utils/toast_message.dart';
import 'package:business_assistant/theme/get_theme_color.dart';
import 'package:business_assistant/theme/theme_color.dart';

/// Create/edit form for a Rental event — reused for both flows since the
/// fields and validation are identical; only pageProps.eventId (null →
/// create) and the Cancel/Delete actions (edit-mode only) differ.
class CreateEditEventPage extends StatelessWidget {
  final CreateEditEventPageProps? pageProps;

  const CreateEditEventPage({super.key, this.pageProps});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateEditEventCubit>(
      create:
          (_) =>
              CreateEditEventCubit(eventId: pageProps?.eventId, initialClientId: pageProps?.initialClientId)
                ..loadFormData(),
      child: const _CreateEditEventPageContent(),
    );
  }
}

class _CreateEditEventPageContent extends StatefulWidget {
  const _CreateEditEventPageContent();

  @override
  State<_CreateEditEventPageContent> createState() => _CreateEditEventPageContentState();
}

class _CreateEditEventPageContentState extends State<_CreateEditEventPageContent> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  bool _controllersPopulated = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _populateControllersOnce(CreateEditEventState state, bool isEditMode) {
    if (_controllersPopulated) return;
    // In edit mode, wait for the event to actually load — otherwise this
    // fires once with the still-empty defaults and never gets to run again.
    if (isEditMode && state.isEventPending) return;
    _controllersPopulated = true;
    _titleController.text = state.title;
    _descriptionController.text = state.description;
    _locationController.text = state.locationAddress;
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

  void _openProductPicker(BuildContext context, CreateEditEventState state) {
    final cubit = context.read<CreateEditEventCubit>();
    final addedIds = state.eventAssets.map((ea) => ea.assetId).toSet();
    final theme = context.colors;
    final currencySymbol = context.read<TenantConfigCubit>().state.currencySymbol;
    final items =
        state.availableAssets
            .where((asset) => !addedIds.contains(asset.id))
            .map(
              (asset) => BaseDropdownItem(
                text: asset.name,
                value: asset.id,
                subtitle: asset.categoryName,
                rightContent:
                    asset.rentalPrice != null
                        ? Text(
                          '${asset.rentalPrice!.toStringAsFixed(0)} $currencySymbol',
                          style: TextStyle(color: theme.statusFinished, fontSize: 15, fontWeight: FontWeight.w600),
                        )
                        : null,
              ),
            )
            .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => SelectionBottomModal(
            title: TranslationStorage.translation.selectProductTitle,
            items: items,
            onItemSelected: (item) {
              final asset = state.availableAssets.firstWhere((asset) => asset.id == item.value);
              cubit.addEventAsset(asset);
            },
          ),
    ).then((_) => FocusManager.instance.primaryFocus?.unfocus());
  }

  void _openInMaps(double? latitude, double? longitude, String address) {
    final query = latitude != null && longitude != null ? '$latitude,$longitude' : address;
    final uri = Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': query});
    launchWebUrl(uri.toString());
  }

  void _openClientPicker(BuildContext context, CreateEditEventState state) {
    final cubit = context.read<CreateEditEventCubit>();
    final items =
        state.availableClients
            .map((client) => BaseDropdownItem(text: client.name, value: client.id, subtitle: client.phoneNumber))
            .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => SelectionBottomModal(
            title: TranslationStorage.translation.selectClientTitle,
            items: items,
            onItemSelected: (item) {
              final client = state.availableClients.firstWhere((client) => client.id == item.value);
              cubit.selectClient(client);
            },
          ),
    ).then((_) => FocusManager.instance.primaryFocus?.unfocus());
  }

  void _onStateChange(BuildContext context, CreateEditEventState state) {
    final t = TranslationStorage.translation;

    _populateControllersOnce(state, context.read<CreateEditEventCubit>().isEditMode);

    if (state.saveSucceeded) {
      ToastMessage().showSuccessToast(text: t.eventSavedToast);
      context.pop(true);
      return;
    }
    if (state.cancelSucceeded) {
      ToastMessage().showSuccessToast(text: t.eventCancelledToast);
      context.pop(true);
      return;
    }
    if (state.deleteSucceeded) {
      ToastMessage().showSuccessToast(text: t.eventDeletedToast);
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

    return BlocConsumer<CreateEditEventCubit, CreateEditEventState>(
      listenWhen:
          (previous, current) =>
              previous.errorMessage != current.errorMessage ||
              previous.saveSucceeded != current.saveSucceeded ||
              previous.cancelSucceeded != current.cancelSucceeded ||
              previous.deleteSucceeded != current.deleteSucceeded ||
              previous.isEventPending != current.isEventPending,
      listener: _onStateChange,
      builder: (context, state) {
        final cubit = context.read<CreateEditEventCubit>();
        final isEditMode = cubit.isEditMode;
        final totalValue =
            state.eventAssets.fold<double>(0, (sum, ea) => sum + ea.price * ea.quantity) +
            state.eventCosts.where((ec) => ec.isIncludedInTotalCost).fold<double>(0, (sum, ec) => sum + ec.cost);
        final currencySymbol = context.read<TenantConfigCubit>().state.currencySymbol;

        return PageFrame(
          headerActionIcon: Icons.close,
          headerActions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${totalValue.toStringAsFixed(0)} $currencySymbol',
                  style: TextStyle(color: theme.statusFinished, fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
          title: Text(
            t.eventDetailsTitle,
            style: TextStyle(color: theme.primaryText, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          pageBody: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Skeletonizer(
                  enabled: isEditMode && state.isEventPending,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildBalanceSection(context, state, theme, currencySymbol),
                      const SizedBox(height: 12),
                      CardFrame(
                        headerSectionTtitle: t.eventTitleLabel,
                        child: PrimaryInputField(
                          controller: _titleController,
                          showValidationError: false,
                          onChanged: cubit.setTitle,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),

                      const SizedBox(height: 12),
                      DateSelectionCard(
                        title: t.eventDateRangeLabel,
                        allDayLabel: t.eventAllDayLabel,
                        fromLabel: t.eventFromLabel,
                        toLabel: t.eventToLabel,
                        from: state.from,
                        to: state.to,
                        onFromChanged: cubit.setFrom,
                        onToChanged: cubit.setTo,
                      ),

                      const SizedBox(height: 12),
                      CardFrame(
                        headerSectionTtitle: t.eventLocationLabel,
                        child: Column(
                          // crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            LocationInputField(
                              controller: _locationController,
                              onLocationSelected: cubit.setLocation,
                              language: TranslationStorage().selectedLanguage.languageCode,
                            ),

                            if (state.locationAddress.trim().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed:
                                      () => _openInMaps(
                                        state.locationLatitude,
                                        state.locationLongitude,
                                        state.locationAddress,
                                      ),
                                  icon: const Icon(Icons.map_outlined, size: 18),
                                  label: Text(t.eventViewOnMapLabel),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Skeletonizer(enabled: state.isClientPending, child: _buildClientPicker(context, state, theme)),
                const SizedBox(height: 24),
                Skeletonizer(enabled: state.isAssetsPending, child: _buildProductsSection(context, state, theme)),
                const SizedBox(height: 24),
                _buildCostsSection(context, state, theme),
                const SizedBox(height: 12),

                CardFrame(
                  headerSectionTtitle: t.eventDescriptionLabel,
                  child: PrimaryInputField(
                    controller: _descriptionController,
                    areaField: 3,
                    showValidationError: false,
                    onChanged: cubit.setDescription,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 28),

                if (isEditMode && !state.isCancelled) ...[
                  CustomOutlinedButton(
                    title: t.cancelEventButton,
                    backgroundColor: Colors.transparent,
                    borderColor: theme.brandError,
                    color: theme.brandError,
                    onClick: () => _confirm(context, message: t.confirmCancelEvent, onConfirm: cubit.cancelEvent),
                  ),
                  const SizedBox(height: 10),
                ],
                if (isEditMode) ...[
                  CustomOutlinedButton(
                    title: t.deleteEventButton,
                    backgroundColor: Colors.transparent,
                    borderColor: theme.brandError,
                    color: theme.brandError,
                    onClick: () => _confirm(context, message: t.confirmDeleteEvent, onConfirm: cubit.deleteEvent),
                  ),
                  const SizedBox(height: 10),
                ],
                ButtonWithLoadingState(
                  buttonText: isEditMode ? t.saveChangesButton : t.createEventButton,
                  loading: state.isSaving,
                  buttonPressed: state.canSave(isEditMode) ? cubit.save : null,
                  backgroundColor: theme.brandPrimary,
                  textColor: Colors.white,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBalanceSection(BuildContext context, CreateEditEventState state, ThemeColor theme, String currencySymbol) {
    final t = TranslationStorage.translation;

    final assetsValue = state.eventAssets.fold<double>(0, (sum, ea) => sum + ea.price * ea.quantity);
    final includedCosts =
        state.eventCosts.where((ec) => ec.isIncludedInTotalCost).fold<double>(0, (sum, ec) => sum + ec.cost);
    final extraCosts =
        state.eventCosts.where((ec) => !ec.isIncludedInTotalCost).fold<double>(0, (sum, ec) => sum + ec.cost);
    final netBalance = assetsValue - extraCosts;

    return CardFrame(
      headerSectionTtitle: t.eventBalanceTitle,
      child: Column(
        children: [
          _buildBalanceRow(theme, t.eventBalanceAssetsValueLabel, assetsValue, theme.statusFinished, currencySymbol),
          Divider(height: 20, color: theme.primaryText.withValues(alpha: 0.08)),
          _buildBalanceRow(
            theme,
            t.eventBalanceIncludedCostsLabel,
            includedCosts,
            theme.statusFinished,
            currencySymbol,
          ),
          Divider(height: 20, color: theme.primaryText.withValues(alpha: 0.08)),
          _buildBalanceRow(theme, t.eventBalanceExtraCostsLabel, extraCosts, theme.brandError, currencySymbol),
          Divider(height: 20, color: theme.primaryText.withValues(alpha: 0.08)),
          _buildBalanceRow(
            theme,
            t.eventBalanceTotalLabel,
            netBalance,
            netBalance >= 0 ? theme.statusFinished : theme.brandError,
            currencySymbol,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceRow(
    ThemeColor theme,
    String label,
    double value,
    Color valueColor,
    String currencySymbol, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: theme.primaryText, fontSize: 14, fontWeight: isBold ? FontWeight.w700 : FontWeight.w500),
        ),
        Text(
          '${value.toStringAsFixed(0)} $currencySymbol',
          style: TextStyle(color: valueColor, fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildClientPicker(BuildContext context, CreateEditEventState state, ThemeColor theme) {
    final t = TranslationStorage.translation;
    return CardFrame(
      headerSectionTtitle: t.eventClientLabel,
      child: InkWell(
        onTap: () => _openClientPicker(context, state),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Icon(Icons.person_outline, color: theme.primaryText.withValues(alpha: 0.5), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                state.clientName ?? t.eventSelectClientLabel,
                style: TextStyle(
                  color: state.clientName != null ? theme.primaryText : theme.primaryText.withValues(alpha: 0.4),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (state.clientId != null)
              InkWell(
                onTap: () => context.read<CreateEditEventCubit>().selectClient(null),
                child: Icon(Icons.close, size: 18, color: theme.primaryText.withValues(alpha: 0.5)),
              )
            else
              Icon(Icons.keyboard_arrow_down_rounded, color: theme.primaryText.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsSection(BuildContext context, CreateEditEventState state, ThemeColor theme) {
    final t = TranslationStorage.translation;
    final cubit = context.read<CreateEditEventCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              t.eventProductsLabel,
              style: TextStyle(color: theme.primaryText, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            TextButton.icon(
              onPressed: state.canAddProduct ? () => _openProductPicker(context, state) : null,
              icon: const Icon(Icons.add, size: 18),
              label: Text(t.addProductButton),
            ),
          ],
        ),
        if (!state.canAddProduct) ...[
          Text(t.eventSelectDatesFirstHint, style: TextStyle(color: theme.brandError, fontSize: 12)),
          const SizedBox(height: 8),
        ],
        if (state.eventAssets.isNotEmpty) const SizedBox(height: 8),
        ...state.eventAssets.map(
          (item) => EventAssetTile(
            key: ValueKey(item.assetId),
            item: item,
            onQuantityChanged: (quantity) => cubit.updateEventAssetQuantity(item.assetId, quantity),
            onPriceChanged: (price) => cubit.updateEventAssetPrice(item.assetId, price),
            onRemove: () => cubit.removeEventAsset(item.assetId),
          ),
        ),
      ],
    );
  }

  Widget _buildCostsSection(BuildContext context, CreateEditEventState state, ThemeColor theme) {
    final t = TranslationStorage.translation;
    final cubit = context.read<CreateEditEventCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              t.eventCostsLabel,
              style: TextStyle(color: theme.primaryText, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            TextButton.icon(
              onPressed: cubit.addEventCost,
              icon: const Icon(Icons.add, size: 18),
              label: Text(t.addCostButton),
            ),
          ],
        ),
        if (state.eventCosts.isNotEmpty) const SizedBox(height: 8),
        ...state.eventCosts.map(
          (item) => EventCostTile(
            key: ValueKey(item.localId),
            item: item,
            onTitleChanged: (title) => cubit.updateEventCostTitle(item.localId, title),
            onCostChanged: (cost) => cubit.updateEventCostAmount(item.localId, cost),
            onIncludedChanged: (included) => cubit.updateEventCostIncluded(item.localId, included),
            onRemove: () => cubit.removeEventCost(item.localId),
          ),
        ),
      ],
    );
  }
}
