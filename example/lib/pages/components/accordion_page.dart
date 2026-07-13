import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;
import '../../shared/demo_page.dart';

/// Showcase esaustiva di [GenAccordion] / [GenAccordionItem]
/// (= GenAccordion / GenAccordionItem).
///
/// Copre: single (default) + multiple, initialValue, iconData custom,
/// separator custom, padding, underlineTitleOnHover, maintainState.
class AccordionShowcase extends StatelessWidget {
  const AccordionShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);

    Widget body(String text) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(text, style: t.bodyText),
        );

    return DemoPage(
      children: [
        // ---- SINGLE (default) ----
        DemoGroup(
          title: 'Single (default)',
          description: 'Costruttore default: un solo item aperto per volta (children:).',
          items: [
            DemoTile(
              label: 'single',
              width: 420,
              child: GenAccordion<String>(
                children: [
                  GenAccordionItem<String>(
                    value: 'a',
                    title: const Text('È accessibile?'),
                    child: body('Sì. Segue le linee guida WAI-ARIA per i widget disclosure.'),
                  ),
                  GenAccordionItem<String>(
                    value: 'b',
                    title: const Text('È stilizzabile?'),
                    child: body('Sì. Eredita i token dal tema Gen come ogni altro componente.'),
                  ),
                  GenAccordionItem<String>(
                    value: 'c',
                    title: const Text('È animato?'),
                    child: body('Sì. Apertura e chiusura hanno animazione fluida di default.'),
                  ),
                ],
              ),
            ),
          ],
        ),

        // ---- SINGLE + initialValue ----
        DemoGroup(
          title: 'Single + initialValue',
          description: 'initialValue apre un item alla creazione.',
          items: [
            DemoTile(
              label: 'initialValue: b',
              width: 420,
              child: GenAccordion<String>(
                initialValue: 'b',
                children: [
                  GenAccordionItem<String>(
                    value: 'a',
                    title: const Text('Generale'),
                    child: body('Impostazioni generali del profilo.'),
                  ),
                  GenAccordionItem<String>(
                    value: 'b',
                    title: const Text('Sicurezza (aperto)'),
                    child: body('Password, 2FA e sessioni attive.'),
                  ),
                  GenAccordionItem<String>(
                    value: 'c',
                    title: const Text('Fatturazione'),
                    child: body('Metodo di pagamento e storico.'),
                  ),
                ],
              ),
            ),
          ],
        ),

        // ---- MULTIPLE ----
        DemoGroup(
          title: 'Multiple',
          description: 'GenAccordion.multiple: più item aperti insieme.',
          items: [
            DemoTile(
              label: 'multiple + initialValue',
              width: 420,
              child: GenAccordion<String>.multiple(
                initialValue: const ['a', 'c'],
                children: [
                  GenAccordionItem<String>(
                    value: 'a',
                    title: const Text('Spedizione (aperto)'),
                    child: body('Consegna in 2-4 giorni lavorativi.'),
                  ),
                  GenAccordionItem<String>(
                    value: 'b',
                    title: const Text('Resi'),
                    child: body('Reso gratuito entro 30 giorni.'),
                  ),
                  GenAccordionItem<String>(
                    value: 'c',
                    title: const Text('Garanzia (aperto)'),
                    child: body('Garanzia legale di 24 mesi.'),
                  ),
                ],
              ),
            ),
          ],
        ),

        // ---- ICONA CUSTOM ----
        DemoGroup(
          title: 'Icona custom',
          description: 'iconData: sostituisce la chevron di default (ruota in apertura).',
          items: [
            DemoTile(
              label: 'iconData plus',
              width: 420,
              child: GenAccordion<String>(
                children: [
                  GenAccordionItem<String>(
                    value: 'a',
                    iconData: LucideIcons.plus,
                    title: const Text('Aggiungi dettagli'),
                    child: body('Icona plus al posto della chevron.'),
                  ),
                  GenAccordionItem<String>(
                    value: 'b',
                    iconData: LucideIcons.chevronRight,
                    title: const Text('Espandi sezione'),
                    child: body('Icona chevronRight personalizzata.'),
                  ),
                ],
              ),
            ),
          ],
        ),

        // ---- SEPARATOR + PADDING ----
        DemoGroup(
          title: 'Separator e padding',
          description: 'separator custom e padding dell header per item.',
          items: [
            DemoTile(
              label: 'separator colorato + padding',
              width: 420,
              child: GenAccordion<String>(
                children: [
                  GenAccordionItem<String>(
                    value: 'a',
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    separator: GenSeparator.horizontal(thickness: 2, color: t.primary),
                    title: const Text('Header più alto'),
                    child: body('padding verticale 20 + separator spesso 2.'),
                  ),
                  GenAccordionItem<String>(
                    value: 'b',
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    separator: GenSeparator.horizontal(thickness: 2, color: t.primary),
                    title: const Text('Secondo item'),
                    child: body('Stesso stile applicato.'),
                  ),
                ],
              ),
            ),
          ],
        ),

        // ---- OPZIONI ----
        DemoGroup(
          title: 'Opzioni',
          description: 'underlineTitleOnHover:false e maintainState:true.',
          items: [
            DemoTile(
              label: 'no underline + maintainState',
              width: 420,
              child: GenAccordion<String>(
                maintainState: true,
                children: [
                  GenAccordionItem<String>(
                    value: 'a',
                    underlineTitleOnHover: false,
                    title: const Text('Titolo senza underline'),
                    child: body('underlineTitleOnHover:false; contenuto mantenuto in tree.'),
                  ),
                  GenAccordionItem<String>(
                    value: 'b',
                    underlineTitleOnHover: false,
                    title: const Text('Altro item'),
                    child: body('maintainState:true a livello di accordion.'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
