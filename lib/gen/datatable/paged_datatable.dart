import 'package:genai_components/gen/datatable/pagination.model.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:genai_components/gen/theme/gen_tokens.dart';
import 'package:genai_components/gen/theme/gen_sizes.dart';
import 'package:genai_components/gen/primitives/gen_primitives.dart';
import 'package:genai_components/gen/widgets/gen_compact_action_scope.dart';
import 'package:genai_components/gen/shell/gen_shell_slots.dart';
import 'package:genai_components/gen/widgets/gen_popup_menu.dart';
import 'package:genai_components/gen/widgets/gen_shimmer.dart';
import 'package:genai_components/old/widgets/cl_text_field.widget.dart';
import 'package:genai_components/gen/widgets/gen_container.dart';
import 'package:genai_components/gen/widgets/gen_select_async.dart';
import 'package:genai_components/gen/widgets/gen_datetime_field.dart';
import 'package:genai_components/gen/widgets/gen_month_field.dart';
import 'package:genai_components/gen/widgets/gen_year_field.dart';
import 'package:genai_components/old/widgets/cl_dropdown/cl_dropdown.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import 'package:equatable/equatable.dart';

part 'errors.dart';

part 'paged_datatable_column.dart';

part 'tableaction.model.dart';

part 'tableextramenu.model.dart';

part 'paged_datatable_column_header.dart';

part 'paged_datatable_controller.dart';

part 'paged_datatable_filter.dart';

part 'paged_datatable_filter_bar.dart';

part 'paged_datatable_filter_bar_menu.dart';

part 'paged_datatable_footer.dart';

part 'paged_datatable_menu.dart';

part 'paged_datatable_row_state.dart';

part 'paged_datatable_rows.dart';

part 'paged_datatable_row.dart';

part 'paged_datatable_row_actions.dart';

part 'paged_datatable_row_states.dart';

part 'paged_datatable_boxed.dart';

part 'paged_datatable_state.dart';

part 'paged_datatable_theme.dart';

part 'pagination_result.dart';

part 'types.dart';

/// Single source of truth for the fixed leading/trailing slot widths of a
/// desktop PagedDataTable row. The RESERVATION math (PagedDataTable.build),
/// the DATA row (_PagedDataTableRow), the HEADER row (_PagedDataTableHeaderRow)
/// and the SHIMMER rows (_ShimmerRows) all read these exact values, so the
/// width reserved for columns can never drift from the width actually rendered.
///
/// Pure-layout constants (NOT theme tokens, intentionally): the left border
/// indicator, the Material checkbox internal-padding compensation, and the
/// checkbox / expand placeholder slot widths.
class PagedDataTableRowMetrics {
  PagedDataTableRowMetrics._({
    required this.leftBorderWidth,
    required this.checkboxSlot,
    required this.expandSlot,
    required this.searchPrefixLeftPad,
    required this.searchPrefixIconSize,
    required this.pagePadX,
    required this.gap,
    required this.popupButtonSlot,
    required this.popupRightGap,
    required this.popupLeftGapWithInline,
    required this.inlineButtonSide,
  });

  // Pure-layout constants (shared by reserve + render).
  final double leftBorderWidth; // row left BorderSide width
  final double checkboxSlot; // SizedBox holding the 0.9-scaled Checkbox
  final double expandSlot; // SizedBox holding the chevron
  final double searchPrefixLeftPad; // left pad of the search-field prefix icon (== gapMd)
  final double searchPrefixIconSize; // search-field prefix icon size (shared with the filter bar)

  // Theme-derived (sourced from the SAME GenTokens getters the widgets use).
  final double pagePadX; // table horizontal content inset (theme.gapLg)
  final double gap; // theme.gapMd — gap BETWEEN inline buttons
  final double popupButtonSlot; // SizedBox around the 3-dot _ActionButton
  final double popupRightGap; // trailing gap right of the popup button
  final double popupLeftGapWithInline; // theme.gapSm — gap when inline+popup coexist
  final double inlineButtonSide; // theme.buttonHeightDefault — CLIconButton side

  factory PagedDataTableRowMetrics.of(BuildContext context) {
    final t = GenTokens.of(context);
    return PagedDataTableRowMetrics._(
      leftBorderWidth: 2.5,
      checkboxSlot: t.iconSizeDefault, // box stretto sul checkbox; Lg dx lo dà il padding cella
      expandSlot: 24.0,
      searchPrefixLeftPad: t.gapMd,
      searchPrefixIconSize: t.iconSizeCompact,
      pagePadX: t.gapLg, // table horizontal content inset = Lg (16)
      gap: t.gapMd,
      popupButtonSlot: 40.0,
      popupRightGap: t.gapLg, // trailing inset == left content inset
      popupLeftGapWithInline: t.gapSm,
      inlineButtonSide: t.buttonHeightCompact, // 32 — the value CLIconButton renders
    );
  }

  // ── Leading slot total widths (left padding + slot), reserve == render ──
  // The checkbox is CENTERED in its slot, and the slot is centered on the search
  // field's prefix-icon center — so the select-all checkbox sits directly under
  // the search magnifier with equal space left/right. Before expand: pagePadX
  // visual edge minus border.
  double get searchIconCenterX => pagePadX + searchPrefixLeftPad + searchPrefixIconSize / 2;
  // Lg a sinistra del checkbox dal bordo bolla: pagePadX meno il bordo riga
  // (che inseta già il contenuto).
  double get checkboxLeftPad => pagePadX - leftBorderWidth;
  // Gap a destra del checkbox: Lg qui + Lg del padding cella = 2Lg verso la colonna.
  double get checkboxRightGap => pagePadX;
  double get expandLeftPad => pagePadX - leftBorderWidth;
  double get checkboxAreaWidth => checkboxLeftPad + checkboxSlot + checkboxRightGap;
  double get expandIconAreaWidth => expandLeftPad + expandSlot; // 17.5 + 24 = 41.5

  // ── Trailing actions cluster total width, reserve == render ──
  // inlineCount inline buttons (each inlineButtonSide wide, gap between them),
  // then optionally the popup column. The popup column carries its own right
  // gap; when inline buttons precede it, it also carries a left gap. When there
  // are inline buttons but NO popup, the cluster still needs a trailing gap.
  double inlineAreaWidth(int inlineCount) => inlineCount == 0 ? 0.0 : inlineCount * inlineButtonSide + (inlineCount - 1) * gap;

  double popupColumnWidth(bool inlinePresent) => (inlinePresent ? popupLeftGapWithInline : 0.0) + popupButtonSlot + popupRightGap;

  double actionsColumnWidth({required int inlineCount, required bool hasPopup}) {
    final inline = inlineAreaWidth(inlineCount);
    if (hasPopup) return inline + popupColumnWidth(inlineCount > 0);
    if (inlineCount > 0) return inline + popupRightGap; // trailing gap, no popup
    return 0.0;
  }
}

/// Soglia (px) sotto cui la tabella usa la vista a card (telefono).
/// Tablet e desktop (>= soglia) usano la tabella classica.
const double _kTableCardBreakpoint = 600.0;

/// True su telefono (larghezza < soglia): la tabella mostra le card.
bool _isTableCompact(BuildContext context) => MediaQuery.sizeOf(context).width < _kTableCardBreakpoint;

/// Restituisce il colore primario effettivo per gli elementi della tabella:
/// usa `PagedDataTableTheme.buttonsColor` se valorizzato (override via
/// `PagedDataTable(primaryColor: ...)`), altrimenti `GenTokens.primary`.
Color _effectiveTablePrimary(BuildContext context) {
  return GenTableStyle.maybeOf(context)?.primary ?? PagedDataTableTheme.maybeOf(context)?.buttonsColor ?? GenTokens.of(context).primary;
}

/// Override colori per-istanza di [PagedDataTable]. Ogni campo null -> token GenTokens.
class GenTableStyle {
  final Color? primary; // accent: selezione, sort, badge, checkbox
  final Color? searchFill; // bg campo ricerca
  final Color? headerBackground; // bg riga header
  final Color? buttonFill; // bg bottoni toolbar (Filtri / Altre azioni)
  final Color? border; // bordi / divider

  const GenTableStyle({this.primary, this.searchFill, this.headerBackground, this.buttonFill, this.border});

  static GenTableStyle? maybeOf(BuildContext c) => c.dependOnInheritedWidgetOfExactType<_CLTableStyleScope>()?.style;
}

class _CLTableStyleScope extends InheritedWidget {
  final GenTableStyle? style;
  const _CLTableStyleScope({required this.style, required super.child});
  @override
  bool updateShouldNotify(_CLTableStyleScope old) => old.style != style;
}

// Chrome tabella (ricerca + bottoni toolbar) = primaryBackground: superfici
// "flat", appena accennate sul toolbar bianco (secondaryBackground). controlFill
// resta solo per i bottoni che vivono SUL grigio (es. azioni nelle row).
// Override per-tabella via GenTableStyle.
Color _tableHeaderBg(BuildContext c) => GenTableStyle.maybeOf(c)?.headerBackground ?? GenTokens.of(c).secondaryBackground;

/// A paginated DataTable that allows page caching and filtering
/// [TKey] is the type of the page token
/// [TResult] is the type of data the data table will show.
/// Public Gen alias for the migrated paged data table.
typedef GenDataTable<TKey extends Comparable, TResultId extends Comparable, TResult extends Object>
    = PagedDataTable<TKey, TResultId, TResult>;

class PagedDataTable<TKey extends Comparable, TResultId extends Comparable, TResult extends Object> extends StatelessWidget {
  /// The callback that gets executed when a page is fetched.
  final Future<(List<TResult>, Pagination?)> Function({int? page, int? perPage, Map<String, dynamic>? searchBy, Map<String, dynamic>? orderBy}) fetchPage;

  /// The initial page to fetch.
  final TKey initialPage;

  final TextTableFilter? mainFilter;

  /// The list of filters to show.
  final List<TableFilter>? extraFilters;

  /// A custom controller used to programatically control the table.
  final PagedDataTableController<TKey, TResultId, TResult>? controller;

  /// The list of columns to display.
  final List<BaseTableColumn<TResult>> columns;

  final List<Widget> mainMenus;

  /// A custom menu tooltip to show in the filter bar.
  final List<TableExtraMenu> extraMenus;

  /// A custom widget to build in the footer, aligned to the left.
  ///
  /// Filter widgets remain untouched.
  final Widget? header;

  /// A custom builder that display any error.
  final ErrorBuilder? errorBuilder;

  /// A custom builder that builds when no item is found.
  final WidgetBuilder? noItemsFoundBuilder;

  /// A custom theme to apply only to this DataTable instance.
  final PagedDataTableThemeData? theme;

  /// Override colori per-istanza (vedi [GenTableStyle]). Null -> token GenTokens.
  final GenTableStyle? style;

  /// Indicates if the table allows the user to select rows.
  final bool rowsSelectable;

  /// A custom builder that builds a row.
  final CustomRowBuilder<TResult>? customRowBuilder;

  /// A stream to listen and refresh the table when any update is received.
  final Stream? refreshListener;

  /// A function that returns the id of an item.
  final ModelIdGetter<TResultId, TResult> idGetter;

  final List<TableAction<TResult>> tableActions;

  /// A function that builds table actions based on the current item
  final List<TableAction<TResult>> Function(TResult item)? actionsBuilder;

  final Function(TResult)? onItemTap;

  final Function(TResult)? actionsTitle;

  /// Builder opzionale per mostrare contenuto espanso sotto la riga
  final Widget Function(BuildContext context, TResult item)? expandedRowBuilder;

  /// Callback chiamata quando una riga viene espansa
  final Future<void> Function(TResult item)? onRowExpanded;

  /// Builder opzionale per le azioni nella toolbar di selezione (appare quando almeno una riga è selezionata).
  /// Ritorna solo i widget delle azioni: badge "X selezionati" e "Deseleziona tutto" vengono
  /// gestiti internamente dalla tabella.
  final List<Widget> Function(BuildContext context, int selectedCount, List<TResult> selectedItems)? selectionActionsBuilder;

  /// Mostra il checkbox "seleziona tutti" nell'header. Default true. Se false
  /// resta lo slot (allineamento) ma niente select-all: la selezione avviene
  /// solo per-riga. Le checkbox di riga restano sempre attive con [rowsSelectable].
  final bool selectAllInHeader;

  final List<int>? pageSizes;
  final int? initialPageSize;
  final bool isFooterVisible;
  final bool isFilterBarVisible;
  final bool isInSnippet;
  final bool showBorder;
  final bool showTopBorder;

  /// Se true la tabella NON disegna la propria card (sfondo/ombra/bordo/raggio):
  /// pensata per essere annidata in un GenContainer che fornisce gia' la superficie.
  final bool embedded;
  final bool showFooter;
  final String? downloadButtonText;
  final IconData? downloadButtonIcon;
  final Future Function({Map<String, dynamic>? searchBy, Map<String, dynamic>? orderBy})? downloadPage;
  final bool isFilterBarRounded;

  /// Opt-in: su mobile (compact) e con un `GenShellScope` antenato, la filter bar
  /// non si renderizza inline ma pubblica i suoi controlli nell'area contestuale
  /// dello shell (riga alta sopra la bottom bar). Default false → comportamento
  /// invariato per ogni tabella esistente (zero blast radius).
  final bool hoistFilterBarToShell;

  final bool showShimmerLoading;

  /// Titolo opzionale mostrato nell'header della tabella (stessa grafica di GenContainer).
  final String? title;

  /// Widget custom da mostrare al posto di [title]. Ha precedenza su [title] e [titleIcon].
  final Widget? titleWidget;

  /// Icona opzionale mostrata a sinistra del [title]. Ignorata se [titleWidget] è valorizzato.
  final Widget? titleIcon;

  /// Override stile del [title]. Default `theme.heading2`.
  final TextStyle? titleStyle;

  /// Colore di sfondo dell'header del titolo (applicato con alpha 0.08).
  final Color? titleBackgroundColor;

  /// Azioni opzionali mostrate nella STESSA riga del titolo, allineate a destra,
  /// sopra la filter bar/ricerca. L'header del titolo compare anche se è
  /// valorizzato solo questo (senza [title]/[titleWidget]).
  final List<Widget> titleActions;

  /// Colore primario applicato agli elementi interattivi della tabella
  /// (indicatore di sort, riga selezionata, checkbox, hover, badge filtri,
  /// toolbar di selezione, empty state).
  /// Se null, viene usato `GenTokens.of(context).primary`.
  final Color? primaryColor;

  /// Se true la tabella riempie l'altezza del parent (che DEVE essere bounded,
  /// es. dentro un `Expanded`): filter bar, header e footer restano fissi e
  /// scorrono solo le righe. Se false (default) la tabella è alta quanto il
  /// contenuto e scorre col parent.
  final bool fillHeight;

  /// ScrollController della PAGINA, per il caso "scroll della pagina, non della
  /// tabella" (`infiniteScroll` senza `fillHeight`). Se fornito, la tabella gestisce
  /// internamente l'auto-fill (carica finché il viewport è pieno) e il load a fine
  /// scroll: la pagina passa solo il controller, niente plumbing manuale.
  final ScrollController? pageScrollController;

  /// Se true abilita l'infinite scroll: la lista possiede lo scroll (come
  /// [fillHeight]) e carica la pagina successiva quando ci si avvicina al fondo
  /// (`nextPage(isInfiniteScroll: true)` → append), con loader in coda e footer
  /// di paginazione nascosto. Il parent DEVE dare un'altezza bounded alla tabella
  /// (es. `Expanded`). Opt-in su tutti i breakpoint.
  final bool infiniteScroll;

  const PagedDataTable({
    this.downloadPage,
    this.downloadButtonText,
    this.downloadButtonIcon,
    required this.fetchPage,
    required this.initialPage,
    required this.columns,
    required this.idGetter,
    this.mainFilter,
    this.extraFilters,
    this.mainMenus = const [],
    this.extraMenus = const [],
    this.controller,
    this.header,
    this.theme,
    this.pageSizes,
    this.initialPageSize,
    this.errorBuilder,
    this.noItemsFoundBuilder,
    this.rowsSelectable = true,
    this.selectAllInHeader = true,
    this.customRowBuilder,
    this.refreshListener,
    this.onItemTap,
    this.tableActions = const [],
    this.actionsBuilder,
    this.isFooterVisible = true,
    this.isFilterBarVisible = true,
    this.isInSnippet = false,
    this.actionsTitle,
    // Foundation: card tabella = L1 + ombra soft, NO border di default (opt-in).
    this.showBorder = false,
    this.showTopBorder = true,
    this.embedded = false,
    this.showFooter = true,
    this.isFilterBarRounded = true,
    this.hoistFilterBarToShell = false,
    this.showShimmerLoading = true,
    this.expandedRowBuilder,
    this.onRowExpanded,
    this.selectionActionsBuilder,
    this.title,
    this.titleWidget,
    this.titleIcon,
    this.titleStyle,
    this.titleBackgroundColor,
    this.titleActions = const [],
    this.primaryColor,
    this.fillHeight = false,
    this.infiniteScroll = false,
    this.pageScrollController,
    this.style,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = theme ??
        PagedDataTableThemeData(
          rowColors: [GenTokens.of(context).secondaryBackground, GenTokens.of(context).secondaryBackground],
          border: const RoundedRectangleBorder(side: BorderSide.none),
          backgroundColor: Colors.transparent,
          headerBackgroundColor: Colors.transparent,
          filtersHeaderBackgroundColor: Colors.transparent,
          footerBackgroundColor: Colors.transparent,
          titleStyle: GenTokens.of(context).heading1,
          footerTextStyle: GenTokens.of(context).bodyLabel,
          headerTextStyle: GenTokens.of(context).bodyLabel,
          textStyle: GenTokens.of(context).bodyText,
          buttonsColor: primaryColor ?? GenTokens.of(context).primary,
          rowsTextStyle: GenTokens.of(context).bodyText,
          configuration: PagedDataTableConfiguration(
            filterBarVisibile: isFilterBarVisible,
            footer: PagedDataTableFooterConfiguration(footerVisible: isFooterVisible),
            pageSizes: pageSizes ?? [5, 25, 50, 100],
            initialPageSize: initialPageSize ?? pageSizes?.first ?? 5,
          ),
        );

    final localTheme = effectiveTheme;
    final Widget tableTree = ChangeNotifierProvider<_PagedDataTableState<TKey, TResultId, TResult>>(
      create: (context) => _PagedDataTableState(
        downloadCallback: downloadPage,
        columns: columns,
        rowsSelectable: rowsSelectable,
        showShimmerLoading: showShimmerLoading,
        mainFilter: mainFilter,
        extraFilters: extraFilters,
        idGetter: idGetter,
        controller: controller,
        fetchCallback: fetchPage,
        initialPage: initialPage,
        pageSize: localTheme.configuration.initialPageSize,
        refreshListener: refreshListener,
      ),
      builder: (context, widget) {
        var state = context.read<_PagedDataTableState<TKey, TResultId, TResult>>();
        // Update columns reference so cellBuilder closures use the latest theme
        state.columns = columns;
        // Split actions into inline (rendered as plain compact icon button in
        // the row) and popup (rendered behind the 3-dot menu).
        final inlineActions = tableActions.where((a) => a.inline).toList();
        final popupActionsCount = tableActions.where((a) => !a.inline).length;
        // Popup column shows when static popup actions exist or a dynamic
        // actionsBuilder is provided (which may yield popup actions per row).
        final hasPopupActions = popupActionsCount > 0 || actionsBuilder != null;
        // Whether rows have expand icon
        final hasExpandIcon = expandedRowBuilder != null;
        // Single source of truth: reserve == render for every leading/trailing slot.
        final m = PagedDataTableRowMetrics.of(context);
        final inlineCount = inlineActions.length;
        final double actionsColumnWidth = m.actionsColumnWidth(inlineCount: inlineCount, hasPopup: hasPopupActions);
        final double checkboxAreaWidth = m.checkboxAreaWidth;
        final double expandIconAreaWidth = m.expandIconAreaWidth;
        final hasAnyActions = hasPopupActions || inlineActions.isNotEmpty;

        Widget child = LayoutBuilder(
          builder: (context, constraints) {
            // Bolla righe: ingombro orizzontale = margin Lg per lato (niente bordo).
            final double rowsBubbleInset = 2 * GenSizes.gapLg;
            // Calculate width available for columns only
            var width = constraints.maxWidth -
                rowsBubbleInset // la bolla restringe la zona righe
                -
                m.leftBorderWidth // left border in rows
                -
                (hasExpandIcon ? expandIconAreaWidth : 0) -
                (rowsSelectable ? checkboxAreaWidth : 0) -
                (hasAnyActions ? actionsColumnWidth : 0);
            state.availableWidth = width;
            // Solo fillHeight fa possedere lo scroll alla lista (Expanded +
            // physics scrollabili). Con infiniteScroll ma SENZA fillHeight la lista
            // resta shrinkWrap: è la PAGINA a scrollare e a guidare il load-more
            // (controller.loadNextPage). La tabella renderizza solo righe + loader.
            final ownScroll = fillHeight;
            // Sezione righe desktop: in fillHeight occupa lo spazio rimanente
            // e scorre da sola (header/filter bar restano fissi sopra).
            Widget rowsSection = _PagedDataTableRows<TKey, TResultId, TResult>(
              rowsSelectable,
              onItemTap,
              isInSnippet,
              customRowBuilder ??
                  CustomRowBuilder<TResult>(
                    builder: (context, item) => throw UnimplementedError("This does not build nothing"),
                    shouldUse: (context, item) => false,
                  ),
              noItemsFoundBuilder,
              errorBuilder,
              width,
              actionsTitle,
              tableActions,
              actionsBuilder,
              localTheme.configuration.initialPageSize,
              showShimmerLoading,
              expandedRowBuilder,
              onRowExpanded,
              ownScroll,
              hasExpandIcon,
              hasAnyActions ? actionsColumnWidth : 0.0,
              infiniteScroll,
            );
            // Righe trasparenti: nessun container arrotondato che le contiene, solo
            // il gutter orizzontale. 0 in `embedded` (il gutter lo dà la pagina host
            // → niente doppio padding).
            final double hGut = embedded ? 0.0 : GenSizes.gapLg;
            rowsSection = Padding(
              padding: EdgeInsets.symmetric(horizontal: hGut),
              child: rowsSection,
            );
            if (ownScroll) rowsSection = Expanded(child: rowsSection);
            // Sezione card mobile: stesso trattamento.
            Widget boxedSection = _PagedDataTableBoxed<TKey, TResultId, TResult>(
              rowsSelectable,
              onItemTap,
              isInSnippet,
              customRowBuilder ??
                  CustomRowBuilder<TResult>(
                    builder: (context, item) => throw UnimplementedError("This does not build nothing"),
                    shouldUse: (context, item) => false,
                  ),
              noItemsFoundBuilder,
              errorBuilder,
              width,
              actionsTitle,
              tableActions,
              actionsBuilder,
              ownScroll,
              infiniteScroll,
            );
            // Bolla righe (mobile): stesso container arrotondato, niente bordo.
            boxedSection = Container(
              margin: EdgeInsets.fromLTRB(hGut, GenSizes.gapLg, hGut, GenSizes.gapLg),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(GenSizes.radiusCard)),
              child: boxedSection,
            );
            if (ownScroll) boxedSection = Expanded(child: boxedSection);

            // Toolbar selezione condivisa tra desktop e mobile (vuota se nessun selectionActionsBuilder).
            final Widget selectionToolbar = selectionActionsBuilder == null
                ? const SizedBox.shrink()
                : Selector<_PagedDataTableState<TKey, TResultId, TResult>, int>(
                    selector: (context, model) => model._rowsSelectionChange,
                    builder: (context, _, __) {
                      final st = context.read<_PagedDataTableState<TKey, TResultId, TResult>>();
                      final selectedCount = st.selectedRows.length;
                      final clTheme = GenTokens.of(context);
                      final tablePrimary = _effectiveTablePrimary(context);

                      Widget toolbarContent;
                      if (selectedCount == 0) {
                        toolbarContent = const SizedBox.shrink(key: ValueKey('toolbar_hidden'));
                      } else {
                        final selectedItems = st.selectedRows.entries.where((e) => e.value < st._items.length).map((e) => st._items[e.value]).toList();
                        final actionWidgets = selectionActionsBuilder!(context, selectedCount, selectedItems);
                        final isDesktop = !_isTableCompact(context);
                        final isAllSelected = st._items.isNotEmpty && st._items.every((it) => st.selectedRows.containsKey(idGetter(it)));
                        toolbarContent = Container(
                          key: const ValueKey('toolbar_visible'),
                          padding: const EdgeInsets.symmetric(horizontal: GenSizes.padding, vertical: 10),
                          decoration: BoxDecoration(
                            color: tablePrimary.withValues(alpha: clTheme.opacitySubtle),
                            border: Border(
                              bottom: BorderSide(color: tablePrimary.withValues(alpha: 0.15), width: 1),
                            ),
                          ),
                          child: Row(
                            children: [
                              if (!isDesktop) ...[
                                Transform.scale(
                                  scale: 0.85,
                                  child: GenCheckbox(
                                    value: isAllSelected,
                                    onChanged: (_) {
                                      if (isAllSelected) {
                                        st.clearAllSelections();
                                      } else {
                                        st.selectAllRows();
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: GenSizes.small),
                              ],
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: tablePrimary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '$selectedCount selezionat${selectedCount == 1 ? 'o' : 'i'}',
                                  style: clTheme.bodyLabel.copyWith(
                                    color: tablePrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              if (actionWidgets.isNotEmpty) ...[
                                const SizedBox(width: GenSizes.padding),
                                ...actionWidgets,
                              ],
                              const Spacer(),
                              if (isDesktop)
                                TextButton(
                                  onPressed: () => st.clearAllSelections(),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: clTheme.gapMd, vertical: clTheme.gapIconText),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Deseleziona tutto',
                                    style: clTheme.bodyLabel.copyWith(
                                      color: clTheme.secondaryText,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }

                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) => SizeTransition(
                          sizeFactor: animation,
                          axisAlignment: -1,
                          child: FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, -0.3),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                              child: child,
                            ),
                          ),
                        ),
                        child: toolbarContent,
                      );
                    },
                  );
            return !_isTableCompact(context)
                ? Stack(
                    // Clip.none: lo Stack default (hardEdge) taglia il focus ring
                    // del search (esce a x<0 in embedded, gutter 0). La bolla
                    // esterna clippa già gli angoli.
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: GenTokens.of(context).secondaryBackground,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            /* FILTER TAB */
                            if (localTheme.configuration.filterBarVisibile &&
                                (header != null ||
                                    mainMenus.isNotEmpty ||
                                    extraMenus.isNotEmpty ||
                                    selectionActionsBuilder != null ||
                                    state.filters.isNotEmpty)) ...[
                              _PagedDataTableFilterTab<TKey, TResultId, TResult>(
                                mainMenus,
                                extraMenus,
                                header,
                                rowsSelectable,
                                idGetter,
                                downloadPage,
                                downloadButtonText,
                                downloadButtonIcon,
                                isFilterBarRounded,
                                hoistFilterBarToShell,
                                selectionActionsBuilder,
                                embedded,
                              ),
                            ],

                            // Desktop: le azioni bulk NON vivono più nella toolbar
                            // (filter tab) — vivono nella card flottante sopra il
                            // footer (vedi _DesktopBulkActionsFloatingCard sotto).

                            /* HEADER ROW — top 0: il gap dalla toolbar lo dà già il
                               centering del testo nella riga (44px) ≈ Lg visivo. */
                            Padding(
                              padding: EdgeInsets.fromLTRB(hGut, 0, hGut, 0),
                              child: _PagedDataTableHeaderRow<TKey, TResultId, TResult>(
                                  rowsSelectable, width, idGetter, hasAnyActions, hasExpandIcon, actionsColumnWidth, selectAllInHeader),
                            ),
                            /* ITEMS */
                            rowsSection,
                          ],
                        ),
                      ),
                      // Card flottante azioni bulk (desktop): overlay sopra le righe,
                      // ancorata gapLg SOPRA il footer (= bordo inferiore di questa
                      // sezione righe, il footer è la sezione sorella subito sotto).
                      // Non sposta le righe (è in overlay nello Stack).
                      if (selectionActionsBuilder != null)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: GenSizes.gapLg,
                          child: _DesktopBulkActionsFloatingCard<TKey, TResultId, TResult>(
                            selectionActionsBuilder: selectionActionsBuilder!,
                            idGetter: idGetter,
                          ),
                        ),
                    ],
                  )
                : Column(
                    children: [
                      // Filter bar mobile. Il tab DEVE essere costruito anche quando
                      // hoisted (è lui a pubblicare ricerca/filtri/sort nello shell),
                      // ma in quel caso NON deve occupare spazio inline: host → shrink,
                      // niente Container/padding → niente spazio morto in cima.
                      if (localTheme.configuration.filterBarVisibile &&
                          (header != null || mainMenus.isNotEmpty || extraMenus.isNotEmpty || state.filters.isNotEmpty))
                        Builder(builder: (context) {
                          final tab = _PagedDataTableFilterTab<TKey, TResultId, TResult>(
                            mainMenus,
                            extraMenus,
                            header,
                            rowsSelectable,
                            idGetter,
                            downloadPage,
                            downloadButtonText,
                            downloadButtonIcon,
                            isFilterBarRounded,
                            hoistFilterBarToShell,
                            // Hoisted: il tab passa il builder all'host che pubblica
                            // la barra bulk nel bottom shell (selectionBar). Il tab
                            // stesso non la renderizza inline su mobile (isDesktopBar).
                            selectionActionsBuilder,
                            embedded,
                          );
                          if (hoistFilterBarToShell) return tab;
                          // Niente SizedBox sotto: il gap verso il container row lo dà
                          // già il suo margine top Lg → solo Lg attorno al container.
                          return Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: GenTokens.of(context).secondaryBackground,
                              borderRadius: BorderRadius.all(Radius.circular(GenSizes.radiusCard)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(GenSizes.gapLg),
                              child: tab,
                            ),
                          );
                        }),
                      // Hoisted: la toolbar selezione vive nel bottom shell
                      // (selectionBar) → niente toolbar inline (evita doppione).
                      if (!hoistFilterBarToShell) selectionToolbar,
                      boxedSection,
                    ],
                  );
          },
        );
        assert(effectiveTheme.rowColors != null ? effectiveTheme.rowColors!.length == 2 : true, "rowColors must contain exactly two colors");

        final titleHeader = _buildTitleHeader(context);

        // Footer paginazione, condiviso tra le due modalità di layout.
        // Stessa superficie della tabella, separato da hairline superiore.
        final bool footerShown = localTheme.configuration.footer.footerVisible && showFooter && !infiniteScroll;
        final Widget footerSection = footerShown
            // Border top fornito dal solo _PagedDataTableFooter: il wrapper non lo
            // ridisegna, altrimenti doppio hairline sopra la paginazione.
            ? SizedBox(
                width: double.infinity,
                child: _PagedDataTableFooter<TKey, TResultId, TResult>(themeData: localTheme, embedded: embedded),
              )
            : const SizedBox.shrink();

        return _CLTableStyleScope(
          style: style,
          child: PagedDataTableTheme(
            data: effectiveTheme,
            child: Container(
              // Foundation: card L1 = secondaryBackground + ombra soft (cardShadowSoft),
              // border opt-in (default off). `embedded` → niente card propria: la
              // superficie la fornisce un GenContainer esterno.
              decoration: embedded
                  ? null
                  : BoxDecoration(
                      color: GenTokens.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(GenSizes.radiusCard),
                      boxShadow: GenTokens.of(context).cardShadowSoft,
                    ),
              child: Material(
                type: MaterialType.transparency,
                shape: RoundedRectangleBorder(
                  // Hairline solo se esplicitamente richiesto (showBorder). Niente
                  // bordo auto in dark: la card si appoggia al contrasto bg/righe.
                  side: (!embedded && showBorder)
                      ? BorderSide(color: GenTokens.of(context).borderColor, width: 1)
                      : BorderSide.none,
                  borderRadius: BorderRadius.circular(embedded ? 0 : GenSizes.radiusCard),
                ),
                // Embedded: nessun radius da clippare → clip.none così il focus
                // ring degli input (esce dal box) non viene tagliato al bordo x=0.
                clipBehavior: embedded ? Clip.none : Clip.antiAlias,
                child: !_isTableCompact(context)
                    // Solo fillHeight: niente scroll esterno, scorrono solo le righe.
                    // (infiniteScroll senza fillHeight → la pagina scrolla la tabella).
                    ? fillHeight
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (titleHeader != null) titleHeader,
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: GenTokens.of(context).secondaryBackground,
                                  ),
                                  child: child,
                                ),
                              ),
                              footerSection,
                            ],
                          )
                        : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (titleHeader != null) titleHeader,
                                Container(
                                  decoration: BoxDecoration(
                                    color: GenTokens.of(context).secondaryBackground,
                                  ),
                                  child: child,
                                ),
                                footerSection,
                              ],
                            ),
                          )
                    : fillHeight
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (titleHeader != null) titleHeader,
                              Expanded(child: child),
                              // Padding solo se il footer è mostrato: senza footer
                              // (infinite scroll) niente spazio morto in fondo.
                              if (footerShown) ...[
                                const SizedBox(height: GenSizes.padding),
                                // Sotto: solo il bottom padding Lg del footer (no extra).
                                footerSection,
                              ],
                            ],
                          )
                        : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (titleHeader != null) titleHeader,
                                child,
                                // Padding/footer solo se il footer è mostrato: in
                                // infinite scroll (footer nascosto) niente spazio
                                // morto sotto il messaggio di fine lista.
                                if (footerShown) ...[
                                  const SizedBox(height: GenSizes.padding),
                                  // Sotto: solo il bottom padding Lg del footer (no extra).
                                  footerSection,
                                ],
                              ],
                            ),
                          ),
              ),
            ),
          ),
        );
      },
    );

    // Scroll guidato dalla pagina (infiniteScroll senza fillHeight): la tabella
    // gestisce internamente auto-fill + load a fine scroll col controller della
    // pagina. Niente plumbing nei consumer.
    if (infiniteScroll && !fillHeight && pageScrollController != null && controller != null) {
      return _PageScrollAutoFill<TKey, TResultId, TResult>(
        scrollController: pageScrollController!,
        controller: controller!,
        child: tableTree,
      );
    }
    return tableTree;
  }

  Widget? _buildTitleHeader(BuildContext context) {
    final hasHeader = title != null || titleWidget != null || titleActions.isNotEmpty;
    if (!hasHeader) return null;
    final theme = GenTokens.of(context);
    return Container(
      // Sfondo = secondaryBackground (si fonde con la card della tabella), niente
      // border bottom: il titolo siede in cima alla card senza divider.
      decoration: BoxDecoration(
        color: titleBackgroundColor != null ? titleBackgroundColor!.withValues(alpha: 0.08) : theme.secondaryBackground,
      ),
      child: Padding(
        // Bottom 0: lo stacco Lg dalla filter bar lo dà già il SUO top padding.
        // Gutter orizzontale 0 in embedded (lo dà la pagina host → no doppio).
        padding: EdgeInsets.fromLTRB(embedded ? 0 : GenSizes.gapLg, GenSizes.gapLg, embedded ? 0 : GenSizes.gapLg, 0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: titleWidget != null
                  ? titleWidget!
                  : title != null
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (titleIcon != null) ...[
                              titleIcon!,
                              const SizedBox(width: GenSizes.gapMd),
                            ],
                            Flexible(
                              child: Text(
                                title!,
                                style: titleStyle ?? theme.heading2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
            ),
            // Azioni del titolo: stessa riga, allineate a destra. Gap Md dal titolo,
            // Sm tra loro.
            for (var i = 0; i < titleActions.length; i++) ...[
              SizedBox(width: i == 0 ? GenSizes.gapMd : GenSizes.gapSm),
              titleActions[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// Incapsula l'infinite-scroll guidato dalla PAGINA (scroll della pagina, non
/// della tabella): auto-fill se il viewport non è pieno + load a fine scroll.
/// Aggancia listener allo [scrollController] della pagina e ai cambi tabella; la
/// pagina passa solo il controller (sostituisce il vecchio plumbing in pagina).
class _PageScrollAutoFill<TKey extends Comparable, TResultId extends Comparable, TResult extends Object> extends StatefulWidget {
  const _PageScrollAutoFill({
    required this.scrollController,
    required this.controller,
    required this.child,
  });

  final ScrollController scrollController;
  final PagedDataTableController<TKey, TResultId, TResult> controller;
  final Widget child;

  @override
  State<_PageScrollAutoFill<TKey, TResultId, TResult>> createState() => _PageScrollAutoFillState<TKey, TResultId, TResult>();
}

class _PageScrollAutoFillState<TKey extends Comparable, TResultId extends Comparable, TResult extends Object>
    extends State<_PageScrollAutoFill<TKey, TResultId, TResult>> {
  bool _autoFilling = false;
  bool _changesAttached = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
    // I cambi tabella (controller.changes → _state) sono disponibili solo dopo il
    // primo build della tabella figlia: aggancio post-frame per evitare il late-init.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.controller.changes.addListener(_onTableChange);
      _changesAttached = true;
      _maybeAutoFill();
    });
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    if (_changesAttached) widget.controller.changes.removeListener(_onTableChange);
    super.dispose();
  }

  void _onTableChange() => _maybeAutoFill();

  void _onScroll() {
    if (!widget.scrollController.hasClients) return;
    final pos = widget.scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 320) widget.controller.loadNextPage();
  }

  /// Se la prima pagina non riempie il viewport non c'è scroll → il trigger su
  /// scroll non parte e la rotella in coda gira a vuoto. Carico in loop finché il
  /// contenuto scrolla o finiscono le pagine.
  Future<void> _maybeAutoFill() async {
    if (_autoFilling) return;
    _autoFilling = true;
    var guard = 0;
    try {
      while (mounted && guard++ < 50) {
        await WidgetsBinding.instance.endOfFrame;
        if (!mounted) return;
        if (!widget.scrollController.hasClients) return;
        if (widget.controller.isLoading) continue;
        if (widget.scrollController.position.maxScrollExtent > 0) return;
        if (!widget.controller.hasNextPage) return;
        await widget.controller.loadNextPage();
      }
    } finally {
      _autoFilling = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Card flottante (desktop) con le azioni bulk di selezione. Renderizzata come
/// overlay nello `Stack` della sezione righe, ancorata `gapLg` SOPRA il footer:
/// non sposta le righe quando appare. Contenuto orizzontale, larghezza-contenuto,
/// centrato. Compare/scompare con fade + slide dal basso (stesso feel della
/// vecchia toolbar di selezione). Mostra: badge conteggio, azioni
/// (`selectionActionsBuilder`), bottone "Deseleziona tutto".
class _DesktopBulkActionsFloatingCard<TKey extends Comparable, TResultId extends Comparable, TResult extends Object>
    extends StatelessWidget {
  const _DesktopBulkActionsFloatingCard({
    required this.selectionActionsBuilder,
    required this.idGetter,
  });

  final List<Widget> Function(BuildContext context, int selectedCount, List<TResult> selectedItems) selectionActionsBuilder;
  final ModelIdGetter<TResultId, TResult> idGetter;

  @override
  Widget build(BuildContext context) {
    return Selector<_PagedDataTableState<TKey, TResultId, TResult>, int>(
      selector: (context, model) => model._rowsSelectionChange,
      builder: (context, _, __) {
        final st = context.read<_PagedDataTableState<TKey, TResultId, TResult>>();
        final selectedCount = st.selectedRows.length;
        final clTheme = GenTokens.of(context);

        Widget content;
        if (selectedCount == 0) {
          content = const SizedBox.shrink(key: ValueKey('bulk_card_hidden'));
        } else {
          final selectedItems =
              st.selectedRows.entries.where((e) => e.value < st._items.length).map((e) => st._items[e.value]).toList();
          final actionWidgets = selectionActionsBuilder(context, selectedCount, selectedItems);
          content = Align(
            key: const ValueKey('bulk_card_visible'),
            alignment: Alignment.bottomCenter,
            child: Container(
              // Card flottante (overlay): solo ombra (popoverShadow), niente hairline.
              padding: EdgeInsets.all(GenSizes.gapLg),
              decoration: BoxDecoration(
                color: clTheme.secondaryBackground,
                borderRadius: BorderRadius.circular(clTheme.radiusCard),
                boxShadow: clTheme.popoverShadow,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Conteggio + deseleziona = unico bottone muted (icona X + testo).
                  ShadButton(
  onPressed: () => st.clearAllSelections(),
  leading: Icon(LucideIcons.x400),
  child: Text('$selectedCount selezionat${selectedCount == 1 ? 'o' : 'i'}'),
),
                  if (actionWidgets.isNotEmpty)
                    for (final action in actionWidgets) ...[
                      SizedBox(width: clTheme.gapMd),
                      action,
                    ],
                ],
              ),
            ),
          );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
          ),
          child: content,
        );
      },
    );
  }
}
