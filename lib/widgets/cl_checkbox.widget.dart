import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
// Budella Shad: nucleo interno = ShadCheckbox. Solo i simboli usati (show).
// Firma pubblica CLCheckbox invariata (incluso tristate/bool? per retro-compat);
// dal 5.17.0 in più, facoltativi, [CLCheckbox.label] e [CLCheckbox.compact].
import 'package:shadcn_ui/shadcn_ui.dart'
    show ShadCheckbox, ShadDecoration, ShadBorder;
import '../cl_theme.dart';

/// CLCheckbox — la casella di spunta.
///
/// Non scelta è un quadrato **vuoto** (fondo della card, bordo dei controlli [CLTheme.inputBorder] da 1,5 px, ≥ 3:1);
/// scelta è piena di `primary` con la spunta nel colore di contrasto del tema ([CLTheme.primaryForeground]).
///
/// L'area di tocco è di **44 × 44** intorno al quadrato (la casella resta piccola, il dito la prende); con [label]
/// anche l'etichetta accanto è toccabile e la riga è alta almeno 44. Dentro una riga che è già tutta toccabile
/// (una riga di un elenco con `onTap`) [compact] toglie l'area di tocco: resta solo il quadrato.
///
/// [value]       stato corrente (true/false; `null` = indeterminato in tristate)
/// [onChanged]   callback su cambio stato; se `null` il checkbox è disabilitato
/// [tristate]    se true supporta `null` come valore intermedio (reso con dash)
/// [scale]       fattore di scala del quadrato (default 0.9: 18 px)
/// [label]       etichetta accanto, toccabile come la casella (facoltativa)
/// [compact]     solo il quadrato, senza l'area di tocco da 44 (default `false`)
class CLCheckbox extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final bool tristate;
  final double scale;

  /// L'etichetta della casella: sta a destra, va a capo, e un tocco su di lei cambia la scelta come sulla casella.
  final String? label;

  /// `true` dentro una riga già toccabile: niente area di tocco da 44, solo il quadrato.
  final bool compact;

  /// Lato dell'area di tocco (le linee guida di iOS e Android: 44 e 48).
  static const double tapTarget = 44;

  const CLCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.tristate = false,
    this.scale = 0.9,
    this.label,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);

    // tristate: `null` è reso come box pieno con dash; il toggle resta 2-stati
    // (nessun call-site usa il ciclo a 3, verificato).
    final bool indeterminate = value == null;
    final bool checked = value == true || indeterminate;
    final bool enabled = onChanged != null;
    final double box = 20 * scale;

    final Widget mark = ShadCheckbox(
      value: checked,
      enabled: enabled,
      onChanged: enabled ? (v) => onChanged!(v) : null,
      size: box,
      color: theme.primary,
      // Il fondo della casella non scelta è quello della card, non un grigio pieno (sembrava scelta o spenta).
      uncheckedColor: theme.secondaryBackground,
      checkboxPadding: EdgeInsets.zero,
      icon: Icon(
        indeterminate ? LucideIcons.minus : LucideIcons.check,
        size: box * 0.7,
        color: theme.primaryForeground,
      ),
      decoration: ShadDecoration(
        border: ShadBorder.all(
          radius: BorderRadius.circular(theme.radiusXs),
          width: checked ? 0 : 1.5,
          color: checked ? theme.primary : theme.inputBorder,
        ),
      ),
    );

    if (compact && label == null) return mark;

    // L'area di tocco: la casella al centro di 44 × 44; con l'etichetta tutta la riga.
    final Widget target = SizedBox.square(dimension: compact ? box : tapTarget, child: Center(child: mark));
    final Widget content = label == null
        ? target
        : ConstrainedBox(
            constraints: const BoxConstraints(minHeight: tapTarget),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                target,
                SizedBox(width: compact ? theme.gapSm : theme.gapXs),
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: theme.gapSm),
                    child: Text(
                      label!,
                      style: theme.bodyText.copyWith(color: enabled ? theme.primaryText : theme.secondaryText),
                    ),
                  ),
                ),
              ],
            ),
          );

    return MergeSemantics(
      child: Semantics(
        label: label,
        child: MouseRegion(
          cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            // Come il tocco sul quadrato (ShadCheckbox): inverte lo stato mostrato.
            onTap: enabled ? () => onChanged!(!checked) : null,
            excludeFromSemantics: true,
            child: content,
          ),
        ),
      ),
    );
  }
}
