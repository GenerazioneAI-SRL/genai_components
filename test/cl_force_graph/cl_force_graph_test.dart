import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

void main() {
  group('CLForceLayout', () {
    test('si assesta: i vicini restano vicini, i lontani si separano, i nodi fissati non si muovono', () {
      final layout = CLForceLayout(
        bodies: [for (final id in ['a', 'b', 'c', 'x']) CLForceBody(id, degree: id == 'x' ? 0 : 2)],
        edges: const [('a', 'b'), ('b', 'c'), ('c', 'a')],
      );
      layout.pin('x', position: const Offset(500, 500));
      final steps = layout.settle(maxSteps: 2000);
      expect(steps, lessThan(2000));
      final p = {for (final b in layout.bodies.values) b.id: b.position};
      expect((p['a']! - p['b']!).distance, lessThan((p['a']! - p['x']!).distance));
      expect(p['x'], const Offset(500, 500));
    });

    test('ripetibile con lo stesso seme', () {
      CLForceLayout make() => CLForceLayout(bodies: [for (var i = 0; i < 30; i++) CLForceBody('n$i')], edges: [for (var i = 1; i < 30; i++) ('n0', 'n$i')])..settle();
      expect(make().bodies['n7']!.position, make().bodies['n7']!.position);
    });

    test('il quadtree trova il nodo sotto il punto', () {
      final bodies = [CLForceBody('a', position: const Offset(0, 0)), CLForceBody('b', position: const Offset(100, 0)), CLForceBody('c', position: const Offset(100, 100))];
      final tree = CLForceQuadTree.of(bodies);
      expect(tree.hit(const Offset(98, 2), (_) => 5)?.id, 'b');
      expect(tree.hit(const Offset(50, 50), (_) => 5), isNull);
    });

    test('regge mille nodi', () {
      final layout = CLForceLayout(bodies: [for (var i = 0; i < 1000; i++) CLForceBody('n$i')], edges: [for (var i = 1; i < 1000; i++) ('n${i ~/ 3}', 'n$i')]);
      final sw = Stopwatch()..start();
      for (var i = 0; i < 20; i++) {
        layout.step();
      }
      expect(sw.elapsedMilliseconds, lessThan(5000));
    });
  });

  testWidgets('CLForceGraph: disegna, il tocco su un nodo lo dice, vuoto ha il suo testo', (tester) async {
    final tapped = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 600,
            height: 400,
            child: CLForceGraph(
              key: const Key('g'),
              animate: false,
              nodes: const [CLForceNode(id: 'a', label: 'Alfa', group: 'A', degree: 2), CLForceNode(id: 'b', label: 'Beta', group: 'B', degree: 1), CLForceNode(id: 'c', label: 'Gamma', muted: true)],
              edges: const [CLForceEdge('a', 'b'), CLForceEdge('a', 'c', dashed: true)],
              onNodeTap: tapped.add,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    final state = tester.state<CLForceGraphState>(find.byKey(const Key('g')));
    final at = state.screenPositionOf('b')!;
    final origin = tester.getTopLeft(find.byKey(const Key('g')));
    await tester.tapAt(origin + at);
    await tester.pump(const Duration(milliseconds: 400));
    expect(tapped, ['b']);
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: CLForceGraph(nodes: [], edges: [], emptyText: 'Vuoto'))));
    expect(find.text('Vuoto'), findsOneWidget);
  });
}
