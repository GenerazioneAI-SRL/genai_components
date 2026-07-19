import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
// Budella Shad: nucleo interno = ShadAccordion single-item + ShadAccordionItem
// (header, chevron rotante e animazione expand nativi). Solo i simboli usati
// (show). Firma pubblica CLCollapsible invariata.
import 'package:shadcn_ui/shadcn_ui.dart' show ShadAccordion, ShadAccordionItem;
import '../cl_theme.dart';

/// Sezione espandibile/collassabile con animazione. Alternativa più semplice
/// a `CustomExpansionTile` con stile coerente al tema.
///
/// Linguaggio Skillera Refined Editorial: header con chevron rotante, titolo
/// `theme.title`, leading opzionale. Interazione (toggle/animazione/hover)
/// delegata a ShadAccordionItem; tono CL nei colori/testi.
class CLCollapsible extends StatelessWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;
  final Widget? leading;

  const CLCollapsible({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);

    final Widget titleWidget = leading == null
        ? Text(title, style: theme.title)
        : Row(
            children: [
              leading!,
              SizedBox(width: theme.gapSm),
              Expanded(child: Text(title, style: theme.title)),
            ],
          );

    return ShadAccordion<int>(
      initialValue: initiallyExpanded ? 0 : null,
      children: [
        ShadAccordionItem<int>(
          value: 0,
          titleStyle: theme.title,
          iconData: LucideIcons.chevronDown,
          padding: EdgeInsets.symmetric(
            horizontal: theme.gapMd,
            vertical: theme.gapMd,
          ),
          title: titleWidget,
          child: Padding(
            padding: EdgeInsets.only(top: theme.gapMd, bottom: theme.gapMd),
            child: child,
          ),
        ),
      ],
    );
  }
}
