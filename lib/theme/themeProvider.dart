import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _currentTheme = ThemeData.light();

  ThemeData get currentTheme => _currentTheme;

  void switchTheme(ThemeData newTheme) {
    _currentTheme = newTheme;
    notifyListeners();
  }
}
