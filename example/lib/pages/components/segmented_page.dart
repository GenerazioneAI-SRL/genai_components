import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;

import '../../shared/demo_page.dart';

/// Showcase di [GenSegmented] (custom Gen: toggle group a selezione singola).
/// Interattivo → stato locale posseduto dalla pagina.
class SegmentedShowcase extends StatefulWidget {
  const SegmentedShowcase({super.key});

  @override
  State<SegmentedShowcase> createState() => _SegmentedShowcaseState();
}

class _SegmentedShowcaseState extends State<SegmentedShowcase> {
  String _pair = 'on';
  String _size = 'md';
  String _view = 'list';
  Brightness _mode = Brightness.light;

  @override
  Widget build(BuildContext context) => DemoPage(
        children: [
          DemoGroup(
            title: 'Base',
            description: 'Selezione singola. La selezionata ha fill; angoli tondi solo agli estremi.',
            items: [
              DemoTile(
                width: 260,
                label: '2 opzioni',
                child: GenSegmented<String>(
                  value: _pair,
                  onChanged: (v) => setState(() => _pair = v),
                  options: const [
                    GenSegmentedOption(value: 'on', label: Text('On')),
                    GenSegmentedOption(value: 'off', label: Text('Off')),
                  ],
                ),
              ),
              DemoTile(
                width: 320,
                label: '5 opzioni',
                child: GenSegmented<String>(
                  value: _size,
                  onChanged: (v) => setState(() => _size = v),
                  options: const [
                    GenSegmentedOption(value: 'none', label: Text('None')),
                    GenSegmentedOption(value: 'sm', label: Text('SM')),
                    GenSegmentedOption(value: 'md', label: Text('MD')),
                    GenSegmentedOption(value: 'lg', label: Text('LG')),
                    GenSegmentedOption(value: 'xl', label: Text('XL')),
                  ],
                ),
              ),
            ],
          ),
          DemoGroup(
            title: 'Con icone',
            description: 'Le etichette sono widget qualsiasi (icona + testo).',
            items: [
              DemoTile(
                width: 320,
                label: 'icona + testo',
                child: GenSegmented<String>(
                  value: _view,
                  onChanged: (v) => setState(() => _view = v),
                  options: const [
                    GenSegmentedOption(
                      value: 'list',
                      label: _IconLabel(icon: LucideIcons.list, text: 'Lista'),
                    ),
                    GenSegmentedOption(
                      value: 'grid',
                      label: _IconLabel(icon: LucideIcons.layoutGrid, text: 'Griglia'),
                    ),
                  ],
                ),
              ),
              DemoTile(
                width: 160,
                label: 'solo icone',
                child: GenSegmented<Brightness>(
                  value: _mode,
                  onChanged: (v) => setState(() => _mode = v),
                  options: const [
                    GenSegmentedOption(value: Brightness.light, label: GenIcon(LucideIcons.sun, size: 16)),
                    GenSegmentedOption(value: Brightness.dark, label: GenIcon(LucideIcons.moon, size: 16)),
                  ],
                ),
              ),
            ],
          ),
          DemoGroup(
            title: 'Altezza custom',
            description: 'Parametro height (default 36).',
            items: [
              DemoTile(
                width: 260,
                label: 'height: 44',
                child: GenSegmented<String>(
                  height: 44,
                  value: _pair,
                  onChanged: (v) => setState(() => _pair = v),
                  options: const [
                    GenSegmentedOption(value: 'on', label: Text('On')),
                    GenSegmentedOption(value: 'off', label: Text('Off')),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
}

/// Etichetta icona + testo per un'opzione segmentata.
class _IconLabel extends StatelessWidget {
  const _IconLabel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GenIcon(icon, size: 16),
          const SizedBox(width: 6),
          Text(text),
        ],
      );
}
