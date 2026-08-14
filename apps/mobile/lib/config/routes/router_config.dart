import 'package:flutter/material.dart';
import 'package:business_assistant/config/routes/bottom_nav_tabs.dart';
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
  GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'rootNavigatorKey');

  /// Shell navigator keys — one per bottom navigation tab's nested navigator.
  /// Not every tab is necessarily shown (see bottom_nav_tabs.dart) — unused
  /// keys are simply never attached to a StatefulShellBranch.
  GlobalKey<NavigatorState> eventsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'eventsNavigatorKey');
  GlobalKey<NavigatorState> inventoryNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'inventoryNavigatorKey');
  GlobalKey<NavigatorState> clientsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'clientsNavigatorKey');
  GlobalKey<NavigatorState> accountNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'accountNavigatorKey');

  /// The initial route GoRouter starts at — set dynamically based on auth state.
  String initialRoute = RouteNames.initialScreen;

  static final RouterState _instance = RouterState._internal();

  factory RouterState() => _instance;
  RouterState._internal();

  /// Hot reload re-uses the same GlobalKey instances, which causes Flutter to
  /// throw "Multiple widgets used the same GlobalKey". Re-creating keys on each
  /// initializeRouteState() call prevents this during development.
  void _resetKeys() {
    rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'rootNavigatorKey');
    eventsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'eventsNavigatorKey');
    inventoryNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'inventoryNavigatorKey');
    clientsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'clientsNavigatorKey');
    accountNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'accountNavigatorKey');
  }

  /// Maps the current auth state to the correct initial route:
  ///   AuthInitial   → initialScreen (splash — covers the loading gap)
  ///   Authenticated → first visible bottom nav tab
  ///   Unauthenticated → landingPage
  void _setInitialRoute() {
    if (authCubit.state is Authenticated) {
      initialRoute = defaultAuthenticatedRoute();
    } else if (authCubit.state is Unauthenticated) {
      initialRoute = RouteNames.loginPage;
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
