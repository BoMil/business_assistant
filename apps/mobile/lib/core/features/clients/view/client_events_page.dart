import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:business_assistant/config/routes/route_names.dart';
import 'package:business_assistant/config/translations/translation_storage.dart';
import 'package:business_assistant/core/features/clients/cubits/client_events/client_events_cubit.dart';
import 'package:business_assistant/core/features/clients/models/page_props/client_events_page_props.dart';
import 'package:business_assistant/core/features/events/models/page_props/create_edit_event_page_props.dart';
import 'package:business_assistant/core/features/events/view/event_card.dart';
import 'package:business_assistant/core/features/events/view/widgets/event_card_skeleton.dart';
import 'package:business_assistant/core/shared/enums/cubit_state.dart';
import 'package:business_assistant/core/shared/pages/page_frame/page_frame.dart';
import 'package:business_assistant/theme/get_theme_color.dart';

/// Read-only list of one client's events (GET /clients/{id}/transactions),
/// reached from CreateEditClientPage's "Events" row. Reuses EventCard as-is —
/// no search box, no FAB (not part of this view).
class ClientEventsPage extends StatelessWidget {
  final ClientEventsPageProps? pageProps;

  const ClientEventsPage({super.key, this.pageProps});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ClientEventsCubit>(
      create: (_) => ClientEventsCubit(clientId: pageProps?.clientId ?? '')..loadEvents(),
      child: _ClientEventsPageContent(clientName: pageProps?.clientName ?? ''),
    );
  }
}

class _ClientEventsPageContent extends StatelessWidget {
  final String clientName;

  const _ClientEventsPageContent({required this.clientName});

  void _openEditEvent(BuildContext context, String eventId) {
    context.push(RouteNames.editEventPage, extra: CreateEditEventPageProps(eventId: eventId));
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationStorage.translation;
    final theme = context.colors;

    return PageFrame(
      headerActionIcon: Icons.close,
      title: Text(
        '$clientName ${t.clientEventsLabel}',
        style: TextStyle(color: theme.primaryText, fontSize: 16, fontWeight: FontWeight.w600),
      ),
      pageBody: BlocBuilder<ClientEventsCubit, ClientEventsState>(
        builder: (context, state) {
          if (state.currentState == CubitState.loading) {
            return const EventCardSkeleton();
          }

          if (state.currentState == CubitState.error) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(state.errorMessage ?? t.genericErrorMessage, style: TextStyle(color: theme.brandError)),
              ),
            );
          }

          if (state.events.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(t.eventsEmptyStateText, style: TextStyle(color: theme.primaryText.withValues(alpha: 0.5))),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                ...state.events.map(
                  (event) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: EventCard(event: event, onTap: () => _openEditEvent(context, event.id)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
