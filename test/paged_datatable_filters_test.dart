import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/utils/models/pagination.model.dart';
import 'package:genai_components/widgets/paged_datatable/paged_datatable.dart';

/// Filtrare per intervallo: `from` e `to` vanno impostati **insieme**.
///
/// Con due `setFilter` separati partono due caricamenti, e il primo usa un
/// intervallo a metà (estremo nuovo + estremo vecchio). Se quella risposta
/// arriva per ultima, a schermo restano righe che non corrispondono al filtro —
/// ed è esattamente il difetto visto sulla striscia dei giorni delle presenze.
void main() {
  late List<Map<String, dynamic>> fetches;
  late PagedDataTableController<String, String, String> controller;

  Widget harness() {
    fetches = [];
    controller = PagedDataTableController<String, String, String>();
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 1200,
          height: 600,
          child: PagedDataTable<String, String, String>(
            initialPage: '0',
            showShimmerLoading: false,
            // La barra filtri vuole ResponsiveBreakpoints dell'app: qui si
            // testano i filtri impostati da codice, non la barra.
            isFilterBarVisible: false,
            controller: controller,
            idGetter: (row) => row,
            columns: [
              TableColumn<String>(title: const Text('Nome'), sizeFactor: 1, cellBuilder: (r) => Text(r)),
            ],
            extraFilters: [
              CLDateTableFilter(id: 'from', title: 'Dal', isMainFilter: false, chipFormatter: (v) => '$v'),
              CLDateTableFilter(id: 'to', title: 'Al', isMainFilter: false, chipFormatter: (v) => '$v'),
            ],
            fetchPage: ({int? page, int? perPage, Map<String, dynamic>? searchBy, Map<String, dynamic>? orderBy}) async {
              fetches.add(Map<String, dynamic>.from(searchBy ?? {}));
              return (<String>['Anna'], Pagination()..total = 1..perPage = 25..currentPage = 1..lastPage = 1);
            },
          ),
        ),
      ),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('setFilters: un solo caricamento, con entrambi gli estremi', (tester) async {
    await tester.pumpWidget(harness());
    await settle(tester);
    final iniziali = fetches.length;

    final giorno = DateTime(2026, 9, 17);
    controller.setFilters({'from': giorno, 'to': giorno});
    await settle(tester);

    expect(fetches.length - iniziali, 1, reason: 'un solo fetch, non uno per filtro');
    expect(fetches.last['from'], giorno);
    expect(fetches.last['to'], giorno);
  });

  testWidgets('due setFilter separati fanno due caricamenti (il motivo di setFilters)', (tester) async {
    await tester.pumpWidget(harness());
    await settle(tester);
    final iniziali = fetches.length;

    final giorno = DateTime(2026, 9, 17);
    controller.setFilter('from', giorno);
    await settle(tester);
    controller.setFilter('to', giorno);
    await settle(tester);

    expect(fetches.length - iniziali, 2);
    // Il primo dei due è quello pericoloso: intervallo incompleto.
    expect(fetches[iniziali]['to'], isNull);
  });
}
