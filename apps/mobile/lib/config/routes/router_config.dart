import 'package:flutter/material.dart';
import 'package:business_assistant/config/routes/route_names.dart';
import 'package:business_assistant/core/features/authentication/cubits/auth/auth_cubit.dart';

/// Singleton that holds global navigation state shared between main.dart and routes.dart.
///
/// Why a singleton?
///   GoRouter needs a GlobalKey<NavigatorState> to control navigation.
///   AuthCubit must be accessible inside the router's redirect callback.
///   Both are created in main.dart and consumed in routes.dart — this singleton
///   bridges that gap without passing objects down the widget tree.
class RouterState {
  /// The AuthCubit instance — set in main.dart before the router is built.
  late AuthCubit authCubit;

  /// Root navigator key — used by GoRouter for top-level navigation.
  GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'rootNavigatorKey');

  /// Shell navigator key — used for the bottom navigation tab's nested navigator.
  /// Reserved for when we add the home shell route.
  GlobalKey<NavigatorState> homeNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'homeNavigatorKey');

  /// The initial route GoRouter starts at — set dynamically based on auth state.
  String initialRoute = RouteNames.homePage;

  static final RouterState _instance = RouterState._internal();

  factory RouterState() => _instance;
  RouterState._internal();

  /// Hot reload re-uses the same GlobalKey instances, which causes Flutter to
  /// throw "Multiple widgets used the same GlobalKey". Re-creating keys on each
  /// initializeRouteState() call prevents this during development.
  void _resetKeys() {
    rootNavigatorKey =
        GlobalKey<NavigatorState>(debugLabel: 'rootNavigatorKey');
    homeNavigatorKey =
        GlobalKey<NavigatorState>(debugLabel: 'homeNavigatorKey');
  }

  /// Maps the current auth state to the correct initial route:
  ///   AuthInitial   → initialScreen (splash — covers the loading gap)
  ///   Authenticated → homePage
  ///   Unauthenticated → landingPage
  void _setInitialRoute() {
    if (authCubit.state is Authenticated) {
      initialRoute = RouteNames.homePage;
    } else if (authCubit.state is Unauthenticated) {
      initialRoute = RouteNames.landingPage;
    } else {
      initialRoute = RouteNames.initialScreen;
    }
  }

  /// Called from MyApp.build() on every rebuild — resets keys and recalculates
  /// the initial route to keep the router in sync with auth state.
  void initializeRouteState() {
    _resetKeys();
    _setInitialRoute();
  }
}
