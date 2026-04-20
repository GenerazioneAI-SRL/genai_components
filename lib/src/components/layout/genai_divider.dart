import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Visual separator (§6.3.2).
class GenaiDivider extends StatelessWidget {
  final Axis direction;
  final double thickness;
  final double indent;
  final double endIndent;
  final String? label;

  const GenaiDivider({
    super.key,
    this.direction = Axis.horizontal,
    this.thickness = 1,
    this.indent = 0,
    this.endIndent = 0,
    this.label,
  });

  const GenaiDivider.vertical({
    super.key,
    this.thickness = 1,
    this.indent = 0,
    this.endIndent = 0,
  })  : direction = Axis.vertical,
        label = null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;

    if (direction == Axis.vertical) {
      return Container(
        width: thickness,
        margin: EdgeInsets.only(top: indent, bottom: endIndent),
        color: colors.borderDefault,
      );
    }

    final line = Container(
      height: thickness,
      color: colors.borderDefault,
    );

    if (label == null) {
      return Padding(
        padding: EdgeInsets.only(left: indent, right: endIndent),
        child: line,
      );
    }

    return Padding(
      padding: EdgeInsets.only(left: indent, right: endIndent),
      child: Row(
        children: [
          Expanded(child: line),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label!,
              style: ty.caption.copyWith(color: colors.textSecondary),
            ),
          ),
          Expanded(child: line),
        ],
      ),
    );
  }
}
