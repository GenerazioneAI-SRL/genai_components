import 'package:flutter/material.dart';

import '../../foundations/animations.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';

class GenaiToggleOption<T> {
  final T value;
  final String? label;
  final IconData? icon;
  final String? tooltip;
  final bool isDisabled;

  const GenaiToggleOption({
    required this.value,
    this.label,
    this.icon,
    this.tooltip,
    this.isDisabled = false,
  });
}

/// Single-select segmented button group (§6.2.3).
///
/// Shares borders between adjacent buttons so they read as one element.
class GenaiToggleButtonGroup<T> extends StatelessWidget {
  final T? value;
  final List<GenaiToggleOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final GenaiSize size;
  final bool isDisabled;
  final bool isFullWidth;

  const GenaiToggleButtonGroup({
    super.key,
    required this.value,
    required this.options,
    this.onChanged,
    this.size = GenaiSize.sm,
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

/// Multi-select segmented group.
class GenaiMultiToggleButtonGroup<T> extends StatelessWidget {
  final List<T> values;
  final List<GenaiToggleOption<T>> options;
  final ValueChanged<List<T>>? onChanged;
  final GenaiSize size;
  final bool isDisabled;
  final bool isFullWidth;

  const GenaiMultiToggleButtonGroup({
    super.key,
    required this.values,
    required this.options,
    this.onChanged,
    this.size = GenaiSize.sm,
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
  final GenaiSize size;
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
    final isCompact = context.isCompact;
    final h = size.resolveHeight(isCompact: isCompact);

    final children = <Widget>[];
    for (var i = 0; i < options.length; i++) {
      final opt = options[i];
      final selected = values.contains(opt.value as Object);
      final disabled = isDisabled || opt.isDisabled;

      final borderRadius = BorderRadius.horizontal(
        left: Radius.circular(i == 0 ? size.borderRadius : 0),
        right: Radius.circular(i == options.length - 1 ? size.borderRadius : 0),
      );

      Widget tile = _SegmentedTile(
        height: h,
        size: size,
        label: opt.label,
        icon: opt.icon,
        selected: selected,
        disabled: disabled,
        onTap: disabled ? null : () => _toggle(opt.value),
        borderRadius: borderRadius,
      );

      if (isFullWidth) tile = Expanded(child: tile);
      children.add(tile);
    }

    final group = Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.borderDefault, width: size.borderWidth),
        borderRadius: BorderRadius.circular(size.borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size.borderRadius),
        child: Row(
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: _withDividers(children, colors.borderDefault),
        ),
      ),
    );

    return Opacity(
      opacity: isDisabled ? GenaiInteraction.disabledOpacity : 1.0,
      child: group,
    );
  }

  List<Widget> _withDividers(List<Widget> tiles, Color color) {
    final out = <Widget>[];
    for (var i = 0; i < tiles.length; i++) {
      out.add(tiles[i]);
      if (i < tiles.length - 1) {
        out.add(VerticalDivider(width: 1, thickness: 1, color: color));
      }
    }
    return out;
  }
}

class _SegmentedTile extends StatefulWidget {
  final double height;
  final GenaiSize size;
  final String? label;
  final IconData? icon;
  final bool selected;
  final bool disabled;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;

  const _SegmentedTile({
    required this.height,
    required this.size,
    required this.label,
    required this.icon,
    required this.selected,
    required this.disabled,
    required this.onTap,
    required this.borderRadius,
  });

  @override
  State<_SegmentedTile> createState() => _SegmentedTileState();
}

class _SegmentedTileState extends State<_SegmentedTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;

    final bg = widget.selected ? colors.colorPrimary : (_hovered ? colors.surfaceHover : Colors.transparent);
    final fg = widget.selected ? colors.textOnPrimary : colors.textPrimary;

    final children = <Widget>[];
    if (widget.icon != null) {
      children.add(Icon(widget.icon, size: widget.size.iconSize, color: fg));
    }
    if (widget.label != null) {
      if (children.isNotEmpty) children.add(SizedBox(width: widget.size.gap));
      final base = widget.size == GenaiSize.xs ? ty.labelSm : ty.label;
      children.add(Text(widget.label!, style: base.copyWith(color: fg)));
    }

    return MouseRegion(
      cursor: widget.disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: GenaiDurations.hover,
          height: widget.height,
          padding: EdgeInsets.symmetric(horizontal: widget.size.paddingH),
          color: bg,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          ),
        ),
      ),
    );
  }
}
