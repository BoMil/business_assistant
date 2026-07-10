import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Extension on GoRouter that adds a popUntilPath helper.
///
/// Flutter's Navigator.popUntil() doesn't work well with go_router because
/// go_router manages its own route stack separately from Navigator's stack.
/// This extension navigates go_router's own route list to pop screens correctly.
extension GoRouterExt on GoRouter {
  /// Pops routes from the top of the stack until [routePath] is the top route.
  ///
  /// Example usage — go back to the landing page from deep inside the auth flow:
  ///   Routes().goRouterInstance.popUntilPath(RouteNames.landingPage);
  void popUntilPath(String routePath) {
    List routeStacks = [...routerDelegate.currentConfiguration.routes];

    try {
      for (int i = routeStacks.length - 1; i >= 0; i--) {
        RouteBase route = routeStacks[i];
        if (route is GoRoute) {
          if (route.path == routePath) break;
          if (i != 0 && routeStacks[i - 1] is ShellRoute) {
            RouteMatchList matchList = routerDelegate.currentConfiguration;
            restore(matchList.remove(matchList.matches.last));
          } else {
            pop();
          }
        }
      }
    } catch (e) {
      debugPrint('Error in popUntilPath: $e');
    }
  }
}
