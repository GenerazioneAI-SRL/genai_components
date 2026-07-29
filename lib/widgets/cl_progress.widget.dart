import 'package:flutter/material.dart';
// Budella Shad: nucleo interno = ShadProgress. Solo il simbolo usato (show).
// Firma pubblica CLProgress invariata.
import 'package:shadcn_ui/shadcn_ui.dart' show ShadProgress;
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

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
    // Colore per variante e bg `muted` da CLTheme: identità CL preservata.
    // Track e fill entrambi a raggio pill (come il ClipRRect originale).
    final pill = BorderRadius.circular(Sizes.radiusPill);
    return ShadProgress(
      value: value.clamp(0.0, 1.0),
      color: _color(theme),
      backgroundColor: theme.muted,
      minHeight: height,
      borderRadius: pill,
      innerBorderRadius: pill,
    );
  }
}
