part of 'user_info_cubit.dart';

class UserInfoState {
  final CubitState currentState;
  final String? firstName;
  final String? email;
  final String? tenantId;
  final UserRole? role;
  final String? imgUrl;

  const UserInfoState({
    this.currentState = CubitState.initial,
    this.firstName,
    this.email,
    this.tenantId,
    this.role,
    this.imgUrl,
  });

  UserInfoState copyWith({
    CubitState? currentState,
    String? firstName,
    String? email,
    String? tenantId,
    UserRole? role,
    String? imgUrl,
  }) {
    return UserInfoState(
      currentState: currentState ?? this.currentState,
      firstName: firstName ?? this.firstName,
      email: email ?? this.email,
      tenantId: tenantId ?? this.tenantId,
      role: role ?? this.role,
      imgUrl: imgUrl ?? this.imgUrl,
    );
  }
}
