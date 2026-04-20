import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import 'cl_confirm_dialog.dart';
import 'cl_loading_spinner.widget.dart';

class CLActionText extends StatefulWidget {
  final Color color;
  final String text;
  final Function() onTap;
  final BuildContext context;
  final IconData? iconData;
  final Widget? hugeIcon;
  final double? width;
  final bool needConfirmation;
  final String? confirmationMessage;
  final Color? foregroundColor;
  final Color? hoverColor;
  final bool enableHover;

  const CLActionText({
    super.key,
    required this.color,
    required this.text,
    required this.onTap,
    required this.context,
    this.iconData,
    this.hugeIcon,
    this.needConfirmation = false,
    this.confirmationMessage,
    this.width,
    this.foregroundColor,
    this.hoverColor,
    this.enableHover = false,
  });

  factory CLActionText.primary({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    bool needConfirmation = false,
    String? confirmationMessage,
    IconData? icon,
    Widget? hugeIcon,
    Color? foregroundColor,
    Color? hoverColor,
    bool enableHover = false,
    double? width,
  }) {
    return CLActionText(
      text: text,
      color: CLTheme.of(context).primary,
      onTap: onTap,
      context: context,
      iconData: icon,
      hugeIcon: hugeIcon,
      width: width,
      enableHover: enableHover,
      hoverColor: hoverColor,
      foregroundColor: foregroundColor,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
    );
  }

  factory CLActionText.secondary({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    bool needConfirmation = false,
    String? confirmationMessage,
    IconData? icon,
    Widget? hugeIcon,
    Color? hoverColor,
    Color? foregroundColor,
    bool enableHover = false,
    double? width,
  }) {
    return CLActionText(
      enableHover: enableHover,
      text: text,
      color: CLTheme.of(context).secondary,
      onTap: onTap,
      context: context,
      hoverColor: hoverColor,
      iconData: icon,
      hugeIcon: hugeIcon,
      width: width,
      foregroundColor: foregroundColor,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
    );
  }

  factory CLActionText.success({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    bool needConfirmation = false,
    String? confirmationMessage,
    Color? foregroundColor,
    Color? hoverColor,
    bool enableHover = false,
    IconData? icon,
    Widget? hugeIcon,
    double? width,
  }) {
    return CLActionText(
      enableHover: enableHover,
      text: text,
      color: CLTheme.of(context).success,
      onTap: onTap,
      context: context,
      iconData: icon,
      hugeIcon: hugeIcon,
      foregroundColor: foregroundColor,
      width: width,
      hoverColor: hoverColor,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
    );
  }

  factory CLActionText.info({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    bool needConfirmation = false,
    String? confirmationMessage,
    Color? hoverColor,
    Color? foregroundColor,
    bool enableHover = false,
    IconData? icon,
    Widget? hugeIcon,
    double? width,
  }) {
    return CLActionText(
      enableHover: enableHover,
      text: text,
      color: CLTheme.of(context).info,
      context: context,
      onTap: onTap,
      iconData: icon,
      hugeIcon: hugeIcon,
      foregroundColor: foregroundColor,
      width: width,
      hoverColor: hoverColor,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
    );
  }

  factory CLActionText.warning({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    bool needConfirmation = false,
    bool enableHover = false,
    String? confirmationMessage,
    Color? hoverColor,
    Color? foregroundColor,
    IconData? icon,
    Widget? hugeIcon,
    double? width,
  }) {
    return CLActionText(
      enableHover: enableHover,
      context: context,
      text: text,
      color: CLTheme.of(context).warning,
      onTap: onTap,
      iconData: icon,
      hugeIcon: hugeIcon,
      hoverColor: hoverColor,
      width: width,
      foregroundColor: foregroundColor,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
    );
  }

  factory CLActionText.danger({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    bool needConfirmation = false,
    String? confirmationMessage,
    Color? foregroundColor,
    Color? hoverColor,
    bool enableHover = false,
    IconData? icon,
    Widget? hugeIcon,
    double? width,
  }) {
    return CLActionText(
      enableHover: enableHover,
      context: context,
      text: text,
      color: CLTheme.of(context).danger,
      onTap: onTap,
      iconData: icon,
      hugeIcon: hugeIcon,
      hoverColor: hoverColor,
      width: width,
      foregroundColor: foregroundColor,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation,
    );
  }

  @override
  State<CLActionText> createState() => _CLActionTextState();
}

class _CLActionTextState extends State<CLActionText> {
  bool loading = false;
  bool isHovering = false;

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
    final fontSize = isMobile ? 13.0 : 14.0;
    final iconSz = isMobile ? Sizes.small : Sizes.medium;
    final activeColor = isHovering ? (widget.hoverColor ?? widget.color) : widget.color;
    final hasIcon = widget.iconData != null || widget.hugeIcon != null || loading;

    return IntrinsicWidth(
      child: MouseRegion(
        onEnter: widget.enableHover ? (_) => setState(() => isHovering = true) : null,
        onExit: widget.enableHover ? (_) => setState(() => isHovering = false) : null,
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: _handleTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: isMobile ? 4 : 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (loading)
                  CLLoadingSpinner(size: 16, color: activeColor)
                else if (widget.hugeIcon != null)
                  widget.hugeIcon!
                else if (widget.iconData != null)
                  Icon(widget.iconData, color: activeColor, size: iconSz),
                if (hasIcon) SizedBox(width: isMobile ? 4 : 6),
                Flexible(
                  child: Text(
                    widget.text,
                    style: CLTheme.of(context).bodyText.merge(TextStyle(color: activeColor, fontSize: fontSize)),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool isAsync(Function function) {
    return function is Future Function();
  }
}
