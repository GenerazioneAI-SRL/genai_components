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
          'Token semantici, scale spaziali, tipografia, raggi, ombre e dimensioni — tutti accessibili tramite extension `context.colors`, `context.spacing`, `context.typography`, `context.radius`, `context.elevation`.',
      children: [
        ShowcaseSection(
          title: 'Colori — Brand & semantici',
          subtitle: 'Token primary + success/warning/error/info con varianti subtle e hover.',
          child: _ColorGrid(swatches: _brandSwatches(context)),
        ),
        ShowcaseSection(
          title: 'Colori — Surface & border',
          child: _ColorGrid(swatches: _surfaceSwatches(context)),
        ),
        ShowcaseSection(
          title: 'Colori — Testo',
          child: _ColorGrid(swatches: _textSwatches(context)),
        ),
        ShowcaseSection(
          title: 'Tipografia',
          subtitle: 'Inter (UI) + JetBrains Mono (code).',
          child: const _TypographyShowcase(),
        ),
        ShowcaseSection(
          title: 'Spacing — scala 4px',
          child: const _SpacingShowcase(),
        ),
        ShowcaseSection(
          title: 'Radius',
          child: const _RadiusShowcase(),
        ),
        ShowcaseSection(
          title: 'Elevation',
          subtitle: '6 livelli (0..5) — ombre in light, overlay opacity in dark.',
          child: const _ElevationShowcase(),
        ),
      ],
    );
  }

  List<_Swatch> _brandSwatches(BuildContext c) {
    final col = c.colors;
    return [
      _Swatch('colorPrimary', col.colorPrimary),
      _Swatch('colorPrimaryHover', col.colorPrimaryHover),
      _Swatch('colorPrimaryPressed', col.colorPrimaryPressed),
      _Swatch('colorPrimarySubtle', col.colorPrimarySubtle),
      _Swatch('colorSuccess', col.colorSuccess),
      _Swatch('colorSuccessSubtle', col.colorSuccessSubtle),
      _Swatch('colorWarning', col.colorWarning),
      _Swatch('colorWarningSubtle', col.colorWarningSubtle),
      _Swatch('colorError', col.colorError),
      _Swatch('colorErrorSubtle', col.colorErrorSubtle),
      _Swatch('colorInfo', col.colorInfo),
      _Swatch('colorInfoSubtle', col.colorInfoSubtle),
    ];
  }

  List<_Swatch> _surfaceSwatches(BuildContext c) {
    final col = c.colors;
    return [
      _Swatch('surfacePage', col.surfacePage),
      _Swatch('surfaceCard', col.surfaceCard),
      _Swatch('surfaceInput', col.surfaceInput),
      _Swatch('surfaceOverlay', col.surfaceOverlay),
      _Swatch('surfaceSidebar', col.surfaceSidebar),
      _Swatch('surfaceHover', col.surfaceHover),
      _Swatch('surfacePressed', col.surfacePressed),
      _Swatch('borderDefault', col.borderDefault),
      _Swatch('borderStrong', col.borderStrong),
      _Swatch('borderFocus', col.borderFocus),
      _Swatch('borderError', col.borderError),
      _Swatch('borderSuccess', col.borderSuccess),
    ];
  }

  List<_Swatch> _textSwatches(BuildContext c) {
    final col = c.colors;
    return [
      _Swatch('textPrimary', col.textPrimary),
      _Swatch('textSecondary', col.textSecondary),
      _Swatch('textDisabled', col.textDisabled),
      _Swatch('textOnPrimary', col.textOnPrimary),
      _Swatch('textLink', col.textLink),
    ];
  }
}

class _Swatch {
  final String name;
  final Color color;
  const _Swatch(this.name, this.color);
}

class _ColorGrid extends StatelessWidget {
  final List<_Swatch> swatches;
  const _ColorGrid({required this.swatches});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final s in swatches)
          SizedBox(
            width: 200,
            child: GenaiCard.outlined(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: s.color,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: context.colors.borderDefault),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(s.name,
                            style: context.typography.label.copyWith(
                              color: context.colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            )),
                        Text(_hex(s.color), style: context.typography.code.copyWith(color: context.colors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _hex(Color c) {
    final v = c.toARGB32() & 0xFFFFFF;
    return '#${v.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}

class _TypographyShowcase extends StatelessWidget {
  const _TypographyShowcase();

  @override
  Widget build(BuildContext context) {
    final ty = context.typography;
    final col = context.colors.textPrimary;
    final samples = <(String, TextStyle)>[
      ('displayLg', ty.displayLg),
      ('displaySm', ty.displaySm),
      ('headingLg', ty.headingLg),
      ('headingSm', ty.headingSm),
      ('bodyLg', ty.bodyLg),
      ('bodyMd', ty.bodyMd),
      ('bodySm', ty.bodySm),
      ('label', ty.label),
      ('labelSm', ty.labelSm),
      ('caption', ty.caption),
      ('code', ty.code),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final s in samples)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                SizedBox(
                  width: 110,
                  child: Text(s.$1, style: ty.caption.copyWith(color: context.colors.textSecondary)),
                ),
                Expanded(
                  child: Text('Aa Bb Cc — Sphinx of black quartz, 1234,56', style: s.$2.copyWith(color: col)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SpacingShowcase extends StatelessWidget {
  const _SpacingShowcase();

  @override
  Widget build(BuildContext context) {
    final spec = context.spacing;
    final values = <(String, double)>[
      ('s1', spec.s1),
      ('s2', spec.s2),
      ('s3', spec.s3),
      ('s4', spec.s4),
      ('s5', spec.s5),
      ('s6', spec.s6),
      ('s8', spec.s8),
      ('s10', spec.s10),
      ('s12', spec.s12),
      ('s16', spec.s16),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final v in values)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(v.$1, style: context.typography.label.copyWith(color: context.colors.textSecondary)),
                ),
                Container(
                  width: v.$2,
                  height: 16,
                  color: context.colors.colorPrimary,
                ),
                const SizedBox(width: 8),
                Text('${v.$2.toStringAsFixed(0)} px', style: context.typography.code.copyWith(color: context.colors.textSecondary)),
              ],
            ),
          ),
      ],
    );
  }
}

class _RadiusShowcase extends StatelessWidget {
  const _RadiusShowcase();

  @override
  Widget build(BuildContext context) {
    final r = context.radius;
    final values = <(String, double)>[
      ('xs', r.xs),
      ('sm', r.sm),
      ('md', r.md),
      ('lg', r.lg),
      ('xl', r.xl),
      ('pill', r.pill),
    ];
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        for (final v in values)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: context.colors.colorPrimarySubtle,
                  border: Border.all(color: context.colors.colorPrimary),
                  borderRadius: BorderRadius.circular(v.$2),
                ),
              ),
              const SizedBox(height: 6),
              Text('${v.$1} · ${v.$2.toStringAsFixed(0)}px', style: context.typography.caption.copyWith(color: context.colors.textSecondary)),
            ],
          ),
      ],
    );
  }
}

class _ElevationShowcase extends StatelessWidget {
  const _ElevationShowcase();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 24,
      children: [
        for (var i = 0; i < 6; i++)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 80,
                decoration: BoxDecoration(
                  color: context.colors.surfaceCard,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: context.elevation.shadow(i),
                ),
                alignment: Alignment.center,
                child: Text('lvl $i', style: context.typography.label.copyWith(color: context.colors.textPrimary)),
              ),
            ],
          ),
      ],
    );
  }
}
