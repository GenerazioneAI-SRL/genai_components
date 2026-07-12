import 'package:flutter/material.dart';

/// Stato interattivo risolto, passato al builder di [CLPressable].
@immutable
class CLPressableState {
  const CLPressableState({
    this.hovered = false,
    this.pressed = false,
    this.focused = false,
    this.disabled = false,
  });

  final bool hovered;
  final bool pressed;
  final bool focused;
  final bool disabled;

  bool get enabled => !disabled;

  /// Nessuno stato interattivo attivo (né hover, né press, né focus, né disabled).
  bool get idle => !hovered && !pressed && !focused && !disabled;

  @override
  bool operator ==(Object other) =>
      other is CLPressableState &&
      other.hovered == hovered &&
      other.pressed == pressed &&
      other.focused == focused &&
      other.disabled == disabled;

  @override
  int get hashCode => Object.hash(hovered, pressed, focused, disabled);
}

typedef CLPressableBuilder = Widget Function(BuildContext context, CLPressableState state);

/// Primitivo di interazione condiviso — **Foundation / Tier 0**.
///
/// Traccia hover / press / focus / disabled **una volta sola** ed espone lo stato
/// al [builder], che decide il rendering. Sostituisce i tanti hand-roll di
/// `MouseRegion + _hovered bool` sparsi nella libreria: ogni widget interattivo
/// (bottoni, chip, voci nav, righe di tabella) si costruisce sopra questo.
///
/// Non impone visuali: motion e colori restano responsabilità del consumer
/// (tipicamente via `CLStyle` + `AnimatedContainer(duration: theme.durationFast)`).
///
/// Gestisce anche l'attivazione da tastiera (Enter/Space, via [ActivateIntent])
/// e la semantica `button` per accessibilità — cose che i singoli hand-roll
/// tipicamente dimenticano.
///
/// Esempio:
/// ```dart
/// CLPressable(
///   onTap: onTap,
///   enabled: onTap != null,
///   builder: (context, state) => AnimatedContainer(
///     duration: theme.durationFast,
///     color: state.hovered ? hoverColor : baseColor,
///     child: child,
///   ),
/// )
/// ```
class CLPressable extends StatefulWidget {
  const CLPressable({
    super.key,
    required this.builder,
    this.onTap,
    this.onLongPress,
    this.onTapDown,
    this.enabled = true,
    this.cursor,
    this.focusNode,
    this.autofocus = false,
    this.behavior = HitTestBehavior.opaque,
    this.semanticButton = true,
    this.semanticLabel,
  });

  final CLPressableBuilder builder;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Chiamato al press-down (prima del tap), solo se `enabled`. Utile per un
  /// feedback immediato (es. `HapticFeedback`). Non implica attivazione.
  final VoidCallback? onTapDown;

  /// Quando `false` lo stato è `disabled`: niente hover/press/tap, cursore neutro.
  final bool enabled;

  /// Override del cursore. Default: `click` se attivo e c'è un handler, altrimenti neutro.
  final MouseCursor? cursor;

  final FocusNode? focusNode;
  final bool autofocus;
  final HitTestBehavior behavior;

  /// Espone `Semantics(button: true)`. Metti `false` per elementi non-bottone
  /// (es. una riga solo-hover).
  final bool semanticButton;
  final String? semanticLabel;

  @override
  State<CLPressable> createState() => _CLPressableState();
}

class _CLPressableState extends State<CLPressable> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  bool get _enabled => widget.enabled;

  void _setHovered(bool v) {
    v = _enabled && v;
    if (_hovered == v) return;
    setState(() {
      _hovered = v;
      // Uscita del puntatore azzera anche il press pendente.
      if (!v) _pressed = false;
    });
  }

  void _setFocused(bool v) {
    if (_focused == v) return;
    setState(() => _focused = v);
  }

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  void _handleTap() {
    if (_enabled) widget.onTap?.call();
  }

  void _handleLongPress() {
    if (_enabled) widget.onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    final state = CLPressableState(
      hovered: _enabled && _hovered,
      pressed: _enabled && _pressed,
      focused: _enabled && _focused,
      disabled: !_enabled,
    );

    final MouseCursor cursor = !_enabled
        ? SystemMouseCursors.basic
        : (widget.cursor ?? (widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer));

    final Widget child = GestureDetector(
      behavior: widget.behavior,
      onTap: _enabled && widget.onTap != null ? _handleTap : null,
      onLongPress: _enabled && widget.onLongPress != null ? _handleLongPress : null,
      onTapDown: _enabled
          ? (_) {
              _setPressed(true);
              widget.onTapDown?.call();
            }
          : null,
      onTapUp: _enabled ? (_) => _setPressed(false) : null,
      onTapCancel: _enabled ? () => _setPressed(false) : null,
      child: widget.builder(context, state),
    );

    return FocusableActionDetector(
      enabled: _enabled,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      mouseCursor: cursor,
      onShowHoverHighlight: _setHovered,
      onShowFocusHighlight: _setFocused,
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            _handleTap();
            return null;
          },
        ),
      },
      child: Semantics(
        button: widget.semanticButton,
        enabled: _enabled,
        label: widget.semanticLabel,
        container: false,
        child: child,
      ),
    );
  }
}
