import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;

import '../../shared/demo_page.dart';

/// Showcase esaustiva di [GenContextMenu] (= GenContextMenu) + [GenContextMenuItem].
///
/// Il menu contestuale si apre avvolgendo un widget in [GenContextMenuRegion]
/// (unico accessor senza alias Gen) e passando `items:` di [GenContextMenuItem].
///
/// Nota: le region qui hanno `tapEnabled: true` così un click sinistro apre il
/// menu su desktop; di default su desktop serve il click destro / secondario.
class ContextMenuShowcase extends StatelessWidget {
  const ContextMenuShowcase({super.key});

  /// Riquadro tratteggiato che fa da bersaglio del click.
  Widget _target(BuildContext context, String label) {
    final t = GenTokens.of(context);
    return Container(
      width: 220,
      height: 90,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: t.secondaryText.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.mousePointerClick, size: 15, color: t.secondaryText),
          const SizedBox(width: 8),
          Text(label, style: t.smallText.copyWith(color: t.secondaryText)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      children: [
        DemoGroup(
          title: 'Base',
          description: 'Region con item semplici. onPressed chiude il menu e '
              'lancia la callback.',
          items: [
            DemoTile(
              label: 'Item semplici',
              child: GenContextMenuRegion(
                tapEnabled: true,
                items: [
                  GenContextMenuItem(onPressed: () {}, child: const Text('Indietro')),
                  GenContextMenuItem(
                    enabled: false,
                    onPressed: () {},
                    child: const Text('Avanti'),
                  ),
                  GenContextMenuItem(onPressed: () {}, child: const Text('Ricarica')),
                ],
                child: _target(context, 'Apri menu'),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Leading / Trailing / Shortcut',
          description: 'leading = icona a sinistra, trailing = widget a destra '
              '(scorciatoia con stile muted automatico).',
          items: [
            DemoTile(
              label: 'Icone + scorciatoie',
              child: GenContextMenuRegion(
                tapEnabled: true,
                items: [
                  GenContextMenuItem(
                    leading: const Icon(LucideIcons.scissors, size: 16),
                    trailing: const Text('Ctrl+X'),
                    onPressed: () {},
                    child: const Text('Taglia'),
                  ),
                  GenContextMenuItem(
                    leading: const Icon(LucideIcons.copy, size: 16),
                    trailing: const Text('Ctrl+C'),
                    onPressed: () {},
                    child: const Text('Copia'),
                  ),
                  GenContextMenuItem(
                    leading: const Icon(LucideIcons.clipboardPaste, size: 16),
                    trailing: const Text('Ctrl+V'),
                    onPressed: () {},
                    child: const Text('Incolla'),
                  ),
                ],
                child: _target(context, 'Modifica'),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Sottomenu',
          description: 'Un item con `items:` non vuoto diventa un sottomenu '
              '(freccia trailing automatica, apertura su hover).',
          items: [
            DemoTile(
              label: 'Submenu annidato',
              child: GenContextMenuRegion(
                tapEnabled: true,
                items: [
                  GenContextMenuItem(
                    leading: const Icon(LucideIcons.plus, size: 16),
                    onPressed: () {},
                    child: const Text('Nuovo file'),
                  ),
                  GenContextMenuItem(
                    leading: const Icon(LucideIcons.share2, size: 16),
                    items: [
                      GenContextMenuItem(onPressed: () {}, child: const Text('Email')),
                      GenContextMenuItem(onPressed: () {}, child: const Text('Messaggio')),
                      GenContextMenuItem(
                        items: [
                          GenContextMenuItem(onPressed: () {}, child: const Text('Copia link')),
                          GenContextMenuItem(onPressed: () {}, child: const Text('QR code')),
                        ],
                        child: const Text('Altro'),
                      ),
                    ],
                    child: const Text('Condividi'),
                  ),
                ],
                child: _target(context, 'Con sottomenu'),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Inset',
          description: 'GenContextMenuItem.inset allinea il testo alla colonna '
              'delle icone anche senza leading (mix con item leading).',
          items: [
            DemoTile(
              label: 'Variante inset',
              child: GenContextMenuRegion(
                tapEnabled: true,
                items: [
                  GenContextMenuItem(
                    leading: const Icon(LucideIcons.check, size: 16),
                    onPressed: () {},
                    child: const Text('Barra di stato'),
                  ),
                  GenContextMenuItem.inset(
                    onPressed: () {},
                    child: const Text('Barra laterale'),
                  ),
                  GenContextMenuItem.inset(
                    onPressed: () {},
                    child: const Text('Barra attivita'),
                  ),
                ],
                child: _target(context, 'Vista'),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Stato e colori',
          description: 'enabled=false disabilita l\'item; '
              'selectedBackgroundColor personalizza l\'evidenziazione.',
          items: [
            DemoTile(
              label: 'Disabled + colore selezione',
              child: Builder(
                builder: (context) {
                  final t = GenTokens.of(context);
                  return GenContextMenuRegion(
                    tapEnabled: true,
                    items: [
                      GenContextMenuItem(
                        leading: const Icon(LucideIcons.star, size: 16),
                        selectedBackgroundColor: t.primary.withValues(alpha: 0.15),
                        onPressed: () {},
                        child: const Text('Preferito'),
                      ),
                      GenContextMenuItem(
                        leading: const Icon(LucideIcons.lock, size: 16),
                        enabled: false,
                        onPressed: () {},
                        child: const Text('Bloccato (disabled)'),
                      ),
                      GenContextMenuItem(
                        leading: Icon(LucideIcons.trash2, size: 16, color: t.danger),
                        selectedBackgroundColor: t.danger.withValues(alpha: 0.15),
                        onPressed: () {},
                        child: Text('Elimina', style: TextStyle(color: t.danger)),
                      ),
                    ],
                    child: _target(context, 'Azioni'),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
