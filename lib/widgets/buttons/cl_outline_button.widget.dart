import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import 'cl_async_button_mixin.dart';
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
  });

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
    return CLOutlineButton(
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
    return CLOutlineButton(
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
    return CLOutlineButton(
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
    return CLOutlineButton(
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
    return CLOutlineButton(
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
    final iconSz = isMobile ? Sizes.small * 0.9 : Sizes.small;
    final spinnerColor = widget.color;
    final hoverBg = CLTheme.of(context).accent;
    final pressedBg = Color.lerp(hoverBg, widget.color, 0.10)!;
    final focusBorder = CLTheme.of(context).primary;

    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
      child: SizedBox(
      width: widget.width,
      child: widget.text.isNotEmpty
          ? OutlinedButton.icon(
              iconAlignment: widget.iconAlignment,
               icon: (widget.iconData != null || widget.hugeIcon != null || loading)
                  ? AnimatedCrossFade(
                      alignment: Alignment.center,
                      firstChild: widget.hugeIcon ??
                          (widget.iconData != null
                            ? Icon(widget.iconData, color: widget.color, size: iconSz)
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
                   return BorderSide(color: CLTheme.of(context).cardBorder, width: 1.0);
                 }),
                 foregroundColor: WidgetStateProperty.all(widget.color),
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
                   RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius)),
                 ),
                 minimumSize: WidgetStateProperty.all(Size(isMobile ? 0 : 64, isMobile ? 40 : 44)),
                 tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                 iconSize: WidgetStateProperty.all(iconSz),
               ),
              label: Text(
                widget.text,
                style: CLTheme.of(context).bodyText.merge(TextStyle(color: widget.color, fontSize: fontSize)),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            )
          : IconButton(
              onPressed: _handleTap,
              iconSize: iconSz,
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(widget.color),
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.pressed)) return pressedBg;
                  if (states.contains(WidgetState.hovered)) return hoverBg;
                  return Colors.transparent;
                }),
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Sizes.borderRadius),
                  side: BorderSide(color: CLTheme.of(context).cardBorder, width: 1.0),
                )),
                minimumSize: WidgetStateProperty.all(Size(isMobile ? 36 : 36, isMobile ? 36 : 36)),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: AnimatedCrossFade(
                firstChild: widget.hugeIcon ??
                    (widget.iconData != null
                      ? Icon(widget.iconData, color: widget.color, size: iconSz)
                      : const SizedBox.shrink()),
                secondChild: CLLoadingSpinner(size: iconSz, color: spinnerColor),
                crossFadeState: loading ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ),
    ));
  }
}
