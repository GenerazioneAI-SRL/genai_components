import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import '../widgets/showcase_section.dart';

class LayoutPage extends StatelessWidget {
  const LayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    return ShowcaseScaffold(
      title: 'Layout',
      description:
          'Card (4 varianti), Divider, Section, AspectRatio, Accordion, '
          'Collapsible.',
      children: [
        ShowcaseSection(
          title: 'Card variants',
          subtitle: 'Outlined (default) / elevated / filled / interactive.',
          child: Wrap(
            spacing: context.spacing.s14,
            runSpacing: context.spacing.s14,
            children: [
              SizedBox(
                width: 260,
                child: GenaiCard.outlined(
                  headerTitle: 'Outlined',
                  headerSubtitle: 'Flat + hairline',
                  child: Text(
                    'Default card in v3.',
                    style: ty.bodySm.copyWith(color: colors.textSecondary),
                  ),
                ),
              ),
              SizedBox(
                width: 260,
                child: GenaiCard.elevated(
                  headerTitle: 'Elevated',
                  headerSubtitle: 'Same as outlined in v3',
                  child: Text(
                    'API parity.',
                    style: ty.bodySm.copyWith(color: colors.textSecondary),
                  ),
                ),
              ),
              SizedBox(
                width: 260,
                child: GenaiCard.filled(
                  headerTitle: 'Filled',
                  headerSubtitle: 'Neutral-soft bg',
                  child: Text(
                    'No border.',
                    style: ty.bodySm.copyWith(color: colors.textSecondary),
                  ),
                ),
              ),
              SizedBox(
                width: 260,
                child: GenaiCard.interactive(
                  headerTitle: 'Interactive',
                  headerSubtitle: 'Cliccabile, hover',
                  semanticLabel: 'Card interattiva',
                  onTap: () {},
                  child: Text(
                    'Tappami!',
                    style: ty.bodySm.copyWith(color: colors.textLink),
                  ),
                ),
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Divider',
          subtitle: 'Con e senza etichetta.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              GenaiDivider(),
              SizedBox(height: 16),
              GenaiDivider(label: 'OPPURE'),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Section',
          subtitle: 'Heading + trailing action + bottom divider.',
          child: GenaiCard.outlined(
            child: GenaiSection(
              title: 'Piani formativi',
              description: '3 piani · 24 moduli · 65% completato',
              trailing: GenaiLinkButton(label: 'Vedi tutti', onPressed: () {}),
              divider: true,
              child: Text(
                'Contenuto di sezione.',
                style: ty.bodySm.copyWith(color: colors.textSecondary),
              ),
            ),
          ),
        ),
        ShowcaseSection(
          title: 'Aspect ratio',
          subtitle: 'Placeholder 16:9 / 4:3 / 1:1.',
          child: Row(
            children: [
              SizedBox(
                width: 200,
                child: GenaiAspectRatio(ratio: 16 / 9, bordered: true),
              ),
              SizedBox(width: context.spacing.s12),
              SizedBox(
                width: 200,
                child: GenaiAspectRatio(ratio: 4 / 3, bordered: true),
              ),
              SizedBox(width: context.spacing.s12),
              SizedBox(
                width: 120,
                child: GenaiAspectRatio(ratio: 1, bordered: true),
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Accordion',
          subtitle: 'Multi-open di default; impostare singleOpen per tab.',
          child: GenaiCard.outlined(
            padding: EdgeInsets.zero,
            useHeaderSlot: false,
            child: GenaiAccordion(
              items: [
                GenaiAccordionItem(
                  id: '1',
                  title: 'Quali corsi sono obbligatori?',
                  body: Text(
                    'Sicurezza sul lavoro, Privacy 2026 e Antiriciclaggio.',
                    style: ty.bodySm.copyWith(color: colors.textSecondary),
                  ),
                ),
                GenaiAccordionItem(
                  id: '2',
                  title: 'Come ottengo il certificato?',
                  body: Text(
                    'Completa tutti i moduli e supera il quiz finale.',
                    style: ty.bodySm.copyWith(color: colors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
        ShowcaseSection(
          title: 'Collapsible',
          subtitle: 'Singolo blocco espandibile.',
          child: GenaiCollapsible(
            title: 'Dettagli scadenza',
            bordered: true,
            body: Text(
              'La formazione obbligatoria scade il 31/12/2026. Completa '
              'almeno 24 ore entro quella data.',
              style: ty.bodySm.copyWith(color: colors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }
}
