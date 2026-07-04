import 'package:flutter/material.dart';

import '../cl_theme.dart';

/// CLPill — chip/pill atomico per stati, conteggi, tag.
///
/// Linguaggio Skillera Refined Editorial:
/// - filled (default): bg soft tint (color × 0.08), NESSUN bordo
/// - outline: bg trasparente + bordo 1px color
/// - pill radius (`CLTheme.radiusPill`)
/// - tipografia Inter SemiBold (`smallLabel` con peso w600)
/// - icona opzionale `CLTheme.iconSizeCompact` (16) — riducibile inline a 14
///   per restare proporzionata al testo del pill.
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

    final Color softBg = pillColor.withValues(alpha: 0.08);

    return IntrinsicWidth(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: theme.gapSm,
          vertical: theme.gapXs / 2 + 1,
        ),
        decoration: BoxDecoration(
          color: outline ? Colors.transparent : softBg,
          borderRadius: BorderRadius.circular(theme.radiusPill),
          // Filled: solo soft tint, niente bordo colorato. Outline: bordo color.
          border: outline ? Border.all(color: pillColor, width: 1) : null,
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
