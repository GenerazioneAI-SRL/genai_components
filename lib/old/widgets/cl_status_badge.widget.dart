import 'package:flutter/material.dart';
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

/// Widget per visualizzare uno status con pallino colorato + testo
/// Esempio: ● In attesa, ● Approvata, ● Rifiutata
class CLStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final double dotSize;
  final TextStyle? textStyle;

  const CLStatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.dotSize = 8,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: Sizes.padding / 2),
        Flexible(
          child: Text(
            label,
            style: textStyle ?? CLTheme.of(context).bodyText.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
