// test/foundation/cl_surface_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/cl_theme.dart';
import 'package:genai_components/widgets/foundation/cl_surface.widget.dart';

const theme = CLTheme.light;

Future<BoxDecoration> _pumpAndGetDecoration(
    WidgetTester tester, Widget surface) async {
  await tester.pumpWidget(MaterialApp(
    theme: ThemeData(brightness: Brightness.light),
    home: Center(child: surface),
  ));
  final container = tester.widget<Container>(find.byType(Container).first);
  return container.decoration! as BoxDecoration;
}

void main() {
  testWidgets('card: secondaryBackground + radiusCard + cardBorder + cardShadow',
      (tester) async {
    final d = await _pumpAndGetDecoration(
        tester, const CLSurface.card(child: SizedBox(width: 10, height: 10)));
    expect(d.color, theme.secondaryBackground);
    expect(d.borderRadius, BorderRadius.circular(theme.radiusCard));
    expect(d.border, Border.all(color: theme.cardBorder));
    expect(d.boxShadow, theme.cardShadow);
  });

  testWidgets('soft: cardShadowSoft e nessun bordo', (tester) async {
    final d = await _pumpAndGetDecoration(
        tester, const CLSurface.soft(child: SizedBox(width: 10, height: 10)));
    expect(d.boxShadow, theme.cardShadowSoft);
    expect(d.border, isNull);
  });

  testWidgets('recessed: primaryBackground, radiusSurface, niente ombra',
      (tester) async {
    final d = await _pumpAndGetDecoration(tester,
        const CLSurface.recessed(child: SizedBox(width: 10, height: 10)));
    expect(d.color, theme.primaryBackground);
    expect(d.borderRadius, BorderRadius.circular(theme.radiusSurface));
    expect(d.boxShadow, isNull);
  });

  testWidgets('panel: popoverShadow + bordo hairline', (tester) async {
    final d = await _pumpAndGetDecoration(
        tester, const CLSurface.panel(child: SizedBox(width: 10, height: 10)));
    expect(d.boxShadow, theme.popoverShadow);
    expect(d.border, Border.all(color: theme.cardBorder));
    expect(d.borderRadius, BorderRadius.circular(theme.radiusSurface));
  });

  testWidgets('tint: bg = colore x opacitySoft, radiusChip', (tester) async {
    final d = await _pumpAndGetDecoration(
        tester,
        CLSurface.tint(
            color: theme.success, child: const SizedBox(width: 10, height: 10)));
    expect(d.color, theme.success.withValues(alpha: theme.opacitySoft));
    expect(d.borderRadius, BorderRadius.circular(theme.radiusChip));
  });

  testWidgets('override: radius e color vincono sul preset', (tester) async {
    final d = await _pumpAndGetDecoration(
        tester,
        const CLSurface.card(
            radius: 99,
            color: Colors.red,
            child: SizedBox(width: 10, height: 10)));
    expect(d.borderRadius, BorderRadius.circular(99));
    expect(d.color, Colors.red);
  });
}
