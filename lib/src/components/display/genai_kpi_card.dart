import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';
import '../indicators/genai_trend_indicator.dart';
import '../layout/genai_card.dart';

/// KPI / metric card (§6.7.4).
class GenaiKPICard extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final IconData? icon;
  final double? trendPercentage;
  final String? trendLabel;
  final String? footnote;
  final Widget? sparkline;
  final VoidCallback? onTap;

  const GenaiKPICard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.icon,
    this.trendPercentage,
    this.trendLabel,
    this.footnote,
    this.sparkline,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.colorPrimarySubtle,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: colors.colorPrimary),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(label, style: ty.label.copyWith(color: colors.textSecondary)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child:
                  Text(value, style: ty.displaySm.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
            ),
            if (unit != null) ...[
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(unit!, style: ty.bodySm.copyWith(color: colors.textSecondary)),
              ),
            ],
          ],
        ),
        if (trendPercentage != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              GenaiTrendIndicator(percentage: trendPercentage!),
              if (trendLabel != null) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: Text(trendLabel!, style: ty.caption.copyWith(color: colors.textSecondary), overflow: TextOverflow.ellipsis),
                ),
              ],
            ],
          ),
        ],
        if (sparkline != null) ...[
          const SizedBox(height: 12),
          SizedBox(height: 40, child: sparkline!),
        ],
        if (footnote != null) ...[
          const SizedBox(height: 8),
          Text(footnote!, style: ty.caption.copyWith(color: colors.textSecondary)),
        ],
      ],
    );

    return onTap != null ? GenaiCard.interactive(onTap: onTap!, child: body) : GenaiCard(child: body);
  }
}
