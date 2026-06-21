import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import '../cl_popup_surface.widget.dart';
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
  Timer? _searchDebounce;

  /// The hint text for this dropdown — used as key in [CLDropdownRegistry].
  final String? hint;

  /// Se `true`, item del menu più densi (ListTile dense).
  final bool isCompact;

  // ═══════════════════════════════════════════════════════════════════════════
  // INFINITE SCROLL
  // ═══════════════════════════════════════════════════════════════════════════
  int _currentPage = 1;
  bool _hasMorePages = true;
  bool _loadingMore = false;
  ScrollController? _scrollController;

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

  void _onScrollListener() {
    final sc = _scrollController;
    if (sc == null || !sc.hasClients) return;
    if (sc.position.pixels >= sc.position.maxScrollExtent - 50) {
      _loadNextPage();
    }
  }

  void _preSelectData(List<T> previousSelectedItems) {
    if (isMultiple) {
      selectedItems.addAll(previousSelectedItems);
      _updateMultipleText();
    } else {
      if (previousSelectedItems.isNotEmpty) {
        selectedItem = previousSelectedItems.first;
        textEditingController.text = valueToShow(selectedItem!);
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
    if (externalSelected != null) {
      textEditingController.text = valueToShow(externalSelected);
    } else {
      textEditingController.clear();
    }

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

  void openOverlay() async {
    if (isOverlayOpen) return;

    if (items.isEmpty && asyncSearchCallback != null) {
      await _prefillData();
    }

    _scrollController = ScrollController();
    _scrollController!.addListener(_onScrollListener);

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    isOverlayOpen = true;
    notifyListeners();
  }

  void closeOverlay() {
    if (!isOverlayOpen) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    isOverlayOpen = false;

    _scrollController?.removeListener(_onScrollListener);
    _scrollController?.dispose();
    _scrollController = null;

    if (searchQuery.isNotEmpty) {
      searchQuery = '';
      items = [];
      _currentPage = 1;
      _hasMorePages = true;
    }

    // Il campo trigger ospita la ricerca: alla chiusura ripristina il testo
    // mostrato (label selezionata / conteggio multiplo) scartando la query.
    if (isMultiple) {
      _updateMultipleText();
    } else if (selectedItem != null) {
      textEditingController.text = valueToShow(selectedItem!);
    } else {
      textEditingController.clear();
    }

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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Lista degli elementi (la ricerca vive nel campo trigger)
                    loading && items.isEmpty
                        ? Material(
                            type: MaterialType.transparency,
                            child: Container(
                              padding: const EdgeInsets.all(Sizes.padding),
                              child: const Center(
                                  child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))),
                            ),
                          )
                        : items.isEmpty
                            ? Material(
                                type: MaterialType.transparency,
                                child: Container(
                                  padding: const EdgeInsets.all(Sizes.padding),
                                  child: Text('Nessun risultato trovato',
                                      style: CLTheme.of(context).bodyLabel),
                                ),
                              )
                            : ConstrainedBox(
                                constraints:
                                    BoxConstraints(maxHeight: listMaxHeight),
                                child: ListView.separated(
                                  controller: _scrollController,
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount:
                                      items.length + (_loadingMore ? 1 : 0),
                                  separatorBuilder: (context, index) => Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: CLTheme.of(context).borderColor,
                                  ),
                                  itemBuilder: (context, index) {
                                    // Loader di fine lista
                                    if (index >= items.length) {
                                      return const Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: CLSizes.gapMd),
                                        child: Center(
                                            child: SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2))),
                                      );
                                    }

                                    var item = items[index];
                                    final isSelected = isMultiple
                                        ? selectedItems.contains(item)
                                        : selectedItem == item;

                                    return _DropdownHoverItem(
                                      onTap: () => _selectItem(item),
                                      isSelected: isSelected,
                                      child: Material(
                                        type: MaterialType.transparency,
                                        child: ListTile(
                                          dense: isCompact,
                                          visualDensity: isCompact
                                              ? VisualDensity.compact
                                              : null,
                                          titleTextStyle:
                                              CLTheme.of(context).bodyText,
                                          title: itemBuilder(context, item),
                                          trailing: isMultiple
                                              ? Checkbox(
                                                  splashRadius: 0,
                                                  // In compact: niente floor 48px
                                                  // del tap target Material.
                                                  materialTapTargetSize: isCompact
                                                      ? MaterialTapTargetSize
                                                          .shrinkWrap
                                                      : MaterialTapTargetSize
                                                          .padded,
                                                  visualDensity: isCompact
                                                      ? VisualDensity.compact
                                                      : null,
                                                  value: selectedItems
                                                      .contains(item),
                                                  onChanged: (value) {
                                                    _selectItem(item);
                                                  },
                                                  activeColor:
                                                      CLTheme.of(context)
                                                          .primary,
                                                  checkColor: Colors.white,
                                                )
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
      textEditingController.text = valueToShow(item);
      onSelectItem?.call(selectedItem);
      closeOverlay();
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

  void _updateMultipleText() {
    if (selectedItems.isEmpty) {
      textEditingController.clear();
    } else {
      textEditingController.text =
          '${selectedItems.length} selezionat${selectedItems.length == 1 ? 'o' : 'i'}';
    }
  }

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
    closeOverlay();
    textEditingController.dispose();
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HOVER ITEM WIDGET
// ═══════════════════════════════════════════════════════════════════════════════

class _DropdownHoverItem extends StatefulWidget {
  final VoidCallback onTap;
  final bool isSelected;
  final Widget child;

  const _DropdownHoverItem(
      {required this.onTap, required this.isSelected, required this.child});

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
    if (widget.isSelected) {
      bgColor = theme.primary.withValues(alpha: isDark ? 0.15 : 0.08);
    } else if (_isHovered) {
      // Hover grigio neutro (stesso standard delle voci di menu), non tint blu.
      bgColor = theme.secondaryText.withValues(alpha: isDark ? 0.12 : 0.08);
    } else {
      bgColor = Colors.transparent;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              color: bgColor,
              child: widget.child)),
    );
  }
}
