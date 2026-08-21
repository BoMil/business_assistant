part of 'user_info_cubit.dart';

class UserInfoState {
  final CubitState currentState;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? tenantId;
  final UserRole? role;
  final String? imgUrl;
  final bool isUploadingImage;
  final String? errorMessage;

  const UserInfoState({
    this.currentState = CubitState.initial,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.tenantId,
    this.role,
    this.imgUrl,
    this.isUploadingImage = false,
    this.errorMessage,
  });

  UserInfoState copyWith({
    CubitState? currentState,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? tenantId,
    UserRole? role,
    String? imgUrl,
    bool? isUploadingImage,
    String? errorMessage,
    bool clearError = false,
  }) {
    return UserInfoState(
      currentState: currentState ?? this.currentState,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      tenantId: tenantId ?? this.tenantId,
      role: role ?? this.role,
      imgUrl: imgUrl ?? this.imgUrl,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
