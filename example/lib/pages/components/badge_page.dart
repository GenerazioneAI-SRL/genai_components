import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;
import '../../shared/demo_page.dart';

/// Showcase esaustiva di [GenBadge] (= GenBadge).
///
/// Copre: 4 varianti, con icona (leading via Row nel child), shape custom,
/// onPressed (interattivo), padding e colori custom.
class BadgeShowcase extends StatelessWidget {
  const BadgeShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);

    return DemoPage(
      children: [
        // ---- VARIANTS ----
        DemoGroup(
          title: 'Variants',
          description: 'Le 4 varianti: primary, secondary, outline, destructive.',
          items: [
            const DemoTile(label: 'primary', child: GenBadge(child: Text('Primary'))),
            const DemoTile(label: 'secondary', child: GenBadge.secondary(child: Text('Secondary'))),
            const DemoTile(label: 'outline', child: GenBadge.outline(child: Text('Outline'))),
            const DemoTile(label: 'destructive', child: GenBadge.destructive(child: Text('Destructive'))),
          ],
        ),

        // ---- VARIANTS via .raw ----
        DemoGroup(
          title: 'Variants (.raw)',
          description: 'GenBadge.raw con variant esplicita (GenBadgeVariant).',
          items: [
            const DemoTile(label: 'raw primary', child: GenBadge.raw(variant: GenBadgeVariant.primary, child: Text('Raw'))),
            const DemoTile(label: 'raw secondary', child: GenBadge.raw(variant: GenBadgeVariant.secondary, child: Text('Raw'))),
            const DemoTile(label: 'raw outline', child: GenBadge.raw(variant: GenBadgeVariant.outline, child: Text('Raw'))),
            const DemoTile(label: 'raw destructive', child: GenBadge.raw(variant: GenBadgeVariant.destructive, child: Text('Raw'))),
          ],
        ),

        // ---- WITH ICON ----
        DemoGroup(
          title: 'With icon',
          description: 'Icona + testo via Row nel child.',
          items: [
            DemoTile(
              label: 'leading icon',
              child: GenBadge(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.check, size: 12),
                    SizedBox(width: t.gapSm / 2),
                    const Text('Verified'),
                  ],
                ),
              ),
            ),
            DemoTile(
              label: 'destructive icon',
              child: GenBadge.destructive(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.triangleAlert, size: 12),
                    SizedBox(width: t.gapSm / 2),
                    const Text('Error'),
                  ],
                ),
              ),
            ),
            DemoTile(
              label: 'trailing icon',
              child: GenBadge.secondary(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Tag'),
                    SizedBox(width: t.gapSm / 2),
                    const Icon(LucideIcons.x, size: 12),
                  ],
                ),
              ),
            ),
          ],
        ),

        // ---- INTERACTIVE ----
        DemoGroup(
          title: 'Interactive',
          description: 'onPressed rende il badge cliccabile (cursor click + hover bg).',
          items: [
            DemoTile(label: 'onPressed', child: GenBadge(onPressed: () {}, child: const Text('Clickable'))),
            DemoTile(label: 'outline onPressed', child: GenBadge.outline(onPressed: () {}, child: const Text('Filter'))),
          ],
        ),

        // ---- CUSTOM SHAPE ----
        DemoGroup(
          title: 'Custom shape',
          description: 'shape override: rettangolo arrotondato (default e StadiumBorder).',
          items: [
            DemoTile(
              label: 'rounded rect',
              child: GenBadge(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(t.radiusChip)),
                child: const Text('Rounded'),
              ),
            ),
            DemoTile(
              label: 'pill (default)',
              child: const GenBadge(child: Text('Pill')),
            ),
          ],
        ),

        // ---- CUSTOM COLORS + PADDING ----
        DemoGroup(
          title: 'Custom colors & padding',
          description: 'backgroundColor / foregroundColor / padding espliciti.',
          items: [
            DemoTile(
              label: 'custom bg',
              child: GenBadge(
                backgroundColor: t.secondary,
                foregroundColor: t.primaryText,
                child: const Text('Custom'),
              ),
            ),
            DemoTile(
              label: 'wide padding',
              child: GenBadge.outline(
                padding: EdgeInsets.symmetric(horizontal: t.gapLg, vertical: t.gapSm),
                child: const Text('Spacious'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
