import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import '../cl_popup_surface.widget.dart';
import '../buttons/cl_loading_spinner.widget.dart';
import 'cl_dropdown_registry.dart';

class DropdownState<T extends Object> extends ChangeNotifier implements ISelectableDropdown {
  List<T> items = [];
  final Future<(List<T>, Object?)> Function(
      {int? page,
      int? perPage,
      Map<String, dynamic>? searchBy,
      Map<String, dynamic>? orderBy})? asyncSearchCallback;
  final Future<List<T>> Function(String)? syncSearchCallback;
  int perPage;
  bool loading = false;
  OverlayEntry? _overlayEntry;
  final LayerLink layerLink = LayerLink();
  final Widget Function(BuildContext, T) itemBuilder;
  final String Function(T) valueToShow;
  List<T> selectedItems = [];
  final List<T> previousSelectedItems;
  final Function(T?)? onSelectItem;
  final Function(List<T>)? onSelectItems;
  final Function()? onClearItem;
  T? selectedItem;
  final bool isMultiple;
  GlobalKey textFormFieldKey = GlobalKey();
  final TextEditingController textEditingController = TextEditingController();

  /// Query corrente digitata nel campo trigger. Distinta dal testo del
  /// controller (che può mostrare la label dell'elemento selezionato): viene
  /// valorizzata solo dall'input utente via [onSearch] e usata per il paging.
  String searchQuery = '';
  final BuildContext context;
  final FocusNode focusNode;
  final String? searchColumn;
  bool isOverlayOpen = false;
  bool _closing = false;
  Timer? _searchDebounce;

  /// The hint text for this dropdown — used as key in [CLDropdownRegistry].
  final String? hint;

  /// Se `true`, item del menu più densi (padding verticale ridotto).
  final bool isCompact;

  // ═══════════════════════════════════════════════════════════════════════════
  // INFINITE SCROLL
  // ═══════════════════════════════════════════════════════════════════════════
  int _currentPage = 1;
  bool _hasMorePages = true;
  bool _loadingMore = false;
  ScrollController? _scrollController;

  /// Key sull'item selezionato (single) per auto-scroll all'apertura.
  final GlobalKey _selectedItemKey = GlobalKey();

  /// FocusNode del campo ricerca nel popover (autofocus all'apertura).
  final FocusNode _searchFocusNode = FocusNode();

  /// Nav da tastiera: indice della voce evidenziata (-1 = nessuna) + key per
  /// tenerla in vista mentre ci si muove con le frecce.
  int _highlightedIndex = -1;
  final GlobalKey _highlightKey = GlobalKey();

  bool get _hasSearch =>
      asyncSearchCallback != null || syncSearchCallback != null;

  KeyEventResult handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final k = event.logicalKey;
    if (k == LogicalKeyboardKey.arrowDown) {
      _moveHighlight(1);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.arrowUp) {
      _moveHighlight(-1);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.numpadEnter) {
      if (_highlightedIndex >= 0 && _highlightedIndex < items.length) {
        _selectItem(items[_highlightedIndex]);
      }
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.escape) {
      closeOverlay();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _moveHighlight(int delta) {
    if (items.isEmpty) return;
    final next =
        (_highlightedIndex < 0 ? (delta > 0 ? 0 : items.length - 1) : _highlightedIndex + delta)
            .clamp(0, items.length - 1);
    if (next == _highlightedIndex) return;
    _highlightedIndex = next;
    notifyListeners();
    _overlayEntry?.markNeedsBuild();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _highlightKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx,
            alignment: 0.5, duration: const Duration(milliseconds: 80));
      }
    });
  }

  DropdownState({
    this.items = const [],
    required this.asyncSearchCallback,
    required this.syncSearchCallback,
    required this.context,
    required this.itemBuilder,
    required this.isMultiple,
    required this.valueToShow,
    required this.previousSelectedItems,
    required this.onSelectItems,
    required this.onSelectItem,
    required this.focusNode,
    required this.perPage,
    required this.searchColumn,
    this.onClearItem,
    this.hint,
    this.isCompact = true,
  }) {
    if (isMultiple) {
      assert(onSelectItems != null);
    } else {
      assert(onSelectItem != null);
    }
    _init(previousSelectedItems);
    if (hint != null) {
      CLDropdownRegistry.instance.register(hint!, this);
    }
  }

  /// Programmatically selects an item matching [name].
  /// For async dropdowns: does a targeted API search by name first (large page),
  /// then falls back to the already-loaded items list.
  /// For sync dropdowns: searches the provided items list.
  /// Returns true if an item was found and selected.
  @override
  Future<bool> selectByName(String name) async {
    T? _findMatch() {
      // Exact match first, then partial
      for (final item in items) {
        if (valueToShow(item).toLowerCase() == name.toLowerCase()) return item;
      }
      for (final item in items) {
        if (valueToShow(item).toLowerCase().contains(name.toLowerCase())) return item;
      }
      return null;
    }

    // For async dropdowns: targeted API search with large page size FIRST
    if (asyncSearchCallback != null && searchColumn != null) {
      try {
        loading = true;
        notifyListeners();
        final (values, _) = await asyncSearchCallback!(
          page: 1,
          perPage: 100,
          searchBy: {searchColumn!: name},
        );
        items = values;
      } catch (_) {
        // keep whatever was already loaded
      } finally {
        loading = false;
        notifyListeners();
      }

      final match = _findMatch();
      if (match != null) {
        _selectItem(match);
        return true;
      }

      // Secondary fallback: load first page unfiltered in case the name is partial
      try {
        loading = true;
        notifyListeners();
        final (values, _) = await asyncSearchCallback!(page: 1, perPage: 100);
        items = values;
      } catch (_) {
        // ignore
      } finally {
        loading = false;
        notifyListeners();
      }

      final fallbackMatch = _findMatch();
      if (fallbackMatch != null) {
        _selectItem(fallbackMatch);
        return true;
      }
      return false;
    }

    // Sync dropdown: load items if empty, then match locally
    if (items.isEmpty && syncSearchCallback != null) {
      items = await syncSearchCallback!('');
    }
    final match = _findMatch();
    if (match != null) {
      _selectItem(match);
      return true;
    }
    return false;
  }

  void _init(List<T> previousSelectedItems) {
    _preSelectData(previousSelectedItems);
  }

  Future<void> _prefillData() async {
    if (asyncSearchCallback != null) {
      loading = true;
      _currentPage = 1;
      _hasMorePages = true;
      notifyListeners();
      try {
        var (values, pagination) =
            await asyncSearchCallback!(page: 1, perPage: perPage);
        items = values;
        _hasMorePages = pagination != null
            ? (pagination as dynamic).next != null
            : values.length >= perPage;
      } catch (e) {
        items = [];
        _hasMorePages = false;
      } finally {
        loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _loadNextPage() async {
    if (_loadingMore || !_hasMorePages || asyncSearchCallback == null) return;
    _loadingMore = true;
    notifyListeners();
    _overlayEntry?.markNeedsBuild();

    try {
      final nextPage = _currentPage + 1;
      final Map<String, dynamic>? searchBy =
          searchQuery.isNotEmpty && searchColumn != null
              ? {searchColumn!: searchQuery}
              : null;

      var (values, pagination) = await asyncSearchCallback!(
          page: nextPage, perPage: perPage, searchBy: searchBy);

      if (values.isNotEmpty) {
        _currentPage = nextPage;
        items = [...items, ...values];
      }
      _hasMorePages = pagination != null
          ? (pagination as dynamic).next != null
          : values.length >= perPage;
    } catch (e) {
      _hasMorePages = false;
    } finally {
      _loadingMore = false;
      notifyListeners();
      _overlayEntry?.markNeedsBuild();
    }
  }

  // Affordance scroll: chevron in cima/fondo quando la lista supera il viewport.
  bool _canScrollUp = false;
  bool _canScrollDown = false;

  void _onScrollListener() {
    final sc = _scrollController;
    if (sc == null || !sc.hasClients) return;
    if (sc.position.pixels >= sc.position.maxScrollExtent - 50) {
      _loadNextPage();
    }
    _updateScrollChevrons();
  }

  void _updateScrollChevrons() {
    final sc = _scrollController;
    if (sc == null || !sc.hasClients) return;
    final up = sc.position.pixels > 4;
    final down = sc.position.pixels < sc.position.maxScrollExtent - 4;
    if (up != _canScrollUp || down != _canScrollDown) {
      _canScrollUp = up;
      _canScrollDown = down;
      _overlayEntry?.markNeedsBuild();
    }
  }

  void _preSelectData(List<T> previousSelectedItems) {
    if (isMultiple) {
      selectedItems.addAll(previousSelectedItems);
      _updateMultipleText();
    } else {
      if (previousSelectedItems.isNotEmpty) {
        selectedItem = previousSelectedItems.first;
      }
    }
  }

  /// Sincronizza lo stato interno con eventuali aggiornamenti esterni
  /// (es. selectedValues valorizzati dopo un preload asincrono).
  void syncExternalSelectedItems(List<T> externalSelectedItems) {
    if (isMultiple) {
      if (listEquals(selectedItems, externalSelectedItems)) return;
      // Don't clear programmatic (AI) selections when the parent rebuilds
      // with an empty list — that happens because vm.notifyListeners() fires
      // before the viewmodel's selectedXxx list is updated back through the
      // callback chain.
      if (externalSelectedItems.isEmpty && selectedItems.isNotEmpty) return;
      selectedItems = List<T>.from(externalSelectedItems);
      _updateMultipleText();
      notifyListeners();
      _overlayEntry?.markNeedsBuild();
      return;
    }

    final T? externalSelected =
        externalSelectedItems.isNotEmpty ? externalSelectedItems.first : null;
    if (selectedItem == externalSelected) return;

    selectedItem = externalSelected;
    notifyListeners();
    _overlayEntry?.markNeedsBuild();
  }

  void toggleOverlay() {
    if (isOverlayOpen) {
      closeOverlay();
    } else {
      openOverlay();
    }
  }

  /// `true` quando la lista deve essere presentata come bottom sheet modale
  /// (mobile, width < 600) anziché come overlay ancorato (desktop).
  bool _useBottomSheet = false;

  /// Soglia di breakpoint mobile/desktop (allineata al resto del DS).
  static const double _mobileBreakpoint = 600.0;

  void openOverlay() async {
    if (isOverlayOpen) return;
    _highlightedIndex = -1;

    if (items.isEmpty && asyncSearchCallback != null) {
      await _prefillData();
    }

    _scrollController = ScrollController();
    _scrollController!.addListener(_onScrollListener);

    // Mobile (width < 600) → bottom sheet modale. Desktop → overlay ancorato.
    final isMobile =
        MediaQuery.sizeOf(context).width < _mobileBreakpoint;

    if (isMobile) {
      _useBottomSheet = true;
      isOverlayOpen = true;
      notifyListeners();
      _openBottomSheet();
    } else {
      _useBottomSheet = false;
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
      isOverlayOpen = true;
      notifyListeners();
      // shadcn ensureSelectedVisible: dopo il primo frame, scrolla all'item
      // selezionato (single) così è già visibile all'apertura.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Autofocus sul campo ricerca del popover (se presente).
        _searchFocusNode.requestFocus();
        final ctx = _selectedItemKey.currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(ctx,
              alignment: 0.5,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut);
        }
        _updateScrollChevrons();
      });
    }
  }

  void _openBottomSheet() {
    final theme = CLTheme.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.secondaryBackground,
      barrierColor: kCLModalScrim,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(theme.radiusModal),
        ),
      ),
      builder: (sheetContext) {
        // Riascolta lo stato così la lista del sheet si ricostruisce su
        // search/loading/paging (al pari di markNeedsBuild per l'overlay).
        return ListenableBuilder(
          listenable: this,
          builder: (context, _) {
            final maxH = MediaQuery.sizeOf(context).height * 0.7;
            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Padding(
                      padding: EdgeInsets.only(
                          top: theme.gapMd, bottom: theme.gapSm),
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.borderColor,
                          borderRadius: BorderRadius.circular(theme.radiusPill),
                        ),
                      ),
                    ),
                    Flexible(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: maxH),
                        child: _buildListContent(context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      // Chiusura del sheet (drag/tap-scrim/select) → reset stato come overlay.
      if (_useBottomSheet && isOverlayOpen) {
        _useBottomSheet = false;
        closeOverlay();
      }
    });
  }

  void closeOverlay() {
    if (!isOverlayOpen || _closing) return;
    // Bottom sheet: chiusura gestita dal Navigator (ha la sua animazione).
    if (_useBottomSheet) {
      _finalizeClose();
      return;
    }
    // Desktop: anima l'uscita (reverse del CLPopupSurface) → onDismissed
    // chiama _finalizeClose che rimuove l'overlay.
    _closing = true;
    _overlayEntry?.markNeedsBuild();
  }

  void _finalizeClose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (_useBottomSheet) {
      _useBottomSheet = false;
      final nav = Navigator.maybeOf(context);
      if (nav != null && nav.canPop()) nav.pop();
    }
    isOverlayOpen = false;
    _closing = false;

    _scrollController?.removeListener(_onScrollListener);
    _scrollController?.dispose();
    _scrollController = null;

    if (searchQuery.isNotEmpty) {
      searchQuery = '';
      items = [];
      _currentPage = 1;
      _hasMorePages = true;
    }

    // La ricerca vive nel popover: alla chiusura azzera la query (il trigger
    // è un bottone che legge la selezione, non usa questo controller).
    textEditingController.clear();

    notifyListeners();
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox =
        textFormFieldKey.currentContext!.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    final screenHeight = MediaQuery.of(context).size.height;
    const gap = 4.0;
    const maxDropdownHeight = 250.0;
    // La ricerca ora vive nel campo trigger: l'overlay contiene solo la lista.
    final estimatedHeight = maxDropdownHeight + 16;

    final spaceBelow = screenHeight - (offset.dy + size.height + gap);
    final spaceAbove = offset.dy - gap;

    // Se sotto non c'è abbastanza spazio e sopra c'è più spazio, apri verso l'alto
    final openUpward = spaceBelow < estimatedHeight && spaceAbove > spaceBelow;

    // Limita l'altezza della lista allo spazio disponibile
    final availableSpace = openUpward ? spaceAbove : spaceBelow;
    final listMaxHeight =
        (availableSpace - 16).clamp(80.0, maxDropdownHeight);

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: () {
              closeOverlay();
            },
            behavior: HitTestBehavior.translucent,
          ),
          Positioned(
            width: size.width,
            left: offset.dx,
            top: offset.dy,
            child: CompositedTransformFollower(
              link: layerLink,
              showWhenUnlinked: false,
              targetAnchor:
                  openUpward ? Alignment.topLeft : Alignment.bottomLeft,
              followerAnchor:
                  openUpward ? Alignment.bottomLeft : Alignment.topLeft,
              offset: openUpward ? const Offset(0, -gap) : const Offset(0, gap),
              child: CLPopupSurface(
                animateUpward: openUpward,
                visible: !_closing,
                onDismissed: _finalizeClose,
                // Focus per la nav da tastiera: con search cattura i tasti che
                // il campo non consuma (frecce/invio/esc); senza search prende
                // lui il focus (autofocus) per riceverli.
                child: Focus(
                  onKeyEvent: handleKey,
                  canRequestFocus: !_hasSearch,
                  autofocus: !_hasSearch,
                  skipTraversal: _hasSearch,
                  child: _buildListContent(
                    context,
                    listMaxHeight: listMaxHeight,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Contenuto condiviso (lista + loader + empty + paging/infinite-scroll)
  /// renderizzato sia dall'overlay desktop sia dal bottom sheet mobile.
  /// [listMaxHeight], se fornito, vincola l'altezza della lista (overlay):
  /// nel bottom sheet il vincolo è gestito dal chiamante (Flexible+maxH).
  Widget _buildListContent(BuildContext context, {double? listMaxHeight}) {
    final theme = CLTheme.of(context);

    final bool hasSearch =
        asyncSearchCallback != null || syncSearchCallback != null;

    // Search DENTRO il popover (stile shadcn .withSearch), solo se c'è un
    // searchCallback. Guida sync (filtro) o async (fetch paginato) via
    // onTriggerChanged. Autofocus all'apertura.
    Widget wrap(Widget body, {bool flexBody = true}) {
      if (!hasSearch) {
        return Material(type: MaterialType.transparency, child: body);
      }
      return Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search NUDA (no bordo/ring/pill) ad ALTEZZA input (scala con
            // isCompact come il trigger) → distinta dalle voci del menu.
            // Stile shadcn: icona + input nudo.
            SizedBox(
              height: isCompact ? theme.inputHeightCompact : theme.inputHeight,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: theme.gapMd),
                child: Row(
                  children: [
                    Icon(LucideIcons.search400,
                        size: theme.iconSizeCompact,
                        color: theme.secondaryText),
                    SizedBox(width: theme.gapSm),
                    Expanded(
                      child: TextField(
                        controller: textEditingController,
                        focusNode: _searchFocusNode,
                        style: theme.bodyText.copyWith(height: 1.0),
                        cursorColor: theme.primary,
                        cursorWidth: 1.5,
                        cursorHeight: 18,
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintText: 'Cerca',
                          hintStyle: theme.bodyText.copyWith(
                              color: theme.mutedForeground, height: 1.0),
                        ),
                        onChanged: (value) => onTriggerChanged(value),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Divider tra search e lista (stile shadcn).
            Divider(height: 1, thickness: 1, color: theme.borderColor),
            flexBody ? Flexible(child: body) : body,
          ],
        ),
      );
    }

    if (loading && items.isEmpty) {
      return wrap(
        Container(
          padding: const EdgeInsets.all(Sizes.padding),
          child: Center(
            child: SizedBox(
                width: 20,
                height: 20,
                child: CLLoadingSpinner(size: 20, color: theme.secondaryText)),
          ),
        ),
        flexBody: false,
      );
    }

    if (items.isEmpty) {
      return wrap(
        Container(
          padding: const EdgeInsets.all(Sizes.padding),
          child: Text('Nessun risultato trovato', style: theme.bodyLabel),
        ),
        flexBody: false,
      );
    }

    final Widget list = ListView.separated(
      controller: _scrollController,
      // Padding attorno alla lista (shadcn optionsPadding = all(4)) → le voci e i
      // loro hover-pill restano staccate dai bordi dell'overlay.
      padding: EdgeInsets.all(theme.gapXs),
      shrinkWrap: true,
      itemCount: items.length + (_loadingMore ? 1 : 0),
      // Piccolo gap verticale tra le voci → gli hover-pill hanno margine
      // top/bottom (non si toccano). Nessun divider.
      separatorBuilder: (context, index) => const SizedBox(height: 2),
      itemBuilder: (context, index) {
        // Loader di fine lista
        if (index >= items.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: CLSizes.gapMd),
            child: Center(
                child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CLLoadingSpinner(size: 18, color: theme.secondaryText))),
          );
        }

        var item = items[index];
        final isSelected = isMultiple
            ? selectedItems.contains(item)
            : selectedItem == item;
        final isHighlighted = index == _highlightedIndex;

        return KeyedSubtree(
          // Key sull'item da tenere in vista: highlight (nav tastiera) o, in
          // apertura, il selected single.
          key: isHighlighted
              ? _highlightKey
              : ((!isMultiple && isSelected) ? _selectedItemKey : null),
          child: _DropdownHoverItem(
            onTap: () => _selectItem(item),
            isSelected: isSelected,
            highlighted: isHighlighted,
            // Le voci sono SEMPRE compatte (altezza inputHeightCompact = 32),
            // a prescindere da isCompact: quest'ultimo governa solo trigger +
            // barra ricerca, non la lista.
            child: SizedBox(
              height: theme.inputHeightCompact,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: theme.gapSm),
                child: Row(
                  children: [
                    Expanded(
                      child: DefaultTextStyle.merge(
                        style: theme.bodyText,
                        child: itemBuilder(context, item),
                      ),
                    ),
                    // Check selezionato a DESTRA (trailing, nero), stile shadcn.
                    if (isSelected) ...[
                      SizedBox(width: theme.gapSm),
                      Icon(LucideIcons.check400,
                          size: theme.iconSizeCompact, color: theme.primaryText),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    // Chevron come RIGHE (non overlay): prendono spazio proprio, la lista si
    // accorcia → nessuna voce coperta.
    Widget scrollable = list;
    if (_canScrollUp || _canScrollDown) {
      scrollable = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_canScrollUp) _scrollChevron(theme, up: true),
          Flexible(child: list),
          if (_canScrollDown) _scrollChevron(theme, up: false),
        ],
      );
    }

    final Widget body = (listMaxHeight != null)
        ? ConstrainedBox(
            constraints: BoxConstraints(maxHeight: listMaxHeight),
            child: scrollable,
          )
        : scrollable;
    return wrap(body, flexBody: listMaxHeight != null);
  }

  /// Indicatore di scroll: strip sottile col chevron. Hover → auto-scroll verso
  /// il bordo (shadcn); uscita → stop.
  Widget _scrollChevron(CLTheme theme, {required bool up}) {
    return MouseRegion(
      onEnter: (_) => _autoScroll(up: up),
      onExit: (_) {
        final sc = _scrollController;
        if (sc != null && sc.hasClients) sc.jumpTo(sc.position.pixels);
      },
      child: SizedBox(
        height: 24,
        child: Center(
          child: Icon(
              up ? LucideIcons.chevronUp400 : LucideIcons.chevronDown400,
              size: 14,
              color: theme.secondaryText),
        ),
      ),
    );
  }

  void _autoScroll({required bool up}) {
    final sc = _scrollController;
    if (sc == null || !sc.hasClients) return;
    final target = up ? 0.0 : sc.position.maxScrollExtent;
    final dist = (target - sc.position.pixels).abs();
    if (dist < 1) return;
    sc.animateTo(target,
        duration: Duration(milliseconds: (dist * 3).clamp(200, 1200).toInt()),
        curve: Curves.linear);
  }

  void _selectItem(T item) {
    if (isMultiple) {
      if (!selectedItems.contains(item)) {
        selectedItems.add(item);
        onSelectItems?.call(selectedItems);
      } else {
        selectedItems.remove(item);
        onSelectItems?.call(selectedItems);
      }
      _updateMultipleText();
      notifyListeners();
      _overlayEntry?.markNeedsBuild();
    } else {
      selectedItem = item;
      onSelectItem?.call(selectedItem);
      closeOverlay();
      // Dopo la chiusura il focus si perde (la search viene smontata): lo
      // richiediamo sul trigger così torna l'elemento attivo e il ring da
      // tastiera ricompare.
      WidgetsBinding.instance.addPostFrameCallback((_) => focusNode.requestFocus());
      notifyListeners();
    }
  }

  void removeItem(T item) {
    if (isMultiple) {
      selectedItems.remove(item);
      onSelectItems?.call(selectedItems);
      _updateMultipleText();
    } else {
      selectedItem = null;
      textEditingController.clear();
      _init([]);
      onSelectItem?.call(null);
      onClearItem?.call();
      focusNode.unfocus();
      closeOverlay();
    }
    notifyListeners();
    _overlayEntry?.markNeedsBuild();
  }

  void clearAll() {
    selectedItems.clear();
    onSelectItems?.call(selectedItems);
    _updateMultipleText();
    notifyListeners();
    _overlayEntry?.markNeedsBuild();
  }

  // Il display multi ora lo calcolano il trigger-bottone (formValue) e i chip;
  // il controller resta esclusivo della ricerca nel popover → no-op.
  void _updateMultipleText() {}

  Future<void> onSearch(String? searchColumn, String query) async {
    searchQuery = query;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(searchColumn, query);
    });
  }

  /// Invocata dall'input utente nel campo trigger: registra la query, apre
  /// l'overlay se chiuso e avvia la ricerca (debounced per l'async).
  void onTriggerChanged(String value) {
    if (!isOverlayOpen) {
      openOverlay();
    }
    // Reset dell'evidenziazione: la lista cambia con la query.
    _highlightedIndex = -1;
    onSearch(searchColumn, value);
  }

  Future<void> _performSearch(String? searchColumn, String query) async {
    if (asyncSearchCallback != null) {
      try {
        loading = true;
        _currentPage = 1;
        _hasMorePages = true;
        notifyListeners();

        if (query.isEmpty) {
          var (values, pagination) =
              await asyncSearchCallback!.call(page: 1, perPage: perPage);
          items = values;
          _hasMorePages = pagination != null
              ? (pagination as dynamic).next != null
              : values.length >= perPage;
        } else {
          var (values, pagination) = await asyncSearchCallback!.call(
              page: 1, perPage: perPage, searchBy: {searchColumn!: query});
          items = values;
          _hasMorePages = pagination != null
              ? (pagination as dynamic).next != null
              : values.length >= perPage;
        }
      } catch (e) {
        items = [];
        _hasMorePages = false;
      } finally {
        loading = false;
        notifyListeners();
        if (isOverlayOpen) {
          _overlayEntry?.markNeedsBuild();
        }
      }
    } else if (syncSearchCallback != null) {
      items = await syncSearchCallback!.call(query);
      notifyListeners();
      if (isOverlayOpen) {
        _overlayEntry?.markNeedsBuild();
      }
    }
  }

  @override
  void dispose() {
    // §2.2.7 — cancel pending debounced search before disposing.
    _searchDebounce?.cancel();
    if (hint != null) {
      CLDropdownRegistry.instance.unregister(hint!);
    }
    // Teardown diretto (niente animazione durante il dispose).
    _overlayEntry?.remove();
    _overlayEntry = null;
    _scrollController?.dispose();
    textEditingController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HOVER ITEM WIDGET
// ═══════════════════════════════════════════════════════════════════════════════

class _DropdownHoverItem extends StatefulWidget {
  final VoidCallback onTap;
  final bool isSelected;
  final bool highlighted;
  final Widget child;

  const _DropdownHoverItem(
      {required this.onTap,
      required this.isSelected,
      this.highlighted = false,
      required this.child});

  @override
  State<_DropdownHoverItem> createState() => _DropdownHoverItemState();
}

class _DropdownHoverItemState extends State<_DropdownHoverItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor;
    if (_isHovered || widget.highlighted) {
      // Hover / evidenziazione tastiera → grigio neutro (precede il selected).
      bgColor = theme.secondaryText.withValues(alpha: isDark ? 0.12 : 0.08);
    } else if (widget.isSelected) {
      bgColor = theme.primary.withValues(alpha: isDark ? 0.15 : 0.08);
    } else {
      bgColor = Colors.transparent;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        // Hover/selected = pill ARROTONDATO (shadcn: BoxDecoration + radius),
        // non full-bleed. Con l'optionsPadding della lista → staccato dai bordi.
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(theme.gapSm),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
