import 'package:flutter/material.dart';
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

/// CLCheckbox — checkbox stilizzata come nella PagedDataTable.
///
/// [value]       stato corrente (true/false)
/// [onChanged]   callback su cambio stato; se `null` il checkbox è disabilitato
/// [tristate]    se true supporta `null` come valore intermedio
/// [scale]       fattore di scala (default 0.9)
class CLCheckbox extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final bool tristate;
  final double scale;

  const CLCheckbox({super.key, required this.value, required this.onChanged, this.tristate = false, this.scale = 0.9});

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);

    return Transform.scale(
      scale: scale,
      child: Checkbox(
        value: value,
        tristate: tristate,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        hoverColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        activeColor: theme.primary,
        checkColor: Colors.white,
        side: WidgetStateBorderSide.resolveWith(
          (states) => BorderSide(
            color: states.contains(WidgetState.selected) ? theme.primary : theme.secondaryText,
            width: states.contains(WidgetState.selected) ? 0 : 1,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.radiusChip)),
        onChanged: onChanged,
      ),
    );
  }
}
