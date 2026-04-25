import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';
import 'genai_button.dart';

/// Single entry in a [GenaiToggleButtonGroup] / [GenaiMultiToggleButtonGroup].
///
/// Provide at least one of [label] or [icon]. [value] identifies the option.
class GenaiToggleOption<T> {
  /// Unique value bound to this option.
  final T value;

  /// Optional visible label.
  final String? label;

  /// Optional leading icon.
  final IconData? icon;

  /// Tooltip shown on hover.
  final String? tooltip;

  /// When `true`, this option cannot be selected regardless of group state.
  final bool isDisabled;

  const GenaiToggleOption({
    required this.value,
    this.label,
    this.icon,
    this.tooltip,
    this.isDisabled = false,
  });
}

/// Single-select segmented group — v3 design system (Forma LMS).
///
/// Adjacent segments share borders so the group reads as a single control.
/// Visually mirrors the `.seg` segmented control in Dashboard v3.html —
/// neutral-soft container, panel-white selected tile.
class GenaiToggleButtonGroup<T> extends StatelessWidget {
  /// Currently selected value. `null` means no selection.
  final T? value;

  /// Options in rendering order.
  final List<GenaiToggleOption<T>> options;

  /// Called with the new selection. `null` disables the group.
  final ValueChanged<T?>? onChanged;

  /// Visual size shared by all segments.
  final GenaiButtonSize size;

  /// When `true`, disables every segment.
  final bool isDisabled;

  /// When `true`, segments expand to fill available width equally.
  final bool isFullWidth;

  const GenaiToggleButtonGroup({
    super.key,
    required this.value,
    required this.options,
    this.onChanged,
    this.size = GenaiButtonSize.sm,
    this.isDisabled = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return _GenaiSegmentedGroup<T>(
      values: value == null ? const [] : [value as Object],
      options: options,
      isMulti: false,
      onSingleChanged: onChanged,
      size: size,
      isDisabled: isDisabled,
      isFullWidth: isFullWidth,
    );
  }
}

/// Multi-select segmented group — v3 design system (Forma LMS).
class GenaiMultiToggleButtonGroup<T> extends StatelessWidget {
  /// Currently selected values. Order is preserved in callbacks.
  final List<T> values;

  /// Options in rendering order.
  final List<GenaiToggleOption<T>> options;

  /// Called with the new selection. `null` disables the group.
  final ValueChanged<List<T>>? onChanged;

  /// Visual size shared by all segments.
  final GenaiButtonSize size;

  /// When `true`, disables every segment.
  final bool isDisabled;

  /// When `true`, segments expand to fill available width equally.
  final bool isFullWidth;

  const GenaiMultiToggleButtonGroup({
    super.key,
    required this.values,
    required this.options,
    this.onChanged,
    this.size = GenaiButtonSize.sm,
    this.isDisabled = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return _GenaiSegmentedGroup<T>(
      values: values.cast<Object>(),
      options: options,
      isMulti: true,
      onMultiChanged: onChanged,
      size: size,
      isDisabled: isDisabled,
      isFullWidth: isFullWidth,
    );
  }
}

class _GenaiSegmentedGroup<T> extends StatelessWidget {
  final List<Object> values;
  final List<GenaiToggleOption<T>> options;
  final bool isMulti;
  final ValueChanged<T?>? onSingleChanged;
  final ValueChanged<List<T>>? onMultiChanged;
  final GenaiButtonSize size;
  final bool isDisabled;
  final bool isFullWidth;

  const _GenaiSegmentedGroup({
    required this.values,
    required this.options,
    required this.isMulti,
    this.onSingleChanged,
    this.onMultiChanged,
    required this.size,
    required this.isDisabled,
    required this.isFullWidth,
  });

  void _toggle(T value) {
    if (isMulti) {
      final next = values.cast<T>().toList();
      if (next.contains(value)) {
        next.remove(value);
      } else {
        next.add(value);
      }
      onMultiChanged?.call(next);
    } else {
      onSingleChanged?.call(values.contains(value) ? null : value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius.md;
    final spec = GenaiButtonSpec.resolve(context, size);
    final spacing = context.spacing;

    final children = <Widget>[];
    for (var i = 0; i < options.length; i++) {
      final opt = options[i];
      final selected = values.contains(opt.value as Object);
      final disabled = isDisabled || opt.isDisabled;

      Widget tile = _SegmentedTile(
        height: spec.height,
        spec: spec,
        label: opt.label,
        icon: opt.icon,
        tooltip: opt.tooltip,
        selected: selected,
        disabled: disabled,
        onTap: disabled ? null : () => _toggle(opt.value),
      );

      if (isFullWidth) tile = Expanded(child: tile);
      children.add(tile);
    }

    // v3 segmented control: a neutral-soft container pad with panel-white
    // tiles for the selected option (see `.seg` + `.seg button[data-on]`).
    final group = Container(
      padding: EdgeInsets.all(spacing.s2),
      decoration: BoxDecoration(
        color: colors.surfaceHover,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: children,
      ),
    );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Opacity(opacity: isDisabled ? 0.5 : 1.0, child: group),
    );
  }
}

class _SegmentedTile extends StatefulWidget {
  final double height;
  final GenaiButtonSpec spec;
  final String? label;
  final IconData? icon;
  final String? tooltip;
  final bool selected;
  final bool disabled;
  final VoidCallback? onTap;

  const _SegmentedTile({
    required this.height,
    required this.spec,
    required this.label,
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  @override
  State<_SegmentedTile> createState() => _SegmentedTileState();
}

class _SegmentedTileState extends State<_SegmentedTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sizing = context.sizing;
    final radius = context.radius.sm;
    final elevation = context.elevation;

    final bg = widget.selected
        ? colors.surfaceCard
        : (_hovered && !widget.disabled
            ? colors.surfaceHover
            : Colors.transparent);
    final fg = widget.selected ? colors.textPrimary : colors.textSecondary;

    final children = <Widget>[];
    if (widget.icon != null) {
      children.add(Icon(widget.icon, size: widget.spec.iconSize, color: fg));
    }
    if (widget.label != null) {
      if (children.isNotEmpty) {
        children.add(SizedBox(width: widget.spec.gap));
      }
      children.add(
        Text(
          widget.label!,
          style: widget.spec.labelStyleFor(context).copyWith(color: fg),
        ),
      );
    }

    Widget tile = Container(
      height:
          widget.height < sizing.minTouchTarget ? widget.height : widget.height,
      padding: EdgeInsets.symmetric(horizontal: widget.spec.paddingH),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        boxShadow:
            widget.selected ? elevation.shadowForLayer(1) : const <BoxShadow>[],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );

    Widget result = MouseRegion(
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
        child: tile,
      ),
    );

    if (widget.tooltip != null) {
      result = Tooltip(message: widget.tooltip!, child: result);
    }

    return Semantics(
      button: true,
      toggled: widget.selected,
      enabled: !widget.disabled,
      label: widget.label,
      child: result,
    );
  }
}
