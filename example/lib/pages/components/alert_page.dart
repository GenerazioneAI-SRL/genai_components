import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;

import '../../shared/demo_page.dart';

/// Showcase esaustiva di [GenAlert] (= GenAlert).
///
/// Copre le due varianti (primary default + `.destructive`), la presenza/assenza
/// dell'icona, e le combinazioni title / description. Ogni tile e' largo 380 per
/// dare all'alert un respiro realistico.
class AlertShowcase extends StatelessWidget {
  const AlertShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return const DemoPage(
      children: [
        DemoGroup(
          title: 'Variante',
          description: 'primary (default) e destructive: colori bordo/testo/icona dal tema.',
          items: [
            DemoTile(
              label: 'Primary (default)',
              width: 380,
              child: GenAlert(
                icon: GenIcon(LucideIcons.info),
                title: Text('Aggiornamento disponibile'),
                description: Text('Una nuova versione dei componenti e\' pronta da installare.'),
              ),
            ),
            DemoTile(
              label: 'Destructive (.destructive)',
              width: 380,
              child: GenAlert.destructive(
                icon: GenIcon(LucideIcons.circleAlert),
                title: Text('Errore di salvataggio'),
                description: Text('Impossibile salvare le modifiche. Riprova piu\' tardi.'),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Con e senza icona',
          description: 'icon: GenIcon(...) opzionale. Senza icona il testo occupa tutta la riga.',
          items: [
            DemoTile(
              label: 'Con icona',
              width: 380,
              child: GenAlert(
                icon: GenIcon(LucideIcons.rocket),
                title: Text('Deploy completato'),
                description: Text('Il rilascio in produzione e\' andato a buon fine.'),
              ),
            ),
            DemoTile(
              label: 'Senza icona',
              width: 380,
              child: GenAlert(
                title: Text('Nota'),
                description: Text('Nessuna icona: l\'alert resta compatto e allineato a sinistra.'),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Contenuto',
          description: 'title da solo, title + description, description da sola.',
          items: [
            DemoTile(
              label: 'Solo title',
              width: 380,
              child: GenAlert(
                icon: GenIcon(LucideIcons.check),
                title: Text('Operazione completata'),
              ),
            ),
            DemoTile(
              label: 'title + description',
              width: 380,
              child: GenAlert(
                icon: GenIcon(LucideIcons.bell),
                title: Text('Promemoria'),
                description: Text('La sessione scade tra 5 minuti. Salva il lavoro in corso.'),
              ),
            ),
            DemoTile(
              label: 'Solo description',
              width: 380,
              child: GenAlert(
                icon: GenIcon(LucideIcons.messageSquare),
                description: Text('Testo informativo senza titolo, utile per note inline discrete.'),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Destructive · varianti contenuto',
          description: 'La variante destructive con le stesse combinazioni di contenuto.',
          items: [
            DemoTile(
              label: 'Solo title',
              width: 380,
              child: GenAlert.destructive(
                icon: GenIcon(LucideIcons.triangleAlert),
                title: Text('Azione irreversibile'),
              ),
            ),
            DemoTile(
              label: 'title + description',
              width: 380,
              child: GenAlert.destructive(
                icon: GenIcon(LucideIcons.trash2),
                title: Text('Eliminazione account'),
                description: Text('Tutti i dati verranno rimossi definitivamente e non recuperabili.'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
