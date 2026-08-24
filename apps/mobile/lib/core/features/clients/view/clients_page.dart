import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:business_assistant/config/routes/route_names.dart';
import 'package:business_assistant/config/translations/translation_storage.dart';
import 'package:business_assistant/core/features/authentication/cubits/auth/auth_cubit.dart';
import 'package:business_assistant/core/features/authentication/cubits/user_info/user_info_cubit.dart';
import 'package:business_assistant/core/features/bottom_navigation/cubits/bottom_navigation/bottom_navigation_cubit.dart';
import 'package:business_assistant/core/features/clients/cubits/clients/clients_cubit.dart';
import 'package:business_assistant/core/features/clients/models/page_props/create_edit_client_page_props.dart';
import 'package:business_assistant/core/features/clients/view/client_card.dart';
import 'package:business_assistant/core/features/clients/view/widgets/client_card_skeleton.dart';
import 'package:business_assistant/core/features/main_header/view/main_header.dart';
import 'package:business_assistant/core/shared/enums/cubit_state.dart';
import 'package:business_assistant/core/shared/pages/page_frame/page_frame.dart';
import 'package:business_assistant/core/shared/widgets/input_fields/text_search.dart';
import 'package:business_assistant/theme/get_theme_color.dart';

/// Clients tab — an unpaginated (GET /clients returns everything at once),
/// client-side-searched list of the tenant's clients, with a FAB to create a
/// new one. ClientsCubit intentionally doesn't use PaginationCubitBase, so
/// this page builds its own CustomScrollView instead of GenericPaginationTrigger.
class ClientsPage extends StatelessWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ClientsCubit>(create: (_) => ClientsCubit()..loadClients(), child: const _ClientsPageContent());
  }
}

class _ClientsPageContent extends StatelessWidget {
  const _ClientsPageContent();

  Future<void> _openCreateClient(BuildContext context) async {
    final cubit = context.read<ClientsCubit>();
    final saved = await context.push<bool>(RouteNames.createClientPage);
    if (saved == true) cubit.resetState();
  }

  Future<void> _openEditClient(BuildContext context, String clientId) async {
    final cubit = context.read<ClientsCubit>();
    final saved = await context.push<bool>(RouteNames.editClientPage, extra: CreateEditClientPageProps(clientId: clientId));
    if (saved == true) cubit.resetState();
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationStorage.translation;
    final theme = context.colors;
    final canManageClients = context.watch<UserInfoCubit>().canManageClients;

    return BlocListener<BottomNavigationCubit, BottomNavigationState>(
      listener: (context, state) {
        bool isAuthanticated = context.read<AuthCubit>().state is Authenticated;
        if (isAuthanticated && context.read<BottomNavigationCubit>().isTabSelected(RouteNames.clientsPage)) {
          context.read<ClientsCubit>().resetState();
        }
      },
      child: PageFrame(
        isHeaderVisible: false,
        pageHeader: const MainHeader(),
        floatingActionButton:
            canManageClients
                ? FloatingActionButton(
                  heroTag: 'clientsFab',
                  onPressed: () => _openCreateClient(context),
                  backgroundColor: theme.brandPrimary,
                  child: const Icon(Icons.add, color: Colors.white),
                )
                : null,
        pageBody: CustomScrollView(
          slivers: [
            SliverAppBar(
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
                  hintText: t.clientsSearchHint,
                  onTypingComplete: (query) => context.read<ClientsCubit>().changeSearch(query),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: BlocBuilder<ClientsCubit, ClientsState>(
                builder: (context, state) {
                  final items = state.filteredClients;

                  if (state.currentState == CubitState.loading && items.isEmpty) {
                    return const ClientCardSkeleton();
                  }

                  if (state.currentState == CubitState.error && items.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          state.errorMessage ?? t.genericErrorMessage,
                          style: TextStyle(color: theme.brandError),
                        ),
                      ),
                    );
                  }

                  if (items.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          t.clientsEmptyStateText,
                          style: TextStyle(color: theme.primaryText.withValues(alpha: 0.5)),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children:
                        items
                            .map(
                              (client) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: ClientCard(client: client, onTap: () => _openEditClient(context, client.id)),
                              ),
                            )
                            .toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
