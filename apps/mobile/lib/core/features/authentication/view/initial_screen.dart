import 'package:flutter/material.dart';
import 'package:business_assistant/theme/theme_color.dart';

/// Shown while AuthCubit is in the AuthInitial state (app startup, token check).
///
/// GoRouter renders this route first (initialLocation = RouteNames.initialScreen)
/// and redirects away as soon as AuthCubit emits Authenticated or Unauthenticated.
/// Using a blank white screen here hides the layout flash that would otherwise
/// occur while the token is being read from secure storage.
class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: AppColors.baseWhite);
  }
}
