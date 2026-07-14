import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;
import '../../shared/demo_page.dart';

/// Showcase esaustiva di [GenCard] (= GenCard).
///
/// Copre: title/description/child/footer, footer con azioni (bottoni),
/// padding custom, leading/trailing, width/height, radius/border/shadows,
/// backgroundColor, allineamenti di riga/colonna.
class CardShowcase extends StatelessWidget {
  const CardShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);

    return DemoPage(
      children: [
        // ---- BASE ----
        DemoGroup(
          title: 'Base',
          description: 'title + description. Blocchi header standard della card.',
          items: [
            const DemoTile(
              label: 'title + description',
              width: 420,
              child: GenCard(
                title: Text('Notifiche'),
                description: Text('Gestisci come ricevi gli avvisi.'),
              ),
            ),
            const DemoTile(
              label: 'solo title',
              width: 420,
              child: GenCard(title: Text('Solo titolo')),
            ),
          ],
        ),

        // ---- CON CHILD ----
        DemoGroup(
          title: 'Con contenuto (child)',
          description: 'child sotto la description: il corpo principale della card.',
          items: [
            DemoTile(
              label: 'title + description + child',
              width: 420,
              child: GenCard(
                title: const Text('Account'),
                description: const Text('Aggiorna i dati del profilo.'),
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Nome, email e preferenze sono sincronizzati su tutti i dispositivi collegati.',
                    style: t.bodyText,
                  ),
                ),
              ),
            ),
          ],
        ),

        // ---- FOOTER CON AZIONI ----
        DemoGroup(
          title: 'Footer con azioni',
          description: 'footer con bottoni (Row di GenButton) in fondo alla card.',
          items: [
            DemoTile(
              label: 'cancel + confirm',
              width: 420,
              child: GenCard(
                title: const Text('Elimina progetto'),
                description: const Text('Questa azione è irreversibile.'),
                footer: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GenButton.ghost(onPressed: () {}, child: const Text('Annulla')),
                      const SizedBox(width: 8),
                      GenButton.destructive(onPressed: () {}, child: const Text('Elimina')),
                    ],
                  ),
                ),
              ),
            ),
            DemoTile(
              label: 'full-width action',
              width: 420,
              child: GenCard(
                title: const Text('Piano Pro'),
                description: const Text('Sblocca tutte le funzionalità.'),
                footer: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: GenButton(
                    width: double.infinity,
                    leading: const Icon(LucideIcons.sparkles),
                    onPressed: () {},
                    child: const Text('Passa a Pro'),
                  ),
                ),
              ),
            ),
          ],
        ),

        // ---- CARD COMPLETA ----
        DemoGroup(
          title: 'Card completa',
          description: 'title + description + child + footer insieme.',
          items: [
            DemoTile(
              label: 'tutti gli slot',
              width: 420,
              child: GenCard(
                title: const Text('Crea team'),
                description: const Text('Invita i tuoi collaboratori.'),
                footer: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GenButton.outline(onPressed: () {}, child: const Text('Indietro')),
                      const SizedBox(width: 8),
                      GenButton(onPressed: () {}, child: const Text('Crea')),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text('Il team avrà accesso condiviso a progetti e risorse.', style: t.bodyText),
                ),
              ),
            ),
          ],
        ),

        // ---- LEADING / TRAILING ----
        DemoGroup(
          title: 'Leading / trailing',
          description: 'Widget ai lati della colonna centrale (icona o azione).',
          items: [
            DemoTile(
              label: 'leading icon',
              width: 420,
              child: GenCard(
                leading: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(LucideIcons.bell, color: t.primary),
                ),
                title: const Text('Avvisi attivi'),
                description: const Text('Riceverai notifiche push.'),
              ),
            ),
            DemoTile(
              label: 'trailing action',
              width: 420,
              child: GenCard(
                title: const Text('Impostazioni'),
                description: const Text('Configura il tuo spazio.'),
                trailing: GenButton.ghost(onPressed: () {}, child: const Icon(LucideIcons.ellipsisVertical)),
              ),
            ),
          ],
        ),

        // ---- PADDING ----
        DemoGroup(
          title: 'Padding',
          description: 'padding custom (default EdgeInsets.all(24)).',
          items: [
            const DemoTile(
              label: 'padding 12',
              width: 420,
              child: GenCard(
                padding: EdgeInsets.all(12),
                title: Text('Compatta'),
                description: Text('padding: EdgeInsets.all(12).'),
              ),
            ),
            const DemoTile(
              label: 'padding 40',
              width: 420,
              child: GenCard(
                padding: EdgeInsets.all(40),
                title: Text('Ariosa'),
                description: Text('padding: EdgeInsets.all(40).'),
              ),
            ),
          ],
        ),

        // ---- STILE ----
        DemoGroup(
          title: 'Stile',
          description: 'backgroundColor, radius, border, shadows.',
          items: [
            DemoTile(
              label: 'background muted',
              width: 420,
              child: GenCard(
                backgroundColor: t.muted,
                title: const Text('Superficie muted'),
                description: const Text('backgroundColor dai token.'),
              ),
            ),
            DemoTile(
              label: 'radius + shadows',
              width: 420,
              child: GenCard(
                radius: BorderRadius.circular(20),
                shadows: t.primaryGlow,
                title: const Text('Elevata'),
                description: const Text('radius 20 + primaryGlow.'),
              ),
            ),
          ],
        ),

        // ---- DIMENSIONI ----
        DemoGroup(
          title: 'Dimensioni',
          description: 'width/height espliciti sulla card.',
          items: [
            const DemoTile(
              label: 'width 200 x height 140',
              width: 420,
              child: GenCard(
                width: 200,
                height: 140,
                title: Text('Fissa'),
                description: Text('200 x 140.'),
              ),
            ),
          ],
        ),

        // ---- ALLINEAMENTI ----
        DemoGroup(
          title: 'Allineamenti',
          description: 'columnCrossAxisAlignment / rowMainAxisAlignment.',
          items: [
            const DemoTile(
              label: 'colonna centrata',
              width: 420,
              child: GenCard(
                columnCrossAxisAlignment: CrossAxisAlignment.center,
                title: Text('Centrata'),
                description: Text('columnCrossAxisAlignment.center.'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
