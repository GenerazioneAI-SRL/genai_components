/// Italian-locale formatting helpers (§3, §11, §13.4).
///
/// All numeric output uses comma `,` as decimal separator and dot `.` as
/// thousands separator. Dates use `dd/MM/yyyy`.
library;

class GenaiFormatters {
  GenaiFormatters._();

  static const _months = [
    'gennaio',
    'febbraio',
    'marzo',
    'aprile',
    'maggio',
    'giugno',
    'luglio',
    'agosto',
    'settembre',
    'ottobre',
    'novembre',
    'dicembre',
  ];

  static const _monthsShort = [
    'gen',
    'feb',
    'mar',
    'apr',
    'mag',
    'giu',
    'lug',
    'ago',
    'set',
    'ott',
    'nov',
    'dic',
  ];

  // ───────────────────────── numbers ─────────────────────────

  /// Formats [value] using IT locale (thousands `.`, decimals `,`).
  static String number(num value, {int decimals = 0}) {
    final fixed = value.toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final intPart = parts[0];
    final isNeg = intPart.startsWith('-');
    final digits = isNeg ? intPart.substring(1) : intPart;
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
      buf.write(digits[i]);
    }
    final intFmt = isNeg ? '-${buf.toString()}' : buf.toString();
    return parts.length == 2 ? '$intFmt,${parts[1]}' : intFmt;
  }

  /// `'1.234,56 €'` (default) or `'€ 1.234,56'` if [symbolBefore].
  static String currency(num value, {int decimals = 2, String symbol = '€', bool symbolBefore = false}) {
    final n = number(value, decimals: decimals);
    return symbolBefore ? '$symbol $n' : '$n $symbol';
  }

  /// `'+12,3%'` / `'-5,0%'`. [showSign] forces leading `+`.
  static String percent(num value, {int decimals = 1, bool showSign = true}) {
    final n = number(value, decimals: decimals);
    if (!showSign) return '$n%';
    if (value > 0) return '+$n%';
    return '$n%';
  }

  /// `'1,2 K'`, `'3,4 M'`, `'5,6 Mld'` for compact display.
  static String compactNumber(num value, {int decimals = 1}) {
    final abs = value.abs();
    if (abs >= 1e9) return '${number(value / 1e9, decimals: decimals)} Mld';
    if (abs >= 1e6) return '${number(value / 1e6, decimals: decimals)} M';
    if (abs >= 1e3) return '${number(value / 1e3, decimals: decimals)} K';
    return number(value, decimals: 0);
  }

  /// `'1,2 KB'`, `'3,4 MB'` …
  static String fileSize(int bytes, {int decimals = 1}) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var v = bytes.toDouble();
    var u = 0;
    while (v >= 1024 && u < units.length - 1) {
      v /= 1024;
      u++;
    }
    return '${number(v, decimals: u == 0 ? 0 : decimals)} ${units[u]}';
  }

  // ───────────────────────── dates ─────────────────────────

  static String _pad(int n) => n.toString().padLeft(2, '0');

  /// `'05/03/2026'`.
  static String date(DateTime d) => '${_pad(d.day)}/${_pad(d.month)}/${d.year}';

  /// `'05/03/2026 14:30'`.
  static String dateTime(DateTime d) => '${date(d)} ${_pad(d.hour)}:${_pad(d.minute)}';

  /// `'14:30'`.
  static String time(DateTime d) => '${_pad(d.hour)}:${_pad(d.minute)}';

  /// `'5 marzo 2026'`.
  static String dateLong(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

  /// `'5 mar 2026'`.
  static String dateShort(DateTime d) => '${d.day} ${_monthsShort[d.month - 1]} ${d.year}';

  /// `'gennaio 2026'`.
  static String monthYear(DateTime d) => '${_months[d.month - 1]} ${d.year}';

  /// `'ora'`, `'5 min fa'`, `'2 h fa'`, `'3 g fa'`, then date.
  static String relative(DateTime t, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final diff = n.difference(t);
    if (diff.isNegative) return 'tra poco';
    if (diff.inMinutes < 1) return 'ora';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min fa';
    if (diff.inHours < 24) return '${diff.inHours} h fa';
    if (diff.inDays < 7) return '${diff.inDays} g fa';
    return date(t);
  }

  // ───────────────────────── strings ─────────────────────────

  /// Initials: `'Mario Rossi'` → `'MR'`.
  static String initials(String fullName, {int max = 2}) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    final letters = parts.where((p) => p.isNotEmpty).map((p) => p[0].toUpperCase()).take(max).join();
    return letters;
  }

  /// Truncates [text] adding `…` (or [ellipsis]) when over [max].
  static String truncate(String text, int max, {String ellipsis = '…'}) {
    if (text.length <= max) return text;
    return text.substring(0, max) + ellipsis;
  }
}
