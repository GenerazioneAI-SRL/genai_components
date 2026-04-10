import 'package:flutter/material.dart';
import '../cl_theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = CLTheme.themeMode;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await CLTheme.saveThemeMode(_themeMode);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await CLTheme.saveThemeMode(mode);
    notifyListeners();
  }
}

