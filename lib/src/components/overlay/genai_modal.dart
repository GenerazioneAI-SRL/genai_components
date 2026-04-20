import 'package:flutter/material.dart';

import '../../foundations/animations.dart';
import '../../foundations/icons.dart';
import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';
import '../actions/genai_button.dart';
import '../actions/genai_icon_button.dart';

enum GenaiModalSize { sm, md, lg, xl, fullscreen }

/// Show a modal dialog (§6.5.1).
///
/// Mobile (compact window size) auto-converts to bottom-sheet style
/// (full width, anchored to bottom).
Future<T?> showGenaiModal<T>(
  BuildContext context, {
  String? title,
  String? description,
  required Widget child,
  List<Widget> actions = const [],
  GenaiModalSize size = GenaiModalSize.md,
  bool dismissible = true,
  bool showClose = true,
}) {
  final isCompact = GenaiResponsive.sizeOf(context) == GenaiWindowSize.compact;
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    barrierLabel: 'Chiudi finestra',
    barrierColor: const Color(0x99000000),
    transitionDuration: GenaiDurations.modalOpen,
    pageBuilder: (ctx, _, __) => _GenaiModalShell(
      title: title,
      description: description,
      size: size,
      isCompact: isCompact,
      showClose: showClose,
      actions: actions,
      child: child,
    ),
    transitionBuilder: (_, anim, __, modal) {
      final curved = CurvedAnimation(parent: anim, curve: GenaiCurves.open);
      if (isCompact) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(curved),
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

/// Confirmation dialog with primary + cancel CTA. Returns true if confirmed.
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
    actions: [
      Builder(
        builder: (ctx) => GenaiButton.ghost(
          label: cancelLabel,
          onPressed: () => Navigator.of(ctx).pop(false),
        ),
      ),
      Builder(builder: (ctx) {
        final btn = isDestructive
            ? GenaiButton.destructive(
                label: confirmLabel,
                onPressed: () => Navigator.of(ctx).pop(true),
              )
            : GenaiButton.primary(
                label: confirmLabel,
                onPressed: () => Navigator.of(ctx).pop(true),
              );
        return btn;
      }),
    ],
    size: GenaiModalSize.sm,
  );
  return result ?? false;
}

/// Strong confirmation requiring the user to type a string (e.g. resource
/// name) before the destructive action is enabled (§6.5.4).
Future<bool> showGenaiStrongConfirm(
  BuildContext context, {
  required String title,
  required String description,
  required String requiredText,
  String confirmLabel = 'Elimina',
  String cancelLabel = 'Annulla',
}) async {
  final controller = TextEditingController();
  final result = await showGenaiModal<bool>(
    context,
    title: title,
    description: description,
    size: GenaiModalSize.sm,
    child: StatefulBuilder(builder: (ctx, setState) {
      final colors = ctx.colors;
      final ty = ctx.typography;
      final matches = controller.text == requiredText;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Digita "$requiredText" per confermare:', style: ty.bodySm.copyWith(color: colors.textSecondary)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colors.borderDefault),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colors.borderDefault),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colors.borderFocus, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GenaiButton.ghost(
                label: cancelLabel,
                onPressed: () => Navigator.of(ctx).pop(false),
              ),
              const SizedBox(width: 8),
              GenaiButton.destructive(
                label: confirmLabel,
                onPressed: matches ? () => Navigator.of(ctx).pop(true) : null,
              ),
            ],
          ),
        ],
      );
    }),
  );
  return result ?? false;
}

class _GenaiModalShell extends StatelessWidget {
  final String? title;
  final String? description;
  final Widget child;
  final List<Widget> actions;
  final GenaiModalSize size;
  final bool isCompact;
  final bool showClose;

  const _GenaiModalShell({
    this.title,
    this.description,
    required this.child,
    required this.actions,
    required this.size,
    required this.isCompact,
    required this.showClose,
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

    final radius = isCompact ? const BorderRadius.vertical(top: Radius.circular(16)) : BorderRadius.circular(12);
    final align = isCompact ? Alignment.bottomCenter : Alignment.center;

    final content = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: isCompact ? double.infinity : _maxWidth(),
        maxHeight: size == GenaiModalSize.fullscreen ? double.infinity : 720,
      ),
      child: Material(
        color: colors.surfaceCard,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null || showClose)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (title != null) Text(title!, style: ty.headingSm.copyWith(color: colors.textPrimary)),
                          if (description != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(description!, style: ty.bodySm.copyWith(color: colors.textSecondary)),
                            ),
                        ],
                      ),
                    ),
                    if (showClose)
                      GenaiIconButton(
                        icon: LucideIcons.x,
                        size: GenaiSize.sm,
                        semanticLabel: 'Chiudi',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                  ],
                ),
              ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: child,
              ),
            ),
            if (actions.isNotEmpty)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: colors.borderDefault)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (var i = 0; i < actions.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      actions[i],
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );

    return SafeArea(
      child: Align(
        alignment: align,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isCompact ? 0 : 24, vertical: isCompact ? 0 : 24),
          child: content,
        ),
      ),
    );
  }
}
