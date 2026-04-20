import 'package:flutter/material.dart';

import '../../foundations/animations.dart';
import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';
import '../actions/genai_icon_button.dart';

enum GenaiToastType { info, success, warning, error }

enum GenaiToastPosition { topRight, topCenter, bottomRight, bottomCenter }

/// Show a transient toast notification (§6.4.2).
///
/// Returns immediately; the toast manages its own lifecycle.
void showGenaiToast(
  BuildContext context, {
  required String message,
  String? title,
  GenaiToastType type = GenaiToastType.info,
  GenaiToastPosition position = GenaiToastPosition.bottomRight,
  Duration? duration,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  final entry = OverlayEntry(builder: (ctx) {
    return _ToastHost(
      message: message,
      title: title,
      type: type,
      position: position,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  });
  overlay.insert(entry);
  Future.delayed(_resolveDuration(duration, type, onAction != null), () {
    if (entry.mounted) entry.remove();
  });
}

Duration _resolveDuration(Duration? d, GenaiToastType type, bool hasAction) {
  if (d != null) return d;
  if (hasAction) return GenaiDurations.toastWithAction;
  switch (type) {
    case GenaiToastType.success:
      return GenaiDurations.toastSuccess;
    case GenaiToastType.info:
      return GenaiDurations.toastInfo;
    case GenaiToastType.warning:
      return GenaiDurations.toastWarning;
    case GenaiToastType.error:
      return GenaiDurations.toastWarning;
  }
}

class _ToastHost extends StatefulWidget {
  final String message;
  final String? title;
  final GenaiToastType type;
  final GenaiToastPosition position;
  final Duration? duration;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _ToastHost({
    required this.message,
    this.title,
    required this.type,
    required this.position,
    this.duration,
    this.actionLabel,
    this.onAction,
  });

  @override
  State<_ToastHost> createState() => _ToastHostState();
}

class _ToastHostState extends State<_ToastHost> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: GenaiDurations.toastIn,
      reverseDuration: GenaiDurations.toastOut,
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: _initialOffset(widget.position),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  Offset _initialOffset(GenaiToastPosition pos) {
    switch (pos) {
      case GenaiToastPosition.topRight:
      case GenaiToastPosition.topCenter:
        return const Offset(0, -0.5);
      case GenaiToastPosition.bottomRight:
      case GenaiToastPosition.bottomCenter:
        return const Offset(0, 0.5);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final isDark = context.isDark;

    final iconColor = switch (widget.type) {
      GenaiToastType.success => colors.colorSuccess,
      GenaiToastType.warning => colors.colorWarning,
      GenaiToastType.error => colors.colorError,
      GenaiToastType.info => colors.colorInfo,
    };
    final icon = switch (widget.type) {
      GenaiToastType.success => LucideIcons.circleCheck,
      GenaiToastType.warning => LucideIcons.triangleAlert,
      GenaiToastType.error => LucideIcons.circleAlert,
      GenaiToastType.info => LucideIcons.info,
    };

    final bg = isDark ? colors.surfaceCard : const Color(0xFF1F2937);
    final fg = isDark ? colors.textPrimary : Colors.white;
    final fgSubtle = fg.withValues(alpha: 0.75);

    Alignment align;
    EdgeInsets margin;
    switch (widget.position) {
      case GenaiToastPosition.topRight:
        align = Alignment.topRight;
        margin = const EdgeInsets.only(top: 24, right: 24);
        break;
      case GenaiToastPosition.topCenter:
        align = Alignment.topCenter;
        margin = const EdgeInsets.only(top: 24);
        break;
      case GenaiToastPosition.bottomRight:
        align = Alignment.bottomRight;
        margin = const EdgeInsets.only(bottom: 24, right: 24);
        break;
      case GenaiToastPosition.bottomCenter:
        align = Alignment.bottomCenter;
        margin = const EdgeInsets.only(bottom: 24);
        break;
    }

    return SafeArea(
      child: Align(
        alignment: align,
        child: Padding(
          padding: margin,
          child: SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _fade,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: context.elevation.shadow(4),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 20, color: iconColor),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.title != null) Text(widget.title!, style: ty.label.copyWith(color: fg, fontWeight: FontWeight.w600)),
                              Text(widget.message, style: ty.bodySm.copyWith(color: fgSubtle)),
                              if (widget.actionLabel != null) ...[
                                const SizedBox(height: 6),
                                GestureDetector(
                                  onTap: widget.onAction,
                                  child: Text(
                                    widget.actionLabel!,
                                    style: ty.label.copyWith(
                                      color: iconColor,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        GenaiIconButton(
                          icon: LucideIcons.x,
                          size: GenaiSize.xs,
                          semanticLabel: 'Chiudi notifica',
                          onPressed: () async {
                            await _ctrl.reverse();
                            // Removed by host's auto-timer.
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
