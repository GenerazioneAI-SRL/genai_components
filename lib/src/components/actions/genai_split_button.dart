import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';
import 'genai_button.dart';
import 'genai_icon_button.dart';

/// A primary action with a chevron-trigger dropdown of secondary actions
/// (§6.2.4).
class GenaiSplitButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final List<PopupMenuEntry<int>> menuItems;
  final ValueChanged<int>? onMenuSelected;
  final GenaiButtonVariant variant;
  final GenaiSize size;
  final bool isDisabled;

  const GenaiSplitButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.menuItems,
    this.icon,
    this.onMenuSelected,
    this.variant = GenaiButtonVariant.primary,
    this.size = GenaiSize.md,
    this.isDisabled = false,
  });

  @override
  State<GenaiSplitButton> createState() => _GenaiSplitButtonState();
}

class _GenaiSplitButtonState extends State<GenaiSplitButton> {
  Future<void> _openMenu() async {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final pos = box.localToGlobal(Offset(0, box.size.height));
    final selected = await showMenu<int>(
      context: context,
      position: RelativeRect.fromLTRB(pos.dx, pos.dy, pos.dx + box.size.width, pos.dy),
      items: widget.menuItems,
    );
    if (selected != null) widget.onMenuSelected?.call(selected);
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.size.borderRadius;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GenaiButton(
            label: widget.label,
            icon: widget.icon,
            variant: widget.variant,
            size: widget.size,
            onPressed: widget.isDisabled ? null : widget.onPressed,
          ),
          Container(
            width: 1,
            height: widget.size.resolveHeight(isCompact: context.isCompact),
            color: context.colors.borderDefault,
          ),
          GenaiIconButton(
            icon: LucideIcons.chevronDown,
            variant: widget.variant,
            size: widget.size,
            onPressed: widget.isDisabled ? null : _openMenu,
            semanticLabel: 'Altre azioni',
          ),
        ],
      ),
    );
  }
}
