import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:business_assistant/config/routes/route_names.dart';
import 'package:business_assistant/config/routes/router_config.dart';
import 'package:business_assistant/core/features/authentication/cubits/auth/auth_cubit.dart';
import 'package:business_assistant/core/features/authentication/view/initial_screen.dart';
import 'package:business_assistant/core/features/authentication/view/landing_page/landing_page.dart';
import 'package:business_assistant/core/features/authentication/view/login_page/login_page.dart';
import 'package:business_assistant/core/utils/stream_to_listenable.dart';
import 'package:go_router/go_router.dart';

/// Defines all routes in the app and the auth redirect logic.
///
/// Singleton pattern: GoRouter is built once and reused (creating a new instance
/// on every rebuild would reset navigation history and cause flickering).
///
/// How auth redirect works:
///   1. RouterState().authCubit.stream emits a new state.
///   2. StreamToListenable calls notifyListeners() — GoRouter re-evaluates redirect.
///   3. redirect() reads the current AuthState and returns the correct path.
///      - Unauthenticated → landingPage (unless already on an unauth route)
///      - Authenticated + first login → homePage
///      - null → stay on current route (no redirect needed)
class Routes {
  static final GoRouter _goRouterInstance = GoRouter(
    navigatorKey: RouterState().rootNavigatorKey,
    // GoRouter re-runs redirect() every time the authCubit stream emits
    refreshListenable: StreamToListenable([RouterState().authCubit.stream]),
    redirect: (BuildContext context, GoRouterState state) {
      if (context.read<AuthCubit>().state is Unauthenticated) {
        // Allow these pages without authentication
        switch (state.fullPath) {
          case RouteNames.signupPage:
            return RouteNames.signupPage;
          case RouteNames.loginPage:
            return RouteNames.loginPage;
          case RouteNames.resetPassword:
            return RouteNames.resetPassword;
          default:
            return RouteNames.landingPage;
        }
      }

      if (context.read<AuthCubit>().state is Authenticated &&
          context.read<AuthCubit>().redirectToHomeInitialy) {
        context.read<AuthCubit>().redirectToHomeInitialy = false;
        // Uncomment when home screen exists:
        // return RouteNames.homePage;
      }

      return null; // no redirect — stay on current route
    },
    initialLocation: RouterState().initialRoute,
    routes: <RouteBase>[
      // Blank white splash shown during the token check (AuthInitial state)
      GoRoute(
        path: RouteNames.initialScreen,
        builder: (context, state) => const InitialScreen(),
      ),

      // Landing page — entry point for unauthenticated users
      GoRoute(
        path: RouteNames.landingPage,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: const LandingPage(),
            transitionDuration: const Duration(milliseconds: 250),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

      // Login page — navigated to from LandingPage "Sign In" button
      GoRoute(
        path: RouteNames.loginPage,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: const LoginPage(),
            transitionDuration: const Duration(milliseconds: 250),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

      // TODO: Add StatefulShellRoute with bottom navigation when home screen is ready
      // StatefulShellRoute.indexedStack(
      //   builder: (context, state, navigationShell) => BottomNavigationFrame(navigationShell),
      //   branches: [
      //     StatefulShellBranch(
      //       navigatorKey: RouterState().homeNavigatorKey,
      //       routes: [
      //         GoRoute(path: RouteNames.homePage, builder: (_, __) => const HomePage()),
      //       ],
      //     ),
      //   ],
      // ),
    ],
  );

  GoRouter get goRouterInstance => _goRouterInstance;
}
