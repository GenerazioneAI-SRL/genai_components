import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '_field_frame.dart';

/// Swatch-palette colour picker with optional hex input — v3 Forma LMS.
///
/// Presents a grid of [swatches] the user can tap to select. When
/// [showHexInput] is true, a compact hex editor sits beneath the grid using
/// the shared field chrome (`surfaceCard` fill, `borderDefault` at rest).
class GenaiColorPicker extends StatefulWidget {
  /// Current colour (null = unset).
  final Color? value;

  /// Fired when the user picks a swatch or commits a hex value.
  final ValueChanged<Color>? onChanged;

  /// Palette swatches. Defaults to an editorial palette that plays well
  /// against the Forma LMS neutrals.
  final List<Color> swatches;

  /// When true, a `#RRGGBB` text field is shown below the swatches.
  final bool showHexInput;

  /// Field label above the picker.
  final String? label;

  /// Helper copy below.
  final String? helperText;

  /// Error copy; takes precedence over helper.
  final String? errorText;

  /// Appends a red asterisk after [label].
  final bool isRequired;

  /// Muted colours, no interaction.
  final bool isDisabled;

  /// Screen-reader label override.
  final String? semanticLabel;

  static const _defaultSwatches = <Color>[
    Color(0xFF0D1220),
    Color(0xFF4A5268),
    Color(0xFF8891A3),
    Color(0xFFB3261E),
    Color(0xFFA35F00),
    Color(0xFF0A7D50),
    Color(0xFF0B5FD9),
    Color(0xFF7C3AED),
    Color(0xFFEC4899),
    Color(0xFF22C55E),
    Color(0xFFF59E0B),
    Color(0xFFFFFFFF),
  ];

  const GenaiColorPicker({
    super.key,
    required this.value,
    this.onChanged,
    this.swatches = _defaultSwatches,
    this.showHexInput = true,
    this.label,
    this.helperText,
    this.errorText,
    this.isRequired = false,
    this.isDisabled = false,
    this.semanticLabel,
  });

  @override
  State<GenaiColorPicker> createState() => _GenaiColorPickerState();
}

class _GenaiColorPickerState extends State<GenaiColorPicker> {
  late TextEditingController _hexController;

  @override
  void initState() {
    super.initState();
    _hexController = TextEditingController(text: _toHex(widget.value));
  }

  @override
  void didUpdateWidget(covariant GenaiColorPicker old) {
    super.didUpdateWidget(old);
    final incoming = _toHex(widget.value);
    if (incoming != _hexController.text && incoming != null) {
      _hexController.text = incoming;
    }
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  String? _toHex(Color? c) {
    if (c == null) return null;
    final r = (c.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (c.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (c.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '#${(r + g + b).toUpperCase()}';
  }

  Color? _parseHex(String raw) {
    var s = raw.trim().replaceAll('#', '');
    if (s.length == 3) {
      s = s.split('').map((c) => '$c$c').join();
    }
    if (s.length != 6) return null;
    final v = int.tryParse(s, radix: 16);
    if (v == null) return null;
    return Color(0xFF000000 | v);
  }

  void _pick(Color c) {
    if (widget.isDisabled) return;
    widget.onChanged?.call(c);
    _hexController.text = _toHex(c) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final radius = context.radius;

    final grid = Wrap(
      spacing: spacing.s8,
      runSpacing: spacing.s8,
      children: [
        for (final c in widget.swatches)
          _Swatch(
            color: c,
            selected: widget.value == c,
            disabled: widget.isDisabled,
            onTap: () => _pick(c),
          ),
      ],
    );

    Widget control = grid;
    if (widget.showHexInput) {
      control = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          grid,
          SizedBox(height: spacing.s8),
          Container(
            height: 36,
            padding: EdgeInsets.symmetric(horizontal: spacing.s12),
            decoration: BoxDecoration(
              color:
                  widget.isDisabled ? colors.surfaceHover : colors.surfaceCard,
              borderRadius: BorderRadius.circular(radius.md),
              border: Border.all(color: colors.borderStrong),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.hash,
                    size: sizing.iconSize, color: colors.textTertiary),
                SizedBox(width: spacing.iconLabelGap),
                Expanded(
                  child: TextField(
                    controller: _hexController,
                    enabled: !widget.isDisabled,
                    style: ty.monoMd.copyWith(color: colors.textPrimary),
                    cursorColor: colors.colorPrimary,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9a-fA-F#]')),
                      LengthLimitingTextInputFormatter(7),
                    ],
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: '#RRGGBB',
                      hintStyle: ty.monoMd.copyWith(color: colors.textTertiary),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (v) {
                      final c = _parseHex(v);
                      if (c != null) widget.onChanged?.call(c);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Semantics(
      label: widget.semanticLabel ?? widget.label ?? 'Scelta colore',
      enabled: !widget.isDisabled,
      child: FieldFrame(
        label: widget.label,
        isRequired: widget.isRequired,
        isDisabled: widget.isDisabled,
        helperText: widget.helperText,
        errorText: widget.errorText,
        control: control,
      ),
    );
  }
}

class _Swatch extends StatefulWidget {
  final Color color;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  const _Swatch({
    required this.color,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  @override
  State<_Swatch> createState() => _SwatchState();
}

class _SwatchState extends State<_Swatch> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sizing = context.sizing;
    final radius = context.radius;

    final borderColor =
        widget.selected ? colors.colorPrimary : colors.borderDefault;
    final borderWidth = widget.selected ? sizing.focusRingWidth : 1.0;

    Widget swatch = Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(radius.sm),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
    );

    if (_focused && !widget.disabled) {
      swatch = Container(
        padding: EdgeInsets.all(sizing.focusRingOffset),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(radius.sm + sizing.focusRingOffset),
          border: Border.all(
              color: colors.borderFocus, width: sizing.focusRingWidth),
        ),
        child: swatch,
      );
    }

    return Opacity(
      opacity: widget.disabled ? 0.5 : 1,
      child: Focus(
        onFocusChange: (f) => setState(() => _focused = f),
        child: MouseRegion(
          cursor: widget.disabled
              ? SystemMouseCursors.forbidden
              : SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.disabled ? null : widget.onTap,
            child: Semantics(
              button: true,
              selected: widget.selected,
              enabled: !widget.disabled,
              label:
                  '#${widget.color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
              child: swatch,
            ),
          ),
        ),
      ),
    );
  }
}
