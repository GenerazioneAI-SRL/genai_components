import 'package:flutter/material.dart';
import '../cl_theme.dart';

/// Single source of truth for the active [ThemeMode].
///
/// Replaces the duplicated `_themeMode` field that previously lived in both
/// `AppState` and `ThemeProvider`. New code should depend on this state
/// directly; the legacy providers are kept for backward compatibility and
/// will be removed in 5.0.
class AppThemeState extends ChangeNotifier {
  ThemeMode _themeMode = CLTheme.themeMode;
  bool _disposed = false;

  /// Currently active theme mode.
  ThemeMode get themeMode => _themeMode;

  /// Whether the active theme is dark.
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Update the theme mode and persist it. Guards on equal value.
  set themeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    CLTheme.saveThemeMode(mode);
    notifyListeners();
  }

  /// Toggle between light and dark mode and persist the new value.
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    CLTheme.saveThemeMode(_themeMode);
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
