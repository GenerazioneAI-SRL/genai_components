import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:genai_components/cl_theme.dart';
import 'package:genai_components/layout/constants/sizes.constant.dart';
import 'package:genai_components/widgets/buttons/cl_icon_button.widget.dart';

/// Trigger riusabile della global search (UI-only). Apre la palette tramite
/// [onTap] — nessuna logica interna: l'app decide cosa aprire (es.
/// `CLCommandPalette.show(...)` con i propri items).
///
/// [compact] true → solo icona (mobile, `CLIconButton`); false → pill card
/// `secondaryBackground` + `cardShadowSoft` con label + chip scorciatoia.
/// Token coerenti col trigger di skillera_admin.
class CLGlobalSearch extends StatelessWidget {
  const CLGlobalSearch({
    super.key,
    required this.onTap,
    this.compact = false,
    this.width = 240,
    this.height,
    this.label = 'Cerca…',
    this.shortcut = '⌘K',
  });

  final VoidCallback onTap;
  final bool compact;
  final double width;

  /// Altezza del trigger. Default `buttonHeightDefault` (40), allineato a
  /// input/button dell'app. Override per contesti più densi.
  final double? height;
  final String label;
  final String? shortcut;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final h = height ?? theme.buttonHeightDefault;

    if (compact) {
      return CLIconButton(
        onTap: onTap,
        iconData: LucideIcons.search,
        backgroundColor: theme.secondaryBackground,
        boxShadow: theme.cardShadowSoft,
        iconColor: theme.primaryText,
        size: h,
        iconSize: Sizes.iconSizeDefault,
        tooltip: 'Cerca',
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: h,
        width: width,
        padding: EdgeInsets.symmetric(horizontal: theme.gapMd),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(theme.radiusPill),
          boxShadow: theme.cardShadowSoft,
        ),
        child: Row(
          children: [
            Icon(LucideIcons.search, size: Sizes.iconSizeCompact, color: theme.primaryText),
            SizedBox(width: theme.gapSm),
            Expanded(
              child: Text(
                label,
                style: theme.bodyText.copyWith(color: theme.mutedForeground),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (shortcut != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: theme.gapXs, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.controlFill,
                  borderRadius: BorderRadius.circular(theme.radiusChip),
                ),
                child: Text(shortcut!, style: theme.smallLabel.copyWith(color: theme.mutedForeground, fontSize: 11)),
              ),
          ],
        ),
      ),
    );
  }
}
