import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

class CLExpansionTile extends StatefulWidget {
  const CLExpansionTile({
    super.key,
    this.isSelected = false,
    required this.children,
    this.title,
    required this.leading,
    this.titleTextStyle,
    this.trailingArrowColor,
    this.controlAffinity,
    this.useCustomLayout =
        true, // Nuovo parametro per usare il layout personalizzato
    this.onExpansionChanged, // Callback per notificare il cambio di stato
    this.onTitleTap, // Callback per navigazione al click sul titolo
  });

  final bool isSelected;
  final List<Widget> children;
  final String? title;
  final TextStyle? titleTextStyle;
  final Widget leading;
  final Color? trailingArrowColor;
  final ListTileControlAffinity? controlAffinity;
  final bool useCustomLayout;
  final void Function(bool)? onExpansionChanged;
  final VoidCallback? onTitleTap;

  @override
  State<CLExpansionTile> createState() => _CLExpansionTileState();
}

class _CLExpansionTileState extends State<CLExpansionTile> {
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.isSelected;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child:
          widget.useCustomLayout
              ? ExpansionTile(
                tilePadding: EdgeInsets.symmetric(
                  horizontal: Sizes.padding / 2,
                ),
                initiallyExpanded: isExpanded,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Sizes.borderRadius),
                ),
                // Nessun leading, usiamo un title personalizzato con Row
                title: Row(
                  children: [
                    // Freccia espandibile
                    AnimatedRotation(
                      duration: CLTheme.of(context).durationFast,
                      turns:
                          isExpanded ? 0.25 : 0, // Ruota di 90° quando espanso
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowRight01,
                        color:
                            widget.isSelected
                                ? CLTheme.of(context).primary
                                : CLTheme.of(context).primaryText,
                        size: Sizes.iconSizeDefault,
                      ),
                    ),
                    SizedBox(width: Sizes.padding / 2),
                    // Icona del modulo - colore dinamico basato su isSelected e isExpanded
                    widget.leading,
                    SizedBox(width: Sizes.padding / 2 + 3),
                    // Testo — navigabile se onTitleTap è definito
                    Expanded(
                      child:
                          widget.onTitleTap != null
                              ? MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: widget.onTitleTap,
                                  child: Text(
                                    widget.title ?? "Senza Nome",
                                    style:
                                        widget.titleTextStyle ??
                                        CLTheme.of(context).title.copyWith(
                                          color:
                                              widget.isSelected
                                                  ? CLTheme.of(context).primary
                                                  : CLTheme.of(
                                                    context,
                                                  ).primaryText,
                                          fontWeight:
                                              widget.isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                        ),
                                    overflow: TextOverflow.fade,
                                    maxLines: 1,
                                  ),
                                ),
                              )
                              : Text(
                                widget.title ?? "Senza Nome",
                                style:
                                    widget.titleTextStyle ??
                                    CLTheme.of(context).title.copyWith(
                                      color:
                                          widget.isSelected
                                              ? CLTheme.of(context).primary
                                              : CLTheme.of(context).primaryText,
                                      fontWeight:
                                          widget.isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                    ),
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                              ),
                    ),
                  ],
                ),
                // Nascondi l'icona di default dell'ExpansionTile
                trailing: SizedBox.shrink(),
                children: [...widget.children],
                onExpansionChanged: (expanded) {
                  setState(() {
                    isExpanded = expanded;
                  });
                  widget.onExpansionChanged?.call(expanded);
                },
              )
              : ExpansionTile(
                controlAffinity:
                    widget.controlAffinity ?? ListTileControlAffinity.leading,
                tilePadding: EdgeInsets.symmetric(horizontal: 0),
                initiallyExpanded: isExpanded,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Sizes.borderRadius),
                ),
                title: Text(
                  widget.title ?? "Senza Nome",
                  style:
                      widget.titleTextStyle ??
                      CLTheme.of(context).bodyLabel.copyWith(
                        color:
                            widget.isSelected
                                ? CLTheme.of(context).primary
                                : CLTheme.of(context).secondaryText,
                        fontWeight:
                            widget.isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                      ),
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                ),
                collapsedIconColor:
                    widget.isSelected
                        ? CLTheme.of(context).primary
                        : CLTheme.of(context).secondaryText,
                iconColor:
                    widget.isSelected
                        ? CLTheme.of(context).primary
                        : CLTheme.of(context).secondaryText,
                leading: widget.leading,
                children: [...widget.children],
                onExpansionChanged: (expanded) {
                  setState(() {
                    isExpanded = expanded;
                  });
                  widget.onExpansionChanged?.call(expanded);
                },
              ),
    );
  }
}
