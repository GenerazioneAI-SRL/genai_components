import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Agenda / calendar date row — v3 design system (§4.4).
///
/// Lists upcoming events with a fixed-width date tile on the left and a
/// flexible content column on the right. Mirrors `.agenda-row` in the Forma
/// LMS reference HTML:
/// - 58 px date tile (`neutral-soft` bg, `radius.lg` = 10, padding 6/8). Day
///   is 18 / 600 tabular; month is 10 px uppercase neutral.
/// - 1fr content: title (bodySm / 600), subtitle (labelSm / ink-2), optional
///   meta row of icon+text widgets.
/// - Row padding 14/20, divided from the next row by a `borderDefault` line.
///
/// The [meta] slot accepts arbitrary widgets — the row wraps them with a
/// DefaultTextStyle of `labelSm` + `textSecondary` and inline `iconSize`.
class GenaiAgendaRow extends StatelessWidget {
  /// Day of month (1..31).
  final int day;

  /// Short month label (e.g. "GEN", "FEB"). Rendered uppercase by the row.
  final String month;

  /// Event title.
  final String title;

  /// Optional secondary line.
  final String? subtitle;

  /// Optional row of meta widgets (icon + text).
  final List<Widget>? meta;

  /// Optional tap callback.
  final VoidCallback? onTap;

  /// Accessibility label. Defaults to a composed summary.
  final String? semanticLabel;

  const GenaiAgendaRow({
    super.key,
    required this.day,
    required this.month,
    required this.title,
    this.subtitle,
    this.meta,
    this.onTap,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final sizing = context.sizing;

    final a11y = semanticLabel ??
        [
          '$day $month',
          title,
          if (subtitle != null) subtitle!,
        ].join(' — ');

    final dateTile = Container(
      width: 58,
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s6,
        vertical: spacing.s8,
      ),
      decoration: BoxDecoration(
        color: colors.colorNeutralSubtle,
        borderRadius: BorderRadius.circular(radius.lg),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$day',
            style: ty.sectionTitle.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          SizedBox(height: spacing.s2),
          Text(
            month.toUpperCase(),
            style: ty.tiny.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: ty.bodySm.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null)
          Padding(
            padding: EdgeInsets.only(top: spacing.s2),
            child: Text(
              subtitle!,
              style: ty.labelSm.copyWith(color: colors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        if (meta != null && meta!.isNotEmpty) ...[
          SizedBox(height: spacing.s8),
          DefaultTextStyle.merge(
            style: ty.labelSm.copyWith(color: colors.textSecondary),
            child: IconTheme.merge(
              data: IconThemeData(
                color: colors.textSecondary,
                size: sizing.iconSize - 2,
              ),
              child: Wrap(
                spacing: spacing.s12,
                runSpacing: spacing.s4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: meta!,
              ),
            ),
          ),
        ],
      ],
    );

    final row = Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s20,
        vertical: spacing.s14,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.borderDefault,
            width: sizing.dividerThickness,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          dateTile,
          SizedBox(width: spacing.s14),
          Expanded(child: content),
        ],
      ),
    );

    final semanticsChild = Semantics(
      container: true,
      button: onTap != null,
      label: a11y,
      child: row,
    );

    if (onTap == null) return semanticsChild;
    return InkWell(
      onTap: onTap,
      child: semanticsChild,
    );
  }
}
