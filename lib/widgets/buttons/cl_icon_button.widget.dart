import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../cl_theme.dart';
import 'cl_async_button_mixin.dart';
import 'cl_loading_spinner.widget.dart';

// ── Costanti micro-interazione (identiche a CLButton) ───────────────
const double _pressScale = 0.97;
const double _pressYOffset = 1.0;
const Duration _pressDuration = Duration(milliseconds: 110);
const Duration _hoverDuration = Duration(milliseconds: 140);
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

  /// Override del raggio di angolo. Se `null` usa `theme.radiusControl`.
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
  // Stato "umano" tracciato via controller: evitiamo gli overlay Material
  // e animiamo noi scala, offset e sfondo per un feedback tattile.
  late final WidgetStatesController _statesController;
  bool _wasPressed = false;

  @override
  void initState() {
    super.initState();
    _statesController = WidgetStatesController();
    _statesController.addListener(_onStatesChanged);
  }

  @override
  void dispose() {
    _statesController.removeListener(_onStatesChanged);
    _statesController.dispose();
    super.dispose();
  }

  void _onStatesChanged() {
    // Gli aggiornamenti visivi (hover/press/focus) passano attraverso
    // `ValueListenableBuilder` in `build`: nessun `setState` qui, altrimenti
    // si rischia "setState during build" quando Material aggiorna il
    // controller all'interno del suo `build` (es. onPressed che diventa null).
    if (!mounted) return;
    final nowPressed = _statesController.value.contains(WidgetState.pressed);
    if (nowPressed && !_wasPressed && widget.haptic && widget.enabled) {
      HapticFeedback.selectionClick();
    }
    _wasPressed = nowPressed;
  }

  Future<void> _handleTap() async {
    await handleAsyncTap(
      onTap: widget.onTap,
      needConfirmation: false,
      confirmationMessage: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final isLoading = widget.loading ?? loading;
    final isInteractive = widget.enabled && !isLoading;

    // ── Colori ────────────────────────────────────────────────────────
    final bgColor = widget.backgroundColor ?? theme.muted;
    // Variante "plain" (bg trasparente): icona nuda, il fill appare solo su
    // hover/press usando theme.muted — il lerp verso nero su un colore
    // trasparente produrrebbe un velo scuro sbagliato, e l'auto-contrast
    // (luminance 0 → bianco) renderebbe l'icona invisibile su superfici chiare.
    final isPlain = bgColor.a == 0.0;
    final fgColor = isPlain ? theme.primaryText : (bgColor.computeLuminance() > 0.5 ? Colors.black : Colors.white);
    final iconColor = widget.iconColor ?? fgColor;

    // Hover/press: alpha-blend uniforme nero 0.08/0.16 (no glow, no colored shadow).
    final hoverBg = isPlain ? theme.muted : Color.lerp(bgColor, Colors.black, 0.08)!;
    final pressedBg = isPlain ? Color.lerp(theme.muted, Colors.black, 0.08)! : Color.lerp(bgColor, Colors.black, 0.16)!;

    // ── Geometria: lato quadrato da design token, icona a metà lato ──
    final side = widget.size ?? theme.buttonHeightDefault;
    final iconSz = widget.iconSize ?? side * 0.5;
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

    // ── Superficie animata (bg + ombra/bordo: niente gap trasparente) ─
    // La surface animata (bg, border focus, press scale+offset) reagisce agli
    // stati tramite UN SOLO ValueListenableBuilder posto COME DESCENDANT
    // dell'ElevatedButton. Se fosse ancestor, quando Material aggiorna il
    // controller in `didUpdateWidget` spareremmo "setState during build" su
    // un ancestor già processato nel frame corrente.
    final surface = ValueListenableBuilder<Set<WidgetState>>(
      valueListenable: _statesController,
      builder: (context, states, stableChild) {
        final isHovered = states.contains(WidgetState.hovered);
        final isPressed = states.contains(WidgetState.pressed);
        final isFocused = states.contains(WidgetState.focused);
        final currentBg = isPressed
            ? pressedBg
            : isHovered
                ? hoverBg
                : bgColor;
        final transform = Matrix4.identity()
          ..translateByDouble(0.0, isPressed ? _pressYOffset : 0.0, 0.0, 1.0)
          ..scaleByDouble(isPressed ? _pressScale : 1.0, isPressed ? _pressScale : 1.0, 1.0, 1.0);

        // Focus ring: sostituisce l'eventuale bordo custom solo quando focused.
        final currentBorder = isFocused ? Border.all(color: fgColor.withValues(alpha: 0.6), width: 2) : widget.border;

        return AnimatedContainer(
          duration: _pressDuration,
          curve: Curves.easeOut,
          transform: transform,
          transformAlignment: Alignment.center,
          child: AnimatedContainer(
            duration: _hoverDuration,
            curve: Curves.easeOut,
            width: side,
            height: side,
            decoration: BoxDecoration(
              color: currentBg,
              borderRadius: BorderRadius.circular(radius),
              border: currentBorder,
              boxShadow: widget.boxShadow,
            ),
            child: stableChild,
          ),
        );
      },
      child: content,
    );

    // ── Style Material "invisibile" (solo tap/focus/semantics, niente chrome) ─
    final buttonStyle = ButtonStyle(
      padding: WidgetStateProperty.all(EdgeInsets.zero),
      backgroundColor: WidgetStateProperty.all(Colors.transparent),
      foregroundColor: WidgetStateProperty.all(fgColor),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      shadowColor: WidgetStateProperty.all(Colors.transparent),
      surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
      elevation: WidgetStateProperty.all(0),
      splashFactory: NoSplash.splashFactory,
      animationDuration: Duration.zero,
      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius))),
      side: WidgetStateProperty.all(BorderSide.none),
      minimumSize: WidgetStateProperty.all(Size.zero),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      iconSize: WidgetStateProperty.all(iconSz),
    );

    Widget button = ElevatedButton(
      statesController: _statesController,
      onPressed: isInteractive ? _handleTap : null,
      style: buttonStyle,
      child: surface,
    );

    // ── Disabled: fade opacità ───────────────────────────────────────
    button = AnimatedOpacity(
      opacity: widget.enabled ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 150),
      child: button,
    );

    if (widget.tooltip != null && widget.tooltip!.isNotEmpty) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }

    if (widget.semanticLabel != null && widget.semanticLabel!.isNotEmpty) {
      button = Semantics(
        button: true,
        enabled: isInteractive,
        label: widget.semanticLabel,
        child: ExcludeSemantics(child: button),
      );
    }

    return button;
  }
}
