import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '_field_frame.dart';

/// A single selectable option in a [GenaiSelect] / combobox.
class GenaiSelectOption<T> {
  /// The value returned by the group.
  final T value;

  /// Visible label.
  final String label;

  /// Secondary description below the label.
  final String? description;

  /// Optional leading icon.
  final IconData? icon;

  /// When true, the option cannot be selected.
  final bool isDisabled;

  const GenaiSelectOption({
    required this.value,
    required this.label,
    this.description,
    this.icon,
    this.isDisabled = false,
  });
}

/// Dropdown single-select — v3 Forma LMS (§8 field rules).
///
/// The trigger shares shape with [GenaiTextField] — same 32/36/40 height,
/// same `surfaceCard` fill, `borderStrong` at rest that flips to
/// `textPrimary` on hover and `borderFocus` when focused or open. Tapping
/// opens an overlay with the option list; an optional search box filters
/// when [searchable] is true.
///
/// Overlay chrome per task spec §8: panel bg, `borderDefault`, radius
/// `xl` (12), `layer2` shadow.
class GenaiSelect<T> extends StatefulWidget {
  /// Currently selected value. Must match one of [options]' values (or be
  /// null when nothing is selected).
  final T? value;

  /// Options to render in the overlay.
  final List<GenaiSelectOption<T>> options;

  /// Fired with the picked value.
  final ValueChanged<T>? onChanged;

  /// Placeholder when no value is selected.
  final String? hintText;

  /// Field label above the trigger.
  final String? label;

  /// Helper copy below the trigger.
  final String? helperText;

  /// Error copy; takes precedence over helper.
  final String? errorText;

  /// Appends a red asterisk after [label].
  final bool isRequired;

  /// Muted colours, no interaction.
  final bool isDisabled;

  /// When true, renders a search box at the top of the overlay.
  final bool searchable;

  /// Placeholder for the search box when [searchable] is true.
  final String searchHint;

  /// Screen-reader label override.
  final String? semanticLabel;

  const GenaiSelect({
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
    this.searchable = false,
    this.searchHint = 'Cerca',
    this.semanticLabel,
  });

  @override
  State<GenaiSelect<T>> createState() => _GenaiSelectState<T>();
}

class _GenaiSelectState<T> extends State<GenaiSelect<T>> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _overlay;
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;
  bool _hovered = false;
  String _query = '';

  /// v3 field heights — 32/36/40 (compact/normal/spacious).
  double _triggerHeight(GenaiDensity d) {
    switch (d) {
      case GenaiDensity.compact:
        return 32;
      case GenaiDensity.normal:
        return 36;
      case GenaiDensity.spacious:
        return 40;
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
    super.dispose();
  }

  GenaiSelectOption<T>? get _selected {
    for (final o in widget.options) {
      if (o.value == widget.value) return o;
    }
    return null;
  }

  bool get _isOpen => _overlay != null;
  bool get _hasError =>
      widget.errorText != null && widget.errorText!.isNotEmpty;

  void _toggleOverlay() {
    if (widget.isDisabled) return;
    if (_isOpen) {
      _hideOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    _query = '';
    final entry = OverlayEntry(builder: _buildOverlay);
    Overlay.of(context).insert(entry);
    setState(() => _overlay = entry);
  }

  void _hideOverlay() {
    _overlay?.remove();
    setState(() => _overlay = null);
  }

  void _select(GenaiSelectOption<T> option) {
    widget.onChanged?.call(option.value);
    _hideOverlay();
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

  Widget _buildOverlay(BuildContext overlayContext) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final elevation = context.elevation;
    final sizing = context.sizing;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _hideOverlay,
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
                  constraints: const BoxConstraints(
                    maxHeight: 320,
                    minWidth: 200,
                  ),
                  child: IntrinsicWidth(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.surfaceOverlay,
                        borderRadius: BorderRadius.circular(radius.xl),
                        border: Border.all(color: colors.borderDefault),
                        boxShadow: elevation.shadowForLayer(2),
                      ),
                      child: StatefulBuilder(
                        builder: (ctx, setOverlayState) {
                          final filtered = _filtered;
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.searchable)
                                Padding(
                                  padding: EdgeInsets.all(spacing.s8),
                                  child: InternalSearchRow(
                                    hint: widget.searchHint,
                                    onChanged: (v) {
                                      _query = v;
                                      setOverlayState(() {});
                                    },
                                  ),
                                ),
                              Flexible(
                                child: filtered.isEmpty
                                    ? Padding(
                                        padding: EdgeInsets.all(spacing.s16),
                                        child: Text(
                                          'Nessun risultato',
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
                                          return InternalOptionRow(
                                            label: o.label,
                                            description: o.description,
                                            icon: o.icon,
                                            selected: o.value == widget.value,
                                            disabled: o.isDisabled,
                                            onTap: o.isDisabled
                                                ? null
                                                : () => _select(o),
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

    final selected = _selected;
    final height = _triggerHeight(sizing.density);

    // Resting border kept at 1 px so layout never reflows on focus / hover.
    // Focus ring rendered as a non-layout overlay below.
    final borderColor = widget.isDisabled
        ? colors.borderSubtle
        : _hasError
            ? colors.colorDanger
            : (_hovered ? colors.textPrimary : colors.borderStrong);
    const borderWidth = 1.0;

    final trigger = CompositedTransformTarget(
      link: _link,
      child: Shortcuts(
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): _ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): _ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.arrowDown): _ActivateIntent(),
        },
        child: Actions(
          actions: {
            _ActivateIntent: CallbackAction<_ActivateIntent>(
              onInvoke: (_) {
                _toggleOverlay();
                return null;
              },
            ),
          },
          child: Focus(
            focusNode: _focusNode,
            child: MouseRegion(
              cursor: widget.isDisabled
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
                onTap: _toggleOverlay,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: height,
                      padding: EdgeInsets.symmetric(horizontal: spacing.s12),
                      decoration: BoxDecoration(
                        color: widget.isDisabled
                            ? colors.surfaceHover
                            : colors.surfaceCard,
                        borderRadius: BorderRadius.circular(radius.md),
                        border:
                            Border.all(color: borderColor, width: borderWidth),
                      ),
                      child: Row(
                        children: [
                          if (selected?.icon != null) ...[
                            Icon(selected!.icon,
                                size: sizing.iconSize,
                                color: widget.isDisabled
                                    ? colors.textDisabled
                                    : colors.textSecondary),
                            SizedBox(width: spacing.iconLabelGap),
                          ],
                          Expanded(
                            child: Text(
                              selected?.label ?? widget.hintText ?? '',
                              style: ty.bodySm.copyWith(
                                color: selected == null
                                    ? colors.textTertiary
                                    : (widget.isDisabled
                                        ? colors.textDisabled
                                        : colors.textPrimary),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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
                    if ((_focused || _isOpen || _hasError) &&
                        !widget.isDisabled)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(radius.md),
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
        ),
      ),
    );

    return Semantics(
      button: true,
      label: widget.semanticLabel ?? widget.label,
      hint: widget.hintText,
      value: selected?.label,
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

class _ActivateIntent extends Intent {
  const _ActivateIntent();
}

/// Shared option row used inside [GenaiSelect] / `GenaiCombobox` overlays.
///
/// Package-private — exposed via a library-prefixed name so the combobox in
/// the same folder can reuse it without going through the public barrel.
class InternalOptionRow extends StatefulWidget {
  final String label;
  final String? description;
  final IconData? icon;
  final bool selected;
  final bool disabled;
  final VoidCallback? onTap;

  const InternalOptionRow({
    super.key,
    required this.label,
    this.description,
    this.icon,
    this.selected = false,
    this.disabled = false,
    this.onTap,
  });

  @override
  State<InternalOptionRow> createState() => _InternalOptionRowState();
}

class _InternalOptionRowState extends State<InternalOptionRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;

    final bg = widget.disabled
        ? Colors.transparent
        : (_hovered ? colors.surfaceHover : Colors.transparent);

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
              horizontal: spacing.s12,
              vertical: spacing.s8,
            ),
            color: bg,
            child: Row(
              children: [
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
                          style: ty.bodySm.copyWith(color: colors.textPrimary)),
                      if (widget.description != null)
                        Text(widget.description!,
                            style: ty.labelSm
                                .copyWith(color: colors.textTertiary)),
                    ],
                  ),
                ),
                if (widget.selected)
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

/// Shared search row used inside [GenaiSelect] / `GenaiCombobox` overlays.
class InternalSearchRow extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const InternalSearchRow({
    super.key,
    required this.hint,
    required this.onChanged,
  });

  @override
  State<InternalSearchRow> createState() => _InternalSearchRowState();
}

class _InternalSearchRowState extends State<InternalSearchRow> {
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
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(radius.md),
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
              style: ty.bodySm.copyWith(color: colors.textPrimary),
              decoration: InputDecoration(
                isDense: true,
                hintText: widget.hint,
                hintStyle: ty.bodySm.copyWith(color: colors.textTertiary),
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
