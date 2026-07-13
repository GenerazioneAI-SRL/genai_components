import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;

import '../../shared/demo_page.dart';

/// Showcase esaustiva di [GenSwitch] (= GenSwitch).
///
/// Copre: base on/off, label + sublabel, disabled, dimensioni (width/height),
/// colori (thumb / track checked / track unchecked), direction RTL e un gruppo
/// di impostazioni. Interattivo: ogni switch ha stato locale.
class SwitchShowcase extends StatefulWidget {
  const SwitchShowcase({super.key});

  @override
  State<SwitchShowcase> createState() => _SwitchShowcaseState();
}

class _SwitchShowcaseState extends State<SwitchShowcase> {
  bool _base = true;
  bool _withLabel = true;
  bool _withSublabel = false;
  bool _sized = true;
  bool _colored = true;
  bool _rtl = false;

  // Gruppo impostazioni.
  bool _wifi = true;
  bool _bluetooth = false;
  bool _airplane = false;

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);

    return DemoPage(
      children: [
        // ── Base ────────────────────────────────────────────────────────────
        DemoGroup(
          title: 'Base',
          description: 'Toggle on/off animato. onChanged null => non interattivo.',
          items: [
            DemoTile(
              label: 'Interattivo',
              child: GenSwitch(
                value: _base,
                onChanged: (v) => setState(() => _base = v),
              ),
            ),
            DemoTile(
              label: 'On (statico)',
              child: const GenSwitch(value: true),
            ),
            DemoTile(
              label: 'Off (statico)',
              child: const GenSwitch(value: false),
            ),
            DemoTile(
              label: 'onChanged: null (read-only)',
              child: const GenSwitch(value: true, onChanged: null),
            ),
          ],
        ),

        // ── Label + sublabel ────────────────────────────────────────────────
        DemoGroup(
          title: 'Label e sublabel',
          description: 'Testo a destra dello switch; sublabel come descrizione secondaria.',
          items: [
            DemoTile(
              label: 'Solo label',
              width: 260,
              child: GenSwitch(
                value: _withLabel,
                onChanged: (v) => setState(() => _withLabel = v),
                label: const Text('Modalità scura'),
              ),
            ),
            DemoTile(
              label: 'Label + sublabel',
              width: 260,
              child: GenSwitch(
                value: _withSublabel,
                onChanged: (v) => setState(() => _withSublabel = v),
                label: const Text('Sincronizzazione'),
                sublabel: const Text('Aggiorna in background quando online.'),
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
              label: 'Disabled off',
              child: const GenSwitch(value: false, enabled: false),
            ),
            DemoTile(
              label: 'Disabled on',
              child: const GenSwitch(value: true, enabled: false),
            ),
            DemoTile(
              label: 'Disabled + label',
              width: 260,
              child: const GenSwitch(
                value: true,
                enabled: false,
                label: Text('Funzione premium'),
                sublabel: Text('Disponibile con il piano Pro.'),
              ),
            ),
          ],
        ),

        // ── Dimensioni ──────────────────────────────────────────────────────
        DemoGroup(
          title: 'Dimensioni',
          description: 'width (default 44), height (default 24), margin del thumb (default 2).',
          items: [
            DemoTile(
              label: 'Compatto (36 x 20)',
              child: GenSwitch(
                value: _sized,
                width: 36,
                height: 20,
                onChanged: (v) => setState(() => _sized = v),
              ),
            ),
            DemoTile(
              label: 'Default (44 x 24)',
              child: GenSwitch(
                value: _sized,
                onChanged: (v) => setState(() => _sized = v),
              ),
            ),
            DemoTile(
              label: 'Grande (60 x 32)',
              child: GenSwitch(
                value: _sized,
                width: 60,
                height: 32,
                margin: 3,
                onChanged: (v) => setState(() => _sized = v),
              ),
            ),
          ],
        ),

        // ── Colori ──────────────────────────────────────────────────────────
        DemoGroup(
          title: 'Colori',
          description: 'thumbColor, checkedTrackColor (on), uncheckedTrackColor (off).',
          items: [
            DemoTile(
              label: 'checkedTrackColor: primary',
              child: GenSwitch(
                value: _colored,
                onChanged: (v) => setState(() => _colored = v),
                checkedTrackColor: t.primary,
              ),
            ),
            DemoTile(
              label: 'thumbColor: card',
              child: GenSwitch(
                value: _colored,
                onChanged: (v) => setState(() => _colored = v),
                thumbColor: t.secondaryBackground,
              ),
            ),
            DemoTile(
              label: 'uncheckedTrackColor: border',
              child: GenSwitch(
                value: false,
                onChanged: (_) {},
                uncheckedTrackColor: t.borderColor,
              ),
            ),
          ],
        ),

        // ── Direction ───────────────────────────────────────────────────────
        DemoGroup(
          title: 'Direction (RTL)',
          description: 'direction:rtl inverte layout: label a sinistra, thumb da destra.',
          items: [
            DemoTile(
              label: 'TextDirection.rtl',
              width: 260,
              child: GenSwitch(
                value: _rtl,
                onChanged: (v) => setState(() => _rtl = v),
                direction: TextDirection.rtl,
                label: const Text('الوضع الليلي'),
              ),
            ),
          ],
        ),

        // ── Gruppo impostazioni ─────────────────────────────────────────────
        DemoGroup(
          title: 'Gruppo impostazioni',
          description: 'Più switch indipendenti che compongono un pannello di preferenze.',
          items: [
            DemoTile(
              label: 'Connettività',
              width: 260,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GenSwitch(
                    value: _wifi,
                    onChanged: (v) => setState(() => _wifi = v),
                    label: const Text('Wi-Fi'),
                  ),
                  SizedBox(height: t.gapSm),
                  GenSwitch(
                    value: _bluetooth,
                    onChanged: (v) => setState(() => _bluetooth = v),
                    label: const Text('Bluetooth'),
                  ),
                  SizedBox(height: t.gapSm),
                  GenSwitch(
                    value: _airplane,
                    onChanged: (v) => setState(() {
                      _airplane = v;
                      if (v) {
                        _wifi = false;
                        _bluetooth = false;
                      }
                    }),
                    label: const Text('Modalità aereo'),
                    sublabel: const Text('Disattiva tutte le radio.'),
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
