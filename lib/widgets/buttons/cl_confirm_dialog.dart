import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';

/// Legacy confirmation dialog. Public API preserved verbatim:
///   ConfirmationDialog({Key?, String? confirmationMessage, required Function() onTap})
///
/// Visual layer refreshed to match the Skillera Refined Editorial language
/// used by the new `CLConfirmationDialog` (in `widgets/dialogs/`), but the
/// chrome is inlined here so this file stays self-contained and does not
/// import the private `_dialog_chrome.dart` exclusive to that directory.
class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    this.confirmationMessage,
    required this.onTap,
  });

  final String? confirmationMessage;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    final isMobile = !ResponsiveBreakpoints.of(context).isDesktop;
    final cl = CLTheme.of(context);
    final dialogWidth = isMobile ? double.infinity : 460.0;
    final tone = cl.primary;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dialogWidth),
        child: Padding(
          padding: const EdgeInsets.all(CLSizes.gapLg),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            builder: (context, t, child) => Opacity(
              opacity: t,
              child: Transform.translate(
                offset: Offset(0, (1 - t) * 8),
                child: child,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: cl.secondaryBackground,
                  borderRadius: BorderRadius.circular(CLSizes.radiusModal),
                  border: Border.all(color: cl.cardBorder, width: 1),
                  boxShadow: cl.cardShadow,
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        CLSizes.gap2Xl,
                        CLSizes.gap2Xl,
                        CLSizes.gap2Xl,
                        CLSizes.gapLg,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _LegacyIconBadge(
                            icon: Icons.help_outline_rounded,
                            color: tone,
                          ),
                          const SizedBox(width: CLSizes.gapLg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Conferma',
                                  style: cl.heading4.copyWith(
                                    color: cl.primaryText,
                                    fontSize: 18,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: CLSizes.gapSm),
                                Text(
                                  confirmationMessage ??
                                      "Sei sicuro di voler effettuare quest'operazione?",
                                  style: cl.bodyText.copyWith(
                                    color: cl.secondaryText,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: cl.borderColor, width: 1),
                        ),
                        color: cl.muted.withValues(alpha: 0.40),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: CLSizes.gap2Xl,
                        vertical: CLSizes.gapLg,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _LegacyDialogButton(
                            label: 'Annulla',
                            tone: _LegacyTone.ghost,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(width: CLSizes.gapMd),
                          _LegacyDialogButton(
                            label: 'Conferma',
                            tone: _LegacyTone.primary,
                            autofocus: true,
                            onPressed: onTap,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Inlined chrome (private) -----------------------------------------------

class _LegacyIconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _LegacyIconBadge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.7, end: 1.0),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutBack,
      builder: (context, t, child) => Transform.scale(scale: t, child: child),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.10),
          border: Border.all(color: color.withValues(alpha: 0.22), width: 1.5),
        ),
        child: Icon(icon, size: 24, color: color),
      ),
    );
  }
}

enum _LegacyTone { primary, ghost }

class _LegacyDialogButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final _LegacyTone tone;
  final bool autofocus;

  const _LegacyDialogButton({
    required this.label,
    required this.onPressed,
    this.tone = _LegacyTone.primary,
    this.autofocus = false,
  });

  @override
  State<_LegacyDialogButton> createState() => _LegacyDialogButtonState();
}

class _LegacyDialogButtonState extends State<_LegacyDialogButton> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cl = CLTheme.of(context);
    final disabled = widget.onPressed == null;

    Color background;
    Color foreground;
    Color? borderColor;

    switch (widget.tone) {
      case _LegacyTone.primary:
        background = disabled
            ? cl.muted
            : Color.alphaBlend(
                Colors.black.withValues(alpha: _hover ? 0.10 : 0),
                cl.primary,
              );
        foreground = disabled ? cl.mutedForeground : Colors.white;
        break;
      case _LegacyTone.ghost:
        background = _hover ? cl.muted : Colors.transparent;
        foreground = cl.primaryText;
        borderColor = cl.borderColor;
        break;
    }

    return Focus(
      autofocus: widget.autofocus,
      child: MouseRegion(
        cursor: disabled
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTapDown:
              disabled ? null : (_) => setState(() => _pressed = true),
          onTapUp:
              disabled ? null : (_) => setState(() => _pressed = false),
          onTapCancel:
              disabled ? null : () => setState(() => _pressed = false),
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            height: CLSizes.buttonHeightDefault,
            transform: _pressed
                ? (Matrix4.identity()..scaleByDouble(0.98, 0.98, 1, 1))
                : Matrix4.identity(),
            transformAlignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: CLSizes.gapLg),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(CLSizes.radiusControl),
              border: borderColor != null
                  ? Border.all(color: borderColor, width: 1)
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: foreground,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
