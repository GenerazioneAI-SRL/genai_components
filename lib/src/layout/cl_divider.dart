import 'package:flutter/material.dart';
import '../theme/cl_theme_provider.dart';

/// Simple horizontal divider using theme border color.
class CLDivider extends StatelessWidget {
  final double height;

  const CLDivider({super.key, this.height = 1});

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);
    return Divider(height: height, thickness: height, color: theme.border);
  }
}
