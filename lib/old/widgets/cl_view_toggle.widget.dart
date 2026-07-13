import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

/// Modello per un'opzione del toggle vista.
class CLViewToggleItem {
  const CLViewToggleItem({required this.icon, this.label, required this.tooltip, required this.value});

  final IconData icon;
  final String? label;
  final String tooltip;
  final Object value;
}

/// Toggle a pill per alternare tra più viste (es. tabella / calendario).
/// Scala automaticamente tra desktop (icona + label) e mobile (solo icona).
class CLViewToggle<T extends Object> extends StatelessWidget {
  const CLViewToggle({super.key, required this.items, required this.selected, required this.onChanged, this.compact});

  final List<CLViewToggleItem> items;
  final T selected;
  final void Function(T value) onChanged;

  /// `null` → decide in base al breakpoint; `true` → solo icone; `false` → icona + label.
  final bool? compact;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;
    final isCompact = compact ?? !isDesktop;

    // ── token dimensionali ────────────────────────────────────────────────
    final outerPad   = isDesktop ? 3.0 : 2.5;
    final outerR     = Sizes.borderRadius - 2;
    final innerR     = Sizes.borderRadius - 4;
    final iconSize   = isDesktop ? 16.0 : 15.0;
    final hPadLabel  = isDesktop ? 11.0 : 9.0;
    final hPadIcon   = isDesktop ? 9.0  : 7.0;
    final vPad       = isDesktop ? 7.0  : 6.0;
    final labelSize  = isDesktop ? 12.0 : 11.0;
    final gap        = isDesktop ? 3.0  : 2.0;

    return Container(
      padding: EdgeInsets.all(outerPad),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(outerR),
        border: Border.all(color: theme.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) SizedBox(width: gap),
            _ToggleButton(
              item: items[i],
              isSelected: items[i].value == selected,
              isCompact: isCompact,
              theme: theme,
              innerR: innerR,
              iconSize: iconSize,
              hPadLabel: hPadLabel,
              hPadIcon: hPadIcon,
              vPad: vPad,
              labelSize: labelSize,
              onTap: () => onChanged(items[i].value as T),
            ),
          ],
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.item,
    required this.isSelected,
    required this.isCompact,
    required this.theme,
    required this.innerR,
    required this.iconSize,
    required this.hPadLabel,
    required this.hPadIcon,
    required this.vPad,
    required this.labelSize,
    required this.onTap,
  });

  final CLViewToggleItem item;
  final bool isSelected;
  final bool isCompact;
  final CLTheme theme;
  final double innerR, iconSize, hPadLabel, hPadIcon, vPad, labelSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final showLabel = !isCompact && item.label != null && item.label!.isNotEmpty;

    return Tooltip(
      message: item.tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(innerR),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: EdgeInsets.symmetric(
            horizontal: showLabel ? hPadLabel : hPadIcon,
            vertical: vPad,
          ),
          decoration: BoxDecoration(
            color: isSelected ? theme.primary.withValues(alpha: theme.opacityMuted) : Colors.transparent,
            borderRadius: BorderRadius.circular(innerR),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, size: iconSize, color: isSelected ? theme.primary : theme.secondaryText),
              if (showLabel) ...[
                const SizedBox(width: 5),
                Text(
                  item.label!,
                  style: theme.smallLabel.copyWith(
                    fontSize: labelSize,
                    color: isSelected ? theme.primary : theme.secondaryText,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
