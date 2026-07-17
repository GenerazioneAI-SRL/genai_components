import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
// Budella Shad: nucleo interno del bottone. Solo i simboli usati (show) per non
// inquinare il namespace. Firma pubblica CLOutlineButton invariata.
import 'package:shadcn_ui/shadcn_ui.dart'
    show ShadButton, ShadButtonVariant, ShadDecoration, ShadBorder;
import '../../cl_theme.dart';
import 'cl_async_button_mixin.dart';
import 'cl_compact_action_scope.dart';
import 'cl_loading_spinner.widget.dart';
import '../foundation/cl_pressable.widget.dart';
import '../foundation/cl_tone_style.dart';

class CLOutlineButton extends StatefulWidget {
  final Color color;
  final String text;
  final Function() onTap;
  final BuildContext context;
  final IconAlignment iconAlignment;
  final IconData? iconData;
  final Widget? hugeIcon;
  final double? width;
  final bool needConfirmation;
  final String? confirmationMessage;
  final bool isCompact;

  /// Interno: `true` → tono semantico colorato (primary/success/info/warning/
  /// danger): testo/bordo/hover derivano da [color]. `false` → neutro
  /// (secondary + costruttore raw): testo `primaryText`, bordo `cardBorder`.
  /// Prima [color] non veniva mai letto in `build()` e ogni tono rendeva neutro.
  final bool _colored;

  const CLOutlineButton({
    super.key,
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
    this.isCompact = false,
  }) : _colored = false;

  const CLOutlineButton._colored({
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
    this.isCompact = false,
  }) : _colored = true;

  factory CLOutlineButton.primary({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    bool needConfirmation = false,
    String? confirmationMessage,
    IconData? icon,
    Widget? hugeIcon,
    double? width,
    bool isCompact = false,
  }) {
    return CLOutlineButton._colored(
      text: text,
      color: CLTheme.of(context).primary,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      hugeIcon: hugeIcon,
      width: width,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
      isCompact: isCompact,
    );
  }

  factory CLOutlineButton.secondary({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    bool needConfirmation = false,
    String? confirmationMessage,
    IconData? icon,
    Widget? hugeIcon,
    double? width,
    bool isCompact = false,
  }) {
    return CLOutlineButton(
      text: text,
      color: CLTheme.of(context).secondary,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      hugeIcon: hugeIcon,
      width: width,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
      isCompact: isCompact,
    );
  }

  factory CLOutlineButton.success({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    bool needConfirmation = false,
    String? confirmationMessage,
    IconData? icon,
    Widget? hugeIcon,
    double? width,
    bool isCompact = false,
  }) {
    return CLOutlineButton._colored(
      text: text,
      color: CLTheme.of(context).success,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      hugeIcon: hugeIcon,
      width: width,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
      isCompact: isCompact,
    );
  }

  factory CLOutlineButton.info({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    bool needConfirmation = false,
    String? confirmationMessage,
    IconData? icon,
    Widget? hugeIcon,
    double? width,
    bool isCompact = false,
  }) {
    return CLOutlineButton._colored(
      text: text,
      color: CLTheme.of(context).info,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      hugeIcon: hugeIcon,
      width: width,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
      isCompact: isCompact,
    );
  }

  factory CLOutlineButton.warning({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    bool needConfirmation = false,
    String? confirmationMessage,
    IconData? icon,
    Widget? hugeIcon,
    double? width,
    bool isCompact = false,
  }) {
    return CLOutlineButton._colored(
      text: text,
      color: CLTheme.of(context).warning,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      hugeIcon: hugeIcon,
      width: width,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
      isCompact: isCompact,
    );
  }

  factory CLOutlineButton.danger({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    bool needConfirmation = false,
    String? confirmationMessage,
    IconData? icon,
    Widget? hugeIcon,
    double? width,
    bool isCompact = false,
  }) {
    return CLOutlineButton._colored(
      text: text,
      color: CLTheme.of(context).danger,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      hugeIcon: hugeIcon,
      width: width,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
      isCompact: isCompact,
    );
  }

  @override
  State<CLOutlineButton> createState() => _CLOutlineButtonState();
}

class _CLOutlineButtonState extends State<CLOutlineButton> with AsyncButtonMixin {
  Future<void> _handleTap() async {
    await handleAsyncTap(
      onTap: widget.onTap,
      needConfirmation: widget.needConfirmation,
      confirmationMessage: widget.confirmationMessage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final isMobile = !ResponsiveBreakpoints.of(context).isDesktop;
    final forceIconOnly = CLCompactActionScope.iconOnlyOf(context) &&
        (widget.iconData != null || widget.hugeIcon != null) &&
        widget.width == null;
    final showText = widget.text.isNotEmpty && !forceIconOnly;
    final isLoading = loading;
    final isInteractive = !isLoading;

    final padH = widget.isCompact ? theme.gapMd : theme.gapLg;
    final iconSz = widget.isCompact ? theme.iconSizeCompact - 2 : theme.iconSizeCompact;
    final btnH = widget.isCompact ? theme.buttonHeightCompact : theme.buttonHeightDefault;
    final iconOnlySide = btnH;
    final radius = forceIconOnly ? iconOnlySide / 2 : theme.radiusControl;

    // fg = tono nel testo/icona (per outline è costante rispetto allo stato).
    final fgColor = CLToneStyle.resolve(theme,
            color: widget.color,
            variant: CLVariant.outline,
            colored: widget._colored)
        .fg;
    final labelStyle = theme.bodyText.copyWith(color: fgColor, fontWeight: FontWeight.w500);
    final hasInlineIcon = widget.iconData != null || widget.hugeIcon != null || isLoading;

    Widget buildIconSlot(double size) {
      final iconChild = widget.hugeIcon ??
          (widget.iconData != null
              ? Icon(widget.iconData, color: fgColor, size: size)
              : SizedBox(width: size, height: size));
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: isLoading
            ? SizedBox(
                key: const ValueKey('spinner'),
                width: size,
                height: size,
                child: CLLoadingSpinner(size: size, color: fgColor))
            : KeyedSubtree(key: const ValueKey('icon'), child: iconChild),
      );
    }

    Widget content;
    if (showText) {
      content = Row(
        mainAxisSize: widget.width != null ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (hasInlineIcon && widget.iconAlignment == IconAlignment.start) ...[
            buildIconSlot(iconSz),
            SizedBox(width: theme.gapSm),
          ],
          Flexible(
            child: Text(widget.text,
                style: labelStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center),
          ),
          if (hasInlineIcon && widget.iconAlignment == IconAlignment.end) ...[
            SizedBox(width: theme.gapSm),
            buildIconSlot(iconSz),
          ],
        ],
      );
    } else {
      content = Center(child: buildIconSlot(iconSz));
    }

    final needsExplicitLabel = !showText && widget.text.isNotEmpty;
    final Widget semanticContent =
        needsExplicitLabel ? ExcludeSemantics(child: content) : content;

    // ── Nucleo = ShadButton (budella Shad): hover/press/focus/keyboard e ring
    //    (da ShadTheme = theme.ring) nativi. I colori per stato restano dal
    //    motore CLToneStyle (variante outline): base/hover/press passati a
    //    ShadButton → tono CL preservato 1:1. Per outline il bg è neutro
    //    (trasparente → accent su hover/press) e il tono vive solo in fg/bordo.
    //    Il bordo è SEMPRE presente (grigio `cardBorder`) via ShadDecoration.
    //    async/confirm/loading/icon-swap restano nel wrapper CL. Firma
    //    pubblica invariata. ────────────────────────────────────────────────
    final CLToneColors tBase = CLToneStyle.resolve(theme,
        color: widget.color, variant: CLVariant.outline, colored: widget._colored);
    final CLToneColors tHover = CLToneStyle.resolve(theme,
        color: widget.color,
        variant: CLVariant.outline,
        colored: widget._colored,
        state: const CLPressableState(hovered: true));
    final CLToneColors tPressed = CLToneStyle.resolve(theme,
        color: widget.color,
        variant: CLVariant.outline,
        colored: widget._colored,
        state: const CLPressableState(pressed: true));
    final Color borderColor = tBase.border ?? theme.cardBorder;

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
      height: showText ? btnH : iconOnlySide,
      width: showText ? null : iconOnlySide,
      padding:
          showText ? EdgeInsets.symmetric(horizontal: padH) : EdgeInsets.zero,
      mainAxisAlignment: MainAxisAlignment.center,
      decoration: ShadDecoration(
        border: ShadBorder.all(
          color: borderColor,
          width: 1,
          radius: BorderRadius.circular(radius),
        ),
      ),
      child: semanticContent,
    );

    // minWidth 64 (desktop) per i bottoni con testo, come prima.
    if (showText && !isMobile) {
      button = ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 64), child: button);
    }

    if (widget.width != null) {
      button = SizedBox(width: widget.width, child: button);
    }

    // a11y: nome esplicito quando il contenuto è ExcludeSemantics (icon-only).
    if (needsExplicitLabel) {
      button = Semantics(
          label: widget.text,
          button: true,
          enabled: isInteractive,
          child: button);
    }

    return button;
  }
}
