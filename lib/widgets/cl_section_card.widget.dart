import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
// Budella Shad: il frame (bg/bordo/raggio/ombra) è ShadCard. Solo i simboli
// usati (show). Firma pubblica CLSectionCard invariata.
import 'package:shadcn_ui/shadcn_ui.dart' show ShadCard, ShadBorder;
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

/// CLSectionCard — card con header colorato, icona HugeIcon, titolo/sottotitolo e contenuto.
///
/// Estratto dal pattern duplicato in shift_plans, shift_templates, rotation_patterns.
class CLSectionCard extends StatelessWidget {
  final dynamic icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;

  const CLSectionCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(Sizes.radiusCard);

    // Frame via ShadCard (padding zero + clip antiAlias: l'header colorato con
    // i top corner arrotondati resta dentro il raggio). Chrome CL preservato:
    // secondaryBackground, cardBorder, cardShadow.
    return ShadCard(
      padding: EdgeInsets.zero,
      backgroundColor: theme.secondaryBackground,
      radius: radius,
      border: ShadBorder.all(color: theme.cardBorder, width: 1, radius: radius),
      shadows: theme.cardShadow,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(Sizes.padding),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isDark ? 0.08 : 0.04),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(Sizes.radiusCard),
                topRight: Radius.circular(Sizes.radiusCard),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: isDark ? theme.opacityMedium : theme.opacitySoft),
                    borderRadius: BorderRadius.circular(Sizes.radiusControl),
                  ),
                  child: HugeIcon(icon: icon, color: iconColor, size: Sizes.iconSizeDefault),
                ),
                const SizedBox(width: Sizes.gapMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.title.copyWith(fontWeight: FontWeight.w600)),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: Sizes.gapXs),
                          child: Text(subtitle!, style: theme.bodyLabel),
                        ),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Sizes.padding),
            child: child,
          ),
        ],
      ),
    );
  }
}
