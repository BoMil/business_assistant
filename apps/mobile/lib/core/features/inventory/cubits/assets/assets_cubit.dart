import 'package:business_assistant/core/features/inventory/api_services/asset_api_service.dart';
import 'package:business_assistant/core/features/inventory/models/requests/assets_request.dart';
import 'package:business_assistant/core/features/inventory/models/responses/asset_response.dart';
import 'package:business_assistant/core/features/pagination/pagination_cubit_base.dart';
import 'package:business_assistant/core/shared/enums/cubit_state.dart';
import 'package:business_assistant/core/shared/models/base_multi_page_response.dart';
import 'package:business_assistant/core/utils/api/api_response.dart';
import 'package:business_assistant/core/utils/safe_emit_cubit_extension.dart';

part 'assets_state.dart';

/// Drives the Inventory list page: a paginated, server-searched list of
/// Assets. All paging/search mechanics (getNextPage/changeSearch/resetState)
/// live in PaginationCubitBase — this cubit only implements its 4 hooks.
class AssetsCubit extends PaginationCubitBase<AssetResponse, AssetsState> {
  final AssetApiService assetApiService;

  AssetsCubit({AssetApiService? assetApiService})
      : assetApiService = assetApiService ?? AssetApiService(),
        super(AssetsState(assetsResponse: BaseMultiPageResponse.empty()));

  static const int _pageSize = 20;

  Future<BaseMultiPageResponse<AssetResponse>> _fetch({required bool clearOnLoad}) async {
    safeEmit(state.copyWith(
      currentState: CubitState.loading,
      assetsResponse: clearOnLoad ? BaseMultiPageResponse<AssetResponse>.empty() : state.assetsResponse,
    ));

    final response = await assetApiService.getAssetsPaged(
      AssetsRequest(page: page, pageSize: _pageSize, searchQuery: searchTerm.isEmpty ? null : searchTerm),
    );

    if (response.status == ResponseStatus.error) {
      if (page > 1) page--;
      safeEmit(state.copyWith(currentState: CubitState.error, errorMessage: response.message));
    }

    return response.data ?? BaseMultiPageResponse.empty();
  }

  @override
  Future<BaseMultiPageResponse<AssetResponse>> getData() => _fetch(clearOnLoad: page == 1);

  @override
  Future<BaseMultiPageResponse<AssetResponse>> getDataOnSearchChange() => _fetch(clearOnLoad: true);

  @override
  void emitStateChangeForPagination() {
    safeEmit(state.copyWith(currentState: CubitState.loaded, assetsResponse: data));
  }

  @override
  void emitStateChangeForSearch() {
    safeEmit(state.copyWith(currentState: CubitState.loaded, assetsResponse: data));
  }
}
