import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:responsive_framework/responsive_framework.dart';
// Budella Shad: nucleo interno del bottone. Solo i simboli usati (show) per non
// inquinare il namespace. Firma pubblica CLSoftButton invariata.
import 'package:shadcn_ui/shadcn_ui.dart'
    show ShadButton, ShadButtonVariant, ShadDecoration, ShadBorder;
import '../../cl_theme.dart';
import 'cl_async_button_mixin.dart';
import 'cl_loading_spinner.widget.dart';
import '../foundation/cl_pressable.widget.dart';
import '../foundation/cl_tone_style.dart';

class CLSoftButton extends StatefulWidget {
  final Color color;
  final String text;
  final Function() onTap;
  final BuildContext context;
  final IconAlignment iconAlignment;
  final IconData? iconData;
  final List<List<dynamic>>? hugeIcon;
  final double? width;
  final bool needConfirmation;
  final String? confirmationMessage;
  final bool isCompact;

  /// Override raggio angoli. Default `theme.radiusControl`. Es. `theme.radiusPill`.
  final double? borderRadius;

  /// Interno: `true` → tono semantico colorato (primary/success/info/warning/
  /// danger): bg tinta `color × opacitySoft` + testo/icona `color`. `false` →
  /// neutro (secondary + costruttore raw): bg `muted`, testo `primaryText`.
  /// Prima [color] non veniva mai letto in `build()` e ogni tono rendeva grigio.
  final bool _colored;

  const CLSoftButton({
    super.key,
    required this.color,
    required this.text,
    required this.onTap,
    required this.context,
    required this.iconAlignment,
    this.needConfirmation = false,
    this.confirmationMessage,
    this.iconData,
    this.hugeIcon,
    this.width,
    this.isCompact = false,
    this.borderRadius,
  }) : _colored = false;

  const CLSoftButton._colored({
    required this.color,
    required this.text,
    required this.onTap,
    required this.context,
    required this.iconAlignment,
    this.needConfirmation = false,
    this.confirmationMessage,
    this.iconData,
    this.hugeIcon,
    this.width,
    this.isCompact = false,
    this.borderRadius,
  }) : _colored = true;

  factory CLSoftButton.primary({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    IconData? icon,
    List<List<dynamic>>? hugeIcon,
    double? width,
    bool needConfirmation = false,
    String? confirmationMessage,
    bool isCompact = false,
    double? borderRadius,
  }) {
    return CLSoftButton._colored(
      text: text,
      color: CLTheme.of(context).primary,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      hugeIcon: hugeIcon,
      width: width,
      needConfirmation: needConfirmation,
      confirmationMessage: confirmationMessage,
      isCompact: isCompact,
      borderRadius: borderRadius,
    );
  }

  factory CLSoftButton.secondary({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    IconData? icon,
    List<List<dynamic>>? hugeIcon,
    double? width,
    bool needConfirmation = false,
    String? confirmationMessage,
    bool isCompact = false,
  }) {
    return CLSoftButton(
      text: text,
      color: CLTheme.of(context).secondary,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      hugeIcon: hugeIcon,
      width: width,
      needConfirmation: needConfirmation,
      confirmationMessage: confirmationMessage,
      isCompact: isCompact,
    );
  }

  factory CLSoftButton.success({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    IconData? icon,
    List<List<dynamic>>? hugeIcon,
    double? width,
    bool needConfirmation = false,
    String? confirmationMessage,
    bool isCompact = false,
  }) {
    return CLSoftButton._colored(
      text: text,
      color: CLTheme.of(context).success,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      hugeIcon: hugeIcon,
      width: width,
      needConfirmation: needConfirmation,
      confirmationMessage: confirmationMessage,
      isCompact: isCompact,
    );
  }

  factory CLSoftButton.info({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    IconData? icon,
    List<List<dynamic>>? hugeIcon,
    double? width,
    bool needConfirmation = false,
    String? confirmationMessage,
    bool isCompact = false,
  }) {
    return CLSoftButton._colored(
      text: text,
      color: CLTheme.of(context).info,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      hugeIcon: hugeIcon,
      width: width,
      needConfirmation: needConfirmation,
      confirmationMessage: confirmationMessage,
      isCompact: isCompact,
    );
  }

  factory CLSoftButton.warning({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    IconData? icon,
    List<List<dynamic>>? hugeIcon,
    double? width,
    bool needConfirmation = false,
    String? confirmationMessage,
    bool isCompact = false,
  }) {
    return CLSoftButton._colored(
      text: text,
      color: CLTheme.of(context).warning,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      hugeIcon: hugeIcon,
      width: width,
      needConfirmation: needConfirmation,
      confirmationMessage: confirmationMessage,
      isCompact: isCompact,
    );
  }

  factory CLSoftButton.danger({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    IconData? icon,
    List<List<dynamic>>? hugeIcon,
    double? width,
    bool needConfirmation = false,
    String? confirmationMessage,
    bool isCompact = false,
  }) {
    return CLSoftButton._colored(
      text: text,
      color: CLTheme.of(context).danger,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      hugeIcon: hugeIcon,
      width: width,
      needConfirmation: needConfirmation,
      confirmationMessage: confirmationMessage,
      isCompact: isCompact,
    );
  }

  @override
  State<CLSoftButton> createState() => _CLSoftButtonState();
}

class _CLSoftButtonState extends State<CLSoftButton> with AsyncButtonMixin {
  Future<void> _handleTap() async {
    await handleAsyncTap(
      onTap: widget.onTap,
      needConfirmation: widget.needConfirmation,
      confirmationMessage: widget.confirmationMessage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = !ResponsiveBreakpoints.of(context).isDesktop;
    final theme = CLTheme.of(context);
    final colored = widget._colored;
    final isLoading = loading;
    final isInteractive = !isLoading;
    final showText = widget.text.isNotEmpty;

    final hPad = widget.isCompact ? theme.gapMd : theme.gapLg;
    final iconSz = widget.isCompact ? theme.iconSizeCompact - 2 : theme.iconSizeCompact;
    final btnH = widget.isCompact ? theme.buttonHeightCompact : theme.buttonHeightDefault;
    final radius = widget.borderRadius ?? theme.radiusControl;

    // ── Colori per stato dal motore CLToneStyle (variante soft): base/hover/press.
    //    `colored` inoltrato → percorso tinto (tono × opacità) o neutro (scala
    //    muted, fg primaryText). Riproduce 1:1 il chrome storico. ──────────────
    final CLToneColors tBase = CLToneStyle.resolve(theme,
        color: widget.color, variant: CLVariant.soft, colored: colored);
    final CLToneColors tHover = CLToneStyle.resolve(theme,
        color: widget.color,
        variant: CLVariant.soft,
        colored: colored,
        state: const CLPressableState(hovered: true));
    final CLToneColors tPressed = CLToneStyle.resolve(theme,
        color: widget.color,
        variant: CLVariant.soft,
        colored: colored,
        state: const CLPressableState(pressed: true));
    final fgColor = tBase.fg;

    final labelStyle = theme.bodyText.copyWith(color: fgColor, fontWeight: FontWeight.w500);

    // ── Slot icona ↔ spinner (hugeicons/icona → CLLoadingSpinner in loading). ──
    Widget buildIconSlot(double size) {
      final iconChild = widget.hugeIcon != null
          ? HugeIcon(icon: widget.hugeIcon!, color: fgColor, size: size)
          : widget.iconData != null
              ? Icon(widget.iconData, color: fgColor, size: size)
              : SizedBox(width: size, height: size);
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: isLoading
            ? SizedBox(
                key: const ValueKey('spinner'),
                width: size,
                height: size,
                child: CLLoadingSpinner(size: size, color: fgColor),
              )
            : KeyedSubtree(key: const ValueKey('icon'), child: iconChild),
      );
    }

    final hasInlineIcon = widget.iconData != null || widget.hugeIcon != null || isLoading;
    final iconTextGap = theme.gapSm;

    Widget content;
    if (showText) {
      // SEMPRE min: il Row interno di ShadButton misura i figli non-flex con
      // larghezza infinita, e un Row `max` con dentro un `Flexible` asserisce
      // (spiegazione estesa in cl_button.widget.dart). La larghezza la dà il
      // SizedBox esterno, che la rende tight: il Row `min` la eredita.
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (hasInlineIcon && widget.iconAlignment == IconAlignment.start) ...[
            buildIconSlot(iconSz),
            SizedBox(width: iconTextGap),
          ],
          Flexible(
            child: Text(
              widget.text,
              style: labelStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
          if (hasInlineIcon && widget.iconAlignment == IconAlignment.end) ...[
            SizedBox(width: iconTextGap),
            buildIconSlot(iconSz),
          ],
        ],
      );
    } else {
      content = Center(child: buildIconSlot(iconSz));
    }

    // ── Nucleo = ShadButton (budella Shad): hover/press/focus/keyboard e ring
    //    nativi. I colori per stato restano dal motore CLToneStyle (soft):
    //    base/hover/press passati a ShadButton → tono CL preservato 1:1.
    //    async/confirm/loading/icon-swap restano nel wrapper CL. Firma pubblica
    //    invariata. ────────────────────────────────────────────────────────────
    Widget button = ShadButton.raw(
      variant: ShadButtonVariant.primary,
      // enabled=isInteractive → in loading ShadButton toglie hover e attenua.
      enabled: isInteractive,
      onPressed: () => _handleTap(),
      backgroundColor: tBase.bg,
      hoverBackgroundColor: tHover.bg,
      pressedBackgroundColor: tPressed.bg,
      foregroundColor: fgColor,
      hoverForegroundColor: fgColor,
      pressedForegroundColor: fgColor,
      height: btnH,
      width: showText ? null : btnH,
      padding: showText ? EdgeInsets.symmetric(horizontal: hPad) : EdgeInsets.zero,
      mainAxisAlignment: MainAxisAlignment.center,
      decoration: ShadDecoration(
        border: ShadBorder(radius: BorderRadius.circular(radius)),
      ),
      child: content,
    );

    // minWidth 64 (desktop) per i bottoni con testo, come prima.
    if (showText && !isMobile) {
      button = ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 64), child: button);
    }

    if (widget.width != null) {
      button = SizedBox(width: widget.width, child: button);
    }

    return button;
  }
}
