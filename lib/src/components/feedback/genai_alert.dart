import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

/// Severity of a [GenaiAlert] — v3 design system.
///
/// Drives the leading icon and its color. Per §1 (fixed semantic pairing),
/// color is always paired with an icon + label; the v3 alert style is a
/// hairline list row, not a tinted banner.
enum GenaiAlertType {
  /// Neutral announcement — info circle.
  info,

  /// Positive confirmation — check circle.
  success,

  /// Attention required — triangle.
  warning,

  /// Something went wrong — circle-alert.
  danger,
}

/// Inline alert list item — v3 design system (§4.4 `.alert`).
///
/// **v3 divergence from v1/v2:** no tinted background, no left border stripe.
/// This is a scanable row meant to stack inside a `GenaiCard`, matching the
/// Forma LMS Dashboard `.alert` pattern:
/// - Grid: `18px icon | 1fr content | auto dismiss` with 12 px gap.
/// - Padding: 14 / 20.
/// - Hairline `border-bottom: --line` between stacked items.
/// - Title 13.5 / 500 ink, body 12.5 / ink-2, meta 11.5 / ink-3.
/// - Dismiss X: 24 × 24, radius 6, hover tints `neutral-soft`.
///
/// For a banner-style alert with tinted background, consumers can wrap content
/// manually using the semantic color tokens — v3 intentionally removes the
/// full-width tinted banner pattern.
class GenaiAlert extends StatefulWidget {
  /// Severity.
  final GenaiAlertType type;

  /// Required title (13.5 / 500).
  final String title;

  /// Optional body (12.5 / ink-2).
  final String? body;

  /// Optional meta line (11.5 / ink-3) — timestamps, IDs, categories.
  final String? meta;

  /// When true (default), suppress the trailing hairline divider.
  /// Use for the last item in a stack to avoid double borders.
  final bool isLastInGroup;

  /// If provided, renders a 24×24 dismiss X and wires Esc to dismiss.
  final VoidCallback? onDismiss;

  /// Accessible label for the dismiss button.
  final String dismissSemanticLabel;

  const GenaiAlert({
    super.key,
    this.type = GenaiAlertType.info,
    required this.title,
    this.body,
    this.meta,
    this.isLastInGroup = false,
    this.onDismiss,
    this.dismissSemanticLabel = 'Dismiss alert',
  });

  const GenaiAlert.info({
    super.key,
    required this.title,
    this.body,
    this.meta,
    this.isLastInGroup = false,
    this.onDismiss,
    this.dismissSemanticLabel = 'Dismiss alert',
  }) : type = GenaiAlertType.info;

  const GenaiAlert.success({
    super.key,
    required this.title,
    this.body,
    this.meta,
    this.isLastInGroup = false,
    this.onDismiss,
    this.dismissSemanticLabel = 'Dismiss alert',
  }) : type = GenaiAlertType.success;

  const GenaiAlert.warning({
    super.key,
    required this.title,
    this.body,
    this.meta,
    this.isLastInGroup = false,
    this.onDismiss,
    this.dismissSemanticLabel = 'Dismiss alert',
  }) : type = GenaiAlertType.warning;

  const GenaiAlert.danger({
    super.key,
    required this.title,
    this.body,
    this.meta,
    this.isLastInGroup = false,
    this.onDismiss,
    this.dismissSemanticLabel = 'Dismiss alert',
  }) : type = GenaiAlertType.danger;

  @override
  State<GenaiAlert> createState() => _GenaiAlertState();
}

class _GenaiAlertState extends State<GenaiAlert> {
  final FocusNode _focusNode = FocusNode(
    skipTraversal: true,
    debugLabel: 'GenaiAlert.dismiss',
  );

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  ({Color fg, IconData icon}) _resolve(BuildContext context) {
    final c = context.colors;
    switch (widget.type) {
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

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (widget.onDismiss == null) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onDismiss!();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final r = _resolve(context);

    final liveRegion = widget.type == GenaiAlertType.danger ||
        widget.type == GenaiAlertType.warning;

    // 13.5 and 12.5 are v3 spec one-offs; we build them from the 13/14 slots.
    final titleStyle = ty.bodySm.copyWith(
      fontSize: 13.5,
      fontWeight: FontWeight.w500,
      color: colors.textPrimary,
    );
    final bodyStyle = ty.bodySm.copyWith(
      fontSize: 12.5,
      color: colors.textSecondary,
      height: 1.45,
    );
    final metaStyle = ty.labelSm.copyWith(color: colors.textTertiary);

    final row = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s20,
        vertical: spacing.s14,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 18 px leading icon column with a 2 px top offset matching
          // `.alert-icon { margin-top: 2px }` in the reference HTML.
          Padding(
            padding: EdgeInsets.only(top: spacing.s2),
            child: SizedBox(
              width: spacing.s18,
              height: spacing.s18,
              child: Icon(r.icon, size: spacing.s18, color: r.fg),
            ),
          ),
          SizedBox(width: spacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.title, style: titleStyle),
                if (widget.body != null) ...[
                  SizedBox(height: spacing.s2),
                  Text(widget.body!, style: bodyStyle),
                ],
                if (widget.meta != null) ...[
                  SizedBox(height: spacing.s6),
                  Text(widget.meta!, style: metaStyle),
                ],
              ],
            ),
          ),
          if (widget.onDismiss != null) ...[
            SizedBox(width: spacing.s12),
            _DismissX(
              onPressed: widget.onDismiss!,
              semanticLabel: widget.dismissSemanticLabel,
            ),
          ],
        ],
      ),
    );

    final bordered = widget.isLastInGroup
        ? row
        : DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colors.borderDefault,
                  width: context.sizing.dividerThickness,
                ),
              ),
            ),
            child: row,
          );

    return Semantics(
      container: true,
      liveRegion: liveRegion,
      label: widget.title,
      value: widget.body,
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: _onKey,
        child: bordered,
      ),
    );
  }
}

class _DismissX extends StatefulWidget {
  final VoidCallback onPressed;
  final String semanticLabel;

  const _DismissX({
    required this.onPressed,
    required this.semanticLabel,
  });

  @override
  State<_DismissX> createState() => _DismissXState();
}

class _DismissXState extends State<_DismissX> {
  final WidgetStatesController _states = WidgetStatesController();

  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;
    final sizing = context.sizing;
    final motion = context.motion;

    final hovered = _states.value.contains(WidgetState.hovered);
    final focused = _states.value.contains(WidgetState.focused);

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: FocusableActionDetector(
        onShowHoverHighlight: (v) => _states.update(WidgetState.hovered, v),
        onShowFocusHighlight: (v) => _states.update(WidgetState.focused, v),
        mouseCursor: SystemMouseCursors.click,
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
          child: AnimatedContainer(
            duration: motion.hover.duration,
            curve: motion.hover.curve,
            // Spec: 24 × 24 visual; minTouchTarget still guards via Semantics.
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: hovered ? colors.surfaceHover : Colors.transparent,
              borderRadius: BorderRadius.circular(radius.sm),
              border: focused
                  ? Border.all(
                      color: colors.borderFocus,
                      width: sizing.focusRingWidth,
                    )
                  : null,
            ),
            child: Icon(
              LucideIcons.x,
              size: 14,
              color: hovered ? colors.textPrimary : colors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}
