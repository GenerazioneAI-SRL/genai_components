import 'package:flutter/cupertino.dart';

import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

class TableActionItem extends StatefulWidget {
  final String name;
  final dynamic iconData; // Può essere IconData o Widget (HugeIcon)
  final Color? iconColor;

  const TableActionItem({super.key, required this.name, required this.iconData, this.iconColor});

  @override
  State<TableActionItem> createState() => _TableActionItemState();
}

class _TableActionItemState extends State<TableActionItem> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        widget.iconData is Widget
            ? widget
                .iconData // Se è un Widget (HugeIcon), lo usa direttamente
            : Icon(widget.iconData, color: widget.iconColor ?? CLTheme.of(context).secondaryText, size: Sizes.medium),
        SizedBox(width: Sizes.gapSm),
        Text(widget.name, style: CLTheme.of(context).title),
      ],
    );
  }
}
