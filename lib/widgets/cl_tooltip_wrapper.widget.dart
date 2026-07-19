import 'package:flutter/material.dart' show TooltipTriggerMode, Theme, Brightness, Colors;
import 'package:flutter/widgets.dart';
// Budella Shad: nucleo interno = ShadTooltip (hover desktop + longPress touch).
// Solo i simboli usati (show). Firma pubblica CLTooltipWrapper invariata.
import 'package:shadcn_ui/shadcn_ui.dart'
    show ShadTooltip, ShadDecoration, ShadBorder;
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

/// Wrapper tooltip con delay di 500ms e stile coerente con il tema.
///
/// `triggerMode` è conservato per retro-compatibilità di firma; ShadTooltip usa
/// hover su desktop e longPress su touch (equivalente al default `longPress`).
class CLTooltipWrapper extends StatelessWidget {
  final String message;
  final Widget child;
  final TooltipTriggerMode triggerMode;

  const CLTooltipWrapper({
    super.key,
    required this.message,
    required this.child,
    this.triggerMode = TooltipTriggerMode.longPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ShadTooltip(
      waitDuration: const Duration(milliseconds: 500),
      // Colore/bordo/raggio da CLTheme: identità CL preservata.
      decoration: ShadDecoration(
        color: isDark ? theme.secondaryBackground : theme.accentForeground,
        border: ShadBorder.all(
          color: theme.cardBorder,
          radius: BorderRadius.circular(Sizes.radiusSurface),
        ),
      ),
      builder: (context) => Text(
        message,
        style: theme.smallText.copyWith(
          color: isDark ? theme.primaryText : Colors.white,
        ),
      ),
      child: child,
    );
  }
}
