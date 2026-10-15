import 'package:flutter/material.dart';

import '../../../../cl_theme.dart';
import '../cl_ai_chat_message.model.dart';

/// Testo di un messaggio: markdown di base (se [markdown]) e segnaposto `[n]` delle [citations]
/// resi come riferimenti cliccabili. Interno alla famiglia (non esportato dal barrel).
///
/// Markdown supportato: titoli `#`..`######`, elenchi puntati (`-`, `*`, `+`, `•`) e numerati,
/// citazioni `>`, blocchi di codice ```` ``` ````, `***grassetto corsivo***`, `**grassetto**`,
/// `__grassetto__`, `*corsivo*`, `_corsivo_`, `` `codice` ``, `[testo](url)`.
class AiMarkdownBody extends StatelessWidget {
  const AiMarkdownBody({
    super.key,
    required this.text,
    required this.style,
    this.markdown = true,
    this.citations = const [],
    this.keyPrefix = 'cl-ai',
    this.onLinkTap,
  });

  final String text;
  final TextStyle style;
  final bool markdown;
  final List<CLAiCitation> citations;

  /// Prefisso delle chiavi dei riferimenti: `<keyPrefix>-cite-<n>`.
  final String keyPrefix;
  final ValueChanged<String>? onLinkTap;

  static final _inlineMd = RegExp(
    r'\[([^\]\n]+)\]\(([^)\s]+)\)' // 1,2 link
    r'|\[(\d{1,3})\]' // 3 citazione
    r'|\*\*\*(.+?)\*\*\*' // 4 grassetto corsivo
    r'|\*\*(.+?)\*\*' // 5 grassetto
    r'|__(.+?)__' // 6 grassetto
    r'|(?<![\w*])\*(?!\s)(.+?)(?<!\s)\*(?!\w)' // 7 corsivo
    r'|(?<!\w)_(?!\s)(.+?)(?<!\s)_(?!\w)' // 8 corsivo
    r'|`([^`\n]+)`', // 9 codice
  );
  static final _citationOnly = RegExp(r'\[(\d{1,3})\]');
  static final _heading = RegExp(r'^(#{1,6})\s+(.*)$');
  static final _bullet = RegExp(r'^(\s*)[-*+•]\s+(.*)$');
  static final _numbered = RegExp(r'^(\s*)(\d+)[.)]\s+(.*)$');
  static final _quote = RegExp(r'^>\s?(.*)$');

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    if (!markdown) {
      return Text.rich(TextSpan(style: style, children: _inline(context, theme, text, md: false)));
    }

    final blocks = <Widget>[];
    final paragraph = <String>[];
    final code = <String>[];
    var inCode = false;

    void flushParagraph() {
      if (paragraph.isEmpty) return;
      final joined = paragraph.join('\n');
      paragraph.clear();
      blocks.add(Text.rich(TextSpan(style: style, children: _inline(context, theme, joined))));
    }

    void flushCode() {
      final body = code.join('\n');
      code.clear();
      blocks.add(Container(
        width: double.infinity,
        padding: EdgeInsets.all(theme.gapMd),
        decoration: BoxDecoration(
          color: theme.muted,
          borderRadius: BorderRadius.circular(theme.radiusControl),
          border: Border.all(color: theme.cardBorder),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            body,
            style: style.copyWith(fontFamily: 'monospace', fontSize: theme.smallText.fontSize),
          ),
        ),
      ));
    }

    for (final line in text.split('\n')) {
      if (line.trimLeft().startsWith('```')) {
        if (inCode) {
          flushCode();
          inCode = false;
        } else {
          flushParagraph();
          inCode = true;
        }
        continue;
      }
      if (inCode) {
        code.add(line);
        continue;
      }
      if (line.trim().isEmpty) {
        flushParagraph();
        continue;
      }

      final h = _heading.firstMatch(line.trim());
      final b = _bullet.firstMatch(line);
      final n = _numbered.firstMatch(line);
      final q = _quote.firstMatch(line.trim());
      if (h != null) {
        flushParagraph();
        final level = h.group(1)!.length;
        final hs = level == 1
            ? theme.heading4
            : level == 2
                ? theme.heading5
                : theme.heading6;
        blocks.add(Text.rich(TextSpan(
          style: hs.copyWith(color: style.color, fontWeight: FontWeight.w600),
          children: _inline(context, theme, h.group(2)!),
        )));
      } else if (b != null || n != null) {
        flushParagraph();
        final indent = ((b ?? n)!.group(1)!.length ~/ 2) * theme.gapLg;
        final marker = b != null ? '•' : '${n!.group(2)}.';
        final body = b != null ? b.group(2)! : n!.group(3)!;
        blocks.add(Padding(
          padding: EdgeInsets.only(left: indent),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: theme.gapXl,
                child: Text(marker, style: style.copyWith(color: theme.secondaryText)),
              ),
              Expanded(child: Text.rich(TextSpan(style: style, children: _inline(context, theme, body)))),
            ],
          ),
        ));
      } else if (q != null) {
        flushParagraph();
        blocks.add(Container(
          padding: EdgeInsets.only(left: theme.gapMd),
          decoration: BoxDecoration(border: Border(left: BorderSide(color: theme.borderColor, width: 3))),
          child: Text.rich(TextSpan(
            style: style.copyWith(color: theme.secondaryText),
            children: _inline(context, theme, q.group(1)!),
          )),
        ));
      } else {
        paragraph.add(line);
      }
    }
    if (inCode) flushCode();
    flushParagraph();

    if (blocks.length == 1) return blocks.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < blocks.length; i++) ...[
          if (i > 0) SizedBox(height: theme.gapSm),
          blocks[i],
        ],
      ],
    );
  }

  List<InlineSpan> _inline(BuildContext context, CLTheme theme, String input, {bool md = true}) {
    final spans = <InlineSpan>[];
    var last = 0;
    for (final m in (md ? _inlineMd : _citationOnly).allMatches(input)) {
      if (m.start > last) spans.add(TextSpan(text: input.substring(last, m.start)));
      last = m.end;

      final citation = md ? m.group(3) : m.group(1);
      if (citation != null) {
        final n = int.parse(citation);
        if (n < 1 || n > citations.length) {
          spans.add(TextSpan(text: m.group(0)));
          continue;
        }
        final c = citations[n - 1];
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Tooltip(
            message: c.subtitle == null ? c.label : '${c.label} · ${c.subtitle}',
            child: Semantics(
              button: c.onTap != null,
              label: 'Fonte $n: ${c.label}',
              child: MouseRegion(
                cursor: c.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
                child: GestureDetector(
                  key: ValueKey('$keyPrefix-cite-$n'),
                  onTap: c.onTap,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: theme.gapXs / 2),
                    padding: EdgeInsets.symmetric(horizontal: theme.gapXs + theme.gapXs / 2),
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(alpha: theme.opacitySoft),
                      borderRadius: BorderRadius.circular(theme.radiusChip),
                    ),
                    child: Text(
                      '$n',
                      style: theme.smallLabel.copyWith(color: theme.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
        continue;
      }

      if (m.group(1) != null) {
        final label = m.group(1)!;
        final url = m.group(2)!;
        final linkStyle = TextStyle(color: theme.primary, decoration: TextDecoration.underline);
        if (onLinkTap == null) {
          spans.add(TextSpan(text: label, style: linkStyle));
        } else {
          spans.add(WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => onLinkTap!(url),
                child: Text(label, style: style.merge(linkStyle)),
              ),
            ),
          ));
        }
      } else if (m.group(4) != null) {
        spans.add(TextSpan(
          style: const TextStyle(fontWeight: FontWeight.w700, fontStyle: FontStyle.italic),
          children: _inline(context, theme, m.group(4)!),
        ));
      } else if (m.group(5) != null || m.group(6) != null) {
        spans.add(TextSpan(
          style: const TextStyle(fontWeight: FontWeight.w700),
          children: _inline(context, theme, (m.group(5) ?? m.group(6))!),
        ));
      } else if (m.group(7) != null || m.group(8) != null) {
        spans.add(TextSpan(
          style: const TextStyle(fontStyle: FontStyle.italic),
          children: _inline(context, theme, (m.group(7) ?? m.group(8))!),
        ));
      } else if (m.group(9) != null) {
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: theme.gapXs),
            decoration: BoxDecoration(
              color: theme.muted,
              borderRadius: BorderRadius.circular(theme.radiusXs),
            ),
            child: Text(
              m.group(9)!,
              style: style.copyWith(fontFamily: 'monospace', fontSize: theme.smallText.fontSize),
            ),
          ),
        ));
      }
    }
    if (last < input.length) spans.add(TextSpan(text: input.substring(last)));
    return spans;
  }
}
