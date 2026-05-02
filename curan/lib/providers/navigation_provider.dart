import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void goToHome() => setIndex(0);
  void goToPlayer() => setIndex(1);
  void goToFavorites() => setIndex(2);
  void goToPrayerTimes() => setIndex(3);
  void goToSettings() => setIndex(4);
}
