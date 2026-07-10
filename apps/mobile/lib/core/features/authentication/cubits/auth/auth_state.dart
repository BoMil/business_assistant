part of 'auth_cubit.dart';

/// The three possible auth states of the app.
///
/// GoRouter's redirect callback reads this state on every navigation event:
///   AuthInitial    → show initial_screen (splash) while we check the token
///   Authenticated  → allow access to protected routes (home, dashboard, etc.)
///   Unauthenticated → redirect to landing_page / login_page
@immutable
sealed class AuthState {}

/// Token check is in progress — app just launched, storage not yet read.
final class AuthInitial extends AuthState {}

/// Valid, non-expired token found in secure storage.
final class Authenticated extends AuthState {}

/// No token, expired token, or user explicitly logged out.
final class Unauthenticated extends AuthState {}
