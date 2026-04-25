import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';
import 'excerpt_text.widget.dart';

/// Skillera Refined Editorial alert.
///
/// Soft semantic tints, IconBadge, Satoshi heading + Inter body, subtle
/// fade+slide entry, hover lift on dismissible variants. Public API
/// (constructors / factories / fields) is preserved from the previous
/// revision: only internal build/style is upgraded.
class CLAlert extends StatelessWidget {
  const CLAlert._(this.alertTitle, this.alertText,
      {super.key, this.icon, this.iconAlignment, this.decoration, this.foregroundColor, this.onClose, this.downloadPercentageStream});

  final String alertTitle;
  final String alertText;
  final IconData? icon;
  final IconAlignment? iconAlignment;
  final BoxDecoration? decoration;
  final Color? foregroundColor;
  final void Function()? onClose;
  final BehaviorSubject<double>? downloadPercentageStream;

  /// Solid (filled) variant. Background color saturates to the semantic tone;
  /// foreground stays light. Kept for high-emphasis system messages.
  CLAlert.solid(
    String alertTitle,
    String alertText, {
    Key? key,
    IconData? icon,
    IconAlignment iconAlignment = IconAlignment.start,
    Color? backgroundColor,
    Color? foregroundColor,
    void Function()? onClose,
  }) : this._(
          key: key,
          alertTitle,
          alertText,
          icon: icon,
          iconAlignment: iconAlignment,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(CLSizes.radiusCard),
          ),
          foregroundColor: foregroundColor ?? Colors.white,
          onClose: onClose,
        );

  /// Soft tinted variant — the default editorial style. 10% bg / 22% border
  /// of the supplied semantic color, IconBadge, primaryText for body.
  CLAlert.border(
    String alertTitle,
    String alertText, {
    Key? key,
    IconData? icon,
    IconAlignment iconAlignment = IconAlignment.start,
    Color? backgroundColor,
    void Function()? onClose,
  }) : this._(
          key: key,
          alertTitle,
          alertText,
          icon: icon,
          iconAlignment: iconAlignment,
          decoration: BoxDecoration(
            color: (backgroundColor ?? const Color(0xFF0C8EC7)).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(CLSizes.radiusControl),
            border: Border.all(
              color: (backgroundColor ?? const Color(0xFF0C8EC7)).withValues(alpha: 0.22),
              width: 1,
            ),
          ),
          foregroundColor: backgroundColor ?? const Color(0xFF0C8EC7),
          onClose: onClose,
        );

  /// Download variant — same soft tone as `border`, with a circular progress
  /// indicator in place of the IconBadge.
  CLAlert.download(
    String alertTitle,
    String alertText, {
    Key? key,
    IconData? icon,
    IconAlignment iconAlignment = IconAlignment.start,
    Color? backgroundColor,
    void Function()? onClose,
    required BehaviorSubject<double> downloadPercentageStream,
  }) : this._(
          key: key,
          alertTitle,
          alertText,
          icon: icon,
          iconAlignment: iconAlignment,
          downloadPercentageStream: downloadPercentageStream,
          decoration: BoxDecoration(
            color: (backgroundColor ?? const Color(0xFF0C8EC7)).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(CLSizes.radiusCard),
            border: Border.all(
              color: (backgroundColor ?? const Color(0xFF0C8EC7)).withValues(alpha: 0.22),
              width: 1,
            ),
          ),
          foregroundColor: backgroundColor ?? const Color(0xFF0C8EC7),
          onClose: onClose,
        );

  /// Outline-only variant — transparent fill, 30% border, kept lightweight
  /// for stacked/inline contexts.
  CLAlert.outline(
    String alertTitle,
    String alertText, {
    Key? key,
    IconData? icon,
    IconAlignment iconAlignment = IconAlignment.start,
    Color? backgroundColor,
    void Function()? onClose,
  }) : this._(
          key: key,
          alertTitle,
          alertText,
          icon: icon,
          iconAlignment: iconAlignment,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(CLSizes.radiusControl),
            border: Border.all(
              color: (backgroundColor ?? const Color(0xFF0C8EC7)).withValues(alpha: 0.30),
              width: 1,
            ),
          ),
          foregroundColor: backgroundColor ?? const Color(0xFF0C8EC7),
          onClose: onClose,
        );

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 6),
            child: child,
          ),
        );
      },
      child: _AlertBody(
        alertTitle: alertTitle,
        alertText: alertText,
        icon: icon,
        decoration: decoration,
        foregroundColor: foregroundColor,
        onClose: onClose,
        downloadPercentageStream: downloadPercentageStream,
      ),
    );
  }
}

/// Internal body — splits the static frame from the entry animation so the
/// hover-lift `MouseRegion` lives in a `StatefulWidget`.
class _AlertBody extends StatefulWidget {
  const _AlertBody({
    required this.alertTitle,
    required this.alertText,
    required this.icon,
    required this.decoration,
    required this.foregroundColor,
    required this.onClose,
    required this.downloadPercentageStream,
  });

  final String alertTitle;
  final String alertText;
  final IconData? icon;
  final BoxDecoration? decoration;
  final Color? foregroundColor;
  final VoidCallback? onClose;
  final BehaviorSubject<double>? downloadPercentageStream;

  @override
  State<_AlertBody> createState() => _AlertBodyState();
}

class _AlertBodyState extends State<_AlertBody> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final tone = widget.foregroundColor ?? theme.primary;
    final isSolid = (widget.decoration?.color != null) &&
        (widget.decoration!.color!.a > 0.5);

    // Solid variant uses light foreground; tinted variants render copy in
    // primaryText (legible on 10% tinted bg).
    final titleColor = isSolid ? Colors.white : theme.primaryText;
    final bodyColor = isSolid ? Colors.white.withValues(alpha: 0.92) : theme.secondaryText;

    final hoverable = widget.onClose != null && widget.downloadPercentageStream == null;

    final shadow = hoverable && _hover
        ? <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ]
        : <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ];

    Widget container = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: (widget.decoration ?? const BoxDecoration()).copyWith(
        boxShadow: shadow,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: CLSizes.gapLg,
        vertical: CLSizes.gapMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.downloadPercentageStream != null)
                  Padding(
                    padding: const EdgeInsets.only(right: CLSizes.gapMd, top: 2),
                    child: _DownloadBadge(
                      tone: tone,
                      stream: widget.downloadPercentageStream!,
                      onComplete: widget.onClose,
                    ),
                  )
                else if (widget.icon != null) ...[
                  _IconBadge(icon: widget.icon!, tone: tone, isSolid: isSolid),
                  const SizedBox(width: CLSizes.gapMd),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.alertTitle,
                        style: theme.heading4.copyWith(color: titleColor),
                        overflow: TextOverflow.visible,
                        softWrap: true,
                      ),
                      const SizedBox(height: CLSizes.gapXs),
                      DefaultTextStyle.merge(
                        style: theme.bodyText.copyWith(color: bodyColor),
                        child: ExcerptText(
                          text: widget.alertText,
                          textStyle: theme.bodyText.copyWith(color: bodyColor),
                          maxLength: 300,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (widget.onClose != null && widget.downloadPercentageStream == null) ...[
            const SizedBox(width: CLSizes.gapSm),
            _CloseButton(
              onTap: widget.onClose!,
              isSolid: isSolid,
              theme: theme,
            ),
          ],
        ],
      ),
    );

    if (!hoverable) return container;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: container,
    );
  }
}

/// Tinted circular icon badge (10% bg, 22% border 1.5w) — Skillera signature.
class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.tone, required this.isSolid});

  final IconData icon;
  final Color tone;
  final bool isSolid;

  @override
  Widget build(BuildContext context) {
    if (isSolid) {
      // On a solid bg the badge would disappear — render a plain icon instead.
      return Padding(
        padding: const EdgeInsets.only(top: 1),
        child: Icon(icon, color: Colors.white, size: CLSizes.iconSizeDefault),
      );
    }
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.10),
        shape: BoxShape.circle,
        border: Border.all(color: tone.withValues(alpha: 0.22), width: 1.5),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: tone, size: CLSizes.iconSizeCompact),
    );
  }
}

/// Tinted circular close button — mutedForeground hover→primaryText.
class _CloseButton extends StatefulWidget {
  const _CloseButton({required this.onTap, required this.isSolid, required this.theme});

  final VoidCallback onTap;
  final bool isSolid;
  final CLTheme theme;

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.isSolid
        ? Colors.white
        : (_hover ? widget.theme.primaryText : widget.theme.mutedForeground);
    final bg = widget.isSolid
        ? Colors.white.withValues(alpha: _hover ? 0.18 : 0.10)
        : widget.theme.muted.withValues(alpha: _hover ? 1.0 : 0.6);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(Icons.close_rounded, size: 16, color: iconColor),
        ),
      ),
    );
  }
}

/// Circular download progress badge replacing the IconBadge in the
/// `download` factory.
class _DownloadBadge extends StatelessWidget {
  const _DownloadBadge({required this.tone, required this.stream, required this.onComplete});

  final Color tone;
  final BehaviorSubject<double> stream;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    return SizedBox(
      width: 32,
      height: 32,
      child: StreamBuilder<double>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              decoration: BoxDecoration(
                color: tone.withValues(alpha: 0.10),
                shape: BoxShape.circle,
                border: Border.all(color: tone.withValues(alpha: 0.22), width: 1.5),
              ),
            );
          }
          final value = snapshot.data!;
          if (value >= 100) {
            WidgetsBinding.instance.addPostFrameCallback((_) => onComplete?.call());
          }
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  value: value / 100,
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(tone),
                  backgroundColor: tone.withValues(alpha: 0.18),
                ),
              ),
              Text(
                "${value.toStringAsFixed(0)}%",
                style: theme.smallLabel.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: theme.primaryText,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
