import 'package:flutter/material.dart';
import '../cl_theme.dart';

/// Widget per visualizzare un codice con prefisso grigio (es: "# - ABC123")
class CLCodeText extends StatelessWidget {
  final String? code;
  final String prefix;
  final TextStyle? codeStyle;
  final TextStyle? prefixStyle;

  const CLCodeText({
    super.key,
    required this.code,
    this.prefix = '# - ',
    this.codeStyle,
    this.prefixStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          prefix,
          style: prefixStyle ?? CLTheme.of(context).bodyLabel.copyWith(color: CLTheme.of(context).secondaryText),
        ),
        Flexible(
          child: Text(
            code ?? '-',
            style: codeStyle ?? CLTheme.of(context).bodyText,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
