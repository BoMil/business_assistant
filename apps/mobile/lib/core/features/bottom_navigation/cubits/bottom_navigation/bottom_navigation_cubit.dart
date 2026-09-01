import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:business_assistant/config/routes/bottom_nav_tabs.dart';
import 'package:business_assistant/core/utils/safe_emit_cubit_extension.dart';

part 'bottom_navigation_state.dart';

/// Global (app-scoped) cubit that tracks which bottom nav tab is selected.
///
/// Why this exists: StatefulShellRoute's [StatefulNavigationShell] only lives
/// inside BottomNavigationFrame, so nothing outside it can trigger a tab
/// switch directly. This cubit is provided at the app root (see main.dart) so
/// any widget can request a tab change via [changeScreenByPath] —
/// BottomNavigationFrame listens for the change and calls
/// navigationShell.goBranch() in response.
class BottomNavigationCubit extends Cubit<BottomNavigationState> {
  final List<BottomNavTab> tabs;

  BottomNavigationCubit({required this.tabs}) : super(const BottomNavigationState(currentIndex: 0));

  /// Switches to [index] directly — used by BottomNavigationBar's onTap.
  void changeScreen(int index) {
    safeEmit(state.copyWith(currentIndex: index));
  }

  /// Switches to the tab whose route path matches [path] — use this to jump
  /// to a tab from anywhere in the app (e.g. after creating a client, jump
  /// back to the Clients tab) without needing the StatefulNavigationShell.
  void changeScreenByPath(String path) {
    final index = tabs.indexWhere((tab) => tab.path == path);
    if (index == -1) return;
    safeEmit(state.copyWith(currentIndex: index));
  }

  /// Resets to the first tab — called on logout so the next login starts fresh.
  void resetCurrentIndex() {
    safeEmit(state.copyWith(currentIndex: 0));
  }

  /// True if the tab at [path] is currently selected.
  bool isTabSelected(String path) {
    final index = tabs.indexWhere((tab) => tab.path == path);
    return index != -1 && index == state.currentIndex;
  }
}
