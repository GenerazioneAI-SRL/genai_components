import 'package:flutter/material.dart';
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';
import 'buttons/cl_ghost_button.widget.dart';

class CLContainer extends StatefulWidget {
  const CLContainer({
    super.key,
    required this.child,
    this.title,
    this.showShadow = true,
    this.customHeader,
    this.contentPadding,
    this.contentMargin,
    this.height,
    this.width,
    this.backgroundColor,
    this.constraints,
    this.borderRadius,
    this.actionTitle,
    this.titleWidget,
    this.actionWidget,
    this.onActionTap,
    this.glassmorphism = true,
    this.showBorder = true,
  });

  final Widget child;
  final String? title;
  final bool showShadow;
  final Widget? customHeader;
  final EdgeInsets? contentPadding;
  final EdgeInsets? contentMargin;
  final double? height;
  final double? width;

  final Color? backgroundColor;
  final BoxConstraints? constraints;
  final BorderRadius? borderRadius;
  final Function()? onActionTap;
  final String? actionTitle;
  final Widget? titleWidget;
  final Widget? actionWidget;
  final bool showBorder;

  final bool glassmorphism;

  @override
  State<CLContainer> createState() => _CLContainerState();
}

class _CLContainerState extends State<CLContainer> {
  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final hasTitle = widget.title != null || widget.titleWidget != null;
    final br = widget.borderRadius ?? BorderRadius.circular(Sizes.borderRadius);
    final borderWidth = widget.showBorder ? 1.0 : 0.0;
    final innerBr = BorderRadius.only(
      topLeft: Radius.circular((br.topLeft.x - borderWidth).clamp(0.0, double.infinity)),
      topRight: Radius.circular((br.topRight.x - borderWidth).clamp(0.0, double.infinity)),
      bottomLeft: Radius.circular((br.bottomLeft.x - borderWidth).clamp(0.0, double.infinity)),
      bottomRight: Radius.circular((br.bottomRight.x - borderWidth).clamp(0.0, double.infinity)),
    );

    return Container(
      height: widget.height,
      width: widget.width,
      margin: widget.contentMargin ?? EdgeInsets.zero,
      constraints: widget.constraints,
      decoration: BoxDecoration(
        border: widget.showBorder ? Border.all(color: CLTheme.of(context).cardBorder, width: 1.0) : null,
        color: widget.backgroundColor ?? theme.secondaryBackground,
        borderRadius: br,
        boxShadow: widget.showShadow ? CLTheme.of(context).cardShadow : null,
      ),
      child: ClipRRect(
        borderRadius: innerBr,
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasTitle) ...[
            Container(
              decoration: BoxDecoration(
                color: theme.primaryBackground,
                border: widget.customHeader == null ? Border(bottom: BorderSide(color: theme.cardBorder, width: 1)) : null,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Sizes.padding, vertical: Sizes.verticalPadding),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child:
                          widget.titleWidget != null ? widget.titleWidget! : Text(widget.title!, style: theme.bodyText.override(fontWeight: FontWeight.bold)),
                    ),
                    if (widget.actionTitle != null && widget.onActionTap != null && widget.actionWidget == null)
                      SizedBox(height: 20, child: CLGhostButton.primary(text: widget.actionTitle!, onTap: widget.onActionTap!, context: context)),
                    if (widget.actionWidget != null) widget.actionWidget!,
                  ],
                ),
              ),
            ),
          ],
          widget.customHeader ?? SizedBox.shrink(),
          Flexible(child: Padding(padding: widget.contentPadding ?? EdgeInsets.zero, child: widget.child)),
        ],
      ),
      ),
    );
  }
}
