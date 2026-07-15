/// Model del modulo Users.
class User {
  const User(this.id, this.name, this.email, this.role, this.codiceFiscale);

  final int id;
  final String name;
  final String email;
  final String role;
  final String codiceFiscale;

  /// Iniziali per l'avatar (es. "Davide Sgravo" → "DS").
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      final p = parts.first;
      return (p.length >= 2 ? p.substring(0, 2) : p).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

const _firstNames = [
  'Davide', 'Toby', 'Jackson', 'Hally', 'Sofia', 'Kenneth', 'Marco', 'Giulia',
  'Luca', 'Elena', 'Andrea', 'Chiara', 'Matteo', 'Sara', 'Alessandro', 'Martina',
];
const _lastNames = [
  'Sgravo', 'Belhome', 'Lee', 'Gray', 'Davis', 'Thompson', 'Rossi', 'Bianchi',
  'Conti', 'Greco', 'Bruno', 'Gallo', 'Costa', 'Fontana', 'Moretti', 'Rizzo',
];
const _roles = ['Admin', 'Viewer', 'Developer'];

/// Seed demo: 50 voci generate deterministicamente (cicli su nome/cognome/ruolo).
final List<User> demoUsers = List.generate(50, (i) {
  final first = _firstNames[i % _firstNames.length];
  final last = _lastNames[(i * 7) % _lastNames.length];
  final role = _roles[i % _roles.length];
  final handle = '${first.toLowerCase()}.${last.toLowerCase()}';
  return User(i + 1, '$first $last', '$handle@example.com', role, _fakeCf(first, last, i));
});

/// Codice fiscale demo (finto ma plausibile: 16 char nel formato reale),
/// generato deterministicamente da nome/cognome/indice.
String _fakeCf(String first, String last, int i) {
  String triplet(String s) {
    final up = s.toUpperCase().replaceAll(RegExp('[^A-Z]'), '');
    final cons = up.replaceAll(RegExp('[AEIOU]'), '');
    final vow = up.replaceAll(RegExp('[^AEIOU]'), '');
    return '$cons${vow}XXX'.substring(0, 3);
  }

  const months = 'ABCDEHLMPRST'; // codifica mese CF (gen→A … dic→T)
  const alpha = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  final year = (70 + i % 30).toString().padLeft(2, '0');
  final month = months[i % 12];
  final day = (1 + i % 28).toString().padLeft(2, '0');
  const belfiore = 'H501'; // Roma
  final check = alpha[i % 26];
  return '${triplet(last)}${triplet(first)}$year$month$day$belfiore$check';
}
