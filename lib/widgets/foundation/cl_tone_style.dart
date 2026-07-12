import 'package:flutter/material.dart';

import '../../cl_theme.dart';
import 'cl_pressable.widget.dart';

/// Toni semantici del kit. `neutral` è il grigio non semantico (muted/accent).
enum CLTone { primary, secondary, success, info, warning, danger, neutral }

/// Asse di variante del catalogo (stile shadcn):
/// solid = riempito · soft = tinta leggera · outline = bordo · ghost = nudo · link = testo.
enum CLVariant { solid, soft, outline, ghost, link }

/// Colori risolti per un dato (tone × variant × stato interattivo).
@immutable
class CLToneColors {
  const CLToneColors({required this.bg, required this.fg, this.border});

  final Color bg;
  final Color fg;
  final Color? border;
}

/// Recipe **L2** — l'unico posto dove vive la matematica del chrome tonale.
///
/// Scala canonica:
/// - `soft` (tinta): base `opacitySoft` (0.10) · hover `opacityMuted` (0.14) · press `opacityMedium` (0.20), colore = tono.
/// - `outline`/`ghost` (stile shadcn): bg SEMPRE neutro (trasparente → grigio `accent` hover → accent scurito press); outline ha bordo SEMPRE grigio `cardBorder`. Il tono vive SOLO nel testo/icona (`fg`), mai in bordo/bg.
/// - `solid`: hover/press scuriscono con `Color.lerp(bg, black, 0.08/0.16)`.
/// - `link`: solo testo = tono (hover scurito), nessun bg/bordo.
///
/// `colored: false` = percorso neutro (tono secondary + costruttori raw): testo `primaryText`; soft → scala `muted`; outline/ghost → overlay neutro + bordo `cardBorder` (outline).
///
/// Con `state.disabled` restituisce i colori idle: l'opacità disabled
/// (`theme.opacityDisabled`) la applica il consumer sull'intero widget.
abstract final class CLToneStyle {
  /// Mappa un [CLTone] sul token colore del tema.
  static Color colorOf(CLTheme theme, CLTone tone) {
    switch (tone) {
      case CLTone.primary:
        return theme.primary;
      case CLTone.secondary:
        return theme.secondary;
      case CLTone.success:
        return theme.success;
      case CLTone.info:
        return theme.info;
      case CLTone.warning:
        return theme.warning;
      case CLTone.danger:
        return theme.danger;
      case CLTone.neutral:
        return theme.mutedForeground;
    }
  }

  static CLToneColors resolve(
    CLTheme theme, {
    required Color color,
    required CLVariant variant,
    CLPressableState state = const CLPressableState(),
    bool colored = true,
  }) {
    // Disabled → colori idle; l'opacità la applica il consumer.
    final s = state.disabled ? const CLPressableState() : state;

    if (!colored) return _neutral(theme, variant, s);

    switch (variant) {
      case CLVariant.solid:
        final bg = s.pressed
            ? Color.lerp(color, Colors.black, 0.16)!
            : s.hovered
                ? Color.lerp(color, Colors.black, 0.08)!
                : color;
        final fg =
            color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
        return CLToneColors(bg: bg, fg: fg);
      case CLVariant.soft:
        final alpha = s.pressed
            ? theme.opacityMedium
            : s.hovered
                ? theme.opacityMuted
                : theme.opacitySoft;
        return CLToneColors(bg: color.withValues(alpha: alpha), fg: color);
      case CLVariant.outline:
        // shadcn: bordo grigio neutro + bg grigio `accent` su hover/press; il
        // tono vive SOLO nel testo/icona.
        return CLToneColors(
          bg: _neutralOverlay(theme, s),
          fg: color,
          border: theme.cardBorder,
        );
      case CLVariant.ghost:
        // Come outline ma senza bordo.
        return CLToneColors(bg: _neutralOverlay(theme, s), fg: color);
      case CLVariant.link:
        return CLToneColors(
          bg: Colors.transparent,
          fg: s.hovered ? Color.lerp(color, Colors.black, 0.12)! : color,
        );
    }
  }

  /// Overlay neutro per varianti trasparenti (outline/ghost), stile shadcn:
  /// trasparente a riposo, grigio `accent` su hover, accent scurito su press.
  /// Indipendente dal tono (il tono resta solo nel testo).
  ///
  /// A riposo torna `accent` con alpha 0 (NON `Colors.transparent`): così
  /// l'`AnimatedContainer` che interpola il bg resta nell'hue di accent invece
  /// di passare per il nero semi-trasparente (flash scuro su hover-in).
  static Color _neutralOverlay(CLTheme theme, CLPressableState s) {
    if (s.pressed) return Color.lerp(theme.accent, Colors.black, 0.08)!;
    if (s.hovered) return theme.accent;
    return theme.accent.withValues(alpha: 0.0);
  }

  /// Percorso neutro: replica il chrome storico dei bottoni non colorati.
  /// Per `soft`: base muted, hover/press scuriscono muted (Color.lerp con black).
  /// Per ghost/outline/link: hover accent, press accent scurito, bordo cardBorder su outline.
  static CLToneColors _neutral(
      CLTheme theme, CLVariant variant, CLPressableState s) {
    final Color bg;
    final Color? border;

    if (variant == CLVariant.soft) {
      // Soft neutro: usa la scala muted (come in cl_soft_button.widget.dart)
      if (s.pressed) {
        bg = Color.lerp(theme.muted, Colors.black, 0.16)!;
      } else if (s.hovered) {
        bg = Color.lerp(theme.muted, Colors.black, 0.08)!;
      } else {
        bg = theme.muted;
      }
      border = null;
    } else {
      // Ghost/outline/link neutri: overlay grigio neutro, bordo grigio su outline.
      bg = _neutralOverlay(theme, s);
      border = variant == CLVariant.outline ? theme.cardBorder : null;
    }

    return CLToneColors(
      bg: bg,
      fg: theme.primaryText,
      border: border,
    );
  }
}
