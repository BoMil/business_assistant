import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:business_assistant/config/routes/bottom_nav_tabs.dart';
import 'package:business_assistant/core/features/bottom_navigation/cubits/bottom_navigation/bottom_navigation_cubit.dart';
import 'package:business_assistant/core/features/bottom_navigation/view/bottom_nav_icon.dart';
import 'package:business_assistant/theme/get_theme_color.dart';

/// Shell widget for StatefulShellRoute.indexedStack — wraps the currently
/// active tab and renders the bottom nav bar from the same tab list used to
/// build the routes, so the bar and the branches never fall out of sync.
///
/// Tab switches always go through BottomNavigationCubit (provided at the app
/// root) rather than calling navigationShell.goBranch() directly, so any
/// widget in the app can request a tab change — see BottomNavigationCubit for
/// why navigationShell alone isn't reachable from outside this widget.
class BottomNavigationFrame extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavigationFrame({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final tabs = visibleBottomNavTabs();
    final theme = context.colors;
    final unselectedColor = theme.primaryText.withValues(alpha: 0.5);

    return BlocListener<BottomNavigationCubit, BottomNavigationState>(
      listener: (context, state) {
        navigationShell.goBranch(
          state.currentIndex,
          // Tapping the already-active tab pops it back to its root route.
          initialLocation: state.currentIndex == navigationShell.currentIndex,
        );
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: BottomNavigationBar(
          // Explicit — Flutter defaults to `shifting` once there are 4+ items,
          // whose default unselected color is white (invisible on a white bar).
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.baseWhite,
          selectedItemColor: theme.brandPrimary,
          unselectedItemColor: unselectedColor,
          selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => context.read<BottomNavigationCubit>().changeScreen(index),
          items: tabs
              .map((tab) => BottomNavigationBarItem(
                    icon: BottomNavIcon(svgIconPath: tab.svgIconPath, color: unselectedColor),
                    activeIcon: BottomNavIcon(svgIconPath: tab.svgIconPath, color: theme.brandPrimary),
                    label: tab.label,
                  ))
              .toList(),
        ),
      ),
    );
  }
}
