import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;

import '../../shared/demo_page.dart';

/// Vista modulo "Utility": GenResponsiveBuilder (rende contenuto diverso in
/// base al breakpoint corrente del tema).
class UtilityShowcase extends StatelessWidget {
  const UtilityShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    return DemoPage(
      children: [
        DemoGroup(
          title: 'GenResponsiveBuilder',
          description: 'Rende contenuto diverso in base al breakpoint corrente (ridimensiona la finestra).',
          items: [
            DemoTile(
              width: 320,
              label: 'breakpoint corrente',
              child: GenResponsiveBuilder(
                builder: (context, breakpoint) => GenCard(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text('Breakpoint: ${breakpoint.runtimeType}', style: t.bodyText),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
