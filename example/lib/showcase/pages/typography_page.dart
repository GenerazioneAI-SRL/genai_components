import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import '../widgets/showcase_section.dart';

class TypographyPage extends StatelessWidget {
  const TypographyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ty = context.typography;
    final colors = context.colors;

    const sample = 'The quick brown fox jumps over the lazy dog';

    final rows = <(String, TextStyle)>[
      ('pageTitle · 22/600', ty.pageTitle),
      ('sectionTitle · 15/600', ty.sectionTitle),
      ('cardTitle · 14/600', ty.cardTitle),
      ('focusTitle · 20/600', ty.focusTitle),
      ('kpiNumber · 28/600 tabular', ty.kpiNumber),
      ('body · 14/400', ty.body),
      ('bodySm · 13/400', ty.bodySm),
      ('label · 12/500', ty.label),
      ('labelSm · 11.5/500', ty.labelSm),
      ('tiny · 11/500 tracked', ty.tiny),
      ('monoMd · 13/500', ty.monoMd),
      ('monoSm · 11/400', ty.monoSm),
    ];

    return ShowcaseScaffold(
      title: 'Typography',
      description:
          'Geist sans + Geist Mono. Numeri tabulari dove serve (kpi, mono).',
      children: [
        ShowcaseSection(
          title: 'Scale',
          child: GenaiCard.outlined(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final r in rows) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: context.spacing.s8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 220,
                          child: Text(
                            r.$1,
                            style: ty.labelSm.copyWith(
                              color: colors.textTertiary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            sample,
                            style: r.$2.copyWith(color: colors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (r != rows.last) const GenaiDivider(),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
