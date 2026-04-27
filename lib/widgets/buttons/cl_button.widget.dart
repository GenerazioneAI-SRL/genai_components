import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import 'cl_async_button_mixin.dart';
import 'cl_loading_spinner.widget.dart';

// ── Costanti micro-interazione ──────────────────────────────────────
const double _pressScale = 0.97;
const double _pressYOffset = 1.0;
const Duration _pressDuration = Duration(milliseconds: 110);
const Duration _hoverDuration = Duration(milliseconds: 140);
const Duration _iconSwapDuration = Duration(milliseconds: 180);

class CLButton extends StatefulWidget {
  final Color? backgroundColor;
  final String text;
  final Function() onTap;
  final BuildContext context;
  final IconAlignment iconAlignment;
  final IconData? iconData;
  final double? width;
  final bool needConfirmation;
  final double? iconSize;
  final String? confirmationMessage;
  final TextStyle? textStyle;
  final Color? iconColor;
  final Widget? hugeIcon;
  final bool isCompact;

  /// Se `false`, disabilita input e applica opacità ridotta.
  final bool enabled;

  /// Tooltip mostrato al hover/long-press. Utile soprattutto per icon-only.
  final String? tooltip;

  /// Override esterno dello stato di loading. Se `null`, usa lo stato interno del mixin async.
  final bool? loading;

  /// Label semantica per screen reader.
  final String? semanticLabel;

  /// Espande il bottone alla larghezza disponibile del parent (zucchero per `width: double.infinity`).
  final bool fullWidth;

  /// Se `true` (default), emette un `HapticFeedback.selectionClick()` al press (iOS/Android).
  final bool haptic;

  /// Override del raggio di angolo. Se `null` usa `Sizes.radiusControl` (6, scala shadcn).
  final double? borderRadius;

  const CLButton({
    super.key,
    this.backgroundColor,
    required this.text,
    required this.onTap,
    required this.context,
    required this.iconAlignment,
    this.iconData,
    this.needConfirmation = false,
    this.confirmationMessage,
    this.iconSize,
    this.width,
    this.textStyle,
    this.iconColor,
    this.hugeIcon,
    this.isCompact = false,
    this.enabled = true,
    this.tooltip,
    this.loading,
    this.semanticLabel,
    this.fullWidth = false,
    this.haptic = true,
    this.borderRadius,
  });

  factory CLButton.primary({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    IconData? icon,
    bool needConfirmation = false,
    String? confirmationMessage,
    double? iconSize,
    double? width,
    TextStyle? textStyle,
    Color? iconColor,
    Widget? hugeIcon,
    bool isCompact = false,
    bool enabled = true,
    String? tooltip,
    bool? loading,
    String? semanticLabel,
    bool fullWidth = false,
    bool haptic = true,
    double? borderRadius,
  }) =>
      _fromColor(
        context: context,
        color: CLTheme.of(context).primary,
        text: text,
        onTap: onTap,
        iconAlignment: iconAlignment,
        icon: icon,
        needConfirmation: needConfirmation,
        confirmationMessage: confirmationMessage,
        iconSize: iconSize,
        width: width,
        textStyle: textStyle,
        iconColor: iconColor,
        hugeIcon: hugeIcon,
        isCompact: isCompact,
        enabled: enabled,
        tooltip: tooltip,
        loading: loading,
        semanticLabel: semanticLabel,
        fullWidth: fullWidth,
        haptic: haptic,
        borderRadius: borderRadius,
      );

  factory CLButton.secondary({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    IconData? icon,
    bool needConfirmation = false,
    String? confirmationMessage,
    double? iconSize,
    double? width,
    TextStyle? textStyle,
    Color? iconColor,
    Widget? hugeIcon,
    bool isCompact = false,
    bool enabled = true,
    String? tooltip,
    bool? loading,
    String? semanticLabel,
    bool fullWidth = false,
    bool haptic = true,
    double? borderRadius,
  }) =>
      _fromColor(
        context: context,
        color: CLTheme.of(context).secondary,
        text: text,
        onTap: onTap,
        iconAlignment: iconAlignment,
        icon: icon,
        needConfirmation: needConfirmation,
        confirmationMessage: confirmationMessage,
        iconSize: iconSize,
        width: width,
        textStyle: textStyle,
        iconColor: iconColor,
        hugeIcon: hugeIcon,
        isCompact: isCompact,
        enabled: enabled,
        tooltip: tooltip,
        loading: loading,
        semanticLabel: semanticLabel,
        fullWidth: fullWidth,
        haptic: haptic,
        borderRadius: borderRadius,
      );

  factory CLButton.success({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    IconData? icon,
    double? iconSize,
    bool needConfirmation = false,
    String? confirmationMessage,
    double? width,
    TextStyle? textStyle,
    Color? iconColor,
    Widget? hugeIcon,
    bool isCompact = false,
    bool enabled = true,
    String? tooltip,
    bool? loading,
    String? semanticLabel,
    bool fullWidth = false,
    bool haptic = true,
    double? borderRadius,
  }) =>
      _fromColor(
        context: context,
        color: CLTheme.of(context).success,
        text: text,
        onTap: onTap,
        iconAlignment: iconAlignment,
        icon: icon,
        needConfirmation: needConfirmation,
        confirmationMessage: confirmationMessage,
        iconSize: iconSize,
        width: width,
        textStyle: textStyle,
        iconColor: iconColor,
        hugeIcon: hugeIcon,
        isCompact: isCompact,
        enabled: enabled,
        tooltip: tooltip,
        loading: loading,
        semanticLabel: semanticLabel,
        fullWidth: fullWidth,
        haptic: haptic,
        borderRadius: borderRadius,
      );

  factory CLButton.info({
    required String text,
    required Function() onTap,
    required BuildContext context,
    double? iconSize,
    IconAlignment iconAlignment = IconAlignment.start,
    IconData? icon,
    bool needConfirmation = false,
    String? confirmationMessage,
    double? width,
    TextStyle? textStyle,
    Color? iconColor,
    Widget? hugeIcon,
    bool isCompact = false,
    bool enabled = true,
    String? tooltip,
    bool? loading,
    String? semanticLabel,
    bool fullWidth = false,
    bool haptic = true,
    double? borderRadius,
  }) =>
      _fromColor(
        context: context,
        color: CLTheme.of(context).info,
        text: text,
        onTap: onTap,
        iconAlignment: iconAlignment,
        icon: icon,
        needConfirmation: needConfirmation,
        confirmationMessage: confirmationMessage,
        iconSize: iconSize,
        width: width,
        textStyle: textStyle,
        iconColor: iconColor,
        hugeIcon: hugeIcon,
        isCompact: isCompact,
        enabled: enabled,
        tooltip: tooltip,
        loading: loading,
        semanticLabel: semanticLabel,
        fullWidth: fullWidth,
        haptic: haptic,
        borderRadius: borderRadius,
      );

  factory CLButton.warning({
    required String text,
    required Function() onTap,
    required BuildContext context,
    double? iconSize,
    IconAlignment iconAlignment = IconAlignment.start,
    IconData? icon,
    bool needConfirmation = false,
    String? confirmationMessage,
    double? width,
    TextStyle? textStyle,
    Color? iconColor,
    Widget? hugeIcon,
    bool isCompact = false,
    bool enabled = true,
    String? tooltip,
    bool? loading,
    String? semanticLabel,
    bool fullWidth = false,
    bool haptic = true,
    double? borderRadius,
  }) =>
      _fromColor(
        context: context,
        color: CLTheme.of(context).warning,
        text: text,
        onTap: onTap,
        iconAlignment: iconAlignment,
        icon: icon,
        needConfirmation: needConfirmation,
        confirmationMessage: confirmationMessage,
        iconSize: iconSize,
        width: width,
        textStyle: textStyle,
        iconColor: iconColor,
        hugeIcon: hugeIcon,
        isCompact: isCompact,
        enabled: enabled,
        tooltip: tooltip,
        loading: loading,
        semanticLabel: semanticLabel,
        fullWidth: fullWidth,
        haptic: haptic,
        borderRadius: borderRadius,
      );

  factory CLButton.danger({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    IconData? icon,
    double? iconSize,
    bool needConfirmation = false,
    String? confirmationMessage,
    double? width,
    TextStyle? textStyle,
    Color? iconColor,
    Widget? hugeIcon,
    bool isCompact = false,
    bool enabled = true,
    String? tooltip,
    bool? loading,
    String? semanticLabel,
    bool fullWidth = false,
    bool haptic = true,
    double? borderRadius,
  }) =>
      _fromColor(
        context: context,
        color: CLTheme.of(context).danger,
        text: text,
        onTap: onTap,
        iconAlignment: iconAlignment,
        icon: icon,
        needConfirmation: needConfirmation,
        confirmationMessage: confirmationMessage,
        iconSize: iconSize,
        width: width,
        textStyle: textStyle,
        iconColor: iconColor,
        hugeIcon: hugeIcon,
        isCompact: isCompact,
        enabled: enabled,
        tooltip: tooltip,
        loading: loading,
        semanticLabel: semanticLabel,
        fullWidth: fullWidth,
        haptic: haptic,
        borderRadius: borderRadius,
      );

  static CLButton _fromColor({
    required BuildContext context,
    required Color color,
    required String text,
    required Function() onTap,
    required IconAlignment iconAlignment,
    IconData? icon,
    bool needConfirmation = false,
    String? confirmationMessage,
    double? iconSize,
    double? width,
    TextStyle? textStyle,
    Color? iconColor,
    Widget? hugeIcon,
    bool isCompact = false,
    bool enabled = true,
    String? tooltip,
    bool? loading,
    String? semanticLabel,
    bool fullWidth = false,
    bool haptic = true,
    double? borderRadius,
  }) {
    return CLButton(
      text: text,
      backgroundColor: color,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      needConfirmation: needConfirmation,
      confirmationMessage: confirmationMessage,
      iconSize: iconSize,
      width: width,
      textStyle: textStyle,
      iconColor: iconColor,
      hugeIcon: hugeIcon,
      isCompact: isCompact,
      enabled: enabled,
      tooltip: tooltip,
      loading: loading,
      semanticLabel: semanticLabel,
      fullWidth: fullWidth,
      haptic: haptic,
      borderRadius: borderRadius,
    );
  }

  @override
  State<CLButton> createState() => _CLButtonState();
}

// Padding orizzontale: gapMd (12) compact, gapLg (16) default. Vertical 0 — l'altezza
// è governata da minHeight (CLSizes.buttonHeight*) per garantire 32/40/48 esatti.
({double h, double v}) _paddingFor({required bool isMobile, required bool isCompact}) {
  if (isCompact) return (h: CLSizes.gapMd, v: 0.0);
  return (h: CLSizes.gapLg, v: 0.0);
}

class _CLButtonState extends State<CLButton> with AsyncButtonMixin {
  // Stato "umano" tracciato via controller: evitiamo gli overlay Material
  // e animiamo noi scala, offset e sfondo per un feedback tattile.
  late final WidgetStatesController _statesController;
  bool _wasPressed = false;

  @override
  void initState() {
    super.initState();
    _statesController = WidgetStatesController();
    _statesController.addListener(_onStatesChanged);
  }

  @override
  void dispose() {
    _statesController.removeListener(_onStatesChanged);
    _statesController.dispose();
    super.dispose();
  }

  void _onStatesChanged() {
    // Gli aggiornamenti visivi (hover/press/focus) passano attraverso
    // `ValueListenableBuilder` in `build`: nessun `setState` qui, altrimenti
    // si rischia "setState during build" quando Material aggiorna il
    // controller all'interno del suo `build` (es. onPressed che diventa null).
    if (!mounted) return;
    final nowPressed = _statesController.value.contains(WidgetState.pressed);
    if (nowPressed && !_wasPressed && widget.haptic && widget.enabled) {
      HapticFeedback.selectionClick();
    }
    _wasPressed = nowPressed;
  }

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
    final isLoading = widget.loading ?? loading;
    final isInteractive = widget.enabled && !isLoading;

    // ── Colori ────────────────────────────────────────────────────────
    final bgColor = widget.backgroundColor ?? theme.primary;
    final isLightBg = bgColor.computeLuminance() > 0.5;
    final fgColor = isLightBg ? Colors.black : Colors.white;

    // Hover/press: alpha-blend uniforme nero 0.08/0.16 (no glow, no colored shadow).
    final hoverBg = Color.lerp(bgColor, Colors.black, 0.08)!;
    final pressedBg = Color.lerp(bgColor, Colors.black, 0.16)!;

    // ── Padding (tabella pura, helper esterno) ───────────────────────
    final pad = _paddingFor(isMobile: isMobile, isCompact: widget.isCompact);
    final iconSz = widget.iconSize ?? (widget.isCompact ? CLSizes.iconSizeCompact - 2 : CLSizes.iconSizeCompact);

    // Altezze fisse da design tokens: 32 compact, 40 default. Niente +/- mobile.
    final minHeight = widget.isCompact ? CLSizes.buttonHeightCompact : CLSizes.buttonHeightDefault;
    final iconOnlySide = minHeight;
    final radius = widget.borderRadius ?? CLSizes.radiusControl;

    // ── Slot icona ↔ spinner ─────────────────────────────────────────
    Widget buildIconSlot(double size) {
      final iconChild = widget.hugeIcon ??
          (widget.iconData != null ? Icon(widget.iconData, color: widget.iconColor ?? fgColor, size: size) : SizedBox(width: size, height: size));
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
    // bodyText (Inter 14 w400) + w500 (Medium, +100). NO SemiBold.
    final labelStyle = widget.textStyle ??
        theme.bodyText.copyWith(
          color: fgColor,
          fontWeight: FontWeight.w500,
        );

    final hasInlineIcon = widget.iconData != null || widget.hugeIcon != null || isLoading;
    final iconTextGap = CLSizes.gapSm;

    Widget content;
    if (widget.text.isNotEmpty) {
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
        mainAxisSize: (widget.width != null || widget.fullWidth) ? MainAxisSize.max : MainAxisSize.min,
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
      content = Center(child: buildIconSlot(widget.iconSize ?? Sizes.medium));
    }

    // ── Superficie animata (bg + padding insieme: niente gap trasparente) ─
    final BoxConstraints constraints = widget.text.isNotEmpty
        ? BoxConstraints(minHeight: minHeight, minWidth: isMobile ? 0 : 64)
        : BoxConstraints(minWidth: iconOnlySide, minHeight: iconOnlySide);

    // La surface animata (bg, border focus, press scale+offset) reagisce agli
    // stati tramite UN SOLO ValueListenableBuilder posto COME DESCENDANT
    // dell'ElevatedButton. Se fosse ancestor, quando Material aggiorna il
    // controller in `didUpdateWidget` spareremmo "setState during build" su
    // un ancestor già processato nel frame corrente.
    final surface = ValueListenableBuilder<Set<WidgetState>>(
      valueListenable: _statesController,
      builder: (context, states, stableChild) {
        final isHovered = states.contains(WidgetState.hovered);
        final isPressed = states.contains(WidgetState.pressed);
        final isFocused = states.contains(WidgetState.focused);
        final currentBg = isPressed
            ? pressedBg
            : isHovered
                ? hoverBg
                : bgColor;
        final transform = Matrix4.identity()
          ..translateByDouble(0.0, isPressed ? _pressYOffset : 0.0, 0.0, 1.0)
          ..scaleByDouble(isPressed ? _pressScale : 1.0, isPressed ? _pressScale : 1.0, 1.0, 1.0);

        return AnimatedContainer(
          duration: _pressDuration,
          curve: Curves.easeOut,
          transform: transform,
          transformAlignment: Alignment.center,
          child: AnimatedContainer(
            duration: _hoverDuration,
            curve: Curves.easeOut,
            padding: widget.text.isNotEmpty ? EdgeInsets.symmetric(horizontal: pad.h, vertical: pad.v) : EdgeInsets.zero,
            constraints: constraints,
            decoration: BoxDecoration(
              color: currentBg,
              borderRadius: BorderRadius.circular(radius),
              border: isFocused ? Border.all(color: fgColor.withValues(alpha: 0.6), width: 2) : null,
            ),
            child: stableChild,
          ),
        );
      },
      child: content,
    );

    // ── Style Material "invisibile" (solo tap/focus/semantics, niente chrome) ─
    final buttonStyle = ButtonStyle(
      padding: WidgetStateProperty.all(EdgeInsets.zero),
      backgroundColor: WidgetStateProperty.all(Colors.transparent),
      foregroundColor: WidgetStateProperty.all(fgColor),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      shadowColor: WidgetStateProperty.all(Colors.transparent),
      surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
      elevation: WidgetStateProperty.all(0),
      splashFactory: NoSplash.splashFactory,
      animationDuration: Duration.zero,
      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius))),
      side: WidgetStateProperty.all(BorderSide.none),
      minimumSize: WidgetStateProperty.all(Size.zero),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      iconSize: WidgetStateProperty.all(iconSz),
    );

    Widget button = ElevatedButton(
      statesController: _statesController,
      onPressed: isInteractive ? _handleTap : null,
      style: buttonStyle,
      child: surface,
    );

    // ── Width (fullWidth ha precedenza su width null) ────────────────
    if (widget.fullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    } else if (widget.width != null) {
      button = SizedBox(width: widget.width, child: button);
    }

    // ── Disabled: fade opacità ───────────────────────────────────────
    button = AnimatedOpacity(
      opacity: widget.enabled ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 150),
      child: button,
    );

    if (widget.tooltip != null && widget.tooltip!.isNotEmpty) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }

    if (widget.semanticLabel != null && widget.semanticLabel!.isNotEmpty) {
      button = Semantics(
        button: true,
        enabled: isInteractive,
        label: widget.semanticLabel,
        child: ExcludeSemantics(child: button),
      );
    }

    return button;
  }
}
