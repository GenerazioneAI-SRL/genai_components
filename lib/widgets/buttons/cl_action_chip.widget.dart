import 'package:flutter/material.dart';

import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';

/// Tonal variants for [CLActionChip].
enum CLActionChipTone { primary, secondary, success, warning, danger, neutral }

/// Compact inline action chip — used for in-row/in-card actions like
/// "Gestisci", "Badge", "Modifica" etc. Smaller than `CLButton.compact`
/// (28px high vs 32) with tonal-tint chrome (`color × 0.10` bg + colored
/// label/icon). Replaces ad-hoc `Container + InkWell + Padding` patterns
/// scattered in pages.
///
/// Example:
/// ```dart
/// CLActionChip(
///   label: 'Gestisci',
///   icon: Icons.edit_outlined,
///   onTap: () => _showDialog(),
/// )
/// ```
class CLActionChip extends StatefulWidget {
  /// Label text.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Tap handler. If null, the chip is rendered disabled.
  final VoidCallback? onTap;

  /// Color tone. Defaults to primary.
  final CLActionChipTone tone;

  /// Custom color override. When provided, takes precedence over [tone].
  final Color? color;

  /// Optional tooltip.
  final String? tooltip;

  const CLActionChip({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.tone = CLActionChipTone.primary,
    this.color,
    this.tooltip,
  });

  @override
  State<CLActionChip> createState() => _CLActionChipState();
}

class _CLActionChipState extends State<CLActionChip> {
  bool _hovered = false;
  bool _pressed = false;

  Color _toneColor(CLTheme theme) {
    if (widget.color != null) return widget.color!;
    switch (widget.tone) {
      case CLActionChipTone.primary:
        return theme.primary;
      case CLActionChipTone.secondary:
        return theme.secondary;
      case CLActionChipTone.success:
        return theme.success;
      case CLActionChipTone.warning:
        return theme.warning;
      case CLActionChipTone.danger:
        return theme.danger;
      case CLActionChipTone.neutral:
        return theme.secondaryText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final disabled = widget.onTap == null;
    final base = _toneColor(theme);
    final fg = disabled ? theme.mutedForeground : base;
    final bgAlpha = disabled
        ? 0.04
        : _pressed
            ? 0.18
            : _hovered
                ? 0.14
                : 0.10;
    final borderAlpha = disabled ? 0.10 : (_hovered ? 0.30 : 0.20);

    final chip = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      height: 28,
      padding: EdgeInsets.symmetric(
        horizontal: widget.icon != null ? CLSizes.gapSm : CLSizes.gapMd,
      ),
      decoration: BoxDecoration(
        color: base.withValues(alpha: bgAlpha),
        borderRadius: BorderRadius.circular(CLSizes.radiusChip + 2),
        border: Border.all(color: base.withValues(alpha: borderAlpha), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 14, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            widget.label,
            style: theme.smallLabel.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );

    final interactive = MouseRegion(
      cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: disabled ? null : (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
        onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: chip,
      ),
    );

    if (widget.tooltip == null) return interactive;
    return Tooltip(message: widget.tooltip, child: interactive);
  }
}
