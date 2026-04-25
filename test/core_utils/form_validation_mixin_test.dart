import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/core_utils/form_validation_mixin.dart';

void main() {
  group('FormValidationMixin', () {
    testWidgets('validateForm returns true when no validators fail',
        (tester) async {
      late _FormHostState state;
      await tester.pumpWidget(MaterialApp(
        home: _FormHostWidget(
          onState: (s) => state = s,
          fieldValidator: (_) => null,
        ),
      ));
      expect(state.validateForm(), isTrue);
    });

    testWidgets('validateForm returns false when validator fails',
        (tester) async {
      late _FormHostState state;
      await tester.pumpWidget(MaterialApp(
        home: _FormHostWidget(
          onState: (s) => state = s,
          fieldValidator: (_) => 'error',
        ),
      ));
      expect(state.validateForm(), isFalse);
    });

    testWidgets('resetForm clears form fields', (tester) async {
      late _FormHostState state;
      await tester.pumpWidget(MaterialApp(
        home: _FormHostWidget(
          onState: (s) => state = s,
          fieldValidator: (_) => null,
          initialValue: 'seed',
        ),
      ));

      // Type into the field.
      await tester.enterText(find.byType(TextFormField), 'changed');
      await tester.pump();
      expect(find.text('changed'), findsOneWidget);

      // Reset — text falls back to initialValue.
      state.resetForm();
      await tester.pump();
      expect(find.text('seed'), findsOneWidget);
    });

    testWidgets('saveForm invokes onSaved on every field', (tester) async {
      late _FormHostState state;
      String? saved;
      await tester.pumpWidget(MaterialApp(
        home: _FormHostWidget(
          onState: (s) => state = s,
          fieldValidator: (_) => null,
          initialValue: 'value-x',
          onFieldSaved: (v) => saved = v,
        ),
      ));

      state.saveForm();
      expect(saved, 'value-x');
    });
  });
}

class _FormHostWidget extends StatefulWidget {
  final void Function(_FormHostState) onState;
  final String? Function(String?) fieldValidator;
  final String? initialValue;
  final void Function(String?)? onFieldSaved;

  const _FormHostWidget({
    required this.onState,
    required this.fieldValidator,
    this.initialValue,
    this.onFieldSaved,
  });

  @override
  State<_FormHostWidget> createState() => _FormHostState();
}

class _FormHostState extends State<_FormHostWidget> with FormValidationMixin {
  @override
  void initState() {
    super.initState();
    widget.onState(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: TextFormField(
          initialValue: widget.initialValue,
          validator: widget.fieldValidator,
          onSaved: widget.onFieldSaved,
        ),
      ),
    );
  }
}
