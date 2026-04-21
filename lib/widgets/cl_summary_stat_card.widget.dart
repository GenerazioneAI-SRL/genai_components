import 'package:flutter/material.dart';

import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

class CLSummaryStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool compact;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const CLSummaryStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.compact = false,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final cardPadding = padding ??
        EdgeInsets.symmetric(
          horizontal: compact ? 10 : 12,
          vertical: compact ? 8 : 10,
        );

    final card = Container(
      padding: cardPadding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Sizes.borderRadius),
        border: Border.all(color: color.withValues(alpha: 0.28), width: 1),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: compact ? 0.08 : 0.10),
            color.withValues(alpha: compact ? 0.04 : 0.06),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 24 : 28,
            height: compact ? 24 : 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: compact ? 14 : 16, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.bodyText.override(
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontSize: compact ? 14 : 16,
                  ),
                ),
                Text(
                  label,
                  style: theme.smallLabel.override(
                    color: color.withValues(alpha: 0.88),
                    fontWeight: FontWeight.w600,
                    fontSize: compact ? 10 : 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(Sizes.borderRadius),
        onTap: onTap,
        child: card,
      ),
    );
  }
}
