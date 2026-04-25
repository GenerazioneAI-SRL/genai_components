import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

/// Composable form-field wrapper (shadcn parity: `<Field>`) — v3 design system.
///
/// Lays out the standard label + helper + error chrome around any input
/// widget so custom inputs share the visual + a11y guarantees of the built-in
/// v3 inputs.
///
/// Layout:
/// - [label] (with `colorDanger` asterisk if [isRequired], dimmed if
///   [isDisabled])
/// - `spacing.s6` gap (matches the v3 `_FieldFrame` cadence)
/// - [child]
/// - either [helperText] or [errorText] — mutually exclusive (error wins).
///   Helper space is **always reserved** so toggling the error state never
///   causes layout shift.
/// - The error line is wrapped in a `Semantics(liveRegion: true)` so screen
///   readers announce validation changes.
class GenaiField extends StatelessWidget {
  /// Label rendered above [child].
  final String? label;

  /// Helper copy below [child]. Hidden when [errorText] is non-empty.
  final String? helperText;

  /// Error copy below [child]. Takes precedence over [helperText].
  final String? errorText;

  /// When true, appends a danger-colored `*` after [label].
  final bool isRequired;

  /// When true, dims the label to the disabled text color.
  final bool isDisabled;

  /// The input widget.
  final Widget child;

  /// Overrides the announced field label.
  final String? semanticLabel;

  /// When true, reserves a single helper-line height even with no helper or
  /// error visible. Turn off for inline fields.
  final bool reserveHelperSpace;

  const GenaiField({
    super.key,
    required this.child,
    this.label,
    this.helperText,
    this.errorText,
    this.isRequired = false,
    this.isDisabled = false,
    this.semanticLabel,
    this.reserveHelperSpace = true,
  });

  bool get _hasError => errorText != null && errorText!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;

    final labelColor = isDisabled ? colors.textDisabled : colors.textPrimary;
    final helperColor =
        _hasError ? colors.colorDangerText : colors.textTertiary;
    final labelStyle = ty.label.copyWith(color: labelColor);

    final children = <Widget>[];

    if (label != null) {
      children.add(
        Padding(
          padding: EdgeInsets.only(bottom: spacing.s6),
          child: Text.rich(
            TextSpan(
              style: labelStyle,
              children: [
                TextSpan(text: label),
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: labelStyle.copyWith(color: colors.colorDanger),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    children.add(child);

    final showHelper =
        _hasError || (helperText != null && helperText!.isNotEmpty);
    if (showHelper || reserveHelperSpace) {
      final helperLine = showHelper
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (_hasError) ...[
                  ExcludeSemantics(
                    child: Icon(
                      LucideIcons.circleAlert,
                      size: (ty.bodySm.fontSize ?? 13) + 1,
                      color: colors.colorDangerText,
                    ),
                  ),
                  SizedBox(width: spacing.s4),
                ],
                Flexible(
                  child: Text(
                    _hasError ? errorText! : helperText!,
                    style: ty.bodySm.copyWith(color: helperColor),
                  ),
                ),
              ],
            )
          : const SizedBox.shrink();

      children.add(
        Padding(
          padding: EdgeInsets.only(top: spacing.s4),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (ty.bodySm.height ?? 1.4) * (ty.bodySm.fontSize ?? 13),
            ),
            child: Semantics(
              liveRegion: _hasError,
              child: helperLine,
            ),
          ),
        ),
      );
    }

    return Semantics(
      container: true,
      label: semanticLabel,
      enabled: !isDisabled,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
