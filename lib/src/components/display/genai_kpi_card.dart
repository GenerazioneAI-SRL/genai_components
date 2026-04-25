import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';
import 'genai_sparkline.dart';

/// KPI / metric card — v3 design system hero component (§4.3).
///
/// Data-forward card tuned to Forma LMS:
/// - `label` — tiny uppercase caption (`ty.tiny`, 11 / 500 / 0.08em tracking).
/// - `value` — hero number (`ty.kpiNumber`, 28 / 600, tabular figures).
/// - `unit` — optional small suffix beside the number.
/// - `delta` — optional percentage chip with soft bg + base-color text, using
///   up/down/flat glyph from v3 semantics.
/// - `sparkline` — inline trend anchored bottom-right.
///
/// `onTap` promotes the card to a button — Semantics reflect the role.
class GenaiKpiCard extends StatefulWidget {
  /// Short label rendered above the value.
  final String label;

  /// Pre-formatted value string. Callers format numbers client-side.
  final String value;

  /// Optional decimal delta — `+0.12` renders as `↑ +12.0%` in success tone,
  /// `-0.03` as `↓ -3.0%` in danger tone, `0` as `— 0.0%` in neutral. `null`
  /// hides the delta chip.
  final double? delta;

  /// Optional inline sparkline series.
  final List<double>? sparkline;

  /// Optional unit suffix appended to [value] in a subdued style.
  final String? unit;

  /// Optional leading icon rendered in a tinted square.
  final IconData? icon;

  /// Tap callback — promotes the card to a button (hover + focus ring).
  final VoidCallback? onTap;

  /// Accessibility label. Defaults to a composed summary of `label`, `value`,
  /// optional `unit` and delta.
  final String? semanticLabel;

  const GenaiKpiCard({
    super.key,
    required this.label,
    required this.value,
    this.delta,
    this.sparkline,
    this.unit,
    this.icon,
    this.onTap,
    this.semanticLabel,
  });

  @override
  State<GenaiKpiCard> createState() => _GenaiKpiCardState();
}

class _GenaiKpiCardState extends State<GenaiKpiCard> {
  bool _hovered = false;
  bool _focused = false;

  String _formatDelta(double d) {
    final pct = d * 100;
    final sign = pct >= 0 ? '+' : '';
    return '$sign${pct.toStringAsFixed(1)}%';
  }

  String _deltaPrefix(double d) {
    if (d > 0) return '↑';
    if (d < 0) return '↓';
    return '—';
  }

  ({Color fg, Color bg}) _deltaPalette(double d, BuildContext context) {
    final c = context.colors;
    if (d > 0) return (fg: c.colorSuccessText, bg: c.colorSuccessSubtle);
    if (d < 0) return (fg: c.colorDangerText, bg: c.colorDangerSubtle);
    return (fg: c.colorNeutralText, bg: c.colorNeutralSubtle);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final sizing = context.sizing;

    final isInteractive = widget.onTap != null;

    final borderColor =
        isInteractive && _hovered ? colors.borderStrong : colors.borderDefault;

    // Compose label if not overridden.
    final composedLabel = widget.semanticLabel ??
        [
          widget.label,
          widget.value,
          if (widget.unit != null) widget.unit!,
          if (widget.delta != null) _formatDelta(widget.delta!),
        ].join(' ');

    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Container(
            width: spacing.s32,
            height: spacing.s32,
            decoration: BoxDecoration(
              color: colors.colorInfoSubtle,
              borderRadius: BorderRadius.circular(radius.lg),
            ),
            alignment: Alignment.center,
            child: Icon(
              widget.icon,
              size: sizing.iconSize,
              color: colors.colorInfoText,
            ),
          ),
          SizedBox(width: spacing.s8),
        ],
        Expanded(
          child: Text(
            widget.label.toUpperCase(),
            style: ty.tiny.copyWith(color: colors.textTertiary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    final valueRow = Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Flexible(
          child: Text(
            widget.value,
            style: ty.kpiNumber.copyWith(color: colors.textPrimary),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        if (widget.unit != null) ...[
          SizedBox(width: spacing.s4),
          Text(
            widget.unit!,
            style: ty.bodySm.copyWith(color: colors.textSecondary),
          ),
        ],
      ],
    );

    Widget? deltaChip;
    if (widget.delta != null) {
      final d = widget.delta!;
      final p = _deltaPalette(d, context);
      deltaChip = Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.s6,
          vertical: spacing.s2,
        ),
        decoration: BoxDecoration(
          color: p.bg,
          borderRadius: BorderRadius.circular(radius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_deltaPrefix(d), style: ty.labelSm.copyWith(color: p.fg)),
            SizedBox(width: spacing.s2),
            Text(
              _formatDelta(d),
              style: ty.monoSm.copyWith(color: p.fg),
            ),
          ],
        ),
      );
    }

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        header,
        SizedBox(height: spacing.s12),
        valueRow,
        if (deltaChip != null || widget.sparkline != null) ...[
          SizedBox(height: spacing.s8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (deltaChip != null) deltaChip else const SizedBox.shrink(),
              if (widget.sparkline != null)
                GenaiSparkline(
                  data: widget.sparkline!,
                  width: 100,
                  height: 28,
                  semanticLabel: 'Andamento ${widget.label}',
                ),
            ],
          ),
        ],
      ],
    );

    Widget card = Container(
      padding: EdgeInsets.all(spacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(radius.xl),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: isInteractive && _hovered
            ? context.elevation.layer1Hover
            : context.elevation.layer1,
      ),
      child: body,
    );

    if (_focused && isInteractive) {
      card = Stack(
        clipBehavior: Clip.none,
        children: [
          card,
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius.xl),
                  border: Border.all(
                    color: colors.borderFocus,
                    width: sizing.focusRingWidth,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final semanticsNode = Semantics(
      container: true,
      button: isInteractive,
      label: composedLabel,
      child: card,
    );

    if (!isInteractive) return semanticsNode;

    return FocusableActionDetector(
      onShowFocusHighlight: (v) {
        if (_focused != v) setState(() => _focused = v);
      },
      onShowHoverHighlight: (v) {
        if (_hovered != v) setState(() => _hovered = v);
      },
      mouseCursor: SystemMouseCursors.click,
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onTap?.call();
            return null;
          },
        ),
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: semanticsNode,
      ),
    );
  }
}
