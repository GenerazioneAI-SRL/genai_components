import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/cl_theme.dart';
import 'package:genai_components/widgets/foundation/cl_pressable.widget.dart';
import 'package:genai_components/widgets/foundation/cl_tone_style.dart';

void main() {
  const theme = CLTheme.light;

  group('CLToneStyle.resolve — colored', () {
    test('soft: idle/hover/press seguono la scala opacitySoft→Muted→Medium', () {
      final idle = CLToneStyle.resolve(theme,
          color: theme.success, variant: CLVariant.soft);
      final hover = CLToneStyle.resolve(theme,
          color: theme.success,
          variant: CLVariant.soft,
          state: const CLPressableState(hovered: true));
      final press = CLToneStyle.resolve(theme,
          color: theme.success,
          variant: CLVariant.soft,
          state: const CLPressableState(pressed: true));
      expect(idle.bg, theme.success.withValues(alpha: theme.opacitySoft));
      expect(hover.bg, theme.success.withValues(alpha: theme.opacityMuted));
      expect(press.bg, theme.success.withValues(alpha: theme.opacityMedium));
      expect(idle.fg, theme.success);
    });

    test('ghost: trasparente a riposo, tinta al hover, fg colorato', () {
      final idle = CLToneStyle.resolve(theme,
          color: theme.danger, variant: CLVariant.ghost);
      final hover = CLToneStyle.resolve(theme,
          color: theme.danger,
          variant: CLVariant.ghost,
          state: const CLPressableState(hovered: true));
      expect(idle.bg, Colors.transparent);
      expect(hover.bg, theme.danger.withValues(alpha: theme.opacitySoft));
      expect(idle.fg, theme.danger);
      expect(idle.border, isNull);
    });

    test('outline: come ghost ma con bordo tonale', () {
      final idle = CLToneStyle.resolve(theme,
          color: theme.primary, variant: CLVariant.outline);
      expect(idle.border, theme.primary);
    });

    test('solid: bg pieno, hover/press scuriscono, fg auto-contrasto', () {
      final idle = CLToneStyle.resolve(theme,
          color: theme.primary, variant: CLVariant.solid);
      final hover = CLToneStyle.resolve(theme,
          color: theme.primary,
          variant: CLVariant.solid,
          state: const CLPressableState(hovered: true));
      expect(idle.bg, theme.primary);
      expect(hover.bg, Color.lerp(theme.primary, Colors.black, 0.08));
      expect(idle.fg,
          theme.primary.computeLuminance() > 0.5 ? Colors.black : Colors.white);
    });

    test('disabled: restituisce i colori idle (opacità a carico del consumer)', () {
      final disabled = CLToneStyle.resolve(theme,
          color: theme.primary,
          variant: CLVariant.soft,
          state: const CLPressableState(disabled: true));
      final idle = CLToneStyle.resolve(theme,
          color: theme.primary, variant: CLVariant.soft);
      expect(disabled.bg, idle.bg);
    });
  });

  group('CLToneStyle.resolve — neutro (colored: false)', () {
    test('ghost neutro: hover=accent, press=accent scurito, fg=primaryText', () {
      final hover = CLToneStyle.resolve(theme,
          color: theme.secondary,
          variant: CLVariant.ghost,
          colored: false,
          state: const CLPressableState(hovered: true));
      final press = CLToneStyle.resolve(theme,
          color: theme.secondary,
          variant: CLVariant.ghost,
          colored: false,
          state: const CLPressableState(pressed: true));
      expect(hover.bg, theme.accent);
      expect(press.bg, Color.lerp(theme.accent, Colors.black, 0.08));
      expect(hover.fg, theme.primaryText);
    });

    test('outline neutro: bordo cardBorder', () {
      final idle = CLToneStyle.resolve(theme,
          color: theme.secondary, variant: CLVariant.outline, colored: false);
      expect(idle.border, theme.cardBorder);
    });
  });

  group('CLToneStyle.colorOf', () {
    test('mappa i toni sui token del tema', () {
      expect(CLToneStyle.colorOf(theme, CLTone.primary), theme.primary);
      expect(CLToneStyle.colorOf(theme, CLTone.danger), theme.danger);
      expect(CLToneStyle.colorOf(theme, CLTone.neutral), theme.mutedForeground);
    });
  });
}
