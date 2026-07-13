import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;
import '../../shared/demo_page.dart';

/// Showcase esaustiva di [GenSeparator] (= GenSeparator).
///
/// Copre: .horizontal() e .vertical(), thickness, color, margin, radius,
/// uso reale in liste e barre di azioni.
class SeparatorShowcase extends StatelessWidget {
  const SeparatorShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);

    return DemoPage(
      children: [
        // ---- HORIZONTAL ----
        DemoGroup(
          title: 'Horizontal',
          description: 'GenSeparator.horizontal(): linea a piena larghezza tra blocchi.',
          items: [
            DemoTile(
              label: 'default',
              width: 420,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sezione A', style: t.bodyText),
                  const SizedBox(height: 12),
                  const GenSeparator.horizontal(),
                  const SizedBox(height: 12),
                  Text('Sezione B', style: t.bodyText),
                ],
              ),
            ),
          ],
        ),

        // ---- HORIZONTAL: thickness + color ----
        DemoGroup(
          title: 'Horizontal — thickness e color',
          description: 'thickness controlla lo spessore; color sovrascrive il default border.',
          items: [
            DemoTile(
              label: 'thickness 1 / 2 / 4',
              width: 420,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  GenSeparator.horizontal(thickness: 1),
                  SizedBox(height: 16),
                  GenSeparator.horizontal(thickness: 2),
                  SizedBox(height: 16),
                  GenSeparator.horizontal(thickness: 4),
                ],
              ),
            ),
            DemoTile(
              label: 'color primary + radius',
              width: 420,
              child: GenSeparator.horizontal(
                thickness: 4,
                color: t.primary,
                radius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),

        // ---- HORIZONTAL: margin ----
        DemoGroup(
          title: 'Horizontal — margin',
          description: 'margin: spazio attorno al separatore.',
          items: [
            DemoTile(
              label: 'margin verticale 24',
              width: 420,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sopra', style: t.bodyText),
                  const GenSeparator.horizontal(margin: EdgeInsets.symmetric(vertical: 24)),
                  Text('Sotto', style: t.bodyText),
                ],
              ),
            ),
          ],
        ),

        // ---- VERTICAL ----
        DemoGroup(
          title: 'Vertical',
          description: 'GenSeparator.vertical(): dentro un box con altezza + Row.',
          items: [
            DemoTile(
              label: 'in una toolbar',
              width: 420,
              child: SizedBox(
                height: 40,
                child: Row(
                  children: [
                    GenButton.ghost(onPressed: () {}, child: const Text('Copia')),
                    const GenSeparator.vertical(margin: EdgeInsets.symmetric(horizontal: 8)),
                    GenButton.ghost(onPressed: () {}, child: const Text('Incolla')),
                    const GenSeparator.vertical(margin: EdgeInsets.symmetric(horizontal: 8)),
                    GenButton.ghost(onPressed: () {}, child: const Text('Taglia')),
                  ],
                ),
              ),
            ),
          ],
        ),

        // ---- VERTICAL: thickness + color ----
        DemoGroup(
          title: 'Vertical — thickness e color',
          description: 'thickness = larghezza del separatore verticale; color custom.',
          items: [
            DemoTile(
              label: 'spessore e colore',
              width: 420,
              child: SizedBox(
                height: 40,
                child: Row(
                  children: [
                    Text('Uno', style: t.bodyText),
                    const GenSeparator.vertical(thickness: 2, margin: EdgeInsets.symmetric(horizontal: 12)),
                    Text('Due', style: t.bodyText),
                    GenSeparator.vertical(
                      thickness: 3,
                      color: t.primary,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    Text('Tre', style: t.bodyText),
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
