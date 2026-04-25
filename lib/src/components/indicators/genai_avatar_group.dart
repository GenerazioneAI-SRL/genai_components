import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';
import 'genai_avatar.dart';

/// Stack of overlapping avatars with `+N` overflow — v3 design system
/// (Forma LMS). The outer ring uses `surfaceCard` so the group reads cleanly
/// on panel or page surfaces.
class GenaiAvatarGroup extends StatelessWidget {
  /// Avatars in render order (left → right, left-most on top).
  final List<GenaiAvatar> avatars;

  /// Maximum number of visible avatars before collapsing into `+N`.
  final int maxVisible;

  /// Size scale shared by every tile. Must match the avatars' own size.
  final GenaiAvatarSize size;

  /// Called when the group is tapped (e.g. to open a roster dialog).
  final VoidCallback? onTap;

  /// Screen-reader label when [onTap] is non-null.
  final String semanticLabel;

  const GenaiAvatarGroup({
    super.key,
    required this.avatars,
    this.maxVisible = 3,
    this.size = GenaiAvatarSize.md,
    this.onTap,
    this.semanticLabel = 'Avatar group',
  });

  @override
  Widget build(BuildContext context) {
    final visible = avatars.take(maxVisible).toList();
    final overflow = avatars.length - visible.length;
    final dim = size.size;
    final overlap = context.spacing.s8;
    final stride = dim - overlap;

    final children = <Widget>[];
    for (var i = 0; i < visible.length; i++) {
      children.add(Positioned(
        left: stride * i,
        child: _withBorder(context, visible[i], dim),
      ));
    }
    if (overflow > 0) {
      children.add(Positioned(
        left: stride * visible.length,
        child: _withBorder(
          context,
          _OverflowAvatar(count: overflow, size: dim),
          dim,
        ),
      ));
    }

    final totalWidth =
        stride * (visible.length + (overflow > 0 ? 1 : 0)) + overlap;
    final stack = SizedBox(
      width: totalWidth,
      height: dim,
      child: Stack(children: children),
    );

    if (onTap == null) return stack;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(onTap: onTap, child: stack),
      ),
    );
  }

  Widget _withBorder(BuildContext context, Widget avatar, double dim) {
    return Container(
      width: dim,
      height: dim,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: context.colors.surfaceCard,
          width: context.sizing.focusRingWidth,
        ),
      ),
      child: ClipOval(child: avatar),
    );
  }
}

class _OverflowAvatar extends StatelessWidget {
  final int count;
  final double size;

  const _OverflowAvatar({required this.count, required this.size});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.surfaceHover,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '+$count',
        style: context.typography.label.copyWith(
          color: colors.textSecondary,
          fontSize: size * 0.32,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      ),
    );
  }
}
