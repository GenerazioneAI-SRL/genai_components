import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';
import 'genai_button.dart';

/// Visually connects multiple action widgets into a segmented control —
/// v3 design system (Forma LMS, §6 — actions).
///
/// Each child keeps its own callback and identity; the group only adds a
/// shared hairline border, rounded outer corners, and 1-px dividers between
/// siblings. There is no selection state.
///
/// For a selectable segmented group, use `GenaiToggleButtonGroup`.
///
/// Typical usage:
///
/// ```dart
/// GenaiButtonGroup(
///   children: [
///     GenaiButton.outline(label: 'Copy', onPressed: ...),
///     GenaiButton.outline(label: 'Cut', onPressed: ...),
///     GenaiButton.outline(label: 'Paste', onPressed: ...),
///   ],
/// )
/// ```
class GenaiButtonGroup extends StatelessWidget {
  /// Buttons (or other action widgets) rendered side-by-side.
  ///
  /// Provide at least 2 entries — a single child renders as a plain button.
  final List<Widget> children;

  /// Layout direction. Horizontal for toolbars, vertical for stacked menus.
  final Axis axis;

  /// Visual size used to derive shared corner radius. Should match the size
  /// of every child for visual coherence.
  final GenaiButtonSize size;

  /// Screen-reader label describing the group as a whole. Individual children
  /// keep their own semantic labels.
  final String? semanticLabel;

  const GenaiButtonGroup({
    super.key,
    required this.children,
    this.axis = Axis.horizontal,
    this.size = GenaiButtonSize.md,
    this.semanticLabel,
  });

  double _radiusFor(BuildContext context) {
    final radius = context.radius;
    switch (size) {
      case GenaiButtonSize.sm:
        return radius.sm;
      case GenaiButtonSize.md:
        return radius.md;
      case GenaiButtonSize.lg:
        return radius.md;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sizing = context.sizing;
    final radius = _radiusFor(context);

    if (children.isEmpty) return const SizedBox.shrink();

    final separated = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      separated.add(children[i]);
      if (i < children.length - 1) {
        separated.add(
          axis == Axis.horizontal
              ? SizedBox(
                  width: sizing.dividerThickness,
                  child: ColoredBox(color: colors.borderDefault),
                )
              : SizedBox(
                  height: sizing.dividerThickness,
                  child: ColoredBox(color: colors.borderDefault),
                ),
        );
      }
    }

    final inner = axis == Axis.horizontal
        ? Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: separated,
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: separated,
          );

    final clipped = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: inner,
    );

    final framed = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: colors.borderDefault,
          width: sizing.dividerThickness,
        ),
      ),
      child: clipped,
    );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: framed,
    );
  }
}
