import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import '../cl_container.widget.dart';
import '../cl_text_field.widget.dart';

class DropdownState<T extends Object> extends ChangeNotifier {
  List<T> items = [];
  final Future<(List<T>, Object?)> Function({int? page, int? perPage, Map<String, dynamic>? searchBy, Map<String, dynamic>? orderBy})? asyncSearchCallback;
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
  final TextEditingController searchController = TextEditingController();
  final BuildContext context;
  final FocusNode focusNode;
  final String? searchColumn;
  bool isOverlayOpen = false;

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
  }) {
    if (isMultiple) {
      assert(onSelectItems != null);
    } else {
      assert(onSelectItem != null);
    }
    _init(previousSelectedItems);
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
        var (values, pagination) = await asyncSearchCallback!(page: 1, perPage: perPage);
        items = values;
        _hasMorePages = pagination != null ? (pagination as dynamic).next != null : values.length >= perPage;
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
      final searchQuery = searchController.text;
      final Map<String, dynamic>? searchBy = searchQuery.isNotEmpty && searchColumn != null ? {searchColumn!: searchQuery} : null;

      var (values, pagination) = await asyncSearchCallback!(page: nextPage, perPage: perPage, searchBy: searchBy);

      if (values.isNotEmpty) {
        _currentPage = nextPage;
        items = [...items, ...values];
      }
      _hasMorePages = pagination != null ? (pagination as dynamic).next != null : values.length >= perPage;
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

    if (searchController.text.isNotEmpty) {
      searchController.clear();
      items = [];
      _currentPage = 1;
      _hasMorePages = true;
    }

    notifyListeners();
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = textFormFieldKey.currentContext!.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    final screenHeight = MediaQuery.of(context).size.height;
    const gap = 4.0;
    const searchBarHeight = 56.0;
    const maxDropdownHeight = 250.0;
    // Altezza stimata totale dell'overlay (search + lista)
    final hasSearch = syncSearchCallback != null || asyncSearchCallback != null;
    final estimatedHeight = maxDropdownHeight + (hasSearch ? searchBarHeight : 0) + 16;

    final spaceBelow = screenHeight - (offset.dy + size.height + gap);
    final spaceAbove = offset.dy - gap;

    // Se sotto non c'è abbastanza spazio e sopra c'è più spazio, apri verso l'alto
    final openUpward = spaceBelow < estimatedHeight && spaceAbove > spaceBelow;

    // Limita l'altezza della lista allo spazio disponibile
    final availableSpace = openUpward ? spaceAbove : spaceBelow;
    final listMaxHeight = (availableSpace - (hasSearch ? searchBarHeight : 0) - 16).clamp(80.0, maxDropdownHeight);


    return OverlayEntry(
      builder:
          (context) => Stack(
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
                  targetAnchor: openUpward ? Alignment.topLeft : Alignment.bottomLeft,
                  followerAnchor: openUpward ? Alignment.bottomLeft : Alignment.topLeft,
                  offset: openUpward ? const Offset(0, -gap) : const Offset(0, gap),
                  child: CLContainer(
                    contentMargin: EdgeInsets.zero,
                    showShadow: true,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Campo di ricerca nell'overlay
                        if (hasSearch)
                          Padding(
                            padding: const EdgeInsets.all(Sizes.padding / 2),
                            child: Material(
                              type: MaterialType.transparency,
                              child: CLTextField(
                                controller: searchController,
                                labelText: 'Cerca...',
                                prefixIcon: HugeIcon(icon: HugeIcons.strokeRoundedSearch01, color: CLTheme.of(context).secondaryText, size: Sizes.medium),
                                prefixIconConstraints: BoxConstraints(minWidth: Sizes.medium + 16, minHeight: Sizes.medium + 16),
                                onChanged: (value) async {
                                  await onSearch(searchColumn, value);
                                },
                              ),
                            ),
                          ),
                        // Lista degli elementi
                        loading && items.isEmpty
                            ? Material(
                              type: MaterialType.transparency,
                              child: Container(
                                padding: const EdgeInsets.all(Sizes.padding),
                                child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                              ),
                            )
                            : items.isEmpty
                            ? Material(
                              type: MaterialType.transparency,
                              child: Container(
                                padding: const EdgeInsets.all(Sizes.padding),
                                child: Text('Nessun risultato trovato', style: CLTheme.of(context).bodyLabel),
                              ),
                            )
                            : ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: listMaxHeight),
                              child: ListView.builder(
                                controller: _scrollController,
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: items.length + (_loadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  // Loader di fine lista
                                  if (index >= items.length) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                      child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
                                    );
                                  }

                                  var item = items[index];
                                  final isSelected = isMultiple ? selectedItems.contains(item) : selectedItem == item;

                                  return _DropdownHoverItem(
                                    onTap: () => _selectItem(item),
                                    isSelected: isSelected,
                                    child: Material(
                                      type: MaterialType.transparency,
                                      child: ListTile(
                                        titleTextStyle: CLTheme.of(context).bodyText,
                                        title: itemBuilder(context, item),
                                        trailing:
                                            isMultiple
                                                ? Checkbox(
                                                  splashRadius: 0,
                                                  value: selectedItems.contains(item),
                                                  onChanged: (value) {
                                                    _selectItem(item);
                                                  },
                                                  activeColor: CLTheme.of(context).primary,
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
      textEditingController.text = '${selectedItems.length} selezionat${selectedItems.length == 1 ? 'o' : 'i'}';
    }
  }

  Future<void> onSearch(String? searchColumn, String query) async {
    if (asyncSearchCallback != null) {
      try {
        loading = true;
        _currentPage = 1;
        _hasMorePages = true;
        notifyListeners();

        if (query.isEmpty) {
          var (values, pagination) = await asyncSearchCallback!.call(page: 1, perPage: perPage);
          items = values;
          _hasMorePages = pagination != null ? (pagination as dynamic).next != null : values.length >= perPage;
        } else {
          var (values, pagination) = await asyncSearchCallback!.call(page: 1, perPage: perPage, searchBy: {searchColumn!: query});
          items = values;
          _hasMorePages = pagination != null ? (pagination as dynamic).next != null : values.length >= perPage;
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
    closeOverlay();
    searchController.dispose();
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

  const _DropdownHoverItem({required this.onTap, required this.isSelected, required this.child});

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
      bgColor = theme.primary.withValues(alpha: isDark ? 0.08 : 0.04);
    } else {
      bgColor = Colors.transparent;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: widget.onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 150), color: bgColor, child: widget.child)),
    );
  }
}
