import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
// Budella Shad: nucleo interno del bottone. Solo i simboli usati (show) per non
// inquinare il namespace. Firma pubblica CLGhostButton invariata.
import 'package:shadcn_ui/shadcn_ui.dart'
    show ShadButton, ShadButtonVariant, ShadDecoration, ShadBorder;

import '../../cl_theme.dart';
import 'cl_async_button_mixin.dart';
import 'cl_loading_spinner.widget.dart';
import '../foundation/cl_pressable.widget.dart';
import '../foundation/cl_tone_style.dart';

// ── Durate micro-interazione ────────────────────────────────────────
const Duration _iconSwapDuration = Duration(milliseconds: 180);

class CLGhostButton extends StatefulWidget {
  final Color color;
  final String text;
  final ButtonStyle? buttonStyle;
  final Function() onTap;
  final BuildContext context;
  final IconAlignment iconAlignment;
  final IconData? iconData;
  final Widget? hugeIcon;
  final double? width;
  final bool needConfirmation;
  final String? confirmationMessage;
  final Color? foregroundColor;
  final bool isCompact;

  /// Interno: `true` → tono semantico colorato (primary/success/info/warning/
  /// danger): testo/hover derivano da [color] via CLToneStyle. `false` → neutro
  /// (secondary + costruttore raw): hover `accent`, testo `primaryText`.
  /// Prima [color] non veniva mai letto in `build()` e ogni tono rendeva neutro.
  final bool _colored;

  const CLGhostButton({
    super.key,
    required this.color,
    required this.text,
    this.buttonStyle,
    required this.onTap,
    required this.context,
    required this.iconAlignment,
    this.iconData,
    this.hugeIcon,
    this.needConfirmation = false,
    this.confirmationMessage,
    this.width,
    this.foregroundColor,
    this.isCompact = false,
  }) : _colored = false;

  const CLGhostButton._colored({
    required this.color,
    required this.text,
    required this.onTap,
    required this.context,
    required this.iconAlignment,
    this.iconData,
    this.hugeIcon,
    this.needConfirmation = false,
    this.confirmationMessage,
    this.width,
    this.foregroundColor,
    this.isCompact = false,
  }) : buttonStyle = null, _colored = true;

  factory CLGhostButton.primary({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    bool needConfirmation = false,
    String? confirmationMessage,
    IconData? icon,
    Widget? hugeIcon,
    Color? foregroundColor,
    double? width,
    bool isCompact = false,
  }) {
    return CLGhostButton._colored(
      text: text,
      color: CLTheme.of(context).primary,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      hugeIcon: hugeIcon,
      width: width,
      foregroundColor: foregroundColor,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
      isCompact: isCompact,
    );
  }

  factory CLGhostButton.secondary({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    bool needConfirmation = false,
    String? confirmationMessage,
    IconData? icon,
    Widget? hugeIcon,
    Color? foregroundColor,
    double? width,
    bool isCompact = false,
  }) {
    return CLGhostButton(
      text: text,
      color: CLTheme.of(context).secondary,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      hugeIcon: hugeIcon,
      width: width,
      foregroundColor: foregroundColor,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
      isCompact: isCompact,
    );
  }

  factory CLGhostButton.success({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    bool needConfirmation = false,
    String? confirmationMessage,
    Color? foregroundColor,
    IconData? icon,
    Widget? hugeIcon,
    double? width,
    bool isCompact = false,
  }) {
    return CLGhostButton._colored(
      text: text,
      color: CLTheme.of(context).success,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      hugeIcon: hugeIcon,
      foregroundColor: foregroundColor,
      width: width,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
      isCompact: isCompact,
    );
  }

  factory CLGhostButton.info({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    bool needConfirmation = false,
    String? confirmationMessage,
    Color? foregroundColor,
    IconData? icon,
    Widget? hugeIcon,
    double? width,
    bool isCompact = false,
  }) {
    return CLGhostButton._colored(
      text: text,
      color: CLTheme.of(context).info,
      context: context,
      onTap: onTap,
      iconAlignment: iconAlignment,
      iconData: icon,
      hugeIcon: hugeIcon,
      foregroundColor: foregroundColor,
      width: width,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
      isCompact: isCompact,
    );
  }

  factory CLGhostButton.warning({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    bool needConfirmation = false,
    String? confirmationMessage,
    Color? foregroundColor,
    IconData? icon,
    Widget? hugeIcon,
    double? width,
    bool isCompact = false,
  }) {
    return CLGhostButton._colored(
      context: context,
      text: text,
      color: CLTheme.of(context).warning,
      onTap: onTap,
      iconAlignment: iconAlignment,
      iconData: icon,
      hugeIcon: hugeIcon,
      width: width,
      foregroundColor: foregroundColor,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
      isCompact: isCompact,
    );
  }

  factory CLGhostButton.danger({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    bool needConfirmation = false,
    String? confirmationMessage,
    Color? foregroundColor,
    IconData? icon,
    Widget? hugeIcon,
    double? width,
    bool isCompact = false,
  }) {
    return CLGhostButton._colored(
      context: context,
      text: text,
      color: CLTheme.of(context).danger,
      onTap: onTap,
      iconAlignment: iconAlignment,
      iconData: icon,
      hugeIcon: hugeIcon,
      width: width,
      foregroundColor: foregroundColor,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
      isCompact: isCompact,
    );
  }

  @override
  State<CLGhostButton> createState() => _CLGhostButtonState();
}

class _CLGhostButtonState extends State<CLGhostButton> with AsyncButtonMixin {
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
    final showText = widget.text.isNotEmpty;
    final isLoading = loading;
    final isInteractive = !isLoading;
    final colored = widget._colored;

    // ── Colori per stato (da CLToneStyle, variante ghost): bg neutro
    // trasparente→accent hover→accent scurito press; il tono vive nel testo/icona
    // (fg). Con `colored:false` percorso neutro (fg = primaryText). ──────────
    CLToneColors chrome(CLPressableState state) => CLToneStyle.resolve(theme,
        color: widget.color,
        variant: CLVariant.ghost,
        colored: colored,
        state: state);
    final CLToneColors tBase = chrome(const CLPressableState());
    final CLToneColors tHover = chrome(const CLPressableState(hovered: true));
    final CLToneColors tPressed = chrome(const CLPressableState(pressed: true));

    // foregroundColor override vince su tutti gli stati; altrimenti fg per-stato.
    final fgColor = widget.foregroundColor ?? tBase.fg;
    final hoverFg = widget.foregroundColor ?? tHover.fg;
    final pressedFg = widget.foregroundColor ?? tPressed.fg;

    final padH = widget.isCompact ? theme.gapMd : theme.gapLg;
    final iconSz = widget.isCompact ? theme.iconSizeCompact - 2 : theme.iconSizeCompact;
    final minHeight = widget.isCompact ? theme.buttonHeightCompact : theme.buttonHeightDefault;
    final iconOnlySide = minHeight;
    final radius = theme.radiusControl;

    // ── Slot icona ↔ spinner ─────────────────────────────────────────
    Widget buildIconSlot(double size) {
      final iconChild = widget.hugeIcon ??
          (widget.iconData != null
              ? Icon(widget.iconData, color: fgColor, size: size)
              : SizedBox(width: size, height: size));
      return AnimatedSwitcher(
        duration: _iconSwapDuration,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
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

    // ── Label ────────────────────────────────────────────────────────
    final labelStyle = theme.bodyText.copyWith(color: fgColor, fontWeight: FontWeight.w500);
    final hasInlineIcon = widget.iconData != null || widget.hugeIcon != null || isLoading;
    final iconTextGap = theme.gapSm;

    Widget content;
    if (showText) {
      // Label con fade durante loading per comunicare stato "in corso".
      final labelWidget = AnimatedOpacity(
        opacity: isLoading ? 0.7 : 1.0,
        duration: _iconSwapDuration,
        child: Text(
          widget.text,
          style: labelStyle,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          textAlign: TextAlign.center,
        ),
      );
      content = Row(
        mainAxisSize: widget.width != null ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (hasInlineIcon && widget.iconAlignment == IconAlignment.start) ...[
            buildIconSlot(iconSz),
            SizedBox(width: iconTextGap),
          ],
          Flexible(child: labelWidget),
          if (hasInlineIcon && widget.iconAlignment == IconAlignment.end) ...[
            SizedBox(width: iconTextGap),
            buildIconSlot(iconSz),
          ],
        ],
      );
    } else {
      content = Center(child: buildIconSlot(iconSz));
    }

    // ── Nucleo = ShadButton (budella Shad, variante ghost): hover/press/focus/
    //    keyboard e ring nativi. Colori per stato dal motore CLToneStyle (ghost):
    //    base/hover/press → tono CL preservato 1:1. async/confirm/loading/icon-swap
    //    restano nel wrapper CL. Firma pubblica invariata. ─────────────────────
    Widget button = ShadButton.raw(
      variant: ShadButtonVariant.ghost,
      // enabled=isInteractive → in loading ShadButton toglie hover e attenua.
      enabled: isInteractive,
      onPressed: () => _handleTap(),
      backgroundColor: tBase.bg,
      hoverBackgroundColor: tHover.bg,
      pressedBackgroundColor: tPressed.bg,
      foregroundColor: fgColor,
      hoverForegroundColor: hoverFg,
      pressedForegroundColor: pressedFg,
      height: showText ? minHeight : iconOnlySide,
      width: showText ? null : iconOnlySide,
      padding:
          showText ? EdgeInsets.symmetric(horizontal: padH) : EdgeInsets.zero,
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
