import 'package:flutter/material.dart';
import 'cl_theme_data.dart';

/// InheritedWidget that provides CLThemeData to all CL widgets.
///
/// Wrap your app with this to customize the theme:
/// ```dart
/// CLThemeProvider(
///   theme: CLThemeData(primary: Colors.red),
///   child: MaterialApp(...),
/// )
/// ```
class CLThemeProvider extends InheritedWidget {
  final CLThemeData theme;

  const CLThemeProvider({
    super.key,
    required this.theme,
    required super.child,
  });

  /// Access the theme from any widget in the tree.
  /// Returns default CLThemeData if no provider is found.
  static CLThemeData of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<CLThemeProvider>();
    return provider?.theme ?? const CLThemeData();
  }

  @override
  bool updateShouldNotify(CLThemeProvider oldWidget) => theme != oldWidget.theme;
}
