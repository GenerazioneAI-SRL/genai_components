import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;

import '../../shared/demo_page.dart';

/// Showcase esaustiva di [GenToast] (= GenToast).
///
/// Il toast si mostra a runtime via `GenToaster.of(context).show(GenToast(...))`
/// (l'accessor GenToaster e' fornito da GenApp e non ha alias Gen). Ogni tile
/// e' un [GenButton] che apre un toast diverso in basso a destra (default).
class ToastShowcase extends StatelessWidget {
  const ToastShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      children: [
        DemoGroup(
          title: 'Contenuto',
          description: 'title, description e action sono tutti opzionali e '
              'combinabili.',
          items: [
            DemoTile(
              label: 'Solo description',
              child: GenButton.outline(
                onPressed: () => GenToaster.of(context).show(
                  const GenToast(
                    description: Text('Il tuo evento e stato creato.'),
                  ),
                ),
                child: const Text('Semplice'),
              ),
            ),
            DemoTile(
              label: 'Title + description',
              child: GenButton.outline(
                onPressed: () => GenToaster.of(context).show(
                  const GenToast(
                    title: Text('Programmato'),
                    description: Text('Venerdi 13 luglio alle 17:00.'),
                  ),
                ),
                child: const Text('Con titolo'),
              ),
            ),
            DemoTile(
              label: 'Con action',
              child: GenButton.outline(
                onPressed: () => GenToaster.of(context).show(
                  GenToast(
                    title: const Text('Evento creato'),
                    description: const Text('Venerdi 13 luglio alle 17:00.'),
                    action: GenButton.outline(
                      size: GenButtonSize.sm,
                      onPressed: () {},
                      child: const Text('Annulla'),
                    ),
                  ),
                ),
                child: const Text('Con azione'),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Varianti',
          description: 'GenToast() primary; GenToast.destructive() per errori.',
          items: [
            DemoTile(
              label: 'Primary',
              child: GenButton.outline(
                onPressed: () => GenToaster.of(context).show(
                  const GenToast(
                    title: Text('Salvato'),
                    description: Text('Modifiche applicate con successo.'),
                  ),
                ),
                child: const Text('Primary'),
              ),
            ),
            DemoTile(
              label: 'Destructive',
              child: GenButton.destructive(
                onPressed: () => GenToaster.of(context).show(
                  GenToast.destructive(
                    title: const Text('Errore'),
                    description: const Text('Impossibile salvare le modifiche.'),
                    action: GenButton.outline(
                      size: GenButtonSize.sm,
                      onPressed: () {},
                      child: const Text('Riprova'),
                    ),
                  ),
                ),
                child: const Text('Destructive'),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Durata',
          description: 'duration controlla per quanto resta visibile '
              '(default 5s).',
          items: [
            DemoTile(
              label: 'Breve (1s)',
              child: GenButton.outline(
                onPressed: () => GenToaster.of(context).show(
                  const GenToast(
                    description: Text('Sparisco dopo 1 secondo.'),
                    duration: Duration(seconds: 1),
                  ),
                ),
                child: const Text('1 secondo'),
              ),
            ),
            DemoTile(
              label: 'Lunga (10s)',
              child: GenButton.outline(
                onPressed: () => GenToaster.of(context).show(
                  const GenToast(
                    description: Text('Resto visibile 10 secondi.'),
                    duration: Duration(seconds: 10),
                  ),
                ),
                child: const Text('10 secondi'),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Posizione',
          description: 'alignment sposta il toast nell\'angolo/lato scelto.',
          items: [
            DemoTile(
              label: 'In alto a destra',
              child: GenButton.outline(
                onPressed: () => GenToaster.of(context).show(
                  const GenToast(
                    title: Text('Top-right'),
                    description: Text('Allineato in alto a destra.'),
                    alignment: Alignment.topRight,
                  ),
                ),
                child: const Text('Top-right'),
              ),
            ),
            DemoTile(
              label: 'In alto al centro',
              child: GenButton.outline(
                onPressed: () => GenToaster.of(context).show(
                  const GenToast(
                    title: Text('Top-center'),
                    description: Text('Allineato in alto al centro.'),
                    alignment: Alignment.topCenter,
                  ),
                ),
                child: const Text('Top-center'),
              ),
            ),
            DemoTile(
              label: 'In basso a sinistra',
              child: GenButton.outline(
                onPressed: () => GenToaster.of(context).show(
                  const GenToast(
                    title: Text('Bottom-left'),
                    description: Text('Allineato in basso a sinistra.'),
                    alignment: Alignment.bottomLeft,
                  ),
                ),
                child: const Text('Bottom-left'),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Close icon',
          description: 'showCloseIconOnlyWhenHovered=false rende la X sempre '
              'visibile; closeIconData la personalizza.',
          items: [
            DemoTile(
              label: 'X sempre visibile',
              child: GenButton.outline(
                onPressed: () => GenToaster.of(context).show(
                  const GenToast(
                    title: Text('Con chiusura'),
                    description: Text('La X e sempre mostrata.'),
                    showCloseIconOnlyWhenHovered: false,
                  ),
                ),
                child: const Text('Close sempre'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
