/// Utility condivise dai campi data Gen (mese/anno).
library;

/// Ritorna la lista inclusiva di anni tra [firstYear] e [lastYear].
/// Default: anno corrente ±10.
List<int> genYearRange(int? firstYear, int? lastYear) {
  final now = DateTime.now();
  final first = firstYear ?? now.year - 10;
  final last = lastYear ?? now.year + 10;
  return [for (var y = first; y <= last; y++) y];
}
