import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import 'cl_confirm_dialog.dart';

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

class _CLSoftButtonState extends State<CLSoftButton> {
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
          ? ElevatedButton.icon(
              iconAlignment: widget.iconAlignment,
              icon: loading
                  ? SizedBox(width: iconSz, height: iconSz, child: CircularProgressIndicator(color: widget.color, strokeWidth: 2))
                  : widget.hugeIcon != null
                      ? HugeIcon(icon: widget.hugeIcon!, color: widget.color, size: iconSz)
                      : widget.iconData != null
                          ? Icon(widget.iconData, color: widget.color, size: iconSz)
                          : null,
              onPressed: _handleTap,
              style: ElevatedButton.styleFrom(
                shadowColor: Colors.transparent,
                foregroundColor: widget.color,
                backgroundColor: CLTheme.of(context).muted,
                overlayColor: CLTheme.of(context).accent,
                textStyle: CLTheme.of(context).bodyText.copyWith(fontSize: fontSize),
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius)),
                elevation: 0,
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
                backgroundColor: WidgetStateProperty.all(CLTheme.of(context).muted),
                foregroundColor: WidgetStateProperty.all(widget.color),
                overlayColor: WidgetStateProperty.all(CLTheme.of(context).accent),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius))),
                elevation: WidgetStateProperty.all(0),
                shadowColor: WidgetStateProperty.all(Colors.transparent),
                minimumSize: WidgetStateProperty.all(Size(isMobile ? 36 : 36, isMobile ? 36 : 36)),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: loading
                  ? SizedBox(width: iconSz, height: iconSz, child: CircularProgressIndicator(color: widget.color, strokeWidth: 2))
                  : widget.hugeIcon != null
                      ? HugeIcon(icon: widget.hugeIcon!, color: widget.color, size: iconSz)
                      : widget.iconData != null
                          ? Icon(widget.iconData, color: widget.color, size: iconSz)
                          : const SizedBox.shrink(),
            ),
    );
  }

  bool isAsync(Function function) {
    return function is Future Function();
  }
}
