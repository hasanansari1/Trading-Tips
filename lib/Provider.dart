import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  ThemeData getTheme() {
    return _isDarkMode ? darkTheme : lightTheme;
  }

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    // Add your light theme configurations here
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    // Add your dark theme configurations here
  );
}
