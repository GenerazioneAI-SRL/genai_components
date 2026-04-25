import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '_field_frame.dart';

/// Chips-style input — v3 Forma LMS.
///
/// User types a value, presses Enter or a separator character, and the token
/// commits to the [values] list as a removable chip. Backspace in an empty
/// editor removes the last chip. Shares the [GenaiTextField] chrome so the
/// control blends with the rest of the form rhythm.
class GenaiTagInput extends StatefulWidget {
  /// Current list of tags.
  final List<String> values;

  /// Fired whenever the list changes (add, remove, paste).
  final ValueChanged<List<String>>? onChanged;

  /// Field label above the control.
  final String? label;

  /// Placeholder inside the editor when there are no chips.
  final String? hintText;

  /// Helper copy below the control.
  final String? helperText;

  /// Error copy; takes precedence over helper.
  final String? errorText;

  /// Appends a red asterisk after [label].
  final bool isRequired;

  /// Muted colours, no interaction.
  final bool isDisabled;

  /// Read-only — chips visible but no editing or removing.
  final bool isReadOnly;

  /// Characters that commit the current editor text as a tag when typed.
  /// Enter always commits. Defaults to `[',', ';']`.
  final List<String> separators;

  /// Max number of tags (null = unbounded).
  final int? maxTags;

  /// Drop duplicate tags silently.
  final bool deduplicate;

  /// Optional validator / transformer for an incoming tag. Return null to
  /// reject it.
  final String? Function(String raw)? transformTag;

  /// Screen-reader label override.
  final String? semanticLabel;

  const GenaiTagInput({
    super.key,
    required this.values,
    this.onChanged,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.isRequired = false,
    this.isDisabled = false,
    this.isReadOnly = false,
    this.separators = const [',', ';'],
    this.maxTags,
    this.deduplicate = true,
    this.transformTag,
    this.semanticLabel,
  });

  @override
  State<GenaiTagInput> createState() => _GenaiTagInputState();
}

class _GenaiTagInputState extends State<GenaiTagInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _focusNode
        .addListener(() => setState(() => _focused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _hasError =>
      widget.errorText != null && widget.errorText!.isNotEmpty;

  bool get _canAddMore =>
      widget.maxTags == null || widget.values.length < widget.maxTags!;

  void _commit(String raw) {
    if (widget.isReadOnly || widget.isDisabled) return;
    var buffer = raw;
    for (final sep in widget.separators) {
      buffer = buffer.replaceAll(sep, '\n');
    }
    final parts = <String>[];
    for (final chunk in buffer.split('\n')) {
      final t = chunk.trim();
      if (t.isEmpty) continue;
      parts.add(t);
    }

    if (parts.isEmpty) {
      _controller.clear();
      return;
    }

    final next = List<String>.from(widget.values);
    for (final p in parts) {
      if (!_canAddMore) break;
      final transformed =
          widget.transformTag == null ? p : widget.transformTag!(p);
      if (transformed == null || transformed.isEmpty) continue;
      if (widget.deduplicate && next.contains(transformed)) continue;
      next.add(transformed);
    }

    if (!listEquals(next, widget.values)) {
      widget.onChanged?.call(next);
    }
    _controller.clear();
  }

  void _remove(int index) {
    if (widget.isReadOnly || widget.isDisabled) return;
    final next = List<String>.from(widget.values)..removeAt(index);
    widget.onChanged?.call(next);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.backspace &&
        _controller.text.isEmpty &&
        widget.values.isNotEmpty) {
      _remove(widget.values.length - 1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final radius = context.radius;
    final motion = context.motion;

    final borderColor = widget.isDisabled
        ? colors.borderSubtle
        : _hasError
            ? colors.colorDanger
            : _focused
                ? colors.borderFocus
                : (_hovered ? colors.textPrimary : colors.borderStrong);
    final borderWidth = (_focused || _hasError) ? sizing.focusRingWidth : 1.0;

    final inputStyle = ty.bodySm.copyWith(
        color: widget.isDisabled ? colors.textDisabled : colors.textPrimary);

    final chips = <Widget>[
      for (var i = 0; i < widget.values.length; i++)
        _TagChip(
          label: widget.values[i],
          onRemove:
              widget.isDisabled || widget.isReadOnly ? null : () => _remove(i),
        ),
    ];

    final editor = Focus(
      onKeyEvent: _onKey,
      child: IntrinsicWidth(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 80),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: !widget.isDisabled && !widget.isReadOnly && _canAddMore,
            style: inputStyle,
            cursorColor: colors.colorPrimary,
            decoration: InputDecoration(
              isDense: true,
              hintText: widget.values.isEmpty ? widget.hintText : null,
              hintStyle: inputStyle.copyWith(color: colors.textTertiary),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (v) {
              for (final sep in widget.separators) {
                if (v.contains(sep)) {
                  _commit(v);
                  return;
                }
              }
            },
            onSubmitted: _commit,
          ),
        ),
      ),
    );

    final body = AnimatedContainer(
      duration: motion.hover.duration,
      curve: motion.hover.curve,
      padding:
          EdgeInsets.symmetric(horizontal: spacing.s8, vertical: spacing.s4),
      decoration: BoxDecoration(
        color: widget.isDisabled ? colors.surfaceHover : colors.surfaceCard,
        borderRadius: BorderRadius.circular(radius.md),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _focusNode.requestFocus(),
          child: Wrap(
            spacing: spacing.s4,
            runSpacing: spacing.s4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ...chips,
              editor,
            ],
          ),
        ),
      ),
    );

    return Semantics(
      label: widget.semanticLabel ?? widget.label,
      enabled: !widget.isDisabled,
      readOnly: widget.isReadOnly,
      child: FieldFrame(
        label: widget.label,
        isRequired: widget.isRequired,
        isDisabled: widget.isDisabled,
        helperText: widget.helperText,
        errorText: widget.errorText,
        control: body,
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final VoidCallback? onRemove;

  const _TagChip({required this.label, this.onRemove});

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
          Text(label, style: ty.label.copyWith(color: colors.colorPrimaryText)),
          if (onRemove != null) ...[
            SizedBox(width: spacing.s4),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onRemove,
                child: Semantics(
                  button: true,
                  label: 'Rimuovi $label',
                  child: Icon(LucideIcons.x,
                      size: (ty.label.fontSize ?? 12) + 1,
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
