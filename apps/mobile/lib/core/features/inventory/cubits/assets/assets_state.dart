part of 'assets_cubit.dart';

class AssetsState {
  final CubitState currentState;
  final BaseMultiPageResponse<AssetResponse> assetsResponse;
  final String? errorMessage;

  const AssetsState({
    this.currentState = CubitState.initial,
    required this.assetsResponse,
    this.errorMessage,
  });

  AssetsState copyWith({
    CubitState? currentState,
    BaseMultiPageResponse<AssetResponse>? assetsResponse,
    String? errorMessage,
  }) {
    return AssetsState(
      currentState: currentState ?? this.currentState,
      assetsResponse: assetsResponse ?? this.assetsResponse,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
