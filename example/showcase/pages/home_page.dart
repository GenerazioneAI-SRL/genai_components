import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import '../widgets/showcase_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseScaffold(
      title: 'Genai Components',
      description:
          'Showcase del nuovo design system. Naviga le sezioni dalla sidebar per esplorare token, foundations e ogni componente — varianti, dimensioni, stati e supporto light/dark.',
      children: [
        ShowcaseSection(
          title: 'Inizio rapido',
          child: GenaiCard.outlined(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Prossimi passi', style: context.typography.headingSm.copyWith(color: context.colors.textPrimary)),
                  const SizedBox(height: 12),
                  _Bullet(text: '1. Apri Foundations per tokens & responsive'),
                  _Bullet(text: '2. Esplora Componenti per varianti & stati'),
                  _Bullet(text: '3. Usa l\'icona luna in alto a destra per il tema'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      GenaiButton.primary(label: 'Apri Foundations', icon: LucideIcons.palette, onPressed: () {}),
                      GenaiButton.secondary(label: 'Documentazione', icon: LucideIcons.bookOpen, onPressed: () {}),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        ShowcaseSection(
          title: 'Stato',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              GenaiKPICard(
                label: 'Componenti',
                value: '70+',
                icon: LucideIcons.boxes,
                footnote: 'Atomic & complessi',
              ),
              GenaiKPICard(
                label: 'Tokens',
                value: '120+',
                icon: LucideIcons.palette,
                footnote: 'Light & dark',
              ),
              GenaiKPICard(
                label: 'Locale',
                value: 'IT',
                icon: LucideIcons.languages,
                footnote: 'Decimali con virgola',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(text, style: context.typography.bodyMd.copyWith(color: context.colors.textPrimary)),
    );
  }
}
