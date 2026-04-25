import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';

/// Shows a shadcn-style alert dialog — v3 design system.
///
/// Differences vs. [showGenaiModal]:
/// - Barrier taps do **not** dismiss (shadcn `AlertDialog` convention).
/// - `Esc` dismisses and resolves with `false`.
/// - Initial focus is trapped on the confirm button.
/// - Semantics mark the container as `liveRegion` + `scopesRoute` so it
///   announces like `role="alertdialog"`.
///
/// Resolves to `true` on confirm, `false` on cancel / Esc, or `null` only if
/// the route is popped programmatically.
Future<bool?> showGenaiAlertDialog(
  BuildContext context, {
  required String title,
  required String description,
  String cancelLabel = 'Annulla',
  String confirmLabel = 'Conferma',
  bool isDestructive = false,
  Widget? icon,
  String? dismissSemanticLabel,
  String? barrierSemanticLabel,
}) {
  final reduced = GenaiResponsive.reducedMotion(context);
  final motion = context.motion.modal;
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierLabel:
        barrierSemanticLabel ?? dismissSemanticLabel ?? 'Finestra di avviso',
    barrierColor: context.colors.scrimModal,
    transitionDuration: reduced ? Duration.zero : motion.duration,
    pageBuilder: (ctx, _, __) => _GenaiAlertDialogShell(
      title: title,
      description: description,
      cancelLabel: cancelLabel,
      confirmLabel: confirmLabel,
      isDestructive: isDestructive,
      icon: icon,
    ),
    transitionBuilder: (_, anim, __, dialog) {
      if (reduced) return dialog;
      final curved = CurvedAnimation(parent: anim, curve: motion.curve);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: dialog,
        ),
      );
    },
  );
}

class _GenaiAlertDialogShell extends StatefulWidget {
  final String title;
  final String description;
  final String cancelLabel;
  final String confirmLabel;
  final bool isDestructive;
  final Widget? icon;

  const _GenaiAlertDialogShell({
    required this.title,
    required this.description,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.isDestructive,
    required this.icon,
  });

  @override
  State<_GenaiAlertDialogShell> createState() => _GenaiAlertDialogShellState();
}

class _GenaiAlertDialogShellState extends State<_GenaiAlertDialogShell> {
  final FocusNode _confirmFocus =
      FocusNode(debugLabel: 'GenaiAlertDialog.confirm');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _confirmFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _confirmFocus.dispose();
    super.dispose();
  }

  void _cancel() => Navigator.of(context).pop(false);
  void _confirm() => Navigator.of(context).pop(true);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    final iconColor =
        widget.isDestructive ? colors.colorDanger : colors.colorWarning;

    final dialog = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Material(
        color: colors.surfaceModal,
        borderRadius: BorderRadius.circular(radius.xl),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius.xl),
            border: Border.all(color: colors.borderDefault),
            boxShadow: context.elevation.shadowForLayer(3),
          ),
          padding: EdgeInsets.fromLTRB(
            spacing.s20,
            spacing.s20,
            spacing.s20,
            spacing.s18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.icon != null) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconTheme(
                    data: IconThemeData(
                      color: iconColor,
                      size: context.sizing.iconEmptyState / 2,
                    ),
                    child: widget.icon!,
                  ),
                ),
                SizedBox(height: spacing.s12),
              ],
              Semantics(
                header: true,
                child: Text(
                  widget.title,
                  style: ty.sectionTitle.copyWith(color: colors.textPrimary),
                ),
              ),
              SizedBox(height: spacing.s8),
              Text(
                widget.description,
                style: ty.bodySm.copyWith(color: colors.textSecondary),
              ),
              SizedBox(height: spacing.s20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _DialogButton(
                    label: widget.cancelLabel,
                    onPressed: _cancel,
                    isPrimary: false,
                    isDestructive: false,
                  ),
                  SizedBox(width: spacing.s8),
                  Focus(
                    focusNode: _confirmFocus,
                    child: _DialogButton(
                      label: widget.confirmLabel,
                      onPressed: _confirm,
                      isPrimary: !widget.isDestructive,
                      isDestructive: widget.isDestructive,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return Semantics(
      container: true,
      scopesRoute: true,
      namesRoute: true,
      liveRegion: true,
      explicitChildNodes: true,
      label: widget.title,
      value: widget.description,
      child: Shortcuts(
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            DismissIntent: CallbackAction<DismissIntent>(
              onInvoke: (_) {
                _cancel();
                return null;
              },
            ),
          },
          child: FocusScope(
            autofocus: true,
            child: SafeArea(
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.s24,
                    vertical: spacing.s24,
                  ),
                  child: dialog,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Locally-scoped button so the alert dialog has no button dependency.
class _DialogButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isDestructive;

  const _DialogButton({
    required this.label,
    required this.onPressed,
    required this.isPrimary,
    required this.isDestructive,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;
    final sizing = context.sizing;

    Color bg;
    Color fg;
    Color border;
    if (isDestructive) {
      bg = colors.colorDanger;
      fg = colors.textOnPrimary;
      border = colors.colorDanger;
    } else if (isPrimary) {
      bg = colors.colorPrimary;
      fg = colors.textOnPrimary;
      border = colors.colorPrimary;
    } else {
      bg = colors.surfaceCard;
      fg = colors.textPrimary;
      border = colors.borderStrong;
    }

    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(radius.md),
        child: Container(
          constraints: BoxConstraints(minHeight: sizing.minTouchTarget),
          padding: EdgeInsets.symmetric(
            horizontal: spacing.s16,
            vertical: spacing.s8,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(radius.md),
            border: Border.all(color: border),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: ty.label.copyWith(color: fg),
          ),
        ),
      ),
    );
  }
}

// AlertDialog renders over the modal backdrop / content layers (§z-index).
// ignore: unused_element
const int _alertDialogZ = GenaiZIndex.modalContent;
