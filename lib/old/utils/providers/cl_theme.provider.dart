import 'package:flutter/material.dart';
import '../../cl_theme.dart';

/// Provider generico per iniettare un tema [CLTheme] custom nell'app.
///
/// Usalo come ChangeNotifierProvider alla radice del widget tree:
///
/// ```dart
/// ChangeNotifierProvider(
///   create: (_) => CLThemeProvider(
///     lightTheme: const LightModeTheme(primary: Color(0xFFFF5722)),
///     darkTheme: const DarkModeTheme(primary: Color(0xFFFF7043)),
///   ),
///   child: MaterialApp(...),
/// )
/// ```
///
/// Se non viene fornito alcun tema, usa i default [LightModeTheme] / [DarkModeTheme].
class CLThemeProvider extends ChangeNotifier {
  CLTheme _lightTheme;
  CLTheme _darkTheme;

  CLThemeProvider({
    CLTheme? lightTheme,
    CLTheme? darkTheme,
  })  : _lightTheme = lightTheme ?? const LightModeTheme(),
        _darkTheme = darkTheme ?? const DarkModeTheme();

  /// Tema light corrente.
  CLTheme get lightTheme => _lightTheme;

  /// Tema dark corrente.
  CLTheme get darkTheme => _darkTheme;

  /// Aggiorna i temi a runtime e notifica i listener.
  void updateThemes({CLTheme? light, CLTheme? dark}) {
    bool changed = false;
    if (light != null && light != _lightTheme) {
      _lightTheme = light;
      changed = true;
    }
    if (dark != null && dark != _darkTheme) {
      _darkTheme = dark;
      changed = true;
    }
    if (changed) notifyListeners();
  }
}

