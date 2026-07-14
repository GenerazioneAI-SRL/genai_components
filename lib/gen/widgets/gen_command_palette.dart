import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../theme/gen_tokens.dart';
import '../theme/gen_sizes.dart';
import '../primitives/gen_primitives.dart';
import '../primitives/gen_overlays.dart';

/// Voce della command palette. La navigazione è incapsulata in [onSelect]
/// (il widget non conosce le route). [group] raggruppa le voci con un header.
@immutable
class GenCommandItem {
  const GenCommandItem({
    required this.id,
    required this.label,
    required this.onSelect,
    this.description,
    this.icon,
    this.group,
  });

  final String id;
  final String label;
  final String? description;
  final IconData? icon;
  final String? group;
  final VoidCallback onSelect;
}

/// Command palette / ricerca globale. Estetica di un [GenSelect] con ricerca:
/// UNA superficie (card popover) con search field borderless in cima, divider,
/// e lista opzioni raggruppate sotto. Ricerca statica ([items]) + opzionale
/// [asyncSearch] con debounce e guard di obsolescenza. Navigazione tastiera
/// (↑/↓/Enter/Esc). Aprire con [GenCommandPalette.show].
class GenCommandPalette extends StatefulWidget {
  const GenCommandPalette({
    super.key,
    this.items = const [],
    this.previewItems,
    this.asyncSearch,
    this.minQueryLength = 1,
    this.debounce = const Duration(milliseconds: 300),
    this.onAskAi,
    this.hintText = 'Cerca comandi, pagine…',
    this.emptyText = 'Nessun risultato',
    this.askAiLabel = 'Chiedi all\'assistente',
  });

  final List<GenCommandItem> items;

  /// Mostrati SOLO a query vuota; fallback su [items].
  final List<GenCommandItem>? previewItems;

  /// Ricerca async (BE/repo). Combinata coi risultati statici.
  final Future<List<GenCommandItem>> Function(String query)? asyncSearch;

  final int minQueryLength;
  final Duration debounce;

  /// Se non-null: a 0 risultati e query non vuota mostra la riga "chiedi all'AI".
  final void Function(String query)? onAskAi;

  final String hintText;
  final String emptyText;
  final String askAiLabel;

  /// Apre la palette come modal centrata (fade/scale via showGenDialog).
  static Future<void> show(
    BuildContext context, {
    List<GenCommandItem> items = const [],
    List<GenCommandItem>? previewItems,
    Future<List<GenCommandItem>> Function(String query)? asyncSearch,
    int minQueryLength = 1,
    Duration debounce = const Duration(milliseconds: 300),
    void Function(String query)? onAskAi,
    String hintText = 'Cerca comandi, pagine…',
    String emptyText = 'Nessun risultato',
    String askAiLabel = 'Chiedi all\'assistente',
  }) {
    return showGenDialog<void>(
      context: context,
      opaque: false,
      builder: (_) => GenCommandPalette(
        items: items,
        previewItems: previewItems,
        asyncSearch: asyncSearch,
        minQueryLength: minQueryLength,
        debounce: debounce,
        onAskAi: onAskAi,
        hintText: hintText,
        emptyText: emptyText,
        askAiLabel: askAiLabel,
      ),
    );
  }

  @override
  State<GenCommandPalette> createState() => _GenCommandPaletteState();
}

class _GenCommandPaletteState extends State<GenCommandPalette> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  final _keyboardFocus = FocusNode();

  String _query = '';
  List<GenCommandItem> _asyncResults = const [];
  bool _loading = false;
  Timer? _debounce;
  int _searchSeq = 0;

  /// Callback attivabili (una per riga selezionabile, header esclusi). Ricostruita
  /// a ogni build; l'indice keyboard/hover [_selected] indicizza qui.
  final List<VoidCallback> _selectable = [];
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onQueryChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _searchFocus.requestFocus());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    _keyboardFocus.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    final q = _searchController.text;
    if (q == _query) return;
    setState(() {
      _query = q;
      _selected = 0;
    });
    _debounce?.cancel();
    final async = widget.asyncSearch;
    if (async == null) return;
    if (q.trim().length < widget.minQueryLength) {
      setState(() {
        _asyncResults = const [];
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    _debounce = Timer(widget.debounce, () async {
      final seq = ++_searchSeq;
      try {
        final res = await async(q);
        if (!mounted || seq != _searchSeq) return; // guard obsolescenza
        setState(() {
          _asyncResults = res;
          _loading = false;
        });
      } catch (_) {
        if (!mounted || seq != _searchSeq) return;
        setState(() {
          _asyncResults = const [];
          _loading = false;
        });
      }
    });
  }

  List<GenCommandItem> get _localHits {
    if (_query.trim().isEmpty) return widget.previewItems ?? widget.items;
    final q = _query.toLowerCase();
    return widget.items.where((it) {
      return it.label.toLowerCase().contains(q) || (it.description?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  List<GenCommandItem> get _hits => [..._localHits, ..._asyncResults];

  void _move(int delta) {
    if (_selectable.isEmpty) return;
    setState(() => _selected = (_selected + delta) % _selectable.length);
  }

  void _activate(int index) {
    if (index < 0 || index >= _selectable.length) return;
    final cb = _selectable[index];
    Navigator.of(context).pop(); // pop PRIMA: la navigazione parte su stack pulito
    cb();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        _move(1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        _move(-1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.numpadEnter:
        if (_selectable.isNotEmpty) _activate(_selected);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.escape:
        Navigator.of(context).pop();
        return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    return Align(
      alignment: const Alignment(0, -0.35),
      child: Padding(
        padding: EdgeInsets.all(t.gapLg),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 560, maxHeight: MediaQuery.sizeOf(context).height * 0.7),
          child: Focus(
            focusNode: _keyboardFocus,
            onKeyEvent: _onKey,
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: t.secondaryBackground,
                  borderRadius: BorderRadius.circular(GenSizes.radiusModal),
                  border: Border.all(color: t.borderColor),
                  boxShadow: t.popoverShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search field borderless (come ShadSelect.withSearch).
                    GenInput(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      placeholder: Text(widget.hintText),
                      padding: EdgeInsets.all(t.gapMd),
                      decoration: const ShadDecoration(
                        border: ShadBorder.none,
                        focusedBorder: ShadBorder.none,
                      ),
                      leading: Padding(
                        padding: EdgeInsets.only(right: t.gapSm),
                        child: Icon(LucideIcons.search, size: t.iconSizeCompact, color: t.secondaryText),
                      ),
                      trailing: _loading
                          ? Padding(
                              padding: EdgeInsets.only(left: t.gapSm),
                              child: SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: t.secondaryText),
                              ),
                            )
                          : null,
                    ),
                    GenSeparator.horizontal(margin: EdgeInsets.zero),
                    Flexible(child: _results(t)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _results(GenTokens t) {
    final rows = _buildRows(t);
    if (rows.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(t.gapLg * 1.5),
        child: Center(
          child: Text(_loading ? 'Ricerca…' : widget.emptyText,
              style: t.bodyText.copyWith(color: t.secondaryText)),
        ),
      );
    }
    return ListView(
      padding: EdgeInsets.all(t.gapXs),
      shrinkWrap: true,
      children: rows,
    );
  }

  List<Widget> _buildRows(GenTokens t) {
    _selectable.clear();
    final rows = <Widget>[];
    // Raggruppa per group nell'ordine di prima apparizione.
    final grouped = <String?, List<GenCommandItem>>{};
    for (final it in _hits) {
      (grouped[it.group] ??= []).add(it);
    }
    grouped.forEach((group, items) {
      if (group != null) rows.add(_groupHeader(t, group, items.length));
      for (final it in items) {
        final idx = _selectable.length;
        _selectable.add(it.onSelect);
        rows.add(_row(t, it, idx));
      }
    });
    if (widget.onAskAi != null && _query.trim().isNotEmpty && _hits.isEmpty) {
      final idx = _selectable.length;
      _selectable.add(() => widget.onAskAi!(_query));
      rows.add(_askAiRow(t, idx));
    }
    if (_selected >= _selectable.length) _selected = _selectable.isEmpty ? 0 : _selectable.length - 1;
    return rows;
  }

  Widget _groupHeader(GenTokens t, String label, int count) => Padding(
        padding: EdgeInsets.fromLTRB(t.gapSm, t.gapSm, t.gapSm, t.gapXs),
        child: Text('$label · $count', style: t.smallLabel.copyWith(color: t.secondaryText)),
      );

  Widget _row(GenTokens t, GenCommandItem it, int index) => _HoverRow(
        selected: index == _selected,
        onHover: () => setState(() => _selected = index),
        onTap: () => _activate(index),
        child: Row(
          children: [
            if (it.icon != null) ...[
              Icon(it.icon!, size: t.iconSizeDefault, color: t.secondaryText),
              SizedBox(width: t.gapMd),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(it.label, style: t.bodyLabel.copyWith(color: t.primaryText), overflow: TextOverflow.ellipsis, maxLines: 1),
                  if (it.description != null)
                    Text(it.description!, style: t.smallText.copyWith(color: t.secondaryText), overflow: TextOverflow.ellipsis, maxLines: 1),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _askAiRow(GenTokens t, int index) => _HoverRow(
        selected: index == _selected,
        onHover: () => setState(() => _selected = index),
        onTap: () => _activate(index),
        child: Row(
          children: [
            Icon(LucideIcons.sparkles, size: t.iconSizeDefault, color: t.primary),
            SizedBox(width: t.gapMd),
            Expanded(
              child: Text('${widget.askAiLabel}: "$_query"',
                  style: t.bodyLabel.copyWith(color: t.primary), overflow: TextOverflow.ellipsis, maxLines: 1),
            ),
          ],
        ),
      );
}

/// Riga selezionabile: hover/keyboard condividono lo stato via [selected].
class _HoverRow extends StatelessWidget {
  const _HoverRow({required this.child, required this.selected, required this.onHover, required this.onTap});

  final Widget child;
  final bool selected;
  final VoidCallback onHover;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    return MouseRegion(
      onEnter: (_) => onHover(),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: t.gapSm, vertical: t.gapSm),
          decoration: BoxDecoration(
            color: selected ? t.accent : null,
            borderRadius: BorderRadius.circular(GenSizes.radiusControl),
          ),
          child: child,
        ),
      ),
    );
  }
}
