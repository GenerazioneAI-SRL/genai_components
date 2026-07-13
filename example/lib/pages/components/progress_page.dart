import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;

import '../../shared/demo_page.dart';

/// Showcase esaustiva di [GenProgress] (= GenProgress).
///
/// Copre lo stato determinato (value 0..1), lo stato indeterminato (value: null,
/// animazione continua), l'altezza custom (minHeight) e i colori custom
/// (color / backgroundColor) presi dai token via [GenTokens].
class ProgressShowcase extends StatelessWidget {
  const ProgressShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    return DemoPage(
      children: [
        const DemoGroup(
          title: 'Determinato',
          description: 'value tra 0.0 e 1.0: la barra riempie la frazione indicata.',
          items: [
            DemoTile(label: '25% (value: 0.25)', width: 380, child: GenProgress(value: 0.25)),
            DemoTile(label: '50% (value: 0.5)', width: 380, child: GenProgress(value: 0.5)),
            DemoTile(label: '75% (value: 0.75)', width: 380, child: GenProgress(value: 0.75)),
            DemoTile(label: '100% (value: 1.0)', width: 380, child: GenProgress(value: 1)),
          ],
        ),
        const DemoGroup(
          title: 'Indeterminato',
          description: 'value: null -> animazione continua, per attese di durata ignota.',
          items: [
            DemoTile(label: 'value: null', width: 380, child: GenProgress()),
          ],
        ),
        const DemoGroup(
          title: 'Altezza (minHeight)',
          description: 'minHeight sovrascrive il default (16). Sottile vs spesso.',
          items: [
            DemoTile(label: 'minHeight: 4', width: 380, child: GenProgress(value: 0.6, minHeight: 4)),
            DemoTile(label: 'minHeight: 8 (default 16)', width: 380, child: GenProgress(value: 0.6, minHeight: 8)),
            DemoTile(label: 'minHeight: 24', width: 380, child: GenProgress(value: 0.6, minHeight: 24)),
          ],
        ),
        DemoGroup(
          title: 'Colori custom',
          description: 'color = indicatore, backgroundColor = traccia. Valori dai token Gen.',
          items: [
            DemoTile(
              label: 'color: accent',
              width: 380,
              child: GenProgress(value: 0.65, color: t.accent),
            ),
            DemoTile(
              label: 'color: danger',
              width: 380,
              child: GenProgress(value: 0.4, color: t.danger),
            ),
            DemoTile(
              label: 'color + backgroundColor',
              width: 380,
              child: GenProgress(
                value: 0.55,
                color: t.primary,
                backgroundColor: t.muted,
              ),
            ),
            DemoTile(
              label: 'indeterminato colorato',
              width: 380,
              child: GenProgress(color: t.accent, backgroundColor: t.muted),
            ),
          ],
        ),
      ],
    );
  }
}
