import 'package:flutter/material.dart';
import '../cl_theme.dart';

@Deprecated('Use AppThemeState — will be removed in 5.0')
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = CLTheme.themeMode;
  bool _disposed = false;

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

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

