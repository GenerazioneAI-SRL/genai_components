import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;
import '../../shared/demo_page.dart';

/// Showcase esaustiva di [GenBreadcrumb] (= GenBreadcrumb) + [GenBreadcrumbLink]
/// (= GenBreadcrumbLink), con [GenBreadcrumbSeparator], [GenBreadcrumbEllipsis]
/// e [GenBreadcrumbDropdown].
///
/// Copre: percorso base con separatori, link con icona, ellipsis statico,
/// dropdown per percorsi lunghi, separatore custom (chevron/slash),
/// spacing, textStyle, lastItemTextColor, colori normal/hover del link.
class BreadcrumbShowcase extends StatelessWidget {
  const BreadcrumbShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);

    return DemoPage(
      children: [
        // ---- BASE ----
        DemoGroup(
          title: 'Base',
          description:
              'Percorso Home / Sezione / Pagina. GenBreadcrumbLink cliccabili + separatore chevron di default; ultimo item come Text (pagina corrente).',
          items: [
            DemoTile(
              label: 'Home / Sezione / Pagina',
              width: 520,
              child: GenBreadcrumb(
                children: [
                  GenBreadcrumbLink(onPressed: () {}, child: const Text('Home')),
                  GenBreadcrumbLink(onPressed: () {}, child: const Text('Sezione')),
                  const Text('Pagina'),
                ],
              ),
            ),
          ],
        ),

        // ---- CON ICONE ----
        DemoGroup(
          title: 'Link con icona',
          description:
              'GenIcon dentro il child del link (icona + testo in una Row).',
          items: [
            DemoTile(
              label: 'icona + testo',
              width: 520,
              child: GenBreadcrumb(
                children: [
                  GenBreadcrumbLink(
                    onPressed: () {},
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GenIcon(LucideIcons.house, size: 14),
                        SizedBox(width: 6),
                        Text('Home'),
                      ],
                    ),
                  ),
                  GenBreadcrumbLink(
                    onPressed: () {},
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GenIcon(LucideIcons.folder, size: 14),
                        SizedBox(width: 6),
                        Text('Progetti'),
                      ],
                    ),
                  ),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GenIcon(LucideIcons.file, size: 14),
                      SizedBox(width: 6),
                      Text('README'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        // ---- ELLIPSIS STATICO ----
        DemoGroup(
          title: 'Ellipsis (percorso troncato)',
          description:
              'GenBreadcrumbEllipsis: indicatore "…" per livelli nascosti in un percorso lungo. size personalizzabile.',
          items: [
            DemoTile(
              label: 'Home / … / Pagina',
              width: 520,
              child: GenBreadcrumb(
                children: [
                  GenBreadcrumbLink(onPressed: () {}, child: const Text('Home')),
                  const GenBreadcrumbEllipsis(),
                  GenBreadcrumbLink(onPressed: () {}, child: const Text('Documenti')),
                  const Text('Pagina'),
                ],
              ),
            ),
            const DemoTile(
              label: 'ellipsis size 20',
              width: 520,
              child: GenBreadcrumb(
                children: [
                  Text('Root'),
                  GenBreadcrumbEllipsis(size: 20),
                  Text('Foglia'),
                ],
              ),
            ),
          ],
        ),

        // ---- DROPDOWN ----
        DemoGroup(
          title: 'Dropdown (livelli collassati)',
          description:
              'GenBreadcrumbDropdown: trigger (di solito ellipsis) che apre un popover con i livelli nascosti (GenBreadcrumbDropMenuItem).',
          items: [
            DemoTile(
              label: 'Home / [▾] / Pagina',
              width: 520,
              child: GenBreadcrumb(
                children: [
                  GenBreadcrumbLink(onPressed: () {}, child: const Text('Home')),
                  GenBreadcrumbDropdown(
                    items: [
                      GenBreadcrumbDropMenuItem(
                        onPressed: () {},
                        child: const Text('Documenti'),
                      ),
                      GenBreadcrumbDropMenuItem(
                        onPressed: () {},
                        child: const Text('Progetti'),
                      ),
                      GenBreadcrumbDropMenuItem(
                        onPressed: () {},
                        child: const Text('Archivio'),
                      ),
                    ],
                    child: const GenBreadcrumbEllipsis(),
                  ),
                  const Text('Pagina'),
                ],
              ),
            ),
            DemoTile(
              label: 'trigger testuale, senza freccia',
              width: 520,
              child: GenBreadcrumb(
                children: [
                  GenBreadcrumbLink(onPressed: () {}, child: const Text('Home')),
                  GenBreadcrumbDropdown(
                    showDropdownArrow: false,
                    items: [
                      GenBreadcrumbDropMenuItem(
                        onPressed: () {},
                        child: const Text('Sotto-cartella A'),
                      ),
                      GenBreadcrumbDropMenuItem(
                        onPressed: () {},
                        child: const Text('Sotto-cartella B'),
                      ),
                    ],
                    child: const Text('Altro'),
                  ),
                  const Text('Dettaglio'),
                ],
              ),
            ),
          ],
        ),

        // ---- SEPARATORE CUSTOM ----
        DemoGroup(
          title: 'Separatore custom',
          description:
              'separator: sovrascrive il chevron di default. Slash o chevron via GenIcon, oppure GenBreadcrumbSeparator con size/color.',
          items: [
            DemoTile(
              label: 'slash /',
              width: 520,
              child: GenBreadcrumb(
                separator: const GenIcon(LucideIcons.slash, size: 14),
                children: [
                  GenBreadcrumbLink(onPressed: () {}, child: const Text('Home')),
                  GenBreadcrumbLink(onPressed: () {}, child: const Text('Sezione')),
                  const Text('Pagina'),
                ],
              ),
            ),
            DemoTile(
              label: 'chevron custom (colore primary, size 18)',
              width: 520,
              child: GenBreadcrumb(
                separator: GenIcon(LucideIcons.chevronRight, size: 18, color: t.primary),
                children: [
                  GenBreadcrumbLink(onPressed: () {}, child: const Text('Home')),
                  GenBreadcrumbLink(onPressed: () {}, child: const Text('Sezione')),
                  const Text('Pagina'),
                ],
              ),
            ),
            DemoTile(
              label: 'GenBreadcrumbSeparator personalizzato',
              width: 520,
              child: GenBreadcrumb(
                separator: GenBreadcrumbSeparator(size: 16, color: t.primary),
                children: [
                  GenBreadcrumbLink(onPressed: () {}, child: const Text('Livello 1')),
                  GenBreadcrumbLink(onPressed: () {}, child: const Text('Livello 2')),
                  const Text('Livello 3'),
                ],
              ),
            ),
          ],
        ),

        // ---- SPACING ----
        DemoGroup(
          title: 'Spacing',
          description: 'spacing: distanza tra item e separatore (default 10).',
          items: [
            DemoTile(
              label: 'spacing 4 (compatto)',
              width: 520,
              child: GenBreadcrumb(
                spacing: 4,
                children: [
                  GenBreadcrumbLink(onPressed: () {}, child: const Text('Home')),
                  GenBreadcrumbLink(onPressed: () {}, child: const Text('Sezione')),
                  const Text('Pagina'),
                ],
              ),
            ),
            DemoTile(
              label: 'spacing 20 (arioso)',
              width: 520,
              child: GenBreadcrumb(
                spacing: 20,
                children: [
                  GenBreadcrumbLink(onPressed: () {}, child: const Text('Home')),
                  GenBreadcrumbLink(onPressed: () {}, child: const Text('Sezione')),
                  const Text('Pagina'),
                ],
              ),
            ),
          ],
        ),

        // ---- STILE TESTO ----
        DemoGroup(
          title: 'Stile testo',
          description:
              'textStyle sull\'intero breadcrumb, lastItemTextColor per la pagina corrente, e colori normal/hover del singolo link.',
          items: [
            DemoTile(
              label: 'textStyle + lastItemTextColor',
              width: 520,
              child: GenBreadcrumb(
                textStyle: t.smallText.copyWith(fontWeight: FontWeight.w600),
                lastItemTextColor: t.primary,
                children: [
                  GenBreadcrumbLink(onPressed: () {}, child: const Text('Home')),
                  GenBreadcrumbLink(onPressed: () {}, child: const Text('Sezione')),
                  const Text('Corrente'),
                ],
              ),
            ),
            DemoTile(
              label: 'link normalColor / hoverColor',
              width: 520,
              child: GenBreadcrumb(
                children: [
                  GenBreadcrumbLink(
                    onPressed: () {},
                    normalColor: t.secondaryText,
                    hoverColor: t.primary,
                    child: const Text('Passa il mouse'),
                  ),
                  const Text('qui'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
