import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import '../buttons/cl_loading_spinner.widget.dart';
import '../foundation/cl_pressable.widget.dart';
import '../foundation/cl_focus_ring.dart';
import 'dropdown_state.dart';

class CLDropdown<T extends Object> extends StatefulWidget {
  const CLDropdown({
    super.key,
    required this.itemBuilder,
    required this.valueToShow,
    required this.hint,
    this.asyncSearchCallback,
    this.syncSearchCallback,
    this.items = const [],
    this.searchColumn,
    required this.isMultiple,
    required this.selectedValues,
    this.onSelectItem,
    this.length = 10,
    this.validators,
    this.isEnabled = true,
    this.onSelectItems,
    this.onClearItem,
    this.fillColor,
    this.isCompact = false,
  });

  final List<T> items;
  final Widget Function(BuildContext, T) itemBuilder;
  final int length;
  final String Function(T) valueToShow;
  final String hint;
  final Future<List<T>> Function(String)? syncSearchCallback;
  final Future<(List<T>, Object?)> Function(
      {int? page,
      int? perPage,
      Map<String, dynamic>? searchBy,
      Map<String, dynamic>? orderBy})? asyncSearchCallback;
  final String? searchColumn;
  final bool isMultiple;
  final List<T> selectedValues;
  final Function(T?)? onSelectItem;
  final Function(List<T>)? onSelectItems;
  final Function()? onClearItem;
  final List<FormFieldValidator<String>>? validators;
  final bool isEnabled;
  final Color? fillColor;

  /// Se `true`, campo a 32px e item del menu più densi.
  final bool isCompact;

  @override
  State<CLDropdown<T>> createState() => _CLDropdownState<T>();

  factory CLDropdown.singleSync({
    Key? key,
    required String hint,
    required List<T> items,
    required String Function(T) valueToShow,
    Future<List<T>> Function(String value)? searchCallback,
    required Widget Function(BuildContext, T) itemBuilder,
    required Function(T?)? onSelectItem,
    final List<FormFieldValidator<String>>? validators,
    int length = 10,
    T? selectedValues,
    Function()? onClearItem,
    Color? fillColor,
    bool isCompact = false,
  }) {
    List<T> previousvalueToShows = [];
    if (selectedValues != null) {
      previousvalueToShows.add(selectedValues);
    }
    return CLDropdown(
      key: key,
      items: items,
      isMultiple: false,
      itemBuilder: itemBuilder,
      valueToShow: valueToShow,
      selectedValues: previousvalueToShows,
      hint: hint,
      length: length,
      onSelectItem: onSelectItem,
      syncSearchCallback: searchCallback,
      onClearItem: onClearItem,
      fillColor: fillColor,
      isCompact: isCompact,
    );
  }

  factory CLDropdown.singleAsync({
    Key? key,
    required String hint,
    required Future<(List<T>, Object?)> Function(
            {int? page,
            int? perPage,
            Map<String, dynamic>? searchBy,
            Map<String, dynamic>? orderBy})?
        searchCallback,
    required searchColumn,
    required Widget Function(BuildContext, T) itemBuilder,
    required String Function(T) valueToShow,
    final List<FormFieldValidator<String>>? validators,
    final bool isEnabled = true,
    int length = 10,
    T? selectedValues,
    required Function(T?)? onSelectItem,
    Function()? onClearItem,
    Color? fillColor,
    bool isCompact = false,
  }) {
    List<T> previousvalueToShows = [];
    if (selectedValues != null) {
      previousvalueToShows.add(selectedValues);
    }
    return CLDropdown(
      key: key,
      itemBuilder: itemBuilder,
      hint: hint,
      isMultiple: false,
      isEnabled: isEnabled,
      valueToShow: valueToShow,
      asyncSearchCallback: searchCallback,
      searchColumn: searchColumn,
      selectedValues: previousvalueToShows,
      onSelectItem: onSelectItem,
      validators: validators,
      length: length,
      onClearItem: onClearItem,
      fillColor: fillColor,
      isCompact: isCompact,
    );
  }

  factory CLDropdown.multipleSync({
    Key? key,
    required String hint,
    required List<T> items,
    required Widget Function(BuildContext, T) itemBuilder,
    required Future<List<T>> Function(String value) searchCallback,
    required String Function(T) valueToShow,
    required Function(List<T>)? onSelectItems,
    final List<FormFieldValidator<String>>? validators,
    List<T> selectedValues = const [],
    int length = 10,
    bool isCompact = false,
  }) {
    return CLDropdown(
      key: key,
      items: items,
      isMultiple: true,
      itemBuilder: itemBuilder,
      valueToShow: valueToShow,
      hint: hint,
      selectedValues: selectedValues,
      onSelectItems: onSelectItems,
      length: length,
      syncSearchCallback: searchCallback,
      validators: validators,
      isCompact: isCompact,
    );
  }

  factory CLDropdown.multipleAsync({
    Key? key,
    required String hint,
    required Future<(List<T>, Object?)> Function(
            {int? page,
            int? perPage,
            Map<String, dynamic>? searchBy,
            Map<String, dynamic>? orderBy})?
        searchCallback,
    required searchColumn,
    required Widget Function(BuildContext, T) itemBuilder,
    required String Function(T) valueToShow,
    required Function(List<T>)? onSelectItems,
    final List<FormFieldValidator<String>>? validators,
    List<T> selectedValues = const [],
    int length = 10,
    bool isCompact = false,
  }) {
    return CLDropdown(
      key: key,
      itemBuilder: itemBuilder,
      valueToShow: valueToShow,
      hint: hint,
      isMultiple: true,
      asyncSearchCallback: searchCallback,
      searchColumn: searchColumn,
      selectedValues: selectedValues,
      onSelectItems: onSelectItems,
      length: length,
      validators: validators,
      isCompact: isCompact,
    );
  }
}

class _CLDropdownState<T extends Object> extends State<CLDropdown<T>> {
  // §2.2.6 — lazy FocusNode so it is created in build (where context exists)
  // and disposed exactly once. Allocating in initState would race with overlay
  // wiring; allocating in build without a guard would leak a node per rebuild.
  FocusNode? _focusNode;

  // Tracks whether the parent widget explicitly changed selectedValues.
  // We only call syncExternalSelectedItems on actual parent-driven changes,
  // NOT on every notifyListeners() rebuild — otherwise AI-driven selections
  // get immediately overwritten by the empty selectedValues of a new form.
  bool _externalSelectionChanged = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CLDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.selectedValues, widget.selectedValues)) {
      _externalSelectionChanged = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    _focusNode ??= FocusNode();
    return ChangeNotifierProvider<DropdownState<T>>(
      create: (context) => DropdownState(
        items: widget.items,
        asyncSearchCallback: widget.asyncSearchCallback,
        syncSearchCallback: widget.syncSearchCallback,
        context: context,
        focusNode: _focusNode!,
        itemBuilder: widget.itemBuilder,
        isMultiple: widget.isMultiple,
        valueToShow: widget.valueToShow,
        onSelectItem: widget.onSelectItem,
        onSelectItems: widget.onSelectItems,
        onClearItem: widget.onClearItem,
        previousSelectedItems: widget.selectedValues,
        perPage: widget.length,
        searchColumn: widget.searchColumn,
        hint: widget.hint,
        isCompact: widget.isCompact,
      ),
      builder: (context, child) {
        var state = context.watch<DropdownState<T>>();

        // Sync only when the parent explicitly changes selectedValues,
        // not on internal state rebuilds (which would wipe AI selections).
        if (_externalSelectionChanged) {
          _externalSelectionChanged = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            state.syncExternalSelectedItems(widget.selectedValues);
          });
        }

        final theme = CLTheme.of(context);
        // Trigger a BOTTONE (stile shadcn): placeholder o valore selezionato +
        // chevron. La ricerca vive nel popover, non nel trigger.
        final bool hasSingleValue =
            !widget.isMultiple && state.selectedItem != null;
        final String triggerText = hasSingleValue
            ? widget.valueToShow(state.selectedItem!)
            : 'Seleziona…';
        // Valore per la validazione form (label selezionata / vuoto).
        final String formValue = widget.isMultiple
            ? (state.selectedItems.isEmpty
                ? ''
                : state.selectedItems.map(widget.valueToShow).join(', '))
            : (state.selectedItem != null
                ? widget.valueToShow(state.selectedItem!)
                : '');
        final bool multiFilled =
            widget.isMultiple && state.selectedItems.isNotEmpty;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Label (hint) sopra, come i campi input ──
            if (widget.hint.isNotEmpty) ...[
              Text(
                widget.hint,
                style: theme.smallText.copyWith(
                    fontWeight: FontWeight.w500, color: theme.secondaryText),
              ),
              SizedBox(height: theme.gapSm),
            ],
            // ── Trigger a BOTTONE (search nel popover). FormField preserva la
            //    validazione del form + mostra l'error sotto (come l'input). ──
            FormField<String>(
              initialValue: formValue,
              validator: (widget.validators == null || widget.validators!.isEmpty)
                  ? null
                  : (value) {
                      for (final v in widget.validators!) {
                        final r = v(value);
                        if (r != null) return r;
                      }
                      return null;
                    },
              builder: (fstate) {
                // Allinea il valore del FormField alla selezione corrente.
                if (fstate.value != formValue) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) fstate.didChange(formValue);
                  });
                }
                final bool hasError = fstate.hasError;

                final Widget suffix = state.loading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CLLoadingSpinner(
                            size: 16, color: theme.secondaryText))
                    : hasSingleValue
                        ? GestureDetector(
                            onTap: () => state.removeItem(state.selectedItem!),
                            child: Icon(LucideIcons.x400,
                                size: 18,
                                color: theme.danger.withValues(alpha: 0.8)),
                          )
                        : Icon(
                            state.isOverlayOpen
                                ? LucideIcons.chevronUp400
                                : LucideIcons.chevronDown400,
                            color: theme.secondaryText,
                            size: theme.iconSizeCompact,
                          );

                final Widget trigger = CompositedTransformTarget(
                  link: state.layerLink,
                  child: CLPressable(
                    key: state.textFormFieldKey,
                    enabled: widget.isEnabled,
                    focusNode: _focusNode,
                    semanticLabel: widget.hint,
                    onTap: widget.isEnabled ? () => state.openOverlay() : null,
                    builder: (context, pstate) {
                      final double h = widget.isCompact
                          ? theme.inputHeightCompact
                          : theme.inputHeight;
                      Widget box = Container(
                        // Multi con selezioni: altezza auto (i badge vanno a capo);
                        // altrimenti altezza fissa input.
                        height: multiFilled ? null : h,
                        constraints:
                            multiFilled ? BoxConstraints(minHeight: h) : null,
                        padding: EdgeInsets.symmetric(
                            horizontal: theme.gapMd,
                            vertical: multiFilled ? theme.gapXs : 0),
                        decoration: BoxDecoration(
                          color: widget.isEnabled
                              ? (widget.fillColor ?? theme.secondaryBackground)
                              : (widget.fillColor ?? theme.secondaryBackground)
                                  .withValues(alpha: 0.6),
                          borderRadius:
                              BorderRadius.circular(theme.radiusControl),
                          border:
                              Border.all(color: theme.cardBorder, width: 1),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: multiFilled
                                  // Badge selezionati INLINE nel trigger (shadcn).
                                  ? Wrap(
                                      spacing: theme.gapXs,
                                      runSpacing: theme.gapXs,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        for (final item in state.selectedItems)
                                          Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                8, 2, 3, 2),
                                            decoration: BoxDecoration(
                                              color: theme.primary
                                                  .withValues(alpha: 0.08),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Sizes.radiusChip),
                                              border: Border.all(
                                                  color: theme.primary
                                                      .withValues(
                                                          alpha: theme
                                                              .opacityMedium)),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  widget.valueToShow(item),
                                                  style: theme.smallLabel
                                                      .override(
                                                          color: theme.primary,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                ),
                                                const SizedBox(width: 2),
                                                GestureDetector(
                                                  onTap: () =>
                                                      state.removeItem(item),
                                                  child: Icon(LucideIcons.x400,
                                                      size: 13,
                                                      color: theme.primary),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    )
                                  : Text(
                                      triggerText,
                                      style: theme.bodyText.copyWith(
                                          color: hasSingleValue
                                              ? theme.primaryText
                                              : theme.mutedForeground),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                            ),
                            SizedBox(width: theme.gapSm),
                            suffix,
                          ],
                        ),
                      );
                      // Ring SOLO su focus da tastiera (traversal), come input/
                      // bottoni. Non appare col mouse né dopo un select (unfocus).
                      if (pstate.focused) {
                        box = CustomPaint(
                          foregroundPainter: CLFocusRingPainter(
                              color: theme.ring, radius: theme.radiusControl),
                          child: box,
                        );
                      }
                      return box;
                    },
                  ),
                );

                if (!hasError) return trigger;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    trigger,
                    SizedBox(height: theme.gapSm),
                    Text(
                      fstate.errorText ?? '',
                      style: theme.smallLabel
                          .copyWith(color: theme.danger, height: 1.3),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}
