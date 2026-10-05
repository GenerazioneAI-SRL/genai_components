import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/widgets/paged_datatable/paged_datatable.dart';

/// Le colonne devono stare **nello schermo**.
///
/// Ogni colonna è larga `spazio disponibile × sizeFactor`: se la somma dei
/// fattori supera 1, la riga esce dalla tabella e compare lo scroll orizzontale.
/// Sull'Elenco Presenze dell'admin la somma era arrivata a **1,34** senza che
/// nessuno se ne accorgesse — in release scorreva e basta, e in debug saltava
/// un `assert`: il peggio dei due mondi.
///
/// Questi test fissano le tre regole del rimedio: si rimpicciolisce per stare
/// dentro, non si allarga mai chi già ci sta, e non si scende sotto la soglia
/// oltre cui una colonna non dice più niente.
Widget _tabella({required List<double> fattori, double width = 1200}) {
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
            for (var i = 0; i < fattori.length; i++)
              TableColumn<String>(
                title: Text('C$i'),
                sizeFactor: fattori[i],
                cellBuilder: (row) => Text('$row-$i'),
              ),
          ],
          fetchPage: ({int? page, int? perPage, Map<String, dynamic>? searchBy, Map<String, dynamic>? orderBy}) async =>
              (['Anna', 'Bruno'], null),
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

/// La somma delle larghezze delle intestazioni: se supera la larghezza della
/// tabella, l'utente deve scorrere per vedere l'ultima colonna.
double _larghezzaIntestazioni(WidgetTester tester, int colonne) {
  var totale = 0.0;
  for (var i = 0; i < colonne; i++) {
    final box = tester.renderObject<RenderBox>(
      find.ancestor(of: find.text('C$i'), matching: find.byType(SizedBox)).first,
    );
    totale += box.size.width;
  }
  return totale;
}

void main() {
  testWidgets('somma 1,34: le colonne rientrano invece di uscire dallo schermo', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // Gli stessi fattori dell'Elenco Presenze, che sommavano 1,34.
    await tester.pumpWidget(_tabella(
      fattori: const [0.1, 0.12, 0.18, 0.12, 0.1, 0.14, 0.14, 0.08, 0.08, 0.08, 0.08, 0.06, 0.06],
    ));
    await _settle(tester);

    // Tutte e tredici hanno un'intestazione visibile: nessuna è finita fuori.
    for (var i = 0; i < 13; i++) {
      expect(find.text('C$i'), findsOneWidget, reason: 'colonna $i');
    }
    expect(_larghezzaIntestazioni(tester, 13), lessThanOrEqualTo(1200));
  });

  testWidgets('una tabella che già ci sta non viene allargata', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // Somma 0,6: resta 0,6. Allargarla cambierebbe l'aspetto di pagine che
    // nessuno ha chiesto di toccare.
    await tester.pumpWidget(_tabella(fattori: const [0.2, 0.2, 0.2]));
    await _settle(tester);

    final larghezza = _larghezzaIntestazioni(tester, 3);
    expect(larghezza, lessThan(1200 * 0.75));
  });

  testWidgets('la proporzione fra le colonne resta quella scritta', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // Rimpicciolire tutte allo stesso modo: la colonna doppia resta doppia.
    await tester.pumpWidget(_tabella(fattori: const [0.8, 0.4]));
    await _settle(tester);

    final prima = tester.renderObject<RenderBox>(
      find.ancestor(of: find.text('C0'), matching: find.byType(SizedBox)).first,
    );
    final seconda = tester.renderObject<RenderBox>(
      find.ancestor(of: find.text('C1'), matching: find.byType(SizedBox)).first,
    );

    expect(prima.size.width / seconda.size.width, closeTo(2, 0.05));
  });
}
