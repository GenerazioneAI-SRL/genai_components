import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

enum GenaiStatusType { active, pending, error, success, warning, info, neutral }

/// Status pill with optional leading dot (§6.7.3).
class GenaiStatusBadge extends StatelessWidget {
  final String label;
  final GenaiStatusType status;
  final bool hasDot;

  /// Optional override for the dot/label color, replacing the [status] mapping.
  final Color? colorOverride;

  const GenaiStatusBadge({
    super.key,
    required this.label,
    this.status = GenaiStatusType.neutral,
    this.hasDot = true,
    this.colorOverride,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;

    final dotColor = colorOverride ?? _statusColor(colors);
    final bg = dotColor.withValues(alpha: 0.12);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(label, style: ty.labelSm.copyWith(color: dotColor)),
        ],
      ),
    );
  }

  Color _statusColor(dynamic colors) {
    switch (status) {
      case GenaiStatusType.active:
      case GenaiStatusType.success:
        return colors.colorSuccess;
      case GenaiStatusType.pending:
      case GenaiStatusType.warning:
        return colors.colorWarning;
      case GenaiStatusType.error:
        return colors.colorError;
      case GenaiStatusType.info:
        return colors.colorInfo;
      case GenaiStatusType.neutral:
        return colors.textSecondary;
    }
  }
}
