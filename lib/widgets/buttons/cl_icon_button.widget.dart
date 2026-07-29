import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Budella Shad: nucleo interno del bottone. Solo i simboli usati (show) per non
// inquinare il namespace. Firma pubblica CLIconButton invariata.
import 'package:shadcn_ui/shadcn_ui.dart'
    show ShadIconButton, ShadButtonVariant, ShadDecoration, ShadBorder;
import '../../cl_theme.dart';
import 'cl_async_button_mixin.dart';
import 'cl_loading_spinner.widget.dart';
import '../foundation/cl_pressable.widget.dart';
import '../foundation/cl_tone_style.dart';

// ── Durata micro-interazione (icon ↔ spinner) ──────────────────────
const Duration _iconSwapDuration = Duration(milliseconds: 180);

/// Bottone pieno solo-icona, quadrato. Stesse micro-interazioni di [CLButton]
/// (press scale/offset, hover blend, haptic, spinner). Pensato per azioni
/// compatte in header/toolbar — es. il pulsante AI in header — dove serve
/// un'icona prominente senza label. Supporta ombra e bordo opzionali.
class CLIconButton extends StatefulWidget {
  final Function() onTap;

  /// Icona Material. Ignorata se [hugeIcon] è presente.
  final IconData? iconData;

  /// Widget icona custom (es. HugeIcon). Se presente vince su [iconData].
  final Widget? hugeIcon;

  /// Colore di sfondo. Se `null` usa `theme.muted` (default neutro: fill grigio,
  /// icona nera auto-contrast, tondo). Per un bottone primario passa `theme.primary`.
  final Color? backgroundColor;

  /// Colore icona. Se `null` auto-contrast sul background (nero/bianco).
  final Color? iconColor;

  /// Lato del quadrato. Se `null` usa `theme.buttonHeightDefault` (40).
  final double? size;

  /// Dimensione icona. Se `null` usa `size * 0.5`.
  final double? iconSize;

  /// Ombra opzionale. Se `null` nessuna ombra.
  final List<BoxShadow>? boxShadow;

  /// Bordo opzionale. Se `null` nessun bordo (focus ring a parte).
  final BoxBorder? border;

  /// Override del raggio di angolo. Se `null` default 999 (cerchio/pill):
  /// i bottoni icona isolati di chrome sono tondi per design (DS: quadrati→cerchio).
  final double? borderRadius;

  /// Tooltip mostrato al hover/long-press.
  final String? tooltip;

  /// Se `false`, disabilita input e applica opacità ridotta.
  final bool enabled;

  /// Override esterno dello stato di loading. Se `null`, usa lo stato interno del mixin async.
  final bool? loading;

  /// Label semantica per screen reader.
  final String? semanticLabel;

  /// Se `true` (default), emette un `HapticFeedback.selectionClick()` al press (iOS/Android).
  final bool haptic;

  const CLIconButton({
    super.key,
    required this.onTap,
    this.iconData,
    this.hugeIcon,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.iconSize,
    this.boxShadow,
    this.border,
    this.borderRadius,
    this.tooltip,
    this.enabled = true,
    this.loading,
    this.semanticLabel,
    this.haptic = true,
  });

  @override
  State<CLIconButton> createState() => _CLIconButtonState();
}

class _CLIconButtonState extends State<CLIconButton> with AsyncButtonMixin {
  // Interazione + stato (hover/press/focus/ring/keyboard) delegati a ShadButton
  // (budella Shad): niente hand-roll di controller/overlay qui. Colori per stato
  // dal motore CLToneStyle.

  Future<void> _handleTap() async {
    await handleAsyncTap(
      onTap: widget.onTap,
      needConfirmation: false,
      confirmationMessage: null,
    );
  }

  void _fireHaptic() => HapticFeedback.selectionClick();

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final isLoading = widget.loading ?? loading;
    final isInteractive = widget.enabled && !isLoading;

    // ── Colori (da CLToneStyle) ───────────────────────────────────────
    final bgColor = widget.backgroundColor ?? theme.muted;
    // Variante "plain" (bg trasparente): icona nuda, il fill appare solo su
    // hover/press. Il lerp verso nero su un colore trasparente produrrebbe un
    // velo scuro sbagliato, quindi usiamo la variante `ghost` neutra (overlay
    // grigio + fg `primaryText`) invece della `solid` colorata.
    final isPlain = bgColor.a == 0.0;
    final variant = isPlain ? CLVariant.ghost : CLVariant.solid;
    final colored = !isPlain;

    final CLToneColors tBase = CLToneStyle.resolve(theme,
        color: bgColor, variant: variant, colored: colored);
    final CLToneColors tHover = CLToneStyle.resolve(theme,
        color: bgColor,
        variant: variant,
        colored: colored,
        state: const CLPressableState(hovered: true));
    final CLToneColors tPressed = CLToneStyle.resolve(theme,
        color: bgColor,
        variant: variant,
        colored: colored,
        state: const CLPressableState(pressed: true));

    final fgColor = tBase.fg;
    final iconColor = widget.iconColor ?? fgColor;

    // ── Geometria: lato quadrato da design token, icona a metà lato ──
    final side = widget.size ?? theme.buttonHeightDefault;
    final iconSz = widget.iconSize ?? side * 0.5;
    // Default 999 → cerchio/pill: i bottoni icona isolati di chrome sono tondi.
    final radius = widget.borderRadius ?? 999;

    // ── Slot icona ↔ spinner ─────────────────────────────────────────
    final iconChild = widget.hugeIcon ??
        (widget.iconData != null
            ? Icon(widget.iconData, color: iconColor, size: iconSz)
            : SizedBox(width: iconSz, height: iconSz));
    final content = Center(
      child: AnimatedSwitcher(
        duration: _iconSwapDuration,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: isLoading
            ? SizedBox(
                key: const ValueKey('spinner'),
                width: iconSz,
                height: iconSz,
                child: CLLoadingSpinner(size: iconSz, color: iconColor),
              )
            : KeyedSubtree(key: const ValueKey('icon'), child: iconChild),
      ),
    );

    // ── a11y: icon-only ⇒ serve sempre un nome accessibile. `tooltip` resta
    // come fallback della label. Quando presente, escludiamo la semantica del
    // contenuto e la rimpiazziamo con un `Semantics` esplicito sul bottone.
    final a11yLabel = widget.semanticLabel ?? widget.tooltip;
    final hasA11y = a11yLabel != null && a11yLabel.isNotEmpty;
    final Widget semanticContent =
        hasA11y ? ExcludeSemantics(child: content) : content;

    // Bordo custom → ShadBorder (il focus ring nativo di ShadButton = theme.ring
    // resta a parte). Solo `Border` (bordo uniforme) è mappabile su ShadBorder.all.
    final BorderSide? side0 =
        widget.border is Border ? (widget.border as Border).top : null;

    // ── Nucleo = ShadIconButton (budella Shad, primitivo icon-only): hover/press/
    //    focus/keyboard/ring nativi, disabled+loading attenuati via `enabled`.
    //    Colori per stato dal motore CLToneStyle. async/confirm/haptic/loading/
    //    icon-swap nel wrapper. Firma pubblica invariata. ──────────────────────
    Widget button = ShadIconButton.raw(
      variant: ShadButtonVariant.primary,
      // enabled=isInteractive → in disabled E loading ShadIconButton toglie hover
      // e attenua (sostituisce sia il tap-guard sia l'AnimatedOpacity precedente).
      enabled: isInteractive,
      onPressed: () => _handleTap(),
      onTapDown: widget.haptic ? (_) => _fireHaptic() : null,
      backgroundColor: tBase.bg,
      hoverBackgroundColor: tHover.bg,
      pressedBackgroundColor: tPressed.bg,
      foregroundColor: iconColor,
      hoverForegroundColor: iconColor,
      pressedForegroundColor: iconColor,
      width: side,
      height: side,
      padding: EdgeInsets.zero,
      shadows: widget.boxShadow,
      decoration: ShadDecoration(
        border: side0 != null
            ? ShadBorder.all(
                color: side0.color,
                width: side0.width,
                radius: BorderRadius.circular(radius))
            : ShadBorder(radius: BorderRadius.circular(radius)),
      ),
      icon: semanticContent,
    );

    // a11y: nome esplicito quando il contenuto è ExcludeSemantics.
    if (hasA11y) {
      button = Semantics(
        button: true,
        enabled: isInteractive,
        label: a11yLabel,
        child: button,
      );
    }

    return button;
  }
}
