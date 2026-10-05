import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:genai_components/cl_theme.dart';
import 'cl_graph_attributes.dart';
import 'cl_graph_models.dart';
import 'cl_graph_values.dart';

// Misure delle card. Il testo non viene mai troncato: titoli, etichette,
// valori e messaggi vanno a capo e la card si allunga. Le altezze servono però
// prima del render (layout dei nodi, archi, hit-test), quindi si misurano qui
// con TextPainter, con gli stessi stili, larghezze e textScaler dei widget che
// le disegnano (`CLNodeGraph._nodeCard`, `CLGraphAttributesSection`). Le
// costanti sotto sono condivise da misura e render: cambiarle in un posto solo.

const double kGraphCardBorderMax = 2; // bordo della card selezionata / bersaglio
/// Distanza fissa tra il bordo esterno della card e il testo: il padding cala
/// quando il bordo si ispessisce (selezione), così la larghezza del testo, e
/// quindi dove va a capo, non cambia selezionando la card.
const double kGraphCardBorder = 1;
const double kGraphFieldH = 26; // campo a una riga
const double kGraphFieldPadV = 3; // padding verticale del testo nei campi
const double kGraphFieldBorder = 1;
const double kGraphCaretMargin = 3; // spazio che EditableText riserva al cursore a fine riga
const double kGraphCheckbox = 20;
const double kGraphMenuIcon = 14; // chevron del menu di scelta
const double kGraphWarningIcon = 14;
const double kGraphDot = 10; // pallino colorato accanto al titolo
const double kGraphBadgePadV = 2;

/// Testo e messaggio d'errore di un campo che non corrisponde al valore
/// dell'host: testo non valido, o non ancora completo mentre si scrive.
/// [error] null ⇒ errore non ancora mostrato (campo a fuoco, testo a metà).
class CLGraphFieldDraft {
  final String text;
  final String? error;
  const CLGraphFieldDraft(this.text, this.error);

  @override
  bool operator ==(Object other) => other is CLGraphFieldDraft && other.text == text && other.error == error;

  @override
  int get hashCode => Object.hash(text, error);
}

/// Errore mostrato sotto la riga di [a]: quello del testo in corso, altrimenti
/// "Obbligatorio" se manca un valore richiesto. Unica formula per misura e render.
String? clGraphRowError(CLGraphNodeAttribute a, Object? value, CLGraphFieldDraft? draft) =>
    draft?.error ?? (value == null && !a.nullable ? 'Obbligatorio' : null);

/// Geometria di una card: altezza dell'intestazione (con eventuali avvisi),
/// altezza di ogni riga attributo e altezza totale.
class CLGraphCardLayout {
  final double headerHeight;
  final List<double> rowHeights;
  final double height;
  const CLGraphCardLayout({required this.headerHeight, required this.rowHeights, required this.height});

  /// Inizio (card-local) della sezione attributi: dentro il padding basso
  /// dell'intestazione, come prima degli avvisi.
  double sectionTop(CLTheme theme) => headerHeight - theme.gapMd;
}

class CLGraphCardMetrics {
  CLGraphCardMetrics({
    required this.theme,
    required TextStyle baseStyle,
    required this.textScaler,
    required this.textDirection,
  })  : titleStyle = baseStyle.merge(theme.bodyText),
        smallStyle = baseStyle.merge(theme.smallText);

  final CLTheme theme;
  final TextScaler textScaler;
  final TextDirection textDirection;

  /// Stili già fusi con il DefaultTextStyle: i widget li usano così come sono,
  /// quindi misura e render partono dalla stessa identica base.
  final TextStyle titleStyle;
  final TextStyle smallStyle;

  final Map<String, double> _cache = {};

  bool sameInputs(CLTheme theme, TextStyle baseStyle, TextScaler textScaler, TextDirection textDirection) =>
      identical(this.theme, theme) &&
      titleStyle == baseStyle.merge(theme.bodyText) &&
      this.textScaler == textScaler &&
      this.textDirection == textDirection;

  /// Altezza di [text] a capo entro [width].
  double textHeight(String text, TextStyle style, double width) {
    final key = '${identical(style, titleStyle) ? 't' : 's'}|$width|$text';
    return _cache[key] ??= _measure(text, style, width);
  }

  double _measure(String text, TextStyle style, double width) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
      textScaler: textScaler,
    )..layout(maxWidth: width);
    final h = painter.height;
    painter.dispose();
    return h.ceilToDouble();
  }

  double get smallLineHeight => textHeight('Ag', smallStyle, double.infinity);

  /// Larghezza del contenuto della sezione attributi (card meno padding).
  double get sectionWidth => kCardW - 2 * theme.gapMd;

  /// Larghezza interna dell'intestazione: padding + bordo costanti (vedi [kGraphCardBorder]).
  double get headerWidth => kCardW - 2 * (theme.gapMd + kGraphCardBorder);

  /// Larghezza della colonna titolo/sottotitolo.
  double titleWidth(CLGraphNode n) =>
      headerWidth - kGraphDot - theme.gapIconText - (n.icon != null ? theme.iconSizeCompact + theme.gapIconText : 0);

  double get warningTextWidth => headerWidth - kGraphWarningIcon - theme.gapXs;
  double get checkboxLabelWidth => sectionWidth - kGraphCheckbox - theme.gapSm;
  double get textFieldTextWidth => sectionWidth - 2 * theme.gapSm - 2 * kGraphFieldBorder - kGraphCaretMargin;
  double get menuTextWidth => sectionWidth - theme.gapSm - theme.gapXs - kGraphMenuIcon - 2 * kGraphFieldBorder;

  double _multiline(String text, double width) =>
      math.max(kGraphFieldH, textHeight(text.isEmpty ? ' ' : text, smallStyle, width) + 2 * (kGraphFieldPadV + kGraphFieldBorder));

  /// Altezza del campo di [a]: una riga per numeri e orari, a capo (cresce col
  /// contenuto) per testi, link e scelte. [text] = testo in corso, se c'è.
  double fieldHeight(CLGraphNodeAttribute a, Object? value, String? text) => switch (a.type) {
        CLGraphAttributeType.string || CLGraphAttributeType.url =>
          _multiline(text ?? (value == null ? '' : value.toString()), textFieldTextWidth),
        CLGraphAttributeType.enumeration => _multiline(clGraphDisplayValue(value), menuTextWidth),
        _ => kGraphFieldH,
      };

  double errorHeight(String? error) => error == null ? 0 : 2 + textHeight(error, smallStyle, sectionWidth);

  /// Riga attributo: etichetta sopra e campo sotto (checkbox: a sinistra
  /// dell'etichetta), poi l'eventuale errore. In sola lettura: etichetta e valore.
  double rowHeight(CLGraphNodeAttribute a, Object? value, CLGraphFieldDraft? draft, {required bool editable}) {
    if (!editable) {
      return textHeight(a.name, smallStyle, sectionWidth) + 2 + textHeight(clGraphDisplayValue(value), smallStyle, sectionWidth);
    }
    final error = errorHeight(clGraphRowError(a, value, draft));
    if (a.type == CLGraphAttributeType.boolean) {
      return math.max(kGraphCheckbox, 1 + textHeight(a.name, smallStyle, checkboxLabelWidth)) + error;
    }
    return textHeight(a.name, smallStyle, sectionWidth) + theme.gapXs + fieldHeight(a, value, draft?.text) + error;
  }

  /// Intestazione: pill, titolo e sottotitolo a capo, avvisi. Mai sotto [kCardH].
  double headerHeight(CLGraphNode n, List<String> warnings) {
    var h = 0.0;
    if (n.badge != null && n.badge!.isNotEmpty) h += smallLineHeight + 2 * kGraphBadgePadV + theme.gapXs;
    final tw = titleWidth(n);
    var text = textHeight(n.title, titleStyle, tw);
    if (n.subtitle != null && n.subtitle!.isNotEmpty) text += textHeight(n.subtitle!, smallStyle, tw);
    h += math.max(text, math.max(kGraphDot, n.icon != null ? theme.iconSizeCompact : 0));
    if (warnings.isNotEmpty) {
      h += theme.gapSm + math.max(kGraphWarningIcon, textHeight(warnings.join('\n'), smallStyle, warningTextWidth));
    }
    return math.max(kCardH, (2 * (theme.gapMd + kGraphCardBorder) + h).ceilToDouble());
  }

  /// Geometria completa della card di [n]. [drafts] = testi in corso per nome
  /// attributo; [editable] = attributi modificabili (campi) o in sola lettura.
  CLGraphCardLayout layout(
    CLGraphNode n, {
    List<String> warnings = const [],
    Map<String, CLGraphFieldDraft> drafts = const {},
    bool editable = false,
  }) {
    final header = headerHeight(n, warnings);
    if (n.attributes.isEmpty) return CLGraphCardLayout(headerHeight: header, rowHeights: const [], height: header);
    final values = n.resolvedAttributeValues;
    final rows = [
      for (final a in n.attributes) rowHeight(a, values[a.name], drafts[a.name], editable: editable),
    ];
    final section = 1 + theme.gapSm + rows.fold(0.0, (s, h) => s + h) + (rows.length - 1) * theme.gapSm + theme.gapMd;
    return CLGraphCardLayout(headerHeight: header, rowHeights: rows, height: header - theme.gapMd + section);
  }
}
