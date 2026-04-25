import 'package:flutter/material.dart';

import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

/// Standard error page widget for the GenAI Components framework.
///
/// Displays an error icon, optional title, error code, message, detail,
/// and up to two action buttons ([onRetry] and [onGoHome]).
///
/// Designed to be used as a default fallback for `GoRouter.errorBuilder`
/// or `Modular.configure(errorBuilder:)`, but can also be used standalone
/// inside any page that needs a consistent error UI.
///
/// Example:
/// ```dart
/// CLErrorPage(
///   errorCode: '404',
///   title: 'Pagina non trovata',
///   message: 'La risorsa richiesta non esiste.',
///   onGoHome: () => context.go('/'),
/// )
/// ```
class CLErrorPage extends StatelessWidget {
  /// Optional error code (e.g. `404`, `500`, custom app codes).
  final String? errorCode;

  /// Optional title. Defaults to `'Errore'` when null.
  final String? title;

  /// Optional human-readable message describing the error.
  final String? message;

  /// Optional technical detail (e.g. stack trace summary, request id).
  final String? detail;

  /// Optional retry callback. Renders a primary button when provided.
  final VoidCallback? onRetry;

  /// Optional go-home callback. Renders a secondary button when provided.
  final VoidCallback? onGoHome;

  const CLErrorPage({
    super.key,
    this.errorCode,
    this.title,
    this.message,
    this.detail,
    this.onRetry,
    this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    final cl = CLTheme.of(context);
    return Scaffold(
      backgroundColor: cl.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              cl.background,
              Color.alphaBlend(cl.danger.withValues(alpha: 0.04), cl.background),
            ],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(CLSizes.gap2Xl),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 360),
                curve: Curves.easeOutCubic,
                builder: (context, t, child) => Opacity(
                  opacity: t,
                  child: Transform.translate(
                    offset: Offset(0, (1 - t) * 12),
                    child: child,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(CLSizes.gap3Xl),
                  decoration: BoxDecoration(
                    color: cl.secondaryBackground,
                    borderRadius: BorderRadius.circular(CLSizes.radiusModal),
                    border: Border.all(color: cl.cardBorder, width: 1),
                    boxShadow: cl.cardShadow,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _ErrorBadge(color: cl.danger),
                      const SizedBox(height: CLSizes.gap2Xl),
                      if (errorCode != null) ...[
                        Text(
                          'CODICE $errorCode',
                          style: cl.smallLabel.copyWith(
                            color: cl.mutedForeground,
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: CLSizes.gapSm),
                      ],
                      Text(
                        title ?? 'Errore',
                        style: cl.heading2.copyWith(color: cl.primaryText),
                        textAlign: TextAlign.center,
                      ),
                      if (message != null) ...[
                        const SizedBox(height: CLSizes.gapMd),
                        Text(
                          message!,
                          textAlign: TextAlign.center,
                          style: cl.subTitle.copyWith(color: cl.secondaryText),
                        ),
                      ],
                      if (detail != null) ...[
                        const SizedBox(height: CLSizes.gapLg),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: CLSizes.gapLg,
                            vertical: CLSizes.gapMd,
                          ),
                          decoration: BoxDecoration(
                            color: cl.muted,
                            borderRadius: BorderRadius.circular(CLSizes.radiusControl),
                            border: Border.all(color: cl.borderColor, width: 1),
                          ),
                          child: SelectableText(
                            detail!,
                            textAlign: TextAlign.left,
                            style: cl.smallText.copyWith(
                              color: cl.mutedForeground,
                              fontFamily: 'monospace',
                              height: 1.55,
                            ),
                          ),
                        ),
                      ],
                      if (onRetry != null || onGoHome != null) ...[
                        const SizedBox(height: CLSizes.gap2Xl),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (onRetry != null)
                              Expanded(
                                child: _PrimaryButton(
                                  label: 'Riprova',
                                  icon: Icons.refresh_rounded,
                                  onPressed: onRetry,
                                  background: cl.primary,
                                  foreground: Colors.white,
                                ),
                              ),
                            if (onRetry != null && onGoHome != null)
                              const SizedBox(width: CLSizes.gapMd),
                            if (onGoHome != null)
                              Expanded(
                                child: _GhostButton(
                                  label: 'Home',
                                  icon: Icons.home_outlined,
                                  onPressed: onGoHome,
                                  borderColor: cl.borderColor,
                                  foreground: cl.primaryText,
                                  hoverBg: cl.muted,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
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

class _ErrorBadge extends StatelessWidget {
  final Color color;
  const _ErrorBadge({required this.color});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.6, end: 1.0),
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutBack,
      builder: (context, t, child) => Transform.scale(scale: t, child: child),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.10),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
        ),
        child: Icon(Icons.priority_high_rounded, size: 36, color: color),
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color background;
  final Color foreground;

  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    required this.background,
    required this.foreground,
    this.icon,
  });

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final hoverBg = Color.alphaBlend(Colors.black.withValues(alpha: _hover ? 0.10 : 0), widget.background);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
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
            color: hoverBg,
            borderRadius: BorderRadius.circular(CLSizes.radiusControl),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: CLSizes.iconSizeCompact, color: widget.foreground),
                const SizedBox(width: CLSizes.gapSm),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: widget.foreground,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GhostButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color borderColor;
  final Color foreground;
  final Color hoverBg;

  const _GhostButton({
    required this.label,
    required this.onPressed,
    required this.borderColor,
    required this.foreground,
    required this.hoverBg,
    this.icon,
  });

  @override
  State<_GhostButton> createState() => _GhostButtonState();
}

class _GhostButtonState extends State<_GhostButton> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
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
            color: _hover ? widget.hoverBg : Colors.transparent,
            borderRadius: BorderRadius.circular(CLSizes.radiusControl),
            border: Border.all(color: widget.borderColor, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: CLSizes.iconSizeCompact, color: widget.foreground),
                const SizedBox(width: CLSizes.gapSm),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: widget.foreground,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
