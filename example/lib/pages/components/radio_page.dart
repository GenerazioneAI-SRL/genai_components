import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;

import '../../shared/demo_page.dart';

/// Showcase esaustiva di [GenRadioGroup] / [GenRadio] (= GenRadioGroup /
/// GenRadio).
///
/// Copre: gruppo base verticale/orizzontale, label + sublabel, disabled (group e
/// singolo item), size / circleSize / color, spacing, direction RTL. Interattivo:
/// ogni gruppo ha il proprio valore selezionato in stato locale.
class RadioShowcase extends StatefulWidget {
  const RadioShowcase({super.key});

  @override
  State<RadioShowcase> createState() => _RadioShowcaseState();
}

class _RadioShowcaseState extends State<RadioShowcase> {
  String? _vertical = 'a';
  String? _horizontal = 'sm';
  String? _rich = 'card';
  String? _sized = 'one';
  String? _colored = 'x';
  String? _spaced = '1';
  String? _rtl = 'yes';
  String? _partial = 'free';

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);

    return DemoPage(
      children: [
        // ── Verticale (default) ─────────────────────────────────────────────
        DemoGroup(
          title: 'Verticale (default)',
          description: 'axis:Axis.vertical. Un solo item selezionabile nel gruppo.',
          items: [
            DemoTile(
              label: 'Selezione: ${_vertical ?? '—'}',
              width: 260,
              child: GenRadioGroup<String>(
                initialValue: _vertical,
                onChanged: (v) => setState(() => _vertical = v),
                items: const [
                  GenRadio(value: 'a', label: Text('Opzione A')),
                  GenRadio(value: 'b', label: Text('Opzione B')),
                  GenRadio(value: 'c', label: Text('Opzione C')),
                ],
              ),
            ),
          ],
        ),

        // ── Orizzontale ─────────────────────────────────────────────────────
        DemoGroup(
          title: 'Orizzontale',
          description: 'axis:Axis.horizontal — items disposti in riga (wrap).',
          items: [
            DemoTile(
              label: 'Taglia: ${_horizontal ?? '—'}',
              width: 320,
              child: GenRadioGroup<String>(
                axis: Axis.horizontal,
                initialValue: _horizontal,
                spacing: 16,
                onChanged: (v) => setState(() => _horizontal = v),
                items: const [
                  GenRadio(value: 'sm', label: Text('S')),
                  GenRadio(value: 'md', label: Text('M')),
                  GenRadio(value: 'lg', label: Text('L')),
                  GenRadio(value: 'xl', label: Text('XL')),
                ],
              ),
            ),
          ],
        ),

        // ── Label + sublabel ────────────────────────────────────────────────
        DemoGroup(
          title: 'Label e sublabel',
          description: 'Ogni radio può avere label + descrizione secondaria.',
          items: [
            DemoTile(
              label: 'Piano: ${_rich ?? '—'}',
              width: 300,
              child: GenRadioGroup<String>(
                initialValue: _rich,
                spacing: 12,
                onChanged: (v) => setState(() => _rich = v),
                items: const [
                  GenRadio(
                    value: 'card',
                    label: Text('Carta di credito'),
                    sublabel: Text('Addebito immediato, ricevuta via email.'),
                  ),
                  GenRadio(
                    value: 'paypal',
                    label: Text('PayPal'),
                    sublabel: Text('Reindirizzamento al portale PayPal.'),
                  ),
                  GenRadio(
                    value: 'transfer',
                    label: Text('Bonifico'),
                    sublabel: Text('Elaborazione in 1-2 giorni lavorativi.'),
                  ),
                ],
              ),
            ),
          ],
        ),

        // ── Disabled ────────────────────────────────────────────────────────
        DemoGroup(
          title: 'Disabled',
          description: 'enabled:false sul gruppo disabilita tutto; oppure sul singolo item.',
          items: [
            DemoTile(
              label: 'Gruppo disabilitato',
              width: 220,
              child: const GenRadioGroup<String>(
                enabled: false,
                initialValue: 'b',
                items: [
                  GenRadio(value: 'a', label: Text('Opzione A')),
                  GenRadio(value: 'b', label: Text('Opzione B')),
                ],
              ),
            ),
            DemoTile(
              label: 'Item singolo disabilitato',
              width: 220,
              child: GenRadioGroup<String>(
                initialValue: _partial,
                spacing: 8,
                onChanged: (v) => setState(() => _partial = v),
                items: const [
                  GenRadio(value: 'free', label: Text('Free')),
                  GenRadio(value: 'pro', label: Text('Pro')),
                  GenRadio(
                    value: 'enterprise',
                    enabled: false,
                    label: Text('Enterprise (contattaci)'),
                  ),
                ],
              ),
            ),
          ],
        ),

        // ── Size / circleSize / color ───────────────────────────────────────
        DemoGroup(
          title: 'Size, circleSize e color',
          description: 'size = box esterno (16), circleSize = pallino interno (10), color = pallino.',
          items: [
            DemoTile(
              label: 'size / circleSize',
              width: 260,
              child: GenRadioGroup<String>(
                initialValue: _sized,
                spacing: 10,
                onChanged: (v) => setState(() => _sized = v),
                items: const [
                  GenRadio(value: 'one', size: 14, circleSize: 8, label: Text('Piccolo')),
                  GenRadio(value: 'two', label: Text('Default')),
                  GenRadio(value: 'three', size: 22, circleSize: 14, label: Text('Grande')),
                ],
              ),
            ),
            DemoTile(
              label: 'color: primary',
              width: 220,
              child: GenRadioGroup<String>(
                initialValue: _colored,
                spacing: 8,
                onChanged: (v) => setState(() => _colored = v),
                items: [
                  GenRadio(value: 'x', color: t.primary, label: const Text('Brand')),
                  GenRadio(value: 'y', color: t.danger, label: const Text('Danger')),
                ],
              ),
            ),
          ],
        ),

        // ── Spacing ─────────────────────────────────────────────────────────
        DemoGroup(
          title: 'Spacing',
          description: 'spacing = distanza main-axis fra gli item del gruppo.',
          items: [
            DemoTile(
              label: 'spacing: 20',
              width: 260,
              child: GenRadioGroup<String>(
                initialValue: _spaced,
                spacing: 20,
                onChanged: (v) => setState(() => _spaced = v),
                items: const [
                  GenRadio(value: '1', label: Text('Primo')),
                  GenRadio(value: '2', label: Text('Secondo')),
                  GenRadio(value: '3', label: Text('Terzo')),
                ],
              ),
            ),
          ],
        ),

        // ── Direction ───────────────────────────────────────────────────────
        DemoGroup(
          title: 'Direction (RTL)',
          description: 'direction:rtl sul singolo radio posiziona la label a sinistra.',
          items: [
            DemoTile(
              label: 'TextDirection.rtl',
              width: 260,
              child: GenRadioGroup<String>(
                initialValue: _rtl,
                spacing: 8,
                onChanged: (v) => setState(() => _rtl = v),
                items: const [
                  GenRadio(value: 'yes', direction: TextDirection.rtl, label: Text('نعم')),
                  GenRadio(value: 'no', direction: TextDirection.rtl, label: Text('لا')),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
