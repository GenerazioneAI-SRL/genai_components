import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import 'cl_async_button_mixin.dart';
import 'cl_loading_spinner.widget.dart';

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
  }) {
    return CLButton(
      text: text,
      backgroundColor: CLTheme.of(context).primary,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      width: width,
      iconSize: iconSize,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
      textStyle: textStyle,
      iconColor: iconColor,
      hugeIcon: hugeIcon,
      isCompact: isCompact,
    );
  }

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
  }) {
    return CLButton(
      text: text,
      backgroundColor: CLTheme.of(context).secondary,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
      iconSize: iconSize,
      width: width,
      textStyle: textStyle,
      iconColor: iconColor,
      hugeIcon: hugeIcon,
      isCompact: isCompact,
    );
  }

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
  }) {
    return CLButton(
      text: text,
      backgroundColor: CLTheme.of(context).success,
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
    );
  }

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
  }) {
    return CLButton(
      text: text,
      backgroundColor: CLTheme.of(context).info,
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
    );
  }

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
  }) {
    return CLButton(
      text: text,
      backgroundColor: CLTheme.of(context).warning,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconSize: iconSize,
      iconData: icon,
      needConfirmation: needConfirmation,
      confirmationMessage: confirmationMessage,
      width: width,
      textStyle: textStyle,
      iconColor: iconColor,
      hugeIcon: hugeIcon,
      isCompact: isCompact,
    );
  }

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
  }) {
    return CLButton(
      text: text,
      backgroundColor: CLTheme.of(context).danger,
      onTap: onTap,
      context: context,
      iconAlignment: iconAlignment,
      iconData: icon,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
      width: width,
      iconSize: iconSize,
      textStyle: textStyle,
      iconColor: iconColor,
      hugeIcon: hugeIcon,
      isCompact: isCompact,
    );
  }

  @override
  State<CLButton> createState() => _CLButtonState();
}

class _CLButtonState extends State<CLButton> with AsyncButtonMixin {
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
    final hPad = widget.isCompact
        ? Sizes.padding * 0.6
        : isMobile
            ? Sizes.padding * 0.75
            : Sizes.padding;
    final vPad = widget.isCompact
        ? Sizes.padding * 0.5
        : isMobile
            ? Sizes.padding * 0.65
            : Sizes.padding * 0.8;
    final fontSize = isMobile ? 13.0 : 14.0;
    final iconSz = widget.iconSize ?? (isMobile ? Sizes.small * 0.9 : Sizes.small);
    final bgColor = widget.backgroundColor ?? CLTheme.of(context).primary;

    // Calcola dinamicamente il colore dello spinner based su luminanza
    final spinnerColor = bgColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    // Hover/pressed via background change (DS): niente overlay splash.
    final hoverBg = bgColor.computeLuminance() > 0.5
        ? Color.lerp(bgColor, Colors.black, 0.06)!
        : Color.lerp(bgColor, Colors.white, 0.08)!;
    final pressedBg = bgColor.computeLuminance() > 0.5
        ? Color.lerp(bgColor, Colors.black, 0.12)!
        : Color.lerp(bgColor, Colors.white, 0.16)!;

    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
      child: SizedBox(
        width: widget.width,
        child: widget.text.isNotEmpty
            ? ElevatedButton.icon(
                iconAlignment: widget.iconAlignment,
                icon: (widget.iconData != null || widget.hugeIcon != null || loading)
                    ? AnimatedCrossFade(
                        alignment: Alignment.center,
                        firstChild: widget.hugeIcon ??
                            (widget.iconData != null
                                ? Icon(widget.iconData, color: widget.iconColor ?? Colors.white, size: iconSz)
                                : SizedBox(width: iconSz, height: iconSz)),
                        secondChild: CLLoadingSpinner(size: iconSz, color: spinnerColor),
                        crossFadeState: loading ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 200),
                      )
                    : null,
                onPressed: _handleTap,
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: hPad, vertical: vPad)),
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.pressed)) return pressedBg;
                    if (states.contains(WidgetState.hovered)) return hoverBg;
                    return bgColor;
                  }),
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius))),
                  elevation: WidgetStateProperty.all(0),
                  shadowColor: WidgetStateProperty.all(Colors.transparent),
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  splashFactory: NoSplash.splashFactory,
                  animationDuration: const Duration(milliseconds: 150),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                  minimumSize: WidgetStateProperty.all(Size(isMobile ? 0 : 64, isMobile ? 40 : 44)),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  iconSize: WidgetStateProperty.all(iconSz),
                ),
                label: Text(
                  widget.text,
                  style: widget.textStyle ?? CLTheme.of(context).bodyText.copyWith(color: Colors.white, fontSize: fontSize),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              )
            : IconButton(
                color: bgColor,
                iconSize: widget.iconSize ?? Sizes.medium,
                style: ButtonStyle(
                  elevation: WidgetStateProperty.all(0),
                  shadowColor: WidgetStateProperty.all(Colors.transparent),
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.pressed)) return pressedBg;
                    if (states.contains(WidgetState.hovered)) return hoverBg;
                    return bgColor;
                  }),
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius))),
                  splashFactory: NoSplash.splashFactory,
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                  minimumSize: WidgetStateProperty.all(Size(isMobile ? 36 : 36, isMobile ? 36 : 36)),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: _handleTap,
                icon: AnimatedCrossFade(
                  alignment: Alignment.center,
                  firstChild: widget.hugeIcon ??
                      (widget.iconData != null
                          ? Icon(widget.iconData, color: widget.iconColor ?? Colors.white, size: widget.iconSize ?? Sizes.medium)
                          : SizedBox(width: widget.iconSize ?? Sizes.medium, height: widget.iconSize ?? Sizes.medium)),
                  secondChild: CLLoadingSpinner(
                    size: widget.iconSize ?? Sizes.medium,
                    color: spinnerColor,
                  ),
                  crossFadeState: loading ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
              ),
      ),
    );
  }
}
