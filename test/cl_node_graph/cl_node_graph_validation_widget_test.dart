import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/src/widgets/cl_node_graph/cl_graph_attributes.dart';
import 'package:genai_components/src/widgets/cl_node_graph/cl_graph_models.dart';
import 'package:genai_components/src/widgets/cl_node_graph/cl_node_graph.widget.dart';

const _longTitle = 'Reminder WhatsApp personalizzato per chi non ha aperto l\'email di benvenuto';
const _longLabel = 'escludi i contatti che sono già clienti negli ultimi dodici mesi';

const _attrs = [
  CLGraphNodeAttribute.time(name: 'invia alle', defaultValue: '18:30'),
  CLGraphNodeAttribute.url(name: 'link', nullable: true),
  CLGraphNodeAttribute.numeric(name: 'giorni', min: 1, max: 30, integer: true, defaultValue: 2),
  CLGraphNodeAttribute.string(name: 'messaggio'),
  CLGraphNodeAttribute.boolean(name: _longLabel, defaultValue: false),
];

class _Host extends StatefulWidget {
  const _Host({required this.calls});
  final List<(String, Object?)> calls;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  List<CLGraphNode> nodes = const [
    CLGraphNode(id: 'A', type: 't', title: 'AAA', subtitle: 'Sottotitolo abbastanza lungo da andare a capo nella card'),
    CLGraphNode(id: 'B', type: 't', title: _longTitle, attributes: _attrs),
  ];

  @override
  Widget build(BuildContext context) => CLNodeGraph(
        nodes: nodes,
        edges: const [],
        layout: (nodes, _) => {'A': Offset.zero, 'B': const Offset(300, 0)},
        onAttributeChanged: (nodeId, name, value) {
          widget.calls.add((name, value));
          setState(() {
            nodes = [for (final n in nodes) n.id == nodeId ? n.withAttributeValue(name, value) : n];
          });
        },
      );
}

Future<List<(String, Object?)>> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1000, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final calls = <(String, Object?)>[];
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: _Host(calls: calls))));
  await tester.pumpAndSettle();
  return calls;
}

Finder _field(int i) => find.byType(TextField).at(i);

Finder _cardOf(String title) => find.ancestor(of: find.text(title), matching: find.byType(Positioned)).first;

Future<void> _unfocus(WidgetTester tester) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('orario: si scrivono solo cifre, i due punti arrivano da soli', (tester) async {
    final calls = await _pump(tester);
    expect(tester.widget<TextField>(_field(0)).controller!.text, '18:30'); // default
    await tester.enterText(_field(0), '930');
    await tester.pump();
    expect(tester.widget<TextField>(_field(0)).controller!.text, '09:30');
    expect(calls.last, ('invia alle', '09:30'));
  });

  testWidgets('orario a metà: nessun errore mentre si scrive, errore quando si esce', (tester) async {
    final calls = await _pump(tester);
    await tester.enterText(_field(0), '093');
    await tester.pump();
    expect(tester.widget<TextField>(_field(0)).controller!.text, '09:3');
    expect(find.textContaining('Completa'), findsNothing);
    await _unfocus(tester);
    expect(find.text('Completa l\'orario (HH:MM)'), findsOneWidget);
    expect(calls.where((c) => c.$1 == 'invia alle'), isEmpty); // mai emesso
  });

  testWidgets('orario con la sola ora: completato con :00 all\'uscita', (tester) async {
    final calls = await _pump(tester);
    await tester.enterText(_field(0), '9');
    await tester.pump();
    expect(tester.widget<TextField>(_field(0)).controller!.text, '09');
    await _unfocus(tester);
    expect(tester.widget<TextField>(_field(0)).controller!.text, '09:00');
    expect(calls.last, ('invia alle', '09:00'));
  });

  testWidgets('link: https aggiunto, link non valido segnalato all\'uscita', (tester) async {
    final calls = await _pump(tester);
    await tester.enterText(_field(1), 'www.atelier.it/prenota');
    await tester.pump();
    expect(calls.last, ('link', 'https://www.atelier.it/prenota'));
    await _unfocus(tester);
    expect(tester.widget<TextField>(_field(1)).controller!.text, 'https://www.atelier.it/prenota');

    await tester.enterText(_field(1), 'atelier');
    await tester.pump();
    expect(find.textContaining('Link non valido'), findsNothing);
    await _unfocus(tester);
    expect(find.text('Link non valido (es. www.sito.it)'), findsOneWidget);
    expect(calls.last, ('link', 'https://www.atelier.it/prenota')); // il valore non valido non arriva all'host
  });

  testWidgets('numero fuori intervallo: errore subito, card più alta, niente emissione', (tester) async {
    final calls = await _pump(tester);
    final before = tester.getSize(_cardOf(_longTitle)).height;
    await tester.enterText(_field(2), '45');
    await tester.pump();
    expect(find.text('Valore tra 1 e 30'), findsOneWidget);
    expect(calls.where((c) => c.$1 == 'giorni'), isEmpty);
    expect(tester.getSize(_cardOf(_longTitle)).height, greaterThan(before));
    await tester.enterText(_field(2), '12');
    await tester.pump();
    expect(find.text('Valore tra 1 e 30'), findsNothing);
    expect(calls.last, ('giorni', 12));
    expect(tester.getSize(_cardOf(_longTitle)).height, before);
  });

  testWidgets('obbligatorio senza valore: "Obbligatorio" visibile finché non si scrive', (tester) async {
    final calls = await _pump(tester);
    expect(find.text('Obbligatorio'), findsOneWidget); // messaggio
    await tester.enterText(_field(3), 'Ciao!');
    await tester.pump();
    expect(calls.last, ('messaggio', 'Ciao!'));
    expect(find.text('Obbligatorio'), findsNothing);
  });

  testWidgets('testo lungo: va a capo, nessun troncamento, la card si allunga', (tester) async {
    await _pump(tester);
    for (final text in [_longTitle, _longLabel, 'Sottotitolo abbastanza lungo da andare a capo nella card']) {
      final paragraph = tester.renderObject<RenderParagraph>(find.text(text));
      expect(paragraph.didExceedMaxLines, isFalse, reason: text);
      expect(paragraph.size.height, greaterThan(paragraph.text.style!.fontSize! * 2), reason: '$text su più righe');
    }
    // Il sottotitolo a capo allunga anche una card senza attributi.
    expect(tester.getSize(_cardOf('AAA')).height, greaterThanOrEqualTo(kCardH));
    // Il messaggio lungo fa crescere il campo invece di scorrere in orizzontale.
    final oneLine = tester.getSize(_field(3)).height;
    await tester.enterText(_field(3), 'Ciao! Ti aspettiamo in atelier per la prima prova: rispondi a questo messaggio per scegliere il giorno.');
    await tester.pump();
    expect(tester.getSize(_field(3)).height, greaterThan(oneLine));
  });
}
