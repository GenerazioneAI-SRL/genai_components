import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

enum CLToastVariant { info, success, warning, error }

/// Toast notification temporanea stile shadcn.
/// Usa [CLToast.show] per mostrare una notifica.
class CLToast {
  CLToast._();

  static void show(
    BuildContext context,
    String message, {
    CLToastVariant variant = CLToastVariant.info,
    String? title,
    Duration duration = const Duration(seconds: 4),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _CLToastWidget(
        message: message,
        title: title,
        variant: variant,
        onDismiss: () => entry.remove(),
        duration: duration,
      ),
    );

    overlay.insert(entry);
  }
}

class _CLToastWidget extends StatefulWidget {
  final String message;
  final String? title;
  final CLToastVariant variant;
  final VoidCallback onDismiss;
  final Duration duration;

  const _CLToastWidget({
    required this.message,
    this.title,
    required this.variant,
    required this.onDismiss,
    required this.duration,
  });

  @override
  State<_CLToastWidget> createState() => _CLToastWidgetState();
}

class _CLToastWidgetState extends State<_CLToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..forward();
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    Future.delayed(widget.duration, _dismiss);
  }

  void _dismiss() {
    if (!mounted) return;
    _ctrl.reverse().then((_) => widget.onDismiss());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _accentColor(CLTheme theme) => switch (widget.variant) {
    CLToastVariant.info => theme.primary,
    CLToastVariant.success => theme.success,
    CLToastVariant.warning => theme.warning,
    CLToastVariant.error => theme.danger,
  };

  IconData get _variantIcon => switch (widget.variant) {
    CLToastVariant.info => LucideIcons.info,
    CLToastVariant.success => LucideIcons.circleCheck,
    CLToastVariant.warning => LucideIcons.triangleAlert,
    CLToastVariant.error => LucideIcons.circleX,
  };

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final accent = _accentColor(theme);
    // Look ShadToast/Sonner: niente accent-stripe. Icona variante colorata
    // (Sonner) + titolo semibold + descrizione muted + close top-right. Bordo
    // danger sulla variante error (destructive Shad), altrimenti cardBorder.
    final borderColor =
        widget.variant == CLToastVariant.error ? theme.danger.withValues(alpha: 0.5) : theme.cardBorder;

    return Positioned(
      bottom: Sizes.gap2Xl,
      right: Sizes.gap2Xl,
      child: FadeTransition(
        opacity: _opacity,
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(minWidth: 280, maxWidth: 400),
            padding: const EdgeInsets.all(Sizes.padding),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(Sizes.radiusSurface),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: Sizes.gapMd, top: 1),
                  child: Icon(_variantIcon, size: Sizes.iconSizeCompact, color: accent),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.title != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: Sizes.gapXs),
                          child: Text(
                            widget.title!,
                            style: theme.title.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      Text(
                        widget.message,
                        style: theme.bodyText.copyWith(color: theme.mutedForeground),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Sizes.gapSm),
                InkWell(
                  onTap: _dismiss,
                  borderRadius: BorderRadius.circular(Sizes.radiusChip),
                  child: Icon(LucideIcons.x, size: Sizes.iconSizeCompact, color: theme.mutedForeground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
