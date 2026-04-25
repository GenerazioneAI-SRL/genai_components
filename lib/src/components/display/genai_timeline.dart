import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

/// Single entry inside a [GenaiTimeline].
class GenaiTimelineItem {
  /// Primary title (e.g. "Deployment v2.3.0").
  final String title;

  /// Optional secondary text under the title.
  final String? subtitle;

  /// Optional longer description shown below the subtitle.
  final String? description;

  /// When the event happened. Rendered top-right of the row if provided.
  final DateTime? timestamp;

  /// Dot icon. Defaults to [LucideIcons.circle].
  final IconData icon;

  /// Optional icon/dot color override.
  final Color? iconColor;

  /// Attachment widgets rendered as chips below the description.
  final List<Widget> attachments;

  const GenaiTimelineItem({
    required this.title,
    this.subtitle,
    this.description,
    this.timestamp,
    this.icon = LucideIcons.circle,
    this.iconColor,
    this.attachments = const [],
  });
}

/// Vertical timeline — v3 design system.
///
/// Renders a sequence of events with a rail + icon dots + content. Rail can
/// be hidden via [showRail]. Follows v3 hairline + tabular styling.
class GenaiTimeline extends StatelessWidget {
  /// Events in chronological order (top to bottom).
  final List<GenaiTimelineItem> items;

  /// Whether to draw a connecting rail between dots. Defaults to `true`.
  final bool showRail;

  const GenaiTimeline({
    super.key,
    required this.items,
    this.showRail = true,
  });

  String _formatTimestamp(DateTime t) {
    final dd = t.day.toString().padLeft(2, '0');
    final mm = t.month.toString().padLeft(2, '0');
    final hh = t.hour.toString().padLeft(2, '0');
    final mi = t.minute.toString().padLeft(2, '0');
    return '$dd/$mm/${t.year} $hh:$mi';
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Timeline',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) _buildItem(context, i),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final item = items[index];
    final isLast = index == items.length - 1;
    final dotColor = item.iconColor ?? colors.textPrimary;

    final dotSize = spacing.s24;
    final iconSize = sizing.iconSize - 2;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: dotSize,
            child: Column(
              children: [
                Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: dotColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(item.icon, size: iconSize, color: dotColor),
                ),
                if (!isLast && showRail)
                  Expanded(
                    child: Container(
                      width: sizing.dividerThickness,
                      color: colors.borderDefault,
                      margin: EdgeInsets.symmetric(vertical: spacing.s4),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: spacing.s12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : spacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: ty.bodySm.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (item.timestamp != null)
                        Text(
                          _formatTimestamp(item.timestamp!),
                          style: ty.monoSm.copyWith(color: colors.textTertiary),
                        ),
                    ],
                  ),
                  if (item.subtitle != null)
                    Padding(
                      padding: EdgeInsets.only(top: spacing.s2),
                      child: Text(
                        item.subtitle!,
                        style: ty.labelSm.copyWith(color: colors.textSecondary),
                      ),
                    ),
                  if (item.description != null)
                    Padding(
                      padding: EdgeInsets.only(top: spacing.s4),
                      child: Text(
                        item.description!,
                        style: ty.bodySm.copyWith(color: colors.textPrimary),
                      ),
                    ),
                  if (item.attachments.isNotEmpty) ...[
                    SizedBox(height: spacing.s8),
                    Wrap(
                      spacing: spacing.s6,
                      runSpacing: spacing.s6,
                      children: item.attachments,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
