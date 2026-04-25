import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Size scale for [GenaiKbd] — v3 Forma LMS.
enum GenaiKbdSize {
  /// Matches `.ask-kbd` in the reference — `monoSm` (~11 px Geist Mono)
  /// inside a 2/6 padded 4-radius pill.
  sm,

  /// Slightly larger — `monoMd` for inline next to `body` text.
  md,
}

/// Keyboard shortcut pill — v3 design system (Forma LMS).
///
/// Matches `.ask-kbd { background: neutral-soft; border: 1px line;
/// border-radius: 4px; padding: 2px 6px; font: Geist Mono 10.5/400 }` in
/// Dashboard v3.html.
///
/// Unicode glyphs (`⌘ ⇧ ⌃ ⌥ ↵ ⌫ ↹ …`) are expanded into readable words for
/// the screen-reader label so users hear "Command K" instead of "clover K".
class GenaiKbd extends StatelessWidget {
  /// Literal text rendered inside the pill.
  final String keys;

  /// Visual size scale.
  final GenaiKbdSize size;

  /// Explicit accessibility label. When `null`, [keys] is expanded via a
  /// glyph → word table for screen readers.
  final String? semanticLabel;

  const GenaiKbd({
    super.key,
    required this.keys,
    this.size = GenaiKbdSize.sm,
    this.semanticLabel,
  });

  static const Map<String, String> _a11yGlyphs = <String, String>{
    '⌘': 'Command ',
    '⇧': 'Shift ',
    '⌃': 'Control ',
    '⌥': 'Option ',
    '↵': 'Enter ',
    '⏎': 'Enter ',
    '⌫': 'Backspace ',
    '⌦': 'Delete ',
    '↹': 'Tab ',
    '⇥': 'Tab ',
    '␣': 'Space ',
    '↑': 'Arrow up ',
    '↓': 'Arrow down ',
    '←': 'Arrow left ',
    '→': 'Arrow right ',
  };

  static String _expandKeysForA11y(String raw) {
    final hasGlyph = _a11yGlyphs.keys.any(raw.contains);
    if (!hasGlyph) return raw;
    var out = raw;
    _a11yGlyphs.forEach((symbol, word) {
      out = out.replaceAll(symbol, word);
    });
    return out.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final sizing = context.sizing;

    final base = size == GenaiKbdSize.sm ? ty.monoSm : ty.monoMd;

    return Semantics(
      label: semanticLabel ?? _expandKeysForA11y(keys),
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.s6,
          vertical: spacing.s2,
        ),
        decoration: BoxDecoration(
          color: colors.colorNeutralSubtle,
          borderRadius: BorderRadius.circular(radius.xs),
          border: Border.all(
            color: colors.borderDefault,
            width: sizing.dividerThickness,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          keys,
          style: base.copyWith(color: colors.textTertiary, height: 1),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
