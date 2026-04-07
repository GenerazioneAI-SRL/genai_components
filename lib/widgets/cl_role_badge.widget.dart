import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:genai_components/cl_theme.dart';
import 'package:genai_components/layout/constants/sizes.constant.dart';

/// Widget per visualizzare un badge con icona + testo colorato in un container arrotondato
/// Usato per figure come Metodologo, Progettista, Ente di Formazione, ecc.
class CLRoleBadge extends StatelessWidget {
  final String label;
  final Color color;
  final dynamic icon; // Può essere IconData o HugeIcon data
  final double iconSize;
  final bool showBorder;

  const CLRoleBadge({super.key, required this.label, required this.color, required this.icon, this.iconSize = 18, this.showBorder = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.padding / 2, vertical: Sizes.padding / 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(Sizes.borderRadius),
            border: showBorder ? Border.all(color: color.withValues(alpha: 0.3), width: 1) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              HugeIcon(icon: icon, color: color, size: iconSize),
              const SizedBox(width: Sizes.padding / 2),
              Flexible(
                child: Text(
                  label,
                  style: CLTheme.of(context).bodyText.copyWith(color: color, fontWeight: FontWeight.w500, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ],
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

  const CLRoleIcon({super.key, required this.tooltip, required this.color, required this.icon, this.radius = 16, this.iconSize = 18});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: CircleAvatar(radius: radius, backgroundColor: color.withValues(alpha: 0.2), child: HugeIcon(icon: icon, color: color, size: iconSize)),
    );
  }
}
