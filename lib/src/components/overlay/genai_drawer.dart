import 'package:flutter/material.dart';

import '../../foundations/animations.dart';
import '../../foundations/icons.dart';
import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';
import '../actions/genai_icon_button.dart';

enum GenaiDrawerSide { left, right }

/// Side drawer (§6.5.5). Mobile transitions like a bottom-sheet.
Future<T?> showGenaiDrawer<T>(
  BuildContext context, {
  required Widget child,
  String? title,
  GenaiDrawerSide side = GenaiDrawerSide.right,
  double width = 400,
  bool dismissible = true,
}) {
  final isCompact = GenaiResponsive.sizeOf(context) == GenaiWindowSize.compact;
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    barrierLabel: 'Chiudi pannello',
    barrierColor: const Color(0x66000000),
    transitionDuration: isCompact ? GenaiDurations.drawerMobile : GenaiDurations.drawerDesktop,
    pageBuilder: (ctx, _, __) => _GenaiDrawerShell(
      title: title,
      side: side,
      width: width,
      isCompact: isCompact,
      child: child,
    ),
    transitionBuilder: (_, anim, __, page) {
      final curved = CurvedAnimation(parent: anim, curve: GenaiCurves.open);
      if (isCompact) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(curved),
          child: page,
        );
      }
      final begin = side == GenaiDrawerSide.right ? const Offset(1, 0) : const Offset(-1, 0);
      return SlideTransition(
        position: Tween<Offset>(begin: begin, end: Offset.zero).animate(curved),
        child: page,
      );
    },
  );
}

/// Bottom sheet (§6.5.6).
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
    barrierColor: const Color(0x99000000),
    isDismissible: dismissible,
    builder: (ctx) {
      final colors = ctx.colors;
      final ty = ctx.typography;
      return SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: colors.surfaceCard,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: colors.borderDefault,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (title != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(title, style: ty.headingSm.copyWith(color: colors.textPrimary)),
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
  final Widget child;

  const _GenaiDrawerShell({
    this.title,
    required this.side,
    required this.width,
    required this.isCompact,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;

    final radius = isCompact
        ? const BorderRadius.vertical(top: Radius.circular(16))
        : (side == GenaiDrawerSide.right
            ? const BorderRadius.horizontal(left: Radius.circular(12))
            : const BorderRadius.horizontal(right: Radius.circular(12)));

    final panel = Container(
      width: isCompact ? double.infinity : width,
      height: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: radius,
        boxShadow: context.elevation.shadow(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: colors.borderDefault)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(title!, style: ty.headingSm.copyWith(color: colors.textPrimary)),
                  ),
                  GenaiIconButton(
                    icon: LucideIcons.x,
                    size: GenaiSize.sm,
                    semanticLabel: 'Chiudi pannello',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: child,
            ),
          ),
        ],
      ),
    );

    return SafeArea(
      child: Align(
        alignment: isCompact ? Alignment.bottomCenter : (side == GenaiDrawerSide.right ? Alignment.centerRight : Alignment.centerLeft),
        child: Material(color: Colors.transparent, child: panel),
      ),
    );
  }
}
