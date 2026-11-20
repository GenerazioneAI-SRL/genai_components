import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: SizedBox(width: 390, child: child)));

/// Il campo dell'assistente AI (audit della 7.0.1 di skillera_emp, G9): il pulsante d'invio sta nella riga del campo,
/// non sotto; a riposo il bordo si vede (≥ 3:1).
void main() {
  final field = find.byKey(const ValueKey('cl-ai-composer-field'));
  final send = find.byKey(const ValueKey('cl-ai-composer-send'));

  testWidgets('invia accanto al campo, nella stessa riga', (tester) async {
    await tester.pumpWidget(_app(CLAiChatComposer(onSend: (_) {}, minLines: 1)));
    final f = tester.getRect(field);
    final b = tester.getRect(send);
    expect(b.left, greaterThan(f.right), reason: 'il pulsante è a destra del campo');
    expect(b.top, lessThan(f.bottom), reason: 'e nella sua riga, non sotto');
    expect(b.bottom, greaterThan(f.top));
  });

  testWidgets('leading facoltativo a sinistra del campo', (tester) async {
    await tester.pumpWidget(_app(CLAiChatComposer(onSend: (_) {}, leading: const Icon(Icons.add, key: ValueKey('plus')))));
    expect(tester.getRect(find.byKey(const ValueKey('plus'))).right, lessThanOrEqualTo(tester.getRect(field).left));
  });

  testWidgets('a riposo il bordo è quello dei controlli', (tester) async {
    await tester.pumpWidget(_app(CLAiChatComposer(onSend: (_) {})));
    final ring = tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer)).first;
    expect((ring.decoration! as BoxDecoration).color, CLTheme.light.inputBorder);
  });

  testWidgets('il segnaposto di serie segue la lingua', (tester) async {
    // La lingua si carica a richiesta (lazy): fuori dal tempo finto del test.
    await tester.runAsync(() => CLLocale.set('en'));
    addTearDown(() => CLLocale.set('it'));
    await tester.pumpWidget(_app(CLAiChatComposer(onSend: (_) {})));
    expect(find.text('Write a message...'), findsOneWidget);
  });
}
