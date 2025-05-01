import 'package:flutter_riverpod/flutter_riverpod.dart';

final bottomNavBarProvider = StateNotifierProvider<BottomNavBarNotifier, int>(
  (ref) => BottomNavBarNotifier(),
);

class BottomNavBarNotifier extends StateNotifier<int> {
  BottomNavBarNotifier() : super(0);

  void updateIndex(int index) {
    state = index;
  }
}
