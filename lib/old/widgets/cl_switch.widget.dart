import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../cl_theme.dart';
import 'foundation/cl_focus_ring.dart';

/// Toggle switch, internalizzato da `ShadSwitch` sulla base CL.
///
/// Foundation nostra: colori via [CLTheme.shad] (superficie ShadColorScheme),
/// focus ring esterno via [CLFocusRingPainter]. Track: primary (on) / input
/// (off); thumb: `shad.background` (bianco).
class CLSwitch extends StatefulWidget {
  const CLSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.enabled = true,
    this.focusNode,
    this.label,
    this.sublabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;
  final FocusNode? focusNode;

  /// Testo/descrizione a fianco del toggle (LTR: a destra). Opzionali.
  final Widget? label;
  final Widget? sublabel;

  @override
  State<CLSwitch> createState() => _CLSwitchState();
}

class _CLSwitchState extends State<CLSwitch> {
  // Dimensioni track/thumb (default shadcn, documentate — non token CL).
  static const double _trackWidth = 44;
  static const double _trackHeight = 24;
  static const double _margin = 2;
  static const double _thumbSize = _trackHeight - _margin * 2; // 20
  static const double _disabledOpacity = 0.5;

  FocusNode? _internalFocus;
  bool _focused = false;

  FocusNode get _focusNode => widget.focusNode ?? (_internalFocus ??= FocusNode());

  @override
  void dispose() {
    _internalFocus?.dispose();
    super.dispose();
  }

  bool get _interactive => widget.enabled && widget.onChanged != null;

  void _toggle() {
    if (!_interactive) return;
    widget.onChanged!(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final scheme = theme.shad;

    final trackColor = widget.value ? scheme.primary : scheme.input;
    final thumbColor = scheme.background; // bianco

    Widget track = AnimatedContainer(
      duration: theme.durationFast,
      curve: Curves.easeInOut,
      width: _trackWidth,
      height: _trackHeight,
      padding: const EdgeInsets.all(_margin),
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(_trackHeight / 2),
      ),
      child: AnimatedAlign(
        duration: theme.durationFast,
        curve: Curves.easeInOut,
        alignment: widget.value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: _thumbSize,
          height: _thumbSize,
          decoration: BoxDecoration(color: thumbColor, shape: BoxShape.circle),
        ),
      ),
    );

    // Focus ring esterno (foundation CLFocusRing): disegnato attorno al track.
    track = CustomPaint(
      foregroundPainter: _focused
          ? CLFocusRingPainter(color: scheme.ring, radius: _trackHeight / 2)
          : null,
      child: track,
    );

    Widget control = Focus(
      focusNode: _focusNode,
      onFocusChange: (f) => setState(() => _focused = f),
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        if (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.space) {
          _toggle();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: MouseRegion(
        cursor: _interactive ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        child: track,
      ),
    );

    if (widget.label != null || widget.sublabel != null) {
      control = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          control,
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.label != null)
                  DefaultTextStyle.merge(
                    style: theme.bodyText.copyWith(
                      fontWeight: FontWeight.w500,
                      color: scheme.foreground,
                    ),
                    child: widget.label!,
                  ),
                if (widget.sublabel != null)
                  DefaultTextStyle.merge(
                    style: theme.smallLabel.copyWith(color: scheme.mutedForeground),
                    child: widget.sublabel!,
                  ),
              ],
            ),
          ),
        ],
      );
    }

    return Opacity(
      opacity: widget.enabled ? 1 : _disabledOpacity,
      child: GestureDetector(
        onTap: _interactive ? _toggle : null,
        behavior: HitTestBehavior.opaque,
        child: control,
      ),
    );
  }
}
