import 'package:flutter/material.dart';
import 'cl_popup_menu.widget.dart';

/// Region che apre un [CLPopupMenu] al tasto destro (desktop) o long-press
/// (mobile) sopra [child], alla posizione del cursore. Equivalente essenziale
/// di ShadContextMenuRegion, costruito sui primitivi CL (nessun overlay proprio:
/// il dismiss tap-fuori/Esc è gestito dal barrier di CLPopupMenu).
class CLContextMenu extends StatelessWidget {
  const CLContextMenu({
    super.key,
    required this.child,
    required this.items,
    this.longPressEnabled = true,
  });

  final Widget child;
  final List<CLPopupMenuItem> items;

  /// Se true, anche il long-press (mobile/touch) apre il menu.
  final bool longPressEnabled;

  void _open(BuildContext context, Offset globalPosition) {
    if (items.isEmpty) return;
    CLPopupMenu.showAt(context: context, globalPosition: globalPosition, items: items);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent, // non ruba i gesti al child
      onSecondaryTapUp: (d) => _open(context, d.globalPosition),
      onLongPressStart: longPressEnabled ? (d) => _open(context, d.globalPosition) : null,
      child: child,
    );
  }
}
