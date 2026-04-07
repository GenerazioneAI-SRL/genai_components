import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genai_components/widgets/alertmanager/alert_manager.dart';

import '../cl_theme.dart';

class CLClipboardWidget extends StatelessWidget {
  const CLClipboardWidget({super.key, required this.text, this.textStyle, this.showAlert = false});

  final TextStyle? textStyle;
  final String text;
  final bool showAlert;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: textStyle ?? CLTheme.of(context).bodyText,
        ),
        IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: text));
              if (showAlert) {
                AlertManager.showInfo("Info", "Testo $text copiato");
              }
            },
            icon: Icon(Icons.copy))
      ],
    );
  }
}
