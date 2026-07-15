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
  final bool hoistToShell;

  /// Tabella embedded → niente gutter orizzontale interno (lo dà la pagina host).
  final bool embedded;

  /// Azioni bulk: rese nel cluster destro della toolbar (desktop), SEMPRE
  /// visibili e grigiate quando 0 righe selezionate. Vedi paged_datatable.dart.
  final List<Widget> Function(BuildContext context, int selectedCount, List<TResult> selectedItems)?
      selectionActionsBuilder;

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
    this.hoistToShell,
    this.selectionActionsBuilder,
    this.embedded,
  );

  @override
  Widget build(BuildContext context) {
    var theme = PagedDataTableTheme.of(context);
    return Consumer<_PagedDataTableState<TKey, TResultId, TResult>>(
      builder: (context, state, _) {
        final clTheme = GenTokens.of(context);
        final GlobalKey buttonKey = state.filterButtonKey;
        final GlobalKey buttonExtraMenuKey = state.extraMenuButtonKey;
        // Filtri extra attivi (non main) per i chip
        final activeExtraFilters = state.filters.entries.where((e) => !e.value._filter.isMainFilter && e.value.hasValue).toList();

        // Azioni bulk: NON più rese nella toolbar (filter tab) su desktop —
        // vivono nella card flottante sopra il footer (vedi
        // _DesktopBulkActionsFloatingCard in paged_datatable.dart). Su mobile/
        // hoisted la barra bulk vive nel bottom shell (selectionBar). Qui restano
        // solo titolo/azioni-pagina (Nuovo, download, menu).

        Widget child = LayoutBuilder(
          builder: (context, constraints) {
            // Larghezza finita anche se misurata in un contesto unbounded
            // (es. overlay/offstage): evita il crash di Expanded nella ricerca.
            final maxW = constraints.maxWidth.isFinite ? constraints.maxWidth : MediaQuery.sizeOf(context).width;
            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxW),
              child: GenCompactActionScope(
                iconOnly: _isTableCompact(context),
                child: Container(
          decoration: BoxDecoration(
            color: GenTokens.of(context).secondaryBackground,
          ),
          // Bottom Lg: insieme allo spazio dell'header row sotto (~Lg) dà 2×Lg tra
          // barra ricerca/filtri e riga label.
          padding: _isTableCompact(context)
              ? EdgeInsets.zero
              : EdgeInsets.fromLTRB(embedded ? 0 : clTheme.gapLg, clTheme.gapLg, embedded ? 0 : clTheme.gapLg, clTheme.gapLg),
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
                        // Campo di ricerca (larghezza preferita 25% viewport, shrink se manca spazio)
                        if (state.filters.isNotEmpty &&
                            state.filters.entries.where((element) => element.value._filter.isMainFilter == true).isNotEmpty)
                          Builder(
                            builder: (context) {
                              final field = state.filters.entries.where((element) => element.value._filter.isMainFilter == true).map((entry) {
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
                              }).first;
                              // Ricerca con larghezza massima contenuta (no full-width):
                              // lascia spazio tra search/Filtri e azioni a destra.
                              // Flexible: si restringe sotto 460 su viewport stretti
                              // (ConstrainedBox da solo non flexa → overflow).
                              return Flexible(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 460),
                                  child: field,
                                ),
                              );
                            },
                          ),

                        // Pulsante filtri (solo se ci sono filtri extra)
                        if (state.filters.entries.where((element) => element.value._filter.isMainFilter == false).isNotEmpty) ...[
                          SizedBox(width: clTheme.gapLg),
                          Builder(
                            builder: (context) {
                              final isDesktop = !_isTableCompact(context);
                              final activeCount = state.filters.values.where((f) => f.hasValue && !f._filter.isMainFilter).length;
                              final isDisabled = state.tableState == _TableState.loading;

                              void onTap() async {
                                if (isDesktop) {
                                  final RenderBox renderBox = buttonKey.currentContext!.findRenderObject() as RenderBox;
                                  final position = renderBox.localToGlobal(Offset.zero);
                                  await _showFilterOverlayDesktopFromPosition(context, state, buttonKey, position);
                                } else {
                                  await _showFilterOverlayMobile(context, state);
                                }
                                // Overlay chiuso → rilascia il focus rimasto sul bottone
                                // (altrimenti resta il bordo focus 2px persistente).
                                FocusManager.instance.primaryFocus?.unfocus();
                              }

                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  KeyedSubtree(
                                    key: buttonKey,
                                    child: _isTableCompact(context)
                                        ? ShadIconButton.ghost(
  onPressed: isDisabled ? () {} : onTap,
  icon: Icon(LucideIcons.slidersHorizontal),
  iconSize: GenSizes.iconSizeDefault,
)
                                        : ShadButton.outline(
                                            onPressed: isDisabled ? () {} : onTap,
                                            leading: const Icon(LucideIcons.slidersHorizontal),
                                            child: const Text("Filtri"),
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
                                          color: _effectiveTablePrimary(context),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: GenTokens.of(context).primaryBackground, width: 1.5),
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
                            },
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Gap Lg tra cluster ricerca/filtri e azioni a destra (es. Altre azioni)
                  if (header != null || downloadPage != null || mainMenus.isNotEmpty || extraMenus.isNotEmpty)
                    SizedBox(width: clTheme.gapLg),

                  // === DESTRA: Azioni ===
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header custom
                      if (header != null) ...[Flexible(child: header!), SizedBox(width: clTheme.gapLg)],

                      // Download button — gray secondary: fill controlFill, testo primaryText, no bordo
                      if (downloadPage != null) ...[
                        ShadButton(
  onPressed: () async {
                            await state._dispatchDownloadCallback();
                          },
  leading: Icon(downloadButtonIcon),
  child: Text(downloadButtonText ?? "Download"),
),
                        SizedBox(width: clTheme.gapLg),
                      ],

                      // Main menus (with horizontal spacing between buttons)
                      if (mainMenus.isNotEmpty)
                        for (var i = 0; i < mainMenus.length; i++) ...[
                          if (i > 0) SizedBox(width: clTheme.gapLg),
                          mainMenus[i],
                        ],

                      // Extra menu (icon button default)
                      if (extraMenus.isNotEmpty) ...[
                        if (mainMenus.isNotEmpty) SizedBox(width: clTheme.gapLg),
                        KeyedSubtree(
                          key: buttonExtraMenuKey,
                          child: _isTableCompact(context)
                              ? ShadIconButton.ghost(
  onPressed: () async {
                                    _showExtraMenuOverlay(context, state, buttonExtraMenuKey);
                                  },
  icon: Icon(LucideIcons.ellipsisVertical400),
  iconSize: GenSizes.iconSizeDefault,
)
                              : ShadButton(
  onPressed: () async {
                                    _showExtraMenuOverlay(context, state, buttonExtraMenuKey);
                                  },
  leading: Icon(LucideIcons.ellipsisVertical400),
  child: Text('Altre azioni'),
),
                        ),
                      ],

                    ],
                  ),
                ],
              ),
              // === CHIP FILTRI ATTIVI (sotto la barra principale) ===
              if (activeExtraFilters.isNotEmpty) ...[
                SizedBox(height: clTheme.gapSm),
                Wrap(
                  spacing: clTheme.gapIconText,
                  runSpacing: clTheme.gapXs,
                  children: activeExtraFilters.map((entry) {
                    final filter = entry.value._filter;
                    final label = (filter as dynamic).chipFormatter(entry.value.value) as String;
                    final clTheme = GenTokens.of(context);
                    return Container(
                      padding: const EdgeInsets.only(left: 10, right: 4, top: 4, bottom: 4),
                      decoration: BoxDecoration(
                        color: clTheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(clTheme.radiusPill),
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
                          SizedBox(width: clTheme.gapXs),
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
          ),
              ),
            );
          },
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
        return hoistToShell
            ? _FilterBarShellHost<TKey, TResultId, TResult>(
                state: state,
                hasExtraFilters:
                    state.filters.entries.any((e) => e.value._filter.isMainFilter == false),
                hasSortableColumns: state.columns.any((c) => c.sortable == true),
                extraMenus: extraMenus,
                idGetter: idGetter,
                selectionActionsBuilder: selectionActionsBuilder,
                child: child,
              )
            : child;
      },
    );
  }

  Future<void> _showExtraMenuOverlay(BuildContext context, _PagedDataTableState<TKey, TResultId, TResult> state, GlobalKey buttonExtraMenuKey) async {
    final theme = GenTokens.of(context);

    if (!_isTableCompact(context)) {
      // Popover unificato (GenPopupMenu): stile "Altre azioni" + hairline divider + token.
      await GenPopupMenu.show(
        context: context,
        anchorKey: buttonExtraMenuKey,
        items: extraMenus.map((m) => GenPopupMenuItem(content: m.content, onTap: m.onTap)).toList(),
      );
    } else {
      await showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        backgroundColor: theme.secondaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(theme.radiusModal)),
        ),
        builder: (BuildContext ctx) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: theme.gapSm),
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
                SizedBox(height: theme.gapSm),
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
    // Modal centrale Gen (ShadDialog): barrier + scale/fade + chrome card nativi.
    await showShadDialog<void>(
      context: context,
      // opaque:false → le route sotto continuano a dipingere (barrier le oscura).
      // Default true occlude tutto e dietro il barrier resta vuoto.
      opaque: false,
      builder: (context) => _FiltersDialog<TKey, TResultId, TResult>(state: state),
    );
  }

  Future<void> _showFilterOverlayMobile(BuildContext context, _PagedDataTableState<TKey, TResultId, TResult> state) async {
    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
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
    final theme = GenTokens.of(context);
    final state = widget.state;
    List<Map<BaseTableColumn<TResult>?, bool>> items = [];
    state.columns.where((column) => column.sortable == true).map((column) {
      items.add({column: true});
      items.add({column: false});
    }).toList();
    return GenContainer(
      height: MediaQuery.of(context).size.height * 0.67,
      title: "Filtri di ricerca",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(theme.pagePadX),
                child: Column(
                  children: [
                    CLDropdown<Map<BaseTableColumn<TResult>?, bool>>.singleSync(
                      hint: 'Ordina per',
                      items: items,
                      valueToShow: (item) {
                        if (item.values.toList()[0]) {
                          return "${item.keys.toList()[0]!.title.toString()} - Discendente";
                        } else {
                          return "${item.keys.toList()[0]!.title.toString()} - Ascendente";
                        }
                      },
                      itemBuilder: (context, item) {
                        if (item.values.toList()[0]) {
                          return Text("${item.keys.toList()[0]!.title.toString()} - Discendente");
                        } else {
                          return Text("${item.keys.toList()[0]!.title.toString()} - Ascendente");
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
                                child: _labeledFilterField(context, entry.value),
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
            padding: EdgeInsets.all(theme.pagePadX),
            child: Row(
              children: [
                ShadButton(
  onPressed: () {
                    Navigator.pop(context);
                    state.resetFilterSort();
                  },
  child: Text("Ripristina"),
),
                const Spacer(),
                ShadButton(
  onPressed: () {
                    state.filtersFormKey.currentState!.save();
                    Navigator.pop(context);
                    state.applyFilters(columnId: selectedColumn?.id!, descending: descending);
                  },
  child: Text("Applica"),
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
  final _PagedDataTableState<TKey, TResultId, TResult> state;

  const _FiltersDialog({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = GenTokens.of(context);
    final maxHeight = MediaQuery.of(context).size.height * 0.8;

    return ShadDialog(
      title: Text('Filtra con...', style: theme.heading4),
      constraints: BoxConstraints(maxWidth: 480, maxHeight: maxHeight),
      actionsMainAxisAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        ShadButton.outline(
          onPressed: () {
            Navigator.pop(context);
            state.resetFilterSort();
          },
          child: const Text('Ripristina'),
        ),
        ShadButton(
          onPressed: () {
            state.filtersFormKey.currentState!.save();
            Navigator.pop(context);
            state.applyFilters();
          },
          child: const Text('Applica'),
        ),
      ],
      child: Form(
        key: state.filtersFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...state.filters.entries
                .where((element) => element.value._filter.visible && element.value._filter.isMainFilter == false)
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: _labeledFilterField(context, entry.value),
                  ),
                ),
          ],
        ),
      ),
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
    final theme = GenTokens.of(context);
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
          padding: EdgeInsets.symmetric(horizontal: theme.gapMd),
          color: _hovered ? theme.muted : Colors.transparent,
          alignment: Alignment.centerLeft,
          child: widget.content,
        ),
      ),
    );
  }
}

/// Contenuto inline del pannello "Filtri" rivelato nell'area contestuale dello
/// shell (mobile): SOLO i filtri extra + Ripristina/Applica. SENZA chrome modale
/// (`onClose` richiude il pannello inline). Applica preserva l'ordinamento
/// corrente (applyFilters senza columnId non tocca il sort). Scroll/altezza-max
/// li fornisce il contenitore dello shell. L'ordinamento sta nel pannello
/// dedicato [_InlineSortPanel].
class _InlineFiltersPanel<TKey extends Comparable, TResultId extends Comparable, TResult extends Object>
    extends StatelessWidget {
  const _InlineFiltersPanel({required this.state, required this.onClose});

  final _PagedDataTableState<TKey, TResultId, TResult> state;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = GenTokens.of(context);
    final filterEntries = state.filters.entries
        .where((e) => e.value._filter.isMainFilter == false && e.value._filter.visible)
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Form(
          key: state.filtersFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final entry in filterEntries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _labeledFilterField(context, entry.value),
                ),
            ],
          ),
        ),
        SizedBox(height: theme.gapLg),
        Row(
          children: [
            ShadButton(
  onPressed: () {
                state.resetFilterSort();
                onClose();
              },
  child: Text('Ripristina'),
),
            const Spacer(),
            ShadButton(
  onPressed: () {
                state.filtersFormKey.currentState?.save();
                state.applyFilters();
                onClose();
              },
  child: Text('Applica'),
),
          ],
        ),
      ],
    );
  }
}

/// Contenuto inline del pannello "Ordina": dropdown delle colonne sortable
/// (asc/desc) + Rimuovi/Applica. Feature aggiuntiva oltre al sort sulle
/// intestazioni di colonna. Applica preserva i filtri attivi (applyFilters con
/// columnId imposta solo il sort).
class _InlineSortPanel<TKey extends Comparable, TResultId extends Comparable, TResult extends Object>
    extends StatefulWidget {
  const _InlineSortPanel({required this.state, required this.onClose});

  final _PagedDataTableState<TKey, TResultId, TResult> state;
  final VoidCallback onClose;

  @override
  State<_InlineSortPanel<TKey, TResultId, TResult>> createState() =>
      _InlineSortPanelState<TKey, TResultId, TResult>();
}

class _InlineSortPanelState<TKey extends Comparable, TResultId extends Comparable, TResult extends Object>
    extends State<_InlineSortPanel<TKey, TResultId, TResult>> {
  BaseTableColumn<TResult>? selectedColumn;
  bool descending = false;

  @override
  Widget build(BuildContext context) {
    final theme = GenTokens.of(context);
    final state = widget.state;

    final sortItems = <Map<BaseTableColumn<TResult>?, bool>>[];
    for (final column in state.columns.where((c) => c.sortable == true)) {
      sortItems.add({column: true});
      sortItems.add({column: false});
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CLDropdown<Map<BaseTableColumn<TResult>?, bool>>.singleSync(
          hint: 'Ordina per',
          items: sortItems,
          valueToShow: (item) => item.values.first
              ? '${item.keys.first!.title} - Discendente'
              : '${item.keys.first!.title} - Ascendente',
          itemBuilder: (context, item) => Text(item.values.first
              ? '${item.keys.first!.title} - Discendente'
              : '${item.keys.first!.title} - Ascendente'),
          onSelectItem: (item) {
            if (item != null) {
              selectedColumn = item.keys.first;
              descending = item.values.first;
              return item.keys.first?.id == state._sortModel?._columnId;
            }
          },
        ),
        SizedBox(height: theme.gapLg),
        Row(
          children: [
            ShadButton(
  onPressed: () {
                state.removeSort();
                widget.onClose();
              },
  child: Text('Rimuovi'),
),
            const Spacer(),
            ShadButton(
  onPressed: () {
                state.applyFilters(columnId: selectedColumn?.id, descending: descending);
                widget.onClose();
              },
  child: Text('Applica'),
),
          ],
        ),
      ],
    );
  }
}

/// Host opt-in: su mobile (compact) e con un [GenShellScope] antenato, pubblica
/// la filter bar nell'area contestuale dello shell invece di renderla inline.
/// Ri-fornisce i provider della tabella (state + theme + style) così la barra
/// costruita SOPRA la tabella (nello shell) trova le sue dipendenze. Altrove →
/// render inline invariato.
class _FilterBarShellHost<TKey extends Comparable, TResultId extends Comparable, TResult extends Object>
    extends StatefulWidget {
  const _FilterBarShellHost({
    required this.state,
    required this.child,
    required this.hasExtraFilters,
    required this.hasSortableColumns,
    required this.extraMenus,
    required this.idGetter,
    required this.selectionActionsBuilder,
  });

  final _PagedDataTableState<TKey, TResultId, TResult> state;
  final Widget child;
  final bool hasExtraFilters;
  final bool hasSortableColumns;
  final List<TableExtraMenu> extraMenus;
  final ModelIdGetter<TResultId, TResult> idGetter;

  /// Azioni bulk: pubblicate nel bottom shell (selectionBar) quando c'è
  /// selezione attiva su mobile, al posto di filtri + pageActions.
  final List<Widget> Function(BuildContext context, int selectedCount, List<TResult> selectedItems)?
      selectionActionsBuilder;

  @override
  State<_FilterBarShellHost<TKey, TResultId, TResult>> createState() =>
      _FilterBarShellHostState<TKey, TResultId, TResult>();
}

class _FilterBarShellHostState<TKey extends Comparable, TResultId extends Comparable, TResult extends Object>
    extends State<_FilterBarShellHost<TKey, TResultId, TResult>> {
  ShellSlotsController? _shell;
  bool _published = false;
  // Ultima lista pubblicata: serve a pulire senza clobberare i controlli che
  // un'altra pagina potrebbe aver già ripubblicato (guard per identità).
  List<ShellContextControl>? _lastPublished;
  // Controller proprio del campo ricerca pubblicato nello shell. Su mobile il
  // campo inline della tabella non viene costruito (host → SizedBox.shrink),
  // quindi non c'è conflitto col `_controller` interno del TextTableFilter.
  final TextEditingController _searchController = TextEditingController();
  // Rotta che contiene la tabella: l'host pubblica nello shell SOLO quando questa
  // rotta è corrente. Quando una rotta figlia la copre (es. dettaglio) ci
  // de-pubblichiamo, altrimenti ricerca/filtri/ordina della lista restano nel
  // bottom mobile del dettaglio.
  ModalRoute<dynamic>? _route;

  @override
  void initState() {
    super.initState();
    // Cambi di selezione → ripubblica la selectionBar. Deferito a post-frame:
    // il notify dello state può arrivare in fase di build (no setState sincrono).
    widget.state.addListener(_onSelectionChanged);
  }

  void _onSelectionChanged() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _shell = GenShellScope.maybeOf(context);
    final route = ModalRoute.of(context);
    if (route != _route) {
      _route?.secondaryAnimation?.removeListener(_onRouteChanged);
      _route = route;
      // secondaryAnimation avanza quando una rotta viene spinta sopra questa →
      // ricostruisci per rivalutare isCurrent (de-pubblica al push, ripubblica al pop).
      _route?.secondaryAnimation?.addListener(_onRouteChanged);
    }
  }

  void _onRouteChanged() {
    if (mounted) setState(() {});
  }

  /// Pulisce i controlli pubblicati, differito a post-frame (dispose/route change
  /// avvengono ad albero LOCKED → no notify sincrono) e con guard per identità
  /// (niente clobber se un'altra pagina ha già ripubblicato).
  void _clearPublished() {
    if (!_published) return;
    _published = false;
    final shell = _shell;
    final mine = _lastPublished;
    if (shell == null) return;
    shell.setSelectionBar(null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (identical(shell.slots.contextControls, mine)) {
        shell.setContextControls(const []);
      }
    });
  }

  @override
  void dispose() {
    widget.state.removeListener(_onSelectionChanged);
    _route?.secondaryAnimation?.removeListener(_onRouteChanged);
    _clearPublished();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shell = _shell;
    final compact = _isTableCompact(context);
    final isCurrent = _route?.isCurrent ?? true;

    if (shell == null || !compact) {
      // Path invariato: render inline. Se prima avevamo pubblicato, pulisci.
      _clearPublished();
      return widget.child;
    }
    if (!isCurrent) {
      // Rotta coperta da un figlio (es. dettaglio): de-pubblica e collassa
      // (la barra è comunque hoisted/offscreen).
      _clearPublished();
      return const SizedBox.shrink();
    }

    // Mobile + shell: pubblica i controlli GRANULARI (ordina/filtri · ricerca)
    // sulla riga alta e "altre azioni" in coda alla riga bassa. I bottoni
    // ordina/filtri/altre-azioni sono REVEAL: il tap rivela il contenuto inline
    // nell'area (lo shell collassa le righe e mostra il pannello). Niente più
    // overlay modali né la barra desktop intera (causava overflow a piena larghezza).
    final state = widget.state;
    final controls = <ShellContextControl>[];

    // Riga 1: ordina · ricerca · filtri. Ordina e filtri sono pannelli DISTINTI
    // (reveal inline). "Ordina" = entry-point aggiuntivo oltre al sort sulle
    // intestazioni di colonna.
    if (widget.hasSortableColumns) {
      controls.add(ShellContextControl.reveal(ShellRevealControl(
        id: 'table-sort',
        icon: LucideIcons.arrowDownNarrowWide400,
        title: 'Ordina',
        tooltip: 'Ordina',
        panelBuilder: (ctx, close) => _InlineSortPanel<TKey, TResultId, TResult>(
          state: state,
          onClose: close,
        ),
      )));
    }

    final mainMatches =
        state.filters.entries.where((e) => e.value._filter.isMainFilter == true);
    if (mainMatches.isNotEmpty) {
      final entry = mainMatches.first;
      final filter = entry.value._filter;
      final current = (entry.value.value ?? '').toString();
      // Allinea il controller solo a variazioni ESTERNE (es. reset filtri):
      // durante la digitazione testo == value, quindi nessun reset del cursore.
      if (_searchController.text != current) _searchController.text = current;
      controls.add(ShellContextControl.search(ShellSearch(
        controller: _searchController,
        hint: filter.title.toString(),
        onChanged: (value) {
          entry.value.value = value;
          if (value.isEmpty) {
            state.removeFilter(filter.id);
          } else {
            state.applyFilters();
          }
        },
      )));
    }

    if (widget.hasExtraFilters) {
      final activeCount = state.filters.values
          .where((f) => f.hasValue && !f._filter.isMainFilter)
          .length;
      controls.add(ShellContextControl.reveal(ShellRevealControl(
        id: 'table-filters',
        icon: LucideIcons.slidersHorizontal,
        title: 'Filtri',
        tooltip: 'Filtri',
        badgeCount: activeCount,
        panelBuilder: (ctx, close) => _InlineFiltersPanel<TKey, TResultId, TResult>(
          state: state,
          onClose: close,
        ),
      )));
    }

    final overflow = widget.extraMenus.isNotEmpty
        ? ShellRevealControl(
            id: 'table-extra-menu',
            icon: LucideIcons.ellipsisVertical400,
            title: 'Altre azioni',
            tooltip: 'Altre azioni',
            panelBuilder: (ctx, close) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final m in widget.extraMenus)
                  _ExtraMenuRow(
                    content: m.content,
                    onTap: () {
                      close();
                      m.onTap();
                    },
                  ),
              ],
            ),
          )
        : null;

    _lastPublished = controls;
    // Selezione attiva → barra bulk (ha priorità nel bottom shell: sostituisce
    // controlli + pageActions). Nessuna selezione → null (torna ai filtri).
    final selBar = _buildSelectionBar(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      shell.setContextControls(controls, overflow: overflow);
      shell.setSelectionBar(selBar);
    });
    _published = true;
    return const SizedBox.shrink();
  }

  /// Barra azioni bulk per il bottom shell (mobile): badge conteggio +
  /// "Deseleziona" sopra, bottoni azione (selectionActionsBuilder) sotto.
  /// `null` se non c'è selezione o nessun builder.
  Widget? _buildSelectionBar(BuildContext context) {
    final builder = widget.selectionActionsBuilder;
    final state = widget.state;
    final count = state.selectedRows.length;
    if (builder == null || count == 0) return null;
    final selectedItems = state.selectedRows.entries
        .where((e) => e.value < state._items.length)
        .map((e) => state._items[e.value])
        .toList();
    final actions = builder(context, count, selectedItems);
    final t = GenTokens.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: t.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(t.radiusChip),
              ),
              child: Text(
                '$count selezionat${count == 1 ? 'o' : 'i'}',
                style: t.bodyLabel.copyWith(color: t.primary, fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => state.clearAllSelections(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: t.gapMd, vertical: t.gapIconText),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('Deseleziona', style: t.bodyLabel.copyWith(color: t.secondaryText, fontSize: 12)),
            ),
          ],
        ),
        if (actions.isNotEmpty) ...[
          SizedBox(height: t.gapLg),
          Row(
            children: [
              for (var i = 0; i < actions.length; i++) ...[
                if (i > 0) SizedBox(width: t.gapLg),
                Expanded(child: actions[i]),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

/// Campo filtro nel pannello/dialog "Filtri": [TableFilter.title] come label
/// sopra il picker. Uniforma tutti i filtri extra (che altrimenti mostrerebbero
/// il titolo solo come placeholder o floating-label, in modo incoerente).
///
/// Stile label IDENTICO a quello dei form field di [GenForm]
/// (`ShadInputDecorator`): `textTheme.muted` con weight w500 e colore foreground,
/// padding bottom 8 → coerenza visiva con i form nativi.
Widget _labeledFilterField(BuildContext context, TableFilterState fs) {
  final theme = GenTokens.of(context);
  final labelStyle = ShadTheme.of(context).textTheme.muted.copyWith(
        fontWeight: FontWeight.w500,
        color: theme.primaryText,
      );
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: GenSizes.gapSm),
        child: Text(fs._filter.title, style: labelStyle),
      ),
      fs._filter.buildPicker(context, fs),
    ],
  );
}
