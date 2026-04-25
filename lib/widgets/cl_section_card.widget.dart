import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
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

    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(Sizes.radiusCard),
        border: Border.all(color: theme.cardBorder),
        boxShadow: theme.cardShadow,
      ),
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
                    color: iconColor.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(Sizes.radiusSm),
                  ),
                  child: HugeIcon(icon: icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: Sizes.padding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.title.copyWith(fontWeight: FontWeight.w600)),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
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

