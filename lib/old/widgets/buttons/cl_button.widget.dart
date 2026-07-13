import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../cl_theme.dart';
import 'cl_async_button_mixin.dart';
import 'cl_compact_action_scope.dart';
import 'cl_loading_spinner.widget.dart';
import '../foundation/cl_pressable.widget.dart';
import '../foundation/cl_tone_style.dart';
import '../foundation/cl_focus_ring.dart';

// ── Durate micro-interazione ────────────────────────────────────────
const Duration _colorDuration = Duration(milliseconds: 150);
const Duration _iconSwapDuration = Duration(milliseconds: 180);
const Duration _opacityDuration = Duration(milliseconds: 150);

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

  /// Override del raggio di angolo. Se `null` usa `theme.radiusControl` (12).
  final double? borderRadius;

  /// Ombra esterna opzionale. Se `null` il bottone resta piatto (default DS).
  final List<BoxShadow>? boxShadow;

  /// Bordo opzionale. Se `null` nessun bordo (focus ring a parte).
  final BoxBorder? border;

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
    this.boxShadow,
    this.border,
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
    List<BoxShadow>? boxShadow,
    BoxBorder? border,
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
        boxShadow: boxShadow,
        border: border,
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
    List<BoxShadow>? boxShadow,
    BoxBorder? border,
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
        boxShadow: boxShadow,
        border: border,
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
    List<BoxShadow>? boxShadow,
    BoxBorder? border,
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
        boxShadow: boxShadow,
        border: border,
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
    List<BoxShadow>? boxShadow,
    BoxBorder? border,
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
        boxShadow: boxShadow,
        border: border,
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
    List<BoxShadow>? boxShadow,
    BoxBorder? border,
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
        boxShadow: boxShadow,
        border: border,
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
    List<BoxShadow>? boxShadow,
    BoxBorder? border,
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
        boxShadow: boxShadow,
        border: border,
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
    List<BoxShadow>? boxShadow,
    BoxBorder? border,
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
      boxShadow: boxShadow,
      border: border,
    );
  }

  @override
  State<CLButton> createState() => _CLButtonState();
}

class _CLButtonState extends State<CLButton> with AsyncButtonMixin {
  // Interazione + stato delegati a CLPressable (foundation): niente hand-roll
  // di focus/hover/press qui. Colori per stato da CLToneStyle.

  Future<void> _handleTap() async {
    await handleAsyncTap(
      onTap: widget.onTap,
      needConfirmation: widget.needConfirmation,
      confirmationMessage: widget.confirmationMessage,
    );
  }

  void _fireHaptic() => HapticFeedback.selectionClick();

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final isMobile = !ResponsiveBreakpoints.of(context).isDesktop;
    final forceIconOnly = CLCompactActionScope.iconOnlyOf(context) &&
        (widget.iconData != null || widget.hugeIcon != null) &&
        !widget.fullWidth &&
        widget.width == null;
    final showText = widget.text.isNotEmpty && !forceIconOnly;
    final isLoading = widget.loading ?? loading;
    final isInteractive = widget.enabled && !isLoading;

    // ── Colori (da CLToneStyle, variante solid: hover/press 0.08/0.16,
    // fg per luminanza). Unico posto della matematica chrome. ──────────
    final bgColor = widget.backgroundColor ?? theme.primary;
    final fgColor =
        CLToneStyle.resolve(theme, color: bgColor, variant: CLVariant.solid).fg;

    // ── Padding orizzontale: gapMd (12) compact, gapLg (16) default. Vertical
    // 0 — l'altezza è governata da minHeight per garantire 32/40/48 esatti.
    final padH = widget.isCompact ? theme.gapMd : theme.gapLg;
    final iconSz = widget.iconSize ?? (widget.isCompact ? theme.iconSizeCompact - 2 : theme.iconSizeCompact);

    // Altezze fisse da design tokens: 32 compact, 40 default. Niente +/- mobile.
    final minHeight = widget.isCompact ? theme.buttonHeightCompact : theme.buttonHeightDefault;
    final iconOnlySide = minHeight;
    final radius = forceIconOnly ? iconOnlySide / 2 : (widget.borderRadius ?? theme.radiusControl);

    // ── Slot icona ↔ spinner ─────────────────────────────────────────
    Widget buildIconSlot(double size) {
      final iconChild = widget.hugeIcon ??
          (widget.iconData != null
              ? Icon(widget.iconData, color: widget.iconColor ?? fgColor, size: size)
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
    // bodyText (Inter 14 w400) + w500 (Medium, +100). NO SemiBold.
    final labelStyle = widget.textStyle ??
        theme.bodyText.copyWith(
          color: fgColor,
          fontWeight: FontWeight.w500,
        );

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
      content =
          Center(child: buildIconSlot(widget.iconSize ?? (widget.isCompact ? theme.iconSizeCompact : theme.gapXl)));
    }

    // ── Vincoli dimensione (altezza fissa da token) ──────────────────
    final BoxConstraints constraints = showText
        ? BoxConstraints(minHeight: minHeight, minWidth: isMobile ? 0 : 64)
        : BoxConstraints(minWidth: iconOnlySide, minHeight: iconOnlySide);

    // ── Label accessibile ────────────────────────────────────────────
    // Esplicita quando: override manuale, oppure testo nascosto (icon-only)
    // per non lasciare il bottone senza nome per gli screen reader.
    final needsExplicitLabel =
        widget.semanticLabel != null || widget.tooltip != null || !showText;
    final a11yLabel = widget.semanticLabel ?? widget.tooltip ?? widget.text;
    final Widget semanticContent =
        needsExplicitLabel ? ExcludeSemantics(child: content) : content;

    // ── Interazione: CLPressable (foundation) — hover/press/focus,
    // keyboard (Enter/Space) e semantica bottone. Colori per stato dal
    // motore CLToneStyle. ──────────────────────────────────────────────
    Widget button = CLPressable(
      enabled: isInteractive,
      onTap: _handleTap,
      onTapDown: widget.haptic ? _fireHaptic : null,
      semanticLabel:
          needsExplicitLabel && a11yLabel.isNotEmpty ? a11yLabel : null,
      builder: (context, state) {
        final colors = CLToneStyle.resolve(
          theme,
          color: bgColor,
          variant: CLVariant.solid,
          state: state,
        );

        Widget surface = AnimatedContainer(
          duration: _colorDuration,
          curve: Curves.easeOut,
          padding:
              showText ? EdgeInsets.symmetric(horizontal: padH) : EdgeInsets.zero,
          constraints: constraints,
          decoration: BoxDecoration(
            color: colors.bg,
            borderRadius: BorderRadius.circular(radius),
            border: widget.border,
            boxShadow: widget.boxShadow,
          ),
          child: semanticContent,
        );

        // Focus ring shadcn: anello verso l'esterno con `theme.ring`, fuori dal
        // layout → nessun salto. Solo su focus da tastiera (traversal).
        // CustomPaint sempre presente (painter null off-focus) → albero stabile.
        surface = CustomPaint(
          foregroundPainter: state.focused
              ? CLFocusRingPainter(color: theme.ring, radius: radius)
              : null,
          child: surface,
        );
        return surface;
      },
    );

    // ── Width (fullWidth ha precedenza su width) ─────────────────────
    if (widget.fullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    } else if (widget.width != null) {
      button = SizedBox(width: widget.width, child: button);
    }

    // ── Disabled: fade opacità ───────────────────────────────────────
    button = AnimatedOpacity(
      opacity: widget.enabled ? 1.0 : theme.opacityDisabled,
      duration: _opacityDuration,
      child: button,
    );

    return button;
  }
}

