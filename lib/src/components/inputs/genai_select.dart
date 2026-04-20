import 'dart:async';

import 'package:flutter/material.dart';

import '../../foundations/animations.dart';
import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';
import '../feedback/genai_spinner.dart';
import '../indicators/genai_chip.dart';

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

typedef GenaiAsyncOptionsLoader<T> = Future<List<GenaiSelectOption<T>>> Function(String query);

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

  bool get _hasError => widget.errorText != null && widget.errorText!.isNotEmpty;

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
    _debounce = Timer(GenaiDurations.searchDebounce, () async {
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
    final filtered = _filteredOptions;

    return Material(
      color: colors.surfaceCard,
      elevation: 0,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.borderDefault),
          boxShadow: menuCtx.elevation.shadow(3),
        ),
        constraints: const BoxConstraints(maxHeight: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isSearchable || widget.asyncLoader != null)
              Padding(
                padding: const EdgeInsets.all(8),
                child: SizedBox(
                  height: 32,
                  child: TextField(
                    autofocus: true,
                    style: ty.bodyMd.copyWith(color: colors.textPrimary),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Cerca...',
                      hintStyle: ty.bodyMd.copyWith(color: colors.textSecondary),
                      prefixIcon: Icon(LucideIcons.search, size: 16, color: colors.textSecondary),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: colors.borderDefault),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: colors.borderDefault),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: colors.borderFocus, width: 2),
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
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: GenaiSpinner()),
                    )
                  : (filtered.isEmpty
                      ? _buildEmpty(menuCtx)
                      : ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) => _buildOption(menuCtx, filtered[i]),
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
    if (widget.isCreatable && _query.isNotEmpty) {
      return InkWell(
        onTap: () {
          widget.onCreate?.call(_query);
          _close();
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(LucideIcons.plus, size: 16, color: colors.colorPrimary),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Crea "$_query"', style: ty.bodyMd.copyWith(color: colors.colorPrimary)),
              ),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text('Nessun risultato', style: ty.bodySm.copyWith(color: colors.textSecondary)),
      ),
    );
  }

  Widget _buildOption(BuildContext menuCtx, GenaiSelectOption<T> o) {
    final colors = menuCtx.colors;
    final ty = menuCtx.typography;
    final selected = widget.isMulti ? widget.values.contains(o.value) : widget.value == o.value;

    return InkWell(
      onTap: o.isDisabled ? null : () => widget.isMulti ? _toggleMulti(o.value) : _selectSingle(o.value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: selected ? colors.colorPrimarySubtle : null,
        child: Row(
          children: [
            if (widget.isMulti) ...[
              Icon(
                selected ? LucideIcons.squareCheck : LucideIcons.square,
                size: 16,
                color: selected ? colors.colorPrimary : colors.textSecondary,
              ),
              const SizedBox(width: 8),
            ],
            if (o.icon != null) ...[
              Icon(o.icon, size: 16, color: colors.textSecondary),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(o.label,
                      style: ty.bodyMd.copyWith(
                        color: o.isDisabled ? colors.textDisabled : colors.textPrimary,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      )),
                  if (o.description != null) Text(o.description!, style: ty.caption.copyWith(color: colors.textSecondary)),
                ],
              ),
            ),
            if (selected && !widget.isMulti) Icon(LucideIcons.check, size: 16, color: colors.colorPrimary),
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
    final isCompact = context.isCompact;
    final h = widget.size.resolveHeight(isCompact: isCompact);

    final borderColor = _hasError ? colors.borderError : (_open || _focused ? colors.borderFocus : colors.borderDefault);
    final borderWidth = _open || _focused || _hasError ? 2.0 : 1.0;

    final hasValue = widget.isMulti ? widget.values.isNotEmpty : widget.value != null;

    String? singleLabel;
    if (!widget.isMulti && widget.value != null) {
      final all = widget.asyncLoader != null ? _asyncResults : widget.options;
      singleLabel = all.where((o) => o.value == widget.value).map((o) => o.label).firstOrNull;
    }

    Widget content;
    if (widget.isMulti && hasValue) {
      content = Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            for (final v in widget.values)
              GenaiChip.removable(
                label: widget.options.where((o) => o.value == v).map((o) => o.label).firstOrNull ?? '$v',
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
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(widget.label!, style: ty.label.copyWith(color: colors.textPrimary)),
      ));
    }

    children.add(CompositedTransformTarget(
      link: _link,
      child: Focus(
        onFocusChange: (f) => setState(() => _focused = f),
        child: MouseRegion(
          cursor: widget.isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggle,
            child: AnimatedContainer(
              key: _fieldKey,
              duration: GenaiDurations.hover,
              constraints: BoxConstraints(minHeight: h),
              padding: EdgeInsets.symmetric(
                horizontal: widget.size.paddingH,
                vertical: widget.isMulti && hasValue ? 4 : widget.size.paddingV,
              ),
              decoration: BoxDecoration(
                color: widget.isDisabled ? colors.surfaceHover : colors.surfaceInput,
                borderRadius: BorderRadius.circular(widget.size.borderRadius),
                border: Border.all(color: borderColor, width: borderWidth),
              ),
              child: Row(
                children: [
                  Expanded(child: content),
                  if (widget.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: GenaiSpinner(size: GenaiSize.xs),
                    ),
                  if (widget.clearable && hasValue)
                    GestureDetector(
                      onTap: _clear,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(LucideIcons.x, size: 16, color: colors.textSecondary),
                      ),
                    ),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: GenaiDurations.dropdownOpen,
                    child: Icon(LucideIcons.chevronDown, size: 16, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ));

    if (widget.helperText != null || _hasError) {
      children.add(Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          widget.errorText ?? widget.helperText!,
          style: ty.caption.copyWith(
            color: _hasError ? colors.textError : colors.textSecondary,
          ),
        ),
      ));
    }

    return Semantics(
      button: true,
      label: widget.semanticLabel ?? widget.label,
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
