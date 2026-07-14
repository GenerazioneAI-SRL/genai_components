import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;
import '../../shared/demo_page.dart';

/// Showcase esaustiva di [GenTabs] / [GenTab] (= GenTabs / GenTab).
///
/// Interattivo: `value` + `onChanged` con setState. Copre: base, con content,
/// leading/trailing, tab disabilitato, scrollable, tabBarAlignment.
class TabsShowcase extends StatefulWidget {
  const TabsShowcase({super.key});

  @override
  State<TabsShowcase> createState() => _TabsShowcaseState();
}

class _TabsShowcaseState extends State<TabsShowcase> {
  String _basic = 'account';
  String _content = 'overview';
  String _icons = 'music';
  String _scroll = 'jan';

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);

    Widget pane(String text) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text(text, style: t.bodyText),
        );

    return DemoPage(
      children: [
        // ---- BASE ----
        DemoGroup(
          title: 'Base',
          description: 'value + onChanged (setState). Solo label, senza content.',
          items: [
            DemoTile(
              label: 'account / password',
              width: 420,
              child: GenTabs<String>(
                value: _basic,
                onChanged: (v) => setState(() => _basic = v),
                tabs: [
                  const GenTab<String>(value: 'account', child: Text('Account')),
                  const GenTab<String>(value: 'password', child: Text('Password')),
                ],
              ),
            ),
          ],
        ),

        // ---- CON CONTENT ----
        DemoGroup(
          title: 'Con content',
          description: 'content: pannello mostrato sotto la tab bar quando la tab è attiva.',
          items: [
            DemoTile(
              label: '3 tab con content',
              width: 420,
              child: GenTabs<String>(
                value: _content,
                onChanged: (v) => setState(() => _content = v),
                tabs: [
                  GenTab<String>(
                    value: 'overview',
                    content: pane('Riepilogo generale del progetto.'),
                    child: const Text('Overview'),
                  ),
                  GenTab<String>(
                    value: 'analytics',
                    content: pane('Metriche e statistiche di utilizzo.'),
                    child: const Text('Analytics'),
                  ),
                  GenTab<String>(
                    value: 'reports',
                    content: pane('Report esportabili in PDF.'),
                    child: const Text('Reports'),
                  ),
                ],
              ),
            ),
          ],
        ),

        // ---- LEADING / TRAILING ----
        DemoGroup(
          title: 'Leading / trailing',
          description: 'Icone leading e trailing dentro la tab.',
          items: [
            DemoTile(
              label: 'icone + content',
              width: 420,
              child: GenTabs<String>(
                value: _icons,
                onChanged: (v) => setState(() => _icons = v),
                tabs: [
                  GenTab<String>(
                    value: 'music',
                    leading: const Icon(LucideIcons.music),
                    content: pane('La tua libreria musicale.'),
                    child: const Text('Musica'),
                  ),
                  GenTab<String>(
                    value: 'podcasts',
                    leading: const Icon(LucideIcons.mic),
                    trailing: const Icon(LucideIcons.chevronDown),
                    content: pane('Episodi e abbonamenti.'),
                    child: const Text('Podcast'),
                  ),
                  const GenTab<String>(
                    value: 'live',
                    enabled: false,
                    leading: Icon(LucideIcons.radio),
                    content: Padding(padding: EdgeInsets.all(16), child: Text('Live non disponibile.')),
                    child: Text('Live (off)'),
                  ),
                ],
              ),
            ),
          ],
        ),

        // ---- SCROLLABLE ----
        DemoGroup(
          title: 'Scrollable',
          description: 'scrollable:true: molte tab scorrono orizzontalmente.',
          items: [
            DemoTile(
              label: '6 mesi scrollabili',
              width: 420,
              child: GenTabs<String>(
                value: _scroll,
                scrollable: true,
                onChanged: (v) => setState(() => _scroll = v),
                tabs: [
                  GenTab<String>(value: 'jan', content: pane('Gennaio'), child: const Text('Gennaio')),
                  GenTab<String>(value: 'feb', content: pane('Febbraio'), child: const Text('Febbraio')),
                  GenTab<String>(value: 'mar', content: pane('Marzo'), child: const Text('Marzo')),
                  GenTab<String>(value: 'apr', content: pane('Aprile'), child: const Text('Aprile')),
                  GenTab<String>(value: 'may', content: pane('Maggio'), child: const Text('Maggio')),
                  GenTab<String>(value: 'jun', content: pane('Giugno'), child: const Text('Giugno')),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
