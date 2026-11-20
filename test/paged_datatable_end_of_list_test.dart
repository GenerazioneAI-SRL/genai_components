import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/utils/models/pagination.model.dart';
import 'package:genai_components/widgets/paged_datatable/paged_datatable.dart';

/// «Non ci sono altri risultati» in fondo a un elenco a scorrimento infinito: solo dopo aver caricato una seconda
/// pagina. Con due righe che stanno tutte nella prima (le ferie, i documenti di una cartella) non dice niente
/// (audit della 7.0.1 di skillera_emp, K8).
Widget _harness(Future<(List<String>, Pagination?)> Function(int page) fetch) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 1200,
        height: 400,
        child: PagedDataTable<String, String, String>(
          initialPage: '0',
          showShimmerLoading: false,
          infiniteScroll: true,
          fillHeight: true,
          idGetter: (row) => row,
          columns: [
            TableColumn<String>(title: const Text('Nome'), sizeFactor: 1, cellBuilder: (row) => Text(row)),
          ],
          fetchPage: ({int? page, int? perPage, Map<String, dynamic>? searchBy, Map<String, dynamic>? orderBy}) =>
              fetch(page ?? 0),
        ),
      ),
    ),
  );
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  testWidgets('una pagina sola: niente «Non ci sono altri risultati»', (tester) async {
    await tester.pumpWidget(_harness((_) async => (['Anna', 'Bruno'], null)));
    await _settle(tester);

    expect(find.text('Anna'), findsWidgets);
    expect(find.text('Non ci sono altri risultati'), findsNothing);
  });

  testWidgets('dopo la seconda pagina il messaggio di fine lista c\'è', (tester) async {
    final first = [for (var i = 0; i < 30; i++) 'Riga $i'];
    await tester.pumpWidget(_harness((page) async {
      if (page == 0) return (first, Pagination()..next = 1);
      return (['Ultima'], Pagination());
    }));
    await _settle(tester);
    expect(find.text('Non ci sono altri risultati'), findsNothing);

    // In fondo alla lista la tabella carica la pagina dopo; poi finisce.
    for (var i = 0; i < 6; i++) {
      await tester.drag(find.byType(ListView).first, const Offset(0, -2000));
      await _settle(tester);
    }
    expect(find.text('Ultima'), findsWidgets);
    expect(find.text('Non ci sono altri risultati'), findsOneWidget);
  });
}
