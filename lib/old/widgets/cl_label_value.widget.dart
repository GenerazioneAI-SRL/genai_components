import 'package:flutter/material.dart';

import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

/// Riga **label → value** per le pagine di dettaglio.
///
/// Layout: etichetta piccola/muted sopra, valore sotto (selezionabile, `'—'`
/// se vuoto). Pensata per stare dentro le bolle grigie
/// `CLContainer(recessed: true)` disposte in `ResponsiveGrid`. Sostituisce gli
/// helper `_field`/`_row` locali delle pagine.
class CLLabelValue extends StatelessWidget {
  const CLLabelValue({
    super.key,
    required this.label,
    this.value,
    this.valueWidget,
    this.placeholder = '—',
    this.selectable = true,
  });

  /// Etichetta (riga superiore, stile muted).
  final String label;

  /// Valore testuale (riga inferiore). Null/vuoto → [placeholder].
  final String? value;

  /// Valore custom (badge, chip, link…). Ha precedenza su [value].
  final Widget? valueWidget;

  /// Testo mostrato quando [value] è null/vuoto e [valueWidget] è null.
  final String placeholder;

  /// Valore copiabile (`SelectableText`). Ignorato se [valueWidget] presente.
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final hasValue = value != null && value!.isNotEmpty;
    final text = hasValue ? value! : placeholder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: theme.smallLabel),
        const SizedBox(height: CLSizes.gapXs),
        if (valueWidget != null)
          valueWidget!
        else if (selectable)
          SelectableText(text, style: theme.bodyText)
        else
          Text(text, style: theme.bodyText),
      ],
    );
  }
}
