import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import 'cl_command_item.model.dart';

/// Command palette / global search stile shadcn — generica e decoupled.
///
/// Due sorgenti, combinabili:
///  - [items]: lista statica/locale, filtrata client-side su `label`/`description`.
///  - [asyncSearch]: callback async (es. fan-out su repository/BE). Debounced
///    ([debounce]), parte solo da [minQueryLength] caratteri, con guard di
///    obsolescenza (le risposte in volo di query superate vengono ignorate).
///
/// I risultati sono raggruppati per [CLCommandItem.group] (header per gruppo;
/// gli item senza group restano in cima senza header). La navigazione è
/// incapsulata in [CLCommandItem.onSelect] → il widget NON conosce le route.
///
/// [onAskAi] opzionale: quando la query non produce risultati, mostra una riga
/// "chiedi all'AI" selezionabile. L'app decide cosa significhi.
class CLCommandPalette extends StatefulWidget {
  final List<CLCommandItem> items;

  /// Voci mostrate SOLO a query vuota (anteprima "principali"). Se null si
  /// ricade su [items]. La ricerca digitata filtra sempre [items] (+ async).
  final List<CLCommandItem>? previewItems;
  final Future<List<CLCommandItem>> Function(String query)? asyncSearch;
  final int minQueryLength;
  final Duration debounce;
  final void Function(String query)? onAskAi;
  final String? askAiLabel;
  final String? hintText;
  final String? emptyText;

  const CLCommandPalette({
    super.key,
    this.items = const [],
    this.previewItems,
    this.asyncSearch,
    this.minQueryLength = 1,
    this.debounce = const Duration(milliseconds: 300),
    this.onAskAi,
    this.askAiLabel,
    this.hintText,
    this.emptyText,
  });

  static Future<void> show(
    BuildContext context, {
    List<CLCommandItem> items = const [],
    List<CLCommandItem>? previewItems,
    Future<List<CLCommandItem>> Function(String query)? asyncSearch,
    int minQueryLength = 1,
    Duration debounce = const Duration(milliseconds: 300),
    void Function(String query)? onAskAi,
    String? askAiLabel,
    String? hintText,
    String? emptyText,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'CLCommand',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (ctx, _, __) => CLCommandPalette(
        items: items,
        previewItems: previewItems,
        asyncSearch: asyncSearch,
        minQueryLength: minQueryLength,
        debounce: debounce,
        onAskAi: onAskAi,
        askAiLabel: askAiLabel,
        hintText: hintText,
        emptyText: emptyText,
      ),
      transitionBuilder: (ctx, anim, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1.0).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOut),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  State<CLCommandPalette> createState() => _CLCommandPaletteState();
}

class _CLCommandPaletteState extends State<CLCommandPalette> {
  final _search = TextEditingController();
  final _focus = FocusNode();
  final _keyboardFocus = FocusNode();

  String _query = '';
  Timer? _debounceTimer;
  int _searchSeq = 0; // guard di obsolescenza per le risposte async
  bool _loading = false;
  List<CLCommandItem> _asyncResults = const [];

  // Ricalcolato a ogni build: gli item selezionabili nell'ordine visivo, per
  // mappare l'indice tastiera (frecce/Enter) ignorando gli header di gruppo.
  List<VoidCallback> _selectable = const [];
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _search.dispose();
    _focus.dispose();
    _keyboardFocus.dispose();
    super.dispose();
  }

  void _onSearch(String raw) {
    final q = raw.trim();
    setState(() {
      _query = q;
      _selected = 0;
    });

    _debounceTimer?.cancel();
    final seq = ++_searchSeq;

    if (widget.asyncSearch == null || q.length < widget.minQueryLength) {
      // Nessuna sorgente async o query troppo corta → reset risultati async.
      if (_asyncResults.isNotEmpty || _loading) {
        setState(() {
          _asyncResults = const [];
          _loading = false;
        });
      }
      return;
    }

    setState(() => _loading = true);
    _debounceTimer = Timer(widget.debounce, () => _runAsync(q, seq));
  }

  Future<void> _runAsync(String q, int seq) async {
    try {
      final res = await widget.asyncSearch!(q);
      if (!mounted || seq != _searchSeq) return; // risposta obsoleta → ignora
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
  }

  List<CLCommandItem> get _localHits {
    if (_query.isEmpty) return widget.previewItems ?? widget.items;
    final q = _query.toLowerCase();
    return widget.items
        .where((i) => i.label.toLowerCase().contains(q) || (i.description?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  void _activate(VoidCallback onSelect) {
    // Pop PRIMA: l'azione (es. navigazione go_router) parte su stack pulito,
    // senza che il dialog overlay intercetti/annulli il go.
    Navigator.of(context).pop();
    onSelect();
  }

  void _move(int delta) {
    if (_selectable.isEmpty) return;
    // Dart `%` con divisore positivo è sempre ≥ 0 → wrap-around senza branch extra.
    setState(() => _selected = (_selected + delta) % _selectable.length);
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);

    final hits = [..._localHits, ..._asyncResults];

    // Gruppi nell'ordine di prima apparizione; item senza group → header null.
    final groupOrder = <String?>[];
    final grouped = <String?, List<CLCommandItem>>{};
    for (final h in hits) {
      final key = (h.group?.isEmpty ?? true) ? null : h.group;
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
        groupOrder.add(key);
      }
      grouped[key]!.add(h);
    }

    // Costruisce righe + callback selezionabili (header esclusi dalla nav).
    final rows = <Widget>[];
    final selectable = <VoidCallback>[];
    for (final key in groupOrder) {
      if (key != null) rows.add(_groupHeader(theme, key, grouped[key]!.length));
      for (final item in grouped[key]!) {
        final index = selectable.length;
        selectable.add(item.onSelect);
        rows.add(_resultRow(theme, item, index));
      }
    }

    final showAskAi = widget.onAskAi != null && _query.isNotEmpty && hits.isEmpty && !_loading;
    if (showAskAi) {
      final index = selectable.length;
      final q = _query;
      selectable.add(() => widget.onAskAi!(q));
      rows.add(_askAiRow(theme, q, index));
    }

    _selectable = selectable;
    if (_selected >= _selectable.length) _selected = 0;

    // Due bolle separate: barra di ricerca (tonda) sopra, elenco risultati sotto.
    final shadow = [
      BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, 8)),
    ];
    final showResults = rows.isNotEmpty || _loading || _query.isNotEmpty;

    return Center(
      child: KeyboardListener(
        focusNode: _keyboardFocus,
        onKeyEvent: (e) {
          if (e is! KeyDownEvent) return;
          if (e.logicalKey == LogicalKeyboardKey.arrowDown) {
            _move(1);
          } else if (e.logicalKey == LogicalKeyboardKey.arrowUp) {
            _move(-1);
          } else if (e.logicalKey == LogicalKeyboardKey.enter || e.logicalKey == LogicalKeyboardKey.numpadEnter) {
            if (_selectable.isNotEmpty) _activate(_selectable[_selected]);
          } else if (e.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.of(context).pop();
          }
        },
        child: Material(
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560, maxHeight: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Bolla ricerca (tonda) ──
                Container(
                  decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(theme.radiusPill),
                    border: Border.all(color: theme.cardBorder),
                    boxShadow: shadow,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: theme.gapLg, vertical: theme.gapMd),
                  child: Row(
                    children: [
                      Icon(Icons.search, size: 18, color: theme.mutedForeground),
                      SizedBox(width: theme.gapSm),
                      Expanded(
                        child: TextField(
                          controller: _search,
                          focusNode: _focus,
                          onChanged: _onSearch,
                          style: theme.bodyText,
                          decoration: InputDecoration(
                            hintText: widget.hintText ?? 'Cerca…',
                            hintStyle: theme.bodyText.copyWith(color: theme.mutedForeground),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (_loading) ...[
                        SizedBox(width: theme.gapSm),
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: theme.mutedForeground),
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Bolla risultati (separata) ──
                if (showResults) ...[
                  SizedBox(height: theme.gapMd),
                  Flexible(
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground,
                        borderRadius: BorderRadius.circular(theme.radiusModal),
                        border: Border.all(color: theme.cardBorder),
                        boxShadow: shadow,
                      ),
                      child: rows.isEmpty
                          ? Padding(
                              padding: EdgeInsets.all(theme.gap3Xl),
                              child: Text(
                                _loading ? 'Ricerca…' : (widget.emptyText ?? 'Nessun risultato'),
                                style: theme.bodyLabel,
                                textAlign: TextAlign.center,
                              ),
                            )
                          // Padding verticale gapSm: tiene la prima/ultima riga
                          // dentro le curve del radiusModal (no clip agli angoli).
                          : ListView(
                              shrinkWrap: true,
                              padding: EdgeInsets.symmetric(horizontal: theme.gapSm, vertical: theme.gapMd),
                              children: rows,
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _groupHeader(CLTheme theme, String label, int count) {
    return Padding(
      padding: EdgeInsets.fromLTRB(theme.gapMd, theme.gapSm, theme.gapMd, theme.gapXs),
      child: Text(
        '$label · $count',
        style: theme.smallLabel.copyWith(
          color: theme.mutedForeground,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _resultRow(CLTheme theme, CLCommandItem item, int index) {
    final isSelected = index == _selected;
    return _HoverRow(
      isSelected: isSelected,
      onTap: () => _activate(item.onSelect),
      onHover: () => setState(() => _selected = index),
      child: Row(
        children: [
          if (item.icon != null) ...[
            Icon(item.icon, size: 16, color: isSelected ? theme.primaryText : theme.mutedForeground),
            SizedBox(width: theme.gapSm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(item.label, style: theme.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                if (item.description != null)
                  Text(item.description!, style: theme.bodyLabel, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _askAiRow(CLTheme theme, String query, int index) {
    final isSelected = index == _selected;
    return _HoverRow(
      isSelected: isSelected,
      onTap: () => _activate(() => widget.onAskAi!(query)),
      onHover: () => setState(() => _selected = index),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_outlined, size: 16, color: theme.primary),
          SizedBox(width: theme.gapSm),
          Expanded(
            child: Text(
              widget.askAiLabel ?? 'Chiedi all’AI: “$query”',
              style: theme.title.copyWith(color: theme.primary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Riga con hover + highlight selezione (frecce/mouse condividono `_selected`).
class _HoverRow extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onHover;
  final Widget child;

  const _HoverRow({
    required this.isSelected,
    required this.onTap,
    required this.onHover,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    return MouseRegion(
      onEnter: (_) => onHover(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: theme.gapMd, vertical: theme.gapSm),
          decoration: BoxDecoration(
            color: isSelected ? theme.accent : null,
            borderRadius: BorderRadius.circular(Sizes.borderRadius - 2),
          ),
          child: child,
        ),
      ),
    );
  }
}
