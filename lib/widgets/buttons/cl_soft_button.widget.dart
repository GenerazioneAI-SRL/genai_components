import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import 'cl_async_button_mixin.dart';
import 'cl_loading_spinner.widget.dart';

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
  });

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
  }) {
    return CLSoftButton(
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
    return CLSoftButton(
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
    return CLSoftButton(
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
    return CLSoftButton(
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
    return CLSoftButton(
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
    final hPad = widget.isCompact ? CLSizes.gapMd : CLSizes.gapLg;
    const vPad = 0.0;
    final theme = CLTheme.of(context);
    final fgColor = theme.primaryText;
    final iconSz = widget.isCompact ? CLSizes.iconSizeCompact - 2 : CLSizes.iconSizeCompact;
    final btnH = widget.isCompact ? CLSizes.buttonHeightCompact : CLSizes.buttonHeightDefault;
    final baseBg = theme.muted;
    final hoverBg = Color.lerp(baseBg, Colors.black, 0.08)!;
    final pressedBg = Color.lerp(baseBg, Colors.black, 0.16)!;
    final focusBorder = theme.primary;
    final labelStyle = theme.bodyText.copyWith(color: fgColor, fontWeight: FontWeight.w500);

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
              icon: (widget.hugeIcon != null || widget.iconData != null || loading)
                  ? AnimatedCrossFade(
                      alignment: Alignment.center,
                      firstChild: widget.hugeIcon != null
                          ? HugeIcon(icon: widget.hugeIcon!, color: fgColor, size: iconSz)
                          : widget.iconData != null
                            ? Icon(widget.iconData, color: fgColor, size: iconSz)
                            : SizedBox(width: iconSz, height: iconSz),
                      secondChild: CLLoadingSpinner(size: iconSz, color: fgColor),
                      crossFadeState: loading ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 200),
                    )
                  : null,
              onPressed: _handleTap,
              style: ButtonStyle(
                shadowColor: WidgetStateProperty.all(Colors.transparent),
                foregroundColor: WidgetStateProperty.all(fgColor),
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.pressed)) return pressedBg;
                  if (states.contains(WidgetState.hovered)) return hoverBg;
                  return baseBg;
                }),
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                splashFactory: NoSplash.splashFactory,
                animationDuration: const Duration(milliseconds: 150),
                textStyle: WidgetStateProperty.all(labelStyle),
                padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: hPad, vertical: vPad)),
                shape: WidgetStateProperty.resolveWith((states) {
                  return RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(CLSizes.radiusControl),
                    side: states.contains(WidgetState.focused)
                        ? BorderSide(color: focusBorder, width: 2)
                        : BorderSide.none,
                  );
                }),
                elevation: WidgetStateProperty.all(0),
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
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.pressed)) return pressedBg;
                  if (states.contains(WidgetState.hovered)) return hoverBg;
                  return baseBg;
                }),
                foregroundColor: WidgetStateProperty.all(fgColor),
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(CLSizes.radiusControl))),
                elevation: WidgetStateProperty.all(0),
                shadowColor: WidgetStateProperty.all(Colors.transparent),
                minimumSize: WidgetStateProperty.all(Size(btnH, btnH)),
                fixedSize: WidgetStateProperty.all(Size(btnH, btnH)),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.standard,
              ),
              icon: AnimatedCrossFade(
                firstChild: widget.hugeIcon != null
                    ? HugeIcon(icon: widget.hugeIcon!, color: fgColor, size: iconSz)
                    : widget.iconData != null
                      ? Icon(widget.iconData, color: fgColor, size: iconSz)
                      : const SizedBox.shrink(),
                secondChild: CLLoadingSpinner(size: iconSz, color: fgColor),
                crossFadeState: loading ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ),
    ));
  }
}
