import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;

import '../../shared/demo_page.dart';

/// Showcase esaustiva di [GenCheckbox] (= GenCheckbox).
///
/// Copre: base on/off, label + sublabel, disabled (checked/unchecked), size,
/// icona custom, colori (color / uncheckedColor), direction RTL, e una selezione
/// multipla di gruppo. Interattivo: ogni checkbox ha stato locale.
class CheckboxShowcase extends StatefulWidget {
  const CheckboxShowcase({super.key});

  @override
  State<CheckboxShowcase> createState() => _CheckboxShowcaseState();
}

class _CheckboxShowcaseState extends State<CheckboxShowcase> {
  bool _base = false;
  bool _withLabel = true;
  bool _withSublabel = true;
  bool _small = true;
  bool _large = false;
  bool _customIcon = true;
  bool _customColor = true;
  bool _rtl = true;

  // Gruppo (selezione multipla).
  final Set<String> _selected = {'email'};

  void _toggleGroup(String key, bool value) {
    setState(() {
      if (value) {
        _selected.add(key);
      } else {
        _selected.remove(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);

    return DemoPage(
      children: [
        // ── Base ────────────────────────────────────────────────────────────
        DemoGroup(
          title: 'Base',
          description: 'Toggle booleano semplice. onChanged null => non interattivo.',
          items: [
            DemoTile(
              label: 'Interattivo',
              child: GenCheckbox(
                value: _base,
                onChanged: (v) => setState(() => _base = v),
              ),
            ),
            DemoTile(
              label: 'Checked (statico)',
              child: const GenCheckbox(value: true),
            ),
            DemoTile(
              label: 'Unchecked (statico)',
              child: const GenCheckbox(value: false),
            ),
            DemoTile(
              label: 'onChanged: null (read-only)',
              child: const GenCheckbox(value: true, onChanged: null),
            ),
          ],
        ),

        // ── Label + sublabel ────────────────────────────────────────────────
        DemoGroup(
          title: 'Label e sublabel',
          description: 'Testo accanto al box; sublabel su seconda riga (allineamento start).',
          items: [
            DemoTile(
              label: 'Solo label',
              width: 260,
              child: GenCheckbox(
                value: _withLabel,
                onChanged: (v) => setState(() => _withLabel = v),
                label: const Text('Accetto i termini'),
              ),
            ),
            DemoTile(
              label: 'Label + sublabel',
              width: 260,
              child: GenCheckbox(
                value: _withSublabel,
                onChanged: (v) => setState(() => _withSublabel = v),
                label: const Text('Notifiche email'),
                sublabel: const Text('Ricevi aggiornamenti sul tuo account.'),
              ),
            ),
          ],
        ),

        // ── Disabled ────────────────────────────────────────────────────────
        DemoGroup(
          title: 'Disabled',
          description: 'enabled:false => dimmato e non interattivo.',
          items: [
            DemoTile(
              label: 'Disabled unchecked',
              child: const GenCheckbox(value: false, enabled: false),
            ),
            DemoTile(
              label: 'Disabled checked',
              child: const GenCheckbox(value: true, enabled: false),
            ),
            DemoTile(
              label: 'Disabled + label',
              width: 260,
              child: const GenCheckbox(
                value: true,
                enabled: false,
                label: Text('Opzione bloccata'),
                sublabel: Text('Non modificabile in questo contesto.'),
              ),
            ),
          ],
        ),

        // ── Size ────────────────────────────────────────────────────────────
        DemoGroup(
          title: 'Size',
          description: 'size regola lato del box (default 16). L\'icona scala di conseguenza.',
          items: [
            DemoTile(
              label: 'size: 14',
              child: GenCheckbox(
                value: _small,
                size: 14,
                onChanged: (v) => setState(() => _small = v),
              ),
            ),
            DemoTile(
              label: 'size: 16 (default)',
              child: GenCheckbox(
                value: _small,
                onChanged: (v) => setState(() => _small = v),
              ),
            ),
            DemoTile(
              label: 'size: 24',
              child: GenCheckbox(
                value: _large,
                size: 24,
                onChanged: (v) => setState(() => _large = v),
              ),
            ),
          ],
        ),

        // ── Icona e colori ──────────────────────────────────────────────────
        DemoGroup(
          title: 'Icona e colori',
          description: 'icon custom quando checked; color (checked) e uncheckedColor (box off).',
          items: [
            DemoTile(
              label: 'Icona custom',
              child: GenCheckbox(
                value: _customIcon,
                onChanged: (v) => setState(() => _customIcon = v),
                icon: const Icon(LucideIcons.heart, size: 16),
              ),
            ),
            DemoTile(
              label: 'color: primary',
              child: GenCheckbox(
                value: _customColor,
                onChanged: (v) => setState(() => _customColor = v),
                color: t.primary,
              ),
            ),
            DemoTile(
              label: 'uncheckedColor: border',
              child: GenCheckbox(
                value: false,
                onChanged: (_) {},
                uncheckedColor: t.borderColor,
              ),
            ),
          ],
        ),

        // ── Direction ───────────────────────────────────────────────────────
        DemoGroup(
          title: 'Direction (RTL)',
          description: 'direction:rtl posiziona la label a sinistra del box.',
          items: [
            DemoTile(
              label: 'TextDirection.rtl',
              width: 260,
              child: GenCheckbox(
                value: _rtl,
                onChanged: (v) => setState(() => _rtl = v),
                direction: TextDirection.rtl,
                label: const Text('محدد'),
                sublabel: const Text('Etichetta allineata a destra'),
              ),
            ),
          ],
        ),

        // ── Gruppo (selezione multipla) ─────────────────────────────────────
        DemoGroup(
          title: 'Gruppo (selezione multipla)',
          description: 'Più checkbox indipendenti che compongono un set di valori.',
          items: [
            DemoTile(
              label: 'Canali di notifica',
              width: 260,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GenCheckbox(
                    value: _selected.contains('email'),
                    onChanged: (v) => _toggleGroup('email', v),
                    label: const Text('Email'),
                  ),
                  SizedBox(height: t.gapSm),
                  GenCheckbox(
                    value: _selected.contains('sms'),
                    onChanged: (v) => _toggleGroup('sms', v),
                    label: const Text('SMS'),
                  ),
                  SizedBox(height: t.gapSm),
                  GenCheckbox(
                    value: _selected.contains('push'),
                    onChanged: (v) => _toggleGroup('push', v),
                    label: const Text('Push'),
                  ),
                  SizedBox(height: t.gapMd),
                  Text(
                    'Selezionati: ${_selected.isEmpty ? '—' : _selected.join(', ')}',
                    style: t.smallText.copyWith(color: t.secondaryText),
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
