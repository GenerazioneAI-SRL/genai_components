import 'package:flutter/material.dart';
import 'package:genai_components/cl_theme.dart';
import 'package:genai_components/layout/constants/sizes.constant.dart';
import 'cl_destination.dart';

/// Rail di navigazione icon-only (tier tablet). Una icona per voce top-level:
/// le foglie navigano (`onSelect`), i gruppi/sezioni aprono il drawer espanso
/// (`onOpenGroup`). `header`/`footer` sono slot opzionali (es. tenant in alto,
/// help+utente in basso). Stile flat, niente bolle.
class CLNavRail extends StatelessWidget {
  const CLNavRail({
    super.key,
    required this.destinations,
    required this.selectedKey,
    required this.onSelect,
    required this.onOpenGroup,
    this.header,
    this.footer,
    this.width = 72,
  });

  final List<CLDestination> destinations;
  final String? selectedKey;
  final ValueChanged<CLDestination> onSelect;

  /// Chiamato sul tap di una voce con figli/sezione → l'app apre il drawer
  /// (eventualmente espandendo quel gruppo).
  final ValueChanged<CLDestination> onOpenGroup;

  final Widget? header;
  final Widget? footer;
  final double width;

  /// Voci da mostrare nel rail: i section-header (es. "Anagrafica") NON sono
  /// navigabili e icon-only renderebbero solo una lettera → appiattiti nei loro
  /// figli (Timbrature, Marcatempo, …). Le foglie/gruppi top-level restano.
  List<CLDestination> get _items {
    final out = <CLDestination>[];
    for (final d in destinations) {
      if (!d.isVisible) continue;
      if (d.isSectionHeader) {
        out.addAll(d.children.where((c) => c.isVisible));
      } else {
        out.add(d);
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    return Container(
      width: width,
      // Rail (menu) = L0 + bordo destro.
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        border: Border(right: BorderSide(color: theme.borderColor)),
      ),
      child: SafeArea(
        right: false,
        child: Column(
          children: [
            if (header != null) ...[
              SizedBox(height: theme.gapMd),
              header!,
              SizedBox(height: theme.gapMd),
            ],
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: theme.gapSm),
                child: Column(
                  children: [
                    for (final d in _items)
                      _RailItem(destination: d, selectedKey: selectedKey, onSelect: onSelect, onOpenGroup: onOpenGroup),
                  ],
                ),
              ),
            ),
            if (footer != null) ...[
              SizedBox(height: theme.gapSm),
              footer!,
              SizedBox(height: theme.gapMd),
            ],
          ],
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.destination,
    required this.selectedKey,
    required this.onSelect,
    required this.onOpenGroup,
  });

  final CLDestination destination;
  final String? selectedKey;
  final ValueChanged<CLDestination> onSelect;
  final ValueChanged<CLDestination> onOpenGroup;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final d = destination;
    final selected = d.key == selectedKey || d.containsKey(selectedKey);
    // Selezionato: bolla grigia neutra + icona primary (coerente con la leaf
    // della sidebar). Non selezionato: icona secondaryText, niente sfondo.
    final fg = selected ? theme.primary : theme.secondaryText;

    final icon = d.buildIcon(fg, Sizes.iconSizeDefault) ??
        Text(
          d.label.isNotEmpty ? d.label.characters.first.toUpperCase() : '?',
          style: theme.bodyLabel.copyWith(color: fg, fontWeight: FontWeight.w700),
        );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: theme.gapSm / 2),
      child: Material(
        color: selected ? theme.secondaryText.withValues(alpha: 0.12) : Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => d.isLeaf ? onSelect(d) : onOpenGroup(d),
          child: SizedBox(
            height: theme.buttonHeightDefault,
            width: theme.buttonHeightDefault,
            child: Center(child: icon),
          ),
        ),
      ),
    );
  }
}
