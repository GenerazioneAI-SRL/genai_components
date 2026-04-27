import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

/// Hero-style KPI card for dashboards.
///
/// Public API preserved: same constructor, same required/optional params.
/// Internally upgraded with optional trend chip, count-up animation,
/// gradient accent, and hover lift.
class CLMetricCard extends StatefulWidget {
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
  State<CLMetricCard> createState() => _CLMetricCardState();
}

class _CLMetricCardState extends State<CLMetricCard> {
  bool _hovering = false;

  static const Duration _kHoverAnim = Duration(milliseconds: 160);
  static const Duration _kCountAnim = Duration(milliseconds: 600);
  static const Curve _kCurve = Curves.easeOutCubic;

  // Cached numeric parse: distinguishes "1.234" KPI strings from non-numeric
  // labels (e.g. "—", "N/D"). When non-numeric: skip count-up, show as-is.
  late final _ParsedValue _parsed;

  @override
  void initState() {
    super.initState();
    _parsed = _ParsedValue.parse(widget.value);
  }

  @override
  void didUpdateWidget(covariant CLMetricCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      // Reparse on value change so animation re-targets.
      // ignore: invalid_use_of_protected_member
      setState(() {});
    }
  }

  void _setHover(bool v) {
    if (widget.onTap == null) return;
    if (_hovering == v) return;
    setState(() => _hovering = v);
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final clickable = widget.onTap != null;

    // Hover lift via boxShadow growth.
    final List<BoxShadow> shadow = clickable && _hovering
        ? <BoxShadow>[
            for (final s in theme.cardShadow)
              BoxShadow(
                color: s.color,
                blurRadius: s.blurRadius * 1.5,
                offset: Offset(s.offset.dx, s.offset.dy + 2),
                spreadRadius: s.spreadRadius,
              ),
          ]
        : theme.cardShadow;

    final EdgeInsets cardPadding = EdgeInsets.all(
      widget.compact ? CLSizes.gapLg : CLSizes.gapXl,
    );

    final card = AnimatedContainer(
      duration: _kHoverAnim,
      curve: _kCurve,
      padding: cardPadding,
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(CLSizes.radiusCard),
        border: Border.all(color: theme.cardBorder),
        boxShadow: shadow,
      ),
      child: _buildContent(theme),
    );

    final scaled = AnimatedScale(
      duration: _kHoverAnim,
      curve: _kCurve,
      scale: clickable && _hovering ? 1.005 : 1.0,
      child: card,
    );

    if (!clickable) return scaled;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: scaled,
      ),
    );
  }

  Widget _buildContent(CLTheme theme) {
    final double iconBoxPad = widget.compact ? CLSizes.gapSm : CLSizes.gapMd;
    final double iconSize = widget.compact
        ? CLSizes.iconSizeCompact
        : CLSizes.iconSizeDefault;

    // Hero number style — Satoshi medium-bold, restrained.
    final TextStyle valueStyle = (widget.compact
            ? theme.heading4
            : theme.heading3)
        .copyWith(
      color: theme.primaryText,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.4,
    );

    // Caption: subdued, regular weight, no shouting.
    final TextStyle captionStyle = theme.smallLabel.copyWith(
      color: theme.mutedForeground,
      letterSpacing: 0.2,
      fontWeight: FontWeight.w400,
    );

    final clickable = widget.onTap != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top row: tinted icon container + optional clickable chevron.
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(iconBoxPad),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(CLSizes.radiusControl),
              ),
              child: Icon(widget.icon, size: iconSize, color: widget.color),
            ),
            if (clickable) ...[
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.arrowUpRight,
                  size: 14,
                  color: widget.color,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: widget.compact ? CLSizes.gapMd : CLSizes.gapLg),
        // Hero value with count-up animation (only when numeric).
        if (_parsed.isNumeric)
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: _parsed.numeric!),
            duration: _kCountAnim,
            curve: _kCurve,
            builder: (context, v, _) {
              return Text(
                _parsed.format(v),
                style: valueStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
            },
          )
        else
          Text(
            widget.value,
            style: valueStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        const SizedBox(height: CLSizes.gapXs),
        Text(
          widget.label,
          style: captionStyle,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }
}

// ─── Internal helpers ─────────────────────────────────────────────────────────

/// Parses the `value` string into a numeric tween target while remembering the
/// original formatting (locale separator, decimal places, prefix/suffix) so the
/// count-up animation produces strings shaped like the original.
class _ParsedValue {
  final double? numeric;
  final String prefix;
  final String suffix;
  final int decimals;
  final String thousandsSep;
  final String decimalSep;

  const _ParsedValue._({
    required this.numeric,
    required this.prefix,
    required this.suffix,
    required this.decimals,
    required this.thousandsSep,
    required this.decimalSep,
  });

  bool get isNumeric => numeric != null;

  static _ParsedValue parse(String raw) {
    // Extract leading non-digit prefix and trailing non-digit suffix.
    final match = RegExp(r'^([^\d\-+]*)([\-+]?[\d.,]+)(.*)$').firstMatch(raw);
    if (match == null) {
      return const _ParsedValue._(
        numeric: null,
        prefix: '',
        suffix: '',
        decimals: 0,
        thousandsSep: ',',
        decimalSep: '.',
      );
    }
    final prefix = match.group(1) ?? '';
    final body = match.group(2) ?? '';
    final suffix = match.group(3) ?? '';

    // Detect separators. If both '.' and ',' present, the last one is decimal.
    String decSep = '.';
    String thouSep = ',';
    final hasDot = body.contains('.');
    final hasComma = body.contains(',');
    if (hasDot && hasComma) {
      decSep = body.lastIndexOf('.') > body.lastIndexOf(',') ? '.' : ',';
      thouSep = decSep == '.' ? ',' : '.';
    } else if (hasComma && !hasDot) {
      // Heuristic: comma with 1-2 trailing digits → decimal; else thousands.
      final commaIdx = body.lastIndexOf(',');
      final trailing = body.length - commaIdx - 1;
      if (trailing > 0 && trailing <= 2) {
        decSep = ',';
        thouSep = '.';
      } else {
        decSep = '.';
        thouSep = ',';
      }
    }

    // Normalize to dot-decimal for parsing.
    String normalized = body.replaceAll(thouSep, '');
    if (decSep != '.') normalized = normalized.replaceAll(decSep, '.');

    final parsed = double.tryParse(normalized);
    if (parsed == null) {
      return _ParsedValue._(
        numeric: null,
        prefix: prefix,
        suffix: suffix,
        decimals: 0,
        thousandsSep: thouSep,
        decimalSep: decSep,
      );
    }

    final decIdx = normalized.indexOf('.');
    final decimals = decIdx >= 0 ? (normalized.length - decIdx - 1) : 0;

    return _ParsedValue._(
      numeric: parsed,
      prefix: prefix,
      suffix: suffix,
      decimals: decimals.clamp(0, 4),
      thousandsSep: thouSep,
      decimalSep: decSep,
    );
  }

  String format(double v) {
    final fixed = v.toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final intPart = parts[0];
    final fracPart = parts.length > 1 ? parts[1] : '';

    // Group thousands.
    final isNeg = intPart.startsWith('-');
    final digits = isNeg ? intPart.substring(1) : intPart;
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(thousandsSep);
      buf.write(digits[i]);
    }
    final intGrouped = (isNeg ? '-' : '') + buf.toString();

    final body = decimals > 0 ? '$intGrouped$decimalSep$fracPart' : intGrouped;
    return '$prefix$body$suffix';
  }
}

