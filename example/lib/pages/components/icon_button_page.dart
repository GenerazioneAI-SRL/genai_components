import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;
import '../../shared/demo_page.dart';

/// Showcase esaustiva di [GenIconButton] (= GenIconButton).
///
/// Icon-only button. Copre: 5 varianti (no link — non supportato), stati
/// enabled/disabled, iconSize, gradient+shadows, onLongPress, colori custom.
class IconButtonShowcase extends StatelessWidget {
  const IconButtonShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);

    return DemoPage(
      children: [
        // ---- VARIANTS ----
        DemoGroup(
          title: 'Variants',
          description: 'primary, secondary, outline, destructive, ghost. Il link non e supportato.',
          items: [
            DemoTile(label: 'primary', child: GenIconButton(icon: const Icon(LucideIcons.plus), onPressed: () {})),
            DemoTile(label: 'secondary', child: GenIconButton.secondary(icon: const Icon(LucideIcons.star), onPressed: () {})),
            DemoTile(label: 'outline', child: GenIconButton.outline(icon: const Icon(LucideIcons.settings), onPressed: () {})),
            DemoTile(label: 'destructive', child: GenIconButton.destructive(icon: const Icon(LucideIcons.trash2), onPressed: () {})),
            DemoTile(label: 'ghost', child: GenIconButton.ghost(icon: const Icon(LucideIcons.ellipsis), onPressed: () {})),
          ],
        ),

        // ---- VARIANTS via .raw ----
        DemoGroup(
          title: 'Variants (.raw)',
          description: 'GenIconButton.raw con variant esplicita (link vietato da assert).',
          items: [
            DemoTile(label: 'raw primary', child: GenIconButton.raw(variant: GenButtonVariant.primary, icon: const Icon(LucideIcons.check), onPressed: () {})),
            DemoTile(label: 'raw secondary', child: GenIconButton.raw(variant: GenButtonVariant.secondary, icon: const Icon(LucideIcons.heart), onPressed: () {})),
            DemoTile(label: 'raw outline', child: GenIconButton.raw(variant: GenButtonVariant.outline, icon: const Icon(LucideIcons.search), onPressed: () {})),
            DemoTile(label: 'raw destructive', child: GenIconButton.raw(variant: GenButtonVariant.destructive, icon: const Icon(LucideIcons.x), onPressed: () {})),
            DemoTile(label: 'raw ghost', child: GenIconButton.raw(variant: GenButtonVariant.ghost, icon: const Icon(LucideIcons.menu), onPressed: () {})),
          ],
        ),

        // ---- ICON SIZE ----
        DemoGroup(
          title: 'Icon size',
          description: 'iconSize controlla la dimensione del glifo interno.',
          items: [
            DemoTile(label: 'size 14', child: GenIconButton(iconSize: 14, icon: const Icon(LucideIcons.bell), onPressed: () {})),
            DemoTile(label: 'size 18', child: GenIconButton(iconSize: 18, icon: const Icon(LucideIcons.bell), onPressed: () {})),
            DemoTile(label: 'size 24', child: GenIconButton(iconSize: 24, icon: const Icon(LucideIcons.bell), onPressed: () {})),
          ],
        ),

        // ---- CUSTOM DIMENSIONS ----
        DemoGroup(
          title: 'Custom width / height',
          description: 'width & height espliciti per box quadrati custom.',
          items: [
            DemoTile(label: '32x32', child: GenIconButton.outline(width: 32, height: 32, iconSize: 16, icon: const Icon(LucideIcons.pencil), onPressed: () {})),
            DemoTile(label: '48x48', child: GenIconButton.outline(width: 48, height: 48, iconSize: 22, icon: const Icon(LucideIcons.pencil), onPressed: () {})),
          ],
        ),

        // ---- DISABLED ----
        DemoGroup(
          title: 'Disabled',
          description: 'enabled:false per ogni variante.',
          items: [
            DemoTile(label: 'primary', child: GenIconButton(enabled: false, icon: const Icon(LucideIcons.plus), onPressed: () {})),
            DemoTile(label: 'secondary', child: GenIconButton.secondary(enabled: false, icon: const Icon(LucideIcons.star), onPressed: () {})),
            DemoTile(label: 'outline', child: GenIconButton.outline(enabled: false, icon: const Icon(LucideIcons.settings), onPressed: () {})),
            DemoTile(label: 'destructive', child: GenIconButton.destructive(enabled: false, icon: const Icon(LucideIcons.trash2), onPressed: () {})),
            DemoTile(label: 'ghost', child: GenIconButton.ghost(enabled: false, icon: const Icon(LucideIcons.ellipsis), onPressed: () {})),
          ],
        ),

        // ---- GRADIENT + SHADOWS ----
        DemoGroup(
          title: 'Gradient + shadows',
          description: 'gradient (LinearGradient) + shadows (primaryGlow dai token).',
          items: [
            DemoTile(
              label: 'gradient',
              child: GenIconButton(
                onPressed: () {},
                gradient: LinearGradient(
                  colors: [t.primary, t.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shadows: t.primaryGlow,
                icon: const Icon(LucideIcons.sparkles),
              ),
            ),
            DemoTile(
              label: 'shadows only',
              child: GenIconButton(
                onPressed: () {},
                shadows: t.primaryGlow,
                icon: const Icon(LucideIcons.zap),
              ),
            ),
          ],
        ),

        // ---- CUSTOM COLORS ----
        DemoGroup(
          title: 'Custom colors',
          description: 'backgroundColor / foregroundColor espliciti.',
          items: [
            DemoTile(
              label: 'secondary bg',
              child: GenIconButton(
                backgroundColor: t.secondary,
                foregroundColor: t.primaryText,
                icon: const Icon(LucideIcons.palette),
                onPressed: () {},
              ),
            ),
          ],
        ),

        // ---- onLongPress ----
        DemoGroup(
          title: 'Long press',
          description: 'onLongPress attivo in aggiunta a onPressed.',
          items: [
            DemoTile(
              label: 'tap + long press',
              child: GenIconButton.outline(
                onPressed: () {},
                onLongPress: () {},
                icon: const Icon(LucideIcons.copy),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
