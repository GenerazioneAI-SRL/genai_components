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
/// Scala canonica per le varianti tinta (soft/outline/ghost):
/// base = `opacitySoft` (0.10) · hover = `opacityMuted` (0.14) · press = `opacityMedium` (0.20).
/// Per `solid`: hover/press scuriscono con `Color.lerp(bg, black, 0.08/0.16)`.
///
/// `colored: false` è il percorso neutro (tono secondary + costruttori raw dei
/// bottoni): hover `accent`, testo `primaryText` — identico al comportamento
/// storico, così i widget esistenti non cambiano resa dove erano neutri.
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
        return CLToneColors(
          bg: _tintOverlay(theme, color, s),
          fg: color,
          border: color,
        );
      case CLVariant.ghost:
        return CLToneColors(bg: _tintOverlay(theme, color, s), fg: color);
      case CLVariant.link:
        return CLToneColors(
          bg: Colors.transparent,
          fg: s.hovered ? Color.lerp(color, Colors.black, 0.12)! : color,
        );
    }
  }

  /// Overlay per varianti trasparenti a riposo (outline/ghost).
  static Color _tintOverlay(CLTheme theme, Color color, CLPressableState s) {
    if (s.pressed) return color.withValues(alpha: theme.opacityMuted);
    if (s.hovered) return color.withValues(alpha: theme.opacitySoft);
    return Colors.transparent;
  }

  /// Percorso neutro: replica il chrome storico dei bottoni non colorati.
  static CLToneColors _neutral(
      CLTheme theme, CLVariant variant, CLPressableState s) {
    final Color bg;
    if (s.pressed) {
      bg = Color.lerp(theme.accent, Colors.black, 0.08)!;
    } else if (s.hovered) {
      bg = theme.accent;
    } else {
      bg = variant == CLVariant.soft ? theme.muted : Colors.transparent;
    }
    return CLToneColors(
      bg: bg,
      fg: theme.primaryText,
      border: variant == CLVariant.outline ? theme.cardBorder : null,
    );
  }
}
