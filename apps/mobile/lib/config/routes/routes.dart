import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:business_assistant/config/routes/bottom_nav_tabs.dart';
import 'package:business_assistant/config/routes/route_names.dart';
import 'package:business_assistant/config/routes/router_config.dart';
import 'package:business_assistant/core/features/authentication/cubits/auth/auth_cubit.dart';
import 'package:business_assistant/core/features/authentication/view/initial_screen.dart';
import 'package:business_assistant/core/features/authentication/view/landing_page/landing_page.dart';
import 'package:business_assistant/core/features/authentication/view/login_page/login_page.dart';
import 'package:business_assistant/core/features/clients/models/page_props/client_events_page_props.dart';
import 'package:business_assistant/core/features/clients/models/page_props/create_edit_client_page_props.dart';
import 'package:business_assistant/core/features/clients/view/client_events_page.dart';
import 'package:business_assistant/core/features/clients/view/create_edit_client_page.dart';
import 'package:business_assistant/core/features/events/models/page_props/create_edit_event_page_props.dart';
import 'package:business_assistant/core/features/events/view/create_edit_event_page.dart';
import 'package:business_assistant/core/features/inventory/models/page_props/create_edit_asset_page_props.dart';
import 'package:business_assistant/core/features/inventory/view/create_edit_asset_page.dart';
import 'package:business_assistant/core/shared/widgets/navigation/bottom_navigation_frame.dart';
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
///      - Authenticated + first login → first visible bottom nav tab
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
          case RouteNames.resetPassword:
            return RouteNames.resetPassword;
          case RouteNames.landingPage:
            return RouteNames.landingPage;
          default:
            return RouteNames.loginPage;
        }
      }

      if (context.read<AuthCubit>().state is Authenticated && context.read<AuthCubit>().redirectToHomeInitialy) {
        context.read<AuthCubit>().redirectToHomeInitialy = false;
        return defaultAuthenticatedRoute();
      }

      return null; // no redirect — stay on current route
    },
    initialLocation: RouterState().initialRoute,
    routes: <RouteBase>[
      // Blank white splash shown during the token check (AuthInitial state)
      GoRoute(path: RouteNames.initialScreen, builder: (context, state) => const InitialScreen()),

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
                position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(animation),
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
                position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

      // Event create/edit — pushed full-screen on top of the Events tab
      // (rootNavigatorKey via top-level placement), so it covers the bottom nav.
      GoRoute(
        path: RouteNames.createEventPage,
        pageBuilder: (BuildContext context, GoRouterState state) {
          CreateEditEventPageProps? pageProps;
          try {
            pageProps = state.extra as CreateEditEventPageProps?;
          } catch (e) {
            debugPrint('No data in the route extra params');
          }
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: CreateEditEventPage(pageProps: pageProps),
            transitionDuration: const Duration(milliseconds: 250),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: RouteNames.editEventPage,
        pageBuilder: (BuildContext context, GoRouterState state) {
          CreateEditEventPageProps? pageProps;
          try {
            pageProps = state.extra as CreateEditEventPageProps?;
          } catch (e) {
            debugPrint('No data in the route extra params');
          }
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: CreateEditEventPage(pageProps: pageProps),
            transitionDuration: const Duration(milliseconds: 250),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

      // Product create/edit — pushed full-screen on top of the Inventory tab
      // (rootNavigatorKey via top-level placement), so it covers the bottom nav.
      GoRoute(
        path: RouteNames.createAssetPage,
        pageBuilder: (BuildContext context, GoRouterState state) {
          CreateEditAssetPageProps? pageProps;
          try {
            pageProps = state.extra as CreateEditAssetPageProps?;
          } catch (e) {
            debugPrint('No data in the route extra params');
          }
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: CreateEditAssetPage(pageProps: pageProps),
            transitionDuration: const Duration(milliseconds: 250),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: RouteNames.editAssetPage,
        pageBuilder: (BuildContext context, GoRouterState state) {
          CreateEditAssetPageProps? pageProps;
          try {
            pageProps = state.extra as CreateEditAssetPageProps?;
          } catch (e) {
            debugPrint('No data in the route extra params');
          }
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: CreateEditAssetPage(pageProps: pageProps),
            transitionDuration: const Duration(milliseconds: 250),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

      // Client create/edit — pushed full-screen on top of the Clients tab
      // (rootNavigatorKey via top-level placement), so it covers the bottom nav.
      GoRoute(
        path: RouteNames.createClientPage,
        pageBuilder: (BuildContext context, GoRouterState state) {
          CreateEditClientPageProps? pageProps;
          try {
            pageProps = state.extra as CreateEditClientPageProps?;
          } catch (e) {
            debugPrint('No data in the route extra params');
          }
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: CreateEditClientPage(pageProps: pageProps),
            transitionDuration: const Duration(milliseconds: 250),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: RouteNames.editClientPage,
        pageBuilder: (BuildContext context, GoRouterState state) {
          CreateEditClientPageProps? pageProps;
          try {
            pageProps = state.extra as CreateEditClientPageProps?;
          } catch (e) {
            debugPrint('No data in the route extra params');
          }
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: CreateEditClientPage(pageProps: pageProps),
            transitionDuration: const Duration(milliseconds: 250),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: RouteNames.clientEventsPage,
        pageBuilder: (BuildContext context, GoRouterState state) {
          ClientEventsPageProps? pageProps;
          try {
            pageProps = state.extra as ClientEventsPageProps?;
          } catch (e) {
            debugPrint('No data in the route extra params');
          }
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: ClientEventsPage(pageProps: pageProps),
            transitionDuration: const Duration(milliseconds: 250),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

      // Bottom navigation shell — tabs shown depend on FeatureFlags, built once
      // from visibleBottomNavTabs() so the branches and the nav bar itself
      // (BottomNavigationFrame) never fall out of sync.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => BottomNavigationFrame(navigationShell: navigationShell),
        branches: visibleBottomNavTabs()
            .map(
              (tab) => StatefulShellBranch(
                navigatorKey: tab.navigatorKey,
                routes: [GoRoute(path: tab.path, builder: (context, state) => tab.pageBuilder(context))],
              ),
            )
            .toList(),
      ),

      //     GoRoute(
      //   path: RouteNames.bulkPaymentInitializationPage,
      //   pageBuilder: (BuildContext context, GoRouterState state) {
      //     BulkPaymentInitPageProps pageProperties = BulkPaymentInitPageProps.empty();
      //     try {
      //       pageProperties = state.extra as BulkPaymentInitPageProps;
      //     } catch (e) {
      //       debugPrint('No data in the route extra params');
      //     }
      //     return CustomTransitionPage<void>(
      //       key: state.pageKey,
      //       name: state.fullPath,
      //       child: BulkPaymentInitializationPage(pageProps: pageProperties),
      //       transitionDuration: const Duration(milliseconds: 250),
      //       transitionsBuilder: (
      //         BuildContext context,
      //         Animation<double> animation,
      //         Animation<double> secondaryAnimation,
      //         Widget child,
      //       ) {
      //         return SlideTransition(
      //           position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(animation),
      //           child: child,
      //         );
      //       },
      //     );
      //   },
      // ),
    ],
  );

  GoRouter get goRouterInstance => _goRouterInstance;
}
