import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import 'cl_confirm_dialog.dart';

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
  });

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
    return CLGhostButton(
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
    return CLGhostButton(
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
    return CLGhostButton(
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
    return CLGhostButton(
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
    return CLGhostButton(
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

class _CLGhostButtonState extends State<CLGhostButton> {
  bool loading = false;

  Future<void> _handleTap() async {
    if (loading) return;
    if (widget.needConfirmation) {
      await showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return Dialog(
            child: ConfirmationDialog(
              confirmationMessage: widget.confirmationMessage,
              onTap: () async {
                if (isAsync(widget.onTap)) {
                  if (mounted) setState(() => loading = true);
                  await widget.onTap();
                  if (mounted) setState(() => loading = false);
                } else {
                  widget.onTap();
                }
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              },
            ),
          );
        },
      );
    } else {
      if (isAsync(widget.onTap)) {
        if (mounted) setState(() => loading = true);
        await widget.onTap();
        if (mounted) setState(() => loading = false);
      } else {
        widget.onTap();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = !ResponsiveBreakpoints.of(context).isDesktop;
    final hPad = widget.isCompact
        ? Sizes.padding * 0.5
        : isMobile
            ? Sizes.padding * 0.6
            : Sizes.padding * 0.75;
    final vPad = widget.isCompact
        ? Sizes.padding * 0.4
        : isMobile
            ? Sizes.padding * 0.5
            : Sizes.padding * 0.6;
    final fontSize = isMobile ? 13.0 : 14.0;
    final iconSz = isMobile ? Sizes.small * 0.9 : Sizes.small;

    return SizedBox(
      width: widget.width,
      child: widget.text.isNotEmpty
          ? TextButton.icon(
              iconAlignment: widget.iconAlignment,
              icon: loading
                  ? SizedBox(width: iconSz, height: iconSz, child: CircularProgressIndicator(color: widget.color, strokeWidth: 2))
                  : widget.hugeIcon ??
                      (widget.iconData != null
                          ? Icon(widget.iconData, color: widget.color, size: iconSz)
                          : null),
              onPressed: _handleTap,
              style: widget.buttonStyle ??
                  TextButton.styleFrom(
                    foregroundColor: widget.foregroundColor ?? widget.color,
                    overlayColor: CLTheme.of(context).accent,
                    padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius)),
                    elevation: 0,
                    minimumSize: Size(isMobile ? 0 : 48, isMobile ? 32 : 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    iconSize: iconSz,
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
                overlayColor: WidgetStateProperty.all(widget.color.withValues(alpha: 0.08)),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius))),
                minimumSize: WidgetStateProperty.all(Size(isMobile ? 36 : 36, isMobile ? 36 : 36)),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: loading
                  ? SizedBox(width: iconSz, height: iconSz, child: CircularProgressIndicator(color: widget.color, strokeWidth: 2))
                  : widget.hugeIcon ??
                      (widget.iconData != null
                          ? Icon(widget.iconData, color: widget.color, size: iconSz)
                          : const SizedBox.shrink()),
            ),
    );
  }

  bool isAsync(Function function) {
    return function is Future Function();
  }
}
