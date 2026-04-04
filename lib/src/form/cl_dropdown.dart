import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../theme/cl_theme_provider.dart';
import '../layout/cl_container.dart';
import 'cl_text_field.dart'; // used inside the overlay search field

/// A searchable dropdown with single/multiple selection and sync/async data.
///
/// Use the factory constructors for common configurations:
/// - [CLDropdown.single] — single selection from a static list
/// - [CLDropdown.singleAsync] — single selection with async search/pagination
/// - [CLDropdown.multiple] — multiple selection from a static list
/// - [CLDropdown.multipleAsync] — multiple selection with async search/pagination
///
/// ```dart
/// CLDropdown.single(
///   hint: 'Select country',
///   items: countries,
///   valueToShow: (c) => c.name,
///   itemBuilder: (ctx, c) => Text(c.name),
///   onSelectItem: (c) => setState(() => _country = c),
/// )
/// ```
class CLDropdown<T extends Object> extends StatefulWidget {
  final String hint;
  final List<T> items;
  final String Function(T) valueToShow;
  final Widget Function(BuildContext, T) itemBuilder;
  final bool isMultiple;
  final bool isEnabled;
  final List<T> selectedValues;
  final Function(T?)? onSelectItem;
  final Function(List<T>)? onSelectItems;
  final Function()? onClearItem;
  final Future<List<T>> Function(String)? syncSearchCallback;
  final Future<(List<T>, Object?)> Function({
    int? page,
    int? perPage,
    Map<String, dynamic>? searchBy,
    Map<String, dynamic>? orderBy,
  })? asyncSearchCallback;
  final String? searchColumn;
  final int perPage;
  final List<FormFieldValidator<String>>? validators;

  const CLDropdown._({
    super.key,
    required this.hint,
    required this.items,
    required this.valueToShow,
    required this.itemBuilder,
    required this.isMultiple,
    required this.selectedValues,
    this.isEnabled = true,
    this.onSelectItem,
    this.onSelectItems,
    this.onClearItem,
    this.syncSearchCallback,
    this.asyncSearchCallback,
    this.searchColumn,
    this.perPage = 10,
    this.validators,
  });

  // ── Factory constructors ────────────────────────────────────────────────────

  /// Single selection from a static list (optionally searchable via [searchCallback]).
  factory CLDropdown.single({
    Key? key,
    required String hint,
    required List<T> items,
    required String Function(T) valueToShow,
    required Widget Function(BuildContext, T) itemBuilder,
    required Function(T?)? onSelectItem,
    Future<List<T>> Function(String)? searchCallback,
    T? selectedValue,
    Function()? onClearItem,
    bool isEnabled = true,
    int perPage = 10,
    List<FormFieldValidator<String>>? validators,
  }) {
    return CLDropdown._(
      key: key,
      hint: hint,
      items: items,
      isMultiple: false,
      isEnabled: isEnabled,
      valueToShow: valueToShow,
      itemBuilder: itemBuilder,
      selectedValues: selectedValue != null ? [selectedValue] : [],
      onSelectItem: onSelectItem,
      syncSearchCallback: searchCallback,
      onClearItem: onClearItem,
      perPage: perPage,
      validators: validators,
    );
  }

  /// Single selection with async search and optional pagination.
  factory CLDropdown.singleAsync({
    Key? key,
    required String hint,
    required String Function(T) valueToShow,
    required Widget Function(BuildContext, T) itemBuilder,
    required Function(T?)? onSelectItem,
    required Future<(List<T>, Object?)> Function({
      int? page,
      int? perPage,
      Map<String, dynamic>? searchBy,
      Map<String, dynamic>? orderBy,
    })? asyncSearchCallback,
    required String? searchColumn,
    T? selectedValue,
    Function()? onClearItem,
    bool isEnabled = true,
    int perPage = 10,
    List<FormFieldValidator<String>>? validators,
  }) {
    return CLDropdown._(
      key: key,
      hint: hint,
      items: const [],
      isMultiple: false,
      isEnabled: isEnabled,
      valueToShow: valueToShow,
      itemBuilder: itemBuilder,
      selectedValues: selectedValue != null ? [selectedValue] : [],
      onSelectItem: onSelectItem,
      asyncSearchCallback: asyncSearchCallback,
      searchColumn: searchColumn,
      onClearItem: onClearItem,
      perPage: perPage,
      validators: validators,
    );
  }

  /// Multiple selection from a static list (optionally searchable via [searchCallback]).
  factory CLDropdown.multiple({
    Key? key,
    required String hint,
    required List<T> items,
    required String Function(T) valueToShow,
    required Widget Function(BuildContext, T) itemBuilder,
    required Function(List<T>)? onSelectItems,
    Future<List<T>> Function(String)? searchCallback,
    List<T> selectedValues = const [],
    int perPage = 10,
    List<FormFieldValidator<String>>? validators,
  }) {
    return CLDropdown._(
      key: key,
      hint: hint,
      items: items,
      isMultiple: true,
      valueToShow: valueToShow,
      itemBuilder: itemBuilder,
      selectedValues: selectedValues,
      onSelectItems: onSelectItems,
      syncSearchCallback: searchCallback,
      perPage: perPage,
      validators: validators,
    );
  }

  /// Multiple selection with async search and optional pagination.
  factory CLDropdown.multipleAsync({
    Key? key,
    required String hint,
    required String Function(T) valueToShow,
    required Widget Function(BuildContext, T) itemBuilder,
    required Function(List<T>)? onSelectItems,
    required Future<(List<T>, Object?)> Function({
      int? page,
      int? perPage,
      Map<String, dynamic>? searchBy,
      Map<String, dynamic>? orderBy,
    })? asyncSearchCallback,
    required String? searchColumn,
    List<T> selectedValues = const [],
    int perPage = 10,
    List<FormFieldValidator<String>>? validators,
  }) {
    return CLDropdown._(
      key: key,
      hint: hint,
      items: const [],
      isMultiple: true,
      valueToShow: valueToShow,
      itemBuilder: itemBuilder,
      selectedValues: selectedValues,
      onSelectItems: onSelectItems,
      asyncSearchCallback: asyncSearchCallback,
      searchColumn: searchColumn,
      perPage: perPage,
      validators: validators,
    );
  }

  @override
  State<CLDropdown<T>> createState() => _CLDropdownState<T>();
}

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class _CLDropdownState<T extends Object> extends State<CLDropdown<T>> {
  late _DropdownController<T> _controller;

  @override
  void initState() {
    super.initState();
    _controller = _DropdownController<T>(
      items: widget.items,
      asyncSearchCallback: widget.asyncSearchCallback,
      syncSearchCallback: widget.syncSearchCallback,
      isMultiple: widget.isMultiple,
      valueToShow: widget.valueToShow,
      itemBuilder: widget.itemBuilder,
      onSelectItem: widget.onSelectItem,
      onSelectItems: widget.onSelectItems,
      onClearItem: widget.onClearItem,
      previousSelectedItems: widget.selectedValues,
      perPage: widget.perPage,
      searchColumn: widget.searchColumn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<_DropdownController<T>>.value(
      value: _controller,
      child: _CLDropdownView<T>(
        hint: widget.hint,
        isMultiple: widget.isMultiple,
        isEnabled: widget.isEnabled,
        validators: widget.validators,
        valueToShow: widget.valueToShow,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// View
// ─────────────────────────────────────────────────────────────────────────────

class _CLDropdownView<T extends Object> extends StatelessWidget {
  final String hint;
  final bool isMultiple;
  final bool isEnabled;
  final List<FormFieldValidator<String>>? validators;
  final String Function(T) valueToShow;

  const _CLDropdownView({
    required this.hint,
    required this.isMultiple,
    required this.isEnabled,
    required this.valueToShow,
    this.validators,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<_DropdownController<T>>();
    final theme = CLThemeProvider.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Selected chips (multiple mode) ──────────────────────────────────
        if (isMultiple && state.selectedItems.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ...state.selectedItems.map(
                (item) => Container(
                  padding: const EdgeInsets.only(left: 10, right: 4, top: 4, bottom: 4),
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          valueToShow(item),
                          style: theme.smallLabel.copyWith(
                            color: theme.primary,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 2),
                      GestureDetector(
                        onTap: () => state.removeItem(item),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: theme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(Icons.close_rounded, size: 14, color: theme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (state.selectedItems.length > 1)
                GestureDetector(
                  onTap: state.clearAll,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.danger.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.danger.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.clear_all_rounded, size: 14, color: theme.danger),
                        const SizedBox(width: 4),
                        Text(
                          'Svuota',
                          style: theme.smallLabel.copyWith(
                            color: theme.danger,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],

        // ── Trigger field ────────────────────────────────────────────────────
        CompositedTransformTarget(
          link: state.layerLink,
          child: _DropdownTrigger<T>(
            fieldKey: state.fieldKey,
            controller: state.textController,
            hint: hint,
            isEnabled: isEnabled,
            isOpen: state.isOpen,
            loading: state.loading,
            selectedItem: state.selectedItem,
            isMultiple: isMultiple,
            validators: validators,
            onTap: isEnabled ? state.toggleOverlay : null,
            onClear: (state.selectedItem != null && !isMultiple)
                ? () => state.removeItem(state.selectedItem as T)
                : null,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trigger widget (the tappable field that opens the dropdown)
// ─────────────────────────────────────────────────────────────────────────────

class _DropdownTrigger<T extends Object> extends StatelessWidget {
  final GlobalKey fieldKey;
  final TextEditingController controller;
  final String hint;
  final bool isEnabled;
  final bool isOpen;
  final bool loading;
  final T? selectedItem;
  final bool isMultiple;
  final List<FormFieldValidator<String>>? validators;
  final VoidCallback? onTap;
  final VoidCallback? onClear;

  const _DropdownTrigger({
    required this.fieldKey,
    required this.controller,
    required this.hint,
    required this.isEnabled,
    required this.isOpen,
    required this.loading,
    required this.selectedItem,
    required this.isMultiple,
    this.validators,
    this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);

    Widget? suffix;
    if (!isEnabled) {
      suffix = null;
    } else if (loading) {
      suffix = const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (selectedItem != null && !isMultiple && onClear != null) {
      suffix = GestureDetector(
        onTap: onClear,
        child: Icon(Icons.close_rounded, size: 18, color: theme.danger.withValues(alpha: 0.8)),
      );
    } else {
      suffix = FaIcon(
        isOpen ? FontAwesomeIcons.chevronUp : FontAwesomeIcons.chevronDown,
        size: 12,
        color: theme.textSecondary,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(hint, style: theme.smallLabel),
        SizedBox(height: theme.xs),
        GestureDetector(
          key: fieldKey,
          onTap: isEnabled ? onTap : null,
          child: MouseRegion(
            cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
            child: FormField<String>(
              validator: validators != null
                  ? (value) {
                      for (final v in validators!) {
                        final result = v(controller.text);
                        if (result != null) return result;
                      }
                      return null;
                    }
                  : null,
              builder: (field) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isEnabled
                          ? theme.surface
                          : theme.surface.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(theme.radiusMd),
                      border: Border.all(
                        color: field.hasError
                            ? theme.danger
                            : isOpen
                                ? theme.primary
                                : theme.border,
                        width: isOpen ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ValueListenableBuilder<TextEditingValue>(
                            valueListenable: controller,
                            builder: (_, value, __) => Text(
                              value.text.isEmpty ? '' : value.text,
                              style: value.text.isEmpty
                                  ? theme.bodyText.copyWith(color: theme.textSecondary)
                                  : theme.bodyText,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        if (suffix != null) ...[
                          const SizedBox(width: 8),
                          suffix,
                        ],
                      ],
                    ),
                  ),
                  if (field.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 4),
                      child: Text(
                        field.errorText!,
                        style: theme.smallText.copyWith(color: theme.danger),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Controller (ChangeNotifier)
// ─────────────────────────────────────────────────────────────────────────────

class _DropdownController<T extends Object> extends ChangeNotifier {
  List<T> items;
  final Future<(List<T>, Object?)> Function({
    int? page,
    int? perPage,
    Map<String, dynamic>? searchBy,
    Map<String, dynamic>? orderBy,
  })? asyncSearchCallback;
  final Future<List<T>> Function(String)? syncSearchCallback;
  final String Function(T) valueToShow;
  final Widget Function(BuildContext, T) itemBuilder;
  final bool isMultiple;
  final Function(T?)? onSelectItem;
  final Function(List<T>)? onSelectItems;
  final Function()? onClearItem;
  final String? searchColumn;
  final int perPage;

  final LayerLink layerLink = LayerLink();
  final GlobalKey fieldKey = GlobalKey();
  final TextEditingController textController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  List<T> selectedItems = [];
  T? selectedItem;
  bool loading = false;
  bool isOpen = false;

  OverlayEntry? _overlayEntry;
  ScrollController? _scrollController;
  int _currentPage = 1;
  bool _hasMorePages = true;
  bool _loadingMore = false;

  _DropdownController({
    required List<T> items,
    required this.asyncSearchCallback,
    required this.syncSearchCallback,
    required this.isMultiple,
    required this.valueToShow,
    required this.itemBuilder,
    required this.onSelectItem,
    required this.onSelectItems,
    required this.onClearItem,
    required List<T> previousSelectedItems,
    required this.perPage,
    required this.searchColumn,
  }) : items = List<T>.from(items) {
    _preSelect(previousSelectedItems);
  }

  void _preSelect(List<T> initial) {
    if (isMultiple) {
      selectedItems.addAll(initial);
      _syncMultipleText();
    } else if (initial.isNotEmpty) {
      selectedItem = initial.first;
      textController.text = valueToShow(selectedItem!);
    }
  }

  void _syncMultipleText() {
    if (selectedItems.isEmpty) {
      textController.clear();
    } else {
      final n = selectedItems.length;
      textController.text = '$n selezionat${n == 1 ? 'o' : 'i'}';
    }
  }

  // ── Overlay ──────────────────────────────────────────────────────────────

  void toggleOverlay() => isOpen ? closeOverlay() : _openOverlay();

  Future<void> _openOverlay() async {
    if (isOpen) return;

    if (items.isEmpty && asyncSearchCallback != null) {
      await _fetchPage(reset: true);
    }

    _scrollController = ScrollController()..addListener(_onScroll);
    _overlayEntry = _buildOverlay();

    // We need a valid context to insert into Overlay.
    // The fieldKey's context is the CompositedTransformTarget in the widget tree.
    final overlayState = Overlay.of(fieldKey.currentContext!);
    overlayState.insert(_overlayEntry!);
    isOpen = true;
    notifyListeners();
  }

  void closeOverlay() {
    if (!isOpen) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    isOpen = false;

    _scrollController?.removeListener(_onScroll);
    _scrollController?.dispose();
    _scrollController = null;

    if (searchController.text.isNotEmpty) {
      searchController.clear();
      if (asyncSearchCallback != null) {
        items = [];
        _currentPage = 1;
        _hasMorePages = true;
      }
    }
    notifyListeners();
  }

  void _onScroll() {
    final sc = _scrollController;
    if (sc == null || !sc.hasClients) return;
    if (sc.position.pixels >= sc.position.maxScrollExtent - 50) {
      _loadNextPage();
    }
  }

  // ── Data fetching ────────────────────────────────────────────────────────

  Future<void> _fetchPage({required bool reset, String? query}) async {
    if (asyncSearchCallback == null) return;
    if (reset) {
      loading = true;
      _currentPage = 1;
      _hasMorePages = true;
      notifyListeners();
    }
    try {
      final Map<String, dynamic>? searchBy =
          (query != null && query.isNotEmpty && searchColumn != null) ? {searchColumn!: query} : null;
      final (values, pagination) = await asyncSearchCallback!(
        page: _currentPage,
        perPage: perPage,
        searchBy: searchBy,
      );
      if (reset) {
        items = values;
      } else {
        items = [...items, ...values];
      }
      _hasMorePages = pagination != null
          ? (pagination as dynamic).next != null
          : values.length >= perPage;
    } catch (_) {
      if (reset) items = [];
      _hasMorePages = false;
    } finally {
      loading = false;
      notifyListeners();
      _overlayEntry?.markNeedsBuild();
    }
  }

  Future<void> _loadNextPage() async {
    if (_loadingMore || !_hasMorePages || asyncSearchCallback == null) return;
    _loadingMore = true;
    _currentPage++;
    notifyListeners();
    _overlayEntry?.markNeedsBuild();
    try {
      final query = searchController.text;
      final Map<String, dynamic>? searchBy =
          (query.isNotEmpty && searchColumn != null) ? {searchColumn!: query} : null;
      final (values, pagination) = await asyncSearchCallback!(
        page: _currentPage,
        perPage: perPage,
        searchBy: searchBy,
      );
      items = [...items, ...values];
      _hasMorePages = pagination != null
          ? (pagination as dynamic).next != null
          : values.length >= perPage;
    } catch (_) {
      _hasMorePages = false;
      _currentPage--;
    } finally {
      _loadingMore = false;
      notifyListeners();
      _overlayEntry?.markNeedsBuild();
    }
  }

  Future<void> onSearch(String query) async {
    if (asyncSearchCallback != null) {
      await _fetchPage(reset: true, query: query.isEmpty ? null : query);
    } else if (syncSearchCallback != null) {
      items = await syncSearchCallback!.call(query);
      notifyListeners();
      _overlayEntry?.markNeedsBuild();
    }
  }

  // ── Selection ────────────────────────────────────────────────────────────

  void selectItem(T item) {
    if (isMultiple) {
      if (!selectedItems.contains(item)) {
        selectedItems.add(item);
      } else {
        selectedItems.remove(item);
      }
      onSelectItems?.call(List.unmodifiable(selectedItems));
      _syncMultipleText();
      notifyListeners();
      _overlayEntry?.markNeedsBuild();
    } else {
      selectedItem = item;
      textController.text = valueToShow(item);
      onSelectItem?.call(item);
      closeOverlay();
      notifyListeners();
    }
  }

  void removeItem(T item) {
    if (isMultiple) {
      selectedItems.remove(item);
      onSelectItems?.call(List.unmodifiable(selectedItems));
      _syncMultipleText();
    } else {
      selectedItem = null;
      textController.clear();
      onClearItem?.call();
      closeOverlay();
    }
    notifyListeners();
    _overlayEntry?.markNeedsBuild();
  }

  void clearAll() {
    selectedItems.clear();
    onSelectItems?.call([]);
    _syncMultipleText();
    notifyListeners();
    _overlayEntry?.markNeedsBuild();
  }

  // ── Overlay builder ──────────────────────────────────────────────────────

  OverlayEntry _buildOverlay() {
    final renderBox = fieldKey.currentContext!.findRenderObject()! as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    // Retrieve screen height from field's context before the overlay is built.
    final screenHeight = MediaQuery.of(fieldKey.currentContext!).size.height;
    const gap = 4.0;
    const searchBarHeight = 56.0;
    const maxListHeight = 250.0;
    final hasSearch = syncSearchCallback != null || asyncSearchCallback != null;
    final estimatedHeight = maxListHeight + (hasSearch ? searchBarHeight : 0) + 16;

    final spaceBelow = screenHeight - (offset.dy + size.height + gap);
    final spaceAbove = offset.dy - gap;
    final openUpward = spaceBelow < estimatedHeight && spaceAbove > spaceBelow;
    final availableSpace = openUpward ? spaceAbove : spaceBelow;
    final listMaxHeight = (availableSpace - (hasSearch ? searchBarHeight : 0) - 16).clamp(80.0, maxListHeight);

    return OverlayEntry(
      builder: (ctx) {
        // Re-read state inside the overlay builder so markNeedsBuild() works.
        return Stack(
          children: [
            GestureDetector(
              onTap: closeOverlay,
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
                child: Material(
                  type: MaterialType.transparency,
                  child: CLContainer(
                    showShadow: true,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasSearch)
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: CLTextField(
                              controller: searchController,
                              label: 'Cerca...',
                              prefixIcon: FontAwesomeIcons.magnifyingGlass,
                              onChanged: onSearch,
                            ),
                          ),
                        _buildList(ctx, listMaxHeight),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildList(BuildContext ctx, double maxHeight) {
    if (loading && items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }
    if (items.isEmpty) {
      final theme = CLThemeProvider.of(ctx);
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Nessun risultato trovato', style: theme.bodyLabel),
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: items.length + (_loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
            );
          }
          final item = items[index];
          final isSelected = isMultiple ? selectedItems.contains(item) : selectedItem == item;
          return _DropdownItem(
            onTap: () => selectItem(item),
            isSelected: isSelected,
            child: ListTile(
              titleTextStyle: CLThemeProvider.of(context).bodyText,
              title: itemBuilder(context, item),
              trailing: isMultiple
                  ? IgnorePointer(
                      child: Checkbox(
                        value: selectedItems.contains(item),
                        onChanged: (_) {},
                        activeColor: CLThemeProvider.of(context).primary,
                        checkColor: Colors.white,
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    closeOverlay();
    textController.dispose();
    searchController.dispose();
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hover-aware list item
// ─────────────────────────────────────────────────────────────────────────────

class _DropdownItem extends StatefulWidget {
  final VoidCallback onTap;
  final bool isSelected;
  final Widget child;

  const _DropdownItem({
    required this.onTap,
    required this.isSelected,
    required this.child,
  });

  @override
  State<_DropdownItem> createState() => _DropdownItemState();
}

class _DropdownItemState extends State<_DropdownItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bg;
    if (widget.isSelected) {
      bg = theme.primary.withValues(alpha: isDark ? 0.15 : 0.08);
    } else if (_hovered) {
      bg = theme.primary.withValues(alpha: isDark ? 0.08 : 0.04);
    } else {
      bg = Colors.transparent;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          color: bg,
          child: widget.child,
        ),
      ),
    );
  }
}
