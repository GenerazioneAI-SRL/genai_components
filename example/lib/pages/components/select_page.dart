import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;

import '../../shared/demo_page.dart';

/// Showcase esaustiva di [GenSelect] (=GenSelect) + [GenOption]: single base,
/// con icone leading nelle opzioni, deselezionabile, con ricerca (withSearch),
/// selezione multipla (multiple), header/footer, disabilitato. Stato locale
/// (valori selezionati, query di ricerca) posseduto dalla pagina.
class SelectShowcase extends StatefulWidget {
  const SelectShowcase({super.key});

  @override
  State<SelectShowcase> createState() => _SelectShowcaseState();
}

class _SelectShowcaseState extends State<SelectShowcase> {
  static const _roles = {'admin': 'Admin', 'viewer': 'Viewer', 'dev': 'Developer'};

  static const _fruits = {
    'apple': 'Mela',
    'banana': 'Banana',
    'orange': 'Arancia',
    'grape': 'Uva',
    'pear': 'Pera',
    'kiwi': 'Kiwi',
    'mango': 'Mango',
  };

  static const _timezones = {
    'utc': ('UTC', LucideIcons.globe),
    'rome': ('Europe/Rome', LucideIcons.mapPin),
    'ny': ('America/New_York', LucideIcons.building),
    'tokyo': ('Asia/Tokyo', LucideIcons.sun),
  };

  String? _role = 'admin';
  String? _tz = 'rome';
  String? _fruit;
  String _query = '';
  Set<String> _multi = {'apple', 'kiwi'};

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);

    final filteredFruits = _fruits.entries
        .where((e) => e.value.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return DemoPage(
      children: [
        DemoGroup(
          title: 'Single',
          description: 'Selezione singola: options + selectedOptionBuilder + placeholder + onChanged.',
          items: [
            DemoTile(
              width: 280,
              label: 'base',
              child: GenSelect<String>(
                placeholder: const Text('Seleziona ruolo'),
                initialValue: _role,
                onChanged: (v) => setState(() => _role = v),
                options: [
                  for (final e in _roles.entries) GenOption(value: e.key, child: Text(e.value)),
                ],
                selectedOptionBuilder: (context, value) => Text(_roles[value] ?? value),
              ),
            ),
            DemoTile(
              width: 280,
              label: 'allowDeselection: true',
              child: GenSelect<String>(
                placeholder: const Text('Ruolo (deselezionabile)'),
                allowDeselection: true,
                onChanged: (v) {},
                options: [
                  for (final e in _roles.entries) GenOption(value: e.key, child: Text(e.value)),
                ],
                selectedOptionBuilder: (context, value) => Text(_roles[value] ?? value),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Opzioni con icona leading',
          description: 'GenIcon dentro il child di ogni GenOption.',
          items: [
            DemoTile(
              width: 280,
              label: 'leading nelle opzioni',
              child: GenSelect<String>(
                placeholder: const Text('Fuso orario'),
                initialValue: _tz,
                onChanged: (v) => setState(() => _tz = v),
                options: [
                  for (final e in _timezones.entries)
                    GenOption(
                      value: e.key,
                      child: Row(
                        children: [
                          GenIcon(e.value.$2, size: 16),
                          const SizedBox(width: 8),
                          Text(e.value.$1),
                        ],
                      ),
                    ),
                ],
                selectedOptionBuilder: (context, value) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GenIcon(_timezones[value]!.$2, size: 16),
                    const SizedBox(width: 8),
                    Text(_timezones[value]!.$1),
                  ],
                ),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Con ricerca',
          description: 'GenSelect.withSearch: onSearchChanged filtra le opzioni.',
          items: [
            DemoTile(
              width: 280,
              label: 'withSearch',
              child: GenSelect<String>.withSearch(
                placeholder: const Text('Cerca frutto'),
                initialValue: _fruit,
                searchPlaceholder: const Text('Digita per filtrare…'),
                onSearchChanged: (q) => setState(() => _query = q),
                onChanged: (v) => setState(() => _fruit = v),
                options: [
                  if (filteredFruits.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('Nessun risultato', style: t.smallText),
                    )
                  else
                    for (final e in filteredFruits) GenOption(value: e.key, child: Text(e.value)),
                ],
                selectedOptionBuilder: (context, value) => Text(_fruits[value] ?? value),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Multipla',
          description: 'GenSelect.multiple: selectedOptionsBuilder + Set di valori.',
          items: [
            DemoTile(
              width: 280,
              label: 'multiple',
              child: GenSelect<String>.multiple(
                placeholder: const Text('Seleziona frutti'),
                initialValues: _multi,
                onChanged: (values) => setState(() => _multi = values),
                options: [
                  for (final e in _fruits.entries) GenOption(value: e.key, child: Text(e.value)),
                ],
                selectedOptionsBuilder: (context, values) =>
                    Text(values.map((v) => _fruits[v] ?? v).join(', ')),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Header / Footer',
          description: 'Widget fissi sopra e sotto la lista di opzioni.',
          items: [
            DemoTile(
              width: 280,
              label: 'header + footer',
              child: GenSelect<String>(
                placeholder: const Text('Ruolo'),
                onChanged: (v) {},
                header: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text('RUOLI DISPONIBILI', style: t.smallLabel),
                ),
                footer: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text('3 elementi', style: t.smallText),
                ),
                options: [
                  for (final e in _roles.entries) GenOption(value: e.key, child: Text(e.value)),
                ],
                selectedOptionBuilder: (context, value) => Text(_roles[value] ?? value),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Disabilitato',
          description: 'enabled: false.',
          items: [
            DemoTile(
              width: 280,
              label: 'enabled: false',
              child: GenSelect<String>(
                enabled: false,
                placeholder: const Text('Non interagibile'),
                onChanged: (v) {},
                options: [
                  for (final e in _roles.entries) GenOption(value: e.key, child: Text(e.value)),
                ],
                selectedOptionBuilder: (context, value) => Text(_roles[value] ?? value),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
