import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;

import '../../shared/demo_page.dart';

/// Showcase esaustiva di [GenSheet] (= GenSheet), aperto con `showGenSheet`.
///
/// Il lato di ingresso e' deciso dal parametro `side` di `showGenSheet` (non da
/// GenSheet, che lo legge dall'InheritedWidget). Copre: tutti i `side`
/// (top/bottom/left/right), contenuto scrollabile, actions, form interno,
/// draggable ed expandable (resize con drag handle + snap).
///
/// IMPORTANTE overlay: `showGenSheet` imposta internamente `opaque: false`
/// (chiama showGenDialog con opaque:false), quindi l'app resta visibile dietro.
class SheetShowcase extends StatelessWidget {
  const SheetShowcase({super.key});

  /// Apre un sheet dal lato [side] con contenuto [child].
  Future<void> _open(
    BuildContext context, {
    required GenSheetSide side,
    required Widget child,
    bool isDismissible = true,
  }) {
    return showGenSheet<void>(
      context: context,
      side: side,
      isDismissible: isDismissible,
      builder: (ctx) => child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      children: [
        DemoGroup(
          title: 'Side',
          description: 'Il lato di ingresso: top, bottom, left, right (parametro side di showGenSheet).',
          items: [
            for (final entry in const [
              ('Bottom', GenSheetSide.bottom, LucideIcons.panelBottom),
              ('Top', GenSheetSide.top, LucideIcons.panelTop),
              ('Left', GenSheetSide.left, LucideIcons.panelLeft),
              ('Right', GenSheetSide.right, LucideIcons.panelRight),
            ])
              DemoTile(
                label: 'side: ${entry.$1}',
                child: GenButton.secondary(
                  leading: GenIcon(entry.$3),
                  onPressed: () => _open(
                    context,
                    side: entry.$2,
                    child: Builder(
                      builder: (ctx) => GenSheet(
                        title: Text('Sheet ${entry.$1}'),
                        description: Text('Entra dal lato ${entry.$1.toLowerCase()}.'),
                        actions: [
                          GenButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Chiudi')),
                        ],
                        child: const Text('Contenuto del pannello. Tap fuori o trascina per chiudere.'),
                      ),
                    ),
                  ),
                  child: Text(entry.$1),
                ),
              ),
          ],
        ),
        DemoGroup(
          title: 'Contenuto scrollabile',
          description: 'Con contenuto lungo il body scorre internamente (scrollable di default).',
          items: [
            DemoTile(
              label: 'lista lunga (right)',
              child: GenButton.secondary(
                leading: const GenIcon(LucideIcons.list),
                onPressed: () => _open(
                  context,
                  side: GenSheetSide.right,
                  child: Builder(
                    builder: (ctx) => GenSheet(
                      title: const Text('Notifiche'),
                      description: const Text('Ultime attivita\''),
                      constraints: const BoxConstraints(maxWidth: 380),
                      actions: [
                        GenButton.outline(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Chiudi')),
                      ],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          20,
                          (i) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                const GenIcon(LucideIcons.bell, size: 16),
                                const SizedBox(width: 10),
                                Expanded(child: Text('Evento numero ${i + 1} nel registro delle attivita\'.')),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                child: const Text('Apri lista'),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Form e actions',
          description: 'Sheet con input e piu\' azioni in fondo.',
          items: [
            DemoTile(
              label: 'form filtri (bottom)',
              child: GenButton(
                leading: const GenIcon(LucideIcons.slidersHorizontal),
                onPressed: () => _open(
                  context,
                  side: GenSheetSide.bottom,
                  child: Builder(
                    builder: (ctx) => GenSheet(
                      title: const Text('Filtri'),
                      description: const Text('Affina i risultati e applica.'),
                      actions: [
                        GenButton.ghost(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Reset')),
                        GenButton.outline(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Annulla')),
                        GenButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Applica')),
                      ],
                      child: const SizedBox(
                        width: 420,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            GenInput(placeholder: Text('Cerca per nome'), leading: GenIcon(LucideIcons.search, size: 16)),
                            SizedBox(height: 12),
                            GenInput(placeholder: Text('Categoria'), leading: GenIcon(LucideIcons.tag, size: 16)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                child: const Text('Apri filtri'),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Draggable ed expandable',
          description: 'draggable: chiusura con trascinamento. expandable: resize con drag handle e snap.',
          items: [
            DemoTile(
              label: 'draggable (bottom)',
              child: GenButton.secondary(
                leading: const GenIcon(LucideIcons.gripHorizontal),
                onPressed: () => _open(
                  context,
                  side: GenSheetSide.bottom,
                  child: Builder(
                    builder: (ctx) => GenSheet(
                      draggable: true,
                      title: const Text('Trascinami giu\''),
                      description: const Text('draggable: true — trascina verso il basso per chiudere.'),
                      actions: [
                        GenButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Chiudi')),
                      ],
                      child: const Text('Il gesto di drag verso il bordo chiude lo sheet.'),
                    ),
                  ),
                ),
                child: const Text('Draggable'),
              ),
            ),
            DemoTile(
              label: 'expandable + snap',
              child: GenButton.secondary(
                leading: const GenIcon(LucideIcons.moveVertical),
                onPressed: () => _open(
                  context,
                  side: GenSheetSide.bottom,
                  child: Builder(
                    builder: (ctx) => GenSheet(
                      expandable: true,
                      initialSize: 0.5,
                      minSize: 0.25,
                      maxSize: 1,
                      snap: true,
                      snapSizes: const [0.25, 0.5, 1],
                      title: const Text('Pannello ridimensionabile'),
                      description: const Text('Trascina la maniglia per ridimensionare; rilascia per lo snap.'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          15,
                          (i) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text('Riga contenuto ${i + 1}'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                child: const Text('Expandable'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
