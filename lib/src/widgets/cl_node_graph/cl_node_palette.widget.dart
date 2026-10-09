import 'package:flutter/material.dart';
import 'package:genai_components/cl_theme.dart';

/// Larghezza sotto cui l'editor a nodi passa alla forma compatta: la palette
/// diventa un menu e il pannello laterale un foglio dal basso. Stessa soglia
/// dei menu di `CLPopupMenu`.
const double kCLNodeEditorCompactWidth = 600;

/// Dice ai widget dell'editor (es. [CLNodePalette]) se il contenitore è in
/// forma compatta. Lo inserisce `CLNodeEditorLayout`; senza, decide la
/// larghezza della finestra.
class CLNodeEditorScope extends InheritedWidget {
  final bool compact;
  const CLNodeEditorScope({super.key, required this.compact, required super.child});

  static bool? compactOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CLNodeEditorScope>()?.compact;

  @override
  bool updateShouldNotify(CLNodeEditorScope oldWidget) => oldWidget.compact != compact;
}

/// Un tipo di nodo nella [CLNodePalette]: trascinato sul canvas di
/// `CLNodeGraph` arriva a `onNodeDrop(type, position)`.
@immutable
class CLNodePaletteItem {
  /// Tipo del nodo (es. 'IF', 'EMAIL'): è il valore passato a `onNodeDrop`.
  final String type;
  final String label;

  /// Gruppo in cui compare (es. 'Inneschi', 'Logica'). Null ⇒ «Altro».
  final String? category;
  final IconData? icon;

  /// Una riga di spiegazione (tooltip e ricerca).
  final String? description;

  /// Colore dell'icona. Null ⇒ `theme.primary`.
  final Color? color;

  const CLNodePaletteItem({
    required this.type,
    required this.label,
    this.category,
    this.icon,
    this.description,
    this.color,
  });
}

/// Palette dei tipi di nodo da comporre accanto a `CLNodeGraph`: elenco
/// raggruppato per categoria con icona e ricerca; ogni voce si **trascina** sul
/// canvas (che chiama `onNodeDrop`) o si **tocca** ([onItemSelected], per
/// aggiungere senza trascinare: l'host sceglie la posizione).
///
/// Forma compatta (schermi stretti, [compact] o larghezza della finestra sotto
/// [kCLNodeEditorCompactWidth]): un pulsante che apre lo stesso elenco in un
/// foglio dal basso; lì le voci si toccano soltanto.
///
/// Nella forma estesa occupa l'altezza che riceve (serve un vincolo d'altezza,
/// es. dentro `CLNodeEditorLayout` o un `Expanded`).
class CLNodePalette extends StatefulWidget {
  final List<CLNodePaletteItem> items;

  /// Tocco su una voce (o scelta dal menu nella forma compatta).
  final void Function(CLNodePaletteItem item)? onItemSelected;

  /// Forma compatta forzata (true) o estesa (false). Null ⇒ da
  /// [CLNodeEditorScope] (dentro `CLNodeEditorLayout`), altrimenti dalla
  /// larghezza della finestra.
  final bool? compact;
  final String title;
  final String searchHint;

  /// Etichetta del pulsante della forma compatta.
  final String menuLabel;
  final String emptyText;

  /// Nome del gruppo delle voci senza categoria.
  final String otherCategory;

  const CLNodePalette({
    super.key,
    required this.items,
    this.onItemSelected,
    this.compact,
    this.title = 'Blocchi',
    this.searchHint = 'Cerca un blocco',
    this.menuLabel = 'Aggiungi blocco',
    this.emptyText = 'Nessun blocco trovato',
    this.otherCategory = 'Altro',
  });

  /// Voci che corrispondono a [query] (maiuscole e accenti ignorati) su
  /// etichetta, categoria, descrizione e tipo, raggruppate per categoria
  /// nell'ordine di prima comparsa.
  static Map<String, List<CLNodePaletteItem>> filterAndGroup(
    List<CLNodePaletteItem> items,
    String query, {
    String otherCategory = 'Altro',
  }) {
    final q = _fold(query.trim());
    final groups = <String, List<CLNodePaletteItem>>{};
    for (final it in items) {
      final hay = _fold('${it.label} ${it.category ?? ''} ${it.description ?? ''} ${it.type}');
      if (q.isNotEmpty && !hay.contains(q)) continue;
      (groups[it.category ?? otherCategory] ??= []).add(it);
    }
    return groups;
  }

  static String _fold(String s) {
    const from = 'àáâäèéêëìíîïòóôöùúûüç';
    const to = 'aaaaeeeeiiiioooouuuuc';
    final lower = s.toLowerCase();
    final b = StringBuffer();
    for (final ch in lower.split('')) {
      final i = from.indexOf(ch);
      b.write(i < 0 ? ch : to[i]);
    }
    return b.toString();
  }

  @override
  State<CLNodePalette> createState() => _CLNodePaletteState();
}

class _CLNodePaletteState extends State<CLNodePalette> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _isCompact(BuildContext context) =>
      widget.compact ??
      CLNodeEditorScope.compactOf(context) ??
      MediaQuery.sizeOf(context).width < kCLNodeEditorCompactWidth;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    if (_isCompact(context)) return _menuButton(context, theme);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(theme.gapMd, theme.gapMd, theme.gapMd, theme.gapSm),
          child: Text(widget.title, style: theme.bodyLabel),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: theme.gapMd),
          child: _searchField(theme, _search, () => setState(() {})),
        ),
        SizedBox(height: theme.gapSm),
        Expanded(
          child: _PaletteList(
            groups: CLNodePalette.filterAndGroup(widget.items, _search.text, otherCategory: widget.otherCategory),
            emptyText: widget.emptyText,
            draggable: true,
            onTap: widget.onItemSelected,
          ),
        ),
      ],
    );
  }

  Widget _menuButton(BuildContext context, CLTheme theme) => Tooltip(
        message: widget.menuLabel,
        child: Material(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(theme.radiusControl),
          child: InkWell(
            borderRadius: BorderRadius.circular(theme.radiusControl),
            onTap: () => _openSheet(context),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: theme.gapMd, vertical: theme.gapSm),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.add, size: theme.iconSizeCompact, color: theme.primaryText),
                SizedBox(width: theme.gapIconText),
                Text(widget.menuLabel, style: theme.smallText),
              ]),
            ),
          ),
        ),
      );

  Future<void> _openSheet(BuildContext context) async {
    final theme = CLTheme.of(context);
    final picked = await showModalBottomSheet<CLNodePaletteItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.secondaryBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(theme.radiusModal))),
      builder: (ctx) => _PaletteSheet(
        items: widget.items,
        title: widget.title,
        searchHint: widget.searchHint,
        emptyText: widget.emptyText,
        otherCategory: widget.otherCategory,
      ),
    );
    if (picked != null) widget.onItemSelected?.call(picked);
  }

  Widget _searchField(CLTheme theme, TextEditingController c, VoidCallback onChanged) =>
      _PaletteSearchField(controller: c, hint: widget.searchHint, onChanged: onChanged);
}

class _PaletteSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback onChanged;
  const _PaletteSearchField({required this.controller, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(theme.radiusControl),
          borderSide: BorderSide(color: c),
        );
    return SizedBox(
      height: theme.inputHeightCompact,
      child: TextField(
        controller: controller,
        onChanged: (_) => onChanged(),
        style: theme.smallText,
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle: theme.smallText.copyWith(color: theme.mutedForeground),
          prefixIcon: Icon(Icons.search, size: theme.iconSizeCompact, color: theme.mutedForeground),
          prefixIconConstraints: BoxConstraints(minWidth: theme.gap3Xl, minHeight: theme.gap3Xl),
          contentPadding: EdgeInsets.symmetric(horizontal: theme.gapSm),
          enabledBorder: border(theme.borderColor),
          focusedBorder: border(theme.ring),
        ),
      ),
    );
  }
}

/// Foglio dal basso della forma compatta: ricerca + elenco, tocco ⇒ chiude e
/// restituisce la voce.
class _PaletteSheet extends StatefulWidget {
  final List<CLNodePaletteItem> items;
  final String title;
  final String searchHint;
  final String emptyText;
  final String otherCategory;
  const _PaletteSheet({
    required this.items,
    required this.title,
    required this.searchHint,
    required this.emptyText,
    required this.otherCategory,
  });

  @override
  State<_PaletteSheet> createState() => _PaletteSheetState();
}

class _PaletteSheetState extends State<_PaletteSheet> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final mq = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: SizedBox(
        height: mq.size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(theme.gapLg, theme.gapLg, theme.gapLg, theme.gapSm),
              child: Text(widget.title, style: theme.bodyLabel),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: theme.gapLg),
              child: _PaletteSearchField(controller: _search, hint: widget.searchHint, onChanged: () => setState(() {})),
            ),
            SizedBox(height: theme.gapSm),
            Expanded(
              child: _PaletteList(
                groups: CLNodePalette.filterAndGroup(widget.items, _search.text, otherCategory: widget.otherCategory),
                emptyText: widget.emptyText,
                draggable: false,
                onTap: (item) => Navigator.of(context).pop(item),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaletteList extends StatelessWidget {
  final Map<String, List<CLNodePaletteItem>> groups;
  final String emptyText;
  final bool draggable;
  final void Function(CLNodePaletteItem item)? onTap;
  const _PaletteList({required this.groups, required this.emptyText, required this.draggable, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    if (groups.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(theme.gapMd),
        child: Text(emptyText, style: theme.smallText.copyWith(color: theme.mutedForeground)),
      );
    }
    final rows = <Widget>[];
    for (final g in groups.entries) {
      rows.add(Padding(
        padding: EdgeInsets.fromLTRB(theme.gapMd, theme.gapMd, theme.gapMd, theme.gapXs),
        child: Semantics(
          header: true,
          child: Text(g.key.toUpperCase(), style: theme.smallText.copyWith(color: theme.mutedForeground)),
        ),
      ));
      for (final it in g.value) {
        rows.add(_PaletteTile(item: it, draggable: draggable, onTap: onTap));
      }
    }
    return ListView(padding: EdgeInsets.only(bottom: theme.gapMd), children: rows);
  }
}

class _PaletteTile extends StatelessWidget {
  final CLNodePaletteItem item;
  final bool draggable;
  final void Function(CLNodePaletteItem item)? onTap;
  const _PaletteTile({required this.item, required this.draggable, this.onTap});

  Widget _row(CLTheme theme) => Row(children: [
        Icon(item.icon ?? Icons.widgets_outlined, size: theme.iconSizeCompact, color: item.color ?? theme.primary),
        SizedBox(width: theme.gapSm),
        Flexible(child: Text(item.label, style: theme.smallText.copyWith(color: theme.primaryText))),
      ]);

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    Widget tile = Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap == null ? null : () => onTap!(item),
        borderRadius: BorderRadius.circular(theme.radiusControl),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: theme.gapMd, vertical: theme.gapSm),
          child: _row(theme),
        ),
      ),
    );
    if (item.description != null) tile = Tooltip(message: item.description!, child: tile);
    tile = Semantics(
      button: true,
      label: item.description == null ? item.label : '${item.label}: ${item.description}',
      excludeSemantics: true,
      child: tile,
    );
    if (!draggable) return tile;
    return Draggable<CLNodePaletteItem>(
      data: item,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Material(
        color: theme.secondaryBackground,
        elevation: 0,
        borderRadius: BorderRadius.circular(theme.radiusControl),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: theme.gapMd, vertical: theme.gapSm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(theme.radiusControl),
            border: Border.all(color: item.color ?? theme.primary),
            boxShadow: theme.cardShadow,
          ),
          child: IntrinsicWidth(child: _row(theme)),
        ),
      ),
      childWhenDragging: Opacity(opacity: theme.opacityDisabled, child: tile),
      child: MouseRegion(cursor: SystemMouseCursors.grab, child: tile),
    );
  }
}
