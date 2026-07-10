/// Request body for POST /auth/login.
///
/// The Identity API expects:
///   { "email": "...", "password": "..." }
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}
