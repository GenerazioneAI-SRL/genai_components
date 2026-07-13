import 'package:flutter/material.dart';

import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import '../foundation/cl_pressable.widget.dart';

/// Tonal variants for [CLActionChip].
enum CLActionChipTone { primary, secondary, success, warning, danger, neutral }

/// Compact inline action chip — used for in-row/in-card actions like
/// "Gestisci", "Badge", "Modifica" etc. Smaller than `CLButton.compact`
/// (28px high vs 32) with tonal-tint chrome (`color × 0.10` bg + colored
/// label/icon). Replaces ad-hoc `Container + InkWell + Padding` patterns
/// scattered in pages.
///
/// Interazione (hover/press/disabled + attivazione da tastiera) delegata al
/// primitivo Foundation [CLPressable]; il chrome/visuale resta invariato.
///
/// Example:
/// ```dart
/// CLActionChip(
///   label: 'Gestisci',
///   icon: Icons.edit_outlined,
///   onTap: () => _showDialog(),
/// )
/// ```
class CLActionChip extends StatelessWidget {
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

  Color _toneColor(CLTheme theme) {
    if (color != null) return color!;
    switch (tone) {
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
    final disabled = onTap == null;
    final base = _toneColor(theme);
    final fg = disabled ? theme.mutedForeground : base;

    final chip = CLPressable(
      enabled: !disabled,
      onTap: onTap,
      semanticLabel: label,
      builder: (context, state) {
        final bgAlpha = state.disabled
            ? theme.opacityFaint
            : state.pressed
                ? 0.18
                : state.hovered
                    ? theme.opacityMuted
                    : theme.opacitySoft;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          height: 28,
          padding: EdgeInsets.symmetric(
            horizontal: icon != null ? theme.gapSm : theme.gapMd,
          ),
          decoration: BoxDecoration(
            color: base.withValues(alpha: bgAlpha),
            borderRadius: BorderRadius.circular(theme.radiusControl),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: fg),
                const SizedBox(width: Sizes.gapXs),
              ],
              Text(
                label,
                style: theme.smallLabel.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );

    if (tooltip == null) return chip;
    return Tooltip(message: tooltip, child: chip);
  }
}
