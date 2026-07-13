import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;

import '../../shared/demo_page.dart';

/// Showcase esaustiva di [GenTextarea] (=GenTextarea): placeholder, valore
/// multiriga, dimensioni (minHeight/maxHeight), resize handle on/off, stati
/// (disabled/readOnly), vincoli (maxLength) e slot leading/bottom.
class TextareaShowcase extends StatefulWidget {
  const TextareaShowcase({super.key});

  @override
  State<TextareaShowcase> createState() => _TextareaShowcaseState();
}

class _TextareaShowcaseState extends State<TextareaShowcase> {
  final _readOnlyController = TextEditingController(
    text: 'Contenuto in sola lettura.\nNon modificabile ma selezionabile.',
  );

  @override
  void dispose() {
    _readOnlyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    return DemoPage(
      children: [
        DemoGroup(
          title: 'Base',
          description: 'placeholder e valore iniziale multiriga.',
          items: const [
            DemoTile(
              width: 280,
              label: 'placeholder',
              child: GenTextarea(placeholder: Text('Scrivi un messaggio…')),
            ),
            DemoTile(
              width: 280,
              label: 'initialValue (multiriga)',
              child: GenTextarea(initialValue: 'Prima riga\nSeconda riga\nTerza riga'),
            ),
          ],
        ),
        DemoGroup(
          title: 'Dimensioni',
          description: 'minHeight, maxHeight e resize handle (default attivo).',
          items: const [
            DemoTile(
              width: 280,
              label: 'minHeight: 120',
              child: GenTextarea(placeholder: Text('Più alto…'), minHeight: 120),
            ),
            DemoTile(
              width: 280,
              label: 'maxHeight: 160',
              child: GenTextarea(placeholder: Text('Cresce fino a 160'), minHeight: 60, maxHeight: 160),
            ),
            DemoTile(
              width: 280,
              label: 'resizable: false',
              child: GenTextarea(placeholder: Text('Nessun handle di resize'), resizable: false),
            ),
          ],
        ),
        DemoGroup(
          title: 'Stati',
          description: 'disabilitato e sola lettura.',
          items: [
            const DemoTile(
              width: 280,
              label: 'enabled: false',
              child: GenTextarea(placeholder: Text('Disabilitato'), enabled: false),
            ),
            DemoTile(
              width: 280,
              label: 'readOnly',
              child: GenTextarea(controller: _readOnlyController, readOnly: true),
            ),
          ],
        ),
        DemoGroup(
          title: 'Vincoli e slot',
          description: 'maxLength e slot bottom per contatore/helper.',
          items: [
            const DemoTile(
              width: 280,
              label: 'maxLength: 120',
              child: GenTextarea(placeholder: Text('Max 120 caratteri'), maxLength: 120),
            ),
            DemoTile(
              width: 280,
              label: 'bottom (helper)',
              child: GenTextarea(
                placeholder: const Text('Bio'),
                minHeight: 90,
                bottom: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('Massimo 160 caratteri.', style: t.smallText),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
