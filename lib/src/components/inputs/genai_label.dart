import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Visual size of a [GenaiLabel] — v3 Forma LMS (§2.3 type scale).
enum GenaiLabelSize {
  /// `label` token — 12 / 500, primary field label (default).
  md,

  /// `labelSm` token — 11.5 / 500, compact clusters.
  sm,

  /// `tiny` token — 11 / 500 uppercase with ~0.06em tracking, section captions.
  tiny,
}

/// Standalone form label for v3 inputs.
///
/// Use for composite fields where a separate label is needed outside a
/// control that already renders its own (e.g. labelling a cluster of chips
/// or pairing a description with a [GenaiToggle]).
///
/// Mirrors the v2 API (`text`, `isRequired`, `isDisabled`, optional `child`)
/// and adds a v3-only `size` + `uppercase` pair that maps onto the Forma LMS
/// type scale — `tiny` matches the HTML's uppercase section captions.
class GenaiLabel extends StatelessWidget {
  /// The label text.
  final String text;

  /// Appends a red `*` suffix per the Forma LMS required-field rule.
  final bool isRequired;

  /// Dims the label to the disabled text colour.
  final bool isDisabled;

  /// Nested widget; when non-null, the label is stacked above with a small
  /// token-driven spacer.
  final Widget? child;

  /// Typography slot to render the label in. Defaults to [GenaiLabelSize.md].
  final GenaiLabelSize size;

  /// Force uppercase transformation. Implicit for [GenaiLabelSize.tiny].
  final bool uppercase;

  /// Screen-reader label override.
  final String? semanticLabel;

  const GenaiLabel({
    super.key,
    required this.text,
    this.isRequired = false,
    this.isDisabled = false,
    this.child,
    this.size = GenaiLabelSize.md,
    this.uppercase = false,
    this.semanticLabel,
  });

  TextStyle _baseStyle(BuildContext context) {
    final ty = context.typography;
    switch (size) {
      case GenaiLabelSize.md:
        return ty.label;
      case GenaiLabelSize.sm:
        return ty.labelSm;
      case GenaiLabelSize.tiny:
        return ty.tiny;
    }
  }

  bool get _isUppercase => uppercase || size == GenaiLabelSize.tiny;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    final textColor = isDisabled ? colors.textDisabled : colors.textSecondary;
    final baseStyle = _baseStyle(context).copyWith(color: textColor);

    final display = _isUppercase ? text.toUpperCase() : text;

    final labelContent = isRequired
        ? Text.rich(
            TextSpan(
              children: [
                TextSpan(text: display, style: baseStyle),
                TextSpan(
                  text: ' *',
                  style: baseStyle.copyWith(color: colors.colorDanger),
                ),
              ],
            ),
          )
        : Text(display, style: baseStyle);

    Widget content = labelContent;
    if (child != null) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          labelContent,
          SizedBox(height: spacing.s6),
          child!,
        ],
      );
    }

    final announced = semanticLabel ?? (isRequired ? '$text, required' : text);

    return Semantics(
      label: announced,
      enabled: !isDisabled,
      child: ExcludeSemantics(child: content),
    );
  }
}
