import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  ThemeData getThemeData() {
    if (_isDarkMode) {
      return ThemeData.dark();
    } else {
      return ThemeData.light();
    }
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
