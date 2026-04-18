import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import 'cl_confirm_dialog.dart';

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

class _CLOutlineButtonState extends State<CLOutlineButton> {
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

    return SizedBox(
      width: widget.width,
      child: widget.text.isNotEmpty
          ? OutlinedButton.icon(
              iconAlignment: widget.iconAlignment,
              icon: loading
                  ? SizedBox(
                      width: iconSz,
                      height: iconSz,
                      child: CircularProgressIndicator(color: widget.color, strokeWidth: 2),
                    )
                  : widget.hugeIcon ??
                      (widget.iconData != null
                          ? Icon(widget.iconData, color: widget.color, size: iconSz)
                          : null),
              onPressed: _handleTap,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: CLTheme.of(context).cardBorder, width: 1.0),
                foregroundColor: widget.color,
                overlayColor: CLTheme.of(context).accent,
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Sizes.borderRadius),
                ),
                minimumSize: Size(isMobile ? 0 : 64, isMobile ? 32 : 36),
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
                shape: WidgetStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Sizes.borderRadius),
                  side: BorderSide(color: CLTheme.of(context).cardBorder, width: 1.0),
                )),
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
