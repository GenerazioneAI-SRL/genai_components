import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import '../widgets/showcase_section.dart';

class ActionsPage extends StatefulWidget {
  const ActionsPage({super.key});

  @override
  State<ActionsPage> createState() => _ActionsPageState();
}

class _ActionsPageState extends State<ActionsPage> {
  bool _toggleOn = false;
  String _toggleVal = 'list';

  @override
  Widget build(BuildContext context) {
    return ShowcaseScaffold(
      title: 'Actions',
      description:
          'Button, IconButton, LinkButton, CopyButton, SplitButton, Fab, '
          'Toggle. v3 primari ink-black + secondari panel-bordered.',
      children: [
        ShowcaseSection(
          title: 'Button variants',
          subtitle: 'Primary (ink), secondary, ghost, destructive.',
          child: Column(
            children: [
              ShowcaseRow(
                label: 'Primary',
                children: [
                  GenaiButton.primary(label: 'Save', onPressed: () {}),
                  GenaiButton.primary(
                    label: 'Riprendi',
                    icon: LucideIcons.play,
                    onPressed: () {},
                  ),
                  GenaiButton.primary(label: 'Disabled'),
                ],
              ),
              ShowcaseRow(
                label: 'Secondary',
                children: [
                  GenaiButton.secondary(label: 'Cancel', onPressed: () {}),
                  GenaiButton.secondary(
                    label: 'Download',
                    trailingIcon: LucideIcons.download,
                    onPressed: () {},
                  ),
                  GenaiButton.secondary(label: 'Disabled'),
                ],
              ),
              ShowcaseRow(
                label: 'Ghost',
                children: [
                  GenaiButton.ghost(label: 'Altre opzioni', onPressed: () {}),
                  GenaiButton.ghost(
                    label: 'More',
                    trailingIcon: LucideIcons.chevronDown,
                    onPressed: () {},
                  ),
                ],
              ),
              ShowcaseRow(
                label: 'Destructive',
                children: [
                  GenaiButton.destructive(label: 'Delete', onPressed: () {}),
                ],
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Sizes',
          subtitle: 'sm / md / lg.',
          child: Column(
            children: [
              ShowcaseRow(
                label: 'sm',
                children: [
                  GenaiButton.primary(
                    label: 'Small',
                    size: GenaiButtonSize.sm,
                    onPressed: () {},
                  ),
                  GenaiButton.secondary(
                    label: 'Small',
                    size: GenaiButtonSize.sm,
                    onPressed: () {},
                  ),
                ],
              ),
              ShowcaseRow(
                label: 'md',
                children: [
                  GenaiButton.primary(label: 'Medium', onPressed: () {}),
                  GenaiButton.secondary(label: 'Medium', onPressed: () {}),
                ],
              ),
              ShowcaseRow(
                label: 'lg',
                children: [
                  GenaiButton.primary(
                    label: 'Large',
                    size: GenaiButtonSize.lg,
                    onPressed: () {},
                  ),
                  GenaiButton.secondary(
                    label: 'Large',
                    size: GenaiButtonSize.lg,
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Icon buttons',
          subtitle: 'Always need a semantic label. Badge slot supported.',
          child: ShowcaseRow(
            label: 'ghost / badge',
            children: [
              GenaiIconButton(
                icon: LucideIcons.settings,
                semanticLabel: 'Impostazioni',
                onPressed: () {},
              ),
              GenaiIconButton(
                icon: LucideIcons.bell,
                semanticLabel: 'Notifiche',
                badge: GenaiBadge.count(count: 5),
                onPressed: () {},
              ),
              GenaiIconButton(
                icon: LucideIcons.x,
                semanticLabel: 'Chiudi',
                variant: GenaiButtonVariant.secondary,
                onPressed: () {},
              ),
              GenaiIconButton(
                icon: LucideIcons.search,
                semanticLabel: 'Cerca (disabilitato)',
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Link buttons',
          subtitle: 'Section-head inline link style.',
          child: ShowcaseRow(
            label: 'variants',
            children: [
              GenaiLinkButton(label: 'Vedi tutte', onPressed: () {}),
              GenaiLinkButton(
                label: 'Scopri',
                icon: LucideIcons.arrowRight,
                onPressed: () {},
              ),
              GenaiLinkButton(
                label: 'Apri docs',
                isExternal: true,
                onPressed: () {},
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Copy / Split / Fab',
          subtitle: 'Secondary action patterns.',
          child: Column(
            children: [
              ShowcaseRow(
                label: 'Copy',
                children: [
                  GenaiCopyButton(
                    valueToCopy: 'COURSE-SEC-2026',
                    semanticLabel: 'Copia codice corso',
                  ),
                ],
              ),
              ShowcaseRow(
                label: 'Split',
                children: [
                  GenaiSplitButton(
                    label: 'Salva',
                    icon: LucideIcons.save,
                    onPressed: () {},
                    menuItems: const [
                      PopupMenuItem(value: 1, child: Text('Salva come bozza')),
                      PopupMenuItem(value: 2, child: Text('Salva e invia')),
                    ],
                    onMenuSelected: (_) {},
                  ),
                ],
              ),
              ShowcaseRow(
                label: 'Fab',
                children: [
                  GenaiFab(
                    icon: LucideIcons.plus,
                    semanticLabel: 'Nuovo',
                    onPressed: () {},
                  ),
                  GenaiFab(
                    icon: LucideIcons.plus,
                    label: 'Nuovo corso',
                    semanticLabel: 'Nuovo corso',
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Toggle buttons',
          subtitle: 'Stateful and grouped.',
          child: Column(
            children: [
              ShowcaseRow(
                label: 'Toggle',
                children: [
                  GenaiToggleButton(
                    pressed: _toggleOn,
                    label: _toggleOn ? 'Mostrato' : 'Nascosto',
                    icon: _toggleOn ? LucideIcons.eye : LucideIcons.eyeOff,
                    onChanged: (v) => setState(() => _toggleOn = v),
                  ),
                ],
              ),
              ShowcaseRow(
                label: 'Group',
                children: [
                  GenaiToggleButtonGroup<String>(
                    value: _toggleVal,
                    onChanged: (v) =>
                        setState(() => _toggleVal = v ?? _toggleVal),
                    options: const [
                      GenaiToggleOption(
                        value: 'list',
                        label: 'Lista',
                        icon: LucideIcons.list,
                      ),
                      GenaiToggleOption(
                        value: 'grid',
                        label: 'Griglia',
                        icon: LucideIcons.layoutGrid,
                      ),
                      GenaiToggleOption(
                        value: 'kanban',
                        label: 'Kanban',
                        icon: LucideIcons.columns3,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
