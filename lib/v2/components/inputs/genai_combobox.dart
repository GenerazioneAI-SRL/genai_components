import 'dart:async';

import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';
import 'genai_select.dart';
import '_field_frame.dart';

/// Searchable select with optional multi-selection — v2 (§4.3 kin).
///
/// Trigger looks like a text field with a chevron; unlike [GenaiSelect], the
/// trigger can render selected values inline as dismissable chips when
/// [multiSelect] is true. The overlay always has a search box and debounces
/// filter updates by [searchDebounce].
class GenaiCombobox<T> extends StatefulWidget {
  /// Selected value (single-select). Null when nothing is selected.
  final T? value;

  /// Selected values (multi-select). Empty when nothing is selected.
  final List<T>? values;

  /// Options rendered in the overlay. Reuses [GenaiSelectOption].
  final List<GenaiSelectOption<T>> options;

  /// Change callback for single-select.
  final ValueChanged<T>? onChanged;

  /// Change callback for multi-select.
  final ValueChanged<List<T>>? onValuesChanged;

  /// Placeholder when no value is selected.
  final String? hintText;

  /// Field label above the trigger.
  final String? label;

  /// Helper copy under the trigger.
  final String? helperText;

  /// Error copy; takes precedence over helper.
  final String? errorText;

  /// Appends a red asterisk after [label].
  final bool isRequired;

  /// Disabled — muted colours, no interaction.
  final bool isDisabled;

  /// When true, allows selecting multiple values; [onValuesChanged] is used.
  final bool multiSelect;

  /// Search placeholder.
  final String searchHint;

  /// Debounce before re-filtering on search input.
  /// Defaults to 200 ms (no v2 `searchDebounce` motion token yet).
  final Duration searchDebounce;

  /// Screen-reader label override.
  final String? semanticLabel;

  /// Single-select constructor.
  const GenaiCombobox({
    super.key,
    required this.value,
    required this.options,
    this.onChanged,
    this.hintText,
    this.label,
    this.helperText,
    this.errorText,
    this.isRequired = false,
    this.isDisabled = false,
    this.searchHint = 'Search',
    this.searchDebounce = const Duration(milliseconds: 200),
    this.semanticLabel,
  })  : values = null,
        onValuesChanged = null,
        multiSelect = false;

  /// Multi-select constructor.
  const GenaiCombobox.multi({
    super.key,
    required List<T> this.values,
    required this.options,
    this.onValuesChanged,
    this.hintText,
    this.label,
    this.helperText,
    this.errorText,
    this.isRequired = false,
    this.isDisabled = false,
    this.searchHint = 'Search',
    this.searchDebounce = const Duration(milliseconds: 200),
    this.semanticLabel,
  })  : value = null,
        onChanged = null,
        multiSelect = true;

  @override
  State<GenaiCombobox<T>> createState() => _GenaiComboboxState<T>();
}

class _GenaiComboboxState<T> extends State<GenaiCombobox<T>> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _overlay;
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;
  String _query = '';
  Timer? _debounce;

  double _triggerHeight(GenaiDensity d) {
    switch (d) {
      case GenaiDensity.compact:
        return 36;
      case GenaiDensity.normal:
        return 40;
      case GenaiDensity.spacious:
        return 44;
    }
  }

  @override
  void initState() {
    super.initState();
    _focusNode
        .addListener(() => setState(() => _focused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _overlay?.remove();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  bool get _hasError =>
      widget.errorText != null && widget.errorText!.isNotEmpty;
  bool get _isOpen => _overlay != null;

  GenaiSelectOption<T>? _optionFor(T v) {
    for (final o in widget.options) {
      if (o.value == v) return o;
    }
    return null;
  }

  List<GenaiSelectOption<T>> get _selectedOptions {
    if (!widget.multiSelect) {
      final s = widget.value == null ? null : _optionFor(widget.value as T);
      return s == null ? const [] : [s];
    }
    return [
      for (final v in widget.values ?? const [])
        if (_optionFor(v) != null) _optionFor(v)!
    ];
  }

  List<GenaiSelectOption<T>> get _filtered {
    if (_query.isEmpty) return widget.options;
    final q = _query.toLowerCase();
    return widget.options
        .where((o) =>
            o.label.toLowerCase().contains(q) ||
            (o.description?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  void _toggle() {
    if (widget.isDisabled) return;
    _isOpen ? _hide() : _show();
  }

  void _show() {
    _query = '';
    final e = OverlayEntry(builder: _buildOverlay);
    Overlay.of(context).insert(e);
    setState(() => _overlay = e);
  }

  void _hide() {
    _overlay?.remove();
    setState(() => _overlay = null);
  }

  void _onSearch(String q) {
    _debounce?.cancel();
    _debounce = Timer(widget.searchDebounce, () {
      _query = q;
      _overlay?.markNeedsBuild();
    });
  }

  void _pick(GenaiSelectOption<T> option) {
    if (widget.multiSelect) {
      final current = List<T>.from(widget.values ?? const []);
      if (current.contains(option.value)) {
        current.remove(option.value);
      } else {
        current.add(option.value);
      }
      widget.onValuesChanged?.call(current);
    } else {
      widget.onChanged?.call(option.value);
      _hide();
    }
  }

  void _removeChip(T v) {
    if (!widget.multiSelect) return;
    final current = List<T>.from(widget.values ?? const [])..remove(v);
    widget.onValuesChanged?.call(current);
  }

  Widget _buildOverlay(BuildContext overlayContext) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final elevation = context.elevation;
    final sizing = context.sizing;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _hide,
      child: Stack(
        children: [
          Positioned.fill(child: Container(color: Colors.transparent)),
          CompositedTransformFollower(
            link: _link,
            offset: Offset(0, _triggerHeight(sizing.density) + spacing.s4),
            showWhenUnlinked: false,
            child: Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: Colors.transparent,
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxHeight: 320, minWidth: 240),
                  child: IntrinsicWidth(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.surfaceOverlay,
                        borderRadius: BorderRadius.circular(radius.md),
                        border: Border.all(color: colors.borderDefault),
                        boxShadow: elevation.shadowForLayer(2),
                      ),
                      child: StatefulBuilder(
                        builder: (ctx, setOverlayState) {
                          final filtered = _filtered;
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(spacing.s8),
                                child: _ComboSearch(
                                  hint: widget.searchHint,
                                  onChanged: (v) {
                                    _onSearch(v);
                                    // Keep overlay redraw in sync with
                                    // debounced _query by calling
                                    // setOverlayState after the debounce.
                                    Timer(widget.searchDebounce, () {
                                      if (mounted) setOverlayState(() {});
                                    });
                                  },
                                ),
                              ),
                              Flexible(
                                child: filtered.isEmpty
                                    ? Padding(
                                        padding: EdgeInsets.all(spacing.s16),
                                        child: Text(
                                          'No results',
                                          style: ty.bodySm.copyWith(
                                              color: colors.textTertiary),
                                        ),
                                      )
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        padding: EdgeInsets.symmetric(
                                            vertical: spacing.s4),
                                        itemCount: filtered.length,
                                        itemBuilder: (_, i) {
                                          final o = filtered[i];
                                          final isSelected = widget.multiSelect
                                              ? (widget.values
                                                      ?.contains(o.value) ??
                                                  false)
                                              : o.value == widget.value;
                                          return _ComboRow(
                                            label: o.label,
                                            description: o.description,
                                            icon: o.icon,
                                            selected: isSelected,
                                            disabled: o.isDisabled,
                                            multi: widget.multiSelect,
                                            onTap: o.isDisabled
                                                ? null
                                                : () {
                                                    _pick(o);
                                                    setOverlayState(() {});
                                                  },
                                          );
                                        },
                                      ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final radius = context.radius;

    final height = _triggerHeight(sizing.density);
    final selected = _selectedOptions;

    // Resting border kept 1 px so layout never reflows on focus / open.
    // Focus ring rendered as a non-layout overlay below.
    final borderColor = widget.isDisabled
        ? colors.borderSubtle
        : _hasError
            ? colors.colorDanger
            : colors.borderDefault;
    const borderWidth = 1.0;

    Widget content;
    if (widget.multiSelect) {
      if (selected.isEmpty) {
        content = Text(
          widget.hintText ?? '',
          style: ty.bodyMd.copyWith(color: colors.textTertiary),
        );
      } else {
        content = Wrap(
          spacing: spacing.s4,
          runSpacing: spacing.s4,
          children: [
            for (final o in selected)
              _Chip(
                label: o.label,
                onRemove: widget.isDisabled ? null : () => _removeChip(o.value),
              ),
          ],
        );
      }
    } else {
      final s = selected.isEmpty ? null : selected.first;
      content = Text(
        s?.label ?? widget.hintText ?? '',
        style: ty.bodyMd.copyWith(
          color: s == null
              ? colors.textTertiary
              : (widget.isDisabled ? colors.textDisabled : colors.textPrimary),
        ),
        overflow: TextOverflow.ellipsis,
      );
    }

    final trigger = CompositedTransformTarget(
      link: _link,
      child: Focus(
        focusNode: _focusNode,
        child: MouseRegion(
          cursor: widget.isDisabled
              ? SystemMouseCursors.forbidden
              : SystemMouseCursors.click,
          opaque: false,
          hitTestBehavior: HitTestBehavior.opaque,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggle,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  constraints: BoxConstraints(minHeight: height),
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.s12,
                    vertical: widget.multiSelect && selected.isNotEmpty
                        ? spacing.s4
                        : 0,
                  ),
                  decoration: BoxDecoration(
                    color: widget.isDisabled
                        ? colors.surfaceHover
                        : colors.surfaceInput,
                    borderRadius: BorderRadius.circular(radius.sm),
                    border:
                        Border.all(color: borderColor, width: borderWidth),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: content),
                      SizedBox(width: spacing.iconLabelGap),
                      Icon(
                        _isOpen
                            ? LucideIcons.chevronUp
                            : LucideIcons.chevronDown,
                        size: sizing.iconSize,
                        color: colors.textTertiary,
                      ),
                    ],
                  ),
                ),
                if ((_focused || _isOpen || _hasError) && !widget.isDisabled)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(radius.sm),
                          border: Border.all(
                            color: _hasError
                                ? colors.colorDanger
                                : colors.borderFocus,
                            width: sizing.focusRingWidth,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      label: widget.semanticLabel ?? widget.label,
      hint: widget.hintText,
      enabled: !widget.isDisabled,
      focused: _focused,
      child: FieldFrame(
        label: widget.label,
        isRequired: widget.isRequired,
        isDisabled: widget.isDisabled,
        helperText: widget.helperText,
        errorText: widget.errorText,
        control: trigger,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final VoidCallback? onRemove;

  const _Chip({required this.label, this.onRemove});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: spacing.s8, vertical: spacing.s2),
      decoration: BoxDecoration(
        color: colors.colorPrimarySubtle,
        borderRadius: BorderRadius.circular(radius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: ty.labelMd.copyWith(color: colors.colorPrimaryText)),
          if (onRemove != null) ...[
            SizedBox(width: spacing.s4),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onRemove,
                child: Semantics(
                  button: true,
                  label: 'Remove $label',
                  child: Icon(LucideIcons.x,
                      size: (ty.labelMd.fontSize ?? 13) + 1,
                      color: colors.colorPrimaryText),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ComboRow extends StatefulWidget {
  final String label;
  final String? description;
  final IconData? icon;
  final bool selected;
  final bool disabled;
  final bool multi;
  final VoidCallback? onTap;

  const _ComboRow({
    required this.label,
    required this.selected,
    required this.multi,
    this.description,
    this.icon,
    this.disabled = false,
    this.onTap,
  });

  @override
  State<_ComboRow> createState() => _ComboRowState();
}

class _ComboRowState extends State<_ComboRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final radius = context.radius;

    return Opacity(
      opacity: widget.disabled ? 0.5 : 1,
      child: MouseRegion(
        cursor: widget.disabled
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
        opaque: false,
        hitTestBehavior: HitTestBehavior.opaque,
        onEnter: (_) {
          if (!_hovered) setState(() => _hovered = true);
        },
        onExit: (_) {
          if (_hovered) setState(() => _hovered = false);
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: spacing.s12, vertical: spacing.s8),
            color: _hovered ? colors.surfaceHover : Colors.transparent,
            child: Row(
              children: [
                if (widget.multi) ...[
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: widget.selected
                          ? colors.colorPrimary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(radius.xs),
                      border: Border.all(
                        color: widget.selected
                            ? colors.colorPrimary
                            : colors.borderStrong,
                        width: 1.5,
                      ),
                    ),
                    child: widget.selected
                        ? Icon(LucideIcons.check,
                            size: 12, color: colors.textOnPrimary)
                        : null,
                  ),
                  SizedBox(width: spacing.iconLabelGap),
                ],
                if (widget.icon != null) ...[
                  Icon(widget.icon,
                      size: sizing.iconSize, color: colors.textSecondary),
                  SizedBox(width: spacing.iconLabelGap),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.label,
                          style: ty.bodyMd.copyWith(color: colors.textPrimary)),
                      if (widget.description != null)
                        Text(widget.description!,
                            style: ty.labelSm
                                .copyWith(color: colors.textTertiary)),
                    ],
                  ),
                ),
                if (!widget.multi && widget.selected)
                  Icon(LucideIcons.check,
                      size: sizing.iconSize, color: colors.colorPrimary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ComboSearch extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const _ComboSearch({required this.hint, required this.onChanged});

  @override
  State<_ComboSearch> createState() => _ComboSearchState();
}

class _ComboSearchState extends State<_ComboSearch> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final radius = context.radius;
    return Container(
      height: 32,
      padding: EdgeInsets.symmetric(horizontal: spacing.s8),
      decoration: BoxDecoration(
        color: colors.surfaceInput,
        borderRadius: BorderRadius.circular(radius.sm),
        border: Border.all(color: colors.borderDefault),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.search,
              size: sizing.iconSize, color: colors.textTertiary),
          SizedBox(width: spacing.iconLabelGap),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              style: ty.bodyMd.copyWith(color: colors.textPrimary),
              decoration: InputDecoration(
                isDense: true,
                hintText: widget.hint,
                hintStyle: ty.bodyMd.copyWith(color: colors.textTertiary),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: widget.onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
