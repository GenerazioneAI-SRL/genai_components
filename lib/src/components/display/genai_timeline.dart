import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

class GenaiTimelineItem {
  final String title;
  final String? subtitle;
  final String? description;
  final DateTime? timestamp;
  final IconData icon;
  final Color? iconColor;
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

/// Timeline (§6.7.5).
///
/// Vertical sequence of events with rail + dots + content.
class GenaiTimeline extends StatelessWidget {
  final List<GenaiTimelineItem> items;
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
    final colors = context.colors;
    final ty = context.typography;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++) _buildItem(context, i, colors, ty),
      ],
    );
  }

  Widget _buildItem(BuildContext context, int index, dynamic colors, dynamic ty) {
    final item = items[index];
    final isLast = index == items.length - 1;
    final iconColor = item.iconColor ?? colors.colorPrimary;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(item.icon, size: 14, color: iconColor),
                ),
                if (!isLast && showRail)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: colors.borderDefault,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.title, style: ty.label.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600)),
                      ),
                      if (item.timestamp != null) Text(_formatTimestamp(item.timestamp!), style: ty.caption.copyWith(color: colors.textSecondary)),
                    ],
                  ),
                  if (item.subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(item.subtitle!, style: ty.bodySm.copyWith(color: colors.textSecondary)),
                    ),
                  if (item.description != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(item.description!, style: ty.bodySm.copyWith(color: colors.textPrimary)),
                    ),
                  if (item.attachments.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
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
