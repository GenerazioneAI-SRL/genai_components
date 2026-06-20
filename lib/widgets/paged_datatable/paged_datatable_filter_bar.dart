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
  );

  @override
  Widget build(BuildContext context) {
    var theme = PagedDataTableTheme.of(context);
    return Consumer<_PagedDataTableState<TKey, TResultId, TResult>>(
      builder: (context, state, _) {
        final clTheme = CLTheme.of(context);
        final GlobalKey buttonKey = state.filterButtonKey;
        final GlobalKey buttonExtraMenuKey = state.extraMenuButtonKey;
        // Filtri extra attivi (non main) per i chip
        final activeExtraFilters = state.filters.entries.where((e) => !e.value._filter.isMainFilter && e.value.hasValue).toList();

        Widget child = LayoutBuilder(
          builder: (context, constraints) {
            // Larghezza finita anche se misurata in un contesto unbounded
            // (es. overlay/offstage): evita il crash di Expanded nella ricerca.
            final maxW = constraints.maxWidth.isFinite ? constraints.maxWidth : MediaQuery.sizeOf(context).width;
            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxW),
              child: CLCompactActionScope(
                iconOnly: _isTableCompact(context),
                child: Container(
          decoration: BoxDecoration(
            color: CLTheme.of(context).secondaryBackground,
          ),
          padding: EdgeInsets.all(_isTableCompact(context) ? 0 : clTheme.gapLg),
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
                              // Ricerca sempre full-width (tutti i breakpoint).
                              return Expanded(child: field);
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
                              }

                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  KeyedSubtree(
                                    key: buttonKey,
                                    child: _isTableCompact(context)
                                        ? CLIconButton(
                                            onTap: isDisabled ? () {} : onTap,
                                            iconData: LucideIcons.slidersHorizontal,
                                            backgroundColor: _tableButtonFill(context),
                                            iconColor: CLTheme.of(context).primaryText,
                                            size: Sizes.buttonHeightDefault,
                                            iconSize: Sizes.iconSizeDefault,
                                            tooltip: 'Filtri',
                                          )
                                        : CLButton(
                                            text: "Filtri",
                                            iconAlignment: IconAlignment.start,
                                            iconData: LucideIcons.slidersHorizontal,
                                            backgroundColor: _tableButtonFill(context),
                                            iconColor: CLTheme.of(context).primaryText,
                                            textStyle: CLTheme.of(context).bodyText.copyWith(
                                              color: CLTheme.of(context).primaryText,
                                              fontWeight: FontWeight.w500,
                                            ),
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
                                          color: _effectiveTablePrimary(context),
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
                        CLButton(
                          backgroundColor: _tableButtonFill(context),
                          textStyle: clTheme.bodyText.copyWith(color: clTheme.primaryText, fontWeight: FontWeight.w500),
                          iconColor: clTheme.primaryText,
                          iconAlignment: IconAlignment.start,
                          text: downloadButtonText ?? "Download",
                          iconData: downloadButtonIcon,
                          onTap: () async {
                            await state._dispatchDownloadCallback();
                          },
                          context: context,
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
                              ? CLIconButton(
                                  onTap: () async {
                                    _showExtraMenuOverlay(context, state, buttonExtraMenuKey);
                                  },
                                  iconData: LucideIcons.ellipsisVertical400,
                                  backgroundColor: _tableButtonFill(context),
                                  iconColor: clTheme.primaryText,
                                  size: Sizes.buttonHeightDefault,
                                  iconSize: Sizes.iconSizeDefault,
                                  tooltip: 'Altre azioni',
                                )
                              : CLButton(
                                  text: 'Altre azioni',
                                  iconData: LucideIcons.ellipsisVertical400,
                                  iconAlignment: IconAlignment.start,
                                  backgroundColor: _tableButtonFill(context),
                                  iconColor: clTheme.primaryText,
                                  textStyle: clTheme.bodyText.copyWith(
                                    color: clTheme.primaryText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  tooltip: 'Altre azioni',
                                  onTap: () async {
                                    _showExtraMenuOverlay(context, state, buttonExtraMenuKey);
                                  },
                                  context: context,
                                ),
                        ),
                      ],

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
            ? _FilterBarShellHost<TKey, TResultId, TResult>(state: state, child: child)
            : child;
      },
    );
  }

  Future<void> _showExtraMenuOverlay(BuildContext context, _PagedDataTableState<TKey, TResultId, TResult> state, GlobalKey buttonExtraMenuKey) async {
    final theme = CLTheme.of(context);

    if (!_isTableCompact(context)) {
      // Popover unificato (CLPopupMenu): stile "Altre azioni" + hairline divider + token.
      await CLPopupMenu.show(
        context: context,
        anchorKey: buttonExtraMenuKey,
        items: extraMenus.map((m) => CLPopupMenuItem(content: m.content, onTap: m.onTap)).toList(),
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
    // Modal centrale (non più popover ancorato): fade + scale come CLCommandPalette.
    await showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 150),
      transitionBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.97, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          ),
          child: child,
        ),
      ),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _FiltersDialog<TKey, TResultId, TResult>(state: state);
      },
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
    final theme = CLTheme.of(context);
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
            padding: EdgeInsets.all(theme.pagePadX),
            child: Row(
              children: [
                CLButton(
                  textStyle: CLTheme.of(context).bodyText.copyWith(color: CLTheme.of(context).primaryText),
                  iconAlignment: IconAlignment.start,
                  backgroundColor: CLTheme.of(context).muted,
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
  final _PagedDataTableState<TKey, TResultId, TResult> state;

  const _FiltersDialog({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final maxHeight = MediaQuery.of(context).size.height * 0.8;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(theme.pagePadX),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 480, maxHeight: maxHeight),
          child: CLPopupSurface(
            animate: false,
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header (fisso): titolo grande + chiudi, sulla superficie
                  // (niente container colorato, niente divider).
                  Padding(
                    padding: EdgeInsets.fromLTRB(theme.pagePadX, theme.pagePadX * 0.65, theme.gapMd, theme.pagePadX * 0.65),
                    child: Row(
                      children: [
                        Expanded(child: Text('Filtra con...', style: theme.heading6)),
                        CLIconButton(
                          onTap: () => Navigator.pop(context),
                          iconData: LucideIcons.x400,
                          backgroundColor: theme.muted,
                          iconColor: theme.primaryText,
                          size: theme.buttonHeightDefault,
                          iconSize: theme.iconSizeDefault,
                          tooltip: 'Chiudi',
                        ),
                      ],
                    ),
                  ),
                  // Filtri (scrollabili se troppi)
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(theme.pagePadX),
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
                  ),
                  // Footer (fisso) — niente divider sopra i bottoni
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: theme.pagePadX, vertical: theme.pagePadX * 0.65),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CLButton(
                          textStyle: theme.bodyLabel.copyWith(color: theme.primaryText),
                          iconAlignment: IconAlignment.start,
                          backgroundColor: theme.controlFill,
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
          padding: EdgeInsets.symmetric(horizontal: theme.gapMd),
          color: _hovered ? theme.muted : Colors.transparent,
          alignment: Alignment.centerLeft,
          child: widget.content,
        ),
      ),
    );
  }
}

/// Host opt-in: su mobile (compact) e con un [CLShellScope] antenato, pubblica
/// la filter bar nell'area contestuale dello shell invece di renderla inline.
/// Ri-fornisce i provider della tabella (state + theme + style) così la barra
/// costruita SOPRA la tabella (nello shell) trova le sue dipendenze. Altrove →
/// render inline invariato.
class _FilterBarShellHost<TKey extends Comparable, TResultId extends Comparable, TResult extends Object>
    extends StatefulWidget {
  const _FilterBarShellHost({required this.state, required this.child});

  final _PagedDataTableState<TKey, TResultId, TResult> state;
  final Widget child;

  @override
  State<_FilterBarShellHost<TKey, TResultId, TResult>> createState() =>
      _FilterBarShellHostState<TKey, TResultId, TResult>();
}

class _FilterBarShellHostState<TKey extends Comparable, TResultId extends Comparable, TResult extends Object>
    extends State<_FilterBarShellHost<TKey, TResultId, TResult>> {
  ShellSlotsController? _shell;
  bool _published = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _shell = CLShellScope.maybeOf(context);
  }

  @override
  void dispose() {
    if (_published) _shell?.setContextControls(const []);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shell = _shell;
    final compact = _isTableCompact(context);

    if (shell == null || !compact) {
      // Path invariato: render inline. Se prima avevamo pubblicato, pulisci.
      if (_published) {
        _published = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _shell?.setContextControls(const []);
        });
      }
      return widget.child;
    }

    // Mobile + shell: pubblica la barra (con i provider ri-forniti) e collassa
    // il render inline.
    final themeData = PagedDataTableTheme.of(context);
    final style = CLTableStyle.maybeOf(context);
    final state = widget.state;
    final barChild = widget.child;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      shell.setContextControls([
        ShellContextControl.custom(
          ShellCustom(
            (ctx) => _CLTableStyleScope(
              style: style,
              child: PagedDataTableTheme(
                data: themeData,
                child: ChangeNotifierProvider<_PagedDataTableState<TKey, TResultId, TResult>>.value(
                  value: state,
                  child: barChild,
                ),
              ),
            ),
          ),
        ),
      ]);
    });
    _published = true;
    return const SizedBox.shrink();
  }
}
