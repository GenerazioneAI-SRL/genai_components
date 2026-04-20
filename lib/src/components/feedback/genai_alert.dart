import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../actions/genai_icon_button.dart';
import '../../tokens/sizing.dart';

enum GenaiAlertType { info, success, warning, error }

/// Inline alert/banner (§6.4.1).
class GenaiAlert extends StatelessWidget {
  final GenaiAlertType type;
  final String? title;
  final String message;
  final List<Widget> actions;
  final VoidCallback? onDismiss;
  final bool showIcon;

  const GenaiAlert({
    super.key,
    this.type = GenaiAlertType.info,
    this.title,
    required this.message,
    this.actions = const [],
    this.onDismiss,
    this.showIcon = true,
  });

  const GenaiAlert.info({
    super.key,
    this.title,
    required this.message,
    this.actions = const [],
    this.onDismiss,
    this.showIcon = true,
  }) : type = GenaiAlertType.info;

  const GenaiAlert.success({
    super.key,
    this.title,
    required this.message,
    this.actions = const [],
    this.onDismiss,
    this.showIcon = true,
  }) : type = GenaiAlertType.success;

  const GenaiAlert.warning({
    super.key,
    this.title,
    required this.message,
    this.actions = const [],
    this.onDismiss,
    this.showIcon = true,
  }) : type = GenaiAlertType.warning;

  const GenaiAlert.error({
    super.key,
    this.title,
    required this.message,
    this.actions = const [],
    this.onDismiss,
    this.showIcon = true,
  }) : type = GenaiAlertType.error;

  ({Color bg, Color fg, Color border, IconData icon}) _resolve(BuildContext context) {
    final c = context.colors;
    switch (type) {
      case GenaiAlertType.info:
        return (
          bg: c.colorInfoSubtle,
          fg: c.colorInfo,
          border: c.colorInfo,
          icon: LucideIcons.info,
        );
      case GenaiAlertType.success:
        return (
          bg: c.colorSuccessSubtle,
          fg: c.colorSuccess,
          border: c.colorSuccess,
          icon: LucideIcons.circleCheck,
        );
      case GenaiAlertType.warning:
        return (
          bg: c.colorWarningSubtle,
          fg: c.colorWarning,
          border: c.colorWarning,
          icon: LucideIcons.triangleAlert,
        );
      case GenaiAlertType.error:
        return (
          bg: c.colorErrorSubtle,
          fg: c.colorError,
          border: c.colorError,
          icon: LucideIcons.circleAlert,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final radius = context.radius;
    final r = _resolve(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: r.bg,
        borderRadius: BorderRadius.circular(radius.md),
        border: Border(left: BorderSide(color: r.border, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showIcon) ...[
            Icon(r.icon, size: 20, color: r.fg),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(title!, style: ty.label.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600)),
                  ),
                Text(message, style: ty.bodySm.copyWith(color: colors.textPrimary)),
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: actions,
                  ),
                ],
              ],
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            GenaiIconButton(
              icon: LucideIcons.x,
              size: GenaiSize.xs,
              semanticLabel: 'Chiudi avviso',
              onPressed: onDismiss,
            ),
          ],
        ],
      ),
    );
  }
}
