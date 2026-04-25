import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import 'genai_button.dart';
import 'genai_icon_button.dart';

/// Primary action paired with a chevron-trigger dropdown of secondary actions —
/// v3 design system (Forma LMS).
///
/// Left half invokes [onPressed]; right half opens [menuItems] and invokes
/// [onMenuSelected] with the chosen entry's value.
class GenaiSplitButton extends StatefulWidget {
  /// Visible label on the primary action.
  final String label;

  /// Optional leading icon on the primary action.
  final IconData? icon;

  /// Primary tap callback.
  final VoidCallback onPressed;

  /// Dropdown menu entries. Use [PopupMenuItem<int>] to get typed callbacks.
  final List<PopupMenuEntry<int>> menuItems;

  /// Called with the value of the selected menu entry.
  final ValueChanged<int>? onMenuSelected;

  /// Visual variant shared by both halves.
  final GenaiButtonVariant variant;

  /// Visual size shared by both halves.
  final GenaiButtonSize size;

  /// When `true`, disables both halves.
  final bool isDisabled;

  /// Screen-reader label used as the menu trigger's accessibility label.
  final String menuSemanticLabel;

  const GenaiSplitButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.menuItems,
    this.icon,
    this.onMenuSelected,
    this.variant = GenaiButtonVariant.primary,
    this.size = GenaiButtonSize.md,
    this.isDisabled = false,
    this.menuSemanticLabel = 'More actions',
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
      position: RelativeRect.fromLTRB(
        pos.dx,
        pos.dy,
        pos.dx + box.size.width,
        pos.dy,
      ),
      items: widget.menuItems,
    );
    if (selected != null) widget.onMenuSelected?.call(selected);
  }

  @override
  Widget build(BuildContext context) {
    final spec = GenaiButtonSpec.resolve(context, widget.size);
    final radius = context.radius.md;
    return Semantics(
      container: true,
      label: widget.label,
      child: ClipRRect(
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
              width: context.sizing.dividerThickness,
              height: spec.height,
              color: context.colors.borderDefault,
            ),
            GenaiIconButton(
              icon: LucideIcons.chevronDown,
              variant: widget.variant,
              size: widget.size,
              onPressed: widget.isDisabled ? null : _openMenu,
              semanticLabel: widget.menuSemanticLabel,
            ),
          ],
        ),
      ),
    );
  }
}
