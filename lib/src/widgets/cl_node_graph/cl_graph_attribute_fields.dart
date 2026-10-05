import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genai_components/cl_theme.dart';
import 'cl_graph_attributes.dart';
import 'cl_graph_card_metrics.dart';
import 'cl_graph_models.dart';
import 'cl_graph_values.dart';

const Object _kNone = Object(); // voce "nessun valore" nel menu enumeration (null chiude il menu)
const double _kSingleLinePadV = 7; // campo a una riga: testo centrato nei kGraphFieldH px

/// Righe attributo di una card: etichetta sopra e campo sotto (checkbox a
/// sinistra dell'etichetta), poi l'eventuale errore; in sola lettura etichetta
/// e valore. Nessun testo troncato: va a capo e la riga si allunga, con le
/// altezze calcolate da [CLGraphCardMetrics] (le stesse che `CLNodeGraph` usa
/// per il layout). `CLNodeGraph` posiziona la sezione sotto l'intestazione
/// della card e le riserva l'hit-test, così il pointer arriva agli input
/// invece di trascinare il nodo.
class CLGraphAttributesSection extends StatelessWidget {
  const CLGraphAttributesSection({
    super.key,
    required this.node,
    required this.metrics,
    this.drafts = const {},
    this.onChanged,
    this.onDraftChanged,
    this.onInteract,
  });

  final CLGraphNode node;
  final CLGraphCardMetrics metrics;
  /// Testi in corso che non corrispondono al valore dell'host, per nome.
  final Map<String, CLGraphFieldDraft> drafts;
  /// Nuovo valore (già valido) per l'attributo `name`. Null ⇒ sola lettura.
  final void Function(String name, Object? value)? onChanged;
  /// Testo in corso non valido o incompleto (null ⇒ di nuovo allineato
  /// all'host): la card si allunga per il messaggio d'errore.
  final void Function(String name, CLGraphFieldDraft? draft)? onDraftChanged;
  /// Pointer-down in un punto qualsiasi della sezione (selezione del nodo).
  final VoidCallback? onInteract;

  @override
  Widget build(BuildContext context) {
    assert(node.attributesProblem == null, node.attributesProblem);
    final theme = metrics.theme;
    final values = node.resolvedAttributeValues;
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => onInteract?.call(),
      child: Material(
        type: MaterialType.transparency,
        textStyle: metrics.smallStyle,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: theme.gapMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(height: 1, color: theme.cardBorder),
              SizedBox(height: theme.gapSm),
              for (var i = 0; i < node.attributes.length; i++) ...[
                if (i > 0) SizedBox(height: theme.gapSm),
                _AttributeRow(
                  key: ValueKey('${node.id}/${node.attributes[i].name}'),
                  attribute: node.attributes[i],
                  value: values[node.attributes[i].name],
                  draft: drafts[node.attributes[i].name],
                  metrics: metrics,
                  onChanged: onChanged == null ? null : (v) => onChanged!(node.attributes[i].name, v),
                  onDraftChanged: (d) => onDraftChanged?.call(node.attributes[i].name, d),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String _typeLabel(CLGraphAttributeType t) => switch (t) {
      CLGraphAttributeType.string => 'testo',
      CLGraphAttributeType.numeric => 'numero',
      CLGraphAttributeType.enumeration => 'scelta',
      CLGraphAttributeType.boolean => 'sì/no',
      CLGraphAttributeType.time => 'orario',
      CLGraphAttributeType.url => 'link',
    };

class _AttributeRow extends StatelessWidget {
  const _AttributeRow({
    super.key,
    required this.attribute,
    required this.value,
    required this.draft,
    required this.metrics,
    required this.onDraftChanged,
    this.onChanged,
  });

  final CLGraphNodeAttribute attribute;
  final Object? value;
  final CLGraphFieldDraft? draft;
  final CLGraphCardMetrics metrics;
  final ValueChanged<Object?>? onChanged;
  final ValueChanged<CLGraphFieldDraft?> onDraftChanged;

  @override
  Widget build(BuildContext context) {
    final theme = metrics.theme;
    final a = attribute;
    final label = Tooltip(
      message: '${a.name} · ${_typeLabel(a.type)}${a.nullable ? ' · facoltativo' : ''}',
      child: Text(a.name, style: metrics.smallStyle.copyWith(color: theme.mutedForeground)),
    );
    if (onChanged == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          label,
          const SizedBox(height: 2),
          Text(
            clGraphDisplayValue(value),
            style: metrics.smallStyle.copyWith(color: value == null && !a.nullable ? theme.danger : theme.primaryText),
          ),
        ],
      );
    }
    final error = clGraphRowError(a, value, draft);
    final Widget input;
    if (a.type == CLGraphAttributeType.boolean) {
      input = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox.square(
            dimension: kGraphCheckbox,
            child: _BoolAttributeField(attribute: a, value: value, error: error != null, onChanged: onChanged!),
          ),
          SizedBox(width: theme.gapSm),
          Expanded(child: Padding(padding: const EdgeInsets.only(top: 1), child: label)),
        ],
      );
    } else {
      final field = a.type == CLGraphAttributeType.enumeration
          ? _EnumAttributeField(attribute: a, value: value, error: error != null, metrics: metrics, onChanged: onChanged!)
          : _TextAttributeField(
              attribute: a,
              value: value,
              draft: draft,
              error: error != null,
              metrics: metrics,
              onChanged: onChanged!,
              onDraftChanged: onDraftChanged,
            );
      input = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          label,
          SizedBox(height: theme.gapXs),
          SizedBox(height: metrics.fieldHeight(a, value, draft?.text), child: field),
        ],
      );
    }
    if (error == null) return input;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        input,
        const SizedBox(height: 2),
        Text(error, style: metrics.smallStyle.copyWith(color: theme.danger)),
      ],
    );
  }
}

OutlineInputBorder _border(double radius, Color color, [double width = kGraphFieldBorder]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: width),
    );

/// Campo di testo per string, numeric, time e url. Emette a ogni modifica che
/// produce un valore valido (dopo conversione: virgola decimale, `https://`
/// aggiunto, orario formattato dalla maschera). Un testo non valido non viene
/// emesso: resta nel campo e diventa una bozza ([CLGraphFieldDraft]) col suo
/// errore, mostrato subito se il testo è completo e alla perdita del focus se
/// è ancora a metà. Fuori focus il campo segue il valore dell'host.
class _TextAttributeField extends StatefulWidget {
  const _TextAttributeField({
    required this.attribute,
    required this.value,
    required this.draft,
    required this.error,
    required this.metrics,
    required this.onChanged,
    required this.onDraftChanged,
  });

  final CLGraphNodeAttribute attribute;
  final Object? value;
  final CLGraphFieldDraft? draft;
  final bool error;
  final CLGraphCardMetrics metrics;
  final ValueChanged<Object?> onChanged;
  final ValueChanged<CLGraphFieldDraft?> onDraftChanged;

  @override
  State<_TextAttributeField> createState() => _TextAttributeFieldState();
}

class _TextAttributeFieldState extends State<_TextAttributeField> {
  late final TextEditingController _controller = TextEditingController(text: widget.draft?.text ?? _text(widget.value));
  final FocusNode _focus = FocusNode();

  CLGraphAttributeType get _type => widget.attribute.type;
  bool get _multiline => _type == CLGraphAttributeType.string || _type == CLGraphAttributeType.url;

  String _text(Object? v) => v == null ? '' : clGraphDisplayValue(v);

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant _TextAttributeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Durante la digitazione il testo è dell'utente; fuori focus segue l'host.
    if (_focus.hasFocus) return;
    final hostText = _text(widget.value);
    if (widget.draft == null) {
      if (_controller.text != hostText) _controller.text = hostText;
    } else if (oldWidget.value != widget.value) {
      // L'host ha cambiato valore sotto una bozza non valida: vince l'host.
      _controller.text = hostText;
      final report = widget.onDraftChanged;
      WidgetsBinding.instance.addPostFrameCallback((_) => report(null));
    }
  }

  void _report(CLGraphFieldDraft? draft) {
    if (draft != widget.draft) widget.onDraftChanged(draft);
  }

  void _onText(String text) {
    final r = clGraphParseText(widget.attribute, text);
    if (r.error == null) {
      widget.onChanged(r.value);
      _report(null);
    } else {
      _report(CLGraphFieldDraft(text, r.deferred ? null : r.error));
    }
  }

  void _onFocusChange() {
    if (_focus.hasFocus) return;
    var text = _controller.text;
    final completed = _type == CLGraphAttributeType.time ? clGraphCompleteTime(text) : text;
    final r = clGraphParseText(widget.attribute, completed);
    if (r.error != null) {
      _report(CLGraphFieldDraft(text, r.error)); // ora l'errore si vede, anche se il testo era a metà
      return;
    }
    if (completed != text) widget.onChanged(r.value); // "9" ⇒ "09:00": valore nuovo
    text = _text(r.value); // forma normalizzata: 3,5 ⇒ 3.5, www.sito.it ⇒ https://www.sito.it
    if (_controller.text != text) _controller.text = text;
    _report(null);
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  List<TextInputFormatter>? get _formatters {
    final a = widget.attribute;
    switch (_type) {
      case CLGraphAttributeType.numeric:
        final signed = a.min == null || a.min! < 0;
        final chars = '0-9${a.integer ? '' : '.,'}${signed ? r'\-' : ''}';
        return [FilteringTextInputFormatter.allow(RegExp('[$chars]'))];
      case CLGraphAttributeType.time:
        return const [CLGraphTimeInputFormatter()];
      case CLGraphAttributeType.url:
        return [FilteringTextInputFormatter.deny(RegExp(r'\s'))];
      default:
        return null;
    }
  }

  TextInputType get _keyboard {
    final a = widget.attribute;
    return switch (_type) {
      CLGraphAttributeType.numeric =>
        TextInputType.numberWithOptions(decimal: !a.integer, signed: a.min == null || a.min! < 0),
      CLGraphAttributeType.time => TextInputType.number,
      CLGraphAttributeType.url => TextInputType.url,
      _ => TextInputType.multiline,
    };
  }

  String? get _hint => switch (_type) {
        CLGraphAttributeType.time => 'HH:MM',
        CLGraphAttributeType.url => 'www.sito.it',
        _ => widget.attribute.nullable ? '—' : null,
      };

  @override
  Widget build(BuildContext context) {
    final m = widget.metrics;
    final theme = m.theme;
    return TextField(
      controller: _controller,
      focusNode: _focus,
      onChanged: _onText,
      textAlign: _type == CLGraphAttributeType.numeric ? TextAlign.end : TextAlign.start,
      keyboardType: _keyboard,
      textInputAction: _type == CLGraphAttributeType.string ? TextInputAction.newline : TextInputAction.done,
      inputFormatters: _formatters,
      maxLines: _multiline ? null : 1,
      expands: _multiline,
      textAlignVertical: _multiline ? TextAlignVertical.top : TextAlignVertical.center,
      style: m.smallStyle.copyWith(color: theme.primaryText),
      cursorColor: theme.primary,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: theme.secondaryBackground,
        hintText: _hint,
        hintStyle: m.smallStyle.copyWith(color: theme.mutedForeground),
        contentPadding: EdgeInsets.symmetric(
          horizontal: theme.gapSm,
          vertical: _multiline ? kGraphFieldPadV : _kSingleLinePadV,
        ),
        enabledBorder: _border(theme.radiusChip, widget.error ? theme.danger : theme.cardBorder),
        focusedBorder: _border(theme.radiusChip, widget.error ? theme.danger : theme.primary, 1.5),
      ),
    );
  }
}

/// Scelta fra le alternative di un attributo enumeration. Se nullable, la
/// prima voce "—" azzera il valore. Il valore scelto va a capo se è lungo.
class _EnumAttributeField extends StatelessWidget {
  const _EnumAttributeField({
    required this.attribute,
    required this.value,
    required this.error,
    required this.metrics,
    required this.onChanged,
  });

  final CLGraphNodeAttribute attribute;
  final Object? value;
  final bool error;
  final CLGraphCardMetrics metrics;
  final ValueChanged<Object?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = metrics.theme;
    return PopupMenuButton<Object>(
      tooltip: attribute.name,
      padding: EdgeInsets.zero,
      initialValue: value ?? _kNone,
      onSelected: (v) => onChanged(identical(v, _kNone) ? null : v),
      itemBuilder: (context) => [
        if (attribute.nullable)
          PopupMenuItem<Object>(
            value: _kNone,
            height: 36,
            child: Text('—', style: metrics.smallStyle.copyWith(color: theme.mutedForeground)),
          ),
        for (final o in attribute.options)
          PopupMenuItem<Object>(value: o, height: 36, child: Text(o, style: metrics.smallStyle)),
      ],
      child: Container(
        padding: EdgeInsets.only(left: theme.gapSm, right: theme.gapXs),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(theme.radiusChip),
          border: Border.all(color: error ? theme.danger : theme.cardBorder, width: kGraphFieldBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                clGraphDisplayValue(value),
                style: metrics.smallStyle.copyWith(color: value == null ? theme.mutedForeground : theme.primaryText),
              ),
            ),
            Icon(Icons.expand_more, size: kGraphMenuIcon, color: theme.mutedForeground),
          ],
        ),
      ),
    );
  }
}

/// Checkbox: a tre stati (sì / no / nessun valore) se l'attributo è nullable.
/// Un non nullable ancora senza valore parte dallo stato "vuoto" e al primo
/// tap diventa un booleano.
class _BoolAttributeField extends StatelessWidget {
  const _BoolAttributeField({
    required this.attribute,
    required this.value,
    required this.error,
    required this.onChanged,
  });

  final CLGraphNodeAttribute attribute;
  final Object? value;
  final bool error;
  final ValueChanged<Object?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final v = value as bool?;
    return Checkbox(
      value: v,
      tristate: attribute.nullable || v == null,
      onChanged: (b) => onChanged(attribute.nullable ? b : (b ?? false)),
      activeColor: theme.primary,
      side: BorderSide(color: error ? theme.danger : theme.mutedForeground, width: 1.5),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      splashRadius: 14,
    );
  }
}
