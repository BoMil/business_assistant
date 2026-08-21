import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:business_assistant/config/constants/api_endpoints.dart';
import 'package:business_assistant/core/features/authentication/api_services/user_api_service.dart';
import 'package:business_assistant/core/features/authentication/models/enums/user_role.dart';
import 'package:business_assistant/core/features/inventory/api_services/image_api_service.dart';
import 'package:business_assistant/core/shared/enums/cubit_state.dart';
import 'package:business_assistant/core/utils/api/api_response.dart';

part 'user_info_state.dart';

/// Holds everything about the logged-in user — profile fields and the
/// derived Owner/Admin-only access getters — fetched from
/// GET /identity/users/me. Separate from AuthCubit, which only tracks
/// whether the user is logged in.
///
/// Loaded only on login / app-start-with-valid-token (see main.dart's
/// BlocListener<AuthCubit, AuthState>) — not re-fetched on a silent token
/// refresh, since role/name don't change while a session is active.
class UserInfoCubit extends Cubit<UserInfoState> {
  final UserApiService userApiService;
  final ImageApiService imageApiService;

  UserInfoCubit({UserApiService? userApiService, ImageApiService? imageApiService})
      : userApiService = userApiService ?? UserApiService(),
        imageApiService = imageApiService ?? ImageApiService(),
        super(const UserInfoState());

  /// Owner and Admin can add/edit/delete Inventory products — Member is view-only.
  bool get canManageInventory => state.role == UserRole.owner || state.role == UserRole.admin;

  /// Owner and Admin can add/edit/remove Clients — Member is view-only.
  bool get canManageClients => state.role == UserRole.owner || state.role == UserRole.admin;

  /// Fetches the logged-in user's profile from the Identity API.
  Future<void> loadUserInfo() async {
    final response = await userApiService.getCurrentUser();
    if (response.status != ResponseStatus.completed) {
      debugPrint('[UserInfoCubit] loadUserInfo error: ${response.message}');
      return;
    }

    final user = response.data!;
    emit(
      state.copyWith(
        currentState: CubitState.loaded,
        firstName: user.firstName,
        email: user.email,
        tenantId: user.tenantId,
        role: user.role,
        imgUrl: user.imgUrl,
      ),
    );
  }

  /// Uploads a new profile picture and persists its URL on the user. Not yet
  /// wired to any UI — ready for whenever the Account page adds this.
  Future<void> updateProfileImage(File file) async {
    final uploadResponse = await imageApiService.uploadImage(file, endpoint: APIEndpoints.identityImages);
    if (uploadResponse.status != ResponseStatus.completed) return;

    final imgUrl = uploadResponse.data!;
    final updateResponse = await userApiService.updateUserImage(imgUrl);
    if (updateResponse.status == ResponseStatus.completed) {
      emit(state.copyWith(imgUrl: imgUrl));
    }
  }

  /// Resets to empty — called on logout.
  void clear() => emit(const UserInfoState());
}
