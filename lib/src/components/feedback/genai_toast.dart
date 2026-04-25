import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import 'genai_alert.dart' show GenaiAlertType;

/// Toast anchor position — v3 design system.
enum GenaiToastPosition {
  topLeft,
  topCenter,
  topRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

/// Inline toast notification — v3 design system.
///
/// Unlike the inline [GenaiAlert] list row, the toast is a floating overlay
/// with a `layer2` shadow. It keeps the left-stripe accent to preserve the
/// required fixed semantic pairing (color + icon + label) per §1, and uses
/// v3 color + radius + shadow tokens. Live region announces danger / warning
/// / success automatically.
class GenaiToast extends StatelessWidget {
  /// Severity — shared with [GenaiAlertType].
  final GenaiAlertType type;

  /// Required message text.
  final String message;

  /// Optional action label (rendered as a text button on the right).
  final String? actionLabel;

  /// Called when the action is pressed.
  final VoidCallback? onAction;

  /// Called when the dismiss "x" is pressed.
  final VoidCallback? onDismiss;

  /// Accessible label for the dismiss button.
  final String dismissSemanticLabel;

  const GenaiToast({
    super.key,
    required this.message,
    this.type = GenaiAlertType.info,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.dismissSemanticLabel = 'Dismiss notification',
  });

  ({Color fg, IconData icon}) _resolve(BuildContext context) {
    final c = context.colors;
    switch (type) {
      case GenaiAlertType.info:
        return (fg: c.colorInfo, icon: LucideIcons.info);
      case GenaiAlertType.success:
        return (fg: c.colorSuccess, icon: LucideIcons.circleCheck);
      case GenaiAlertType.warning:
        return (fg: c.colorWarning, icon: LucideIcons.triangleAlert);
      case GenaiAlertType.danger:
        return (fg: c.colorDanger, icon: LucideIcons.circleAlert);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final elevation = context.elevation;
    final sizing = context.sizing;
    final r = _resolve(context);
    final liveRegion = type == GenaiAlertType.danger ||
        type == GenaiAlertType.warning ||
        type == GenaiAlertType.success;

    return Semantics(
      container: true,
      liveRegion: liveRegion,
      value: message,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, minWidth: 280),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.s12,
            vertical: spacing.s10,
          ),
          decoration: BoxDecoration(
            color: colors.surfaceOverlay,
            borderRadius: BorderRadius.circular(radius.md),
            border: Border(
              left: BorderSide(color: r.fg, width: spacing.s2),
              top: BorderSide(color: colors.borderSubtle),
              right: BorderSide(color: colors.borderSubtle),
              bottom: BorderSide(color: colors.borderSubtle),
            ),
            boxShadow: elevation.shadowForLayer(2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(r.icon, size: sizing.iconSize, color: r.fg),
              SizedBox(width: spacing.s8),
              Flexible(
                child: Text(
                  message,
                  style: ty.bodySm.copyWith(color: colors.textPrimary),
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                SizedBox(width: spacing.s12),
                _ToastTextAction(
                  label: actionLabel!,
                  onPressed: onAction!,
                  color: r.fg,
                ),
              ],
              if (onDismiss != null) ...[
                SizedBox(width: spacing.s4),
                _ToastIconButton(
                  icon: LucideIcons.x,
                  onPressed: onDismiss!,
                  semanticLabel: dismissSemanticLabel,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ToastTextAction extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const _ToastTextAction({
    required this.label,
    required this.onPressed,
    required this.color,
  });

  @override
  State<_ToastTextAction> createState() => _ToastTextActionState();
}

class _ToastTextActionState extends State<_ToastTextAction> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final ty = context.typography;
    final colors = context.colors;
    final sizing = context.sizing;
    final radius = context.radius;

    return Semantics(
      button: true,
      label: widget.label,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowHoverHighlight: (v) => setState(() => _hovered = v),
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onPressed();
              return null;
            },
          ),
        },
        child: GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.spacing.s6,
              vertical: context.spacing.s2,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius.sm),
              border: _focused
                  ? Border.all(
                      color: colors.borderFocus,
                      width: sizing.focusRingWidth,
                    )
                  : null,
            ),
            child: Text(
              widget.label,
              style: ty.label.copyWith(
                color: widget.color,
                decoration:
                    _hovered ? TextDecoration.underline : TextDecoration.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String semanticLabel;

  const _ToastIconButton({
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
  });

  @override
  State<_ToastIconButton> createState() => _ToastIconButtonState();
}

class _ToastIconButtonState extends State<_ToastIconButton> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;
    final sizing = context.sizing;
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowHoverHighlight: (v) => setState(() => _hovered = v),
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onPressed();
              return null;
            },
          ),
        },
        child: GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _hovered ? colors.surfaceHover : Colors.transparent,
              borderRadius: BorderRadius.circular(radius.sm),
              border: _focused
                  ? Border.all(
                      color: colors.borderFocus,
                      width: sizing.focusRingWidth,
                    )
                  : null,
            ),
            child: Icon(
              widget.icon,
              size: 14,
              color: colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Imperative toast API — v3 design system.
///
/// Mounts a [GenaiToast] as an [OverlayEntry] anchored via [position]. Auto-
/// dismisses after [duration] (default 4 s). When the user prefers reduced
/// motion, enter/exit transitions collapse to zero.
///
/// Returns a `Future<void>` that resolves when the toast is removed.
Future<void> showGenaiToast(
  BuildContext context, {
  required String message,
  GenaiAlertType type = GenaiAlertType.info,
  GenaiToastPosition position = GenaiToastPosition.bottomRight,
  Duration duration = const Duration(seconds: 4),
  String? actionLabel,
  VoidCallback? onAction,
}) async {
  final overlay = Overlay.of(context, rootOverlay: true);
  final spacing = context.spacing;
  final reduced = context.motion.hover.duration == Duration.zero;
  final toastMotion = context.motion.toast;

  late final OverlayEntry entry;
  final controller = _ToastController();

  void remove() {
    if (!controller.removed) {
      controller.removed = true;
      if (entry.mounted) entry.remove();
    }
  }

  entry = OverlayEntry(
    builder: (ctx) {
      final edge = spacing.s16;
      final align = switch (position) {
        GenaiToastPosition.topLeft => Alignment.topLeft,
        GenaiToastPosition.topCenter => Alignment.topCenter,
        GenaiToastPosition.topRight => Alignment.topRight,
        GenaiToastPosition.bottomLeft => Alignment.bottomLeft,
        GenaiToastPosition.bottomCenter => Alignment.bottomCenter,
        GenaiToastPosition.bottomRight => Alignment.bottomRight,
      };

      return Positioned.fill(
        child: Padding(
          padding: EdgeInsets.all(edge),
          child: Align(
            alignment: align,
            child: _ToastTransition(
              reduced: reduced,
              motionDuration: toastMotion.duration,
              motionCurve: toastMotion.curve,
              position: position,
              child: GenaiToast(
                message: message,
                type: type,
                actionLabel: actionLabel,
                onAction: onAction == null
                    ? null
                    : () {
                        onAction();
                        remove();
                      },
                onDismiss: remove,
              ),
            ),
          ),
        ),
      );
    },
  );

  overlay.insert(entry);

  // Wire Esc → dismiss at app level via HardwareKeyboard listener.
  void escHandler(KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      remove();
    }
  }

  HardwareKeyboard.instance.addHandler((event) {
    escHandler(event);
    return false;
  });

  await Future.delayed(duration);
  remove();
}

class _ToastController {
  bool removed = false;
}

class _ToastTransition extends StatefulWidget {
  final Widget child;
  final bool reduced;
  final Duration motionDuration;
  final Curve motionCurve;
  final GenaiToastPosition position;

  const _ToastTransition({
    required this.child,
    required this.reduced,
    required this.motionDuration,
    required this.motionCurve,
    required this.position,
  });

  @override
  State<_ToastTransition> createState() => _ToastTransitionState();
}

class _ToastTransitionState extends State<_ToastTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: widget.reduced ? Duration.zero : widget.motionDuration,
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fromTop = widget.position == GenaiToastPosition.topLeft ||
        widget.position == GenaiToastPosition.topCenter ||
        widget.position == GenaiToastPosition.topRight;

    final slide = Tween<Offset>(
      begin: Offset(0, fromTop ? -0.2 : 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: widget.motionCurve));
    final fade = CurvedAnimation(parent: _ctrl, curve: widget.motionCurve);

    if (widget.reduced) {
      return widget.child;
    }

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: widget.child,
      ),
    );
  }
}
