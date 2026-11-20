import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';
import 'package:shadcn_ui/shadcn_ui.dart' show ShadTheme, ShadCheckbox;

Widget _app(Widget child, {CLTheme theme = CLTheme.light}) => MaterialApp(
      home: ShadTheme(
        data: theme.toShadTheme(),
        child: Scaffold(body: Center(child: child)),
      ),
    );

/// La casella di spunta (audit della 7.0.1 di skillera_emp, PK1): non scelta è vuota col bordo dei controlli, l'area
/// di tocco è di 44 × 44 e, con l'etichetta, anche il testo cambia la scelta.
void main() {
  testWidgets('non scelta: fondo della card, bordo dei controlli (non un quadrato pieno)', (tester) async {
    await tester.pumpWidget(_app(CLCheckbox(value: false, onChanged: (_) {})));
    final box = tester.widget<ShadCheckbox>(find.byType(ShadCheckbox));
    expect(box.uncheckedColor, CLTheme.light.secondaryBackground);
    expect(box.decoration!.border!.top!.color, CLTheme.light.inputBorder);
    expect(clContrastRatio(CLTheme.light.inputBorder, CLTheme.light.secondaryBackground), greaterThanOrEqualTo(3));
    expect(clContrastRatio(CLTheme.dark.inputBorder, CLTheme.dark.secondaryBackground), greaterThanOrEqualTo(3));
  });

  testWidgets('area di tocco 44 × 44: un tocco vicino al quadrato cambia la scelta', (tester) async {
    bool? got;
    await tester.pumpWidget(_app(CLCheckbox(value: false, onChanged: (v) => got = v)));
    expect(tester.getSize(find.byType(CLCheckbox)), const Size(44, 44));
    // Nell'angolo dell'area, fuori dal quadrato da 18.
    await tester.tapAt(tester.getTopLeft(find.byType(CLCheckbox)) + const Offset(3, 3));
    expect(got, isTrue);
  });

  testWidgets('con l\'etichetta: un tocco sul testo cambia la scelta, la riga è alta almeno 44', (tester) async {
    bool? got;
    await tester.pumpWidget(_app(CLCheckbox(value: true, label: 'Invia anche nel canale', onChanged: (v) => got = v)));
    expect(tester.getSize(find.byType(CLCheckbox)).height, greaterThanOrEqualTo(44));
    await tester.tap(find.text('Invia anche nel canale'));
    expect(got, isFalse);
  });

  testWidgets('compact: solo il quadrato; spenta senza onChanged', (tester) async {
    await tester.pumpWidget(_app(const CLCheckbox(value: false, onChanged: null, compact: true)));
    expect(tester.getSize(find.byType(CLCheckbox)).width, lessThan(44));
  });
}
