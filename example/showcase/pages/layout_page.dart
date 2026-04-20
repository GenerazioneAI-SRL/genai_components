import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import '../widgets/showcase_section.dart';

class LayoutPage extends StatelessWidget {
  const LayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseScaffold(
      title: 'Layout',
      description: 'Card (4 varianti), Divider, Accordion, Section.',
      children: [
        ShowcaseSection(
          title: 'GenaiCard — varianti',
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: 240,
                child: GenaiCard.outlined(
                  child: _cardContent(context, 'Outlined'),
                ),
              ),
              SizedBox(
                width: 240,
                child: GenaiCard.elevated(
                  child: _cardContent(context, 'Elevated'),
                ),
              ),
              SizedBox(
                width: 240,
                child: GenaiCard.filled(
                  child: _cardContent(context, 'Filled'),
                ),
              ),
              SizedBox(
                width: 240,
                child: GenaiCard.interactive(
                  onTap: () {},
                  child: _cardContent(context, 'Interactive'),
                ),
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiCard — header & footer',
          child: SizedBox(
            width: 380,
            child: GenaiCard.outlined(
              header: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(LucideIcons.user, color: context.colors.colorPrimary),
                    const SizedBox(width: 8),
                    Text('Profilo', style: context.typography.headingSm.copyWith(color: context.colors.textPrimary)),
                    const Spacer(),
                    GenaiBadge.text(text: 'Pro'),
                  ],
                ),
              ),
              footer: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GenaiButton.ghost(label: 'Annulla', onPressed: () {}),
                    const SizedBox(width: 8),
                    GenaiButton.primary(label: 'Salva', onPressed: () {}),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Modifica le informazioni del tuo profilo. Sono visibili agli altri membri del team.',
                    style: context.typography.bodyMd.copyWith(color: context.colors.textSecondary)),
              ),
            ),
          ),
        ),
        ShowcaseSection(
          title: 'GenaiDivider',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const GenaiDivider(),
              const SizedBox(height: 16),
              const GenaiDivider(label: 'oppure'),
              const SizedBox(height: 16),
              SizedBox(
                height: 60,
                child: Row(
                  children: [
                    Text('Sinistra', style: context.typography.bodyMd.copyWith(color: context.colors.textPrimary)),
                    const SizedBox(width: 16),
                    const GenaiDivider.vertical(),
                    const SizedBox(width: 16),
                    Text('Destra', style: context.typography.bodyMd.copyWith(color: context.colors.textPrimary)),
                  ],
                ),
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiAccordion',
          child: GenaiAccordion(
            allowMultiple: true,
            items: [
              GenaiAccordionItem(
                title: 'Domande generali',
                subtitle: 'Tutto quello che devi sapere',
                leadingIcon: LucideIcons.circleQuestionMark,
                initiallyExpanded: true,
                content: Text(
                    'Genai Components è una libreria di componenti UI per Flutter, basata su token semantici e pensata per applicazioni gestionali italiane.',
                    style: context.typography.bodyMd.copyWith(color: context.colors.textSecondary)),
              ),
              GenaiAccordionItem(
                title: 'Installazione',
                leadingIcon: LucideIcons.download,
                content: Text('Aggiungi `genai_components` al tuo pubspec.yaml.',
                    style: context.typography.bodyMd.copyWith(color: context.colors.textSecondary)),
              ),
              GenaiAccordionItem(
                title: 'Personalizzazione tema',
                leadingIcon: LucideIcons.palette,
                content: Text('Sostituisci i token tramite GenaiTheme.light(...) e GenaiTheme.dark(...).',
                    style: context.typography.bodyMd.copyWith(color: context.colors.textSecondary)),
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiSection',
          child: GenaiSection(
            title: 'Notifiche',
            description: 'Gestisci come vuoi essere avvisato.',
            trailing: GenaiLinkButton(label: 'Configura', onPressed: () {}),
            child: GenaiCard.outlined(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    GenaiToggle(
                      value: true,
                      label: 'Email',
                      description: 'Riepilogo giornaliero',
                      onChanged: (_) {},
                    ),
                    GenaiToggle(
                      value: false,
                      label: 'SMS',
                      description: 'Solo per allerte critiche',
                      onChanged: (_) {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _cardContent(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: context.typography.headingSm.copyWith(color: context.colors.textPrimary)),
          const SizedBox(height: 6),
          Text('Contenuto card di esempio', style: context.typography.bodySm.copyWith(color: context.colors.textSecondary)),
        ],
      ),
    );
  }
}
