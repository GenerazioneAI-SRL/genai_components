import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;
import '../../shared/demo_page.dart';

/// Showcase esaustiva di [GenAvatar] (= GenAvatar).
///
/// Costruttore: `GenAvatar(src, {placeholder, size, shape, backgroundColor,
/// fit, package})`. `src` è dynamic (URL / asset path). Qui è tutto OFFLINE:
/// `src` vuoto → viene mostrato solo il [placeholder] (tipicamente le iniziali).
class AvatarShowcase extends StatelessWidget {
  const AvatarShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);

    // Helper: iniziali su sfondo colorato (demo offline, nessuna rete).
    Widget initials(String text, Color bg, {Size? size, ShapeBorder? shape}) {
      return GenAvatar(
        '',
        size: size,
        shape: shape,
        backgroundColor: bg,
        placeholder: Text(
          text,
          style: TextStyle(
            color: t.isDark ? Colors.black : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: (size?.width ?? 40) * 0.4,
          ),
        ),
      );
    }

    return DemoPage(
      children: [
        // ── Placeholder: iniziali ──────────────────────────────────────────
        DemoGroup(
          title: 'Placeholder (iniziali)',
          description:
              'src vuoto → mostra il widget placeholder. Uso tipico offline: '
              'iniziali dell\'utente centrate sullo sfondo.',
          items: [
            DemoTile(
              label: 'Iniziali testo',
              child: initials('DS', t.primary),
            ),
            DemoTile(
              label: 'Iniziali singola',
              child: initials('A', t.secondary),
            ),
            DemoTile(
              label: 'Icona come placeholder',
              child: GenAvatar(
                '',
                backgroundColor: t.muted,
                placeholder: Icon(
                  LucideIcons.user,
                  size: 20,
                  color: t.mutedForeground,
                ),
              ),
            ),
            DemoTile(
              label: 'Placeholder vuoto (default)',
              child: GenAvatar('', backgroundColor: t.muted),
            ),
          ],
        ),

        // ── Size ────────────────────────────────────────────────────────────
        DemoGroup(
          title: 'Size',
          description:
              'Il parametro size (Size) definisce width+height. Default 40x40 '
              'se non specificato.',
          items: [
            DemoTile(
              label: '24 x 24',
              child: initials('XS', t.primary, size: const Size.square(24)),
            ),
            DemoTile(
              label: '32 x 32',
              child: initials('SM', t.primary, size: const Size.square(32)),
            ),
            DemoTile(
              label: '40 x 40 (default)',
              child: initials('MD', t.primary, size: const Size.square(40)),
            ),
            DemoTile(
              label: '56 x 56',
              child: initials('LG', t.primary, size: const Size.square(56)),
            ),
            DemoTile(
              label: '80 x 80',
              child: initials('XL', t.primary, size: const Size.square(80)),
            ),
          ],
        ),

        // ── Shape ───────────────────────────────────────────────────────────
        DemoGroup(
          title: 'Shape',
          description:
              'Il parametro shape (ShapeBorder) sovrascrive la forma di default '
              '(CircleBorder). Si può usare RoundedRectangleBorder per un '
              'avatar quadrato/arrotondato.',
          items: [
            DemoTile(
              label: 'Circle (default)',
              child: initials(
                'CI',
                t.primary,
                size: const Size.square(56),
                shape: const CircleBorder(),
              ),
            ),
            DemoTile(
              label: 'Square',
              child: initials(
                'SQ',
                t.primary,
                size: const Size.square(56),
                shape: const RoundedRectangleBorder(),
              ),
            ),
            DemoTile(
              label: 'Rounded rect',
              child: initials(
                'RR',
                t.primary,
                size: const Size.square(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(t.radiusControl),
                ),
              ),
            ),
            DemoTile(
              label: 'Con bordo',
              child: initials(
                'BD',
                t.primary,
                size: const Size.square(56),
                shape: CircleBorder(
                  side: BorderSide(color: t.borderColor, width: 2),
                ),
              ),
            ),
          ],
        ),

        // ── Background color ────────────────────────────────────────────────
        DemoGroup(
          title: 'Background color',
          description:
              'backgroundColor dietro l\'immagine/placeholder. Default: muted.',
          items: [
            DemoTile(label: 'primary', child: initials('P', t.primary)),
            DemoTile(label: 'secondary', child: initials('S', t.secondary)),
            DemoTile(label: 'accent', child: initials('A', t.accent)),
            DemoTile(label: 'danger', child: initials('D', t.danger)),
            DemoTile(
              label: 'muted',
              child: GenAvatar(
                '',
                backgroundColor: t.muted,
                placeholder: Text(
                  'M',
                  style: TextStyle(
                    color: t.mutedForeground,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),

        // ── Gruppo affiancato / sovrapposto ────────────────────────────────
        DemoGroup(
          title: 'Gruppo di avatar',
          description:
              'Composizione: avatar affiancati (Row) o sovrapposti a stack '
              'tramite margini negativi + bordo per separazione.',
          items: [
            DemoTile(
              label: 'Affiancati',
              width: 220,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  initials('AB', t.primary, size: const Size.square(36)),
                  const SizedBox(width: 8),
                  initials('CD', t.secondary, size: const Size.square(36)),
                  const SizedBox(width: 8),
                  initials('EF', t.accent, size: const Size.square(36)),
                ],
              ),
            ),
            DemoTile(
              label: 'Sovrapposti (+3)',
              width: 220,
              child: SizedBox(
                height: 36,
                child: Stack(
                  children: [
                    for (var i = 0; i < 3; i++)
                      Padding(
                        padding: EdgeInsets.only(left: i * 24.0),
                        child: initials(
                          ['AB', 'CD', 'EF'][i],
                          [t.primary, t.secondary, t.accent][i],
                          size: const Size.square(36),
                          shape: CircleBorder(
                            side: BorderSide(
                              color: t.secondaryBackground,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(left: 72),
                      child: GenAvatar(
                        '',
                        size: const Size.square(36),
                        backgroundColor: t.muted,
                        shape: CircleBorder(
                          side: BorderSide(
                            color: t.secondaryBackground,
                            width: 2,
                          ),
                        ),
                        placeholder: Text(
                          '+3',
                          style: TextStyle(
                            color: t.mutedForeground,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
