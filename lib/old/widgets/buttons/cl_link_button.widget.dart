import 'package:flutter/material.dart';
import '../../cl_theme.dart';
import 'cl_async_button_mixin.dart';
import 'cl_loading_spinner.widget.dart';
import '../foundation/cl_pressable.widget.dart';
import '../foundation/cl_tone_style.dart';

/// Bottone "link" (variante shadcn): solo testo colorato dal tono, **underline
/// su hover**, nessun background né bordo. Costruito sul foundation
/// `CLPressable` + `CLToneStyle` (variante `link`).
class CLLinkButton extends StatefulWidget {
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

  /// Interno: `true` → tono semantico (testo = [color]). `false` → neutro
  /// (secondary + costruttore raw): testo `primaryText`.
  final bool _colored;

  const CLLinkButton({
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

  const CLLinkButton._colored({
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

  factory CLLinkButton.primary({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    IconData? icon,
    Widget? hugeIcon,
    double? width,
    bool needConfirmation = false,
    String? confirmationMessage,
    bool isCompact = false,
  }) =>
      CLLinkButton._colored(
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

  factory CLLinkButton.secondary({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    IconData? icon,
    Widget? hugeIcon,
    double? width,
    bool needConfirmation = false,
    String? confirmationMessage,
    bool isCompact = false,
  }) =>
      CLLinkButton(
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

  factory CLLinkButton.success({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    IconData? icon,
    Widget? hugeIcon,
    double? width,
    bool needConfirmation = false,
    String? confirmationMessage,
    bool isCompact = false,
  }) =>
      CLLinkButton._colored(
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

  factory CLLinkButton.info({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    IconData? icon,
    Widget? hugeIcon,
    double? width,
    bool needConfirmation = false,
    String? confirmationMessage,
    bool isCompact = false,
  }) =>
      CLLinkButton._colored(
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

  factory CLLinkButton.warning({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    IconData? icon,
    Widget? hugeIcon,
    double? width,
    bool needConfirmation = false,
    String? confirmationMessage,
    bool isCompact = false,
  }) =>
      CLLinkButton._colored(
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

  factory CLLinkButton.danger({
    required String text,
    required Function() onTap,
    required BuildContext context,
    IconAlignment iconAlignment = IconAlignment.start,
    IconData? icon,
    Widget? hugeIcon,
    double? width,
    bool needConfirmation = false,
    String? confirmationMessage,
    bool isCompact = false,
  }) =>
      CLLinkButton._colored(
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

  @override
  State<CLLinkButton> createState() => _CLLinkButtonState();
}

class _CLLinkButtonState extends State<CLLinkButton> with AsyncButtonMixin {
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
    final showText = widget.text.isNotEmpty;
    final isLoading = loading;
    final isInteractive = !isLoading;
    final iconSz = widget.isCompact ? theme.iconSizeCompact - 2 : theme.iconSizeCompact;
    final btnH = widget.isCompact ? theme.buttonHeightCompact : theme.buttonHeightDefault;
    final hasInlineIcon = widget.iconData != null || widget.hugeIcon != null || isLoading;

    Widget button = CLPressable(
      enabled: isInteractive,
      onTap: _handleTap,
      builder: (context, state) {
        final fg = CLToneStyle.resolve(theme,
                color: widget.color,
                variant: CLVariant.link,
                state: state,
                colored: widget._colored)
            .fg;
        final labelStyle = theme.bodyText.copyWith(
          color: fg,
          fontWeight: FontWeight.w500,
          decoration:
              state.hovered ? TextDecoration.underline : TextDecoration.none,
          decorationColor: fg,
        );

        Widget iconSlot(double size) {
          if (isLoading) {
            return SizedBox(
                width: size,
                height: size,
                child: CLLoadingSpinner(size: size, color: fg));
          }
          return widget.hugeIcon ??
              (widget.iconData != null
                  ? Icon(widget.iconData, color: fg, size: size)
                  : SizedBox(width: size, height: size));
        }

        return Container(
          constraints: BoxConstraints(minHeight: btnH),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: theme.gapXs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasInlineIcon && widget.iconAlignment == IconAlignment.start) ...[
                iconSlot(iconSz),
                SizedBox(width: theme.gapXs),
              ],
              if (showText)
                Flexible(
                  child: Text(widget.text,
                      style: labelStyle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1),
                ),
              if (hasInlineIcon && widget.iconAlignment == IconAlignment.end) ...[
                SizedBox(width: theme.gapXs),
                iconSlot(iconSz),
              ],
            ],
          ),
        );
      },
    );

    if (widget.width != null) {
      button = SizedBox(width: widget.width, child: button);
    }
    return button;
  }
}
