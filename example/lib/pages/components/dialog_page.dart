import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;

import '../../shared/demo_page.dart';

/// Showcase esaustiva di [GenDialog] (= GenDialog), aperto con `showGenDialog`.
///
/// Ogni esempio e' un trigger [GenButton] che apre l'overlay. Copre: dialog base
/// (title/description/actions/child), variante `GenDialog.alert`, posizionamento
/// (`alignment`) e vincoli (`constraints`), form interno, close icon, contenuto
/// scrollabile e opzioni del barrier (`barrierDismissible`, `barrierColor`).
///
/// IMPORTANTE: `showGenDialog` di default ha `opaque: true` che nasconde tutto
/// dietro il dialog. Qui passiamo SEMPRE `opaque: false` cosi' l'app resta visibile.
class DialogShowcase extends StatelessWidget {
  const DialogShowcase({super.key});

  /// Apre un dialog costruito da [builder] con `opaque: false` (regola comune).
  Future<void> _open(
    BuildContext context,
    WidgetBuilder builder, {
    bool barrierDismissible = true,
    Color barrierColor = const Color(0xcc000000),
  }) {
    return showGenDialog<void>(
      context: context,
      opaque: false,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      children: [
        DemoGroup(
          title: 'Base',
          description: 'title, description, child e actions. Le actions chiudono con Navigator.pop.',
          items: [
            DemoTile(
              label: 'title + description + actions',
              child: GenButton(
                leading: const GenIcon(LucideIcons.messageSquare),
                onPressed: () => _open(
                  context,
                  (ctx) => GenDialog(
                    title: const Text('Conferma operazione'),
                    description: const Text('Vuoi procedere con il salvataggio delle modifiche?'),
                    actions: [
                      GenButton.outline(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Annulla')),
                      GenButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Conferma')),
                    ],
                  ),
                ),
                child: const Text('Apri dialog'),
              ),
            ),
            DemoTile(
              label: 'solo title + child',
              child: GenButton.secondary(
                onPressed: () => _open(
                  context,
                  (ctx) => GenDialog(
                    title: const Text('Note di rilascio'),
                    actions: [
                      GenButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Ho capito')),
                    ],
                    child: const Text(
                      'Versione 1.4.0\n\n- Nuovo componente Sheet\n- Fix del popover su schermi piccoli\n- Migliorie performance',
                    ),
                  ),
                ),
                child: const Text('Con child testuale'),
              ),
            ),
            DemoTile(
              label: 'senza actions (solo close icon)',
              child: GenButton.ghost(
                onPressed: () => _open(
                  context,
                  (ctx) => const GenDialog(
                    title: Text('Informazione'),
                    description: Text('Chiudi con la X in alto a destra o tap fuori.'),
                    closeIconData: LucideIcons.x,
                  ),
                ),
                child: const Text('Solo informativo'),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Variante alert',
          description: 'GenDialog.alert per azioni distruttive o critiche.',
          items: [
            DemoTile(
              label: 'GenDialog.alert',
              child: GenButton.destructive(
                leading: const GenIcon(LucideIcons.trash2),
                onPressed: () => _open(
                  context,
                  (ctx) => GenDialog.alert(
                    title: const Text('Eliminare l\'elemento?'),
                    description: const Text('Questa azione e\' irreversibile. I dati verranno rimossi definitivamente.'),
                    actions: [
                      GenButton.outline(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Annulla')),
                      GenButton.destructive(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Elimina')),
                    ],
                  ),
                ),
                child: const Text('Elimina…'),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Posizione e vincoli',
          description: 'alignment sposta il dialog; constraints ne limita la larghezza.',
          items: [
            DemoTile(
              label: 'alignment: topCenter',
              child: GenButton.secondary(
                onPressed: () => _open(
                  context,
                  (ctx) => GenDialog(
                    alignment: Alignment.topCenter,
                    title: const Text('Ancorato in alto'),
                    description: const Text('alignment: Alignment.topCenter'),
                    actions: [
                      GenButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Chiudi')),
                    ],
                  ),
                ),
                child: const Text('In alto'),
              ),
            ),
            DemoTile(
              label: 'alignment: bottomRight',
              child: GenButton.secondary(
                onPressed: () => _open(
                  context,
                  (ctx) => GenDialog(
                    alignment: Alignment.bottomRight,
                    title: const Text('In basso a destra'),
                    description: const Text('alignment: Alignment.bottomRight'),
                    actions: [
                      GenButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Chiudi')),
                    ],
                  ),
                ),
                child: const Text('In basso a destra'),
              ),
            ),
            DemoTile(
              label: 'constraints: maxWidth 360',
              child: GenButton.secondary(
                onPressed: () => _open(
                  context,
                  (ctx) => GenDialog(
                    constraints: const BoxConstraints(maxWidth: 360),
                    title: const Text('Dialog stretto'),
                    description: const Text('constraints: BoxConstraints(maxWidth: 360)'),
                    actions: [
                      GenButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Chiudi')),
                    ],
                  ),
                ),
                child: const Text('Larghezza limitata'),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Form interno',
          description: 'Il child puo\' contenere un form completo con input e actions.',
          items: [
            DemoTile(
              label: 'form login',
              child: GenButton(
                leading: const GenIcon(LucideIcons.userPlus),
                onPressed: () => _open(
                  context,
                  (ctx) => GenDialog(
                    title: const Text('Nuovo contatto'),
                    description: const Text('Inserisci i dati e salva.'),
                    actions: [
                      GenButton.outline(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Annulla')),
                      GenButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Salva')),
                    ],
                    child: const SizedBox(
                      width: 320,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          GenInput(placeholder: Text('Nome'), leading: GenIcon(LucideIcons.user, size: 16)),
                          SizedBox(height: 12),
                          GenInput(placeholder: Text('Email'), leading: GenIcon(LucideIcons.mail, size: 16)),
                        ],
                      ),
                    ),
                  ),
                ),
                child: const Text('Apri form'),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Scrollable e barrier',
          description: 'scrollable con contenuto lungo; opzioni del barrier (dismiss e colore).',
          items: [
            DemoTile(
              label: 'contenuto scrollabile',
              child: GenButton.secondary(
                onPressed: () => _open(
                  context,
                  (ctx) => GenDialog(
                    title: const Text('Termini di servizio'),
                    constraints: const BoxConstraints(maxWidth: 460, maxHeight: 420),
                    actions: [
                      GenButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Accetto')),
                    ],
                    child: SizedBox(
                      width: 400,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          12,
                          (i) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text('Clausola ${i + 1}. Lorem ipsum dolor sit amet, consectetur adipiscing elit, '
                                'sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                child: const Text('Testo lungo'),
              ),
            ),
            DemoTile(
              label: 'barrierDismissible: false',
              child: GenButton.secondary(
                onPressed: () => _open(
                  context,
                  barrierDismissible: false,
                  (ctx) => GenDialog(
                    title: const Text('Azione obbligatoria'),
                    description: const Text('Il tap fuori non chiude: usa il bottone.'),
                    actions: [
                      GenButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Ho capito')),
                    ],
                  ),
                ),
                child: const Text('Non-dismissible'),
              ),
            ),
            DemoTile(
              label: 'barrierColor trasparente',
              child: GenButton.secondary(
                onPressed: () => _open(
                  context,
                  barrierColor: const Color(0x00000000),
                  (ctx) => GenDialog(
                    title: const Text('Barrier trasparente'),
                    description: const Text('barrierColor: Color(0x00000000)'),
                    actions: [
                      GenButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Chiudi')),
                    ],
                  ),
                ),
                child: const Text('Senza velo'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
