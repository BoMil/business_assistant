import 'package:business_assistant/core/features/authentication/cubits/auth/auth_cubit.dart';
import 'package:business_assistant/core/features/bottom_navigation/cubits/bottom_navigation/bottom_navigation_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:business_assistant/config/routes/route_names.dart';
import 'package:business_assistant/config/translations/translation_storage.dart';
import 'package:business_assistant/core/features/events/cubits/events/events_cubit.dart';
import 'package:business_assistant/core/features/events/view/event_card.dart';
import 'package:business_assistant/core/features/events/view/widgets/event_card_skeleton.dart';
import 'package:business_assistant/core/features/main_header/view/main_header.dart';
import 'package:business_assistant/core/features/pagination/triggers/pagination_listener_cubit_generic_trigger.dart';
import 'package:business_assistant/core/shared/enums/cubit_state.dart';
import 'package:business_assistant/core/shared/pages/page_frame/page_frame.dart';
import 'package:business_assistant/core/shared/widgets/input_fields/text_search.dart';
import 'package:business_assistant/theme/get_theme_color.dart';

/// Events tab — a paginated, server-searched list of the tenant's Rental
/// events, with a FAB to create a new one. Pagination/search mechanics come
/// from PaginationCubitBase via EventsCubit — this page only renders state.
class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EventsCubit>(create: (_) => EventsCubit()..resetState(), child: const _EventsPageContent());
  }
}

class _EventsPageContent extends StatelessWidget {
  const _EventsPageContent();

  Future<void> _openCreateEvent(BuildContext context) async {
    final cubit = context.read<EventsCubit>();
    await context.push(RouteNames.createEventPage);
    cubit.resetState();
  }

  Future<void> _openEditEvent(BuildContext context, String eventId) async {
    final cubit = context.read<EventsCubit>();
    await context.push(RouteNames.editEventPagePath(eventId));
    cubit.resetState();
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationStorage.translation;
    final theme = context.colors;

    return BlocListener<BottomNavigationCubit, BottomNavigationState>(
      listener: (context, state) {
        bool isAuthanticated = context.read<AuthCubit>().state is Authenticated;
        if (isAuthanticated && context.read<BottomNavigationCubit>().isTabSelected(RouteNames.eventsPage)) {
          context.read<EventsCubit>().resetState();
        }
      },
      child: PageFrame(
        isHeaderVisible: false,
        pageHeader: const MainHeader(),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openCreateEvent(context),
          backgroundColor: theme.brandPrimary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        pageBody: GenericPaginationTrigger<EventsCubit>(
          fixedContent: SliverAppBar(
            toolbarHeight: 70,
            collapsedHeight: 70,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            pinned: true,
            flexibleSpace: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: TextSearch(
                hintText: t.eventsSearchHint,
                onTypingComplete: (query) => context.read<EventsCubit>().changeSearch(query),
              ),
            ),
          ),
          child: BlocBuilder<EventsCubit, EventsState>(
            builder: (context, state) {
              final items = state.eventsResponse.items;

              if (state.currentState == CubitState.loading && items.isEmpty) {
                return const EventCardSkeleton();
              }

              if (state.currentState == CubitState.error && items.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(state.errorMessage ?? t.genericErrorMessage, style: TextStyle(color: theme.brandError)),
                  ),
                );
              }

              if (items.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      t.eventsEmptyStateText,
                      style: TextStyle(color: theme.primaryText.withValues(alpha: 0.5)),
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  ...items.map(
                    (event) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: EventCard(event: event, onTap: () => _openEditEvent(context, event.id)),
                    ),
                  ),
                  // "Load more" placeholder — only shown once page 1 already has items.
                  if (state.currentState == CubitState.loading) const EventCardSkeleton(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
