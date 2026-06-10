import 'package:flutter/material.dart';

import '../cl_theme.dart';

/// CLPill — chip/pill atomico per stati, conteggi, tag.
///
/// Linguaggio Skillera Refined Editorial:
/// - bg soft tint (color × 0.08), border tonale 1px (color × 0.22)
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
    final Color tonalBorder = pillColor.withValues(alpha: 0.22);

    return IntrinsicWidth(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: theme.gapSm,
          vertical: theme.gapXs / 2 + 1,
        ),
        decoration: BoxDecoration(
          color: outline ? Colors.transparent : softBg,
          borderRadius: BorderRadius.circular(theme.radiusPill),
          border: Border.all(
            color: outline ? pillColor : tonalBorder,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: pillColor),
              SizedBox(width: theme.gapXs),
            ],
            Text(
              pillText,
              style: textStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
