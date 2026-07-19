import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
// Budella Shad: CLRoleBadge = ShadBadge.raw (soft + border, radiusChip). Solo i
// simboli usati (show). CLRoleIcon resta CircleAvatar (non è un badge).
import 'package:shadcn_ui/shadcn_ui.dart' show ShadBadge, ShadBadgeVariant;
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

/// Widget per visualizzare un badge con icona + testo colorato in un container arrotondato
/// Usato per figure come Metodologo, Progettista, Ente di Formazione, ecc.
class CLRoleBadge extends StatelessWidget {
  final String label;
  final Color color;
  final dynamic icon; // Può essere IconData o HugeIcon data
  final double iconSize;
  final bool showBorder;

  const CLRoleBadge({super.key, required this.label, required this.color, required this.icon, this.iconSize = Sizes.iconSizeCompact, this.showBorder = true});

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    // Soft bg + bordo color@0.3 (se showBorder), radiusChip: chrome CL 1:1.
    return ShadBadge.raw(
      variant: ShadBadgeVariant.primary,
      backgroundColor: color.withValues(alpha: theme.opacitySoft),
      hoverBackgroundColor: color.withValues(alpha: theme.opacitySoft),
      foregroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: Sizes.padding / 2, vertical: Sizes.padding / 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.radiusChip),
        side: showBorder
            ? BorderSide(color: color.withValues(alpha: 0.3), width: 1)
            : BorderSide.none,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(icon: icon, color: color, size: iconSize),
          const SizedBox(width: Sizes.padding / 2),
          Flexible(
            child: Text(
              label,
              style: theme.smallLabel.copyWith(color: color, fontWeight: FontWeight.w500, fontSize: 13),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget per visualizzare solo l'icona del ruolo in un CircleAvatar con tooltip
class CLRoleIcon extends StatelessWidget {
  final String tooltip;
  final Color color;
  final dynamic icon; // Può essere IconData o HugeIcon data
  final double radius;
  final double iconSize;

  const CLRoleIcon({super.key, required this.tooltip, required this.color, required this.icon, this.radius = 16, this.iconSize = Sizes.iconSizeCompact});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: CircleAvatar(radius: radius, backgroundColor: color.withValues(alpha: CLTheme.of(context).opacityMedium), child: HugeIcon(icon: icon, color: color, size: iconSize)),
    );
  }
}
