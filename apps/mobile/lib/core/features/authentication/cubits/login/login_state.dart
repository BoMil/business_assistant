part of 'login_cubit.dart';

class LoginState {
  final CubitState currentState;
  final String? errorMessage;
  final LoginResponse? loginResponse;

  const LoginState({
    this.currentState = CubitState.initial,
    this.errorMessage,
    this.loginResponse,
  });

  LoginState copyWith({
    CubitState? currentState,
    String? errorMessage,
    LoginResponse? loginResponse,
  }) {
    return LoginState(
      currentState: currentState ?? this.currentState,
      errorMessage: errorMessage ?? this.errorMessage,
      loginResponse: loginResponse ?? this.loginResponse,
    );
  }
}
