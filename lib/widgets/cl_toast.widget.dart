import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final accent = _accentColor(theme);

    return Positioned(
      bottom: 24,
      right: 24,
      child: FadeTransition(
        opacity: _opacity,
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(minWidth: 280, maxWidth: 400),
            padding: const EdgeInsets.all(Sizes.padding),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(Sizes.borderRadius),
              border: Border.all(color: theme.cardBorder),
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
                Container(
                  width: 3,
                  height: widget.title != null ? 44 : 20,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.title != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(widget.title!, style: theme.title),
                        ),
                      Text(widget.message, style: theme.bodyText),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _dismiss,
                  borderRadius: BorderRadius.circular(4),
                  child: Icon(Icons.close, size: 16, color: theme.mutedForeground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
