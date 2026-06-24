import 'package:flutter/material.dart';
import '../../cl_theme.dart';
import '../cl_tabs/cl_tab_item.model.dart';
import '../cl_tabs/cl_tab_view.widget.dart';
import 'entity_domain.dart';
import 'entity_tab.model.dart';

/// Registro di tab di dettaglio entità, domain-tagged e permission-gated,
/// costruito SOPRA [CLTabView].
///
/// Il chiamante dichiara una lista di [EntityTab]; il widget filtra per
/// `EntityTab.guard` (null => sempre visibile) e mappa le tab residue in
/// [CLTabItem], delegando rendering e lazy-mount a [CLTabView]. Il contenuto di
/// ogni tab è avvolto in un [Builder] così che `EntityTab.builder` venga
/// invocato solo quando [CLTabView] monta effettivamente quella tab,
/// preservando il caricamento dati pigro.
///
/// Con [groupByDomain] true le voci vengono raggruppate per [EntityDomain]:
/// **una tab per dominio** (Anagrafica, Risorse Umane, ...), contenuto = colonna
/// verticale delle card di quel dominio. Così il numero di tab resta limitato al
/// numero di domini (max 6), non al numero di card — aggiungere card a un
/// dominio non crea nuove tab, e spostare una card da un dominio all'altro
/// (cambiando `EntityTab.domain`) la riposiziona nella tab giusta.
///
/// Se nessuna voce è visibile mostra un placeholder vuoto.
class CLEntityTabs extends StatelessWidget {
  final List<EntityTab> tabs;
  final String? title;

  /// Header ricco persistente sopra la tab bar (ha precedenza su [title]).
  /// Resta visibile al cambio tab; inoltrato a [CLTabView.titleWidget].
  final Widget? titleWidget;
  final bool showDivider;

  /// Colore dell'indicator (sottolineato) del tab attivo, inoltrato a
  /// [CLTabView]. Default: `theme.primary`.
  final Color? indicatorColor;

  /// Se true, raggruppa le voci per [EntityDomain] (una tab per dominio, ordine
  /// enum `EntityDomain.values`); il contenuto della tab è la colonna verticale
  /// delle card di quel dominio. Se false (default) ogni [EntityTab] è una tab a
  /// sé (label/icona della voce).
  final bool groupByDomain;

  /// Notificato col `key` della tab attiva ([EntityTab.key], o nome del dominio
  /// se [groupByDomain]); utile per scoping di contenuti renderizzati FUORI dal
  /// widget. Inoltrato a [CLTabView.onTabChanged] mappando indice→key.
  final ValueChanged<String>? onTabChanged;

  const CLEntityTabs({
    super.key,
    required this.tabs,
    this.title,
    this.titleWidget,
    this.showDivider = false,
    this.indicatorColor,
    this.groupByDomain = false,
    this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);

    final visible = tabs.where((t) => t.guard == null || t.guard!() == true).toList();

    if (visible.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(theme.gap2Xl),
          child: Text(
            'Nessuna sezione disponibile',
            style: theme.bodyText.copyWith(color: theme.mutedForeground),
          ),
        ),
      );
    }

    final items = groupByDomain ? _groupedItems(visible, theme) : _perTabItems(visible);
    // Chiavi parallele agli items: riportano la tab attiva come key stabile,
    // indipendente dal filtraggio dei guard.
    final keys = groupByDomain
        ? [for (final d in EntityDomain.values) if (visible.any((t) => t.domain == d)) d.name]
        : [for (final t in visible) t.key];

    return CLTabView(
      clTabItems: items,
      title: title,
      titleWidget: titleWidget,
      showDivider: showDivider,
      indicatorColor: indicatorColor,
      onTabChanged: onTabChanged == null ? null : (i) => onTabChanged!(keys[i]),
    );
  }

  // Una tab per voce: label/icona della singola [EntityTab].
  List<CLTabItem> _perTabItems(List<EntityTab> visible) {
    return visible
        .map(
          (t) => CLTabItem(
            tabName: t.label,
            icon: t.icon,
            // Builder => content built lazily when CLTabView mounts the tab.
            tabContent: Builder(builder: (_) => t.builder()),
          ),
        )
        .toList();
  }

  // Una tab per dominio (ordine `EntityDomain.values`): contenuto = colonna
  // verticale delle card del dominio, costruite pigramente al primo mount della
  // tab (Builder) — coerente col lazy-mount di CLTabView.
  List<CLTabItem> _groupedItems(List<EntityTab> visible, CLTheme theme) {
    final items = <CLTabItem>[];
    for (final domain in EntityDomain.values) {
      final group = visible.where((t) => t.domain == domain).toList();
      if (group.isEmpty) continue;
      items.add(
        CLTabItem(
          tabName: domain.label,
          tabContent: Builder(
            builder: (_) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < group.length; i++) ...[
                  if (i > 0) SizedBox(height: theme.gapLg),
                  group[i].builder(),
                ],
              ],
            ),
          ),
        ),
      );
    }
    return items;
  }
}
