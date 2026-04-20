import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import '../widgets/showcase_section.dart';

class OverlayPage extends StatelessWidget {
  const OverlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseScaffold(
      title: 'Overlay',
      description: 'Modal · Confirm · Strong-confirm · Drawer · BottomSheet · Tooltip · Popover · ContextMenu.',
      children: [
        ShowcaseSection(
          title: 'showGenaiModal',
          child: Wrap(spacing: 8, runSpacing: 8, children: [
            for (final s in GenaiModalSize.values)
              GenaiButton.outline(
                label: 'Modal ${s.name}',
                onPressed: () => showGenaiModal<void>(
                  context,
                  title: 'Modal ${s.name}',
                  description: 'Esempio di modal con dimensione ${s.name}.',
                  size: s,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Contenuto del modal. Chiudi premendo Escape o cliccando fuori.',
                        style: context.typography.bodyMd.copyWith(color: context.colors.textPrimary)),
                  ),
                  actions: [
                    GenaiButton.ghost(label: 'Annulla', onPressed: () => Navigator.pop(context)),
                    GenaiButton.primary(label: 'OK', onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
          ]),
        ),
        ShowcaseSection(
          title: 'Confirm',
          child: Wrap(spacing: 8, children: [
            GenaiButton.secondary(
                label: 'Conferma',
                onPressed: () async {
                  await showGenaiConfirm(
                    context,
                    title: 'Vuoi procedere?',
                    description: 'L\'azione può essere annullata in seguito.',
                  );
                }),
            GenaiButton.destructive(
                label: 'Conferma forte',
                onPressed: () async {
                  await showGenaiStrongConfirm(
                    context,
                    title: 'Eliminare definitivamente?',
                    description: 'Per confermare digita "elimina" — l\'operazione è irreversibile.',
                    requiredText: 'elimina',
                  );
                }),
          ]),
        ),
        ShowcaseSection(
          title: 'Drawer & BottomSheet',
          child: Wrap(spacing: 8, children: [
            GenaiButton.outline(
                label: 'Drawer destro',
                onPressed: () => showGenaiDrawer<void>(
                      context,
                      child: _drawerContent(context),
                    )),
            GenaiButton.outline(
                label: 'Drawer sinistro',
                onPressed: () => showGenaiDrawer<void>(
                      context,
                      side: GenaiDrawerSide.left,
                      child: _drawerContent(context),
                    )),
            GenaiButton.outline(
                label: 'Bottom sheet',
                onPressed: () => showGenaiBottomSheet<void>(
                      context,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Bottom sheet', style: context.typography.headingSm.copyWith(color: context.colors.textPrimary)),
                            const SizedBox(height: 12),
                            Text('Trascina la maniglia in alto per chiudere.',
                                style: context.typography.bodyMd.copyWith(color: context.colors.textSecondary)),
                            const SizedBox(height: 16),
                            GenaiButton.primary(label: 'Chiudi', onPressed: () => Navigator.pop(context)),
                          ],
                        ),
                      ),
                    )),
          ]),
        ),
        ShowcaseSection(
          title: 'Tooltip',
          child: Wrap(spacing: 16, children: [
            GenaiTooltip(
              message: 'Salva il documento',
              child: GenaiIconButton(icon: LucideIcons.save, semanticLabel: 'Salva', onPressed: () {}),
            ),
            const GenaiTooltip(
              message: 'Disabilitato per permessi',
              child: GenaiIconButton(icon: LucideIcons.lock, semanticLabel: 'Bloccato'),
            ),
          ]),
        ),
        ShowcaseSection(
          title: 'Popover',
          child: Builder(builder: (ctx) {
            return GenaiPopover(
              content: (ctx) => SizedBox(
                width: 220,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Popover', style: ctx.typography.headingSm.copyWith(color: ctx.colors.textPrimary)),
                    const SizedBox(height: 6),
                    Text('Contenuto contestuale ancorato al trigger.', style: ctx.typography.bodySm.copyWith(color: ctx.colors.textSecondary)),
                  ],
                ),
              ),
              child: GenaiButton.outline(label: 'Apri popover', onPressed: () {}),
            );
          }),
        ),
        ShowcaseSection(
          title: 'ContextMenu',
          child: Builder(builder: (ctx) {
            return GestureDetector(
              onSecondaryTapDown: (d) => showGenaiContextMenu<String>(
                ctx,
                position: d.globalPosition,
                items: const [
                  GenaiContextMenuItem(value: 'edit', label: 'Modifica', icon: LucideIcons.pencil, shortcut: 'Cmd+E'),
                  GenaiContextMenuItem(value: 'duplicate', label: 'Duplica', icon: LucideIcons.copy),
                  GenaiContextMenuItem(value: 'delete', label: 'Elimina', icon: LucideIcons.trash2, isDestructive: true),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: ctx.colors.surfaceCard,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: ctx.colors.borderDefault),
                ),
                child: Text('Right-click qui per il menu', style: ctx.typography.bodyMd.copyWith(color: ctx.colors.textPrimary)),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _drawerContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Drawer', style: context.typography.headingSm.copyWith(color: context.colors.textPrimary)),
          const SizedBox(height: 8),
          Text('Pannello laterale per dettagli o azioni secondarie.', style: context.typography.bodyMd.copyWith(color: context.colors.textSecondary)),
          const SizedBox(height: 16),
          GenaiButton.primary(label: 'Chiudi', onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}
