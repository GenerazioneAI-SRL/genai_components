import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genai_components/cl_theme.dart';
import 'cl_graph_attributes.dart';
import 'cl_graph_models.dart';

const double _kFieldW = 112; // larghezza dell'input a destra della riga
const double _kFieldH = 26;
const Object _kNone = Object(); // voce "nessun valore" nel menu enumeration (null chiude il menu)

/// Righe attributo di una card: etichetta a sinistra, input (o valore in sola
/// lettura) a destra. `CLNodeGraph` la posiziona sotto l'intestazione della
/// card e le riserva l'hit-test, così il pointer arriva agli input invece di
/// trascinare il nodo.
class CLGraphAttributesSection extends StatelessWidget {
  const CLGraphAttributesSection({
    super.key,
    required this.node,
    this.onChanged,
    this.onInteract,
  });

  final CLGraphNode node;
  /// Nuovo valore per l'attributo `name`. Null ⇒ sola lettura.
  final void Function(String name, Object? value)? onChanged;
  /// Pointer-down in un punto qualsiasi della sezione (selezione del nodo).
  final VoidCallback? onInteract;

  @override
  Widget build(BuildContext context) {
    assert(node.attributesProblem == null, node.attributesProblem);
    final theme = CLTheme.of(context);
    final values = node.resolvedAttributeValues;
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => onInteract?.call(),
      child: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: theme.gapMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(height: 1, color: theme.cardBorder),
              SizedBox(height: theme.gapXs - 1),
              for (final a in node.attributes)
                SizedBox(
                  height: kGraphAttributeRowH,
                  child: _AttributeRow(
                    key: ValueKey('${node.id}/${a.name}'),
                    attribute: a,
                    value: values[a.name],
                    onChanged: onChanged == null ? null : (v) => onChanged!(a.name, v),
                  ),
                ),
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
    };

String _formatNum(num n) {
  final s = n.toString();
  return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
}

/// Testo di un valore in sola lettura (e nel bottone del menu).
String _display(Object? v) => switch (v) {
      null => '—',
      final bool b => b ? 'Sì' : 'No',
      final num n => _formatNum(n),
      _ => v.toString(),
    };

class _AttributeRow extends StatelessWidget {
  const _AttributeRow({super.key, required this.attribute, required this.value, this.onChanged});

  final CLGraphNodeAttribute attribute;
  final Object? value;
  final ValueChanged<Object?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final a = attribute;
    final missing = value == null && !a.nullable; // non nullable senza valore né default
    final Widget field;
    if (onChanged == null) {
      field = Align(
        alignment: Alignment.centerRight,
        child: Text(
          _display(value),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.smallText.copyWith(color: missing ? theme.danger : theme.primaryText),
        ),
      );
    } else {
      field = switch (a.type) {
        CLGraphAttributeType.string || CLGraphAttributeType.numeric =>
          _TextAttributeField(attribute: a, value: value, missing: missing, onChanged: onChanged!),
        CLGraphAttributeType.enumeration =>
          _EnumAttributeField(attribute: a, value: value, missing: missing, onChanged: onChanged!),
        CLGraphAttributeType.boolean =>
          _BoolAttributeField(attribute: a, value: value, missing: missing, onChanged: onChanged!),
      };
    }
    return Row(
      children: [
        Expanded(
          child: Tooltip(
            message: '${a.name} · ${_typeLabel(a.type)}${a.nullable ? ' · facoltativo' : ''}',
            child: Text(
              a.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.smallText.copyWith(color: theme.mutedForeground),
            ),
          ),
        ),
        SizedBox(width: theme.gapSm),
        SizedBox(width: _kFieldW, height: _kFieldH, child: field),
      ],
    );
  }
}

OutlineInputBorder _border(CLTheme theme, Color color, [double width = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(theme.radiusChip),
      borderSide: BorderSide(color: color, width: width),
    );

/// Campo testo (string) o numerico (numeric). Emette a ogni modifica valida;
/// un numero non valido resta evidenziato e non viene emesso. Il testo si
/// riallinea al valore dell'host quando il campo perde il focus.
class _TextAttributeField extends StatefulWidget {
  const _TextAttributeField({
    required this.attribute,
    required this.value,
    required this.missing,
    required this.onChanged,
  });

  final CLGraphNodeAttribute attribute;
  final Object? value;
  final bool missing;
  final ValueChanged<Object?> onChanged;

  @override
  State<_TextAttributeField> createState() => _TextAttributeFieldState();
}

class _TextAttributeFieldState extends State<_TextAttributeField> {
  late final TextEditingController _controller = TextEditingController(text: _text(widget.value));
  final FocusNode _focus = FocusNode();
  bool _invalid = false;

  bool get _numeric => widget.attribute.type == CLGraphAttributeType.numeric;

  String _text(Object? v) => v == null ? '' : _display(v);

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant _TextAttributeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Durante la digitazione il testo è dell'utente; fuori focus segue l'host.
    if (!_focus.hasFocus && _controller.text != _text(widget.value)) {
      _controller.text = _text(widget.value);
      _invalid = false;
    }
  }

  void _onFocusChange() {
    if (_focus.hasFocus) return;
    setState(() {
      _controller.text = _text(widget.value);
      _invalid = false;
    });
  }

  void _onText(String text) {
    final a = widget.attribute;
    if (!_numeric) {
      setState(() => _invalid = false);
      widget.onChanged(text.isEmpty && a.nullable ? null : text);
      return;
    }
    final t = text.trim().replaceAll(',', '.');
    if (t.isEmpty) {
      setState(() => _invalid = !a.nullable);
      if (a.nullable) widget.onChanged(null);
      return;
    }
    final n = num.tryParse(t);
    final ok = n != null && n.isFinite;
    setState(() => _invalid = !ok);
    if (ok) widget.onChanged(n);
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final error = _invalid || (widget.missing && _controller.text.isEmpty);
    return TextField(
      controller: _controller,
      focusNode: _focus,
      onChanged: _onText,
      textAlign: _numeric ? TextAlign.end : TextAlign.start,
      keyboardType: _numeric ? const TextInputType.numberWithOptions(decimal: true, signed: true) : TextInputType.text,
      inputFormatters: _numeric ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\-]'))] : null,
      maxLines: 1,
      style: theme.smallText.copyWith(color: theme.primaryText),
      cursorColor: theme.primary,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: theme.secondaryBackground,
        hintText: widget.attribute.nullable ? '—' : null,
        hintStyle: theme.smallText.copyWith(color: theme.mutedForeground),
        contentPadding: EdgeInsets.symmetric(horizontal: theme.gapSm, vertical: 7),
        enabledBorder: _border(theme, error ? theme.danger : theme.cardBorder),
        focusedBorder: _border(theme, error ? theme.danger : theme.primary, 1.5),
      ),
    );
  }
}

/// Scelta fra le alternative di un attributo enumeration. Se nullable, la
/// prima voce "—" azzera il valore.
class _EnumAttributeField extends StatelessWidget {
  const _EnumAttributeField({
    required this.attribute,
    required this.value,
    required this.missing,
    required this.onChanged,
  });

  final CLGraphNodeAttribute attribute;
  final Object? value;
  final bool missing;
  final ValueChanged<Object?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
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
            child: Text('—', style: theme.smallText.copyWith(color: theme.mutedForeground)),
          ),
        for (final o in attribute.options)
          PopupMenuItem<Object>(value: o, height: 36, child: Text(o, style: theme.smallText)),
      ],
      child: Container(
        height: _kFieldH,
        padding: EdgeInsets.only(left: theme.gapSm, right: theme.gapXs),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(theme.radiusChip),
          border: Border.all(color: missing ? theme.danger : theme.cardBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _display(value),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.smallText.copyWith(color: value == null ? theme.mutedForeground : theme.primaryText),
              ),
            ),
            Icon(Icons.expand_more, size: 14, color: theme.mutedForeground),
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
    required this.missing,
    required this.onChanged,
  });

  final CLGraphNodeAttribute attribute;
  final Object? value;
  final bool missing;
  final ValueChanged<Object?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final v = value as bool?;
    return Align(
      alignment: Alignment.centerRight,
      child: Checkbox(
        value: v,
        tristate: attribute.nullable || v == null,
        onChanged: (b) => onChanged(attribute.nullable ? b : (b ?? false)),
        activeColor: theme.primary,
        side: BorderSide(color: missing ? theme.danger : theme.mutedForeground, width: 1.5),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        splashRadius: 14,
      ),
    );
  }
}
