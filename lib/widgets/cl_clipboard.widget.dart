import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './alertmanager/alert_manager.dart';

import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

/// CLClipboardWidget — testo + bottone copia con feedback visivo.
///
/// Linguaggio Skillera Refined Editorial:
/// - swap icona copy → check (success) per ~1.6s con AnimatedSwitcher
///   (scale + fade) come conferma immediata, prima della snackbar
/// - hover ring/muted leggero sul bottone
class CLClipboardWidget extends StatefulWidget {
  const CLClipboardWidget({
    super.key,
    required this.text,
    this.textStyle,
    this.showAlert = false,
  });

  final TextStyle? textStyle;
  final String text;
  final bool showAlert;

  @override
  State<CLClipboardWidget> createState() => _CLClipboardWidgetState();
}

class _CLClipboardWidgetState extends State<CLClipboardWidget> {
  bool _copied = false;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    if (!mounted) return;
    setState(() => _copied = true);
    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _copied = false);
    });
    if (widget.showAlert) {
      AlertManager.showInfo("Info", "Testo ${widget.text} copiato");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            widget.text,
            style: widget.textStyle ?? theme.bodyText,
          ),
        ),
        const SizedBox(width: CLSizes.gapXs),
        Tooltip(
          message: _copied ? 'Copiato' : 'Copia',
          child: InkWell(
            onTap: _handleCopy,
            borderRadius: BorderRadius.circular(CLSizes.radiusControl),
            child: Padding(
              padding: const EdgeInsets.all(CLSizes.gapXs + 2),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: _copied
                    ? Icon(
                        Icons.check_rounded,
                        key: const ValueKey('cl-clipboard-check'),
                        size: CLSizes.iconSizeCompact,
                        color: theme.success,
                      )
                    : Icon(
                        Icons.copy_rounded,
                        key: const ValueKey('cl-clipboard-copy'),
                        size: CLSizes.iconSizeCompact,
                        color: theme.mutedForeground,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
