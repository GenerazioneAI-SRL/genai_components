import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;
import '../../shared/demo_page.dart';

/// Showcase esaustiva di [GenButton] (= GenButton).
///
/// Copre: 6 varianti, size (sm/regular/lg), leading/trailing/icon-only,
/// stati (enabled/disabled), width full, gradient+shadows, onLongPress,
/// mainAxisAlignment con width fissa.
class ButtonShowcase extends StatelessWidget {
  const ButtonShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);

    return DemoPage(
      children: [
        // ---- VARIANTS ----
        DemoGroup(
          title: 'Variants',
          description: 'Le 6 varianti: primary, secondary, outline, destructive, ghost, link.',
          items: [
            DemoTile(label: 'primary', child: GenButton(onPressed: () {}, child: const Text('Primary'))),
            DemoTile(label: 'secondary', child: GenButton.secondary(onPressed: () {}, child: const Text('Secondary'))),
            DemoTile(label: 'outline', child: GenButton.outline(onPressed: () {}, child: const Text('Outline'))),
            DemoTile(label: 'destructive', child: GenButton.destructive(onPressed: () {}, child: const Text('Destructive'))),
            DemoTile(label: 'ghost', child: GenButton.ghost(onPressed: () {}, child: const Text('Ghost'))),
            DemoTile(label: 'link', child: GenButton.link(onPressed: () {}, child: const Text('Link'))),
          ],
        ),

        // ---- VARIANTS via .raw ----
        DemoGroup(
          title: 'Variants (.raw)',
          description: 'GenButton.raw con variant esplicita (GenButtonVariant).',
          items: [
            DemoTile(label: 'raw primary', child: GenButton.raw(variant: GenButtonVariant.primary, onPressed: () {}, child: const Text('Raw'))),
            DemoTile(label: 'raw secondary', child: GenButton.raw(variant: GenButtonVariant.secondary, onPressed: () {}, child: const Text('Raw'))),
            DemoTile(label: 'raw outline', child: GenButton.raw(variant: GenButtonVariant.outline, onPressed: () {}, child: const Text('Raw'))),
            DemoTile(label: 'raw destructive', child: GenButton.raw(variant: GenButtonVariant.destructive, onPressed: () {}, child: const Text('Raw'))),
            DemoTile(label: 'raw ghost', child: GenButton.raw(variant: GenButtonVariant.ghost, onPressed: () {}, child: const Text('Raw'))),
            DemoTile(label: 'raw link', child: GenButton.raw(variant: GenButtonVariant.link, onPressed: () {}, child: const Text('Raw'))),
          ],
        ),

        // ---- SIZES ----
        DemoGroup(
          title: 'Sizes',
          description: 'GenButtonSize: sm, regular (default), lg.',
          items: [
            DemoTile(label: 'sm', child: GenButton(size: GenButtonSize.sm, onPressed: () {}, child: const Text('Small'))),
            DemoTile(label: 'regular', child: GenButton(size: GenButtonSize.regular, onPressed: () {}, child: const Text('Regular'))),
            DemoTile(label: 'lg', child: GenButton(size: GenButtonSize.lg, onPressed: () {}, child: const Text('Large'))),
          ],
        ),

        // ---- LEADING ICON ----
        DemoGroup(
          title: 'Leading icon',
          description: 'Icona prima del testo (leading).',
          items: [
            DemoTile(label: 'primary', child: GenButton(leading: const GenIcon(LucideIcons.plus), onPressed: () {}, child: const Text('Add'))),
            DemoTile(label: 'secondary', child: GenButton.secondary(leading: const GenIcon(LucideIcons.download), onPressed: () {}, child: const Text('Download'))),
            DemoTile(label: 'outline', child: GenButton.outline(leading: const GenIcon(LucideIcons.settings), onPressed: () {}, child: const Text('Settings'))),
            DemoTile(label: 'destructive', child: GenButton.destructive(leading: const GenIcon(LucideIcons.trash2), onPressed: () {}, child: const Text('Delete'))),
          ],
        ),

        // ---- TRAILING ICON ----
        DemoGroup(
          title: 'Trailing icon',
          description: 'Icona dopo il testo (trailing).',
          items: [
            DemoTile(label: 'primary', child: GenButton(trailing: const GenIcon(LucideIcons.arrowRight), onPressed: () {}, child: const Text('Next'))),
            DemoTile(label: 'ghost', child: GenButton.ghost(trailing: const GenIcon(LucideIcons.chevronDown), onPressed: () {}, child: const Text('More'))),
            DemoTile(label: 'link', child: GenButton.link(trailing: const GenIcon(LucideIcons.externalLink), onPressed: () {}, child: const Text('Open'))),
          ],
        ),

        // ---- LEADING + TRAILING ----
        DemoGroup(
          title: 'Leading + trailing',
          description: 'Icona su entrambi i lati del testo.',
          items: [
            DemoTile(
              label: 'both',
              child: GenButton(
                leading: const GenIcon(LucideIcons.creditCard),
                trailing: const GenIcon(LucideIcons.arrowRight),
                onPressed: () {},
                child: const Text('Pay now'),
              ),
            ),
            DemoTile(
              label: 'both outline',
              child: GenButton.outline(
                leading: const GenIcon(LucideIcons.calendar),
                trailing: const GenIcon(LucideIcons.chevronDown),
                onPressed: () {},
                child: const Text('Pick date'),
              ),
            ),
          ],
        ),

        // ---- ICON ONLY (via child) ----
        DemoGroup(
          title: 'Icon only',
          description: 'Solo icona come child (per icon-only dedicato usa GenIconButton).',
          items: [
            DemoTile(label: 'primary', child: GenButton(onPressed: () {}, child: const GenIcon(LucideIcons.check))),
            DemoTile(label: 'secondary', child: GenButton.secondary(onPressed: () {}, child: const GenIcon(LucideIcons.star))),
            DemoTile(label: 'ghost', child: GenButton.ghost(onPressed: () {}, child: const GenIcon(LucideIcons.ellipsis))),
          ],
        ),

        // ---- DISABLED (enabled:false) ----
        DemoGroup(
          title: 'Disabled',
          description: 'enabled:false — dimmed e non interattivo, per ogni variante.',
          items: [
            DemoTile(label: 'primary', child: GenButton(enabled: false, onPressed: () {}, child: const Text('Primary'))),
            DemoTile(label: 'secondary', child: GenButton.secondary(enabled: false, onPressed: () {}, child: const Text('Secondary'))),
            DemoTile(label: 'outline', child: GenButton.outline(enabled: false, onPressed: () {}, child: const Text('Outline'))),
            DemoTile(label: 'destructive', child: GenButton.destructive(enabled: false, onPressed: () {}, child: const Text('Destructive'))),
            DemoTile(label: 'ghost', child: GenButton.ghost(enabled: false, onPressed: () {}, child: const Text('Ghost'))),
            DemoTile(label: 'link', child: GenButton.link(enabled: false, onPressed: () {}, child: const Text('Link'))),
          ],
        ),

        // ---- WIDTH FULL ----
        DemoGroup(
          title: 'Full width',
          description: 'width: double.infinity dentro un box a larghezza piena.',
          items: [
            DemoTile(
              label: 'primary full',
              width: 320,
              child: GenButton(width: double.infinity, onPressed: () {}, child: const Text('Full width')),
            ),
            DemoTile(
              label: 'outline full',
              width: 320,
              child: GenButton.outline(width: double.infinity, onPressed: () {}, child: const Text('Full width outline')),
            ),
          ],
        ),

        // ---- GRADIENT + SHADOWS ----
        DemoGroup(
          title: 'Gradient + shadows',
          description: 'gradient (LinearGradient) + shadows (primaryGlow dai token).',
          items: [
            DemoTile(
              label: 'gradient',
              child: GenButton(
                onPressed: () {},
                gradient: LinearGradient(
                  colors: [t.primary, t.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shadows: t.primaryGlow,
                leading: const GenIcon(LucideIcons.sparkles),
                child: const Text('Generate'),
              ),
            ),
            DemoTile(
              label: 'shadows only',
              child: GenButton(
                onPressed: () {},
                shadows: t.primaryGlow,
                child: const Text('Glow'),
              ),
            ),
          ],
        ),

        // ---- onLongPress ----
        DemoGroup(
          title: 'Long press',
          description: 'onLongPress attivo (in aggiunta a onPressed).',
          items: [
            DemoTile(
              label: 'tap + long press',
              child: GenButton(
                onPressed: () {},
                onLongPress: () {},
                child: const Text('Hold me'),
              ),
            ),
          ],
        ),

        // ---- mainAxisAlignment (width fissa) ----
        DemoGroup(
          title: 'mainAxisAlignment',
          description: 'Con width fissa: allineamento del contenuto nella Row interna.',
          items: [
            DemoTile(
              label: 'spaceBetween',
              width: 260,
              child: GenButton(
                width: 240,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                leading: const GenIcon(LucideIcons.folder),
                trailing: const GenIcon(LucideIcons.chevronRight),
                onPressed: () {},
                child: const Text('Documents'),
              ),
            ),
            DemoTile(
              label: 'start',
              width: 260,
              child: GenButton.outline(
                width: 240,
                mainAxisAlignment: MainAxisAlignment.start,
                leading: const GenIcon(LucideIcons.user),
                onPressed: () {},
                child: const Text('Profile'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
