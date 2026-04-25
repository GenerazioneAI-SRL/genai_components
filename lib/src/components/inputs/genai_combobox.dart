import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/icons.dart';
import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';
import '../indicators/genai_chip.dart';
import 'genai_select.dart';

/// Searchable dropdown select (shadcn/ui Combobox equivalent).
///
/// Two modes, selected by [isMultiple]:
/// - Single select: pass [value] + [onChanged]. Trigger shows the selected
///   option label or [hintText].
/// - Multi select: pass [values] + [onChangedMulti]. Trigger renders each
///   selected option as a removable chip.
///
/// The popup contains an inline [GenaiTextField]-styled search box that
/// filters [options] by label (case-insensitive). If the filter yields no
/// matches, [emptyText] is displayed.
///
/// Reuses [GenaiSelectOption] from [GenaiSelect] so options are portable
/// between the two.
///
/// {@tool snippet}
/// ```dart
/// GenaiCombobox<String>(
///   label: 'Framework',
///   hintText: 'Search…',
///   value: selected,
///   options: const [
///     GenaiSelectOption(value: 'flutter', label: 'Flutter'),
///     GenaiSelectOption(value: 'react',   label: 'React'),
///   ],
///   onChanged: (v) => setState(() => selected = v),
/// );
/// ```
/// {@end-tool}
///
/// See also: [GenaiSelect], [GenaiTagInput].
class GenaiCombobox<T> extends StatefulWidget {
  /// Options rendered inside the popup. Required.
  final List<GenaiSelectOption<T>> options;

  /// Currently selected value — single-select mode only. Must be null when
  /// [isMultiple] is true.
  final T? value;

  /// Currently selected values — multi-select mode only. Must be null when
  /// [isMultiple] is false.
  final List<T>? values;

  /// Called when the single-select value changes. Called with `null` when
  /// the current value is cleared.
  final ValueChanged<T?>? onChanged;

  /// Called when the multi-select values change with the new list.
  final ValueChanged<List<T>>? onChangedMulti;

  /// Optional label rendered above the trigger.
  final String? label;

  /// Placeholder shown in the trigger when nothing is selected.
  final String? hintText;

  /// Message shown inside the popup when the search yields no results.
  final String? emptyText;

  /// If true, the combobox allows multi-selection (checkmarks, chips in
  /// trigger). If false, selecting an option closes the popup.
  final bool isMultiple;

  /// Accessible label for the trigger. Falls back to [label] if omitted.
  final String? semanticLabel;

  /// If true, the trigger is non-interactive and styled as disabled.
  final bool isDisabled;

  /// Size scale used for the trigger.
  final GenaiSize size;

  const GenaiCombobox({
    super.key,
    required this.options,
    this.value,
    this.values,
    this.onChanged,
    this.onChangedMulti,
    this.label,
    this.hintText,
    this.emptyText,
    this.isMultiple = false,
    this.semanticLabel,
    this.isDisabled = false,
    this.size = GenaiSize.md,
  })  : assert(
          !isMultiple || value == null,
          'Use `values` (not `value`) when isMultiple is true.',
        ),
        assert(
          isMultiple || values == null,
          'Use `value` (not `values`) when isMultiple is false.',
        );

  @override
  State<GenaiCombobox<T>> createState() => _GenaiComboboxState<T>();
}

class _GenaiComboboxState<T> extends State<GenaiCombobox<T>> {
  final LayerLink _link = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();
  final FocusNode _triggerFocus =
      FocusNode(debugLabel: 'GenaiCombobox.trigger');
  final FocusNode _overlayFocus = FocusNode(debugLabel: 'GenaiCombobox');
  final TextEditingController _searchCtrl = TextEditingController();

  OverlayEntry? _overlay;
  bool _open = false;
  bool _focused = false;
  String _query = '';
  int _activeIndex = 0;
  Timer? _debounce;

  List<T> get _values => widget.values ?? const [];

  void _toggle() {
    if (widget.isDisabled) return;
    _open ? _close() : _openMenu();
  }

  void _openMenu() {
    final overlay = Overlay.of(context);
    final box = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final width = box.size.width;
    _query = '';
    _activeIndex = 0;
    _searchCtrl.clear();
    _overlay = OverlayEntry(
      builder: (ctx) => _ComboboxMenu<T>(
        link: _link,
        width: width,
        onClose: _close,
        builder: (menuCtx) => _buildMenuBody(menuCtx),
      ),
    );
    overlay.insert(_overlay!);
    setState(() => _open = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_overlay != null) _overlayFocus.requestFocus();
    });
  }

  void _moveActive(int delta) {
    final filtered = _filteredOptions;
    if (filtered.isEmpty) return;
    var next = _activeIndex + delta;
    if (next < 0) next = filtered.length - 1;
    if (next >= filtered.length) next = 0;
    setState(() => _activeIndex = next);
    _overlay?.markNeedsBuild();
  }

  void _activateHighlighted() {
    final filtered = _filteredOptions;
    if (_activeIndex < 0 || _activeIndex >= filtered.length) return;
    final o = filtered[_activeIndex];
    if (o.isDisabled) return;
    if (widget.isMultiple) {
      _toggleMulti(o.value);
    } else {
      _selectSingle(o.value);
    }
  }

  void _close() {
    _overlay?.remove();
    _overlay = null;
    _query = '';
    if (mounted) setState(() => _open = false);
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(context.motion.searchDebounce, () {
      if (!mounted) return;
      setState(() {
        _query = v;
        _activeIndex = 0;
      });
      _overlay?.markNeedsBuild();
    });
  }

  List<GenaiSelectOption<T>> get _filteredOptions {
    if (_query.isEmpty) return widget.options;
    final q = _query.toLowerCase();
    return widget.options
        .where((o) => o.label.toLowerCase().contains(q))
        .toList();
  }

  void _selectSingle(T v) {
    widget.onChanged?.call(v);
    _close();
  }

  void _toggleMulti(T v) {
    final current = List<T>.from(_values);
    if (current.contains(v)) {
      current.remove(v);
    } else {
      current.add(v);
    }
    widget.onChangedMulti?.call(current);
    _overlay?.markNeedsBuild();
    setState(() {});
  }

  Widget _buildMenuBody(BuildContext menuCtx) {
    final colors = menuCtx.colors;
    final ty = menuCtx.typography;
    final spacing = menuCtx.spacing;
    final radius = menuCtx.radius;
    final sizing = menuCtx.sizing;
    final filtered = _filteredOptions;

    return Material(
      color: colors.surfaceCard,
      elevation: 0,
      borderRadius: BorderRadius.circular(radius.md),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius.md),
          border: Border.all(color: colors.borderDefault),
          boxShadow: menuCtx.elevation.shadow(3),
        ),
        constraints: const BoxConstraints(maxHeight: 320),
        child: Focus(
          focusNode: _overlayFocus,
          onKeyEvent: (node, event) {
            if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
              return KeyEventResult.ignored;
            }
            final key = event.logicalKey;
            if (key == LogicalKeyboardKey.escape) {
              _close();
              return KeyEventResult.handled;
            }
            if (key == LogicalKeyboardKey.arrowDown) {
              _moveActive(1);
              return KeyEventResult.handled;
            }
            if (key == LogicalKeyboardKey.arrowUp) {
              _moveActive(-1);
              return KeyEventResult.handled;
            }
            if (key == LogicalKeyboardKey.enter ||
                key == LogicalKeyboardKey.numpadEnter ||
                (key == LogicalKeyboardKey.space && _query.isEmpty)) {
              _activateHighlighted();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Live region announcing result count as the user types.
              Semantics(
                liveRegion: true,
                label: filtered.isEmpty
                    ? (widget.emptyText ?? 'Nessun risultato')
                    : '${filtered.length} risultati',
                child: const SizedBox.shrink(),
              ),
              Padding(
                padding: EdgeInsets.all(spacing.s2),
                child: SizedBox(
                  height: GenaiSize.sm.height - spacing.s2,
                  child: TextField(
                    autofocus: true,
                    controller: _searchCtrl,
                    style: ty.bodyMd.copyWith(color: colors.textPrimary),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: widget.hintText ?? 'Cerca...',
                      hintStyle:
                          ty.bodyMd.copyWith(color: colors.textSecondary),
                      prefixIcon: Icon(
                        LucideIcons.search,
                        size: GenaiSize.xs.iconSize,
                        color: colors.textSecondary,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: spacing.s1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(radius.sm),
                        borderSide: BorderSide(color: colors.borderDefault),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(radius.sm),
                        borderSide: BorderSide(color: colors.borderDefault),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(radius.sm),
                        borderSide: BorderSide(
                          color: colors.borderFocus,
                          width: sizing.focusOutlineWidth,
                        ),
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
              ),
              Flexible(
                child: filtered.isEmpty
                    ? _buildEmpty(menuCtx)
                    : Semantics(
                        explicitChildNodes: true,
                        container: true,
                        label: 'Risultati',
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(vertical: spacing.s1),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) =>
                              _buildOption(menuCtx, filtered[i], i),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext menuCtx) {
    final colors = menuCtx.colors;
    final ty = menuCtx.typography;
    final spacing = menuCtx.spacing;
    return Padding(
      padding: EdgeInsets.all(spacing.s4),
      child: Center(
        child: Text(
          widget.emptyText ?? 'Nessun risultato',
          style: ty.bodySm.copyWith(color: colors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext menuCtx, GenaiSelectOption<T> o, int index) {
    final colors = menuCtx.colors;
    final ty = menuCtx.typography;
    final spacing = menuCtx.spacing;
    final sizing = menuCtx.sizing;
    final selected =
        widget.isMultiple ? _values.contains(o.value) : widget.value == o.value;
    final highlighted = index == _activeIndex;

    final bg = selected
        ? colors.colorPrimarySubtle
        : (highlighted ? colors.surfaceHover : null);

    return Semantics(
      button: true,
      enabled: !o.isDisabled,
      selected: selected,
      inMutuallyExclusiveGroup: !widget.isMultiple,
      label: o.label,
      hint: o.description,
      child: InkWell(
        onTap: o.isDisabled
            ? null
            : () => widget.isMultiple
                ? _toggleMulti(o.value)
                : _selectSingle(o.value),
        onHover: (h) {
          if (h && !o.isDisabled) {
            setState(() => _activeIndex = index);
            _overlay?.markNeedsBuild();
          }
        },
        child: Container(
          constraints: BoxConstraints(minHeight: sizing.minTouchTarget),
          padding: EdgeInsets.symmetric(
            horizontal: spacing.s3,
            vertical: spacing.s2,
          ),
          decoration: BoxDecoration(
            color: bg,
            border: highlighted && !selected
                ? Border.all(
                    color: colors.borderFocus,
                    width: sizing.focusOutlineWidth,
                  )
                : null,
          ),
          child: Row(
            children: [
              if (o.icon != null) ...[
                Icon(
                  o.icon,
                  size: GenaiSize.xs.iconSize,
                  color: colors.textSecondary,
                ),
                SizedBox(width: spacing.s2),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      o.label,
                      style: ty.bodyMd.copyWith(
                        color: o.isDisabled
                            ? colors.textDisabled
                            : colors.textPrimary,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    if (o.description != null)
                      Text(
                        o.description!,
                        style: ty.caption.copyWith(color: colors.textSecondary),
                      ),
                  ],
                ),
              ),
              if (selected)
                Icon(
                  LucideIcons.check,
                  size: GenaiSize.xs.iconSize,
                  color: colors.colorPrimary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _overlay?.remove();
    _triggerFocus.dispose();
    _overlayFocus.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final motion = context.motion;
    final isCompact = context.isCompact;
    final h = widget.size.resolveHeight(isCompact: isCompact);

    // Resting border kept thin so layout never reflows on focus / open.
    // Focus ring rendered as a non-layout overlay below.
    final borderColor = colors.borderDefault;
    final borderWidth = widget.size.borderWidth;

    final hasValue =
        widget.isMultiple ? _values.isNotEmpty : widget.value != null;

    String? singleLabel;
    if (!widget.isMultiple && widget.value != null) {
      singleLabel = widget.options
          .where((o) => o.value == widget.value)
          .map((o) => o.label)
          .firstOrNull;
    }

    Widget content;
    if (widget.isMultiple && hasValue) {
      content = Padding(
        padding: EdgeInsets.symmetric(vertical: spacing.s1),
        child: Wrap(
          spacing: spacing.s1,
          runSpacing: spacing.s1,
          children: [
            for (final v in _values)
              GenaiChip.removable(
                label: widget.options
                        .where((o) => o.value == v)
                        .map((o) => o.label)
                        .firstOrNull ??
                    '$v',
                onRemove: () => _toggleMulti(v),
              ),
          ],
        ),
      );
    } else {
      content = Text(
        hasValue
            ? (singleLabel ?? '${widget.value}')
            : (widget.hintText ?? 'Seleziona...'),
        style: ty.bodyMd.copyWith(
          color: hasValue ? colors.textPrimary : colors.textSecondary,
          fontSize: widget.size.fontSize,
        ),
        overflow: TextOverflow.ellipsis,
      );
    }

    final children = <Widget>[];
    if (widget.label != null) {
      children.add(
        Padding(
          padding: EdgeInsets.only(bottom: spacing.s1 + 2),
          child: Text(
            widget.label!,
            style: ty.label.copyWith(color: colors.textPrimary),
          ),
        ),
      );
    }

    final minTouch = sizing.minTouchTarget;
    final triggerMinHeight = h < minTouch ? minTouch : h;

    children.add(
      CompositedTransformTarget(
        link: _link,
        child: Focus(
          focusNode: _triggerFocus,
          canRequestFocus: !widget.isDisabled,
          onFocusChange: (f) {
            if (_focused != f) setState(() => _focused = f);
          },
          onKeyEvent: (node, event) {
            if (widget.isDisabled) return KeyEventResult.ignored;
            if (event is! KeyDownEvent) return KeyEventResult.ignored;
            final key = event.logicalKey;
            if (key == LogicalKeyboardKey.enter ||
                key == LogicalKeyboardKey.numpadEnter ||
                key == LogicalKeyboardKey.space ||
                key == LogicalKeyboardKey.arrowDown) {
              _toggle();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
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
                    key: _fieldKey,
                    constraints: BoxConstraints(minHeight: triggerMinHeight),
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.size.paddingH,
                      vertical: widget.isMultiple && hasValue
                          ? spacing.s1
                          : widget.size.paddingV,
                    ),
                    decoration: BoxDecoration(
                      color: widget.isDisabled
                          ? colors.surfaceHover
                          : colors.surfaceInput,
                      borderRadius:
                          BorderRadius.circular(widget.size.borderRadius),
                      border:
                          Border.all(color: borderColor, width: borderWidth),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: content),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: spacing.s1),
                          child: Icon(
                            LucideIcons.search,
                            size: GenaiSize.xs.iconSize,
                            color: colors.textSecondary,
                          ),
                        ),
                        AnimatedRotation(
                          turns: _open ? 0.5 : 0,
                          duration: motion.dropdownOpen.duration,
                          curve: motion.dropdownOpen.curve,
                          child: Icon(
                            LucideIcons.chevronDown,
                            size: GenaiSize.xs.iconSize,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if ((_focused || _open) && !widget.isDisabled)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                widget.size.borderRadius),
                            border: Border.all(
                              color: colors.borderFocus,
                              width: sizing.focusOutlineWidth,
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
    );

    // Flutter has no dedicated `combobox` ARIA role; we combine
    // `button + expanded + explicitChildNodes` and a hint that names the
    // popup so screen readers announce state transitions correctly.
    return Semantics(
      button: true,
      expanded: _open,
      enabled: !widget.isDisabled,
      label: widget.semanticLabel ?? widget.label,
      hint: widget.hintText == null
          ? 'Combobox. Premi Invio per aprire.'
          : '${widget.hintText}. Combobox, premi Invio per aprire.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class _ComboboxMenu<T> extends StatelessWidget {
  final LayerLink link;
  final double width;
  final VoidCallback onClose;
  final WidgetBuilder builder;

  const _ComboboxMenu({
    required this.link,
    required this.width,
    required this.onClose,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final motion = context.motion;
    final reduced = GenaiResponsive.reducedMotion(context);
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onClose,
          ),
        ),
        CompositedTransformFollower(
          link: link,
          showWhenUnlinked: false,
          offset: Offset(0, spacing.s1),
          targetAnchor: Alignment.bottomLeft,
          child: SizedBox(
            width: width,
            child: TweenAnimationBuilder<double>(
              duration: reduced ? Duration.zero : motion.dropdownOpen.duration,
              curve: motion.dropdownOpen.curve,
              tween: Tween(begin: 0, end: 1),
              builder: (_, t, c) => Opacity(opacity: t, child: c),
              child: builder(context),
            ),
          ),
        ),
      ],
    );
  }
}
