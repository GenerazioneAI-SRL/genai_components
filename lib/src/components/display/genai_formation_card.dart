import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Formation / training type card — v3 design system (§4.5).
///
/// Domain card for Forma LMS "formazione" grids. Matches the
/// `.formation-card` pattern in the reference HTML:
/// - 34×34 icon badge, `radius.lg` (10), [iconBg] tint, white glyph.
/// - name: 14.5 / 600 primary.
/// - description: 12.5 / 400 secondary, min 36 px height to align cards.
/// - footer row (space-between): optional hours (`ore` totali, mono) + linear
///   progress.
///
/// Card: `surfaceCard` bg, hairline border, `radius.xl` (12). Hover
/// upgrades the shadow to `layer1Hover` when [onTap] is set.
class GenaiFormationCard extends StatefulWidget {
  /// Icon glyph rendered inside the colored badge.
  final IconData icon;

  /// Background color of the icon badge. Use intent-bearing tokens when the
  /// training type has a semantic meaning (e.g. `colorInfo`, `colorSuccess`).
  final Color iconBg;

  /// Course / type name.
  final String name;

  /// Optional description.
  final String? description;

  /// Optional total hours counter (e.g. 24 → "24 ore").
  final int? oreTotali;

  /// Optional progress 0..1. Renders a thin linear track under the footer
  /// when provided.
  final double? progress;

  /// Tap callback.
  final VoidCallback? onTap;

  /// Accessibility label. Defaults to a composed summary.
  final String? semanticLabel;

  const GenaiFormationCard({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.name,
    this.description,
    this.oreTotali,
    this.progress,
    this.onTap,
    this.semanticLabel,
  }) : assert(progress == null || (progress >= 0 && progress <= 1),
            'progress must be in [0, 1] or null');

  @override
  State<GenaiFormationCard> createState() => _GenaiFormationCardState();
}

class _GenaiFormationCardState extends State<GenaiFormationCard> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final sizing = context.sizing;

    final isInteractive = widget.onTap != null;
    final border =
        isInteractive && _hovered ? colors.borderStrong : colors.borderDefault;

    final a11y = widget.semanticLabel ??
        [
          widget.name,
          if (widget.description != null) widget.description!,
          if (widget.oreTotali != null) '${widget.oreTotali} ore',
          if (widget.progress != null)
            '${(widget.progress! * 100).round()}% completato',
        ].join(' — ');

    final iconBadge = Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: widget.iconBg,
        borderRadius: BorderRadius.circular(radius.lg),
      ),
      alignment: Alignment.center,
      child: Icon(
        widget.icon,
        size: sizing.iconSize,
        color: colors.textOnPrimary,
      ),
    );

    final footer = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.oreTotali != null)
          Text(
            '${widget.oreTotali} ore',
            style: ty.monoSm.copyWith(color: colors.textSecondary),
          )
        else
          const SizedBox.shrink(),
        if (widget.progress != null)
          Text(
            '${(widget.progress! * 100).round()}%',
            style: ty.monoSm.copyWith(color: colors.textPrimary),
          ),
      ],
    );

    Widget card = Container(
      padding: EdgeInsets.all(spacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(radius.xl),
        border: Border.all(color: border, width: 1.0),
        boxShadow: isInteractive && _hovered
            ? context.elevation.layer1Hover
            : context.elevation.layer1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          iconBadge,
          SizedBox(height: spacing.s12),
          Text(
            widget.name,
            style: ty.cardTitle.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: spacing.s4),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 36),
            child: Text(
              widget.description ?? '',
              style: ty.bodySm.copyWith(color: colors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: spacing.s14),
          footer,
          if (widget.progress != null) ...[
            SizedBox(height: spacing.s8),
            ClipRRect(
              borderRadius: BorderRadius.circular(radius.pill),
              child: SizedBox(
                height: 4,
                child: Stack(
                  children: [
                    Container(color: colors.borderDefault),
                    FractionallySizedBox(
                      widthFactor: widget.progress!.clamp(0.0, 1.0),
                      heightFactor: 1,
                      child: Container(color: colors.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
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
      label: a11y,
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
