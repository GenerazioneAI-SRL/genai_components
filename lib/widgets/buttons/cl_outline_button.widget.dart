import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../cl_theme.dart';
import 'cl_async_button_mixin.dart';
import 'cl_compact_action_scope.dart';
import 'cl_loading_spinner.widget.dart';

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
    final isMobile = !ResponsiveBreakpoints.of(context).isDesktop;
    final theme = CLTheme.of(context);
    final forceIconOnly = CLCompactActionScope.iconOnlyOf(context) &&
        (widget.iconData != null || widget.hugeIcon != null) &&
        widget.width == null;
    final showText = widget.text.isNotEmpty && !forceIconOnly;
    // Padding orizzontale da token; verticale 0 — minimumSize governa l'altezza.
    final hPad = widget.isCompact ? theme.gapMd : theme.gapLg;
    const vPad = 0.0;
    final colored = widget._colored;
    final fgColor = colored ? widget.color : theme.primaryText;
    final iconSz = widget.isCompact ? theme.iconSizeCompact - 2 : theme.iconSizeCompact;
    final btnH = widget.isCompact ? theme.buttonHeightCompact : theme.buttonHeightDefault;
    final spinnerColor = fgColor;
    final hoverBg = colored ? widget.color.withValues(alpha: theme.opacitySoft) : theme.accent;
    final pressedBg =
        colored ? widget.color.withValues(alpha: theme.opacityMuted) : Color.lerp(theme.accent, Colors.black, 0.08)!;
    final defaultBorder =
        colored ? BorderSide(color: widget.color, width: 1.0) : BorderSide(color: theme.cardBorder, width: 1.0);
    final focusBorder = colored ? widget.color : theme.primary;
    final labelStyle = theme.bodyText.copyWith(color: fgColor, fontWeight: FontWeight.w500);

    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
      child: SizedBox(
      width: widget.width,
      child: showText
          ? OutlinedButton.icon(
              iconAlignment: widget.iconAlignment,
               icon: (widget.iconData != null || widget.hugeIcon != null || loading)
                  ? AnimatedCrossFade(
                      alignment: Alignment.center,
                      firstChild: widget.hugeIcon ??
                          (widget.iconData != null
                            ? Icon(widget.iconData, color: fgColor, size: iconSz)
                            : SizedBox(width: iconSz, height: iconSz)),
                      secondChild: CLLoadingSpinner(size: iconSz, color: spinnerColor),
                      crossFadeState: loading ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 200),
                    )
                  : null,
               onPressed: _handleTap,
               style: ButtonStyle(
                 side: WidgetStateProperty.resolveWith((states) {
                   if (states.contains(WidgetState.focused)) {
                     return BorderSide(color: focusBorder, width: 2);
                   }
                   return defaultBorder;
                 }),
                 foregroundColor: WidgetStateProperty.all(fgColor),
                 backgroundColor: WidgetStateProperty.resolveWith((states) {
                   if (states.contains(WidgetState.pressed)) return pressedBg;
                   if (states.contains(WidgetState.hovered)) return hoverBg;
                   return Colors.transparent;
                 }),
                 overlayColor: WidgetStateProperty.all(Colors.transparent),
                 splashFactory: NoSplash.splashFactory,
                 animationDuration: const Duration(milliseconds: 150),
                 padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: hPad, vertical: vPad)),
                 shape: WidgetStateProperty.all(
                   RoundedRectangleBorder(borderRadius: BorderRadius.circular(theme.radiusControl)),
                 ),
                 minimumSize: WidgetStateProperty.all(Size(isMobile ? 0 : 64, btnH)),
                 fixedSize: WidgetStateProperty.all(Size.fromHeight(btnH)),
                 tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                 visualDensity: VisualDensity.standard,
                 iconSize: WidgetStateProperty.all(iconSz),
               ),
              label: Text(
                widget.text,
                style: labelStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            )
          : IconButton(
              onPressed: _handleTap,
              iconSize: iconSz,
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(fgColor),
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.pressed)) return pressedBg;
                  if (states.contains(WidgetState.hovered)) return hoverBg;
                  return Colors.transparent;
                }),
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(forceIconOnly ? btnH / 2 : theme.radiusControl),
                  side: defaultBorder,
                )),
                minimumSize: WidgetStateProperty.all(Size(btnH, btnH)),
                fixedSize: WidgetStateProperty.all(Size(btnH, btnH)),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.standard,
              ),
              icon: AnimatedCrossFade(
                firstChild: widget.hugeIcon ??
                    (widget.iconData != null
                      ? Icon(widget.iconData, color: fgColor, size: iconSz)
                      : const SizedBox.shrink()),
                secondChild: CLLoadingSpinner(size: iconSz, color: spinnerColor),
                crossFadeState: loading ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ),
    ));
  }
}
