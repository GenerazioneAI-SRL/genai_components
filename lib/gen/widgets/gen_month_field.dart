import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:genai_components/gen/primitives/gen_primitives.dart';
import 'package:genai_components/gen/theme/gen_sizes.dart';

import 'gen_date_field_utils.dart';

/// Campo mese+anno (due tendine Shad affiancate). Emette un [DateTime] al 1°
/// del mese/anno scelti quando entrambe le tendine sono valorizzate, `null`
/// altrimenti. Preserva la semantica `mm/aaaa`.
class GenMonthField extends StatefulWidget {
  const GenMonthField({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.firstYear,
    this.lastYear,
  });

  final DateTime? initialValue;
  final ValueChanged<DateTime?> onChanged;
  final int? firstYear;
  final int? lastYear;

  @override
  State<GenMonthField> createState() => _GenMonthFieldState();
}

class _GenMonthFieldState extends State<GenMonthField> {
  int? _month;
  int? _year;

  @override
  void initState() {
    super.initState();
    _month = widget.initialValue?.month;
    _year = widget.initialValue?.year;
  }

  void _emit() {
    if (_month != null && _year != null) {
      widget.onChanged(DateTime(_year!, _month!));
    } else {
      widget.onChanged(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat.MMMM();
    final years = genYearRange(widget.firstYear, widget.lastYear);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GenSelect<int>(
            placeholder: const Text('Mese'),
            initialValue: _month,
            options: [
              for (var m = 1; m <= 12; m++)
                GenOption<int>(
                  value: m,
                  child: Text(monthLabel.format(DateTime(2000, m))),
                ),
            ],
            selectedOptionBuilder: (context, value) =>
                Text(monthLabel.format(DateTime(2000, value))),
            onChanged: (m) {
              setState(() => _month = m);
              _emit();
            },
          ),
        ),
        const SizedBox(width: GenSizes.gapSm),
        Expanded(
          child: GenSelect<int>(
            placeholder: const Text('Anno'),
            initialValue: _year,
            options: [
              for (final y in years) GenOption<int>(value: y, child: Text('$y')),
            ],
            selectedOptionBuilder: (context, value) => Text('$value'),
            onChanged: (y) {
              setState(() => _year = y);
              _emit();
            },
          ),
        ),
      ],
    );
  }
}
