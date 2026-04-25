import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import '../widgets/showcase_section.dart';

class InputsPage extends StatefulWidget {
  const InputsPage({super.key});

  @override
  State<InputsPage> createState() => _InputsPageState();
}

class _InputsPageState extends State<InputsPage> {
  bool _cb = false;
  bool _cbMixed = true; // rendered as indeterminate via null
  String _radio = 'md';
  bool _toggle = false;
  double _slider = 0.4;
  String? _select = 'obbligatoria';
  Color _color = const Color(0xFF0B5FD9);
  List<String> _tags = ['Sicurezza', 'Privacy'];

  @override
  Widget build(BuildContext context) {
    return ShowcaseScaffold(
      title: 'Inputs',
      description:
          'Form primitives v3 — TextField, Label, Checkbox, Radio, Toggle, '
          'Slider, Select, Combobox, Textarea + specializzati.',
      children: [
        ShowcaseSection(
          title: 'Text field',
          subtitle:
              'outline (default) / filled / ghost. States disabled/error.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const GenaiTextField(
                label: 'Nome completo',
                hintText: 'Mario Rossi',
                helperText: 'Come appare sul certificato.',
              ),
              SizedBox(height: context.spacing.s12),
              const GenaiTextField(
                label: 'Codice corso',
                hintText: 'COURSE-XYZ',
                variant: GenaiTextFieldVariant.filled,
              ),
              SizedBox(height: context.spacing.s12),
              const GenaiTextField(
                label: 'Email',
                hintText: 'you@forma.it',
                errorText: 'Email non valida',
              ),
              SizedBox(height: context.spacing.s12),
              const GenaiTextField(
                label: 'Disabilitato',
                hintText: 'read only',
                isDisabled: true,
              ),
              SizedBox(height: context.spacing.s12),
              GenaiTextField.password(
                label: 'Password',
                hintText: 'min 8 caratteri',
              ),
              SizedBox(height: context.spacing.s12),
              GenaiTextField.search(hintText: 'Cerca corsi…'),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Label',
          subtitle: 'Helper per etichette uniformi.',
          child: const ShowcaseRow(
            label: 'variants',
            children: [
              GenaiLabel(text: 'Default'),
              GenaiLabel(text: 'Required', isRequired: true),
              GenaiLabel(text: 'Disabled', isDisabled: true),
              GenaiLabel(
                text: 'Uppercase',
                uppercase: true,
                size: GenaiLabelSize.sm,
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Checkbox / Radio / Toggle',
          subtitle: 'Selection primitives.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GenaiCheckbox(
                value: _cb,
                label: 'Ricevi promemoria via email',
                description: 'Invieremo una notifica 7 giorni prima.',
                onChanged: (v) => setState(() => _cb = v ?? false),
              ),
              SizedBox(height: context.spacing.s8),
              GenaiCheckbox(
                value: _cbMixed ? null : false,
                label: 'Tutti i corsi',
                onChanged: (v) => setState(() => _cbMixed = !_cbMixed),
              ),
              SizedBox(height: context.spacing.s16),
              GenaiRadio<String>(
                value: _radio,
                onChanged: (v) => setState(() => _radio = v),
                options: const [
                  GenaiRadioOption(
                    value: 'sm',
                    label: 'Small',
                    description: 'Dense tables.',
                  ),
                  GenaiRadioOption(
                    value: 'md',
                    label: 'Medium',
                    description: 'Default.',
                  ),
                  GenaiRadioOption(
                    value: 'lg',
                    label: 'Large',
                    description: 'Accessibility.',
                  ),
                ],
              ),
              SizedBox(height: context.spacing.s16),
              GenaiToggle(
                value: _toggle,
                label: 'Modalità AI avanzata',
                description: 'Suggerisce prossimi passi in modo proattivo.',
                onChanged: (v) => setState(() => _toggle = v),
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Slider',
          subtitle: 'Con label + valore tabular.',
          child: GenaiSlider(
            label: 'Soglia alert (ore mancanti)',
            value: _slider,
            onChanged: (v) => setState(() => _slider = v),
            min: 0,
            max: 1,
            divisions: 10,
          ),
        ),
        ShowcaseSection(
          title: 'Select & Combobox',
          subtitle: 'Dropdown + ricerca opzionale.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GenaiSelect<String>(
                label: 'Tipologia',
                value: _select,
                options: const [
                  GenaiSelectOption(
                    value: 'obbligatoria',
                    label: 'Obbligatoria',
                  ),
                  GenaiSelectOption(value: 'fnc', label: 'Fondo N.C.'),
                  GenaiSelectOption(value: 'tirocinio', label: 'Tirocinio'),
                  GenaiSelectOption(
                    value: 'apprendistato',
                    label: 'Apprendistato',
                  ),
                ],
                onChanged: (v) => setState(() => _select = v),
              ),
              SizedBox(height: context.spacing.s12),
              GenaiCombobox<String>(
                label: 'Corso (ricerca)',
                value: null,
                options: const [
                  GenaiSelectOption(
                    value: 'sec',
                    label: 'Sicurezza e guardrail',
                  ),
                  GenaiSelectOption(value: 'pri', label: 'Privacy 2026'),
                  GenaiSelectOption(value: 'aml', label: 'Antiriciclaggio'),
                  GenaiSelectOption(value: 'aif', label: 'AI per il business'),
                ],
                onChanged: (_) {},
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Textarea',
          subtitle: 'Multi-riga. Auto-grow controllato.',
          child: const GenaiTextarea(
            label: 'Note',
            hintText: 'Aggiungi note al tuo percorso…',
          ),
        ),
        ShowcaseSection(
          title: 'Specializzati',
          subtitle: 'File upload / Color picker / OTP / Tag input.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GenaiFileUpload(label: 'Allega documento', onPickFiles: () {}),
              SizedBox(height: context.spacing.s12),
              GenaiColorPicker(
                label: 'Accent team',
                value: _color,
                onChanged: (c) => setState(() => _color = c),
              ),
              SizedBox(height: context.spacing.s12),
              const GenaiOtpInput(label: 'Codice di verifica', length: 6),
              SizedBox(height: context.spacing.s12),
              GenaiTagInput(
                label: 'Tag corso',
                values: _tags,
                onChanged: (v) => setState(() => _tags = v),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
