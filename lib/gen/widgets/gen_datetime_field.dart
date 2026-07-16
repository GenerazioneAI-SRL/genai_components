import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:genai_components/gen/primitives/gen_primitives.dart';
import 'package:genai_components/gen/theme/gen_sizes.dart';

/// Campo data+ora: combina [GenDatePicker] (parte data) e [GenTimePicker]
/// (parte ora) affiancati. Emette un [DateTime] completo quando entrambe le
/// parti sono valorizzate, `null` altrimenti.
class GenDateTimeField extends StatefulWidget {
  const GenDateTimeField({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
  });

  final DateTime? initialValue;
  final ValueChanged<DateTime?> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  State<GenDateTimeField> createState() => _GenDateTimeFieldState();
}

class _GenDateTimeFieldState extends State<GenDateTimeField> {
  DateTime? _date;
  ShadTimeOfDay? _time;

  @override
  void initState() {
    super.initState();
    final v = widget.initialValue;
    if (v != null) {
      _date = DateTime(v.year, v.month, v.day);
      _time = ShadTimeOfDay(hour: v.hour, minute: v.minute, second: 0);
    }
  }

  void _emit() {
    final d = _date;
    final t = _time;
    if (d != null && t != null) {
      widget.onChanged(DateTime(d.year, d.month, d.day, t.hour, t.minute));
    } else {
      widget.onChanged(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GenDatePicker(
            selected: _date,
            fromMonth: widget.firstDate,
            toMonth: widget.lastDate,
            onChanged: (d) {
              setState(() => _date = d);
              _emit();
            },
          ),
        ),
        const SizedBox(width: GenSizes.gapSm),
        Expanded(
          child: GenTimePicker(
            initialValue: _time,
            onChanged: (t) {
              setState(() => _time = t);
              _emit();
            },
          ),
        ),
      ],
    );
  }
}
