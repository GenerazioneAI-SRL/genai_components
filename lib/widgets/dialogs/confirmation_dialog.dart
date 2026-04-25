import 'package:flutter/material.dart';

import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import '_dialog_chrome.dart';

/// A simple yes/no confirmation dialog.
///
/// Use the static [show] helper to display the dialog and await a `bool`
/// result (`true` if the user confirmed, `false` if cancelled or dismissed).
///
/// When [isDestructive] is `true`, the confirm button is styled with the
/// theme's `danger` color and the optional [icon] sits on a tinted danger
/// halo to signal a potentially irreversible action.
///
/// Note: named [CLConfirmationDialog] (not `ConfirmationDialog`) to avoid
/// a name collision with the legacy `ConfirmationDialog` exported from
/// `widgets/buttons/cl_confirm_dialog.dart`.
class CLConfirmationDialog extends StatelessWidget {
  /// Title shown in the dialog header.
  final String title;

  /// Body message describing the action being confirmed.
  final String message;

  /// Label of the confirm button.
  final String confirmLabel;

  /// Label of the cancel button.
  final String cancelLabel;

  /// Whether the action is destructive (changes confirm button styling).
  final bool isDestructive;

  /// Optional icon shown above the title.
  final IconData? icon;

  /// Creates a [CLConfirmationDialog].
  const CLConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Conferma',
    this.cancelLabel = 'Annulla',
    this.isDestructive = false,
    this.icon,
  });

  /// Shows a [CLConfirmationDialog] and returns whether the user confirmed.
  ///
  /// Resolves to `false` if the dialog is dismissed without an explicit
  /// confirmation (e.g. tapping outside or pressing back).
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Conferma',
    String cancelLabel = 'Annulla',
    bool isDestructive = false,
    IconData? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => CLConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        icon: icon,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final cl = CLTheme.of(context);
    final tone = isDestructive ? cl.danger : cl.primary;
    final headerIcon = icon ??
        (isDestructive ? Icons.warning_amber_rounded : Icons.help_outline_rounded);

    return DialogShell(
      maxWidth: 440,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              CLSizes.gap2Xl,
              CLSizes.gap2Xl,
              CLSizes.gap2Xl,
              CLSizes.gapLg,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconBadge(icon: headerIcon, color: tone, size: 48, iconSize: 24),
                const SizedBox(width: CLSizes.gapLg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: cl.heading4.copyWith(
                          color: cl.primaryText,
                          fontSize: 18,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: CLSizes.gapSm),
                      Text(
                        message,
                        style: cl.bodyText.copyWith(
                          color: cl.secondaryText,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          DialogFooter(
            actions: [
              CLDialogButton(
                label: cancelLabel,
                tone: CLDialogButtonTone.ghost,
                onPressed: () => Navigator.of(context).pop(false),
              ),
              CLDialogButton(
                label: confirmLabel,
                tone: isDestructive
                    ? CLDialogButtonTone.danger
                    : CLDialogButtonTone.primary,
                icon: isDestructive ? Icons.delete_outline_rounded : null,
                autofocus: true,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
