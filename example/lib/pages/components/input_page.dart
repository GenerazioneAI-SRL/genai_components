import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;

import '../../shared/demo_page.dart';

/// Showcase esaustiva di [GenInput] (=GenInput): placeholder, leading/trailing,
/// password con toggle, stati (disabled/readOnly/errore), vincoli (maxLength),
/// slot top/bottom per label esterna e helper. Stato locale posseduto dalla pagina
/// (visibilità password).
class InputShowcase extends StatefulWidget {
  const InputShowcase({super.key});

  @override
  State<InputShowcase> createState() => _InputShowcaseState();
}

class _InputShowcaseState extends State<InputShowcase> {
  bool _obscure = true;
  final _readOnlyController = TextEditingController(text: 'Valore in sola lettura');

  @override
  void dispose() {
    _readOnlyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    return DemoPage(
      children: [
        DemoGroup(
          title: 'Base',
          description: 'placeholder, valore iniziale, allineamento del testo.',
          items: const [
            DemoTile(
              width: 280,
              label: 'placeholder',
              child: GenInput(placeholder: Text('Scrivi qui…')),
            ),
            DemoTile(
              width: 280,
              label: 'initialValue',
              child: GenInput(initialValue: 'Mario Rossi'),
            ),
            DemoTile(
              width: 280,
              label: 'textAlign: center',
              child: GenInput(placeholder: Text('Centrato'), textAlign: TextAlign.center),
            ),
          ],
        ),
        DemoGroup(
          title: 'Leading / Trailing',
          description: 'Icone o testo prima e dopo il campo (prefix/suffix).',
          items: const [
            DemoTile(
              width: 280,
              label: 'leading (icona)',
              child: GenInput(
                placeholder: Text('Cerca…'),
                leading: Icon(
                  LucideIcons.search,
                ),
              ),
            ),
            DemoTile(
              width: 280,
              label: 'trailing (icona)',
              child: GenInput(
                placeholder: Text('Email'),
                trailing: Icon(LucideIcons.mail, size: 16),
              ),
            ),
            DemoTile(
              width: 280,
              label: 'leading + trailing',
              child: GenInput(
                placeholder: Text('Importo'),
                leading: Icon(LucideIcons.dollarSign, size: 16),
                trailing: Icon(LucideIcons.check, size: 16),
              ),
            ),
            DemoTile(
              width: 280,
              label: 'prefix / suffix (testo)',
              child: GenInput(
                placeholder: Text('miosito'),
                leading: Text('https://'),
                trailing: Text('.com'),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Password',
          description: 'obscureText con toggle visibilità nel trailing.',
          items: [
            DemoTile(
              width: 280,
              label: 'obscureText + toggle',
              child: GenInput(
                placeholder: const Text('Password'),
                obscureText: _obscure,
                leading: const Icon(LucideIcons.lock, size: 16),
                trailing: GestureDetector(
                  onTap: () => setState(() => _obscure = !_obscure),
                  child: Icon(_obscure ? LucideIcons.eye : LucideIcons.eyeOff, size: 16),
                ),
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Stati',
          description: 'disabled, sola lettura, errore (helper rosso in slot bottom).',
          items: [
            const DemoTile(
              width: 280,
              label: 'enabled: false',
              child: GenInput(placeholder: Text('Disabilitato'), enabled: false),
            ),
            DemoTile(
              width: 280,
              label: 'readOnly',
              child: GenInput(controller: _readOnlyController, readOnly: true),
            ),
            DemoTile(
              width: 280,
              label: 'errore (label + helper esterni)',
              // Label e helper FUORI dal bordo del campo (Column attorno al
              // GenInput), non negli slot top/bottom di GenInput che stanno
              // dentro la decorazione.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Email', style: t.smallLabel.copyWith(color: t.primaryText)),
                  const SizedBox(height: 6),
                  GenInput(
                    placeholder: const Text('nome@dominio'),
                    trailing: Icon(LucideIcons.circleAlert, size: 16, color: t.danger),
                  ),
                  const SizedBox(height: 6),
                  Text('Indirizzo email non valido', style: t.smallText.copyWith(color: t.danger)),
                ],
              ),
            ),
          ],
        ),
        DemoGroup(
          title: 'Vincoli',
          description: 'maxLength, keyboardType, textCapitalization.',
          items: const [
            DemoTile(
              width: 280,
              label: 'maxLength: 10',
              child: GenInput(placeholder: Text('Max 10 caratteri'), maxLength: 10),
            ),
            DemoTile(
              width: 280,
              label: 'keyboardType: number',
              child: GenInput(placeholder: Text('Solo numeri'), keyboardType: TextInputType.number),
            ),
            DemoTile(
              width: 280,
              label: 'textCapitalization: characters',
              child: GenInput(placeholder: Text('MAIUSCOLO'), textCapitalization: TextCapitalization.characters),
            ),
          ],
        ),
        DemoGroup(
          title: 'Label + helper esterni',
          description: 'Label sopra e testo di aiuto sotto il campo (fuori dal bordo), '
              'via Column che avvolge GenInput. Gli slot top/bottom di GenInput invece '
              'stanno DENTRO il bordo (integrati nel campo).',
          items: [
            DemoTile(
              width: 280,
              label: 'label + helper',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('Username', style: t.smallLabel.copyWith(color: t.primaryText)),
                  ),
                  const GenInput(placeholder: Text('@username')),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('Sarà pubblico sul tuo profilo.', style: t.smallText),
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
