import 'package:flutter/material.dart';

/// Parses inline markdown (**bold**, *italic*, `code`) into [TextSpan]s
/// and renders them via [RichText].
///
/// Supports:
/// - `**bold**` or `__bold__`
/// - `*italic*` or `_italic_`
/// - `` `inline code` ``
/// - Nested bold+italic: `***text***`
class MarkdownText extends StatelessWidget {
  final String text;
  final TextStyle baseStyle;
  final bool selectable;

  const MarkdownText({
    super.key,
    required this.text,
    required this.baseStyle,
    this.selectable = false,
  });

  @override
  Widget build(BuildContext context) {
    final span = TextSpan(children: _parse(text), style: baseStyle);
    if (selectable) {
      return SelectableText.rich(span);
    }
    return RichText(text: span);
  }

  List<InlineSpan> _parse(String input) {
    final spans = <InlineSpan>[];
    // Pattern order matters: bold+italic first, then bold, then italic, then code.
    final regex = RegExp(
      r'(\*\*\*|___)(.+?)\1' // ***bold italic*** or ___bold italic___
      r'|(\*\*|__)(.+?)\3' // **bold** or __bold__
      r'|(\*|_)(.+?)\5' // *italic* or _italic_
      r'|`([^`]+)`', // `code`
    );

    int lastEnd = 0;
    for (final match in regex.allMatches(input)) {
      // Add plain text before this match.
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: input.substring(lastEnd, match.start)));
      }

      if (match.group(2) != null) {
        // Bold + italic
        spans.add(
          TextSpan(
            text: match.group(2),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      } else if (match.group(4) != null) {
        // Bold
        spans.add(
          TextSpan(
            text: match.group(4),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        );
      } else if (match.group(6) != null) {
        // Italic
        spans.add(
          TextSpan(
            text: match.group(6),
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        );
      } else if (match.group(7) != null) {
        // Inline code
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                match.group(7)!,
                style: baseStyle.copyWith(
                  fontFamily: 'monospace',
                  fontSize: (baseStyle.fontSize ?? 13.5) - 1,
                ),
              ),
            ),
          ),
        );
      }

      lastEnd = match.end;
    }

    // Add remaining plain text.
    if (lastEnd < input.length) {
      spans.add(TextSpan(text: input.substring(lastEnd)));
    }

    return spans;
  }
}
