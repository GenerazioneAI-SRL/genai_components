import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
// Budella Shad: varianti SYNC delegate a ShadSelect (path a). Solo i simboli
// usati (show) per non inquinare il namespace. Firma CLDropdown invariata.
import 'package:shadcn_ui/shadcn_ui.dart'
    show ShadSelect, ShadOption, ShadSelectController;

import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import '../buttons/cl_loading_spinner.widget.dart';
import '../foundation/cl_pressable.widget.dart';
import '../foundation/cl_focus_ring.dart';
import 'cl_dropdown_registry.dart';
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
    // Path (a) — varianti SYNC (nessun asyncSearchCallback: items in memoria):
    // delega a ShadSelect (feature-complete: header/footer/allowDeselection/
    // multi/search + keyboard/focus/a11y nativi). L'async paginato + bottom-sheet
    // resta sul path CL sotto (DropdownState). Firma pubblica invariata.
    if (widget.asyncSearchCallback == null) {
      return _ClDropdownShad<T>(
        items: widget.items,
        itemBuilder: widget.itemBuilder,
        valueToShow: widget.valueToShow,
        hint: widget.hint,
        isMultiple: widget.isMultiple,
        selectedValues: widget.selectedValues,
        isEnabled: widget.isEnabled,
        isCompact: widget.isCompact,
        syncSearchCallback: widget.syncSearchCallback,
        onSelectItem: widget.onSelectItem,
        onSelectItems: widget.onSelectItems,
        onClearItem: widget.onClearItem,
        validators: widget.validators,
        fillColor: widget.fillColor,
      );
    }

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

// ═══════════════════════════════════════════════════════════════════════════
// Path (a) — CLDropdown SYNC su ShadSelect
// ───────────────────────────────────────────────────────────────────────────
// Varianti in-memory (singleSync/multipleSync): il nucleo è ShadSelect, che
// porta gratis tutte le feature Shad (allowDeselection, keyboard nav, focus
// trap, a11y, scroll-chevron, popover positioning). Attorno resta il "chrome"
// CL: label sopra + error sotto (FormField), token CL via ShadTheme.
//
// Preservato dal CL: validazione (validators/FormField), registry+selectByName
// (AI), sync selezione esterna (didUpdateWidget), search sync (client/callback),
// disabled, fillColor, isCompact, hint.
//
// Differenze dichiarate (UI ora "stile Shad", volutamente):
//  • multi trigger = etichette joined (Shad), non i chip rimovibili inline del
//    CL overlay. La rimozione avviene ri-aprendo e deselezionando (allowDeselection).
//  • clear single = deselezione dalla lista (allowDeselection), non la X nel campo.
// L'async paginato + il bottom-sheet mobile restano sul path CL (DropdownState).
// ═══════════════════════════════════════════════════════════════════════════
class _ClDropdownShad<T extends Object> extends StatefulWidget {
  const _ClDropdownShad({
    required this.items,
    required this.itemBuilder,
    required this.valueToShow,
    required this.hint,
    required this.isMultiple,
    required this.selectedValues,
    required this.isEnabled,
    required this.isCompact,
    this.syncSearchCallback,
    this.onSelectItem,
    this.onSelectItems,
    this.onClearItem,
    this.validators,
    this.fillColor,
  });

  final List<T> items;
  final Widget Function(BuildContext, T) itemBuilder;
  final String Function(T) valueToShow;
  final String hint;
  final bool isMultiple;
  final List<T> selectedValues;
  final bool isEnabled;
  final bool isCompact;
  final Future<List<T>> Function(String)? syncSearchCallback;
  final Function(T?)? onSelectItem;
  final Function(List<T>)? onSelectItems;
  final Function()? onClearItem;
  final List<FormFieldValidator<String>>? validators;
  final Color? fillColor;

  @override
  State<_ClDropdownShad<T>> createState() => _ClDropdownShadState<T>();
}

class _ClDropdownShadState<T extends Object> extends State<_ClDropdownShad<T>>
    implements ISelectableDropdown {
  late final ShadSelectController<T> _controller;
  late List<T> _filtered;

  @override
  void initState() {
    super.initState();
    _controller =
        ShadSelectController<T>(initialValue: widget.selectedValues.toSet());
    _filtered = widget.items;
    if (widget.hint.isNotEmpty) {
      CLDropdownRegistry.instance.register(widget.hint, this);
    }
  }

  @override
  void didUpdateWidget(covariant _ClDropdownShad<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Selezione cambiata dal parent (reset form, AI) → allinea il controller.
    if (!listEquals(oldWidget.selectedValues, widget.selectedValues)) {
      _controller.value = widget.selectedValues.toSet();
    }
    if (!listEquals(oldWidget.items, widget.items)) {
      _filtered = widget.items;
    }
  }

  @override
  void dispose() {
    if (widget.hint.isNotEmpty) {
      CLDropdownRegistry.instance.unregister(widget.hint);
    }
    _controller.dispose();
    super.dispose();
  }

  /// AI/registry: seleziona per nome (match esatto poi parziale su items).
  @override
  Future<bool> selectByName(String name) async {
    final lower = name.toLowerCase();
    T? match;
    for (final it in widget.items) {
      if (widget.valueToShow(it).toLowerCase() == lower) {
        match = it;
        break;
      }
    }
    if (match == null) {
      for (final it in widget.items) {
        if (widget.valueToShow(it).toLowerCase().contains(lower)) {
          match = it;
          break;
        }
      }
    }
    if (match == null) return false;
    if (widget.isMultiple) {
      _controller.value = {..._controller.value, match};
      widget.onSelectItems?.call(_controller.value.toList());
    } else {
      _controller.value = {match};
      widget.onSelectItem?.call(match);
    }
    return true;
  }

  void _runSearch(String q) {
    if (widget.syncSearchCallback != null) {
      widget.syncSearchCallback!(q).then((r) {
        if (mounted) setState(() => _filtered = r);
      });
    } else {
      setState(() => _filtered = q.isEmpty
          ? widget.items
          : widget.items
              .where((e) =>
                  widget.valueToShow(e).toLowerCase().contains(q.toLowerCase()))
              .toList());
    }
  }

  String get _formValue => widget.isMultiple
      ? _controller.value.map(widget.valueToShow).join(', ')
      : (_controller.value.isEmpty
          ? ''
          : widget.valueToShow(_controller.value.first));

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final bool hasSearch = widget.syncSearchCallback != null;

    final Widget placeholder = Text('Seleziona…',
        style: theme.bodyText
            .copyWith(color: theme.mutedForeground, height: 1.0));
    final EdgeInsets padding = EdgeInsets.symmetric(
        horizontal: theme.gapMd,
        vertical: widget.isCompact ? theme.gapSm * 0.75 : 10);

    List<Widget> options() => _filtered
        .map((e) => ShadOption<T>(
              value: e,
              child: DefaultTextStyle.merge(
                  style: theme.bodyText,
                  child: widget.itemBuilder(context, e)),
            ))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.hint.isNotEmpty) ...[
          Text(widget.hint,
              style: theme.smallText.copyWith(
                  fontWeight: FontWeight.w500, color: theme.secondaryText)),
          SizedBox(height: theme.gapSm),
        ],
        FormField<String>(
          initialValue: _formValue,
          validator:
              (widget.validators == null || widget.validators!.isEmpty)
                  ? null
                  : (value) {
                      for (final v in widget.validators!) {
                        final r = v(value);
                        if (r != null) return r;
                      }
                      return null;
                    },
          builder: (fstate) {
            // Allinea il FormField alla selezione corrente (validazione+error).
            if (fstate.value != _formValue) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) fstate.didChange(_formValue);
              });
            }

            final Widget select = widget.isMultiple
                ? ShadSelect<T>.multiple(
                    controller: _controller,
                    enabled: widget.isEnabled,
                    placeholder: placeholder,
                    options: options(),
                    padding: padding,
                    allowDeselection: true,
                    selectedOptionsBuilder: (context, values) => Text(
                        values.map(widget.valueToShow).join(', '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            theme.bodyText.copyWith(color: theme.primaryText)),
                    onChanged: (set) {
                      widget.onSelectItems?.call(set.toList());
                      fstate.didChange(set.map(widget.valueToShow).join(', '));
                    },
                  )
                : hasSearch
                    ? ShadSelect<T>.withSearch(
                        controller: _controller,
                        enabled: widget.isEnabled,
                        placeholder: placeholder,
                        options: options(),
                        padding: padding,
                        allowDeselection: true,
                        searchPlaceholder: Text('Cerca',
                            style: theme.bodyText.copyWith(
                                color: theme.mutedForeground, height: 1.0)),
                        onSearchChanged: _runSearch,
                        selectedOptionBuilder: (context, value) => Text(
                            widget.valueToShow(value),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.bodyText
                                .copyWith(color: theme.primaryText)),
                        onChanged: (v) {
                          widget.onSelectItem?.call(v);
                          if (v == null) widget.onClearItem?.call();
                          fstate.didChange(
                              v == null ? '' : widget.valueToShow(v));
                        },
                      )
                    : ShadSelect<T>(
                        controller: _controller,
                        enabled: widget.isEnabled,
                        placeholder: placeholder,
                        options: options(),
                        padding: padding,
                        allowDeselection: true,
                        selectedOptionBuilder: (context, value) => Text(
                            widget.valueToShow(value),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.bodyText
                                .copyWith(color: theme.primaryText)),
                        onChanged: (v) {
                          widget.onSelectItem?.call(v);
                          if (v == null) widget.onClearItem?.call();
                          fstate.didChange(
                              v == null ? '' : widget.valueToShow(v));
                        },
                      );

            if (!fstate.hasError) return select;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                select,
                SizedBox(height: theme.gapSm),
                Text(fstate.errorText ?? '',
                    style: theme.smallLabel
                        .copyWith(color: theme.danger, height: 1.3)),
              ],
            );
          },
        ),
      ],
    );
  }
}
