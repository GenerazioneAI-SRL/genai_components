import 'package:flutter/material.dart';
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

class CLMetricCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;
  final bool compact;
  final VoidCallback? onTap;

  const CLMetricCard({
    super.key,
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);

    final card = Container(
      padding: EdgeInsets.all(compact ? 12.0 : Sizes.padding),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(Sizes.radiusCard),
        border: Border.all(color: theme.cardBorder),
        boxShadow: theme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(compact ? 6.0 : 8.0),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(Sizes.radiusSm),
            ),
            child: Icon(icon, size: compact ? 14.0 : 16.0, color: color),
          ),
          SizedBox(height: compact ? 8.0 : 12.0),
          Text(
            value,
            style: (compact ? theme.heading4 : theme.heading3).copyWith(
              color: theme.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.bodyLabel,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(Sizes.radiusCard),
        onTap: onTap,
        child: card,
      ),
    );
  }
}
