import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/src/widgets/cl_node_graph/cl_graph_connections.dart';
import 'package:genai_components/src/widgets/cl_node_graph/cl_graph_models.dart';

const _trigger = CLGraphNode(
  id: 'T',
  type: 'trigger',
  title: 'Nuovo lead',
  connectionRules: CLGraphConnectionRules(inputTypes: {}, outputTypes: {'action', 'wait'}, minOutputs: 1, maxOutputs: 1),
);
const _action = CLGraphNode(
  id: 'A',
  type: 'action',
  title: 'Email',
  connectionRules: CLGraphConnectionRules(inputTypes: {'trigger', 'action'}, minInputs: 1),
);
const _end = CLGraphNode(
  id: 'E',
  type: 'end',
  title: 'Fine',
  connectionRules: CLGraphConnectionRules(outputTypes: {}, minInputs: 1),
);
const _free = CLGraphNode(id: 'F', type: 'note', title: 'Libero');

CLGraphEdge _e(String from, String to) =>
    CLGraphEdge(id: '$from>$to', fromNodeId: from, toNodeId: to, kind: CLGraphEdgeKind.prerequisite);

String _label(String type) => switch (type) {
      'action' => 'Azione',
      'wait' => 'Attesa',
      'trigger' => 'Trigger',
      _ => type,
    };

void main() {
  group('clGraphConnectionProblem', () {
    test('nodi senza regole: tutto ammesso tranne se stesso e i doppioni', () {
      const other = CLGraphNode(id: 'G', type: 'note', title: 'Altro');
      expect(clGraphConnectionProblem(_free, other, const []), isNull);
      expect(clGraphConnectionProblem(_free, _free, const []), contains('se stesso'));
      expect(clGraphConnectionProblem(_free, other, [_e('F', 'G')]), contains('già collegato'));
    });

    test('tipo in uscita non ammesso, con i nomi leggibili dei tipi', () {
      expect(clGraphConnectionProblem(_trigger, _action, const []), isNull);
      expect(
        clGraphConnectionProblem(_trigger, _end, const [], typeLabel: _label),
        '«Nuovo lead» può proseguire solo verso: Azione, Attesa',
      );
    });

    test('tipo in ingresso non ammesso e nodi senza ingressi o uscite', () {
      expect(
        clGraphConnectionProblem(_free, _action, const [], typeLabel: _label), // _free esce ovunque, ma «Email» sceglie
        '«Email» accetta ingressi solo da: Trigger, Azione',
      );
      expect(
        clGraphConnectionProblem(const CLGraphNode(id: 'W', type: 'wait', title: 'Attendi'), _action, const [], typeLabel: _label),
        '«Email» accetta ingressi solo da: Trigger, Azione',
      );
      expect(clGraphConnectionProblem(_action, _trigger, const []), '«Nuovo lead» non accetta ingressi');
      expect(clGraphConnectionProblem(_end, _action, const []), '«Fine» non ha uscite');
    });

    test('massimo di uscite raggiunto', () {
      const other = CLGraphNode(id: 'A2', type: 'action', title: 'SMS', connectionRules: CLGraphConnectionRules(inputTypes: {'trigger'}));
      expect(clGraphConnectionProblem(_trigger, other, [_e('T', 'A')]), '«Nuovo lead» ha già 1 uscita (massimo 1)');
      expect(clGraphOutputProblem(_trigger, [_e('T', 'A')]), isNotNull);
      expect(clGraphOutputProblem(_trigger, const []), isNull);
    });

    test('massimo di ingressi raggiunto', () {
      const single = CLGraphNode(id: 'S', type: 'x', title: 'Unico', connectionRules: CLGraphConnectionRules(maxInputs: 1));
      expect(clGraphConnectionProblem(_free, single, [_e('A', 'S')]), '«Unico» ha già 1 ingresso (massimo 1)');
    });
  });

  group('clGraphConnectionWarnings', () {
    test('minimi mancanti', () {
      final w = clGraphConnectionWarnings([_trigger, _action, _end, _free], const []);
      expect(w['T'], ['Manca il collegamento in uscita']);
      expect(w['A'], ['Manca il collegamento in ingresso']);
      expect(w['E'], ['Manca il collegamento in ingresso']);
      expect(w.containsKey('F'), isFalse); // senza regole nessun avviso
    });

    test('grafo completo e valido: nessun avviso', () {
      expect(clGraphConnectionWarnings([_trigger, _action, _end], [_e('T', 'A'), _e('A', 'E')]), isEmpty);
    });

    test('archi esistenti che violano tipi e massimi', () {
      final w = clGraphConnectionWarnings(
        [_trigger, _action, _end, _free],
        [_e('T', 'A'), _e('T', 'E'), _e('F', 'A')],
      );
      expect(w['T'], ['Troppe uscite: 2 (massimo 1)', 'Uscita non ammessa verso «Fine»']);
      expect(w['A'], ['Ingresso non ammesso da «Libero»']);
      expect(w.containsKey('E'), isFalse);
    });

    test('minimo maggiore di uno', () {
      const cond = CLGraphNode(id: 'C', type: 'condition', title: 'Se', connectionRules: CLGraphConnectionRules(minOutputs: 2, maxOutputs: 2));
      expect(clGraphConnectionWarnings([cond, _action], [_e('C', 'A')])['C'], ['Servono almeno 2 uscite (ora 1)']);
    });
  });

  test('definitionProblem delle regole', () {
    expect(const CLGraphConnectionRules(minInputs: 2, maxInputs: 1).definitionProblem, isNotNull);
    expect(const CLGraphConnectionRules(inputTypes: {}, minInputs: 1).definitionProblem, isNotNull);
    expect(_trigger.connectionRules.definitionProblem, isNull);
    expect(const CLGraphConnectionRules(inputTypes: {}).acceptsInputs, isFalse);
    expect(const CLGraphConnectionRules(maxOutputs: 0).acceptsOutputs, isFalse);
    expect(CLGraphConnectionRules.any.acceptsInputs, isTrue);
  });
}
