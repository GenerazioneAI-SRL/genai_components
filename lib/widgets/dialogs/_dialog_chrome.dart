// Internal chrome shared by CLDialog, QRCodeDialog, CLConfirmationDialog,
// AssignEntitiesModal. Not exported by the package barrel.

import 'package:flutter/material.dart';

import '../../cl_theme.dart';
import '../foundation/cl_pressable.widget.dart';

/// Animated container for a refined Skillera dialog. Wraps a Material
/// surface with rounded modal radius, theme-aware shadow and entrance
/// fade+lift transition. Pass [maxWidth] to clamp horizontal extent.
class DialogShell extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const DialogShell({
    super.key,
    required this.child,
    this.maxWidth = 480,
  });

  @override
  Widget build(BuildContext context) {
    final cl = CLTheme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.all(cl.gapLg),
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
                  borderRadius: BorderRadius.circular(cl.radiusModal),
                  border: Border.all(color: cl.cardBorder, width: 1),
                  boxShadow: cl.popoverShadow,
                ),
                clipBehavior: Clip.antiAlias,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Header section with an Inter title, optional subtitle, and a discreet
/// close affordance via [onClose].
class DialogHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  const DialogHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final cl = CLTheme.of(context);
    return Padding(
      padding: padding ??
          EdgeInsets.fromLTRB(
            cl.gap2Xl,
            cl.gap2Xl,
            cl.gap2Xl,
            cl.gapLg,
          ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[
            leading!,
            SizedBox(width: cl.gapLg),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: cl.heading4.copyWith(
                    color: cl.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: cl.gapXs),
                  Text(
                    subtitle!,
                    style: cl.smallLabel.copyWith(color: cl.secondaryText, height: 1.5),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: cl.gapLg),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Footer divider + action bar (cancel + confirm). [actions] is rendered
/// right-aligned with an `gapMd` gap between buttons.
class DialogFooter extends StatelessWidget {
  final List<Widget> actions;

  const DialogFooter({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    final cl = CLTheme.of(context);
    // Footer piatto in stile shadcn: nessuna hairline né fascia colorata —
    // separato dal corpo solo dallo spazio. Bottoni allineati a destra.
    return Padding(
      padding: EdgeInsets.fromLTRB(cl.gap2Xl, 0, cl.gap2Xl, cl.gap2Xl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) SizedBox(width: cl.gapMd),
            actions[i],
          ],
        ],
      ),
    );
  }
}

/// Decorative icon badge with a tinted circular background. Use [tone]
/// to pick the semantic color (primary / danger / warning / success).
class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;

  const IconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 56,
    this.iconSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.7, end: 1.0),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutBack,
      builder: (context, t, child) => Transform.scale(scale: t, child: child),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: CLTheme.of(context).opacitySoft),
          border: Border.all(color: color.withValues(alpha: 0.22), width: 1.5),
        ),
        child: Icon(icon, size: iconSize, color: color),
      ),
    );
  }
}

/// Tonal variants used by [CLDialogButton]. `primary` is filled with the
/// theme primary color; `danger` is filled with the theme `danger` color;
/// `ghost` is bordered transparent.
enum CLDialogButtonTone { primary, danger, ghost }

/// Bottone di dialog in stile shadcn: superficie piatta, tre toni semantici
/// (primary/danger filled, ghost outline). Interazione via [CLPressable]
/// (hover/press/focus + attivazione tastiera), senza press-scale.
class CLDialogButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final CLDialogButtonTone tone;
  final bool autofocus;

  const CLDialogButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.tone = CLDialogButtonTone.primary,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final cl = CLTheme.of(context);
    final disabled = onPressed == null;

    return CLPressable(
      enabled: !disabled,
      onTap: onPressed,
      autofocus: autofocus,
      semanticLabel: label,
      builder: (context, state) {
        Color background;
        Color foreground;
        Color? borderColor;

        switch (tone) {
          case CLDialogButtonTone.primary:
            background = disabled
                ? cl.muted
                : Color.alphaBlend(
                    Colors.black.withValues(alpha: state.hovered ? cl.opacitySoft : 0),
                    cl.primary,
                  );
            foreground = disabled ? cl.mutedForeground : Colors.white;
            break;
          case CLDialogButtonTone.danger:
            background = disabled
                ? cl.muted
                : Color.alphaBlend(
                    Colors.black.withValues(alpha: state.hovered ? cl.opacitySoft : 0),
                    cl.danger,
                  );
            foreground = disabled ? cl.mutedForeground : Colors.white;
            break;
          case CLDialogButtonTone.ghost:
            background = state.hovered ? cl.muted : Colors.transparent;
            foreground = cl.primaryText;
            borderColor = cl.borderColor;
            break;
        }

        return AnimatedContainer(
          duration: cl.durationFast,
          curve: cl.easingStandard,
          height: cl.buttonHeightDefault,
          padding: EdgeInsets.symmetric(horizontal: cl.gapLg),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(cl.radiusControl),
            border: borderColor != null ? Border.all(color: borderColor, width: 1) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: cl.iconSizeCompact, color: foreground),
                SizedBox(width: cl.gapSm),
              ],
              Text(
                label,
                style: cl.bodyText.copyWith(color: foreground, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Discreet circular close button used in dialog headers when present.
class DialogCloseButton extends StatefulWidget {
  final VoidCallback onPressed;

  const DialogCloseButton({super.key, required this.onPressed});

  @override
  State<DialogCloseButton> createState() => _DialogCloseButtonState();
}

class _DialogCloseButtonState extends State<DialogCloseButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final cl = CLTheme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: cl.buttonHeightCompact,
          height: cl.buttonHeightCompact,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hover ? cl.muted : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.close_rounded,
            size: cl.iconSizeCompact,
            color: _hover ? cl.primaryText : cl.mutedForeground,
          ),
        ),
      ),
    );
  }
}
