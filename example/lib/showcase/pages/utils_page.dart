import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import '../widgets/showcase_section.dart';

class UtilsPage extends StatefulWidget {
  const UtilsPage({super.key});

  @override
  State<UtilsPage> createState() => _UtilsPageState();
}

class _UtilsPageState extends State<UtilsPage> {
  String _emailInput = 'mario@example.com';
  String _phoneInput = '+39 333 1234567';
  String _urlInput = 'https://genai.it';

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return ShowcaseScaffold(
      title: 'Utils & Formatters',
      description:
          'GenaiFormatters (numeri, valute, date in italiano) · GenaiValidators · GenaiFormController · GenaiAccessState. '
          'Utility agnostiche dal framework UI — valgono anche fuori dai widget.',
      children: [
        ShowcaseSection(
          title: 'GenaiFormatters — numeri',
          child: _KVGrid(
            entries: [
              (
                'number(1234567.89)',
                GenaiFormatters.number(1234567.89, decimals: 2),
              ),
              ('currency(1250)', GenaiFormatters.currency(1250)),
              (
                'currency(1250, symbolBefore: true)',
                GenaiFormatters.currency(1250, symbolBefore: true),
              ),
              ('percent(0.123)', GenaiFormatters.percent(0.123)),
              (
                'percent(-0.04, showSign: true)',
                GenaiFormatters.percent(-0.04),
              ),
              ('compactNumber(1500)', GenaiFormatters.compactNumber(1500)),
              (
                'compactNumber(2_400_000)',
                GenaiFormatters.compactNumber(2400000),
              ),
              ('fileSize(1024)', GenaiFormatters.fileSize(1024)),
              ('fileSize(1234567890)', GenaiFormatters.fileSize(1234567890)),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiFormatters — date',
          child: _KVGrid(
            entries: [
              ('date(now)', GenaiFormatters.date(now)),
              ('dateTime(now)', GenaiFormatters.dateTime(now)),
              ('time(now)', GenaiFormatters.time(now)),
              ('dateLong(now)', GenaiFormatters.dateLong(now)),
              ('dateShort(now)', GenaiFormatters.dateShort(now)),
              ('monthYear(now)', GenaiFormatters.monthYear(now)),
              (
                'relative(-3h)',
                GenaiFormatters.relative(
                  now.subtract(const Duration(hours: 3)),
                ),
              ),
              (
                'relative(-2d)',
                GenaiFormatters.relative(now.subtract(const Duration(days: 2))),
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiFormatters — testo',
          child: _KVGrid(
            entries: [
              (
                'initials("Mario Rossi")',
                GenaiFormatters.initials('Mario Rossi'),
              ),
              (
                'initials("Giovanni della Torre", max: 3)',
                GenaiFormatters.initials('Giovanni della Torre', max: 3),
              ),
              (
                'truncate("testo lungo assai", 10)',
                GenaiFormatters.truncate('testo lungo assai', 10),
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiValidators',
          subtitle: 'Digita per vedere il validator eseguito live.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ValidatorRow(
                label: 'Email',
                initialValue: _emailInput,
                validator: (v) => GenaiValidators.isValidEmail(v)
                    ? 'Valida'
                    : 'Email non valida',
                onChanged: (v) => setState(() => _emailInput = v),
              ),
              const SizedBox(height: 12),
              _ValidatorRow(
                label: 'Telefono IT',
                initialValue: _phoneInput,
                validator: (v) => GenaiValidators.isValidPhone(v)
                    ? 'Valido'
                    : 'Telefono non valido',
                onChanged: (v) => setState(() => _phoneInput = v),
              ),
              const SizedBox(height: 12),
              _ValidatorRow(
                label: 'URL',
                initialValue: _urlInput,
                validator: (v) =>
                    GenaiValidators.isValidUrl(v) ? 'Valido' : 'URL non valido',
                onChanged: (v) => setState(() => _urlInput = v),
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiAccessState',
          subtitle:
              'Enum semantico per wrappare widget condizionati da permessi / feature flags.',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _AccessTile(state: GenaiAccessState.allowed, label: 'allowed'),
              _AccessTile(
                state: GenaiAccessState.disabledNoPermission,
                label: 'disabledNoPermission',
              ),
              _AccessTile(
                state: GenaiAccessState.disabledUpgrade,
                label: 'disabledUpgrade',
              ),
              _AccessTile(state: GenaiAccessState.hidden, label: 'hidden'),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiFormController',
          subtitle: 'Vedi la demo completa in Demo · Form + autosave.',
          child: GenaiAlert.info(
            title: 'Pattern consigliato',
            body:
                'Instanzia un GenaiFormController in initState, registra i campi con .register(), '
                'usa AnimatedBuilder per ascoltare i cambi, e isValid / errorOf per feedback.',
          ),
        ),
      ],
    );
  }
}

class _KVGrid extends StatelessWidget {
  final List<(String, String)> entries;
  const _KVGrid({required this.entries});

  @override
  Widget build(BuildContext context) {
    final ty = context.typography;
    final col = context.colors;
    return GenaiCard.outlined(
      padding: EdgeInsets.symmetric(
        vertical: context.spacing.s2,
        horizontal: context.spacing.s4,
      ),
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0) const GenaiDivider(),
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.spacing.s2),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      entries[i].$1,
                      style: ty.monoSm.copyWith(color: col.textSecondary),
                    ),
                  ),
                  SizedBox(width: context.spacing.s4),
                  Expanded(
                    flex: 2,
                    child: Text(
                      entries[i].$2,
                      style: ty.body.copyWith(
                        color: col.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ValidatorRow extends StatefulWidget {
  final String label;
  final String initialValue;
  final String Function(String) validator;
  final ValueChanged<String> onChanged;

  const _ValidatorRow({
    required this.label,
    required this.initialValue,
    required this.validator,
    required this.onChanged,
  });

  @override
  State<_ValidatorRow> createState() => _ValidatorRowState();
}

class _ValidatorRowState extends State<_ValidatorRow> {
  late String _value = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    final result = widget.validator(_value);
    final valid = result.toLowerCase().startsWith('val');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: GenaiTextField(
            label: widget.label,
            initialValue: _value,
            onChanged: (v) {
              setState(() => _value = v);
              widget.onChanged(v);
            },
          ),
        ),
        SizedBox(width: context.spacing.s4),
        Padding(
          padding: EdgeInsets.only(top: context.spacing.s6),
          child: GenaiStatusBadge(
            label: result,
            status: valid ? GenaiStatusType.success : GenaiStatusType.error,
          ),
        ),
      ],
    );
  }
}

class _AccessTile extends StatelessWidget {
  final GenaiAccessState state;
  final String label;
  const _AccessTile({required this.state, required this.label});

  @override
  Widget build(BuildContext context) {
    final col = context.colors;
    final ty = context.typography;
    final (bg, fg, icon) = switch (state) {
      GenaiAccessState.allowed => (
        col.colorSuccess.withValues(alpha: 0.12),
        col.colorSuccess,
        LucideIcons.check,
      ),
      GenaiAccessState.disabledNoPermission => (
        col.colorDanger.withValues(alpha: 0.12),
        col.colorDanger,
        LucideIcons.ban,
      ),
      GenaiAccessState.disabledUpgrade => (
        col.colorWarning.withValues(alpha: 0.12),
        col.colorWarning,
        LucideIcons.sparkles,
      ),
      GenaiAccessState.hidden => (
        col.surfaceHover,
        col.textSecondary,
        LucideIcons.eyeOff,
      ),
    };
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.s6,
        vertical: context.spacing.s2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(context.radius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          SizedBox(width: context.spacing.s2),
          Text(label, style: ty.labelSm.copyWith(color: fg)),
        ],
      ),
    );
  }
}
