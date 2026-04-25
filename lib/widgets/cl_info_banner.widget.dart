import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

/// CLInfoBanner — banner esplicativo contestuale con icona, testo e azione opzionale.
///
/// Linguaggio Skillera Refined Editorial: tinta soft (alpha ~0.06), bordo tonale
/// 1px + accent stripe a sinistra, IconBadge semantico, tipografia Satoshi/Inter,
/// dismiss opzionale, action link primario, ingresso con fade+slide (180ms).
/// Inline — niente elevazione: spetta a card/dialog.
class CLInfoBanner extends StatefulWidget {
  final String text;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? color;
  final dynamic icon;
  final bool dismissible;

  const CLInfoBanner({
    super.key,
    required this.text,
    this.actionText,
    this.onAction,
    this.color,
    this.icon,
    this.dismissible = false,
  });

  @override
  State<CLInfoBanner> createState() => _CLInfoBannerState();
}

class _CLInfoBannerState extends State<CLInfoBanner> {
  bool _dismissed = false;
  bool _hoverDismiss = false;
  bool _hoverAction = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    final theme = CLTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = widget.color ?? theme.info;

    final tintAlpha = isDark ? 0.10 : 0.06;
    final borderAlpha = isDark ? 0.28 : 0.20;
    final iconBgAlpha = isDark ? 0.18 : 0.10;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: 1),
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 6),
            child: child,
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(CLSizes.radiusControl),
        child: Container(
          decoration: BoxDecoration(
            color: c.withValues(alpha: tintAlpha),
            borderRadius: BorderRadius.circular(CLSizes.radiusControl),
            border: Border.all(
              color: c.withValues(alpha: borderAlpha),
              width: 1,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Accent stripe — 3px
                Container(
                  width: 3,
                  decoration: BoxDecoration(color: c),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: CLSizes.gapLg,
                      vertical: CLSizes.gapMd,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Leading IconBadge
                        Container(
                          padding: const EdgeInsets.all(CLSizes.gapSm),
                          decoration: BoxDecoration(
                            color: c.withValues(alpha: iconBgAlpha),
                            borderRadius: BorderRadius.circular(CLSizes.radiusChip + 2),
                            border: Border.all(
                              color: c.withValues(alpha: borderAlpha),
                              width: 0.5,
                            ),
                          ),
                          child: HugeIcon(
                            icon: widget.icon ?? HugeIcons.strokeRoundedInformationCircle,
                            color: c,
                            size: CLSizes.iconSizeCompact,
                          ),
                        ),
                        const SizedBox(width: CLSizes.gapMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.text,
                                style: theme.bodyText.copyWith(
                                  color: isDark
                                      ? theme.primaryText
                                      : theme.primaryText.withValues(alpha: 0.88),
                                  height: 1.5,
                                ),
                              ),
                              if (widget.actionText != null && widget.onAction != null) ...[
                                const SizedBox(height: CLSizes.gapSm),
                                _ActionLink(
                                  label: widget.actionText!,
                                  color: c,
                                  hovered: _hoverAction,
                                  onHover: (h) => setState(() => _hoverAction = h),
                                  onTap: widget.onAction!,
                                  baseStyle: theme.smallLabel,
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (widget.dismissible) ...[
                          const SizedBox(width: CLSizes.gapSm),
                          _DismissButton(
                            hovered: _hoverDismiss,
                            onHover: (h) => setState(() => _hoverDismiss = h),
                            onTap: () => setState(() => _dismissed = true),
                            mutedFg: theme.mutedForeground,
                            muted: theme.muted,
                          ),
                        ],
                      ],
                    ),
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

class _ActionLink extends StatelessWidget {
  final String label;
  final Color color;
  final bool hovered;
  final ValueChanged<bool> onHover;
  final VoidCallback onTap;
  final TextStyle baseStyle;

  const _ActionLink({
    required this.label,
    required this.color,
    required this.hovered,
    required this.onHover,
    required this.onTap,
    required this.baseStyle,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 120),
          style: baseStyle.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            decoration: hovered ? TextDecoration.underline : TextDecoration.none,
            decorationColor: color.withValues(alpha: 0.55),
            decorationThickness: 1.5,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

class _DismissButton extends StatelessWidget {
  final bool hovered;
  final ValueChanged<bool> onHover;
  final VoidCallback onTap;
  final Color mutedFg;
  final Color muted;

  const _DismissButton({
    required this.hovered,
    required this.onHover,
    required this.onTap,
    required this.mutedFg,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: hovered ? muted : Colors.transparent,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedCancel01,
            color: hovered ? mutedFg.withValues(alpha: 0.95) : mutedFg,
            size: 14,
          ),
        ),
      ),
    );
  }
}
