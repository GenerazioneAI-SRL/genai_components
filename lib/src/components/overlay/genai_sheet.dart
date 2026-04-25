import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/icons.dart';
import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';
import 'genai_drawer.dart';

/// Edge that a [showGenaiSheet] slides in from — v3 design system (Forma LMS).
///
/// shadcn-style alias of `GenaiDrawerSide` extended to the four cardinal
/// directions. `top`/`bottom` slide along the vertical axis; `left`/`right`
/// along the horizontal axis.
enum GenaiSheetSide {
  /// Slide down from the top edge.
  top,

  /// Slide in from the right edge (default — desktop side panels).
  right,

  /// Slide up from the bottom edge.
  bottom,

  /// Slide in from the left edge.
  left,
}

/// Shows a side or edge sheet — the shadcn equivalent of `Sheet` (v3).
///
/// For `left` and `right` sides, this delegates to [showGenaiDrawer]. For
/// `bottom` it delegates to [showGenaiBottomSheet]. For `top` it renders a
/// custom slide-down panel since top sheets are not supported by the drawer
/// helper. Reduced motion is honoured automatically via v3's motion tokens.
///
/// Returns the popped value of type `T` when the sheet closes.
Future<T?> showGenaiSheet<T>(
  BuildContext context, {
  required Widget child,
  GenaiSheetSide side = GenaiSheetSide.right,
  double width = 400,
  double height = 360,
  String? title,
  bool dismissible = true,
  String dismissSemanticLabel = 'Chiudi pannello',
}) {
  switch (side) {
    case GenaiSheetSide.left:
      return showGenaiDrawer<T>(
        context,
        child: child,
        title: title,
        side: GenaiDrawerSide.left,
        width: width,
        dismissible: dismissible,
        dismissSemanticLabel: dismissSemanticLabel,
      );
    case GenaiSheetSide.right:
      return showGenaiDrawer<T>(
        context,
        child: child,
        title: title,
        side: GenaiDrawerSide.right,
        width: width,
        dismissible: dismissible,
        dismissSemanticLabel: dismissSemanticLabel,
      );
    case GenaiSheetSide.bottom:
      return showGenaiBottomSheet<T>(
        context,
        child: child,
        title: title,
        dismissible: dismissible,
      );
    case GenaiSheetSide.top:
      return _showGenaiTopSheet<T>(
        context,
        child: child,
        title: title,
        height: height,
        dismissible: dismissible,
        dismissSemanticLabel: dismissSemanticLabel,
      );
  }
}

Future<T?> _showGenaiTopSheet<T>(
  BuildContext context, {
  required Widget child,
  required double height,
  String? title,
  bool dismissible = true,
  String dismissSemanticLabel = 'Chiudi pannello',
}) {
  final reduced = GenaiResponsive.reducedMotion(context);
  final motion = context.motion.modal;
  final scrim = context.colors.scrimDrawer;

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    barrierLabel: dismissSemanticLabel,
    barrierColor: scrim,
    transitionDuration: reduced ? Duration.zero : motion.duration,
    pageBuilder: (ctx, _, __) => _GenaiTopSheetShell(
      title: title,
      height: height,
      dismissSemanticLabel: dismissSemanticLabel,
      child: child,
    ),
    transitionBuilder: (_, anim, __, page) {
      if (reduced) return page;
      final curved = CurvedAnimation(parent: anim, curve: motion.curve);
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
            .animate(curved),
        child: page,
      );
    },
  );
}

class _GenaiTopSheetShell extends StatelessWidget {
  final String? title;
  final double height;
  final String dismissSemanticLabel;
  final Widget child;

  const _GenaiTopSheetShell({
    this.title,
    required this.height,
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

    final panel = Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: colors.surfaceModal,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(radiusTokens.xl),
        ),
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
                spacing.s16,
                spacing.s12,
                spacing.s16,
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
                  _SheetCloseButton(
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
              bottom: false,
              child: Align(
                alignment: Alignment.topCenter,
                child: Material(color: Colors.transparent, child: panel),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetCloseButton extends StatelessWidget {
  final String semanticLabel;
  final VoidCallback onTap;
  const _SheetCloseButton({
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
        borderRadius: BorderRadius.circular(radius.sm),
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
