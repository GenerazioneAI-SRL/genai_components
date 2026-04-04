import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/cl_theme_provider.dart';

/// A pair of confirm / reject icon buttons for inline approval flows.
///
/// Both callbacks are async so the caller can perform a network action while
/// the widget stays interactive.
///
/// ```dart
/// CLConfirmRejectButtons(
///   onConfirm: () async => await api.approve(id),
///   onReject: () async => await api.reject(id),
///   confirmTooltip: 'Approve',
///   rejectTooltip: 'Reject',
/// )
/// ```
class CLConfirmRejectButtons extends StatelessWidget {
  final Future<void> Function() onConfirm;
  final Future<void> Function() onReject;
  final String? confirmTooltip;
  final String? rejectTooltip;

  const CLConfirmRejectButtons({
    super.key,
    required this.onConfirm,
    required this.onReject,
    this.confirmTooltip,
    this.rejectTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);
    final radius = theme.sm;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: confirmTooltip ?? 'Confirm',
          child: InkWell(
            mouseCursor: SystemMouseCursors.click,
            borderRadius: BorderRadius.circular(radius * 2),
            onTap: onConfirm,
            child: CircleAvatar(
              radius: radius,
              backgroundColor: theme.success.withAlpha(71),
              child: FaIcon(
                FontAwesomeIcons.check,
                color: theme.success,
                size: radius,
              ),
            ),
          ),
        ),
        SizedBox(width: theme.sm / 2),
        Tooltip(
          message: rejectTooltip ?? 'Reject',
          child: InkWell(
            mouseCursor: SystemMouseCursors.click,
            borderRadius: BorderRadius.circular(radius * 2),
            onTap: onReject,
            child: CircleAvatar(
              radius: radius,
              backgroundColor: theme.danger.withAlpha(71),
              child: FaIcon(
                FontAwesomeIcons.xmark,
                color: theme.danger,
                size: radius,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
