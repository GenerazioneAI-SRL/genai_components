import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shadcn_ui/shadcn_ui.dart' show ShadTheme;

// I CL* delegano a Shad (ShadTheme) e CLSoftButton legge ResponsiveBreakpoints: l'harness li fornisce.
Widget _app(Widget child) => MaterialApp(
      theme: ThemeData(brightness: Brightness.light),
      builder: (context, c) => ResponsiveBreakpoints.builder(
        child: c!,
        breakpoints: const [
          Breakpoint(start: 0, end: 800, name: MOBILE),
          Breakpoint(start: 801, end: double.infinity, name: DESKTOP),
        ],
      ),
      home: ShadTheme(
        data: CLTheme.light.toShadTheme(),
        child: Scaffold(body: SizedBox(width: 900, height: 700, child: child)),
      ),
    );

CLAiChatMessage _user(String id, String text, {CLAiChatStatus status = CLAiChatStatus.done}) =>
    CLAiChatMessage(id: id, role: MessageRole.user, text: text, status: status);

CLAiChatMessage _bot(String id, String text) =>
    CLAiChatMessage(id: id, role: MessageRole.assistant, text: text, markdown: true);

void main() {
  group('CLAiChatView — stati dei messaggi', () {
    testWidgets('sending → done: «Invio…» sparisce e la bolla torna piena', (tester) async {
      await tester.pumpWidget(_app(CLAiChatView(messages: [_user('1', 'ciao', status: CLAiChatStatus.sending)])));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Invio…'), findsOneWidget);
      final faded = tester.widget<AnimatedOpacity>(
          find.ancestor(of: find.byKey(const ValueKey('cl-ai-msg-1')), matching: find.byType(AnimatedOpacity)));
      expect(faded.opacity, lessThan(1));

      await tester.pumpWidget(_app(CLAiChatView(messages: [_user('1', 'ciao')])));
      await tester.pumpAndSettle();
      expect(find.text('Invio…'), findsNothing);
      final full = tester.widget<AnimatedOpacity>(
          find.ancestor(of: find.byKey(const ValueKey('cl-ai-msg-1')), matching: find.byType(AnimatedOpacity)));
      expect(full.opacity, 1);
    });

    testWidgets('error: testo di errore e «Riprova» chiama onRetry', (tester) async {
      var retried = 0;
      await tester.pumpWidget(_app(CLAiChatView(messages: [
        CLAiChatMessage(
          id: 'e',
          role: MessageRole.assistant,
          text: 'parziale',
          status: CLAiChatStatus.error,
          errorText: 'Servizio non raggiungibile',
          onRetry: () => retried++,
        ),
      ])));
      await tester.pumpAndSettle();
      expect(find.text('Servizio non raggiungibile'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('cl-ai-msg-e-retry')));
      await tester.pump();
      expect(retried, 1);
    });

    testWidgets('error senza onRetry: niente «Riprova», testo di serie', (tester) async {
      await tester.pumpWidget(_app(CLAiChatView(messages: [_user('u', 'x', status: CLAiChatStatus.error)])));
      await tester.pumpAndSettle();
      expect(find.text('Messaggio non inviato'), findsOneWidget);
      expect(find.byKey(const ValueKey('cl-ai-msg-u-retry')), findsNothing);
    });

    testWidgets('«Modifica» rende il testo modificabile e Salva chiama onEdit', (tester) async {
      String? edited;
      await tester.pumpWidget(_app(CLAiChatView(messages: [
        CLAiChatMessage(id: 'm', role: MessageRole.user, text: 'prima', onEdit: (v) => edited = v),
      ])));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('cl-ai-msg-m-edit-start')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('cl-ai-msg-m-edit')), 'dopo');
      await tester.tap(find.byKey(const ValueKey('cl-ai-msg-m-edit-save')));
      await tester.pumpAndSettle();
      expect(edited, 'dopo');
      expect(find.byKey(const ValueKey('cl-ai-msg-m-edit')), findsNothing);
    });

    testWidgets('markdown: grassetto senza asterischi; tool e system hanno la loro riga', (tester) async {
      await tester.pumpWidget(_app(CLAiChatView(messages: [
        _bot('b', 'Risultato **importante**\n\n- uno\n- due'),
        const CLAiChatMessage(id: 't', role: MessageRole.tool, text: 'Cerco nei ticket'),
        const CLAiChatMessage(id: 's', role: MessageRole.system, text: 'Conversazione ripresa'),
      ])));
      await tester.pumpAndSettle();
      expect(find.textContaining('importante', findRichText: true), findsOneWidget);
      expect(find.textContaining('**', findRichText: true), findsNothing);
      expect(find.text('uno', findRichText: true), findsOneWidget);
      expect(find.text('Cerco nei ticket'), findsOneWidget);
      expect(find.text('Conversazione ripresa'), findsOneWidget);
    });

    testWidgets('footer: la card azione compare sotto la bolla', (tester) async {
      await tester.pumpWidget(_app(CLAiChatView(messages: [
        CLAiChatMessage(
          id: 'a',
          role: MessageRole.assistant,
          text: 'Creo il ticket?',
          footer: Row(children: [TextButton(onPressed: () {}, child: const Text('Conferma'))]),
        ),
      ])));
      await tester.pumpAndSettle();
      expect(find.text('Conferma'), findsOneWidget);
    });
  });

  group('CLAiChatView — citazioni', () {
    testWidgets('[n] nel testo e fonti sotto la bolla sono cliccabili; [n] fuori range resta testo', (tester) async {
      final tapped = <int>[];
      await tester.pumpWidget(_app(CLAiChatView(messages: [
        CLAiChatMessage(
          id: 'c',
          role: MessageRole.assistant,
          text: 'Le ferie si chiedono entro marzo [1], salvo deroghe [2]. Vedi anche [3].',
          markdown: true,
          citations: [
            CLAiCitation(label: 'Regolamento ferie', subtitle: 'pag. 4', onTap: () => tapped.add(1)),
            CLAiCitation(label: 'Accordo 2026', onTap: () => tapped.add(2)),
          ],
        ),
      ])));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('cl-ai-msg-c-cite-1')));
      await tester.tap(find.byKey(const ValueKey('cl-ai-msg-c-cite-2')));
      await tester.tap(find.byKey(const ValueKey('cl-ai-msg-c-source-2')));
      await tester.pump();
      expect(tapped, [1, 2, 2]);
      expect(find.byKey(const ValueKey('cl-ai-msg-c-cite-3')), findsNothing);
      expect(find.textContaining('[3]', findRichText: true), findsOneWidget);
      expect(find.text('Regolamento ferie'), findsOneWidget);
      expect(find.text('pag. 4'), findsOneWidget);
    });

    testWidgets('le citazioni valgono anche senza markdown', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_app(CLAiChatView(messages: [
        CLAiChatMessage(
          id: 'p',
          role: MessageRole.assistant,
          text: 'Testo **semplice** [1]',
          citations: [CLAiCitation(label: 'Fonte', onTap: () => tapped = true)],
        ),
      ])));
      await tester.pumpAndSettle();
      expect(find.textContaining('**semplice**', findRichText: true), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('cl-ai-msg-p-cite-1')));
      expect(tapped, isTrue);
    });
  });

  group('CLAiChatView — composer e scorciatoie', () {
    Future<List<String>> pumpComposer(WidgetTester tester, {bool enterToSend = true}) async {
      final sent = <String>[];
      await tester.pumpWidget(_app(CLAiChatView(messages: const [], onSend: sent.add, enterToSend: enterToSend)));
      await tester.pumpAndSettle();
      return sent;
    }

    final field = find.byKey(const ValueKey('cl-ai-composer-field'));

    testWidgets('Invio invia e svuota il campo', (tester) async {
      final sent = await pumpComposer(tester);
      await tester.enterText(field, '  ciao  ');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(sent, ['ciao']);
      expect(tester.widget<TextField>(field).controller!.text, isEmpty);
    });

    testWidgets('Maiusc+Invio non invia (va a capo)', (tester) async {
      final sent = await pumpComposer(tester);
      await tester.enterText(field, 'riga uno');
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(sent, isEmpty);
      expect(tester.widget<TextField>(field).controller!.text, 'riga uno');
    });

    testWidgets('⌘Invio e Ctrl+Invio inviano anche con enterToSend false', (tester) async {
      final sent = await pumpComposer(tester, enterToSend: false);
      await tester.enterText(field, 'uno');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(sent, isEmpty);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      await tester.pump();
      expect(sent, ['uno']);

      await tester.enterText(field, 'due');
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
      expect(sent, ['uno', 'due']);
    });

    testWidgets('campo vuoto: Invio non invia', (tester) async {
      final sent = await pumpComposer(tester);
      await tester.enterText(field, '   ');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(sent, isEmpty);
    });

    testWidgets('mentre pensa: «Stop» chiama onStop e Invio non invia', (tester) async {
      var stopped = 0;
      final sent = <String>[];
      await tester.pumpWidget(_app(CLAiChatView(
        messages: [_user('1', 'domanda')],
        isThinking: true,
        thinkingLabel: 'Cerco nei ticket…',
        thinkingSteps: const ['Letto il progetto', 'Cerco i ticket aperti'],
        onSend: sent.add,
        onStop: () => stopped++,
      )));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Cerco nei ticket…'), findsOneWidget);
      expect(find.text('Letto il progetto'), findsOneWidget);
      expect(find.text('Cerco i ticket aperti'), findsOneWidget);

      await tester.enterText(field, 'altro');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.tap(find.byKey(const ValueKey('cl-ai-composer-stop')));
      await tester.pump();
      expect(sent, isEmpty);
      expect(stopped, 1);
    });

    testWidgets('stato vuoto: il suggerimento invia il suo messaggio', (tester) async {
      final sent = <String>[];
      await tester.pumpWidget(_app(CLAiChatView(
        messages: const [],
        emptyTitle: 'Ciao Francesco',
        suggestions: const [CLAiChatSuggestion(label: 'I miei ticket', message: 'Quali ticket ho aperti?')],
        onSend: sent.add,
      )));
      await tester.pumpAndSettle();
      expect(find.text('Ciao Francesco'), findsOneWidget);
      await tester.tap(find.text('I miei ticket'));
      await tester.pump();
      expect(sent, ['Quali ticket ho aperti?']);
    });
  });

  group('CLAiChatView — scroll automatico', () {
    List<CLAiChatMessage> many(int n) =>
        [for (var i = 0; i < n; i++) _bot('$i', 'Messaggio numero $i\n\nsu due righe')];

    testWidgets('in fondo segue i messaggi nuovi; scrollato su resta fermo', (tester) async {
      var msgs = many(30);
      await tester.pumpWidget(_app(CLAiChatView(messages: msgs)));
      await tester.pumpAndSettle();
      final list = find.byType(Scrollable).first;
      ScrollPosition pos() => tester.state<ScrollableState>(list).position;
      expect(pos().pixels, pos().maxScrollExtent);

      // Arriva una risposta mentre è in fondo → segue.
      msgs = [...msgs, _bot('n1', 'nuova')];
      await tester.pumpWidget(_app(CLAiChatView(messages: msgs)));
      await tester.pumpAndSettle();
      expect(pos().pixels, pos().maxScrollExtent);

      // L'utente scrolla su: una risposta nuova non lo sposta, compare «Vai in fondo».
      await tester.drag(list, const Offset(0, 600));
      await tester.pumpAndSettle();
      final before = pos().pixels;
      expect(before, lessThan(pos().maxScrollExtent));
      msgs = [...msgs, _bot('n2', 'altra')];
      await tester.pumpWidget(_app(CLAiChatView(messages: msgs)));
      await tester.pumpAndSettle();
      expect(pos().pixels, before);
      expect(find.byKey(const ValueKey('cl-ai-scroll-bottom')), findsOneWidget);

      // L'utente invia: torna in fondo.
      msgs = [...msgs, _user('u1', 'mia domanda')];
      await tester.pumpWidget(_app(CLAiChatView(messages: msgs)));
      await tester.pumpAndSettle();
      expect(pos().pixels, pos().maxScrollExtent);
      expect(find.byKey(const ValueKey('cl-ai-scroll-bottom')), findsNothing);
    });
  });

  group('CLAiConversationList', () {
    testWidgets('seleziona, nuova, archivia, elimina', (tester) async {
      final log = <String>[];
      final now = DateTime.now();
      await tester.pumpWidget(_app(CLAiConversationList(
        title: 'Conversazioni',
        selectedId: 'b',
        items: [
          CLAiConversationItem(id: 'a', title: 'Ferie di agosto', updatedAt: now),
          CLAiConversationItem(id: 'b', title: 'Ticket aperti', updatedAt: now.subtract(const Duration(days: 1))),
          const CLAiConversationItem(id: 'c', title: 'Sprint 12', subtitle: 'ultima: «ok»'),
        ],
        onSelect: (id) => log.add('select:$id'),
        onNew: () => log.add('new'),
        onArchive: (id) => log.add('archive:$id'),
        onDelete: (id) => log.add('delete:$id'),
      )));
      await tester.pumpAndSettle();
      expect(find.text('Conversazioni'), findsOneWidget);
      expect(find.text('oggi'), findsOneWidget);
      expect(find.text('ieri'), findsOneWidget);
      expect(find.text('ultima: «ok»'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('cl-ai-conv-a')));
      await tester.tap(find.byKey(const ValueKey('cl-ai-conv-new')));
      await tester.tap(find.byKey(const ValueKey('cl-ai-conv-c-archive')));
      await tester.tap(find.byKey(const ValueKey('cl-ai-conv-b-delete')));
      await tester.pump();
      expect(log, ['select:a', 'new', 'archive:c', 'delete:b']);

      final selectedTitle = tester.widget<Text>(find.text('Ticket aperti'));
      expect(selectedTitle.style!.fontWeight, FontWeight.w600);
    });

    testWidgets('vuota e in caricamento', (tester) async {
      await tester.pumpWidget(_app(const CLAiConversationList(items: [])));
      expect(find.text('Nessuna conversazione salvata'), findsOneWidget);
      await tester.pumpWidget(_app(const CLAiConversationList(items: [], loading: true)));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    test('relativeDate', () {
      final now = DateTime(2026, 10, 15, 10);
      expect(CLAiConversationList.relativeDate(DateTime(2026, 10, 15, 1), now: now), 'oggi');
      expect(CLAiConversationList.relativeDate(DateTime(2026, 10, 14, 23), now: now), 'ieri');
      expect(CLAiConversationList.relativeDate(DateTime(2026, 10, 12), now: now), '3g fa');
      expect(CLAiConversationList.relativeDate(DateTime(2026, 9, 2), now: now), '02/09');
    });
  });
}
