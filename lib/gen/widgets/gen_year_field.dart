import 'package:flutter/material.dart';
import 'package:genai_components/gen/primitives/gen_primitives.dart';

import 'gen_date_field_utils.dart';

/// Campo di selezione anno (tendina Shad). Emette un [DateTime] al 1° gennaio
/// dell'anno scelto, o `null` se deselezionato. Intervallo default: anno
/// corrente ±10, sovrascrivibile con [firstYear]/[lastYear].
class GenYearField extends StatelessWidget {
  const GenYearField({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.firstYear,
    this.lastYear,
    this.placeholder,
  });

  final DateTime? initialValue;
  final ValueChanged<DateTime?> onChanged;
  final int? firstYear;
  final int? lastYear;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    final years = genYearRange(firstYear, lastYear);
    return GenSelect<int>(
      placeholder: placeholder ?? const Text('Anno'),
      initialValue: initialValue?.year,
      options: [
        for (final y in years) GenOption<int>(value: y, child: Text('$y')),
      ],
      selectedOptionBuilder: (context, value) => Text('$value'),
      onChanged: (y) => onChanged(y == null ? null : DateTime(y)),
    );
  }
}
