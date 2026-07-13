import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;
import 'package:provider/provider.dart';

import '../app/theme_controller.dart';

/// Contenuto del popover "theme playground" nell'header: preset · scala · raggio
/// · modalità colore + reset. Muta il [ThemeController] (Provider); `ExampleApp`
/// ricostruisce il tema live.
class ThemeCustomizer extends StatelessWidget {
  const ThemeCustomizer({super.key});

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    final tc = context.watch<ThemeController>();
    final read = context.read<ThemeController>();

    return SizedBox(
      width: 300,
      child: Padding(
        padding: EdgeInsets.all(t.gapLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _label(t, 'Preset tema'),
            GenSelect<ThemePreset>(
              initialValue: tc.preset,
              minWidth: 0,
              options: [
                for (final p in ThemePreset.values) GenOption(value: p, child: _presetLabel(t, p)),
              ],
              selectedOptionBuilder: (context, value) => _presetLabel(t, value),
              onChanged: (v) => v == null ? null : read.setPreset(v),
            ),
            SizedBox(height: t.gapLg),
            _label(t, 'Scala'),
            GenSegmented<ThemeScale>(
              value: tc.scale,
              onChanged: read.setScale,
              options: [for (final s in ThemeScale.values) GenSegmentedOption(value: s, label: Text(s.label))],
            ),
            SizedBox(height: t.gapLg),
            _label(t, 'Raggio'),
            GenSegmented<ThemeRadius>(
              value: tc.radius,
              onChanged: read.setRadius,
              options: [for (final r in ThemeRadius.values) GenSegmentedOption(value: r, label: Text(r.label))],
            ),
            SizedBox(height: t.gapLg),
            _label(t, 'Modalità colore'),
            GenSegmented<Brightness>(
              value: tc.brightness,
              onChanged: read.setBrightness,
              options: const [
                GenSegmentedOption(value: Brightness.light, label: Text('Chiaro')),
                GenSegmentedOption(value: Brightness.dark, label: Text('Scuro')),
              ],
            ),
            SizedBox(height: t.gapLg * 1.25),
            GenButton(
              width: double.infinity,
              onPressed: read.reset,
              child: const Text('Ripristina predefiniti'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(GenTokens t, String text) => Padding(
        padding: EdgeInsets.only(bottom: t.gapSm),
        child: Text(text, style: t.bodyLabel.copyWith(color: t.primaryText)),
      );

  Widget _presetLabel(GenTokens t, ThemePreset p) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: p.primary ?? t.primary, shape: BoxShape.circle),
          ),
          SizedBox(width: t.gapSm),
          Text(p.label, style: t.bodyText),
        ],
      );
}
