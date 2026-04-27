import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

/// Group item descriptor for [CLInputGroup].
///
/// `value` is the unique key of the option, `label` is the displayed text.
class CLInputGroupItem<T> {
  final T value;
  final String label;
  final IconData? icon;

  const CLInputGroupItem({required this.value, required this.label, this.icon});
}

/// "Input group" / "segmented input" — a single visual chrome containing
/// a leading dropdown and a trailing text field, sharing border, radius,
/// height and focus state. Common pattern (Bootstrap input-group, Tailwind
/// "addon", etc.) used for typed inputs that require a category selector.
///
/// Example:
/// ```dart
/// CLInputGroup<ContactableType>(
///   selected: ContactableType.email,
///   items: [
///     CLInputGroupItem(value: ContactableType.email, label: 'Email'),
///     CLInputGroupItem(value: ContactableType.phone, label: 'Telefono'),
///   ],
///   onChanged: (v) => setState(() => type = v!),
///   controller: textCtrl,
///   hintText: 'email@esempio.it',
/// )
/// ```
class CLInputGroup<T> extends StatefulWidget {
  /// Currently selected dropdown value.
  final T? selected;

  /// Available dropdown options.
  final List<CLInputGroupItem<T>> items;

  /// Invoked when the dropdown selection changes. If `null` the dropdown
  /// is rendered read-only.
  final ValueChanged<T?>? onChanged;

  /// Text editing controller for the input segment.
  final TextEditingController controller;

  /// Optional focus node for the input segment.
  final FocusNode? focusNode;

  /// Hint text shown when the input is empty.
  final String? hintText;

  /// Optional input keyboard type.
  final TextInputType? keyboardType;

  /// Whether the input segment is enabled. Both segments respect this flag.
  final bool enabled;

  /// Optional fixed width for the dropdown segment. If null (default), the
  /// segment auto-sizes to the widest item label.
  final double? dropdownWidth;

  /// Whether to show an error border (theme.danger).
  final bool hasError;

  /// Invoked on text changes.
  final ValueChanged<String>? onTextChanged;

  /// Invoked when text submitted (Enter key).
  final ValueChanged<String>? onSubmitted;

  const CLInputGroup({
    super.key,
    required this.selected,
    required this.items,
    required this.controller,
    this.onChanged,
    this.focusNode,
    this.hintText,
    this.keyboardType,
    this.enabled = true,
    this.dropdownWidth,
    this.hasError = false,
    this.onTextChanged,
    this.onSubmitted,
  });

  @override
  State<CLInputGroup<T>> createState() => _CLInputGroupState<T>();
}

class _CLInputGroupState<T> extends State<CLInputGroup<T>> {
  late FocusNode _internalFocus;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _internalFocus = widget.focusNode ?? FocusNode();
    _internalFocus.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant CLInputGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      _internalFocus.removeListener(_onFocusChange);
      if (oldWidget.focusNode == null) _internalFocus.dispose();
      _internalFocus = widget.focusNode ?? FocusNode();
      _internalFocus.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    _internalFocus.removeListener(_onFocusChange);
    if (widget.focusNode == null) _internalFocus.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!mounted) return;
    final f = _internalFocus.hasFocus;
    if (f != _isFocused) setState(() => _isFocused = f);
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final Color borderColor =
        widget.hasError ? theme.danger : (_isFocused ? theme.ring : (widget.enabled ? theme.cardBorder : theme.cardBorder.withValues(alpha: 0.5)));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      height: CLSizes.inputHeight,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: widget.enabled ? theme.secondaryBackground : theme.secondaryBackground.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(CLSizes.radiusControl),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: _isFocused && !widget.hasError ? [BoxShadow(color: theme.ring, spreadRadius: 1, blurRadius: 0)] : null,
      ),
      child: Row(
        children: [
          // ── Dropdown segment (auto-sized) ────────────────────────
          widget.dropdownWidth != null
              ? SizedBox(
                  width: widget.dropdownWidth,
                  child: _buildDropdown(theme),
                )
              : IntrinsicWidth(child: _buildDropdown(theme)),
          // ── Vertical divider ────────────────────────────────────
          Container(width: 1, color: theme.cardBorder),
          // ── Text input segment ──────────────────────────────────
          Expanded(child: _buildTextField(theme)),
        ],
      ),
    );
  }

  Widget _buildDropdown(CLTheme theme) {
    final selectedItem = widget.items.firstWhere(
      (e) => e.value == widget.selected,
      orElse: () => widget.items.first,
    );
    final isInteractive = widget.onChanged != null && widget.enabled;
    return _DropdownSegment<T>(
      items: widget.items,
      selected: selectedItem,
      isInteractive: isInteractive,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
    );
  }

  Widget _buildTextField(CLTheme theme) {
    return Theme(
      data: Theme.of(context).copyWith(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _internalFocus,
        enabled: widget.enabled,
        keyboardType: widget.keyboardType,
        textAlignVertical: TextAlignVertical.center,
        cursorColor: theme.primary,
        cursorWidth: 1.5,
        style: theme.bodyText.copyWith(color: theme.primaryText),
        onChanged: widget.onTextChanged,
        onSubmitted: widget.onSubmitted,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          hintText: widget.hintText,
          hintStyle: theme.bodyText.copyWith(color: theme.mutedForeground),
        ),
      ),
    );
  }
}

/// Borderless dropdown segment used inside [CLInputGroup].
///
/// Renders the selected label + chevron. On tap, opens a custom overlay
/// popup anchored to the segment via [LayerLink]/[CompositedTransformFollower].
/// This mechanism — same one used by Flutter's [DropdownButton] — guarantees
/// pixel-perfect anchoring regardless of parent transforms or clip paths
/// (the outer [CLInputGroup] uses [ClipRRect] + rounded corners which broke
/// [PopupMenuButton]'s positioning math).
class _DropdownSegment<T> extends StatefulWidget {
  final List<CLInputGroupItem<T>> items;
  final CLInputGroupItem<T> selected;
  final bool isInteractive;
  final bool enabled;
  final ValueChanged<T?>? onChanged;

  const _DropdownSegment({
    required this.items,
    required this.selected,
    required this.isInteractive,
    required this.enabled,
    required this.onChanged,
  });

  @override
  State<_DropdownSegment<T>> createState() => _DropdownSegmentState<T>();
}

class _DropdownSegmentState<T> extends State<_DropdownSegment<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlay;
  bool _hovered = false;

  bool get _isOpen => _overlay != null;

  void _toggle() {
    if (_isOpen) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    final theme = CLTheme.of(context);
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final size = box.size;

    _overlay = OverlayEntry(
      builder: (overlayContext) {
        return Positioned(
          width: max(size.width, 160),
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomLeft,
            followerAnchor: Alignment.topLeft,
            offset: const Offset(0, 1),
            child: TapRegion(
              onTapOutside: (_) => _close(),
              child: Material(
                color: theme.secondaryBackground,
                borderRadius: BorderRadius.circular(CLSizes.radiusSurface),
                elevation: 4,
                shadowColor: Colors.black.withValues(alpha: 0.10),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(CLSizes.radiusSurface),
                    border: Border.all(color: theme.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: widget.items.map((it) {
                      final isSelected = it.value == widget.selected.value;
                      return _MenuItem<T>(
                        item: it,
                        isSelected: isSelected,
                        onTap: () {
                          _close();
                          if (!isSelected) widget.onChanged?.call(it.value);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlay!);
    setState(() {});
  }

  void _close() {
    _overlay?.remove();
    _overlay = null;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _overlay?.remove();
    _overlay = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final fg = widget.enabled ? theme.primaryText : theme.mutedForeground;

    final Widget label = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.selected.icon != null) ...[
          Icon(widget.selected.icon, size: 14, color: theme.secondaryText),
          const SizedBox(width: 8),
        ],
        Text(widget.selected.label, style: theme.bodyText.copyWith(color: fg)),
        const SizedBox(width: 6),
        Icon(
          LucideIcons.chevronDown,
          size: 14,
          color: widget.isInteractive ? theme.secondaryText : theme.mutedForeground,
        ),
      ],
    );

    final bool tinted = widget.isInteractive && (_hovered || _isOpen);

    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        cursor: widget.isInteractive ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: widget.isInteractive ? (_) => setState(() => _hovered = true) : null,
        onExit: widget.isInteractive ? (_) => setState(() => _hovered = false) : null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.isInteractive ? _toggle : null,
          child: Container(
            decoration: BoxDecoration(
              color: tinted ? theme.muted : Colors.transparent,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(CLSizes.radiusControl),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            child: label,
          ),
        ),
      ),
    );
  }
}

/// Single row inside the dropdown overlay popup.
///
/// Renders selected/hover tints aligned with the design system:
/// - hovered (not selected): `theme.muted`
/// - selected: `theme.primary` at 10% alpha + primary-tinted label/icon
/// - trailing check mark when selected
class _MenuItem<T> extends StatefulWidget {
  final CLInputGroupItem<T> item;
  final bool isSelected;
  final VoidCallback onTap;

  const _MenuItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_MenuItem<T>> createState() => _MenuItemState<T>();
}

class _MenuItemState<T> extends State<_MenuItem<T>> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);

    final Color bg = widget.isSelected ? theme.primary.withValues(alpha: 0.10) : (_hovered ? theme.muted : Colors.transparent);
    final Color fg = widget.isSelected ? theme.primary : theme.primaryText;
    final FontWeight weight = widget.isSelected ? FontWeight.w600 : FontWeight.w400;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          height: 36,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          color: bg,
          child: Row(
            children: [
              if (widget.item.icon != null) ...[
                Icon(widget.item.icon, size: 14, color: fg),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  widget.item.label,
                  style: theme.bodyText.copyWith(color: fg, fontWeight: weight),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.isSelected) ...[
                const SizedBox(width: 8),
                Icon(LucideIcons.check, size: 14, color: theme.primary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
