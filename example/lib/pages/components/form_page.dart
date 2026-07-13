import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;

import '../../shared/demo_page.dart';

/// Showcase esaustiva del sistema Form:
/// - [GenForm] (=GenForm) con [GlobalKey]<[GenFormState]>, `saveAndValidate`,
///   `reset` e lettura di `value` (mappa id -> valore).
/// - [GenInputFormField] (=GenInputFormField): label/description/placeholder,
///   validator (required, email, minLength), obscureText, leading, initialValue,
///   enabled/readOnly, onChanged, keyboardType, maxLength.
/// - [GenCheckboxFormField] (=GenCheckboxFormField): inputLabel/inputSublabel,
///   validator "accetta termini", disabilitato.
/// - Extra: `GenSelectFormField` / `GenRadioGroupFormField` (nessun alias Gen
///   dedicato: ammesso il nome Shad) integrati nello stesso form.
///
/// La sezione "interattiva" possiede lo stato del risultato di submit; i singoli
/// campi di showcase sono avvolti ciascuno in un [GenForm] per fornire il
/// contesto necessario alla registrazione.
class FormShowcase extends StatefulWidget {
  const FormShowcase({super.key});

  @override
  State<FormShowcase> createState() => _FormShowcaseState();
}

class _FormShowcaseState extends State<FormShowcase> {
  // Chiave del form interattivo: lo State/Key usa il nome Shad (nessun alias).
  final _formKey = GlobalKey<GenFormState>();

  // Risultato dell'ultimo submit validato (null = nessun submit riuscito).
  Map<String, dynamic>? _submitted;

  static const _countries = {
    'it': 'Italia',
    'fr': 'Francia',
    'de': 'Germania',
    'es': 'Spagna',
  };

  // ── Validators riutilizzabili ──────────────────────────────────────────────
  String? _required(String v) => v.trim().isEmpty ? 'Campo obbligatorio' : null;

  String? _email(String v) {
    if (v.trim().isEmpty) return 'Email obbligatoria';
    final ok = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(v.trim());
    return ok ? null : 'Email non valida';
  }

  String? _minLen(String v, int n) =>
      v.length < n ? 'Minimo $n caratteri' : null;

  void _submit() {
    if (_formKey.currentState!.saveAndValidate()) {
      setState(() => _submitted = _formKey.currentState!.value);
    } else {
      setState(() => _submitted = null);
    }
  }

  void _reset() {
    _formKey.currentState!.reset();
    setState(() => _submitted = null);
  }

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);

    return DemoPage(
      children: [
        // ── 1. FORM INTERATTIVO COMPLETO ────────────────────────────────────
        DemoGroup(
          title: 'Form interattivo',
          description:
              'GlobalKey<GenFormState> + saveAndValidate() + reset(). Campi con '
              'validator (required, email, minLength), checkbox "accetta termini", '
              'errori inline e feedback di submit.',
          items: [
            SizedBox(
              width: 360,
              child: GenForm(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GenInputFormField(
                      id: 'username',
                      label: const Text('Username'),
                      description: const Text('Almeno 3 caratteri.'),
                      placeholder: const Text('mario.rossi'),
                      leading: const GenIcon(LucideIcons.atSign, size: 16),
                      validator: (v) => _required(v) ?? _minLen(v, 3),
                    ),
                    const SizedBox(height: 12),
                    GenInputFormField(
                      id: 'email',
                      label: const Text('Email'),
                      placeholder: const Text('mario@example.com'),
                      keyboardType: TextInputType.emailAddress,
                      validator: _email,
                    ),
                    const SizedBox(height: 12),
                    GenInputFormField(
                      id: 'password',
                      label: const Text('Password'),
                      placeholder: const Text('••••••••'),
                      obscureText: true,
                      validator: (v) => _required(v) ?? _minLen(v, 6),
                    ),
                    const SizedBox(height: 12),
                    GenSelectFormField<String>(
                      id: 'country',
                      label: const Text('Paese'),
                      placeholder: const Text('Seleziona un paese'),
                      options: [
                        for (final e in _countries.entries)
                          GenOption(value: e.key, child: Text(e.value)),
                      ],
                      selectedOptionBuilder: (context, value) =>
                          Text(_countries[value] ?? value),
                      validator: (v) =>
                          v == null ? 'Seleziona un paese' : null,
                    ),
                    const SizedBox(height: 16),
                    GenCheckboxFormField(
                      id: 'terms',
                      initialValue: false,
                      inputLabel: const Text('Accetto i termini di servizio'),
                      inputSublabel:
                          const Text('Richiesto per creare un account.'),
                      validator: (v) =>
                          v ? null : 'Devi accettare i termini',
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: GenButton(
                            leading: const GenIcon(LucideIcons.check),
                            onPressed: _submit,
                            child: const Text('Invia'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GenButton.outline(
                          leading: const GenIcon(LucideIcons.rotateCcw),
                          onPressed: _reset,
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                    if (_submitted != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: t.secondaryBackground,
                          border: Border.all(color: t.borderColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                GenIcon(LucideIcons.circleCheck,
                                    size: 16, color: t.primary),
                                const SizedBox(width: 6),
                                Text('Form inviato', style: t.heading5),
                              ],
                            ),
                            const SizedBox(height: 8),
                            for (final e in _submitted!.entries)
                              Text('${e.key}: ${e.value}',
                                  style: t.smallText),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),

        // ── 2. GenInputFormField: varianti ──────────────────────────────────
        DemoGroup(
          title: 'GenInputFormField',
          description:
              'Varianti del campo input: label, description, placeholder, '
              'initialValue, obscureText, leading, keyboardType, maxLength, '
              'validator (autovalidate always mostra l\'errore inline), '
              'enabled/readOnly.',
          items: [
            _fieldTile(
              'label + description + placeholder',
              GenInputFormField(
                label: const Text('Nome'),
                description: const Text('Come vuoi essere chiamato.'),
                placeholder: const Text('Mario'),
              ),
            ),
            _fieldTile(
              'initialValue',
              GenInputFormField(
                label: const Text('Città'),
                initialValue: 'Milano',
              ),
            ),
            _fieldTile(
              'leading (GenIcon)',
              GenInputFormField(
                label: const Text('Cerca'),
                placeholder: const Text('Filtra…'),
                leading: const GenIcon(LucideIcons.search, size: 16),
              ),
            ),
            _fieldTile(
              'obscureText (password)',
              GenInputFormField(
                label: const Text('Password'),
                obscureText: true,
                placeholder: const Text('••••••••'),
              ),
            ),
            _fieldTile(
              'keyboardType + maxLength',
              GenInputFormField(
                label: const Text('PIN'),
                keyboardType: TextInputType.number,
                maxLength: 4,
                placeholder: const Text('0000'),
              ),
            ),
            _fieldTile(
              'validator (minLength, autovalidate)',
              GenInputFormField(
                label: const Text('Username'),
                placeholder: const Text('min 3 caratteri'),
                autovalidateMode: AutovalidateMode.always,
                validator: (v) => _minLen(v, 3),
              ),
            ),
            _fieldTile(
              'onChanged',
              _OnChangedInput(),
            ),
            _fieldTile(
              'enabled: false',
              GenInputFormField(
                label: const Text('Disabilitato'),
                enabled: false,
                initialValue: 'Non modificabile',
              ),
            ),
            _fieldTile(
              'readOnly: true',
              GenInputFormField(
                label: const Text('Sola lettura'),
                readOnly: true,
                initialValue: 'Selezionabile, non editabile',
              ),
            ),
          ],
        ),

        // ── 3. GenCheckboxFormField: varianti ───────────────────────────────
        DemoGroup(
          title: 'GenCheckboxFormField',
          description:
              'Checkbox come form field: inputLabel, inputSublabel, description, '
              'validator (accetta obbligatorio), initialValue, disabilitato.',
          items: [
            _fieldTile(
              'inputLabel',
              GenCheckboxFormField(
                initialValue: false,
                inputLabel: const Text('Iscrivimi alla newsletter'),
              ),
            ),
            _fieldTile(
              'inputLabel + inputSublabel',
              GenCheckboxFormField(
                initialValue: true,
                inputLabel: const Text('Notifiche push'),
                inputSublabel:
                    const Text('Ricevi aggiornamenti in tempo reale.'),
              ),
            ),
            _fieldTile(
              'validator (accetta, autovalidate)',
              GenCheckboxFormField(
                initialValue: false,
                inputLabel: const Text('Accetto la privacy policy'),
                autovalidateMode: AutovalidateMode.always,
                validator: (v) => v ? null : 'Devi accettare per continuare',
              ),
            ),
            _fieldTile(
              'enabled: false',
              GenCheckboxFormField(
                initialValue: true,
                enabled: false,
                inputLabel: const Text('Opzione bloccata'),
              ),
            ),
          ],
        ),

        // ── 4. Altri form field (Select / Radio) ────────────────────────────
        DemoGroup(
          title: 'Altri form field',
          description:
              'GenSelectFormField e GenRadioGroupFormField (nessun typedef Gen '
              'dedicato) usati come campi di form con label e validator.',
          items: [
            _fieldTile(
              'GenSelectFormField',
              GenSelectFormField<String>(
                label: const Text('Paese'),
                placeholder: const Text('Seleziona…'),
                options: [
                  for (final e in _countries.entries)
                    GenOption(value: e.key, child: Text(e.value)),
                ],
                selectedOptionBuilder: (context, value) =>
                    Text(_countries[value] ?? value),
              ),
            ),
            _fieldTile(
              'GenRadioGroupFormField',
              GenRadioGroupFormField<String>(
                label: const Text('Piano'),
                initialValue: 'free',
                items: const [
                  GenRadio(value: 'free', label: Text('Free')),
                  GenRadio(value: 'pro', label: Text('Pro')),
                  GenRadio(value: 'team', label: Text('Team')),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Campo di showcase isolato: ogni field vive in un [GenForm] proprio per
  /// avere il contesto di registrazione, dentro un [DemoTile] largo 360.
  Widget _fieldTile(String label, Widget field) => DemoTile(
        label: label,
        width: 360,
        child: GenForm(child: field),
      );
}

/// Piccolo campo con `onChanged` che riflette il valore digitato sotto di esso.
class _OnChangedInput extends StatefulWidget {
  @override
  State<_OnChangedInput> createState() => _OnChangedInputState();
}

class _OnChangedInputState extends State<_OnChangedInput> {
  String _value = '';

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GenInputFormField(
          label: const Text('Digita qualcosa'),
          placeholder: const Text('…'),
          onChanged: (v) => setState(() => _value = v),
        ),
        const SizedBox(height: 6),
        Text('Valore: "$_value"', style: t.smallText),
      ],
    );
  }
}
