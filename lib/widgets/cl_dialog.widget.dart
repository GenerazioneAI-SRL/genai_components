import 'dart:async';

import 'package:flutter/material.dart';
// Budella Shad: nucleo interno = ShadDialog (surface/constraints/scrollable/
// layout title-body-actions nativi). Solo il simbolo usato (show). Firma
// pubblica CLDialog (campi, show(), buildContent) invariata.
import 'package:shadcn_ui/shadcn_ui.dart' show ShadDialog;

import '../cl_theme.dart';
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

  /// Optional leading widget in the header (icon badge, avatar).
  final Widget? headerLeading;

  /// Whether to show the close (×) button in the header. Default `true`.
  final bool showCloseButton;

  /// Max dialog width. Default `480`.
  final double maxWidth;

  /// Larghezza massima come frazione della larghezza schermo (es. `0.6` = 60%).
  /// Ha precedenza su [maxWidth]. Per dialog "larghi" (es. tabelle embedded).
  final double? maxWidthFraction;

  /// When `true` (default) the body is wrapped in a scroll view. Set `false`
  /// when the content manages its own scrolling (e.g. an inner list/table).
  final bool scrollableBody;

  /// Creates a [CLDialog].
  const CLDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.onCancel,
    this.onConfirm,
    this.confirmLabel = 'Conferma',
    this.cancelLabel = 'Annulla',
    this.headerLeading,
    this.showCloseButton = true,
    this.maxWidth = 480,
    this.maxWidthFraction,
    this.scrollableBody = true,
  });

  /// Builds the body of the dialog. Subclasses must override.
  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    final cl = CLTheme.of(context);
    final double resolvedMaxWidth = maxWidthFraction != null
        ? MediaQuery.sizeOf(context).width * maxWidthFraction!
        : maxWidth;

    // Header CL: leading badge opzionale + titolo (heading4 18 w600).
    final Widget titleWidget = headerLeading == null
        ? Text(
            title,
            style: cl.heading4.copyWith(
              color: cl.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              headerLeading!,
              SizedBox(width: cl.gapLg),
              Expanded(
                child: Text(
                  title,
                  style: cl.heading4.copyWith(
                    color: cl.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          );

    // Nucleo = ShadDialog: surface (radius/bordo/ombra/bg da token CL),
    // constraints maxWidth, scrollable e layout title→body→actions nativi.
    // Close = DialogCloseButton CL (preserva onCancel). Bottoni = CLDialogButton.
    return ShadDialog(
      constraints: BoxConstraints(maxWidth: resolvedMaxWidth),
      backgroundColor: cl.secondaryBackground,
      radius: BorderRadius.circular(cl.radiusModal),
      border: Border.all(color: cl.cardBorder, width: 1),
      shadows: cl.popoverShadow,
      padding: EdgeInsets.all(cl.gap2Xl),
      gap: cl.gapLg,
      scrollable: scrollableBody,
      closeIcon: showCloseButton
          ? DialogCloseButton(
              onPressed: () {
                onCancel?.call();
                Navigator.of(context).pop();
              },
            )
          : const SizedBox.shrink(),
      title: titleWidget,
      description: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: cl.smallLabel.copyWith(color: cl.secondaryText, height: 1.5),
            ),
      actionsMainAxisAlignment: MainAxisAlignment.end,
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
      child: DefaultTextStyle.merge(
        style: cl.bodyText.copyWith(color: cl.primaryText),
        child: buildContent(context),
      ),
    );
  }

  /// Apre un CLDialog **inline**, senza sottoclasse. Ritorna il risultato di
  /// [onConfirm] (o `null` se annullato/chiuso).
  ///
  /// ```dart
  /// final ok = await CLDialog.show<bool>(
  ///   context,
  ///   title: 'Gestisci contatti',
  ///   headerLeading: IconBadge(icon: Icons.contacts, color: theme.primary),
  ///   maxWidth: 520,
  ///   content: (ctx) => _contactsForm,
  ///   confirmLabel: 'Salva',
  ///   onConfirm: () => vm.save(),
  /// );
  /// ```
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required WidgetBuilder content,
    String? subtitle,
    Widget? headerLeading,
    bool showCloseButton = true,
    double maxWidth = 480,
    bool scrollableBody = true,
    FutureOr<T?> Function()? onConfirm,
    VoidCallback? onCancel,
    String confirmLabel = 'Conferma',
    String cancelLabel = 'Annulla',
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => _CLBuilderDialog<T>(
        title: title,
        subtitle: subtitle,
        headerLeading: headerLeading,
        showCloseButton: showCloseButton,
        maxWidth: maxWidth,
        scrollableBody: scrollableBody,
        onConfirm: onConfirm,
        onCancel: onCancel,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        contentBuilder: content,
      ),
    );
  }
}

/// Sottoclasse concreta di [CLDialog] per l'uso inline via [CLDialog.show].
/// Rende [contentBuilder] come corpo — nessuna sottoclasse lato consumer.
class _CLBuilderDialog<T> extends CLDialog<T> {
  const _CLBuilderDialog({
    required super.title,
    super.subtitle,
    super.onCancel,
    super.onConfirm,
    super.confirmLabel = 'Conferma',
    super.cancelLabel = 'Annulla',
    super.headerLeading,
    super.showCloseButton = true,
    super.maxWidth = 480,
    super.scrollableBody = true,
    required this.contentBuilder,
  });

  final WidgetBuilder contentBuilder;

  @override
  Widget buildContent(BuildContext context) => contentBuilder(context);
}
