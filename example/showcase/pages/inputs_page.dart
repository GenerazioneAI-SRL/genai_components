import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import '../widgets/showcase_section.dart';

class InputsPage extends StatefulWidget {
  const InputsPage({super.key});

  @override
  State<InputsPage> createState() => _InputsPageState();
}

class _InputsPageState extends State<InputsPage> {
  bool? _check1 = false;
  bool? _check2 = true;
  bool? _check3;
  String _radio = 'a';
  bool _toggle = true;
  double _slider = 35;
  RangeValues _range = const RangeValues(20, 70);
  String? _select = 'eur';
  List<String> _multiSelect = ['mario'];
  DateTime? _date;
  DateTimeRange? _dateRange;
  DateTime? _month;
  List<String> _tags = ['design', 'system'];
  String _otp = '';
  Color _color = const Color(0xFF7C3AED);
  List<GenaiUploadedFile> _files = const [];

  @override
  Widget build(BuildContext context) {
    return ShowcaseScaffold(
      title: 'Inputs',
      description:
          'TextField (5 varianti) · Checkbox tri-state · Radio · Toggle · Slider/Range · Select (5 modi) · DatePicker · FileUpload · TagInput · OTP · ColorPicker.',
      children: [
        ShowcaseSection(
          title: 'GenaiTextField',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              GenaiTextField(label: 'Nome', hint: 'Mario', helperText: 'Visibile nel profilo'),
              SizedBox(height: 12),
              GenaiTextField.password(label: 'Password', hint: '••••••••'),
              SizedBox(height: 12),
              GenaiTextField.search(hint: 'Cerca clienti...'),
              SizedBox(height: 12),
              GenaiTextField.numeric(label: 'Importo', hint: '0,00', suffixText: '€'),
              SizedBox(height: 12),
              GenaiTextField.multiline(label: 'Note', hint: 'Aggiungi note...', minLines: 3),
              SizedBox(height: 12),
              GenaiTextField(label: 'Email', initialValue: 'mario@invalido', errorText: 'Email non valida'),
              SizedBox(height: 12),
              GenaiTextField(label: 'Disabled', initialValue: 'Read-only', isDisabled: true),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiCheckbox — tri-state',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GenaiCheckbox(
                value: _check1,
                label: 'Ricorda credenziali',
                onChanged: (v) => setState(() => _check1 = v),
              ),
              GenaiCheckbox(
                value: _check2,
                label: 'Iscriviti alla newsletter',
                description: 'Riceverai una mail al mese.',
                onChanged: (v) => setState(() => _check2 = v),
              ),
              GenaiCheckbox(
                value: _check3,
                label: 'Indeterminato',
                onChanged: (v) => setState(() => _check3 = v),
              ),
              const GenaiCheckbox(value: true, label: 'Disabilitato', isDisabled: true),
              const GenaiCheckbox(value: false, label: 'Errore', hasError: true),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiRadioGroup',
          child: GenaiRadioGroup<String>(
            value: _radio,
            onChanged: (v) => setState(() => _radio = v ?? _radio),
            options: const [
              GenaiRadioOption(value: 'a', label: 'Standard', description: 'Spedizione 3-5 giorni'),
              GenaiRadioOption(value: 'b', label: 'Express', description: 'Spedizione 24h'),
              GenaiRadioOption(value: 'c', label: 'Ritiro in negozio', description: 'Disponibile in 2 ore'),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiToggle',
          child: Column(
            children: [
              GenaiToggle(
                value: _toggle,
                label: 'Notifiche push',
                description: 'Ricevi avvisi sul dispositivo.',
                onChanged: (v) => setState(() => _toggle = v),
              ),
              const GenaiToggle(value: false, label: 'Disabilitato', isDisabled: true),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiSlider & RangeSlider',
          child: Column(
            children: [
              GenaiSlider(
                value: _slider,
                min: 0,
                max: 100,
                onChanged: (v) => setState(() => _slider = v),
              ),
              const SizedBox(height: 16),
              GenaiRangeSlider(
                values: _range,
                min: 0,
                max: 100,
                onChanged: (v) => setState(() => _range = v),
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiSelect',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GenaiSelect<String>(
                label: 'Valuta',
                value: _select,
                onChanged: (v) => setState(() => _select = v),
                clearable: true,
                options: const [
                  GenaiSelectOption(value: 'eur', label: 'Euro (EUR)'),
                  GenaiSelectOption(value: 'usd', label: 'US Dollar (USD)'),
                  GenaiSelectOption(value: 'gbp', label: 'British Pound (GBP)'),
                ],
              ),
              const SizedBox(height: 12),
              GenaiSelect<String>.multi(
                label: 'Membri team',
                values: _multiSelect,
                onMultiChanged: (v) => setState(() => _multiSelect = v),
                options: const [
                  GenaiSelectOption(value: 'mario', label: 'Mario Rossi'),
                  GenaiSelectOption(value: 'luca', label: 'Luca Bianchi'),
                  GenaiSelectOption(value: 'anna', label: 'Anna Verdi'),
                ],
              ),
              const SizedBox(height: 12),
              GenaiSelect<String>.searchable(
                label: 'Cerca città',
                hint: 'Digita per cercare',
                onChanged: (_) {},
                options: const [
                  GenaiSelectOption(value: 'mi', label: 'Milano'),
                  GenaiSelectOption(value: 'rm', label: 'Roma'),
                  GenaiSelectOption(value: 'na', label: 'Napoli'),
                  GenaiSelectOption(value: 'to', label: 'Torino'),
                ],
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiDatePicker',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GenaiDatePicker(
                label: 'Data',
                value: _date,
                onChanged: (v) => setState(() => _date = v),
              ),
              const SizedBox(height: 12),
              GenaiDateRangePicker(
                label: 'Periodo',
                value: _dateRange,
                onChanged: (v) => setState(() => _dateRange = v),
              ),
              const SizedBox(height: 12),
              GenaiMonthPicker(
                label: 'Mese',
                value: _month,
                onChanged: (v) => setState(() => _month = v),
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiFileUpload',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GenaiFileUpload(
                label: 'Allegato',
                files: _files,
                onChanged: (v) => setState(() => _files = v),
                onPickRequested: () async => [
                  GenaiUploadedFile(name: 'preventivo.pdf', sizeBytes: 254300),
                ],
              ),
              const SizedBox(height: 12),
              GenaiFileUpload.multi(
                label: 'Allegati multipli',
                files: _files,
                onChanged: (v) => setState(() => _files = v),
                onPickRequested: () async => [
                  GenaiUploadedFile(name: 'logo.png', sizeBytes: 12400),
                  GenaiUploadedFile(name: 'note.txt', sizeBytes: 800),
                ],
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiTagInput',
          child: GenaiTagInput(
            label: 'Tag',
            tags: _tags,
            onChanged: (v) => setState(() => _tags = v),
            suggestions: const ['flutter', 'design', 'system', 'ui', 'token'],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiOTPInput',
          child: GenaiOTPInput(
            length: 6,
            value: _otp,
            onChanged: (v) => setState(() => _otp = v),
          ),
        ),
        ShowcaseSection(
          title: 'GenaiColorPicker',
          child: GenaiColorPicker(
            label: 'Colore brand',
            value: _color,
            onChanged: (v) => setState(() => _color = v),
          ),
        ),
        const SizedBox(height: 24),
        const Wrap(spacing: 12, children: [
          GenaiBadge.dot(),
          GenaiBadge.text(text: 'Beta'),
        ]),
        const SizedBox(height: 24),
        Wrap(spacing: 12, children: [
          GenaiButton.primary(
              label: 'Reset',
              onPressed: () {
                setState(() {
                  _check1 = false;
                  _check2 = true;
                  _check3 = null;
                  _radio = 'a';
                  _toggle = true;
                  _slider = 35;
                  _range = const RangeValues(20, 70);
                  _select = 'eur';
                  _multiSelect = ['mario'];
                  _date = null;
                  _dateRange = null;
                  _month = null;
                  _tags = ['design', 'system'];
                  _otp = '';
                  _files = const [];
                });
              }),
          Text('OTP: $_otp', style: context.typography.code.copyWith(color: context.colors.textSecondary)),
        ]),
      ],
    );
  }
}
