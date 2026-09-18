import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/widgets/paged_datatable/paged_datatable.dart';
import 'package:genai_components/utils/models/pagination.model.dart';

/// Il piede della tabella: quante righe dice di avere, e quando mostra i
/// controlli di pagina.
///
/// Le due regole che questi test fissano nascono da una segnalazione: un
/// riepilogo con due righe a schermo scriveva «0 risultati», e una tabella con
/// una riga sola offriva comunque «5 · 25 · 50 · 100» e le frecce avanti e
/// indietro. Le viste che calcolano tutto lato client non hanno una
/// `Pagination` dal backend: il totale, lì, è semplicemente quello che hanno
/// consegnato.

Widget _harness({
  required List<String> rows,
  Pagination? pagination,
  double width = 1200,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: width,
        height: 600,
        child: PagedDataTable<String, String, String>(
          initialPage: '0',
          // Lo shimmer anima all'infinito: con pumpAndSettle il test non
          // tornerebbe mai.
          showShimmerLoading: false,
          idGetter: (row) => row,
          columns: [
            TableColumn<String>(
              title: const Text('Nome'),
              sizeFactor: 1,
              cellBuilder: (row) => Text(row),
            ),
          ],
          fetchPage: ({int? page, int? perPage, Map<String, dynamic>? searchBy, Map<String, dynamic>? orderBy}) async =>
              (rows, pagination),
        ),
      ),
    ),
  );
}

/// La tabella ha animazioni che non si fermano da sole (AnimatedSwitcher del
/// contatore): si avanza a mano invece di aspettare la quiete.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  testWidgets('senza Pagination il totale è il numero di righe consegnate', (tester) async {
    await tester.pumpWidget(_harness(rows: ['Anna', 'Bruno'], pagination: null));
    await _settle(tester);

    // Prima diceva «0 risultati» con due righe ben visibili sopra.
    expect(find.text('1 – 2 di 2'), findsOneWidget);
    expect(find.text('0 risultati'), findsNothing);
  });

  testWidgets('nessuna riga: resta «0 risultati»', (tester) async {
    await tester.pumpWidget(_harness(rows: const [], pagination: null));
    await _settle(tester);

    expect(find.text('0 risultati'), findsOneWidget);
  });

  testWidgets('una pagina sola: niente selettore di dimensione né frecce', (tester) async {
    await tester.pumpWidget(_harness(rows: ['Anna', 'Bruno', 'Carla'], pagination: null));
    await _settle(tester);

    // Il conteggio resta, i controlli spariscono: non c'è niente da sfogliare.
    expect(find.text('1 – 3 di 3'), findsOneWidget);
    expect(find.text('25'), findsNothing);
    expect(find.text('100'), findsNothing);
  });

  testWidgets('più pagine: i controlli tornano', (tester) async {
    final pagination = Pagination()
      ..total = 120
      ..perPage = 25
      ..currentPage = 1
      ..lastPage = 5
      ..next = 2;

    await tester.pumpWidget(_harness(
      rows: List.generate(25, (i) => 'Riga $i'),
      pagination: pagination,
    ));
    await _settle(tester);

    expect(find.text('1 – 25 di 120'), findsOneWidget);
    expect(find.text('100'), findsOneWidget);
  });
}
