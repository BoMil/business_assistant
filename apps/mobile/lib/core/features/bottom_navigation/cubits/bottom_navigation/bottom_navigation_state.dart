part of 'bottom_navigation_cubit.dart';

class BottomNavigationState {
  final int currentIndex;

  const BottomNavigationState({this.currentIndex = 0});

  BottomNavigationState copyWith({int? currentIndex}) {
    return BottomNavigationState(currentIndex: currentIndex ?? this.currentIndex);
  }
}
