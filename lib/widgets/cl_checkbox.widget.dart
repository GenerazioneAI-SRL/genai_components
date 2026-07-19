import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
// Budella Shad: nucleo interno = ShadCheckbox. Solo i simboli usati (show).
// Firma pubblica CLCheckbox invariata (incluso tristate/bool? per retro-compat).
import 'package:shadcn_ui/shadcn_ui.dart'
    show ShadCheckbox, ShadDecoration, ShadBorder;
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

/// CLCheckbox — checkbox stilizzata come nella PagedDataTable.
///
/// [value]       stato corrente (true/false; `null` = indeterminato in tristate)
/// [onChanged]   callback su cambio stato; se `null` il checkbox è disabilitato
/// [tristate]    se true supporta `null` come valore intermedio (reso con dash)
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

    // tristate: `null` è reso come box pieno con dash; il toggle resta 2-stati
    // (nessun call-site usa il ciclo a 3, verificato). Check bianco su primary,
    // bordo secondaryText a riposo, raggio radiusChip: identità CL preservata.
    final bool indeterminate = value == null;
    final bool checked = value == true || indeterminate;

    return Transform.scale(
      scale: scale,
      child: ShadCheckbox(
        value: checked,
        enabled: onChanged != null,
        onChanged: onChanged == null ? null : (v) => onChanged!(v),
        size: 16,
        color: theme.primary,
        uncheckedColor: theme.secondaryText,
        icon: Icon(
          indeterminate ? LucideIcons.minus : LucideIcons.check,
          size: 12,
          color: Colors.white,
        ),
        decoration: ShadDecoration(
          border: ShadBorder.all(
            radius: BorderRadius.circular(Sizes.radiusChip),
            width: checked ? 0 : 1,
            color: checked ? theme.primary : theme.secondaryText,
          ),
        ),
      ),
    );
  }
}
