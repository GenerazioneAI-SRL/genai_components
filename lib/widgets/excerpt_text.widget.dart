import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:genai_components/cl_theme.dart';

class ExcerptText<T extends Object> extends StatefulWidget {
  final String text;
  final TextStyle textStyle;
  final int maxLength;
  final Future<void> Function(T)? onMoreTap;

  const ExcerptText({
    required this.text,
    required this.textStyle,
    this.maxLength = 100,
    this.onMoreTap,
    super.key,
  });

  @override
  _ExcerptTextState createState() => _ExcerptTextState();
}

class _ExcerptTextState<T extends Object> extends State<ExcerptText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Determina il testo da mostrare in base allo stato di espansione
    final displayText = isExpanded || widget.maxLength == 0
        ? widget.text
        : widget.text.substring(0, widget.maxLength <= widget.text.length ? widget.maxLength : widget.text.length);
    return RichText(
      text: TextSpan(
        text: displayText,
        style: widget.textStyle,
        children: [
          if (!isExpanded && widget.text.length > widget.maxLength && widget.maxLength != 0)
            TextSpan(
            text: '...',
            style: widget.textStyle,
          ),
          // Aggiunge "Leggi altro" solo se il testo non è espanso e supera maxLength
          if (!isExpanded && widget.text.length > widget.maxLength && widget.maxLength != 0)
            TextSpan(
              text: ' Leggi altro',
              style: widget.textStyle.copyWith(color: CLTheme.of(context).primary),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  if (widget.onMoreTap != null) {
                    widget.onMoreTap!(T);
                  } else {
                    setState(() {
                      isExpanded = true;
                    });
                  }
                },
            ),
        ],
      ),
    );
  }
}
