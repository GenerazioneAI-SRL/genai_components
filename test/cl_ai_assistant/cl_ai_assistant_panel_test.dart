import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/cl_theme.dart';
import 'package:genai_components/widgets/cl_ai_assistant/flutter_ai_assistant.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shadcn_ui/shadcn_ui.dart' show ShadTheme;

// CLAiAssistant.panel dal 5.15.0 usa CLAiChatView + CLAiChatComposer: senza AiAssistant sopra
// (controller assente) mostra lo stato vuoto e l'invio è spento, come prima.
void main() {
  testWidgets('CLAiAssistant.panel senza AiAssistant: stato vuoto, composer e informativa', (tester) async {
    await tester.pumpWidget(MaterialApp(
      builder: (context, c) => ResponsiveBreakpoints.builder(
        child: c!,
        breakpoints: const [
          Breakpoint(start: 0, end: 800, name: MOBILE),
          Breakpoint(start: 801, end: double.infinity, name: DESKTOP),
        ],
      ),
      home: ShadTheme(
        data: CLTheme.light.toShadTheme(),
        child: const Scaffold(body: SizedBox(width: 380, height: 700, child: CLAiAssistant.panel())),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Ciao'), findsOneWidget);
    expect(find.text('Come posso aiutarti oggi?'), findsOneWidget);
    expect(find.byType(CLAiChatView), findsOneWidget);
    expect(find.byType(CLAiChatComposer), findsOneWidget);
    expect(find.textContaining('GDPR'), findsOneWidget);
  });
}
