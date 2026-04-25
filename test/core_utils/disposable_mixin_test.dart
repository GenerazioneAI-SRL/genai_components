import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/core_utils/disposable_mixin.dart';

void main() {
  group('DisposableMixin', () {
    testWidgets('disposes tracked controllers/focusNodes/timers on State.dispose',
        (tester) async {
      late TextEditingController controller;
      late FocusNode focusNode;
      late Timer timer;

      await tester.pumpWidget(
        MaterialApp(
          home: _DisposableHostWidget(
            onInit: (state) {
              controller = state.createController(text: 'hello');
              focusNode = state.createFocusNode();
              timer = state.trackTimer(Timer(const Duration(seconds: 60), () {}));
            },
          ),
        ),
      );

      expect(controller.text, 'hello');
      expect(timer.isActive, isTrue);
      // FocusNode is alive — assert no throw on a basic accessor.
      expect(focusNode.hasFocus, isFalse);

      // Replace widget to trigger dispose.
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      // After dispose, mutating controller throws (already disposed).
      expect(() => controller.text = 'x', throwsFlutterError);
      // Timer cancelled.
      expect(timer.isActive, isFalse);
    });

    testWidgets('cancels tracked stream subscriptions on dispose',
        (tester) async {
      var cancelled = false;
      final controllerStream = StreamController<int>.broadcast(
        onCancel: () => cancelled = true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: _DisposableHostWidget(
            onInit: (state) {
              state.trackSubscription(controllerStream.stream.listen((_) {}));
            },
          ),
        ),
      );

      expect(cancelled, isFalse);
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();
      expect(cancelled, isTrue);
      await controllerStream.close();
    });
  });
}

class _DisposableHostWidget extends StatefulWidget {
  final void Function(_DisposableHostState) onInit;
  const _DisposableHostWidget({required this.onInit});

  @override
  State<_DisposableHostWidget> createState() => _DisposableHostState();
}

class _DisposableHostState extends State<_DisposableHostWidget>
    with DisposableMixin {
  @override
  void initState() {
    super.initState();
    widget.onInit(this);
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}
