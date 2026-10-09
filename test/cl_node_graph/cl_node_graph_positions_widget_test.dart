import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

import 'flow_test_utils.dart';

const _nodes = [
  CLGraphNode(id: 'a', type: 't', title: 'Nodo A'),
  CLGraphNode(id: 'b', type: 't', title: 'Nodo B'),
  CLGraphNode(id: 'c', type: 't', title: 'Nodo C'),
];

/// Host che salva le posizioni come farebbe l'editor del flusso.
class _Host extends StatefulWidget {
  final Map<String, Offset> initial;
  final bool persist;
  final List<(String, Offset)> moved;
  final List<Map<String, Offset>> arranged;
  const _Host({required this.initial, required this.moved, required this.arranged, this.persist = true});

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late Map<String, Offset> positions = Map.of(widget.initial);

  @override
  Widget build(BuildContext context) => CLNodeGraph(
        nodes: _nodes,
        edges: const [],
        nodePositions: positions,
        showArrangeButton: true,
        layout: (nodes, _) => {for (var i = 0; i < nodes.length; i++) nodes[i].id: Offset(i * 300.0, 0)},
        onNodeMoved: (id, p) {
          widget.moved.add((id, p));
          if (widget.persist) setState(() => positions = {...positions, id: p});
        },
        onArrange: (p) {
          widget.arranged.add(p);
          setState(() => positions = p);
        },
      );
}

Future<(List<(String, Offset)>, List<Map<String, Offset>>)> _pump(
  WidgetTester tester, {
  Map<String, Offset> initial = const {'a': Offset(0, 0), 'b': Offset(400, 100), 'c': Offset(100, 300)},
  bool persist = true,
}) async {
  setFlowView(tester);
  final moved = <(String, Offset)>[];
  final arranged = <Map<String, Offset>>[];
  await pumpGraph(tester, _Host(initial: initial, moved: moved, arranged: arranged, persist: persist));
  return (moved, arranged);
}

Offset _canvasPos(WidgetTester tester, String title) {
  final p = cardPositioned(tester, title);
  return Offset(p.left!, p.top!);
}

double _scale(WidgetTester tester) => cardRect(tester, 'Nodo A').width / kCardW;

void main() {
  testWidgets('le posizioni dell\'host battono il layout', (tester) async {
    await _pump(tester);
    expect(_canvasPos(tester, 'Nodo A'), Offset.zero);
    expect(_canvasPos(tester, 'Nodo B'), const Offset(400, 100));
    expect(_canvasPos(tester, 'Nodo C'), const Offset(100, 300));
  });

  testWidgets('nodo senza posizione: segue il layout', (tester) async {
    await _pump(tester, initial: const {'a': Offset(0, 0), 'b': Offset(400, 100)});
    expect(_canvasPos(tester, 'Nodo C'), const Offset(600, 0)); // terzo nodo del layout
  });

  testWidgets('trascinamento: onNodeMoved con la posizione nuova, l\'host la salva', (tester) async {
    final (moved, _) = await _pump(tester);
    final s = _scale(tester);
    final start = cardRect(tester, 'Nodo B').center;
    await dragFromTo(tester, start, start + Offset(60 * s, 40 * s));
    expect(moved.single.$1, 'b');
    expect(moved.single.$2.dx, closeTo(460, 1));
    expect(moved.single.$2.dy, closeTo(140, 1));
    expect(_canvasPos(tester, 'Nodo B').dx, closeTo(460, 1));
  });

  testWidgets('se l\'host non salva, il nodo torna dov\'era', (tester) async {
    final (moved, _) = await _pump(tester, persist: false);
    final s = _scale(tester);
    final start = cardRect(tester, 'Nodo B').center;
    await dragFromTo(tester, start, start + Offset(60 * s, 40 * s));
    expect(moved, hasLength(1));
    expect(_canvasPos(tester, 'Nodo B'), const Offset(400, 100));
  });

  testWidgets('«Ordina»: onArrange riceve le posizioni del layout', (tester) async {
    final (_, arranged) = await _pump(tester);
    await tester.tap(find.text('Ordina'));
    await tester.pumpAndSettle();
    expect(arranged.single, {'a': Offset.zero, 'b': const Offset(300, 0), 'c': const Offset(600, 0)});
    expect(_canvasPos(tester, 'Nodo C'), const Offset(600, 0));
  });

  testWidgets('posizioni negative: il canvas scorre, onNodeMoved resta nelle coordinate dell\'host', (tester) async {
    final (moved, _) = await _pump(tester, initial: const {'a': Offset(-200, -50), 'b': Offset(400, 100), 'c': Offset(0, 0)});
    expect(_canvasPos(tester, 'Nodo A'), Offset.zero);
    expect(_canvasPos(tester, 'Nodo B'), const Offset(600, 150));
    final s = _scale(tester);
    final start = cardRect(tester, 'Nodo C').center;
    await dragFromTo(tester, start, start + Offset(10 * s, 10 * s));
    expect(moved.single.$2.dx, closeTo(10, 1));
    expect(moved.single.$2.dy, closeTo(10, 1));
  });
}
