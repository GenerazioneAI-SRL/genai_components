import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;

import '../../shared/demo_page.dart';

/// Showcase esaustiva di [GenMenubar] (= GenMenubar) + [GenMenubarItem].
///
/// La barra allinea in riga piu [GenMenubarItem]; ciascuno apre un menu i cui
/// item sono [GenContextMenuItem]. Passa il puntatore da un item all'altro:
/// con selectOnHover (default) il menu segue l'hover una volta aperta la barra.
class MenubarShowcase extends StatelessWidget {
  const MenubarShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      children: [
        DemoGroup(
          title: 'Barra completa',
          description: 'Piu item ciascuno con il proprio menu, scorciatoie, '
              'submenu e item disabilitati.',
          items: [
            DemoTile(
              label: 'File / Modifica / Vista',
              child: GenMenubar(
                items: [
                  GenMenubarItem(
                    items: [
                      GenContextMenuItem(
                        trailing: const Text('Ctrl+T'),
                        onPressed: () {},
                        child: const Text('Nuova scheda'),
                      ),
                      GenContextMenuItem(
                        trailing: const Text('Ctrl+N'),
                        onPressed: () {},
                        child: const Text('Nuova finestra'),
                      ),
                      GenContextMenuItem(
                        enabled: false,
                        onPressed: () {},
                        child: const Text('Nuova incognito'),
                      ),
                      GenContextMenuItem(
                        items: [
                          GenContextMenuItem(onPressed: () {}, child: const Text('Email')),
                          GenContextMenuItem(onPressed: () {}, child: const Text('Messaggio')),
                          GenContextMenuItem(onPressed: () {}, child: const Text('Note')),
                        ],
                        child: const Text('Condividi'),
                      ),
                      GenContextMenuItem(
                        trailing: const Text('Ctrl+P'),
                        onPressed: () {},
                        child: const Text('Stampa...'),
                      ),
                    ],
                    child: const Text('File'),
                  ),
                  GenMenubarItem(
                    items: [
                      GenContextMenuItem(
                        trailing: const Text('Ctrl+Z'),
                        onPressed: () {},
                        child: const Text('Annulla'),
                      ),
                      GenContextMenuItem(
                        trailing: const Text('Ctrl+Y'),
                        onPressed: () {},
                        child: const Text('Ripeti'),
                      ),
                      GenContextMenuItem(
                        items: [
                          GenContextMenuItem(onPressed: () {}, child: const Text('Cerca sul web')),
                          GenContextMenuItem(onPressed: () {}, child: const Text('Trova...')),
                          GenContextMenuItem(onPressed: () {}, child: const Text('Trova successivo')),
                        ],
                        child: const Text('Trova'),
                      ),
                    ],
                    child: const Text('Modifica'),
                  ),
                  GenMenubarItem(
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
                        child: const Text('Ricarica'),
                      ),
                    ],
                    child: const Text('Vista'),
                  ),
                ],
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Item con leading',
          description: 'GenMenubarItem accetta leading/trailing come un bottone.',
          items: [
            DemoTile(
              label: 'Icone nella barra',
              child: GenMenubar(
                items: [
                  GenMenubarItem(
                    leading: const Icon(LucideIcons.folder, size: 16),
                    items: [
                      GenContextMenuItem(onPressed: () {}, child: const Text('Apri')),
                      GenContextMenuItem(onPressed: () {}, child: const Text('Apri recenti')),
                    ],
                    child: const Text('Progetto'),
                  ),
                  GenMenubarItem(
                    leading: const Icon(LucideIcons.settings, size: 16),
                    items: [
                      GenContextMenuItem(onPressed: () {}, child: const Text('Preferenze')),
                      GenContextMenuItem(onPressed: () {}, child: const Text('Scorciatoie')),
                    ],
                    child: const Text('Impostazioni'),
                  ),
                ],
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'selectOnHover = false',
          description: 'Con selectOnHover=false il passaggio da un menu all\'altro '
              'richiede un click, non il solo hover.',
          items: [
            DemoTile(
              label: 'Solo click',
              child: GenMenubar(
                selectOnHover: false,
                items: [
                  GenMenubarItem(
                    items: [
                      GenContextMenuItem(onPressed: () {}, child: const Text('Profilo')),
                      GenContextMenuItem(onPressed: () {}, child: const Text('Fatturazione')),
                    ],
                    child: const Text('Account'),
                  ),
                  GenMenubarItem(
                    items: [
                      GenContextMenuItem(onPressed: () {}, child: const Text('Documentazione')),
                      GenContextMenuItem(onPressed: () {}, child: const Text('Contatta')),
                    ],
                    child: const Text('Aiuto'),
                  ),
                ],
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Item disabilitato',
          description: 'enabled=false sul GenMenubarItem disattiva l\'intera voce.',
          items: [
            DemoTile(
              label: 'Voce disabilitata',
              child: GenMenubar(
                items: [
                  GenMenubarItem(
                    items: [
                      GenContextMenuItem(onPressed: () {}, child: const Text('Azione')),
                    ],
                    child: const Text('Attivo'),
                  ),
                  GenMenubarItem(
                    enabled: false,
                    items: const [],
                    child: const Text('Disabilitato'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
