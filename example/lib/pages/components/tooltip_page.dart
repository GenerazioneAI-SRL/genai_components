import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;

import '../../shared/demo_page.dart';

/// Showcase esaustiva di [GenTooltip] (= GenTooltip).
///
/// Il tooltip appare su hover (o focus) del [child]. Copre: child bottone,
/// child icon button, contenuto ricco dal `builder`, posizionamento via `anchor`
/// (sopra / sotto / a destra) e ritardo di apertura via `waitDuration`.
///
/// Nota: passa il puntatore sopra i controlli per vedere il tooltip.
class TooltipShowcase extends StatelessWidget {
  const TooltipShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    return DemoPage(
      children: [
        DemoGroup(
          title: 'Child',
          description: 'Il tooltip si aggancia a qualsiasi widget: bottone o icon button.',
          items: [
            DemoTile(
              label: 'Su GenButton',
              child: GenTooltip(
                builder: (context) => const Text('Aggiungi un nuovo elemento'),
                child: GenButton(
                  onPressed: () {},
                  leading: const Icon(LucideIcons.plus),
                  child: const Text('Aggiungi'),
                ),
              ),
            ),
            DemoTile(
              label: 'Su GenIconButton',
              child: GenTooltip(
                builder: (context) => const Text('Impostazioni'),
                child: GenIconButton(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.settings),
                ),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Contenuto (builder)',
          description: 'Il builder puo\' restituire qualsiasi widget, non solo testo.',
          items: [
            DemoTile(
              label: 'Testo semplice',
              child: GenTooltip(
                builder: (context) => const Text('Copia negli appunti'),
                child: GenIconButton(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.copy),
                ),
              ),
            ),
            DemoTile(
              label: 'Contenuto ricco',
              child: GenTooltip(
                builder: (context) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.info, size: 14, color: t.secondaryText),
                    const SizedBox(width: 6),
                    const Text('Salva con Ctrl+S'),
                  ],
                ),
                child: GenButton.outline(
                  onPressed: () {},
                  child: const Text('Salva'),
                ),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Posizionamento (anchor)',
          description: 'anchor controlla dove appare rispetto al child: sopra, sotto, a destra.',
          items: [
            DemoTile(
              label: 'Sopra (default)',
              child: GenTooltip(
                builder: (context) => const Text('Sopra il child'),
                child: GenButton.secondary(onPressed: () {}, child: const Text('Sopra')),
              ),
            ),
            DemoTile(
              label: 'Sotto',
              child: GenTooltip(
                anchor: const GenAnchor(
                  childAlignment: Alignment.bottomCenter,
                  overlayAlignment: Alignment.topCenter,
                  offset: Offset(0, 4),
                ),
                builder: (context) => const Text('Sotto il child'),
                child: GenButton.secondary(onPressed: () {}, child: const Text('Sotto')),
              ),
            ),
            DemoTile(
              label: 'A destra',
              child: GenTooltip(
                anchor: const GenAnchor(
                  childAlignment: Alignment.centerRight,
                  overlayAlignment: Alignment.centerLeft,
                  offset: Offset(4, 0),
                ),
                builder: (context) => const Text('A destra del child'),
                child: GenButton.secondary(onPressed: () {}, child: const Text('Destra')),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Ritardo (waitDuration)',
          description: 'waitDuration impone un\'attesa in hover prima di mostrare il tooltip.',
          items: [
            DemoTile(
              label: 'Immediato (default)',
              child: GenTooltip(
                builder: (context) => const Text('Appare subito'),
                child: GenIconButton(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.zap),
                ),
              ),
            ),
            DemoTile(
              label: 'waitDuration: 600ms',
              child: GenTooltip(
                waitDuration: const Duration(milliseconds: 600),
                builder: (context) => const Text('Appare dopo 600ms di hover'),
                child: GenIconButton(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.clock),
                ),
              ),
            ),
            DemoTile(
              label: 'showDuration: 1s (persiste all\'uscita)',
              child: GenTooltip(
                showDuration: const Duration(seconds: 1),
                builder: (context) => const Text('Resta 1s dopo l\'uscita'),
                child: GenIconButton(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.timer),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
