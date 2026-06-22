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
    this.showBorder = false,
    this.titleBackgroundColor,
    this.titleIcon,
    this.plainHeader = false,
    this.externalTitle = false,
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

  final Color? titleBackgroundColor;

  /// Icona opzionale mostrata a sinistra del [title].
  /// Ignorata se viene fornito [titleWidget].
  final Widget? titleIcon;

  /// Header "grouped" stile iOS: titolo come label sopra il contenuto, senza
  /// barra di sfondo grigia né divider inferiore. La card resta una superficie
  /// unica delimitata da bordo/contrasto. Default `false` (header classico).
  final bool plainHeader;

  /// Titolo FUORI dalla card: [title]/[titleWidget] (+ [titleIcon]/azione)
  /// renderizzati come riga sopra la card, con gap `gapSm` (8) prima della
  /// superficie. La card non mostra la barra titolo interna. Default `false`.
  final bool externalTitle;

  @override
  State<CLContainer> createState() => _CLContainerState();
}

class _CLContainerState extends State<CLContainer> {
  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final hasTitle = widget.title != null || widget.titleWidget != null;
    // Dark: cardShadowSoft è invisibile su near-black → la card si delinea con un
    // bordo hairline. Light: ci pensa l'ombra (default Foundation, niente bordo).
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final useBorder = widget.showBorder || (widget.showShadow && isDark);
    // Card L1: raggio card (radiusCard), non radiusControl. Override esplicito via borderRadius.
    final br = widget.borderRadius ?? BorderRadius.circular(Sizes.radiusCard);
    final borderWidth = useBorder ? 1.0 : 0.0;
    final innerBr = BorderRadius.only(
      topLeft: Radius.circular((br.topLeft.x - borderWidth).clamp(0.0, double.infinity)),
      topRight: Radius.circular((br.topRight.x - borderWidth).clamp(0.0, double.infinity)),
      bottomLeft: Radius.circular((br.bottomLeft.x - borderWidth).clamp(0.0, double.infinity)),
      bottomRight: Radius.circular((br.bottomRight.x - borderWidth).clamp(0.0, double.infinity)),
    );

    final Widget card = Container(
      height: widget.height,
      width: widget.width,
      margin: widget.contentMargin ?? EdgeInsets.zero,
      constraints: widget.constraints,
      decoration: BoxDecoration(
        border: useBorder ? Border.all(color: theme.cardBorder, width: 1.0) : null,
        color: widget.backgroundColor ?? theme.secondaryBackground,
        borderRadius: br,
        // Default Foundation: ombra soft (card statica L1), nessun bordo. Il
        // bordo torna opt-in via `showBorder: true`.
        boxShadow: widget.showShadow ? theme.cardShadowSoft : null,
      ),
      child: ClipRRect(
        borderRadius: innerBr,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasTitle && !widget.externalTitle) ...[
              Container(
                decoration: BoxDecoration(
                  // plainHeader: nessuna barra grigia né divider — il titolo è
                  // una label sopra il contenuto (grouped iOS).
                  color: widget.plainHeader
                      ? Colors.transparent
                      : widget.titleBackgroundColor != null
                          ? widget.titleBackgroundColor!.withValues(alpha: 0.08)
                          : theme.secondaryBackground,
                  border: (widget.customHeader == null && !widget.plainHeader)
                      ? Border(bottom: BorderSide(color: theme.cardBorder, width: 1))
                      : null,
                ),
                child: Padding(
                  padding: widget.plainHeader
                      ? const EdgeInsets.fromLTRB(Sizes.padding, Sizes.padding, Sizes.padding, 0)
                      : const EdgeInsets.symmetric(horizontal: Sizes.padding, vertical: Sizes.verticalPadding),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: widget.titleWidget != null
                            ? widget.titleWidget!
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.titleIcon != null) ...[
                                    widget.titleIcon!,
                                    const SizedBox(width: Sizes.gapMd),
                                  ],
                                  Flexible(
                                    child: Text(widget.title!,
                                        style: theme.bodyText.override(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                      ),
                      if (widget.actionTitle != null && widget.onActionTap != null && widget.actionWidget == null)
                        SizedBox(
                            height: 20,
                            child: CLGhostButton.primary(
                                text: widget.actionTitle!, onTap: widget.onActionTap!, context: context)),
                      if (widget.actionWidget != null) widget.actionWidget!,
                    ],
                  ),
                ),
              ),
            ],
            widget.customHeader ?? SizedBox.shrink(),
            Flexible(
              child: Padding(
                padding: widget.contentPadding ?? const EdgeInsets.all(Sizes.gapLg),
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );

    // Titolo fuori card: riga (icona+titolo+azione) sopra la superficie, gap
    // gapSm (8) prima della card. La card sopra non ha barra titolo interna.
    if (hasTitle && widget.externalTitle) {
      final Widget? action = widget.actionWidget ??
          (widget.actionTitle != null && widget.onActionTap != null
              ? CLGhostButton.primary(text: widget.actionTitle!, onTap: widget.onActionTap!, context: context)
              : null);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Titolo allineato a sinistra al content della card (padding left gapLg).
          Padding(
            padding: const EdgeInsets.only(left: Sizes.gapLg),
            child: Row(
              children: [
                if (widget.titleIcon != null) ...[
                  widget.titleIcon!,
                  const SizedBox(width: Sizes.gapSm),
                ],
                Expanded(
                  child: widget.titleWidget ??
                      Text(widget.title!, style: theme.title, overflow: TextOverflow.ellipsis),
                ),
                if (action != null) action,
              ],
            ),
          ),
          const SizedBox(height: Sizes.gapSm),
          card,
        ],
      );
    }
    return card;
  }
}
