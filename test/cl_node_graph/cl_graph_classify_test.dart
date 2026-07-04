import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/src/widgets/cl_node_graph/cl_graph_layout.dart';

void main() {
  test('containment: children(out) -> parent(in) is containment, source is from', () {
    final r = classifyGraphLink('children', 'parent');
    expect(r.role, CLGraphLinkRole.containment);
    expect(r.sourceIsFrom, isTrue);
  });

  test('containment reversed: parent(in) -> children(out), source is to', () {
    final r = classifyGraphLink('parent', 'children');
    expect(r.role, CLGraphLinkRole.containment);
    expect(r.sourceIsFrom, isFalse);
  });

  test('link: unlocks(out) -> requires(in) is link, source(prereq) is from', () {
    final r = classifyGraphLink('unlocks', 'requires');
    expect(r.role, CLGraphLinkRole.link);
    expect(r.sourceIsFrom, isTrue);
  });

  test('mixed ports are invalid', () {
    expect(classifyGraphLink('children', 'requires').role, CLGraphLinkRole.invalid);
    expect(classifyGraphLink('parent', 'unlocks').role, CLGraphLinkRole.invalid);
    expect(classifyGraphLink('parent', 'parent').role, CLGraphLinkRole.invalid);
  });
}
