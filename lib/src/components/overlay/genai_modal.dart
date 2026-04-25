import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/icons.dart';
import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';

/// Preset widths for [showGenaiModal]. `fullscreen` covers the whole viewport.
enum GenaiModalSize {
  /// Small — ~400 px.
  sm,

  /// Medium — ~560 px (default).
  md,

  /// Large — ~760 px.
  lg,

  /// Extra large — ~1024 px.
  xl,

  /// Full viewport.
  fullscreen,
}

/// Shows a modal dialog — v3 design system.
///
/// Panel bg, hairline border, `radius.xl` corners (14 on focus hero), layer 3
/// shadow. Compact window sizes convert to a bottom-sheet-style slide-up.
/// `Esc` closes, scrim uses `context.colors.scrimModal`.
Future<T?> showGenaiModal<T>(
  BuildContext context, {
  String? title,
  String? description,
  required Widget child,
  List<Widget> actions = const [],
  GenaiModalSize size = GenaiModalSize.md,
  bool dismissible = true,
  bool showClose = true,
  String dismissSemanticLabel = 'Chiudi',
  String barrierSemanticLabel = 'Chiudi finestra',
}) {
  final isCompact = GenaiResponsive.sizeOf(context) == GenaiWindowSize.compact;
  final reduced = GenaiResponsive.reducedMotion(context);
  final motion = context.motion.modal;
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    barrierLabel: barrierSemanticLabel,
    barrierColor: context.colors.scrimModal,
    transitionDuration: reduced ? Duration.zero : motion.duration,
    pageBuilder: (ctx, _, __) => _GenaiModalShell(
      title: title,
      description: description,
      size: size,
      isCompact: isCompact,
      showClose: showClose,
      actions: actions,
      dismissSemanticLabel: dismissSemanticLabel,
      child: child,
    ),
    transitionBuilder: (_, anim, __, modal) {
      if (reduced) return modal;
      final curved = CurvedAnimation(parent: anim, curve: motion.curve);
      if (isCompact) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(curved),
          child: modal,
        );
      }
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: modal,
        ),
      );
    },
  );
}

/// Shows a confirmation dialog with primary + cancel CTA.
///
/// Resolves to `true` when confirmed, `false` otherwise.
Future<bool> showGenaiConfirm(
  BuildContext context, {
  required String title,
  String? description,
  String confirmLabel = 'Conferma',
  String cancelLabel = 'Annulla',
  bool isDestructive = false,
}) async {
  final result = await showGenaiModal<bool>(
    context,
    title: title,
    description: description,
    child: const SizedBox.shrink(),
    size: GenaiModalSize.sm,
    actions: [
      _ConfirmButton(
        label: cancelLabel,
        isPrimary: false,
        isDestructive: false,
        onTap: (ctx) => Navigator.of(ctx).pop(false),
      ),
      _ConfirmButton(
        label: confirmLabel,
        isPrimary: !isDestructive,
        isDestructive: isDestructive,
        onTap: (ctx) => Navigator.of(ctx).pop(true),
      ),
    ],
  );
  return result ?? false;
}

class _ConfirmButton extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final bool isDestructive;
  final void Function(BuildContext ctx) onTap;

  const _ConfirmButton({
    required this.label,
    required this.isPrimary,
    required this.isDestructive,
    required this.onTap,
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
        onTap: () => onTap(context),
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
          child: Text(label, style: ty.label.copyWith(color: fg)),
        ),
      ),
    );
  }
}

class _GenaiModalShell extends StatelessWidget {
  final String? title;
  final String? description;
  final Widget child;
  final List<Widget> actions;
  final GenaiModalSize size;
  final bool isCompact;
  final bool showClose;
  final String dismissSemanticLabel;

  const _GenaiModalShell({
    this.title,
    this.description,
    required this.child,
    required this.actions,
    required this.size,
    required this.isCompact,
    required this.showClose,
    required this.dismissSemanticLabel,
  });

  double _maxWidth() {
    switch (size) {
      case GenaiModalSize.sm:
        return 400;
      case GenaiModalSize.md:
        return 560;
      case GenaiModalSize.lg:
        return 760;
      case GenaiModalSize.xl:
        return 1024;
      case GenaiModalSize.fullscreen:
        return double.infinity;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radiusTokens = context.radius;
    final sizing = context.sizing;

    final borderRadius = isCompact
        ? BorderRadius.vertical(top: Radius.circular(radiusTokens.xl))
        : BorderRadius.circular(radiusTokens.xl);
    final align = isCompact ? Alignment.bottomCenter : Alignment.center;

    final content = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: isCompact ? double.infinity : _maxWidth(),
        maxHeight: size == GenaiModalSize.fullscreen ? double.infinity : 720,
      ),
      child: Material(
        color: colors.surfaceModal,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(color: colors.borderDefault),
            boxShadow: context.elevation.shadowForLayer(3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null || showClose)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    spacing.s20,
                    spacing.s18,
                    spacing.s12,
                    0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (title != null)
                              Semantics(
                                header: true,
                                child: Text(
                                  title!,
                                  style: ty.sectionTitle.copyWith(
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),
                            if (description != null)
                              Padding(
                                padding: EdgeInsets.only(top: spacing.s4),
                                child: Text(
                                  description!,
                                  style: ty.bodySm.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (showClose)
                        _CloseIconButton(
                          semanticLabel: dismissSemanticLabel,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                    ],
                  ),
                ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    spacing.s20,
                    spacing.s16,
                    spacing.s20,
                    spacing.s16,
                  ),
                  child: child,
                ),
              ),
              if (actions.isNotEmpty)
                Container(
                  padding: EdgeInsets.fromLTRB(
                    spacing.s20,
                    spacing.s12,
                    spacing.s20,
                    spacing.s18,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: colors.borderDefault,
                        width: sizing.dividerThickness,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      for (var i = 0; i < actions.length; i++) ...[
                        if (i > 0) SizedBox(width: spacing.s8),
                        actions[i],
                      ],
                    ],
                  ),
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
      explicitChildNodes: true,
      label: title,
      value: description,
      child: Shortcuts(
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            DismissIntent: CallbackAction<DismissIntent>(
              onInvoke: (_) {
                Navigator.of(context).maybePop();
                return null;
              },
            ),
          },
          child: FocusScope(
            autofocus: true,
            child: SafeArea(
              child: Align(
                alignment: align,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 0 : spacing.s24,
                    vertical: isCompact ? 0 : spacing.s24,
                  ),
                  child: content,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseIconButton extends StatelessWidget {
  final String semanticLabel;
  final VoidCallback onTap;
  const _CloseIconButton({
    required this.semanticLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sizing = context.sizing;
    final radius = context.radius;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius.md),
        child: Container(
          width: sizing.minTouchTarget,
          height: sizing.minTouchTarget,
          alignment: Alignment.center,
          child: Icon(
            LucideIcons.x,
            size: sizing.iconSize,
            color: colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// Modal backdrop + content live on dedicated z-index layers.
// ignore: unused_element
const int _modalBackdropZ = GenaiZIndex.modalBackdrop;
// ignore: unused_element
const int _modalContentZ = GenaiZIndex.modalContent;
