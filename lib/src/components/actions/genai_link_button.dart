import 'package:flutter/material.dart';

import '../../foundations/animations.dart';
import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';

/// Inline clickable text styled as a link (§6.2.6).
class GenaiLinkButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;

  /// Optional leading icon.
  final IconData? icon;

  /// When `true`, renders a small "external link" icon trailing the label.
  final bool isExternal;

  /// Optional explicit size. When `null`, inherits from the surrounding
  /// text style.
  final GenaiSize? size;

  const GenaiLinkButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isExternal = false,
    this.size,
  });

  @override
  State<GenaiLinkButton> createState() => _GenaiLinkButtonState();
}

class _GenaiLinkButtonState extends State<GenaiLinkButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final disabled = widget.onPressed == null;

    final base = widget.size == GenaiSize.xs ? ty.labelSm : ty.bodyMd;
    final style = base.copyWith(
      color: colors.textLink,
      decoration: _hovered ? TextDecoration.underline : TextDecoration.none,
      decorationColor: colors.textLink,
    );

    final iconSize = (widget.size ?? GenaiSize.sm).iconSize;
    final children = <Widget>[];
    if (widget.icon != null) {
      children.add(Icon(widget.icon, size: iconSize, color: colors.textLink));
      children.add(const SizedBox(width: 4));
    }
    children.add(Text(widget.label, style: style));
    if (widget.isExternal) {
      children.add(const SizedBox(width: 4));
      children.add(Icon(LucideIcons.externalLink, size: iconSize, color: colors.textLink));
    }

    Widget result = Row(mainAxisSize: MainAxisSize.min, children: children);

    result = MouseRegion(
      cursor: disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: disabled ? null : widget.onPressed,
        child: Opacity(
          opacity: disabled ? GenaiInteraction.disabledOpacity : 1.0,
          child: result,
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: !disabled,
      link: true,
      label: widget.label,
      child: result,
    );
  }
}
