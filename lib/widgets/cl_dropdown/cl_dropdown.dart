import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

import '../../cl_theme.dart';
import '../cl_text_field.widget.dart';
import 'dropdown_state.dart';

class CLDropdown<T extends Object> extends StatefulWidget {
  const CLDropdown({
    super.key,
    required this.controller,
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
  });

  final TextEditingController controller;
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
  }) {
    List<T> previousvalueToShows = [];
    if (selectedValues != null) {
      previousvalueToShows.add(selectedValues);
    }
    return CLDropdown(
      key: key,
      controller: TextEditingController(),
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
  }) {
    List<T> previousvalueToShows = [];
    if (selectedValues != null) {
      previousvalueToShows.add(selectedValues);
    }
    return CLDropdown(
      key: key,
      controller: TextEditingController(),
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
  }) {
    return CLDropdown(
      key: key,
      controller: TextEditingController(),
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
  }) {
    return CLDropdown(
      key: key,
      controller: TextEditingController(),
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
    );
  }
}

class _CLDropdownState<T extends Object> extends State<CLDropdown<T>> {
  FocusNode? _focusNode;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    super.dispose();
  }

  bool _isExternalSelectionAligned(DropdownState<T> state) {
    if (widget.isMultiple) {
      return listEquals(state.selectedItems, widget.selectedValues);
    }

    final T? externalSelected =
        widget.selectedValues.isNotEmpty ? widget.selectedValues.first : null;
    return state.selectedItem == externalSelected;
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
      ),
      builder: (context, child) {
        var state = context.watch<DropdownState<T>>();

        if (!_isExternalSelectionAligned(state)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            state.syncExternalSelectedItems(widget.selectedValues);
          });
        }

        final theme = CLTheme.of(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Chip selezionati (sopra il campo) ──
            if (widget.isMultiple && state.selectedItems.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ...state.selectedItems.map(
                    (item) => Container(
                      padding: const EdgeInsets.only(
                          left: 10, right: 4, top: 4, bottom: 4),
                      decoration: BoxDecoration(
                        color: theme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: theme.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              widget.valueToShow(item),
                              style: theme.smallLabel.override(
                                  color: theme.primary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12),
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
                              child: Icon(Icons.close_rounded,
                                  size: 14, color: theme.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Pulsante "svuota tutto"
                  if (state.selectedItems.length > 1)
                    GestureDetector(
                      onTap: () {
                        state.clearAll();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.danger.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: theme.danger.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.clear_all_rounded,
                                size: 14, color: theme.danger),
                            const SizedBox(width: 4),
                            Text('Svuota',
                                style: theme.smallLabel.override(
                                    color: theme.danger,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            // ── Campo di testo ──
            CompositedTransformTarget(
              link: state.layerLink,
              child: CLTextField(
                key: state.textFormFieldKey,
                controller: state.textEditingController,
                labelText: widget.hint,
                isRequired: false,
                isEnabled: widget.isEnabled,
                isReadOnly: true,
                validators: widget.validators,
                fillColor: widget.fillColor,
                onTap: widget.isEnabled ? () => state.toggleOverlay() : null,
                suffixIcon: !widget.isEnabled
                    ? null
                    : state.loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : state.selectedItem != null
                            ? _deleteButton(
                                onPressed: () {
                                  state.removeItem(state.selectedItem!);
                                },
                              )
                            : HugeIcon(
                                icon: state.isOverlayOpen
                                    ? HugeIcons.strokeRoundedArrowUp01
                                    : HugeIcons.strokeRoundedArrowDown01,
                                color: CLTheme.of(context).secondaryText,
                                size: 16,
                              ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _deleteButton({required Function() onPressed}) {
    return GestureDetector(
        onTap: onPressed,
        child: Icon(Icons.close_rounded,
            size: 18,
            color: CLTheme.of(context).danger.withValues(alpha: 0.8)));
  }
}
