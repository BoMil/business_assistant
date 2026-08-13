import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:business_assistant/core/features/inventory/api_services/asset_api_service.dart';
import 'package:business_assistant/core/features/inventory/models/responses/asset_response.dart';
import 'package:business_assistant/core/shared/enums/cubit_state.dart';
import 'package:business_assistant/core/utils/api/api_response.dart';
import 'package:business_assistant/core/utils/safe_emit_cubit_extension.dart';

part 'assets_state.dart';

/// Drives the Inventory list page. Unlike EventsCubit, GET /assets returns
/// the full list in one call (no server pagination) — search filters the
/// already-loaded list client-side instead of re-fetching.
class AssetsCubit extends Cubit<AssetsState> {
  final AssetApiService assetApiService;

  AssetsCubit({AssetApiService? assetApiService})
      : assetApiService = assetApiService ?? AssetApiService(),
        super(const AssetsState());

  Future<void> loadAssets() async {
    safeEmit(state.copyWith(currentState: CubitState.loading));

    final response = await assetApiService.getAssets();

    if (response.status == ResponseStatus.error) {
      safeEmit(state.copyWith(currentState: CubitState.error, errorMessage: response.message));
      return;
    }

    safeEmit(state.copyWith(currentState: CubitState.loaded, assets: response.data ?? []));
  }

  void changeSearch(String term) => safeEmit(state.copyWith(searchTerm: term));
}
