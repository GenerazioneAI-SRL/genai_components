part of 'paged_datatable.dart';

class _PagedDataTableFilterTab<TKey extends Comparable, TResultId extends Comparable, TResult extends Object> extends StatelessWidget {
  final List<Widget> mainMenus;
  final List<TableExtraMenu> extraMenus;
  final Widget? header;
  final bool rowsSelectable;
  final ModelIdGetter<TResultId, TResult> idGetter;
  final Future Function({Map<String, dynamic>? searchBy, Map<String, dynamic>? orderBy})? downloadPage;
  final String? downloadButtonText;
  final IconData? downloadButtonIcon;
  final bool isFilterBarRounded;

  const _PagedDataTableFilterTab(
    this.mainMenus,
    this.extraMenus,
    this.header,
    this.rowsSelectable,
    this.idGetter,
    this.downloadPage,
    this.downloadButtonText,
    this.downloadButtonIcon,
    this.isFilterBarRounded,
  );

  @override
  Widget build(BuildContext context) {
    var theme = PagedDataTableTheme.of(context);
    return Consumer<_PagedDataTableState<TKey, TResultId, TResult>>(
      builder: (context, state, _) {
        final GlobalKey buttonKey = state.filterButtonKey;
        final GlobalKey buttonExtraMenuKey = state.extraMenuButtonKey;
        // Filtri extra attivi (non main) per i chip
        final activeExtraFilters = state.filters.entries.where((e) => !e.value._filter.isMainFilter && e.value.hasValue).toList();

        Widget child = Container(
          decoration: BoxDecoration(
            color: CLTheme.of(context).secondaryBackground,
          ),
          padding: EdgeInsets.all(ResponsiveBreakpoints.of(context).isDesktop ? Sizes.padding : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // === SINISTRA: Campo di ricerca + Filtri ===
                  Expanded(
                    child: Row(
                      children: [
                        // Campo di ricerca (larghezza fissa)
                        if (state.filters.isNotEmpty &&
                            state.filters.entries.where((element) => element.value._filter.isMainFilter == true).isNotEmpty)
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 4,
                            child: state.filters.entries.where((element) => element.value._filter.isMainFilter == true).map((entry) {
                              TextTableFilter mainFilter = entry.value._filter as TextTableFilter;
                              mainFilter.onChange = (String value) {
                                entry.value.value = value;
                                if (value.isEmpty) {
                                  state.removeFilter(mainFilter.id);
                                } else {
                                  state.applyFilters();
                                }
                              };
                              return mainFilter.buildPicker(context, entry.value);
                            }).first,
                          ),

                        // Pulsante filtri (solo se ci sono filtri extra)
                        if (state.filters.entries.where((element) => element.value._filter.isMainFilter == false).isNotEmpty) ...[
                          const SizedBox(width: Sizes.borderRadius),
                          Builder(
                            builder: (context) {
                              final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;
                              final activeCount = state.filters.values.where((f) => f.hasValue && !f._filter.isMainFilter).length;
                              final isDisabled = state.tableState == _TableState.loading;

                              void onTap() {
                                if (isDesktop) {
                                  final RenderBox renderBox = buttonKey.currentContext!.findRenderObject() as RenderBox;
                                  final position = renderBox.localToGlobal(Offset.zero);
                                  _showFilterOverlayDesktopFromPosition(context, state, buttonKey, position);
                                } else {
                                  _showFilterOverlayMobile(context, state);
                                }
                              }

                              if (isDesktop) {
                                // Desktop: CLOutlineButton con testo + icona + badge
                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    KeyedSubtree(
                                      key: buttonKey,
                                      child: CLGhostButton.primary(
                                        text: "Filtri",
                                        iconAlignment: IconAlignment.start,
                                        icon: LucideIcons.slidersHorizontal,
                                        onTap: isDisabled ? () {} : onTap,
                                        context: context,
                                      ),
                                    ),
                                    if (activeCount > 0)
                                      Positioned(
                                        top: -4,
                                        right: -4,
                                        child: Container(
                                          width: 18,
                                          height: 18,
                                          decoration: BoxDecoration(
                                            color: CLTheme.of(context).primary,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: CLTheme.of(context).primaryBackground, width: 1.5),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '$activeCount',
                                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              } else {
                                // Mobile: solo icona con badge
                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    IconButton(
                                      key: buttonKey,
                                      icon: Icon(
                                        LucideIcons.slidersHorizontal,
                                        color: CLTheme.of(context).primaryText,
                                        size: Sizes.medium,
                                      ),
                                      onPressed: isDisabled ? null : onTap,
                                    ),
                                    if (activeCount > 0)
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: CLTheme.of(context).primary,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: CLTheme.of(context).primaryBackground, width: 1),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '$activeCount',
                                              style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                  ),

                  // === DESTRA: Azioni ===
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header custom
                      if (header != null) ...[Flexible(child: header!), const SizedBox(width: Sizes.padding)],

                      // Download button
                      if (downloadPage != null) ...[
                        CLButton.secondary(
                          text: downloadButtonText ?? "Download",
                          icon: downloadButtonIcon,
                          onTap: () async {
                            await state._dispatchDownloadCallback();
                          },
                          context: context,
                        ),
                        const SizedBox(width: Sizes.padding),
                      ],

                      // Main menus (with horizontal spacing between buttons)
                      if (mainMenus.isNotEmpty)
                        for (var i = 0; i < mainMenus.length; i++) ...[
                          if (i > 0) const SizedBox(width: CLSizes.gapMd),
                          mainMenus[i],
                        ],

                      // Extra menu (icon-only ghost button)
                      if (extraMenus.isNotEmpty) ...[
                        if (mainMenus.isNotEmpty) const SizedBox(width: CLSizes.gapMd),
                        KeyedSubtree(
                          key: buttonExtraMenuKey,
                          child: CLGhostButton.primary(
                            text: '',
                            iconAlignment: IconAlignment.start,
                            icon: LucideIcons.ellipsisVertical400,
                            onTap: () async {
                              _showExtraMenuOverlay(context, state, buttonExtraMenuKey);
                            },
                            context: context,
                          ),
                        ),
                      ],

                      // Checkbox (solo mobile)
                      if (rowsSelectable && !ResponsiveBreakpoints.of(context).isDesktop)
                        Transform.translate(
                          offset: Offset(6, 0),
                          child: Selector<_PagedDataTableState<TKey, TResultId, TResult>, int>(
                            selector: (context, model) => model._rowsSelectionChange,
                            builder: (context, value, _) {
                              return HookBuilder(
                                builder: (context) {
                                  final isAllSelected =
                                      state._items.isNotEmpty && state._items.every((item) => state.selectedRows.containsKey(idGetter(item)));
                                  final hasCurrentPageSelection = state._items.any((item) => state.selectedRows.containsKey(idGetter(item)));
                                  return Checkbox(
                                    value: isAllSelected ? true : (hasCurrentPageSelection ? null : false),
                                    tristate: true,
                                    hoverColor: Colors.transparent,
                                    overlayColor: WidgetStateProperty.all<Color>(Colors.transparent),
                                    activeColor: CLTheme.of(context).secondary,
                                    onChanged: (newValue) {
                                      switch (newValue) {
                                        case true:
                                          state.selectAllRows();
                                          break;
                                        case false:
                                        case null:
                                          // Clear globale: deseleziona anche pagine precedenti
                                          state.clearAllSelections();
                                          break;
                                      }
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              // === CHIP FILTRI ATTIVI (sotto la barra principale) ===
              if (activeExtraFilters.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: activeExtraFilters.map((entry) {
                    final filter = entry.value._filter;
                    final label = (filter as dynamic).chipFormatter(entry.value.value) as String;
                    final clTheme = CLTheme.of(context);
                    return Container(
                      padding: const EdgeInsets.only(left: 10, right: 4, top: 4, bottom: 4),
                      decoration: BoxDecoration(
                        color: clTheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: clTheme.primary.withValues(alpha: 0.2), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${filter.title}: $label',
                            style: clTheme.bodyLabel.copyWith(
                              color: clTheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => state.removeFilter(entry.key),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Icon(Icons.close_rounded, size: 14, color: clTheme.primary.withValues(alpha: 0.7)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        );
        if (theme.headerBackgroundColor != null) {
          child = DecoratedBox(decoration: BoxDecoration(color: theme.headerBackgroundColor), child: child);
        }
        if (theme.chipTheme != null) {
          child = ChipTheme(data: theme.chipTheme!, child: child);
        }
        if (theme.filtersHeaderTextStyle != null) {
          child = DefaultTextStyle(style: theme.filtersHeaderTextStyle!, child: child);
        }
        return child;
      },
    );
  }

  Future<void> _showExtraMenuOverlay(BuildContext context, _PagedDataTableState<TKey, TResultId, TResult> state, GlobalKey buttonExtraMenuKey) async {
    final theme = CLTheme.of(context);

    if (ResponsiveBreakpoints.of(context).isDesktop) {
      final buttonCtx = buttonExtraMenuKey.currentContext;
      if (buttonCtx == null) return;
      final overlayState = Overlay.of(context);
      final RenderBox button = buttonCtx.findRenderObject() as RenderBox;
      final RenderBox overlay = overlayState.context.findRenderObject() as RenderBox;
      final buttonPos = button.localToGlobal(Offset.zero, ancestor: overlay);
      final buttonSize = button.size;
      const double menuWidth = 240;
      final screenSize = overlay.size;
      double left = buttonPos.dx + buttonSize.width - menuWidth;
      if (left < 8) left = 8;
      if (left + menuWidth > screenSize.width - 8) left = screenSize.width - menuWidth - 8;
      final double top = buttonPos.dy + buttonSize.height + 4;

      OverlayEntry? entry;
      void close() {
        entry?.remove();
        entry = null;
      }

      entry = OverlayEntry(
        builder: (ctx) {
          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: close,
                ),
              ),
              Positioned(
                left: left,
                top: top,
                width: menuWidth,
                child: TapRegion(
                  onTapOutside: (_) => close(),
                  child: Material(
                    color: theme.secondaryBackground,
                    elevation: 4,
                    borderRadius: BorderRadius.circular(CLSizes.radiusSurface),
                    clipBehavior: Clip.antiAlias,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(CLSizes.radiusSurface),
                        border: Border.all(color: theme.cardBorder, width: 1),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < extraMenus.length; i++)
                            _ExtraMenuRow(
                              content: extraMenus[i].content,
                              onTap: () {
                                close();
                                extraMenus[i].onTap();
                              },
                            ),
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

      overlayState.insert(entry!);
    } else {
      await showModalBottomSheet(
        context: context,
        backgroundColor: theme.secondaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(CLSizes.radiusModal)),
        ),
        builder: (BuildContext ctx) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: CLSizes.gapSm),
                  child: Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(color: theme.borderColor, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                ),
                for (final menu in extraMenus)
                  _ExtraMenuRow(
                    content: menu.content,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      menu.onTap();
                    },
                  ),
                const SizedBox(height: CLSizes.gapSm),
              ],
            ),
          );
        },
      );
    }
  }

  Future<void> _showFilterOverlayDesktopFromPosition(
    BuildContext context,
    _PagedDataTableState<TKey, TResultId, TResult> state,
    GlobalKey buttonKey,
    Offset position,
  ) async {
    final RenderBox renderBox = buttonKey.currentContext?.findRenderObject() as RenderBox;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final menuWidth = screenWidth / 3;
    double dx = position.dx;
    if (dx + menuWidth > screenWidth) {
      dx = screenWidth - menuWidth - Sizes.padding;
    }
    final topPos = position.dy + renderBox.size.height + 8;
    final openUpwards = topPos + 300 > screenHeight;

    await showGeneralDialog(
      context: context,
      barrierColor: Colors.black12,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, openUpwards ? 0.02 : -0.02),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return _FiltersDialog<TKey, TResultId, TResult>(
          left: dx,
          top: openUpwards ? null : topPos,
          bottom: openUpwards ? screenHeight - position.dy + 8 : null,
          width: menuWidth,
          state: state,
        );
      },
    );
  }

  Future<void> _showFilterOverlayMobile(BuildContext context, _PagedDataTableState<TKey, TResultId, TResult> state) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FiltersDialogBoxed<TKey, TResultId, TResult>(rect: RelativeRect.fromLTRB(10, 0, 0, 0), state: state),
    );
  }
}

class _FiltersDialogBoxed<TKey extends Comparable, TResultId extends Comparable, TResult extends Object> extends StatefulWidget {
  final RelativeRect rect;
  final _PagedDataTableState<TKey, TResultId, TResult> state;

  const _FiltersDialogBoxed({required this.rect, required this.state});

  @override
  State<_FiltersDialogBoxed<TKey, TResultId, TResult>> createState() => _FiltersDialogBoxedState<TKey, TResultId, TResult>();
}

class _FiltersDialogBoxedState<TKey extends Comparable, TResultId extends Comparable, TResult extends Object>
    extends State<_FiltersDialogBoxed<TKey, TResultId, TResult>> {
  BaseTableColumn<TResult>? selectedColumn;
  bool descending = false;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    List<Map<BaseTableColumn<TResult>?, bool>> items = [];
    state.columns.where((column) => column.sortable == true).map((column) {
      items.add({column: true});
      items.add({column: false});
    }).toList();
    return CLContainer(
      height: MediaQuery.of(context).size.height * 0.67,
      title: "Filtri di ricerca",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(Sizes.padding),
                child: Column(
                  children: [
                    CLDropdown<Map<BaseTableColumn<TResult>?, bool>>.singleSync(
                      hint: 'Ordina per',
                      items: items,
                      valueToShow: (item) {
                        if (item.values.toList()[0]) {
                          return "\${item.keys.toList()[0]!.title.toString()} - Discendente";
                        } else {
                          return "\${item.keys.toList()[0]!.title.toString()} - Ascendente";
                        }
                      },
                      itemBuilder: (context, item) {
                        if (item.values.toList()[0]) {
                          return Text("\${item.keys.toList()[0]!.title.toString()} - Discendente");
                        } else {
                          return Text("\${item.keys.toList()[0]!.title.toString()} - Ascendente");
                        }
                      },
                      onSelectItem: (item) {
                        if (item != null) {
                          selectedColumn = item.keys.toList()[0];
                          descending = item.values.toList()[0];
                          return item.keys.toList()[0]?.id == state._sortModel?._columnId;
                        }
                      },
                    ),
                    Form(
                      key: state.filtersFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: state.filters.entries
                            .where((filter) => filter.value._filter.isMainFilter == false)
                            .where((element) => element.value._filter.visible)
                            .map(
                              (entry) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: entry.value._filter.buildPicker(context, entry.value),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Sizes.padding),
            child: Row(
              children: [
                CLButton(
                  textStyle: CLTheme.of(context).bodyText,
                  iconAlignment: IconAlignment.start,
                  backgroundColor: CLTheme.of(context).primaryBackground,
                  text: "Ripristina",
                  onTap: () {
                    Navigator.pop(context);
                    state.resetFilterSort();
                  },
                  context: context,
                ),
                const Spacer(),
                CLButton.primary(
                  text: "Applica",
                  onTap: () {
                    state.filtersFormKey.currentState!.save();
                    Navigator.pop(context);
                    state.applyFilters(columnId: selectedColumn?.id!, descending: descending);
                  },
                  context: context,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltersDialog<TKey extends Comparable, TResultId extends Comparable, TResult extends Object> extends StatelessWidget {
  final double left;
  final double? top;
  final double? bottom;
  final double width;
  final _PagedDataTableState<TKey, TResultId, TResult> state;

  const _FiltersDialog({required this.left, this.top, this.bottom, required this.width, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);

    return Stack(
      children: [
        Positioned(
          left: left,
          top: top,
          bottom: bottom,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: width,
              constraints: const BoxConstraints(maxWidth: 420),
              decoration: BoxDecoration(
                color: theme.secondaryBackground,
                borderRadius: BorderRadius.circular(Sizes.borderRadius),
                border: Border.all(color: theme.borderColor, width: 1),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 8), spreadRadius: -4),
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Sizes.borderRadius),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: Sizes.padding, vertical: Sizes.padding * 0.65),
                      decoration: BoxDecoration(
                        color: theme.primaryBackground,
                        border: Border(bottom: BorderSide(color: theme.borderColor, width: 1)),
                      ),
                      child: Text(
                        'Filtra con...',
                        style: theme.smallLabel.copyWith(color: theme.secondaryText, fontWeight: FontWeight.w600, fontSize: 11, letterSpacing: 0.5),
                      ),
                    ),
                    // Filters
                    Padding(
                      padding: const EdgeInsets.all(Sizes.padding),
                      child: Form(
                        key: state.filtersFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ...state.filters.entries
                                .where((element) => element.value._filter.visible && element.value._filter.isMainFilter == false)
                                .map(
                                  (entry) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    child: entry.value._filter.buildPicker(context, entry.value),
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),
                    // Footer buttons
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: Sizes.padding, vertical: Sizes.padding * 0.65),
                      decoration: BoxDecoration(border: Border(top: BorderSide(color: theme.borderColor, width: 1))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CLButton(
                            textStyle: theme.bodyLabel,
                            iconAlignment: IconAlignment.start,
                            backgroundColor: theme.primaryBackground,
                            text: "Ripristina",
                            onTap: () {
                              Navigator.pop(context);
                              state.resetFilterSort();
                            },
                            context: context,
                          ),
                          CLButton.primary(
                            text: "Applica",
                            onTap: () {
                              state.filtersFormKey.currentState!.save();
                              Navigator.pop(context);
                              state.applyFilters();
                            },
                            context: context,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Single row inside extra-menu popup. Hover bg + 36px height + horizontal
/// padding consistent with `tableActions` row context menu UX.
class _ExtraMenuRow extends StatefulWidget {
  final Widget content;
  final VoidCallback onTap;

  const _ExtraMenuRow({required this.content, required this.onTap});

  @override
  State<_ExtraMenuRow> createState() => _ExtraMenuRowState();
}

class _ExtraMenuRowState extends State<_ExtraMenuRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          height: 40,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: CLSizes.gapMd),
          color: _hovered ? theme.muted : Colors.transparent,
          alignment: Alignment.centerLeft,
          child: widget.content,
        ),
      ),
    );
  }
}
