import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;

import '../../shared/demo_page.dart';

/// Showcase esaustiva di [GenSlider] (= GenSlider).
///
/// Copre: base 0-1, min/max custom, divisions (snap), disabled, colori (track /
/// thumb), trackHeight e thumbRadius, onChangeStart/End. Nota: GenSlider è a
/// valore singolo (nessun range). Ogni slider vive in un SizedBox(width: 280)
/// perché richiede una larghezza limitata. Interattivo: stato locale per slider.
class SliderShowcase extends StatefulWidget {
  const SliderShowcase({super.key});

  @override
  State<SliderShowcase> createState() => _SliderShowcaseState();
}

class _SliderShowcaseState extends State<SliderShowcase> {
  double _base = 0.4;
  double _range = 40; // 0..100
  double _temp = 22; // 16..30
  double _divisions = 3; // 0..5, step 1
  double _colored = 0.6;
  double _thick = 0.5;
  double _dragged = 0.3;
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);

    return DemoPage(
      children: [
        // ── Base ────────────────────────────────────────────────────────────
        DemoGroup(
          title: 'Base (0.0 – 1.0)',
          description: 'initialValue obbligatorio (o controller). Range di default 0..1.',
          items: [
            DemoTile(
              label: 'Valore: ${_base.toStringAsFixed(2)}',
              child: SizedBox(
                width: 280,
                child: GenSlider(
                  initialValue: _base,
                  onChanged: (v) => setState(() => _base = v),
                ),
              ),
            ),
          ],
        ),

        // ── Min / Max ───────────────────────────────────────────────────────
        DemoGroup(
          title: 'Min / Max',
          description: 'min e max ridefiniscono il dominio del valore.',
          items: [
            DemoTile(
              label: 'Percentuale (0 – 100): ${_range.round()}%',
              child: SizedBox(
                width: 280,
                child: GenSlider(
                  initialValue: _range,
                  min: 0,
                  max: 100,
                  onChanged: (v) => setState(() => _range = v),
                ),
              ),
            ),
            DemoTile(
              label: 'Temperatura (16 – 30): ${_temp.round()}°C',
              child: SizedBox(
                width: 280,
                child: GenSlider(
                  initialValue: _temp,
                  min: 16,
                  max: 30,
                  onChanged: (v) => setState(() => _temp = v),
                ),
              ),
            ),
          ],
        ),

        // ── Divisions ───────────────────────────────────────────────────────
        DemoGroup(
          title: 'Divisions (snap)',
          description: 'divisions divide il range in step discreti con tacche visibili. '
              'label mostra un tooltip sopra il thumb durante il drag.',
          items: [
            DemoTile(
              label: 'Step: ${_divisions.round()} / 5',
              child: SizedBox(
                width: 280,
                child: GenSlider(
                  initialValue: _divisions,
                  min: 0,
                  max: 5,
                  divisions: 5,
                  label: '${_divisions.round()}',
                  onChanged: (v) => setState(() => _divisions = v),
                ),
              ),
            ),
          ],
        ),

        // ── Disabled ────────────────────────────────────────────────────────
        DemoGroup(
          title: 'Disabled',
          description: 'enabled:false => track e thumb dimmati, nessuna interazione.',
          items: [
            DemoTile(
              label: 'Disabled',
              child: SizedBox(
                width: 280,
                child: GenSlider(
                  initialValue: 0.5,
                  enabled: false,
                  onChanged: (_) {},
                ),
              ),
            ),
            DemoTile(
              label: 'Disabled + divisions',
              child: SizedBox(
                width: 280,
                child: GenSlider(
                  initialValue: 2,
                  min: 0,
                  max: 4,
                  divisions: 4,
                  enabled: false,
                  onChanged: (_) {},
                ),
              ),
            ),
          ],
        ),

        // ── Colori ──────────────────────────────────────────────────────────
        DemoGroup(
          title: 'Colori',
          description: 'activeTrackColor, inactiveTrackColor, thumbColor, thumbBorderColor.',
          items: [
            DemoTile(
              label: 'Track / thumb custom: ${_colored.toStringAsFixed(2)}',
              child: SizedBox(
                width: 280,
                child: GenSlider(
                  initialValue: _colored,
                  activeTrackColor: t.primary,
                  inactiveTrackColor: t.borderColor,
                  thumbColor: t.secondaryBackground,
                  thumbBorderColor: t.primary,
                  onChanged: (v) => setState(() => _colored = v),
                ),
              ),
            ),
          ],
        ),

        // ── Dimensioni ──────────────────────────────────────────────────────
        DemoGroup(
          title: 'trackHeight e thumbRadius',
          description: 'trackHeight (default 8) e thumbRadius (default 10) regolano lo spessore.',
          items: [
            DemoTile(
              label: 'Sottile (track 4, thumb 8)',
              child: SizedBox(
                width: 280,
                child: GenSlider(
                  initialValue: _thick,
                  trackHeight: 4,
                  thumbRadius: 8,
                  onChanged: (v) => setState(() => _thick = v),
                ),
              ),
            ),
            DemoTile(
              label: 'Spesso (track 14, thumb 14)',
              child: SizedBox(
                width: 280,
                child: GenSlider(
                  initialValue: _thick,
                  trackHeight: 14,
                  thumbRadius: 14,
                  onChanged: (v) => setState(() => _thick = v),
                ),
              ),
            ),
          ],
        ),

        // ── Callbacks ───────────────────────────────────────────────────────
        DemoGroup(
          title: 'onChangeStart / onChangeEnd',
          description: 'Callback all\'inizio e alla fine del gesto di drag.',
          items: [
            DemoTile(
              label: _dragging
                  ? 'Trascinamento… ${_dragged.toStringAsFixed(2)}'
                  : 'Fermo: ${_dragged.toStringAsFixed(2)}',
              child: SizedBox(
                width: 280,
                child: GenSlider(
                  initialValue: _dragged,
                  onChangeStart: (_) => setState(() => _dragging = true),
                  onChangeEnd: (_) => setState(() => _dragging = false),
                  onChanged: (v) => setState(() => _dragged = v),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
