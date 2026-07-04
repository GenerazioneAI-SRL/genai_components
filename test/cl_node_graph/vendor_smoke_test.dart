import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/src/vendor/fl_nodes/fl_nodes.dart';

void main() {
  test('vendored fl_nodes controller instantiates and registers a prototype', () {
    final controller = FlNodesController(appVersion: '0.0.1');
    controller.registerNodePrototype(
      FlNodePrototype(
        idName: 'cl.node',
        displayName: (_) => 'CL Node',
        description: (_) => '',
        portPrototypes: [
          FlGenericPortPrototype(
            idName: 'parent',
            displayName: (_) => 'parent',
            geometricOrientation: FlPortGeometricOrientation.left,
          ),
        ],
        onExecute: (ports, fields, state, forward, put) async => (),
      ),
    );
    expect(controller.nodePrototypes.containsKey('cl.node'), isTrue);
    controller.dispose();
  });
}
