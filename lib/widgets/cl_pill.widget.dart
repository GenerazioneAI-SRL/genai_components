import 'package:flutter/material.dart';

import '../cl_theme.dart';

class CLPill extends StatelessWidget {
  const CLPill({
    super.key,
    required this.pillColor,
    required this.pillText,
    this.icon,
    this.outline = false,
  });

  final Color pillColor;
  final String pillText;
  final IconData? icon;
  final bool outline;

  @override
  Widget build(BuildContext context) {
    final textStyle = CLTheme.of(context).bodyText.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: pillColor,
    );

    return IntrinsicWidth(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: outline ? Colors.transparent : pillColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(9999),
          border: outline ? Border.all(color: pillColor, width: 1.0) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: pillColor),
              const SizedBox(width: 4),
            ],
            Text(pillText, style: textStyle, overflow: TextOverflow.ellipsis, maxLines: 1),
          ],
        ),
      ),
    );
  }
}
