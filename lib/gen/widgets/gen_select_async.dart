import 'dart:async';

import 'package:flutter/material.dart';
import 'package:genai_components/gen/theme/gen_tokens.dart';
import 'package:genai_components/gen/theme/gen_sizes.dart';
import 'package:genai_components/gen/primitives/gen_primitives.dart';

/// Callback di ricerca ASINCRONA paginata: ritorna `(elementi, pagination)` dove
/// il secondo campo è opaco. Per rilevare altre pagine si legge (via `dynamic`)
/// il campo `next`: non nullo → c'è una pagina successiva. Se il campo non esiste
/// si ripiega sul conteggio (`elementi.length >= perPage`). Stessa firma di
/// `CLDropdownTableFilterAsync.searchCallback` → i consumer la passano invariata.
typedef GenAsyncSearch<T> = Future<(List<T>, Object?)> Function({
  int? page,
  int? perPage,
  Map<String, dynamic>? searchBy,
  Map<String, dynamic>? orderBy,
});

/// Select a ricerca ASINCRONA costruita sul primitivo Gen ([GenSelect] =
/// `ShadSelect.withSearch`): rimpiazza `CLDropdown.singleAsync` senza dipendere
/// da `lib/old`.
///
/// Ricerca debounced + **paginazione con infinite-scroll**: il primo fetch (o un
/// cambio query) resetta a `page: 1`; avvicinandosi al fondo della lista carica
/// la pagina successiva e accoda i risultati. Spinner nel footer sia durante il
/// fetch iniziale sia durante il caricamento incrementale.
class GenSelectAsync<T extends Object> extends StatefulWidget {
  const GenSelectAsync({
    super.key,
    required this.searchCallback,
    required this.searchColumn,
    required this.optionBuilder,
    required this.valueToShow,
    this.initialValue,
    this.onChanged,
    this.placeholder,
    this.perPage = 100,
    this.debounce = const Duration(milliseconds: 350),
  });

  /// Sorgente dati paginata. Invocata con `searchBy: {searchColumn: query}`.
  final GenAsyncSearch<T> searchCallback;

  /// Nome del campo su cui filtra il backend (chiave di `searchBy`).
  final String searchColumn;

  /// Riga opzione nella tendina.
  final Widget Function(BuildContext, T) optionBuilder;

  /// Testo mostrato nel trigger per il valore selezionato.
  final String Function(T) valueToShow;

  final T? initialValue;
  final ValueChanged<T?>? onChanged;
  final Widget? placeholder;

  /// Dimensione di ogni pagina richiesta al backend.
  final int perPage;

  /// Ritardo di debounce sulla digitazione prima del fetch (reset).
  final Duration debounce;

  @override
  State<GenSelectAsync<T>> createState() => _GenSelectAsyncState<T>();
}

class _GenSelectAsyncState<T extends Object> extends State<GenSelectAsync<T>> {
  final List<T> _options = [];
  final ScrollController _scroll = ScrollController();

  /// Soglia (px dal fondo) entro cui far scattare il caricamento della pagina
  /// successiva → si carica prima di toccare l'ultimo elemento.
  static const double _loadMoreThreshold = 64;

  bool _loading = false; // fetch iniziale / reset ricerca (lista vuota)
  bool _loadingMore = false; // caricamento pagina successiva (append)
  bool _hasMore = true;
  int _currentPage = 1;
  String _query = '';
  Timer? _debounce;

  /// Id dell'ultima richiesta di RESET: scarta le risposte fuori ordine (una
  /// query lenta che ritorna dopo una più recente non deve sovrascrivere) e
  /// aborta i loadMore appartenenti a una ricerca ormai superata.
  int _reqId = 0;

  @override
  void initState() {
    super.initState();
    // Valore iniziale subito tra le opzioni → il trigger non resta "vuoto" in
    // attesa del primo fetch e la voce selezionata è evidenziabile all'apertura.
    if (widget.initialValue != null) _options.add(widget.initialValue as T);
    _scroll.addListener(_onScroll);
    _fetch('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  /// `hasMore` dal `pagination` opaco: `next != null` → altra pagina; se il campo
  /// non esiste, fallback sul conteggio ricevuto vs [GenSelectAsync.perPage].
  bool _computeHasMore(Object? pagination, int received) {
    if (pagination != null) {
      try {
        return (pagination as dynamic).next != null;
      } catch (_) {
        // pagination senza campo `next` → fallback sul conteggio.
      }
    }
    return received >= widget.perPage;
  }

  /// Fetch di RESET: nuova query o primo caricamento. Riparte da `page: 1` e
  /// rimpiazza le opzioni.
  Future<void> _fetch(String query) async {
    final reqId = ++_reqId;
    _query = query;
    _currentPage = 1;
    setState(() => _loading = true);
    try {
      final (values, pagination) = await widget.searchCallback(
        page: 1,
        perPage: widget.perPage,
        searchBy: query.isEmpty ? null : {widget.searchColumn: query},
      );
      if (!mounted || reqId != _reqId) return; // risposta superata → scarta
      setState(() {
        _options
          ..clear()
          ..addAll(values);
        // Mantieni la selezione visibile anche se il fetch non la include.
        final sel = widget.initialValue;
        if (sel != null && !_options.contains(sel)) _options.insert(0, sel);
        _hasMore = _computeHasMore(pagination, values.length);
        _loading = false;
      });
    } catch (_) {
      if (!mounted || reqId != _reqId) return;
      setState(() {
        _hasMore = false;
        _loading = false;
      });
    }
  }

  /// Carica e accoda la pagina successiva (infinite scroll).
  Future<void> _loadMore() async {
    if (_loadingMore || _loading || !_hasMore) return;
    final reqId = _reqId; // se cambia (nuova ricerca reset) → aborta
    setState(() => _loadingMore = true);
    try {
      final nextPage = _currentPage + 1;
      final (values, pagination) = await widget.searchCallback(
        page: nextPage,
        perPage: widget.perPage,
        searchBy: _query.isEmpty ? null : {widget.searchColumn: _query},
      );
      if (!mounted || reqId != _reqId) return; // ricerca superata → scarta
      setState(() {
        if (values.isNotEmpty) {
          _currentPage = nextPage;
          _options.addAll(values);
        }
        _hasMore = _computeHasMore(pagination, values.length);
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted || reqId != _reqId) return;
      setState(() {
        _hasMore = false;
        _loadingMore = false;
      });
    }
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    if (pos.pixels >= pos.maxScrollExtent - _loadMoreThreshold) _loadMore();
  }

  void _onSearch(String query) {
    _debounce?.cancel();
    _debounce = Timer(widget.debounce, () => _fetch(query));
  }

  @override
  Widget build(BuildContext context) {
    final theme = GenTokens.of(context);
    return GenSelect<T>.withSearch(
      placeholder: widget.placeholder,
      initialValue: widget.initialValue,
      onSearchChanged: _onSearch,
      onChanged: widget.onChanged,
      // Controller condiviso con la lista opzioni: ci attacchiamo il listener di
      // infinite-scroll (ShadSelect ci aggiunge il proprio per le chevron).
      scrollController: _scroll,
      selectedOptionBuilder: (context, value) => Text(widget.valueToShow(value)),
      options: [
        for (final it in _options) GenOption<T>(value: it, child: widget.optionBuilder(context, it)),
      ],
      // Spinner in coda alla lista: fetch iniziale (lista vuota) o pagina
      // successiva in arrivo. ShadSelect non ha uno stato di loading → lo diamo noi.
      footer: (_loading || _loadingMore)
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: GenSizes.gapLg),
              // Row min-size (NON Center): il footer si dimensiona sullo spinner e
              // non espande alla maxWidth del popover → l'overlay non si allarga
              // durante il caricamento.
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: GenSizes.iconSizeCompact,
                    height: GenSizes.iconSizeCompact,
                    child: CircularProgressIndicator(strokeWidth: 2, color: theme.secondaryText),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
