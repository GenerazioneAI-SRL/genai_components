import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import 'genai_button.dart';

/// Inline clickable text styled as a link — v3 design system (Forma LMS).
///
/// Underlines on hover, uses `textLink` color. Typical use: the
/// `.section-h a, .section-h button` style in the reference HTML (12.5 px
/// info-blue link aligned to the right of section headers).
class GenaiLinkButton extends StatefulWidget {
  /// Visible link text.
  final String label;

  /// Tap callback. `null` disables the link.
  final VoidCallback? onPressed;

  /// Optional leading icon.
  final IconData? icon;

  /// When `true`, appends an external-link glyph after the label.
  final bool isExternal;

  /// Optional explicit size. When `null`, inherits from the surrounding
  /// body text style (13/400 `bodySm`).
  final GenaiButtonSize? size;

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
    final spacing = context.spacing;
    final disabled = widget.onPressed == null;

    final base = switch (widget.size) {
      GenaiButtonSize.sm => ty.labelSm,
      GenaiButtonSize.lg => ty.body,
      _ => ty.bodySm,
    };

    final style = base.copyWith(
      color: colors.textLink,
      decoration: _hovered ? TextDecoration.underline : TextDecoration.none,
      decorationColor: colors.textLink,
    );

    final iconSize = switch (widget.size) {
      GenaiButtonSize.sm => 14.0,
      GenaiButtonSize.lg => 18.0,
      _ => 16.0,
    };

    final gap = SizedBox(width: spacing.s4);
    final children = <Widget>[];
    if (widget.icon != null) {
      children.add(Icon(widget.icon, size: iconSize, color: colors.textLink));
      children.add(gap);
    }
    children.add(Text(widget.label, style: style));
    if (widget.isExternal) {
      children.add(gap);
      children.add(
        Icon(LucideIcons.externalLink, size: iconSize, color: colors.textLink),
      );
    }

    Widget result = Row(mainAxisSize: MainAxisSize.min, children: children);

    result = MouseRegion(
      cursor:
          disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      opaque: false,
      hitTestBehavior: HitTestBehavior.opaque,
      onEnter: (_) {
        if (!_hovered) setState(() => _hovered = true);
      },
      onExit: (_) {
        if (_hovered) setState(() => _hovered = false);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: disabled ? null : widget.onPressed,
        child: Opacity(
          opacity: disabled ? 0.5 : 1.0,
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
