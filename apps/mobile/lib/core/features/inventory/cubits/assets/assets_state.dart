part of 'assets_cubit.dart';

class AssetsState {
  final CubitState currentState;
  final List<AssetResponse> assets;
  final String searchTerm;
  final String? errorMessage;

  const AssetsState({
    this.currentState = CubitState.initial,
    this.assets = const [],
    this.searchTerm = '',
    this.errorMessage,
  });

  /// GET /assets isn't paginated/searched server-side — filter the already
  /// loaded list client-side instead.
  List<AssetResponse> get filteredAssets {
    final query = searchTerm.trim().toLowerCase();
    if (query.isEmpty) return assets;
    return assets
        .where((asset) => asset.name.toLowerCase().contains(query) || asset.category.toLowerCase().contains(query))
        .toList();
  }

  AssetsState copyWith({
    CubitState? currentState,
    List<AssetResponse>? assets,
    String? searchTerm,
    String? errorMessage,
  }) {
    return AssetsState(
      currentState: currentState ?? this.currentState,
      assets: assets ?? this.assets,
      searchTerm: searchTerm ?? this.searchTerm,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
