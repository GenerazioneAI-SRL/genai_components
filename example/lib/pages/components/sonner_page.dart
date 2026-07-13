import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;

import '../../shared/demo_page.dart';

/// Showcase esaustiva di [GenSonner] (= GenSonner).
///
/// A differenza del toaster, il sonner impila piu notifiche (stack collassato
/// che si espande in hover). Si mostra via `GenSonner.of(context).show(GenToast(...))`
/// (l'accessor GenSonner e' fornito da GenApp e non ha alias Gen). La posizione
/// dello stack e' definita dall'ancestor GenSonner; l'`alignment` del singolo
/// GenToast ne guida l'animazione d'ingresso.
class SonnerShowcase extends StatelessWidget {
  const SonnerShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      children: [
        DemoGroup(
          title: 'Base',
          description: 'Notifica singola impilata dal sonner.',
          items: [
            DemoTile(
              label: 'Default',
              child: GenButton.outline(
                onPressed: () => GenSonner.of(context).show(
                  const GenToast(
                    title: Text('Evento creato'),
                    description: Text('Venerdi 13 luglio alle 17:00.'),
                  ),
                ),
                child: const Text('Mostra'),
              ),
            ),
            DemoTile(
              label: 'Solo description',
              child: GenButton.outline(
                onPressed: () => GenSonner.of(context).show(
                  const GenToast(
                    description: Text('Impostazioni salvate.'),
                  ),
                ),
                child: const Text('Semplice'),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Con azione',
          description: 'action mostra un bottone dentro la notifica.',
          items: [
            DemoTile(
              label: 'Con Annulla',
              child: GenButton.outline(
                onPressed: () => GenSonner.of(context).show(
                  GenToast(
                    title: const Text('File eliminato'),
                    description: const Text('report.pdf spostato nel cestino.'),
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
          description: 'Anche il sonner supporta la variante destructive.',
          items: [
            DemoTile(
              label: 'Destructive',
              child: GenButton.destructive(
                onPressed: () => GenSonner.of(context).show(
                  const GenToast.destructive(
                    title: Text('Sincronizzazione fallita'),
                    description: Text('Controlla la connessione e riprova.'),
                  ),
                ),
                child: const Text('Errore'),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Multipli (stack)',
          description: 'Piu show consecutivi si impilano; passa il puntatore '
              'sopra per espandere lo stack.',
          items: [
            DemoTile(
              label: 'Tre notifiche',
              child: GenButton.outline(
                onPressed: () {
                  final sonner = GenSonner.of(context);
                  for (var i = 1; i <= 3; i++) {
                    sonner.show(
                      GenToast(
                        title: Text('Notifica $i'),
                        description: Text('Messaggio numero $i dello stack.'),
                      ),
                    );
                  }
                },
                child: const Text('Impila x3'),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Durata',
          description: 'duration regola la permanenza della singola notifica '
              '(default 5s). In hover il timer e\' in pausa.',
          items: [
            DemoTile(
              label: 'Breve (1.5s)',
              child: GenButton.outline(
                onPressed: () => GenSonner.of(context).show(
                  const GenToast(
                    description: Text('Sparisco dopo 1.5 secondi.'),
                    duration: Duration(milliseconds: 1500),
                  ),
                ),
                child: const Text('1.5 secondi'),
              ),
            ),
            DemoTile(
              label: 'Lunga (10s)',
              child: GenButton.outline(
                onPressed: () => GenSonner.of(context).show(
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
      ],
    );
  }
}
