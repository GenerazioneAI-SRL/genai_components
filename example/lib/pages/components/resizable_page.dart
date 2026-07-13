import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;
import '../../shared/demo_page.dart';

/// Showcase esaustiva di [GenResizablePanelGroup] (= GenResizablePanelGroup) +
/// [GenResizablePanel] (= GenResizablePanel).
///
/// Copre: gruppo orizzontale a 2 e 3 pannelli, gruppo verticale, defaultSize /
/// minSize / maxSize, handle visibile (showHandle), handle icona custom,
/// divider (color/thickness/size), reset su doppio tap.
///
/// Nota UX: trascina le maniglie tra i pannelli per ridimensionare; doppio tap
/// sul divider ripristina le dimensioni di default.
class ResizableShowcase extends StatelessWidget {
  const ResizableShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);

    // Contenuto standard di un pannello: superficie muted + label centrata.
    Widget panel(String label, {IconData? icon}) => Container(
          color: t.muted,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                GenIcon(icon, color: t.secondaryText),
                const SizedBox(height: 8),
              ],
              Text(label, style: t.bodyLabel, textAlign: TextAlign.center),
            ],
          ),
        );

    // Pannello reso con GenCard (variante "card dentro pannello").
    Widget cardPanel(String title, String body) => Padding(
          padding: const EdgeInsets.all(12),
          child: GenCard(
            title: Text(title),
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(body, style: t.smallText),
            ),
          ),
        );

    // Bordo attorno al gruppo per delimitarne l'area.
    Widget framed({required double height, required Widget child}) => Container(
          height: height,
          decoration: BoxDecoration(
            border: Border.all(color: t.borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        );

    return DemoPage(
      children: [
        // ---- ORIZZONTALE 2 PANNELLI ----
        DemoGroup(
          title: 'Orizzontale — 2 pannelli',
          description:
              'axis di default (horizontal). Due GenResizablePanel 50/50; trascina la maniglia centrale.',
          items: [
            DemoTile(
              label: 'defaultSize 0.5 / 0.5',
              width: 520,
              child: framed(
                height: 220,
                child: GenResizablePanelGroup(
                  showHandle: true,
                  children: [
                    GenResizablePanel(
                      id: 'h2-a',
                      defaultSize: 0.5,
                      child: panel('Pannello sinistro', icon: LucideIcons.panelLeft),
                    ),
                    GenResizablePanel(
                      id: 'h2-b',
                      defaultSize: 0.5,
                      child: panel('Pannello destro', icon: LucideIcons.panelRight),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // ---- ORIZZONTALE 3 PANNELLI + MIN/MAX ----
        DemoGroup(
          title: 'Orizzontale — 3 pannelli con min/max',
          description:
              'defaultSize iniziali 0.25 / 0.5 / 0.25; minSize e maxSize limitano il ridimensionamento di ogni pannello.',
          items: [
            DemoTile(
              label: 'sidebar / contenuto / aside',
              width: 520,
              child: framed(
                height: 220,
                child: GenResizablePanelGroup(
                  showHandle: true,
                  children: [
                    GenResizablePanel(
                      id: 'h3-a',
                      defaultSize: 0.25,
                      minSize: 0.15,
                      maxSize: 0.4,
                      child: panel('Sidebar\n(15%–40%)', icon: LucideIcons.list),
                    ),
                    GenResizablePanel(
                      id: 'h3-b',
                      defaultSize: 0.5,
                      minSize: 0.3,
                      child: panel('Contenuto\n(min 30%)', icon: LucideIcons.fileText),
                    ),
                    GenResizablePanel(
                      id: 'h3-c',
                      defaultSize: 0.25,
                      minSize: 0.15,
                      maxSize: 0.4,
                      child: panel('Aside\n(15%–40%)', icon: LucideIcons.info),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // ---- VERTICALE ----
        DemoGroup(
          title: 'Verticale',
          description:
              'axis: Axis.vertical. I pannelli si impilano; la maniglia si trascina in su/giù.',
          items: [
            DemoTile(
              label: 'editor sopra / console sotto',
              width: 520,
              child: framed(
                height: 320,
                child: GenResizablePanelGroup(
                  axis: Axis.vertical,
                  showHandle: true,
                  children: [
                    GenResizablePanel(
                      id: 'v-a',
                      defaultSize: 0.65,
                      minSize: 0.2,
                      child: panel('Editor', icon: LucideIcons.code),
                    ),
                    GenResizablePanel(
                      id: 'v-b',
                      defaultSize: 0.35,
                      minSize: 0.15,
                      child: panel('Console', icon: LucideIcons.terminal),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // ---- HANDLE / DIVIDER STYLE ----
        DemoGroup(
          title: 'Handle e divider — stile',
          description:
              'handleIconData (icona custom), dividerColor, dividerThickness e dividerSize personalizzano la maniglia.',
          items: [
            DemoTile(
              label: 'handle icona + divider primary',
              width: 520,
              child: framed(
                height: 220,
                child: GenResizablePanelGroup(
                  showHandle: true,
                  handleIconData: LucideIcons.gripVertical,
                  dividerColor: t.primary,
                  dividerThickness: 2,
                  dividerSize: 12,
                  children: [
                    GenResizablePanel(
                      id: 'st-a',
                      defaultSize: 0.4,
                      child: panel('A'),
                    ),
                    GenResizablePanel(
                      id: 'st-b',
                      defaultSize: 0.6,
                      child: panel('B'),
                    ),
                  ],
                ),
              ),
            ),
            DemoTile(
              label: 'senza handle (solo divider)',
              width: 520,
              child: framed(
                height: 220,
                child: GenResizablePanelGroup(
                  children: [
                    GenResizablePanel(
                      id: 'nh-a',
                      defaultSize: 0.5,
                      child: panel('Trascina il bordo'),
                    ),
                    GenResizablePanel(
                      id: 'nh-b',
                      defaultSize: 0.5,
                      child: panel('per ridimensionare'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // ---- CONTENUTO GenCard ----
        DemoGroup(
          title: 'Con contenuto GenCard',
          description:
              'I pannelli possono contenere qualsiasi widget: qui una GenCard per lato.',
          items: [
            DemoTile(
              label: 'card a sinistra e a destra',
              width: 520,
              child: framed(
                height: 240,
                child: GenResizablePanelGroup(
                  showHandle: true,
                  children: [
                    GenResizablePanel(
                      id: 'cp-a',
                      defaultSize: 0.5,
                      minSize: 0.25,
                      child: cardPanel('Anteprima', 'Contenuto sinistro ridimensionabile.'),
                    ),
                    GenResizablePanel(
                      id: 'cp-b',
                      defaultSize: 0.5,
                      minSize: 0.25,
                      child: cardPanel('Dettagli', 'Contenuto destro ridimensionabile.'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // ---- RESET DOUBLE TAP ----
        DemoGroup(
          title: 'Reset su doppio tap',
          description:
              'resetOnDoubleTap (default true): doppio tap sul divider ripristina le defaultSize.',
          items: [
            DemoTile(
              label: 'doppio tap sul divider → reset 0.3 / 0.7',
              width: 520,
              child: framed(
                height: 220,
                child: GenResizablePanelGroup(
                  showHandle: true,
                  children: [
                    GenResizablePanel(
                      id: 'rd-a',
                      defaultSize: 0.3,
                      child: panel('30%'),
                    ),
                    GenResizablePanel(
                      id: 'rd-b',
                      defaultSize: 0.7,
                      child: panel('70%'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
