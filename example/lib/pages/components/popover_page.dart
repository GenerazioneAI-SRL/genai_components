import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;

import '../../shared/demo_page.dart';

/// Showcase esaustiva di [GenPopover] (= GenPopover).
///
/// Il popover si ancora al [child] (qui un [GenButton]) e la sua visibilita' e'
/// guidata da un [GenPopoverController] (toggle sul tap del trigger). Copre:
/// popover base, posizionamento via `anchor` (sotto/sopra/destra/sinistra),
/// contenuto ricco (menu), e le opzioni `closeOnTapOutside` e `padding`.
class PopoverShowcase extends StatelessWidget {
  const PopoverShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      children: [
        DemoGroup(
          title: 'Base',
          description: 'Tap sul trigger per aprire/chiudere. Visibilita\' gestita da GenPopoverController.',
          items: [
            _PopoverDemo(
              label: 'testo semplice',
              trigger: 'Apri popover',
              icon: LucideIcons.messageCircle,
              popover: (ctx) => const SizedBox(
                width: 220,
                child: Text('Un popover ancorato al bottone. Tap fuori per chiudere.'),
              ),
            ),
            _PopoverDemo(
              label: 'con titolo',
              trigger: 'Dettagli',
              icon: LucideIcons.info,
              popover: (ctx) => _titledBody(ctx),
            ),
          ],
        ),
        DemoGroup(
          title: 'Posizionamento (anchor)',
          description: 'anchor controlla dove appare rispetto al trigger.',
          items: [
            _PopoverDemo(
              label: 'sotto (default)',
              trigger: 'Sotto',
              popover: (ctx) => const Text('Sotto il trigger'),
            ),
            _PopoverDemo(
              label: 'sopra',
              trigger: 'Sopra',
              anchor: const GenAnchor(
                childAlignment: Alignment.topCenter,
                overlayAlignment: Alignment.bottomCenter,
                offset: Offset(0, -4),
              ),
              popover: (ctx) => const Text('Sopra il trigger'),
            ),
            _PopoverDemo(
              label: 'a destra',
              trigger: 'Destra',
              anchor: const GenAnchor(
                childAlignment: Alignment.centerRight,
                overlayAlignment: Alignment.centerLeft,
                offset: Offset(4, 0),
              ),
              popover: (ctx) => const Text('A destra del trigger'),
            ),
            _PopoverDemo(
              label: 'a sinistra',
              trigger: 'Sinistra',
              anchor: const GenAnchor(
                childAlignment: Alignment.centerLeft,
                overlayAlignment: Alignment.centerRight,
                offset: Offset(-4, 0),
              ),
              popover: (ctx) => const Text('A sinistra del trigger'),
            ),
          ],
        ),
        DemoGroup(
          title: 'Contenuto ricco',
          description: 'Il popover puo\' ospitare un menu o un layout complesso.',
          items: [
            _PopoverDemo(
              label: 'menu di azioni',
              trigger: 'Azioni',
              icon: LucideIcons.ellipsisVertical,
              padding: EdgeInsets.zero,
              popover: (ctx) => _menuBody(ctx),
            ),
            _PopoverDemo(
              label: 'card profilo',
              trigger: 'Profilo',
              icon: LucideIcons.user,
              popover: (ctx) => _profileBody(ctx),
            ),
          ],
        ),
        DemoGroup(
          title: 'Opzioni',
          description: 'closeOnTapOutside e padding personalizzati.',
          items: [
            _PopoverDemo(
              label: 'closeOnTapOutside: false',
              trigger: 'Persistente',
              popover: (ctx) => const SizedBox(
                width: 220,
                child: Text('Il tap fuori NON chiude. Usa Esc o ri-tappa il trigger.'),
              ),
              closeOnTapOutside: false,
            ),
            _PopoverDemo(
              label: 'padding ampio',
              trigger: 'Padding 24',
              padding: const EdgeInsets.all(24),
              popover: (ctx) => const Text('padding: EdgeInsets.all(24)'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _titledBody(BuildContext context) {
    final t = GenTokens.of(context);
    return SizedBox(
      width: 240,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dimensioni', style: t.heading5.copyWith(color: t.primaryText)),
          const SizedBox(height: 4),
          Text('Imposta larghezza e altezza del riquadro.', style: t.smallText),
        ],
      ),
    );
  }

  Widget _menuBody(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          _MenuItem(icon: LucideIcons.pencil, label: 'Modifica'),
          _MenuItem(icon: LucideIcons.copy, label: 'Duplica'),
          _MenuItem(icon: LucideIcons.share2, label: 'Condividi'),
          _MenuItem(icon: LucideIcons.trash2, label: 'Elimina', destructive: true),
        ],
      ),
    );
  }

  Widget _profileBody(BuildContext context) {
    final t = GenTokens.of(context);
    return SizedBox(
      width: 260,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const GenAvatar(null, placeholder: Text('MR')),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mario Rossi', style: t.title.copyWith(color: t.primaryText)),
                  Text('mario@example.com', style: t.smallText),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          GenButton.outline(
            onPressed: () {},
            width: double.infinity,
            child: const Text('Vai al profilo'),
          ),
        ],
      ),
    );
  }
}

/// Voce di menu usata nel popover "Azioni".
class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.label, this.destructive = false});

  final IconData icon;
  final String label;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    final color = destructive ? t.danger : t.primaryText;
    return GenButton.ghost(
      onPressed: () {},
      width: double.infinity,
      mainAxisAlignment: MainAxisAlignment.start,
      leading: GenIcon(icon, size: 16, color: color),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(label, style: t.bodyText.copyWith(color: color)),
      ),
    );
  }
}

/// Trigger + [GenPopover] con controller dedicato. Il tap sul bottone fa toggle.
class _PopoverDemo extends StatefulWidget {
  const _PopoverDemo({
    required this.label,
    required this.trigger,
    required this.popover,
    this.anchor,
    this.icon,
    this.closeOnTapOutside = true,
    this.padding,
  });

  final String label;
  final String trigger;
  final WidgetBuilder popover;
  final GenAnchorBase? anchor;
  final IconData? icon;
  final bool closeOnTapOutside;
  final EdgeInsetsGeometry? padding;

  @override
  State<_PopoverDemo> createState() => _PopoverDemoState();
}

class _PopoverDemoState extends State<_PopoverDemo> {
  final _controller = GenPopoverController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DemoTile(
      label: widget.label,
      child: GenPopover(
        controller: _controller,
        anchor: widget.anchor,
        closeOnTapOutside: widget.closeOnTapOutside,
        padding: widget.padding,
        popover: widget.popover,
        child: GenButton.secondary(
          onPressed: _controller.toggle,
          leading: widget.icon == null ? null : GenIcon(widget.icon!),
          child: Text(widget.trigger),
        ),
      ),
    );
  }
}
