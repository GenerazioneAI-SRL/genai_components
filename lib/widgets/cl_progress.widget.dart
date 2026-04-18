import 'package:flutter/material.dart';
import '../cl_theme.dart';

enum CLProgressVariant { primary, success, warning, danger }

/// Barra di progresso lineare stile shadcn.
class CLProgress extends StatelessWidget {
  final double value; // 0.0 – 1.0
  final CLProgressVariant variant;
  final double height;

  const CLProgress({
    super.key,
    required this.value,
    this.variant = CLProgressVariant.primary,
    this.height = 8.0,
  });

  Color _color(CLTheme theme) => switch (variant) {
    CLProgressVariant.primary => theme.primary,
    CLProgressVariant.success => theme.success,
    CLProgressVariant.warning => theme.warning,
    CLProgressVariant.danger => theme.danger,
  };

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(9999),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: theme.muted,
        valueColor: AlwaysStoppedAnimation(_color(theme)),
      ),
    );
  }
}
