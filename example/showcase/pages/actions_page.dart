import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import '../widgets/showcase_section.dart';

class ActionsPage extends StatefulWidget {
  const ActionsPage({super.key});

  @override
  State<ActionsPage> createState() => _ActionsPageState();
}

class _ActionsPageState extends State<ActionsPage> {
  String _toggleValue = 'list';
  List<String> _multiToggle = ['b'];

  @override
  Widget build(BuildContext context) {
    return ShowcaseScaffold(
      title: 'Actions',
      description: 'Bottoni primari/secondari/ghost/outline/destructive, IconButton, LinkButton, CopyButton, ToggleGroup, SplitButton, FAB.',
      children: [
        ShowcaseSection(
          title: 'GenaiButton — varianti',
          child: Column(
            children: [
              ShowcaseRow(label: 'Primary', children: [
                GenaiButton.primary(label: 'Salva', onPressed: () {}),
                GenaiButton.primary(label: 'Aggiungi', icon: LucideIcons.plus, onPressed: () {}),
                GenaiButton.primary(label: 'Caricamento', isLoading: true, onPressed: () {}),
                const GenaiButton.primary(label: 'Disabled'),
              ]),
              ShowcaseRow(label: 'Secondary', children: [
                GenaiButton.secondary(label: 'Annulla', onPressed: () {}),
                GenaiButton.secondary(label: 'Filtri', icon: LucideIcons.funnel, onPressed: () {}),
                const GenaiButton.secondary(label: 'Disabled'),
              ]),
              ShowcaseRow(label: 'Ghost', children: [
                GenaiButton.ghost(label: 'Skip', onPressed: () {}),
                GenaiButton.ghost(label: 'Importa', icon: LucideIcons.upload, onPressed: () {}),
              ]),
              ShowcaseRow(label: 'Outline', children: [
                GenaiButton.outline(label: 'Esporta', onPressed: () {}),
                GenaiButton.outline(label: 'Esporta CSV', icon: LucideIcons.download, onPressed: () {}),
              ]),
              ShowcaseRow(label: 'Destructive', children: [
                GenaiButton.destructive(label: 'Elimina', onPressed: () {}),
                GenaiButton.destructive(label: 'Elimina', icon: LucideIcons.trash2, onPressed: () {}),
              ]),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiButton — sizes',
          child: Column(
            children: [
              ShowcaseRow(label: 'XS', children: [
                GenaiButton.primary(label: 'Salva', size: GenaiSize.xs, onPressed: () {}),
              ]),
              ShowcaseRow(label: 'SM', children: [
                GenaiButton.primary(label: 'Salva', size: GenaiSize.sm, onPressed: () {}),
              ]),
              ShowcaseRow(label: 'MD (default)', children: [
                GenaiButton.primary(label: 'Salva', onPressed: () {}),
              ]),
              ShowcaseRow(label: 'LG', children: [
                GenaiButton.primary(label: 'Salva', size: GenaiSize.lg, onPressed: () {}),
              ]),
              ShowcaseRow(label: 'XL', children: [
                GenaiButton.primary(label: 'Salva', size: GenaiSize.xl, onPressed: () {}),
              ]),
              ShowcaseRow(label: 'Full width', children: [
                SizedBox(
                  width: 280,
                  child: GenaiButton.primary(label: 'Continua', isFullWidth: true, onPressed: () {}),
                ),
              ]),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiIconButton',
          child: Column(
            children: [
              ShowcaseRow(label: 'Sizes', children: [
                GenaiIconButton(icon: LucideIcons.heart, semanticLabel: 'Mi piace', size: GenaiSize.xs, onPressed: () {}),
                GenaiIconButton(icon: LucideIcons.heart, semanticLabel: 'Mi piace', size: GenaiSize.sm, onPressed: () {}),
                GenaiIconButton(icon: LucideIcons.heart, semanticLabel: 'Mi piace', onPressed: () {}),
                GenaiIconButton(icon: LucideIcons.heart, semanticLabel: 'Mi piace', size: GenaiSize.lg, onPressed: () {}),
              ]),
              ShowcaseRow(label: 'Tooltip', children: [
                GenaiIconButton(icon: LucideIcons.refreshCw, tooltip: 'Ricarica', semanticLabel: 'Ricarica', onPressed: () {}),
                GenaiIconButton(icon: LucideIcons.settings, tooltip: 'Impostazioni', semanticLabel: 'Impostazioni', onPressed: () {}),
                const GenaiIconButton(icon: LucideIcons.lock, semanticLabel: 'Disabilitato'),
              ]),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiLinkButton',
          child: Wrap(spacing: 16, runSpacing: 8, children: [
            GenaiLinkButton(label: 'Maggiori dettagli', onPressed: () {}),
            GenaiLinkButton(label: 'Apri sito', icon: LucideIcons.externalLink, isExternal: true, onPressed: () {}),
          ]),
        ),
        ShowcaseSection(
          title: 'GenaiCopyButton',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: context.colors.surfaceCard,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: context.colors.borderDefault),
                ),
                child: Text('genai_components_v4', style: context.typography.code.copyWith(color: context.colors.textPrimary)),
              ),
              const SizedBox(width: 8),
              const GenaiCopyButton(valueToCopy: 'genai_components_v4'),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiToggleButtonGroup',
          child: Column(
            children: [
              ShowcaseRow(label: 'Singolo', children: [
                GenaiToggleButtonGroup<String>(
                  value: _toggleValue,
                  onChanged: (v) => setState(() => _toggleValue = v ?? _toggleValue),
                  options: const [
                    GenaiToggleOption(value: 'list', icon: LucideIcons.list, tooltip: 'Lista'),
                    GenaiToggleOption(value: 'grid', icon: LucideIcons.layoutGrid, tooltip: 'Griglia'),
                    GenaiToggleOption(value: 'kanban', icon: LucideIcons.columns3, tooltip: 'Kanban'),
                  ],
                ),
              ]),
              ShowcaseRow(label: 'Multi', children: [
                GenaiMultiToggleButtonGroup<String>(
                  values: _multiToggle,
                  onChanged: (v) => setState(() => _multiToggle = v),
                  options: const [
                    GenaiToggleOption(value: 'a', label: 'Bold'),
                    GenaiToggleOption(value: 'b', label: 'Italic'),
                    GenaiToggleOption(value: 'c', label: 'Underline'),
                  ],
                ),
              ]),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiSplitButton',
          child: GenaiSplitButton(
            label: 'Salva',
            icon: LucideIcons.save,
            onPressed: () {},
            onMenuSelected: (_) {},
            menuItems: const [
              PopupMenuItem(value: 0, child: Text('Salva e chiudi')),
              PopupMenuItem(value: 1, child: Text('Salva come bozza')),
              PopupMenuItem(value: 2, child: Text('Salva e duplica')),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiFAB',
          child: Wrap(spacing: 16, runSpacing: 16, children: [
            GenaiFAB(icon: LucideIcons.plus, semanticLabel: 'Crea', onPressed: () {}),
            GenaiFAB(icon: LucideIcons.plus, label: 'Crea', semanticLabel: 'Crea elemento', onPressed: () {}),
          ]),
        ),
      ],
    );
  }
}
