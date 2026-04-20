import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import '../widgets/showcase_section.dart';

class FormDemoPage extends StatefulWidget {
  const FormDemoPage({super.key});

  @override
  State<FormDemoPage> createState() => _FormDemoPageState();
}

class _FormDemoPageState extends State<FormDemoPage> {
  late final GenaiFormController _form;
  String _autosaveLabel = 'Mai salvato';
  int _step = 0;

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Obbligatorio' : null;
  String? _email(String? v) {
    if (v == null || v.isEmpty) return 'Obbligatorio';
    return GenaiValidators.isValidEmail(v) ? null : 'Email non valida';
  }

  @override
  void initState() {
    super.initState();
    _form = GenaiFormController(
      enableAutosave: true,
      autosaveDebounce: const Duration(milliseconds: 800),
      onAutosave: (values) async {
        await Future<void>.delayed(const Duration(milliseconds: 250));
        if (!mounted) return;
        setState(() => _autosaveLabel = 'Salvato automaticamente alle ${GenaiFormatters.time(DateTime.now())}');
      },
    );
    _form.register<String>('firstName', initialValue: '', validator: _required);
    _form.register<String>('lastName', initialValue: '', validator: _required);
    _form.register<String>('email', initialValue: '', validator: _email);
    _form.register<String>('phone', initialValue: '');
    _form.register<String>('role', initialValue: 'developer');
    _form.register<bool>('newsletter', initialValue: false);
    _form.register<List<String>>('skills', initialValue: const []);
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Widget _field({required String name, required Widget child}) {
    return AnimatedBuilder(
      animation: _form,
      builder: (_, __) {
        final error = _form.errorOf(name);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            child,
            if (error != null) ...[
              const SizedBox(height: 4),
              Text(error, style: context.typography.caption.copyWith(color: context.colors.colorError)),
            ],
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ty = context.typography;

    return ShowcaseScaffold(
      title: 'Demo · Form con autosave',
      description: 'GenaiFormController + validatori + autosave debounced + stepper di avanzamento.',
      children: [
        GenaiStepper(
          currentStep: _step,
          onStepTap: (i) => setState(() => _step = i),
          steps: const [
            GenaiStepperStep(title: 'Anagrafica'),
            GenaiStepperStep(title: 'Contatti'),
            GenaiStepperStep(title: 'Preferenze'),
          ],
        ),
        const SizedBox(height: 24),
        GenaiCard.outlined(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_step == 0) ...[
                  _field(
                    name: 'firstName',
                    child: GenaiTextField(
                      label: 'Nome',
                      hint: 'Mario',
                      onChanged: (v) => _form.setValue<String>('firstName', v, markTouched: true),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _field(
                    name: 'lastName',
                    child: GenaiTextField(
                      label: 'Cognome',
                      hint: 'Rossi',
                      onChanged: (v) => _form.setValue<String>('lastName', v, markTouched: true),
                    ),
                  ),
                ],
                if (_step == 1) ...[
                  _field(
                    name: 'email',
                    child: GenaiTextField(
                      label: 'Email',
                      hint: 'mario@example.com',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (v) => _form.setValue<String>('email', v, markTouched: true),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _field(
                    name: 'phone',
                    child: GenaiTextField(
                      label: 'Telefono',
                      hint: '+39 333 1234567',
                      keyboardType: TextInputType.phone,
                      onChanged: (v) => _form.setValue<String>('phone', v),
                    ),
                  ),
                ],
                if (_step == 2) ...[
                  Text('Ruolo', style: ty.label.copyWith(color: c.textPrimary)),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: _form,
                    builder: (_, __) => GenaiRadioGroup<String>(
                      value: _form.value<String>('role'),
                      onChanged: (v) => _form.setValue<String>('role', v ?? 'developer'),
                      options: const [
                        GenaiRadioOption(value: 'developer', label: 'Developer'),
                        GenaiRadioOption(value: 'designer', label: 'Designer'),
                        GenaiRadioOption(value: 'pm', label: 'Project Manager'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedBuilder(
                    animation: _form,
                    builder: (_, __) => GenaiCheckbox(
                      value: _form.value<bool>('newsletter') ?? false,
                      label: 'Iscrivimi alla newsletter',
                      onChanged: (v) => _form.setValue<bool>('newsletter', v ?? false),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Competenze', style: ty.label.copyWith(color: c.textPrimary)),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: _form,
                    builder: (_, __) => GenaiTagInput(
                      tags: _form.value<List<String>>('skills') ?? const [],
                      onChanged: (v) => _form.setValue<List<String>>('skills', v),
                      hint: 'Aggiungi competenze',
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Row(
                      children: [
                        Icon(LucideIcons.cloudCheck, size: 16, color: c.colorSuccess),
                        const SizedBox(width: 6),
                        Text(_autosaveLabel, style: ty.caption.copyWith(color: c.textSecondary)),
                      ],
                    ),
                    const Spacer(),
                    if (_step > 0)
                      GenaiButton.ghost(
                        label: 'Indietro',
                        onPressed: () => setState(() => _step--),
                      ),
                    const SizedBox(width: 8),
                    if (_step < 2)
                      GenaiButton.primary(
                        label: 'Avanti',
                        onPressed: () => setState(() => _step++),
                      )
                    else
                      AnimatedBuilder(
                        animation: _form,
                        builder: (_, __) => GenaiButton.primary(
                          label: 'Salva',
                          icon: LucideIcons.check,
                          onPressed: _form.isValid
                              ? () {
                                  _form.markPristine();
                                  showGenaiToast(context, message: 'Form salvato', type: GenaiToastType.success);
                                }
                              : null,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
