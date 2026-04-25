import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

/// Private frame shared by every v3 input (§9 field rules).
///
/// Renders the standard chrome around a form control body:
/// * `label` above the control, with an optional `colorDanger` asterisk when
///   [isRequired] is true.
/// * [control] — the actual field body.
/// * `helperText` / `errorText` rendered beneath the control with **reserved
///   space** so toggling the error state never causes layout shift.
/// * `Semantics(liveRegion: true)` around the error line so screen readers
///   announce validation changes as they happen.
///
/// Not exported from the v3 barrel — consumers only see individual inputs.
class FieldFrame extends StatelessWidget {
  /// Label rendered above [control].
  final String? label;

  /// Appends a red `*` suffix to [label].
  final bool isRequired;

  /// When true, dims the label to the disabled text colour.
  final bool isDisabled;

  /// Helper copy below the control.
  final String? helperText;

  /// Error copy below the control. Takes precedence over [helperText] when
  /// non-null and non-empty.
  final String? errorText;

  /// The input body.
  final Widget control;

  /// Secondary content placed to the right of the helper/counter row —
  /// typically a character counter in text inputs. Space is reserved even
  /// when null to preserve layout stability.
  final Widget? trailingHelper;

  /// When true, reserves a single helper-line-height even with no helper/error
  /// visible. Turn off for inline inputs (single checkbox) where helper space
  /// below would look odd.
  final bool reserveHelperSpace;

  const FieldFrame({
    super.key,
    required this.control,
    this.label,
    this.isRequired = false,
    this.isDisabled = false,
    this.helperText,
    this.errorText,
    this.trailingHelper,
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

    final children = <Widget>[];

    if (label != null) {
      children.add(
        Padding(
          padding: EdgeInsets.only(bottom: spacing.s6),
          child: Text.rich(
            TextSpan(
              style: ty.label.copyWith(color: labelColor),
              children: [
                TextSpan(text: label),
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: ty.label.copyWith(color: colors.colorDanger),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    children.add(control);

    final showHelper =
        _hasError || (helperText != null && helperText!.isNotEmpty);
    if (showHelper || reserveHelperSpace || trailingHelper != null) {
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Semantics(
                    liveRegion: _hasError,
                    child: helperLine,
                  ),
                ),
                if (trailingHelper != null) trailingHelper!,
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}
