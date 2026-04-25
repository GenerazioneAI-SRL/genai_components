import 'dart:async';

import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';
import '../feedback/genai_spinner.dart';
import '../indicators/genai_chip.dart';

/// Single option inside a [GenaiSelect].
///
/// [group] is an optional header label used to visually cluster related
/// options inside the dropdown.
class GenaiSelectOption<T> {
  final T value;
  final String label;
  final String? description;
  final IconData? icon;
  final bool isDisabled;
  final String? group;

  const GenaiSelectOption({
    required this.value,
    required this.label,
    this.description,
    this.icon,
    this.isDisabled = false,
    this.group,
  });
}

/// Signature of the async loader passed to [GenaiSelect.async] — receives the
/// current search query and returns matching options.
typedef GenaiAsyncOptionsLoader<T> = Future<List<GenaiSelectOption<T>>>
    Function(String query);

/// Dropdown select (§6.1.2).
///
/// Modes:
/// - default ([GenaiSelect.new]) — single value
/// - multi ([GenaiSelect.multi]) — multiple values rendered as chips
/// - searchable ([GenaiSelect.searchable]) — text filter inside menu
/// - creatable ([GenaiSelect.creatable]) — allows creating new option
/// - async ([GenaiSelect.async]) — loads options via callback
class GenaiSelect<T> extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;

  final List<GenaiSelectOption<T>> options;
  final T? value;
  final List<T> values;
  final ValueChanged<T?>? onChanged;
  final ValueChanged<List<T>>? onMultiChanged;

  final bool isMulti;
  final bool isSearchable;
  final bool isCreatable;
  final ValueChanged<String>? onCreate;

  final GenaiAsyncOptionsLoader<T>? asyncLoader;

  final bool isDisabled;
  final bool isLoading;
  final bool clearable;
  final GenaiSize size;
  final String? semanticLabel;

  const GenaiSelect({
    super.key,
    this.label,
    this.hint = 'Seleziona...',
    this.helperText,
    this.errorText,
    required this.options,
    this.value,
    this.onChanged,
    this.isDisabled = false,
    this.isLoading = false,
    this.clearable = false,
    this.size = GenaiSize.md,
    this.semanticLabel,
  })  : isMulti = false,
        isSearchable = false,
        isCreatable = false,
        onCreate = null,
        asyncLoader = null,
        values = const [],
        onMultiChanged = null;

  const GenaiSelect.multi({
    super.key,
    this.label,
    this.hint = 'Seleziona...',
    this.helperText,
    this.errorText,
    required this.options,
    this.values = const [],
    this.onMultiChanged,
    this.isDisabled = false,
    this.isLoading = false,
    this.clearable = false,
    this.size = GenaiSize.md,
    this.semanticLabel,
  })  : isMulti = true,
        isSearchable = false,
        isCreatable = false,
        onCreate = null,
        asyncLoader = null,
        value = null,
        onChanged = null;

  const GenaiSelect.searchable({
    super.key,
    this.label,
    this.hint = 'Seleziona...',
    this.helperText,
    this.errorText,
    required this.options,
    this.value,
    this.onChanged,
    this.isDisabled = false,
    this.isLoading = false,
    this.clearable = true,
    this.size = GenaiSize.md,
    this.semanticLabel,
  })  : isMulti = false,
        isSearchable = true,
        isCreatable = false,
        onCreate = null,
        asyncLoader = null,
        values = const [],
        onMultiChanged = null;

  const GenaiSelect.creatable({
    super.key,
    this.label,
    this.hint = 'Seleziona o crea...',
    this.helperText,
    this.errorText,
    required this.options,
    this.value,
    this.onChanged,
    this.onCreate,
    this.isDisabled = false,
    this.isLoading = false,
    this.clearable = true,
    this.size = GenaiSize.md,
    this.semanticLabel,
  })  : isMulti = false,
        isSearchable = true,
        isCreatable = true,
        asyncLoader = null,
        values = const [],
        onMultiChanged = null;

  const GenaiSelect.async({
    super.key,
    this.label,
    this.hint = 'Cerca...',
    this.helperText,
    this.errorText,
    required this.asyncLoader,
    this.value,
    this.onChanged,
    this.isDisabled = false,
    this.clearable = true,
    this.size = GenaiSize.md,
    this.semanticLabel,
  })  : options = const [],
        isMulti = false,
        isSearchable = true,
        isCreatable = false,
        isLoading = false,
        onCreate = null,
        values = const [],
        onMultiChanged = null;

  @override
  State<GenaiSelect<T>> createState() => _GenaiSelectState<T>();
}

class _GenaiSelectState<T> extends State<GenaiSelect<T>> {
  final LayerLink _link = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();
  OverlayEntry? _overlay;
  bool _open = false;
  bool _focused = false;

  String _query = '';
  List<GenaiSelectOption<T>> _asyncResults = [];
  bool _asyncLoading = false;
  Timer? _debounce;

  bool get _hasError =>
      widget.errorText != null && widget.errorText!.isNotEmpty;

  void _toggle() {
    if (widget.isDisabled) return;
    _open ? _close() : _openMenu();
  }

  void _openMenu() {
    final overlay = Overlay.of(context);
    final box = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final width = box.size.width;
    _overlay = OverlayEntry(
      builder: (ctx) => _SelectMenu(
        link: _link,
        width: width,
        onClose: _close,
        builder: (menuCtx) => _buildMenuBody(menuCtx),
      ),
    );
    overlay.insert(_overlay!);
    setState(() => _open = true);
    if (widget.asyncLoader != null) _runAsync('');
  }

  void _close() {
    _overlay?.remove();
    _overlay = null;
    if (mounted) setState(() => _open = false);
    _query = '';
  }

  void _runAsync(String q) {
    _debounce?.cancel();
    _debounce = Timer(context.motion.searchDebounce, () async {
      if (!mounted) return;
      setState(() => _asyncLoading = true);
      try {
        final results = await widget.asyncLoader!(q);
        if (!mounted) return;
        setState(() {
          _asyncResults = results;
          _asyncLoading = false;
        });
        _overlay?.markNeedsBuild();
      } catch (_) {
        if (!mounted) return;
        setState(() => _asyncLoading = false);
      }
    });
  }

  List<GenaiSelectOption<T>> get _filteredOptions {
    final source = widget.asyncLoader != null ? _asyncResults : widget.options;
    if (_query.isEmpty) return source;
    final q = _query.toLowerCase();
    return source.where((o) => o.label.toLowerCase().contains(q)).toList();
  }

  void _selectSingle(T v) {
    widget.onChanged?.call(v);
    _close();
  }

  void _toggleMulti(T v) {
    final current = List<T>.from(widget.values);
    if (current.contains(v)) {
      current.remove(v);
    } else {
      current.add(v);
    }
    widget.onMultiChanged?.call(current);
    _overlay?.markNeedsBuild();
  }

  void _clear() {
    if (widget.isMulti) {
      widget.onMultiChanged?.call(const []);
    } else {
      widget.onChanged?.call(null);
    }
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isSearchable || widget.asyncLoader != null)
              Padding(
                padding: EdgeInsets.all(spacing.s2),
                child: SizedBox(
                  height: GenaiSize.sm.height - spacing.s2,
                  child: TextField(
                    autofocus: true,
                    style: ty.bodyMd.copyWith(color: colors.textPrimary),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Cerca...',
                      hintStyle:
                          ty.bodyMd.copyWith(color: colors.textSecondary),
                      prefixIcon: Icon(LucideIcons.search,
                          size: GenaiSize.xs.iconSize,
                          color: colors.textSecondary),
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
                            width: sizing.focusOutlineWidth),
                      ),
                    ),
                    onChanged: (v) {
                      _query = v;
                      if (widget.asyncLoader != null) {
                        _runAsync(v);
                      } else {
                        _overlay?.markNeedsBuild();
                      }
                    },
                  ),
                ),
              ),
            Flexible(
              child: _asyncLoading
                  ? Padding(
                      padding: EdgeInsets.all(spacing.s4),
                      child: const Center(child: GenaiSpinner()),
                    )
                  : (filtered.isEmpty
                      ? _buildEmpty(menuCtx)
                      : ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(vertical: spacing.s1),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) =>
                              _buildOption(menuCtx, filtered[i]),
                        )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext menuCtx) {
    final colors = menuCtx.colors;
    final ty = menuCtx.typography;
    final spacing = menuCtx.spacing;
    if (widget.isCreatable && _query.isNotEmpty) {
      return InkWell(
        onTap: () {
          widget.onCreate?.call(_query);
          _close();
        },
        child: Padding(
          padding: EdgeInsets.all(spacing.s3),
          child: Row(
            children: [
              Icon(LucideIcons.plus,
                  size: GenaiSize.xs.iconSize, color: colors.colorPrimary),
              SizedBox(width: spacing.s2),
              Expanded(
                child: Text('Crea "$_query"',
                    style: ty.bodyMd.copyWith(color: colors.colorPrimary)),
              ),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.all(spacing.s4),
      child: Center(
        child: Text('Nessun risultato',
            style: ty.bodySm.copyWith(color: colors.textSecondary)),
      ),
    );
  }

  Widget _buildOption(BuildContext menuCtx, GenaiSelectOption<T> o) {
    final colors = menuCtx.colors;
    final ty = menuCtx.typography;
    final spacing = menuCtx.spacing;
    final selected = widget.isMulti
        ? widget.values.contains(o.value)
        : widget.value == o.value;

    return InkWell(
      onTap: o.isDisabled
          ? null
          : () =>
              widget.isMulti ? _toggleMulti(o.value) : _selectSingle(o.value),
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: spacing.s3, vertical: spacing.s2),
        color: selected ? colors.colorPrimarySubtle : null,
        child: Row(
          children: [
            if (widget.isMulti) ...[
              Icon(
                selected ? LucideIcons.squareCheck : LucideIcons.square,
                size: GenaiSize.xs.iconSize,
                color: selected ? colors.colorPrimary : colors.textSecondary,
              ),
              SizedBox(width: spacing.s2),
            ],
            if (o.icon != null) ...[
              Icon(o.icon,
                  size: GenaiSize.xs.iconSize, color: colors.textSecondary),
              SizedBox(width: spacing.s2),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(o.label,
                      style: ty.bodyMd.copyWith(
                        color: o.isDisabled
                            ? colors.textDisabled
                            : colors.textPrimary,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                      )),
                  if (o.description != null)
                    Text(o.description!,
                        style:
                            ty.caption.copyWith(color: colors.textSecondary)),
                ],
              ),
            ),
            if (selected && !widget.isMulti)
              Icon(LucideIcons.check,
                  size: GenaiSize.xs.iconSize, color: colors.colorPrimary),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _overlay?.remove();
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
    // Focus / error ring rendered as a non-layout overlay below.
    final borderColor =
        _hasError ? colors.borderError : colors.borderDefault;
    final borderWidth = widget.size.borderWidth;

    final hasValue =
        widget.isMulti ? widget.values.isNotEmpty : widget.value != null;

    String? singleLabel;
    if (!widget.isMulti && widget.value != null) {
      final all = widget.asyncLoader != null ? _asyncResults : widget.options;
      singleLabel = all
          .where((o) => o.value == widget.value)
          .map((o) => o.label)
          .firstOrNull;
    }

    Widget content;
    if (widget.isMulti && hasValue) {
      content = Padding(
        padding: EdgeInsets.symmetric(vertical: spacing.s1),
        child: Wrap(
          spacing: spacing.s1,
          runSpacing: spacing.s1,
          children: [
            for (final v in widget.values)
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
        hasValue ? (singleLabel ?? '${widget.value}') : (widget.hint ?? ''),
        style: ty.bodyMd.copyWith(
          color: hasValue ? colors.textPrimary : colors.textSecondary,
          fontSize: widget.size.fontSize,
        ),
        overflow: TextOverflow.ellipsis,
      );
    }

    final children = <Widget>[];
    if (widget.label != null) {
      children.add(Padding(
        padding: EdgeInsets.only(bottom: spacing.s1 + 2),
        child: Text(widget.label!,
            style: ty.label.copyWith(color: colors.textPrimary)),
      ));
    }

    children.add(CompositedTransformTarget(
      link: _link,
      child: Focus(
        onFocusChange: (f) {
          if (_focused != f) setState(() => _focused = f);
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
                  constraints: BoxConstraints(minHeight: h),
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.size.paddingH,
                    vertical: widget.isMulti && hasValue
                        ? spacing.s1
                        : widget.size.paddingV,
                  ),
                  decoration: BoxDecoration(
                    color: widget.isDisabled
                        ? colors.surfaceHover
                        : colors.surfaceInput,
                    borderRadius:
                        BorderRadius.circular(widget.size.borderRadius),
                    border: Border.all(color: borderColor, width: borderWidth),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: content),
                      if (widget.isLoading)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: spacing.s1),
                          child: const GenaiSpinner(size: GenaiSize.xs),
                        ),
                      if (widget.clearable && hasValue)
                        GestureDetector(
                          onTap: _clear,
                          child: Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: spacing.s1),
                            child: Icon(LucideIcons.x,
                                size: GenaiSize.xs.iconSize,
                                color: colors.textSecondary),
                          ),
                        ),
                      AnimatedRotation(
                        turns: _open ? 0.5 : 0,
                        duration: motion.dropdownOpen.duration,
                        curve: motion.dropdownOpen.curve,
                        child: Icon(LucideIcons.chevronDown,
                            size: GenaiSize.xs.iconSize,
                            color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                if ((_focused || _open || _hasError) && !widget.isDisabled)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(widget.size.borderRadius),
                          border: Border.all(
                            color: _hasError
                                ? colors.borderError
                                : colors.borderFocus,
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
    ));

    if (widget.helperText != null || _hasError) {
      children.add(Padding(
        padding: EdgeInsets.only(top: spacing.s1 + 2),
        child: Semantics(
          liveRegion: _hasError,
          child: Text(
            widget.errorText ?? widget.helperText!,
            style: ty.caption.copyWith(
              color: _hasError ? colors.textError : colors.textSecondary,
            ),
          ),
        ),
      ));
    }

    return Semantics(
      button: true,
      expanded: _open,
      label: widget.semanticLabel ?? widget.label,
      hint: widget.hint,
      enabled: !widget.isDisabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class _SelectMenu extends StatelessWidget {
  final LayerLink link;
  final double width;
  final VoidCallback onClose;
  final WidgetBuilder builder;

  const _SelectMenu({
    required this.link,
    required this.width,
    required this.onClose,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
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
          offset: const Offset(0, 4),
          targetAnchor: Alignment.bottomLeft,
          child: SizedBox(width: width, child: builder(context)),
        ),
      ],
    );
  }
}
