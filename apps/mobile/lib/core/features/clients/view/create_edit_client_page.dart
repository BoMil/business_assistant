import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:business_assistant/config/routes/route_names.dart';
import 'package:business_assistant/config/translations/translation_storage.dart';
import 'package:business_assistant/core/features/authentication/cubits/auth/auth_cubit.dart';
import 'package:business_assistant/core/features/clients/cubits/create_edit_client/create_edit_client_cubit.dart';
import 'package:business_assistant/core/features/clients/models/page_props/client_events_page_props.dart';
import 'package:business_assistant/core/features/clients/models/page_props/create_edit_client_page_props.dart';
import 'package:business_assistant/core/features/events/models/page_props/create_edit_event_page_props.dart';
import 'package:business_assistant/core/shared/pages/page_frame/page_frame.dart';
import 'package:business_assistant/core/shared/widgets/buttons/button_with_loading_state.dart';
import 'package:business_assistant/core/shared/widgets/buttons/custom_outlined_button.dart';
import 'package:business_assistant/core/shared/widgets/cards/card_frame.dart';
import 'package:business_assistant/core/shared/widgets/input_fields/location_input_field.dart';
import 'package:business_assistant/core/shared/widgets/input_fields/primary_input_field.dart';
import 'package:business_assistant/core/utils/toast_message.dart';
import 'package:business_assistant/theme/get_theme_color.dart';

/// Create/edit form for a Client — reused for both flows since the fields
/// and validation are identical; only pageProps.clientId (null → create) and
/// the Add-event/Remove actions (edit-mode only) differ.
class CreateEditClientPage extends StatelessWidget {
  final CreateEditClientPageProps? pageProps;

  const CreateEditClientPage({super.key, this.pageProps});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateEditClientCubit>(
      create: (_) => CreateEditClientCubit(clientId: pageProps?.clientId)..loadFormData(),
      child: const _CreateEditClientPageContent(),
    );
  }
}

class _CreateEditClientPageContent extends StatefulWidget {
  const _CreateEditClientPageContent();

  @override
  State<_CreateEditClientPageContent> createState() => _CreateEditClientPageContentState();
}

class _CreateEditClientPageContentState extends State<_CreateEditClientPageContent> {
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  bool _controllersPopulated = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _populateControllersOnce(CreateEditClientState state, bool isEditMode) {
    if (_controllersPopulated) return;
    // In edit mode, wait for the client to actually load — otherwise this
    // fires once with the still-empty defaults and never gets to run again.
    if (isEditMode && state.isPending) return;
    _controllersPopulated = true;
    _nameController.text = state.name;
    _phoneNumberController.text = state.phoneNumber;
    _emailController.text = state.email;
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

  void _openAddNewEvent(BuildContext context, String clientId) {
    context.push(RouteNames.createEventPage, extra: CreateEditEventPageProps(initialClientId: clientId));
  }

  void _openClientEvents(BuildContext context, String clientId, String clientName) {
    context.push(RouteNames.clientEventsPage, extra: ClientEventsPageProps(clientId: clientId, clientName: clientName));
  }

  void _onStateChange(BuildContext context, CreateEditClientState state) {
    final t = TranslationStorage.translation;

    _populateControllersOnce(state, context.read<CreateEditClientCubit>().isEditMode);

    if (state.saveSucceeded) {
      ToastMessage().showSuccessToast(text: t.clientSavedToast);
      context.pop();
      return;
    }
    if (state.deleteSucceeded) {
      ToastMessage().showSuccessToast(text: t.clientDeletedToast);
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

    return BlocConsumer<CreateEditClientCubit, CreateEditClientState>(
      listenWhen:
          (previous, current) =>
              previous.errorMessage != current.errorMessage ||
              previous.saveSucceeded != current.saveSucceeded ||
              previous.deleteSucceeded != current.deleteSucceeded ||
              previous.isPending != current.isPending,
      listener: _onStateChange,
      builder: (context, state) {
        final cubit = context.read<CreateEditClientCubit>();
        final isEditMode = cubit.isEditMode;
        final canManageClients = context.read<AuthCubit>().canManageClients;

        return PageFrame(
          headerActionIcon: Icons.close,
          title: Text(
            t.clientDetailsTitle,
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
                        headerSectionTtitle: t.clientNameLabel,
                        child: PrimaryInputField(
                          controller: _nameController,
                          showValidationError: false,
                          onChanged: cubit.setName,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 12),
                      CardFrame(
                        headerSectionTtitle: t.clientPhoneNumberLabel,
                        child: PrimaryInputField(
                          controller: _phoneNumberController,
                          showValidationError: false,
                          keyboardType: TextInputType.phone,
                          onChanged: cubit.setPhoneNumber,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 12),
                      CardFrame(
                        headerSectionTtitle: t.clientEmailLabel,
                        child: PrimaryInputField(
                          controller: _emailController,
                          showValidationError: false,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: cubit.setEmail,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 12),
                      CardFrame(
                        headerSectionTtitle: t.clientLocationLabel,
                        child: LocationInputField(
                          controller: _locationController,
                          onLocationSelected: cubit.setLocation,
                          language: TranslationStorage().selectedLanguage.languageCode,
                        ),
                      ),
                      if (isEditMode) ...[
                        const SizedBox(height: 12),
                        CardFrame(
                          headerSectionTtitle: t.clientEventsLabel,
                          child: InkWell(
                            onTap: () => _openClientEvents(context, cubit.clientId!, state.name),
                            borderRadius: BorderRadius.circular(12),
                            child: Row(
                              children: [
                                Icon(Icons.event_outlined, color: theme.primaryText.withValues(alpha: 0.5), size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    t.clientEventsLabel,
                                    style: TextStyle(color: theme.primaryText, fontSize: 14, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_right_rounded, color: theme.primaryText.withValues(alpha: 0.5)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                CardFrame(
                  headerSectionTtitle: t.clientDescriptionLabel,
                  child: PrimaryInputField(
                    controller: _descriptionController,
                    areaField: 3,
                    showValidationError: false,
                    onChanged: cubit.setDescription,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 28),

                if (canManageClients) ...[
                  if (isEditMode) ...[
                    CustomOutlinedButton(
                      title: t.addNewEventButton,
                      backgroundColor: Colors.transparent,
                      borderColor: theme.brandPrimary,
                      color: theme.brandPrimary,
                      onClick: () => _openAddNewEvent(context, cubit.clientId!),
                    ),
                    const SizedBox(height: 10),
                    CustomOutlinedButton(
                      title: t.removeClientButton,
                      backgroundColor: Colors.transparent,
                      borderColor: theme.brandError,
                      color: theme.brandError,
                      onClick: () => _confirm(context, message: t.confirmDeleteClient, onConfirm: cubit.deleteClient),
                    ),
                    const SizedBox(height: 10),
                  ],
                  ButtonWithLoadingState(
                    buttonText: isEditMode ? t.saveChangesButton : t.createClientButton,
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
