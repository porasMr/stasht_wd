import 'package:flutter/material.dart';

class BottomBarVisibilityProvider with ChangeNotifier {
  bool _isBottomBarVisible = true;

  bool get isBottomBarVisible => _isBottomBarVisible;

  void showBottomBar() {
    _isBottomBarVisible = true;
    notifyListeners();
  }

  void hideBottomBar() {
    _isBottomBarVisible = false;
    notifyListeners();
  }
}
