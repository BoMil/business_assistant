import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:business_assistant/config/routes/bottom_nav_tabs.dart';

/// Shell widget for StatefulShellRoute.indexedStack — wraps the currently
/// active tab and renders the bottom nav bar from the same tab list used to
/// build the routes, so the bar and the branches never fall out of sync.
class BottomNavigationFrame extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavigationFrame({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final tabs = visibleBottomNavTabs();

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          // Tapping the already-active tab pops it back to its root route.
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: tabs
            .map((tab) => BottomNavigationBarItem(
                  icon: Icon(tab.icon),
                  label: tab.label,
                ))
            .toList(),
      ),
    );
  }
}
