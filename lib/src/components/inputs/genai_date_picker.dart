import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '_field_frame.dart';

/// What the picker returns / renders.
enum GenaiDatePickerMode { single, range, month }

/// Date-range tuple used by [GenaiDatePickerMode.range].
@immutable
class GenaiDateRange {
  final DateTime start;
  final DateTime end;
  const GenaiDateRange(this.start, this.end);
}

/// Date picker — v3 Forma LMS (§8 field rules).
///
/// Trigger matches [GenaiTextField] shape (32/36/40 heights, `borderStrong`
/// at rest flipping to `textPrimary` on hover / `borderFocus` on focus).
/// Tapping opens Flutter's native date / date-range dialog. Output types
/// depend on [mode]:
/// * [GenaiDatePickerMode.single] → `DateTime?`
/// * [GenaiDatePickerMode.range]  → `GenaiDateRange?`
/// * [GenaiDatePickerMode.month]  → `DateTime?` (day clamped to 1)
///
/// Use [value] + [onChanged] for single/month, [range] + [onRangeChanged]
/// for range. The unused pair is ignored.
class GenaiDatePicker extends StatefulWidget {
  final GenaiDatePickerMode mode;

  /// Selected single/month date (single / month modes).
  final DateTime? value;

  /// Selected range (range mode).
  final GenaiDateRange? range;

  /// Single/month callback.
  final ValueChanged<DateTime>? onChanged;

  /// Range callback.
  final ValueChanged<GenaiDateRange>? onRangeChanged;

  /// Earliest selectable date. Defaults to `1900-01-01`.
  final DateTime? firstDate;

  /// Latest selectable date. Defaults to `now + 10 years`.
  final DateTime? lastDate;

  /// Field label above the trigger.
  final String? label;

  /// Placeholder when no value is selected.
  final String? hintText;

  /// Helper copy below the trigger.
  final String? helperText;

  /// Error copy; takes precedence over helper.
  final String? errorText;

  /// Appends a red asterisk after [label].
  final bool isRequired;

  /// Muted colours, no interaction.
  final bool isDisabled;

  /// Override for the trigger display formatter.
  final String Function(DateTime value)? formatDate;

  /// Override for the range-trigger display formatter.
  final String Function(GenaiDateRange range)? formatRange;

  /// Screen-reader label override.
  final String? semanticLabel;

  const GenaiDatePicker({
    super.key,
    this.mode = GenaiDatePickerMode.single,
    this.value,
    this.range,
    this.onChanged,
    this.onRangeChanged,
    this.firstDate,
    this.lastDate,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.isRequired = false,
    this.isDisabled = false,
    this.formatDate,
    this.formatRange,
    this.semanticLabel,
  });

  @override
  State<GenaiDatePicker> createState() => _GenaiDatePickerState();
}

class _GenaiDatePickerState extends State<GenaiDatePicker> {
  bool _hovered = false;
  bool _focused = false;

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

  String _defaultFormat(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  String _defaultFormatMonth(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}';

  String _defaultRangeFormat(GenaiDateRange r) =>
      '${_defaultFormat(r.start)} → ${_defaultFormat(r.end)}';

  String? _displayValue() {
    switch (widget.mode) {
      case GenaiDatePickerMode.single:
        if (widget.value == null) return null;
        return (widget.formatDate ?? _defaultFormat)(widget.value!);
      case GenaiDatePickerMode.month:
        if (widget.value == null) return null;
        return (widget.formatDate ?? _defaultFormatMonth)(widget.value!);
      case GenaiDatePickerMode.range:
        if (widget.range == null) return null;
        return (widget.formatRange ?? _defaultRangeFormat)(widget.range!);
    }
  }

  Future<void> _openPicker(BuildContext context) async {
    if (widget.isDisabled) return;
    final now = DateTime.now();
    final first = widget.firstDate ?? DateTime(1900);
    final last = widget.lastDate ?? DateTime(now.year + 10, now.month, now.day);

    if (widget.mode == GenaiDatePickerMode.range) {
      final initial = widget.range == null
          ? null
          : DateTimeRange(start: widget.range!.start, end: widget.range!.end);
      final picked = await showDateRangePicker(
        context: context,
        firstDate: first,
        lastDate: last,
        initialDateRange: initial,
      );
      if (picked != null) {
        widget.onRangeChanged?.call(GenaiDateRange(picked.start, picked.end));
      }
    } else {
      final picked = await showDatePicker(
        context: context,
        firstDate: first,
        lastDate: last,
        initialDate: widget.value ?? now,
        initialDatePickerMode: widget.mode == GenaiDatePickerMode.month
            ? DatePickerMode.year
            : DatePickerMode.day,
      );
      if (picked != null) {
        final v = widget.mode == GenaiDatePickerMode.month
            ? DateTime(picked.year, picked.month, 1)
            : picked;
        widget.onChanged?.call(v);
      }
    }
  }

  bool get _hasError =>
      widget.errorText != null && widget.errorText!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final radius = context.radius;
    final motion = context.motion;

    final display = _displayValue();
    final height = _triggerHeight(sizing.density);

    final borderColor = widget.isDisabled
        ? colors.borderSubtle
        : _hasError
            ? colors.colorDanger
            : _focused
                ? colors.borderFocus
                : (_hovered ? colors.textPrimary : colors.borderStrong);
    final borderWidth = (_focused || _hasError) ? sizing.focusRingWidth : 1.0;

    final trigger = Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: MouseRegion(
        cursor: widget.isDisabled
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _openPicker(context),
          child: AnimatedContainer(
            duration: motion.hover.duration,
            curve: motion.hover.curve,
            height: height,
            padding: EdgeInsets.symmetric(horizontal: spacing.s12),
            decoration: BoxDecoration(
              color:
                  widget.isDisabled ? colors.surfaceHover : colors.surfaceCard,
              borderRadius: BorderRadius.circular(radius.md),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            child: Row(
              children: [
                Icon(
                  widget.mode == GenaiDatePickerMode.range
                      ? LucideIcons.calendarRange
                      : LucideIcons.calendar,
                  size: sizing.iconSize,
                  color: colors.textTertiary,
                ),
                SizedBox(width: spacing.iconLabelGap),
                Expanded(
                  child: Text(
                    display ?? widget.hintText ?? '',
                    style: ty.bodySm.copyWith(
                      color: display == null
                          ? colors.textTertiary
                          : (widget.isDisabled
                              ? colors.textDisabled
                              : colors.textPrimary),
                    ),
                    overflow: TextOverflow.ellipsis,
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
      value: display,
      enabled: !widget.isDisabled,
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
