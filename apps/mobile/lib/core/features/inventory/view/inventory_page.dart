import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:business_assistant/config/routes/route_names.dart';
import 'package:business_assistant/config/translations/translation_storage.dart';
import 'package:business_assistant/core/features/authentication/cubits/auth/auth_cubit.dart';
import 'package:business_assistant/core/features/bottom_navigation/cubits/bottom_navigation/bottom_navigation_cubit.dart';
import 'package:business_assistant/core/features/inventory/cubits/assets/assets_cubit.dart';
import 'package:business_assistant/core/features/inventory/view/asset_card.dart';
import 'package:business_assistant/core/features/inventory/view/widgets/asset_card_skeleton.dart';
import 'package:business_assistant/core/features/main_header/view/main_header.dart';
import 'package:business_assistant/core/shared/enums/cubit_state.dart';
import 'package:business_assistant/core/shared/pages/page_frame/page_frame.dart';
import 'package:business_assistant/core/shared/widgets/input_fields/text_search.dart';
import 'package:business_assistant/theme/get_theme_color.dart';

/// Inventory tab — a list of the tenant's products (Assets). GET /assets
/// isn't paginated server-side, so search filters the already-loaded list
/// client-side (see AssetsCubit) instead of re-fetching per keystroke.
class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AssetsCubit>(create: (_) => AssetsCubit()..loadAssets(), child: const _InventoryPageContent());
  }
}

class _InventoryPageContent extends StatelessWidget {
  const _InventoryPageContent();

  Future<void> _openCreateAsset(BuildContext context) async {
    final cubit = context.read<AssetsCubit>();
    await context.push(RouteNames.createAssetPage);
    cubit.loadAssets();
  }

  Future<void> _openEditAsset(BuildContext context, String assetId) async {
    final cubit = context.read<AssetsCubit>();
    await context.push(RouteNames.editAssetPagePath(assetId));
    cubit.loadAssets();
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationStorage.translation;
    final theme = context.colors;
    final canManageInventory = context.watch<AuthCubit>().canManageInventory;

    return BlocListener<BottomNavigationCubit, BottomNavigationState>(
      listener: (context, state) {
        bool isAuthanticated = context.read<AuthCubit>().state is Authenticated;
        if (isAuthanticated && context.read<BottomNavigationCubit>().isTabSelected(RouteNames.inventoryPage)) {
          context.read<AssetsCubit>().loadAssets();
        }
      },
      child: PageFrame(
        isHeaderVisible: false,
        pageHeader: const MainHeader(),
        floatingActionButton:
            canManageInventory
                ? FloatingActionButton(
                  heroTag: 'inventoryFab',
                  onPressed: () => _openCreateAsset(context),
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
                  hintText: t.productsSearchHint,
                  onTypingComplete: (query) => context.read<AssetsCubit>().changeSearch(query),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: BlocBuilder<AssetsCubit, AssetsState>(
                builder: (context, state) {
                  final items = state.filteredAssets;

                  if (state.currentState == CubitState.loading && items.isEmpty) {
                    return const AssetCardSkeleton();
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
                          t.productsEmptyStateText,
                          style: TextStyle(color: theme.primaryText.withValues(alpha: 0.5)),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children:
                        items
                            .map(
                              (asset) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: AssetCard(asset: asset, onTap: () => _openEditAsset(context, asset.id)),
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
