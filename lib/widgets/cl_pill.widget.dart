import 'package:flutter/material.dart';
// Budella Shad: nucleo interno = ShadBadge.raw. Solo i simboli usati (show).
// Firma pubblica CLPill invariata.
import 'package:shadcn_ui/shadcn_ui.dart' show ShadBadge, ShadBadgeVariant;

import '../cl_theme.dart';

/// CLPill — chip/pill atomico per stati, conteggi, tag.
///
/// Linguaggio Skillera Refined Editorial:
/// - filled (default): bg soft tint (color × 0.08), NESSUN bordo
/// - outline: bg trasparente + bordo 1px color
/// - pill radius (stadium)
/// - tipografia Inter SemiBold (`smallLabel` con peso w600)
/// - icona opzionale ridotta a 14 per restare proporzionata al testo.
class CLPill extends StatelessWidget {
  const CLPill({
    super.key,
    required this.pillColor,
    required this.pillText,
    this.icon,
    this.outline = false,
  });

  final Color pillColor;
  final String pillText;
  final IconData? icon;
  final bool outline;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);

    final TextStyle textStyle = theme.smallLabel.override(
      color: pillColor,
      fontWeight: FontWeight.w600,
    );

    // Filled: solo soft tint (0.08), niente bordo. Outline: trasparente + bordo
    // color. Chrome CL preservato 1:1, sizing/pill delegati a ShadBadge.
    final Color softBg = pillColor.withValues(alpha: 0.08);
    final Color bg = outline ? Colors.transparent : softBg;

    return IntrinsicWidth(
      child: ShadBadge.raw(
        variant: ShadBadgeVariant.primary,
        backgroundColor: bg,
        hoverBackgroundColor: bg,
        foregroundColor: pillColor,
        padding: EdgeInsets.symmetric(
          horizontal: theme.gapSm,
          vertical: theme.gapXs / 2 + 1,
        ),
        shape: StadiumBorder(
          side: outline
              ? BorderSide(color: pillColor, width: 1)
              : BorderSide.none,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: pillColor),
              SizedBox(width: theme.gapXs),
            ],
            Flexible(
              child: Text(
                pillText,
                style: textStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
