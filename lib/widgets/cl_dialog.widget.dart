import 'dart:async';

import 'package:flutter/material.dart';

import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';
import 'dialogs/_dialog_chrome.dart';

/// Base class for CL dialogs with title, optional subtitle, and confirm/cancel actions.
///
/// Subclasses implement [buildContent] to provide the dialog body. The
/// [onConfirm] callback may be synchronous or asynchronous and its return
/// value is used as the result passed to `Navigator.pop`.
///
/// Example:
/// ```dart
/// class MyDialog extends CLDialog<String> {
///   const MyDialog({super.key}) : super(title: 'Esempio');
///
///   @override
///   Widget buildContent(BuildContext context) => const Text('Body');
/// }
/// ```
abstract class CLDialog<T> extends StatelessWidget {
  /// Title shown in the dialog header.
  final String title;

  /// Optional subtitle rendered below the title and above [buildContent].
  final String? subtitle;

  /// Invoked when the user taps the cancel action, before the dialog pops.
  final VoidCallback? onCancel;

  /// Invoked when the user taps the confirm action. Its result is returned
  /// to the caller of [showDialog]. If `null`, the confirm button is hidden.
  final FutureOr<T?> Function()? onConfirm;

  /// Label of the confirm button.
  final String confirmLabel;

  /// Label of the cancel button.
  final String cancelLabel;

  /// Creates a [CLDialog].
  const CLDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.onCancel,
    this.onConfirm,
    this.confirmLabel = 'Conferma',
    this.cancelLabel = 'Annulla',
  });

  /// Builds the body of the dialog. Subclasses must override.
  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    final cl = CLTheme.of(context);
    return DialogShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DialogHeader(
            title: title,
            subtitle: subtitle,
            trailing: DialogCloseButton(
              onPressed: () {
                onCancel?.call();
                Navigator.of(context).pop();
              },
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                CLSizes.gap2Xl,
                0,
                CLSizes.gap2Xl,
                CLSizes.gap2Xl,
              ),
              child: DefaultTextStyle.merge(
                style: cl.bodyText.copyWith(color: cl.primaryText),
                child: buildContent(context),
              ),
            ),
          ),
          DialogFooter(
            actions: [
              CLDialogButton(
                label: cancelLabel,
                tone: CLDialogButtonTone.ghost,
                onPressed: () {
                  onCancel?.call();
                  Navigator.of(context).pop();
                },
              ),
              if (onConfirm != null)
                CLDialogButton(
                  label: confirmLabel,
                  tone: CLDialogButtonTone.primary,
                  autofocus: true,
                  onPressed: () async {
                    final result = await onConfirm!.call();
                    if (context.mounted) Navigator.of(context).pop(result);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
