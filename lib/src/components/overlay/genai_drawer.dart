import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/icons.dart';
import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';

/// Side a [showGenaiDrawer] slides in from on desktop.
enum GenaiDrawerSide {
  /// Slide in from the left edge.
  left,

  /// Slide in from the right edge (default).
  right,
}

/// Shows a side drawer — v3 design system.
///
/// Panel bg, hairline border, `radius.xl` on the sliding edge, layer 3 shadow.
/// Compact windows collapse to a bottom-sheet slide-up. `Esc` dismisses;
/// barrier uses `context.colors.scrimDrawer`.
Future<T?> showGenaiDrawer<T>(
  BuildContext context, {
  required Widget child,
  String? title,
  GenaiDrawerSide side = GenaiDrawerSide.right,
  double width = 400,
  bool dismissible = true,
  String dismissSemanticLabel = 'Chiudi pannello',
}) {
  final isCompact = GenaiResponsive.sizeOf(context) == GenaiWindowSize.compact;
  final reduced = GenaiResponsive.reducedMotion(context);
  final motion = context.motion.modal;
  final scrim = context.colors.scrimDrawer;

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    barrierLabel: dismissSemanticLabel,
    barrierColor: scrim,
    transitionDuration: reduced ? Duration.zero : motion.duration,
    pageBuilder: (ctx, _, __) => _GenaiDrawerShell(
      title: title,
      side: side,
      width: width,
      isCompact: isCompact,
      dismissSemanticLabel: dismissSemanticLabel,
      child: child,
    ),
    transitionBuilder: (_, anim, __, page) {
      if (reduced) return page;
      final curved = CurvedAnimation(parent: anim, curve: motion.curve);
      if (isCompact) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(curved),
          child: page,
        );
      }
      final begin = side == GenaiDrawerSide.right
          ? const Offset(1, 0)
          : const Offset(-1, 0);
      return SlideTransition(
        position: Tween<Offset>(begin: begin, end: Offset.zero).animate(curved),
        child: page,
      );
    },
  );
}

/// Shows a bottom sheet — v3 design system.
///
/// Thin wrapper around [showModalBottomSheet] styled to v3 tokens with an
/// optional title header and drag handle.
Future<T?> showGenaiBottomSheet<T>(
  BuildContext context, {
  required Widget child,
  String? title,
  bool dismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: context.colors.scrimDrawer,
    isDismissible: dismissible,
    builder: (ctx) {
      final colors = ctx.colors;
      final ty = ctx.typography;
      final spacing = ctx.spacing;
      final radius = ctx.radius;
      return SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: colors.surfaceModal,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(radius.xl),
            ),
            border: Border.all(color: colors.borderDefault),
          ),
          padding: EdgeInsets.fromLTRB(
            spacing.s20,
            spacing.s12,
            spacing.s20,
            spacing.s24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: spacing.s40,
                  height: spacing.s4,
                  margin: EdgeInsets.only(bottom: spacing.s12),
                  decoration: BoxDecoration(
                    color: colors.borderDefault,
                    borderRadius: BorderRadius.circular(radius.xs),
                  ),
                ),
              ),
              if (title != null)
                Padding(
                  padding: EdgeInsets.only(bottom: spacing.s12),
                  child: Semantics(
                    header: true,
                    child: Text(
                      title,
                      style:
                          ty.sectionTitle.copyWith(color: colors.textPrimary),
                    ),
                  ),
                ),
              Flexible(
                child: SingleChildScrollView(child: child),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _GenaiDrawerShell extends StatelessWidget {
  final String? title;
  final GenaiDrawerSide side;
  final double width;
  final bool isCompact;
  final String dismissSemanticLabel;
  final Widget child;

  const _GenaiDrawerShell({
    this.title,
    required this.side,
    required this.width,
    required this.isCompact,
    required this.dismissSemanticLabel,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radiusTokens = context.radius;
    final sizing = context.sizing;

    final borderRadius = isCompact
        ? BorderRadius.vertical(top: Radius.circular(radiusTokens.xl))
        : (side == GenaiDrawerSide.right
            ? BorderRadius.horizontal(left: Radius.circular(radiusTokens.xl))
            : BorderRadius.horizontal(right: Radius.circular(radiusTokens.xl)));

    final panel = Container(
      width: isCompact ? double.infinity : width,
      height: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceModal,
        borderRadius: borderRadius,
        border: Border.all(color: colors.borderDefault),
        boxShadow: context.elevation.shadowForLayer(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Container(
              padding: EdgeInsets.fromLTRB(
                spacing.s20,
                spacing.s18,
                spacing.s12,
                spacing.s18,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colors.borderDefault,
                    width: sizing.dividerThickness,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        title!,
                        style:
                            ty.sectionTitle.copyWith(color: colors.textPrimary),
                      ),
                    ),
                  ),
                  _DrawerCloseButton(
                    semanticLabel: dismissSemanticLabel,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(spacing.s20),
              child: child,
            ),
          ),
        ],
      ),
    );

    return Semantics(
      container: true,
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: title,
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
                alignment: isCompact
                    ? Alignment.bottomCenter
                    : (side == GenaiDrawerSide.right
                        ? Alignment.centerRight
                        : Alignment.centerLeft),
                child: Material(color: Colors.transparent, child: panel),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerCloseButton extends StatelessWidget {
  final String semanticLabel;
  final VoidCallback onTap;
  const _DrawerCloseButton({
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

// Drawers live on the drawer z-index layer.
// ignore: unused_element
const int _drawerZ = GenaiZIndex.drawer;
