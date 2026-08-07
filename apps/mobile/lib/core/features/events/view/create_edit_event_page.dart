import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:business_assistant/config/translations/translation_storage.dart';
import 'package:business_assistant/core/features/events/cubits/create_edit_event/create_edit_event_cubit.dart';
import 'package:business_assistant/core/features/events/view/widgets/event_asset_tile.dart';
import 'package:business_assistant/core/shared/models/dropdowns/base_dropdown_item.dart';
import 'package:business_assistant/core/shared/models/input_fields/date_input_field_props.dart';
import 'package:business_assistant/core/shared/pages/page_frame/page_frame.dart';
import 'package:business_assistant/core/shared/widgets/buttons/button_with_loading_state.dart';
import 'package:business_assistant/core/shared/widgets/buttons/custom_outlined_button.dart';
import 'package:business_assistant/core/shared/widgets/input_fields/date_input/date_input_field.dart';
import 'package:business_assistant/core/shared/widgets/input_fields/date_input/date_input_time_selection.dart';
import 'package:business_assistant/core/shared/widgets/input_fields/location_input_field.dart';
import 'package:business_assistant/core/shared/widgets/input_fields/primary_input_field.dart';
import 'package:business_assistant/core/shared/widgets/modals/selection_bottom_modal.dart';
import 'package:business_assistant/core/utils/toast_message.dart';
import 'package:business_assistant/theme/get_theme_color.dart';
import 'package:business_assistant/theme/theme_color.dart';

/// Create/edit form for a Rental event — reused for both flows since the
/// fields and validation are identical; only eventId (null → create) and the
/// Cancel/Delete actions (edit-mode only) differ.
class CreateEditEventPage extends StatelessWidget {
  final String? eventId;

  const CreateEditEventPage({super.key, this.eventId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateEditEventCubit>(
      create: (_) => CreateEditEventCubit(eventId: eventId)..loadFormData(),
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

  // Test-only fields for trying out DateInputTimeSelection (sequential native
  // date + time pickers) side by side with DateInputField's combined picker.
  DateTime? _testFrom;
  DateTime? _testTo;

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
    final items =
        state.availableAssets
            .where((asset) => !addedIds.contains(asset.id))
            .map((asset) => BaseDropdownItem(text: asset.name, value: asset.id, subtitle: asset.category))
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
    );
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
    );
  }

  void _onStateChange(BuildContext context, CreateEditEventState state) {
    final t = TranslationStorage.translation;

    if (state.saveSucceeded) {
      ToastMessage().showSuccessToast(text: t.eventSavedToast);
      context.pop();
      return;
    }
    if (state.cancelSucceeded) {
      ToastMessage().showSuccessToast(text: t.eventCancelledToast);
      context.pop();
      return;
    }
    if (state.deleteSucceeded) {
      ToastMessage().showSuccessToast(text: t.eventDeletedToast);
      context.pop();
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
              previous.deleteSucceeded != current.deleteSucceeded,
      listener: _onStateChange,
      builder: (context, state) {
        final cubit = context.read<CreateEditEventCubit>();
        final isEditMode = cubit.isEditMode;

        _populateControllersOnce(state, isEditMode);

        return PageFrame(
          headerActionIcon: Icons.close,
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
                      PrimaryInputField(
                        controller: _titleController,
                        placeholderText: t.eventTitleLabel,
                        hintText: t.eventTitleLabel,
                        showValidationError: false,
                        onChanged: cubit.setTitle,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      const SizedBox(height: 12),
                      PrimaryInputField(
                        controller: _descriptionController,
                        placeholderText: t.eventDescriptionLabel,
                        hintText: t.eventDescriptionLabel,
                        areaField: 3,
                        showValidationError: false,
                        onChanged: cubit.setDescription,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      const SizedBox(height: 12),
                      DateInputField(
                        props: DateInputFieldProps(
                          infoTitle: t.eventFromLabel,
                          placeholderText: t.eventFromLabel,
                          preselectedDate: state.from,
                          includeTime: true,
                          dateChanged: ({required date}) => cubit.setFrom(date.date),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DateInputField(
                        props: DateInputFieldProps(
                          infoTitle: t.eventToLabel,
                          placeholderText: t.eventToLabel,
                          preselectedDate: state.to,
                          firstDate: state.from,
                          includeTime: true,
                          dateChanged: ({required date}) => cubit.setTo(date.date),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // DateInputTimeSelection(
                      //   props: DateInputFieldProps(
                      //     infoTitle: '${t.eventFromLabel} (test)',
                      //     placeholderText: '${t.eventFromLabel} (test)',
                      //     preselectedDate: _testFrom,
                      //     dateChanged: ({required date}) => setState(() => _testFrom = date.date),
                      //   ),
                      // ),
                      // const SizedBox(height: 12),
                      // DateInputTimeSelection(
                      //   props: DateInputFieldProps(
                      //     infoTitle: '${t.eventToLabel} (test)',
                      //     placeholderText: '${t.eventToLabel} (test)',
                      //     preselectedDate: _testTo,
                      //     firstDate: _testFrom,
                      //     dateChanged: ({required date}) => setState(() => _testTo = date.date),
                      //   ),
                      // ),
                      // const SizedBox(height: 12),
                      LocationInputField(
                        controller: _locationController,
                        hintText: t.eventLocationLabel,
                        onLocationSelected: cubit.setLocation,
                        language: TranslationStorage().selectedLanguage.languageCode,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Skeletonizer(
                  enabled: state.isClientPending,
                  child: _buildClientPicker(context, state, theme),
                ),
                const SizedBox(height: 24),
                Skeletonizer(
                  enabled: state.isAssetsPending,
                  child: _buildProductsSection(context, state, theme),
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

  Widget _buildClientPicker(BuildContext context, CreateEditEventState state, ThemeColor theme) {
    final t = TranslationStorage.translation;
    return InkWell(
      onTap: () => _openClientPicker(context, state),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: theme.baseWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.primaryText.withValues(alpha: 0.15)),
        ),
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
          Text(
            t.eventSelectDatesFirstHint,
            style: TextStyle(color: theme.primaryText.withValues(alpha: 0.4), fontSize: 12),
          ),
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
}
