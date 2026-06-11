import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart' hide WidgetBuilder;
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Confronto default vs compact: bottoni, campi testo, dropdown.
class CompactScreen extends StatelessWidget {
  const CompactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);

    Widget section(String title, Widget normal, Widget compact) {
      return Padding(
        padding: EdgeInsets.only(bottom: theme.gap2Xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.heading4),
            SizedBox(height: theme.gapMd),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Standard (isCompact: false)', style: theme.smallLabel),
                    SizedBox(height: theme.gapSm),
                    normal,
                  ]),
                ),
                SizedBox(width: theme.gap2Xl),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Compact (default)', style: theme.smallLabel),
                    SizedBox(height: theme.gapSm),
                    compact,
                  ]),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(theme.gap2Xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          section(
            'CLButton',
            Wrap(spacing: theme.gapSm, runSpacing: theme.gapSm, children: [
              CLButton.primary(context: context, text: 'Salva', icon: LucideIcons.check, isCompact: false, onTap: () {}),
              CLOutlineButton.primary(context: context, text: 'Annulla', isCompact: false, onTap: () {}),
              CLSoftButton.primary(context: context, text: 'Soft', isCompact: false, onTap: () {}),
              CLGhostButton.primary(context: context, text: 'Ghost', isCompact: false, onTap: () {}),
            ]),
            Wrap(spacing: theme.gapSm, runSpacing: theme.gapSm, children: [
              CLButton.primary(context: context, text: 'Salva', icon: LucideIcons.check, onTap: () {}),
              CLOutlineButton.primary(context: context, text: 'Annulla', onTap: () {}),
              CLSoftButton.primary(context: context, text: 'Soft', onTap: () {}),
              CLGhostButton.primary(context: context, text: 'Ghost', onTap: () {}),
            ]),
          ),
          section(
            'CLTextField',
            Column(children: [
              CLTextField(controller: TextEditingController(), labelText: 'Nome', isCompact: false),
              SizedBox(height: theme.gapSm),
              CLTextField.date(
                controller: TextEditingController(),
                labelText: 'Data',
                isCompact: false,
                onDateTimeSelected: (_) {},
              ),
            ]),
            Column(children: [
              CLTextField(controller: TextEditingController(), labelText: 'Nome'),
              SizedBox(height: theme.gapSm),
              CLTextField.date(
                controller: TextEditingController(),
                labelText: 'Data',
                onDateTimeSelected: (_) {},
              ),
            ]),
          ),
          section(
            'CLDropdown',
            CLDropdown<String>.singleSync(
              hint: 'Stato',
              isCompact: false,
              items: const ['Attivo', 'Sospeso', 'Chiuso'],
              itemBuilder: (_, s) => Text(s),
              valueToShow: (s) => s,
              onSelectItem: (_) {},
            ),
            CLDropdown<String>.singleSync(
              hint: 'Stato',
              items: const ['Attivo', 'Sospeso', 'Chiuso'],
              itemBuilder: (_, s) => Text(s),
              valueToShow: (s) => s,
              onSelectItem: (_) {},
            ),
          ),
        ],
      ),
    );
  }
}
