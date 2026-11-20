import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

/// La superficie «Trascina i file qui o clicca per caricare» sul telefono: il testo va a capo e la superficie cresce
/// con lui (prima era alta 140 fissi e traboccava di 20 px a 358 di larghezza: CI di skillera_emp, «Carica documento»).
void main() {
  testWidgets('a 358 px di larghezza niente overflow', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 358,
            child: ClFilePicker.multiple(
              allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'heic', 'docx'],
              maxNumberOfFile: 5,
              onFilesPicked: (_) {},
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Trascina i file qui o clicca per caricare'), findsOneWidget);
  });
}
