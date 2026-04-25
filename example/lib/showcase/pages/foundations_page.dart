import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import '../widgets/showcase_section.dart';

class FoundationsPage extends StatelessWidget {
  const FoundationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseScaffold(
      title: 'Foundations',
      description:
          'Color tokens, spacing scale, radius — ricavati dal Dashboard v3.',
      children: const [_ColorSwatches(), _SpacingScale(), _RadiusScale()],
    );
  }
}

class _ColorSwatches extends StatelessWidget {
  const _ColorSwatches();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final groups = <String, List<(String, Color)>>{
      'Surfaces': [
        ('surfacePage', c.surfacePage),
        ('surfaceCard', c.surfaceCard),
        ('surfaceHover', c.surfaceHover),
        ('surfaceInverse', c.surfaceInverse),
      ],
      'Text': [
        ('textPrimary', c.textPrimary),
        ('textSecondary', c.textSecondary),
        ('textTertiary', c.textTertiary),
        ('textLink', c.textLink),
      ],
      'Borders': [
        ('borderSubtle', c.borderSubtle),
        ('borderDefault', c.borderDefault),
        ('borderStrong', c.borderStrong),
        ('borderFocus', c.borderFocus),
      ],
      'Primary (ink)': [
        ('colorPrimary', c.colorPrimary),
        ('colorPrimaryHover', c.colorPrimaryHover),
        ('colorPrimarySubtle', c.colorPrimarySubtle),
      ],
      'Semantic — base': [
        ('colorSuccess', c.colorSuccess),
        ('colorWarning', c.colorWarning),
        ('colorDanger', c.colorDanger),
        ('colorInfo', c.colorInfo),
        ('colorNeutral', c.colorNeutral),
      ],
      'Semantic — soft': [
        ('colorSuccessSubtle', c.colorSuccessSubtle),
        ('colorWarningSubtle', c.colorWarningSubtle),
        ('colorDangerSubtle', c.colorDangerSubtle),
        ('colorInfoSubtle', c.colorInfoSubtle),
        ('colorNeutralSubtle', c.colorNeutralSubtle),
      ],
    };
    return ShowcaseSection(
      title: 'Color tokens',
      subtitle: 'Forma LMS palette verbatim dal reference HTML.',
      child: Column(
        children: [
          for (final g in groups.entries)
            Padding(
              padding: EdgeInsets.only(bottom: context.spacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: context.spacing.s8),
                    child: Text(
                      g.key,
                      style: context.typography.labelSm.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: context.spacing.s10,
                    runSpacing: context.spacing.s10,
                    children: [
                      for (final s in g.value) _Swatch(name: s.$1, color: s.$2),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  final String name;
  final Color color;
  const _Swatch({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(context.radius.md),
              border: Border.all(color: context.colors.borderSubtle),
            ),
          ),
          SizedBox(height: context.spacing.s4),
          Text(
            name,
            style: context.typography.labelSm.copyWith(
              color: context.colors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
            style: context.typography.monoSm.copyWith(
              color: context.colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpacingScale extends StatelessWidget {
  const _SpacingScale();

  @override
  Widget build(BuildContext context) {
    final steps = <(String, double)>[
      ('s2', 2),
      ('s4', 4),
      ('s6', 6),
      ('s8', 8),
      ('s10', 10),
      ('s12', 12),
      ('s14', 14),
      ('s16', 16),
      ('s20', 20),
      ('s24', 24),
      ('s28', 28),
      ('s32', 32),
      ('s48', 48),
      ('s64', 64),
    ];
    return ShowcaseSection(
      title: 'Spacing scale',
      subtitle: 'Base 4 con stop 14/18/28 per parità HTML.',
      child: GenaiCard.outlined(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final s in steps)
              Padding(
                padding: EdgeInsets.symmetric(vertical: context.spacing.s4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        s.$1,
                        style: context.typography.monoSm.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ),
                    Container(
                      width: s.$2,
                      height: 10,
                      color: context.colors.colorPrimary,
                    ),
                    SizedBox(width: context.spacing.s12),
                    Text(
                      '${s.$2.toInt()}px',
                      style: context.typography.labelSm.copyWith(
                        color: context.colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RadiusScale extends StatelessWidget {
  const _RadiusScale();

  @override
  Widget build(BuildContext context) {
    final r = context.radius;
    final steps = <(String, double)>[
      ('xs', r.xs),
      ('sm', r.sm),
      ('md', r.md),
      ('lg', r.lg),
      ('xl', r.xl),
      ('pill', r.pill),
    ];
    return ShowcaseSection(
      title: 'Radius scale',
      child: Wrap(
        spacing: context.spacing.s12,
        runSpacing: context.spacing.s12,
        children: [
          for (final s in steps)
            SizedBox(
              width: 120,
              child: Column(
                children: [
                  Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: context.colors.colorPrimarySubtle,
                      borderRadius: BorderRadius.circular(
                        s.$2.clamp(0, 32).toDouble(),
                      ),
                      border: Border.all(color: context.colors.borderDefault),
                    ),
                  ),
                  SizedBox(height: context.spacing.s4),
                  Text(
                    '${s.$1} · ${s.$2.toStringAsFixed(0)}',
                    style: context.typography.labelSm.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
