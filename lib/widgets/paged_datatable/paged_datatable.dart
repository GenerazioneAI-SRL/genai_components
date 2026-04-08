import '../../utils/models/pagination.model.dart';
import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:hugeicons/hugeicons.dart';
import 'package:genai_components/cl_theme.dart';
import 'package:genai_components/layout/constants/sizes.constant.dart';
import 'package:genai_components/widgets/buttons/cl_button.widget.dart';
import 'package:genai_components/widgets/cl_shimmer.widget.dart';
import 'package:genai_components/widgets/cl_text_field.widget.dart';
import 'package:genai_components/widgets/cl_container.widget.dart';
import 'package:genai_components/widgets/cl_dropdown/cl_dropdown.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import 'package:equatable/equatable.dart';
import 'package:responsive_framework/responsive_framework.dart';

part 'controls.dart';

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

part 'paged_datatable_boxed.dart';

part 'paged_datatable_state.dart';

part 'paged_datatable_theme.dart';

part 'pagination_result.dart';

part 'types.dart';

/// A paginated DataTable that allows page caching and filtering
/// [TKey] is the type of the page token
/// [TResult] is the type of data the data table will show.
class PagedDataTable<TKey extends Comparable, TResultId extends Comparable, TResult extends Object> extends StatelessWidget {
  /// The callback that gets executed when a page is fetched.
  final Future<(List<TResult>, Pagination?)> Function({int? page, int? perPage, Map<String, dynamic>? searchBy, Map<String, dynamic>? orderBy})
  fetchPage;

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

  final List<int>? pageSizes;
  final int? initialPageSize;
  final bool isFooterVisible;
  final bool isFilterBarVisible;
  final bool isInSnippet;
  final bool showBorder;
  final bool showTopBorder;
  final bool showFooter;
  final String? downloadButtonText;
  final IconData? downloadButtonIcon;
  final Future Function({Map<String, dynamic>? searchBy, Map<String, dynamic>? orderBy})? downloadPage;
  final bool isFilterBarRounded;
  final bool showShimmerLoading;

  PagedDataTable({
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
    this.customRowBuilder,
    this.refreshListener,
    this.onItemTap,
    this.tableActions = const [],
    this.actionsBuilder,
    this.isFooterVisible = true,
    this.isFilterBarVisible = true,
    this.isInSnippet = false,
    this.actionsTitle,
    this.showBorder = true,
    this.showTopBorder = true,
    this.showFooter = true,
    this.isFilterBarRounded = true,
    this.showShimmerLoading = true,
    this.expandedRowBuilder,
    this.onRowExpanded,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = theme ?? PagedDataTableThemeData(
      rowColors: [CLTheme.of(context).secondaryBackground, CLTheme.of(context).secondaryBackground],
      border: const RoundedRectangleBorder(side: BorderSide.none),
      backgroundColor: Colors.transparent,
      headerBackgroundColor: Colors.transparent,
      filtersHeaderBackgroundColor: Colors.transparent,
      footerBackgroundColor: Colors.transparent,
      titleStyle: CLTheme.of(context).heading1,
      footerTextStyle: CLTheme.of(context).bodyLabel,
      headerTextStyle: CLTheme.of(context).bodyLabel,
      textStyle: CLTheme.of(context).bodyText,
      buttonsColor: CLTheme.of(context).primary,
      rowsTextStyle: CLTheme.of(context).bodyText,
      configuration: PagedDataTableConfiguration(
        filterBarVisibile: isFilterBarVisible,
        footer: PagedDataTableFooterConfiguration(footerVisible: isFooterVisible),
        pageSizes: pageSizes ?? [5, 25, 50, 100],
        initialPageSize: initialPageSize ?? pageSizes?.first ?? 5,
      ),
    );

    final localTheme = effectiveTheme;
    return ChangeNotifierProvider<_PagedDataTableState<TKey, TResultId, TResult>>(
      create:
          (context) => _PagedDataTableState(
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
        // Whether actions column is present (either static or dynamic)
        final hasActions = tableActions.isNotEmpty || actionsBuilder != null;
        // Whether rows have expand icon
        final hasExpandIcon = expandedRowBuilder != null;
        // Left border indicator width in rows
        const double leftBorderWidth = 2.5;
        // Actions column width
        const double actionsColumnWidth = 40.0;
        // Checkbox area: left padding(Sizes.padding - leftBorderWidth = 15.5) + checkbox width(32)
        const double checkboxAreaWidth = 47.5;
        // Expand icon area: left padding(Sizes.padding - leftBorderWidth = 15.5) + icon width(24)
        const double expandIconAreaWidth = 39.5;

        Widget child = LayoutBuilder(
          builder: (context, constraints) {
            // Calculate width available for columns only
            var width =
                constraints.maxWidth -
                leftBorderWidth // left border in rows
                -
                (hasExpandIcon ? expandIconAreaWidth : 0) -
                (rowsSelectable ? checkboxAreaWidth : 0) -
                (hasActions ? actionsColumnWidth : 0);
            state.availableWidth = width;
            return ResponsiveBreakpoints.of(context).isDesktop
                ? Container(
                  decoration: BoxDecoration(
                    color: CLTheme.of(context).secondaryBackground,
                    border: showTopBorder ? Border(top: BorderSide(color: CLTheme.of(context).borderColor, width: 1)) : null,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(Sizes.borderRadius),
                      topRight: Radius.circular(Sizes.borderRadius),
                    ),
                  ),
                  child: Column(
                    children: [
                      /* FILTER TAB */
                      if (localTheme.configuration.filterBarVisibile &&
                          (header != null || mainMenus.isNotEmpty || extraMenus.isNotEmpty || state.filters.isNotEmpty)) ...[
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
                        ),
                      ],

                      /* HEADER ROW */
                      _PagedDataTableHeaderRow<TKey, TResultId, TResult>(rowsSelectable, width, idGetter, hasActions, hasExpandIcon),
                      Divider(height: 0, color: CLTheme.of(context).borderColor, thickness: 1),
                      /* ITEMS */
                      _PagedDataTableRows<TKey, TResultId, TResult>(
                        rowsSelectable,
                        this.onItemTap,
                        this.isInSnippet,
                        customRowBuilder ??
                            CustomRowBuilder<TResult>(
                              builder: (context, item) => throw UnimplementedError("This does not build nothing"),
                              shouldUse: (context, item) => false,
                            ),
                        noItemsFoundBuilder,
                        errorBuilder,
                        width,
                        this.actionsTitle,
                        this.tableActions,
                        this.actionsBuilder,
                        localTheme.configuration.initialPageSize,
                        showShimmerLoading,
                        this.expandedRowBuilder,
                        this.onRowExpanded,
                      ),
                    ],
                  ),
                )
                : Column(
                  children: [
                    if (localTheme.configuration.filterBarVisibile &&
                        (header != null || mainMenus.isNotEmpty || extraMenus.isNotEmpty || state.filters.isNotEmpty)) ...[
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: CLTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.all(Radius.circular(Sizes.borderRadius)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(Sizes.padding),
                          child: _PagedDataTableFilterTab<TKey, TResultId, TResult>(
                            mainMenus,
                            extraMenus,
                            header,
                            rowsSelectable,
                            idGetter,
                            downloadPage,
                            downloadButtonText,
                            downloadButtonIcon,
                            isFilterBarRounded,
                          ),
                        ),
                      ),
                      const SizedBox(height: Sizes.small),
                    ],
                    _PagedDataTableBoxed<TKey, TResultId, TResult>(
                      rowsSelectable,
                      this.onItemTap,
                      this.isInSnippet,
                      customRowBuilder ??
                          CustomRowBuilder<TResult>(
                            builder: (context, item) => throw UnimplementedError("This does not build nothing"),
                            shouldUse: (context, item) => false,
                          ),
                      noItemsFoundBuilder,
                      errorBuilder,
                      width,
                      this.actionsTitle,
                      this.tableActions,
                      this.actionsBuilder,
                    ),
                  ],
                );
          },
        );
        // apply configuration to this widget only
        child = PagedDataTableTheme(data: effectiveTheme, child: child);
        assert(effectiveTheme.rowColors != null ? effectiveTheme.rowColors!.length == 2 : true, "rowColors must contain exactly two colors");

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Sizes.borderRadius),
            border:
                showBorder
                    ? Border(
                      bottom: BorderSide(color: CLTheme.of(context).borderColor, width: 1),
                      left: BorderSide(color: CLTheme.of(context).borderColor, width: 1),
                      right: BorderSide(color: CLTheme.of(context).borderColor, width: 1),
                      top: BorderSide.none,
                    )
                    : null,
          ),
          child:
              ResponsiveBreakpoints.of(context).isDesktop
                  ? SingleChildScrollView(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(Sizes.borderRadius),
                            topLeft: Radius.circular(Sizes.borderRadius),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: CLTheme.of(context).secondaryBackground,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(Sizes.borderRadius),
                                topLeft: Radius.circular(Sizes.borderRadius),
                              ),
                            ),
                            child: child,
                          ),
                        ),
                        localTheme.configuration.footer.footerVisible
                            ? showFooter
                                ? Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: CLTheme.of(context).secondaryBackground,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(Sizes.borderRadius),
                                      bottomRight: Radius.circular(Sizes.borderRadius),
                                    ),
                                  ),
                                  child: _PagedDataTableFooter<TKey, TResultId, TResult>(themeData: localTheme),
                                )
                                : SizedBox.shrink()
                            : const SizedBox.shrink(),
                      ],
                    ),
                  )
                  : SingleChildScrollView(
                    child: Column(
                      children: [
                        child,
                        SizedBox(height: Sizes.padding),
                        localTheme.configuration.footer.footerVisible
                            ? showFooter
                                ? Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: CLTheme.of(context).secondaryBackground,
                                    borderRadius: const BorderRadius.all(Radius.circular(Sizes.borderRadius)),
                                  ),
                                  child: _PagedDataTableFooter<TKey, TResultId, TResult>(themeData: localTheme),
                                )
                                : SizedBox.shrink()
                            : const SizedBox.shrink(),
                        !this.isInSnippet ? SizedBox(height: Sizes.padding) : SizedBox.shrink(),
                      ],
                    ),
                  ),
        );
      },
    );
  }
}
