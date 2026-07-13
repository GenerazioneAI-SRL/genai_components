import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ═══════════════════════════════════════════════════════════════════════════
// CLDateFieldType – Tipo di campo data/ora inline
// ═══════════════════════════════════════════════════════════════════════════

enum CLDateFieldType {
  /// Solo data: dd/MM/yyyy
  date,

  /// Data e ora: dd/MM/yyyy HH:mm
  dateTime,

  /// Solo ora: HH:mm
  time,

  /// Mese e anno: MM/yyyy
  month,

  /// Solo anno: yyyy
  year,
}

extension CLDateFieldTypeX on CLDateFieldType {
  /// Maschera di formattazione (`#` = digit).
  String get mask => switch (this) {
        CLDateFieldType.date => '##/##/####',
        CLDateFieldType.dateTime => '##/##/#### ##:##',
        CLDateFieldType.time => '##:##',
        CLDateFieldType.month => '##/####',
        CLDateFieldType.year => '####',
      };

  /// Testo suggerimento visualizzato nel campo vuoto.
  String get hint => switch (this) {
        CLDateFieldType.date => 'gg/mm/aaaa',
        CLDateFieldType.dateTime => 'gg/mm/aaaa hh:mm',
        CLDateFieldType.time => 'hh:mm',
        CLDateFieldType.month => 'mm/aaaa',
        CLDateFieldType.year => 'aaaa',
      };

  /// Numero massimo di cifre (senza separatori).
  int get maxDigits => mask.replaceAll(RegExp(r'[^#]'), '').length;

  /// Lunghezza attesa del testo formattato completo.
  int get expectedLength => mask.length;

  // ─── Formattazione ──────────────────────────────────────────────────

  /// Formatta un [DateTime] nella rappresentazione del tipo.
  String format(DateTime dt) => switch (this) {
        CLDateFieldType.date =>
          '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year.toString().padLeft(4, '0')}',
        CLDateFieldType.dateTime =>
          '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year.toString().padLeft(4, '0')}'
              ' ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}',
        CLDateFieldType.time =>
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}',
        CLDateFieldType.month =>
          '${dt.month.toString().padLeft(2, '0')}/${dt.year.toString().padLeft(4, '0')}',
        CLDateFieldType.year => dt.year.toString().padLeft(4, '0'),
      };

  /// Formatta un [TimeOfDay] (solo per [CLDateFieldType.time]).
  String formatTimeOfDay(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  // ─── Parsing ────────────────────────────────────────────────────────

  /// Tenta il parse del [text] formattato in un [DateTime].
  /// Ritorna `null` se il formato non è completo o non valido.
  DateTime? parse(String text) {
    if (text.length != expectedLength) return null;
    try {
      switch (this) {
        case CLDateFieldType.date:
          final p = text.split('/');
          if (p.length != 3) return null;
          return _validDate(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));

        case CLDateFieldType.dateTime:
          final dtParts = text.split(' ');
          if (dtParts.length != 2) return null;
          final dp = dtParts[0].split('/');
          final tp = dtParts[1].split(':');
          if (dp.length != 3 || tp.length != 2) return null;
          return _validDateTime(
            int.parse(dp[2]), int.parse(dp[1]), int.parse(dp[0]),
            int.parse(tp[0]), int.parse(tp[1]),
          );

        case CLDateFieldType.time:
          final p = text.split(':');
          if (p.length != 2) return null;
          final h = int.parse(p[0]);
          final m = int.parse(p[1]);
          if (h < 0 || h > 23 || m < 0 || m > 59) return null;
          final now = DateTime.now();
          return DateTime(now.year, now.month, now.day, h, m);

        case CLDateFieldType.month:
          final p = text.split('/');
          if (p.length != 2) return null;
          final month = int.parse(p[0]);
          final year = int.parse(p[1]);
          if (month < 1 || month > 12 || year < 1) return null;
          return DateTime(year, month);

        case CLDateFieldType.year:
          final year = int.parse(text);
          if (year < 1) return null;
          return DateTime(year);
      }
    } catch (_) {
      return null;
    }
  }

  /// Parse del testo in [TimeOfDay] (solo per [CLDateFieldType.time]).
  TimeOfDay? parseTime(String text) {
    if (this != CLDateFieldType.time || text.length != 5) return null;
    try {
      final p = text.split(':');
      if (p.length != 2) return null;
      final h = int.parse(p[0]);
      final m = int.parse(p[1]);
      if (h < 0 || h > 23 || m < 0 || m > 59) return null;
      return TimeOfDay(hour: h, minute: m);
    } catch (_) {
      return null;
    }
  }

  // ─── Helpers interni ────────────────────────────────────────────────

  static DateTime? _validDate(int year, int month, int day) {
    if (month < 1 || month > 12 || day < 1 || day > 31 || year < 1) return null;
    final dt = DateTime(year, month, day);
    // Controlla overflow (es. 31/02 → 03/03)
    if (dt.year != year || dt.month != month || dt.day != day) return null;
    return dt;
  }

  static DateTime? _validDateTime(int year, int month, int day, int hour, int minute) {
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    final dt = _validDate(year, month, day);
    if (dt == null) return null;
    return DateTime(year, month, day, hour, minute);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DateMaskFormatter – TextInputFormatter con maschera e validazione per-digit
// ═══════════════════════════════════════════════════════════════════════════

class DateMaskFormatter extends TextInputFormatter {
  final CLDateFieldType type;
  late final String _mask;
  late final int _maxDigits;

  DateMaskFormatter(this.type) {
    _mask = type.mask;
    _maxDigits = type.maxDigits;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final oldDigits = oldValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final newDigits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (newDigits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // ── 1. Valida e auto-padda le cifre ──
    final validated = _validateAndPadDigits(newDigits.split(''));

    // ── 2. Limita al numero massimo di cifre ──
    final limited = validated.length > _maxDigits
        ? validated.sublist(0, _maxDigits)
        : validated;

    // ── 3. Applica la maschera ──
    final buffer = StringBuffer();
    int di = 0;
    for (int mi = 0; mi < _mask.length && di < limited.length; mi++) {
      if (_mask[mi] == '#') {
        buffer.write(limited[di++]);
      } else {
        buffer.write(_mask[mi]);
      }
    }

    String result = buffer.toString();

    // ── 4. Auto-appendi separatore se l'utente sta digitando ──
    final isTyping = newDigits.length > oldDigits.length;
    if (isTyping && di < _maxDigits) {
      int nextPos = result.length;
      while (nextPos < _mask.length && _mask[nextPos] != '#') {
        result += _mask[nextPos];
        nextPos++;
      }
    }

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }

  // ─── Validazione per-digit con auto-padding ────────────────────────
  //
  // Per ogni segmento a 2 cifre (giorno, mese, ora, minuto) applica:
  //
  //  • Auto-pad: se la prima cifra digitata è impossibile come "decina"
  //    (es. "5" per il giorno, "3" per l'ora) viene interpretata come
  //    unità e prefissata con "0" → l'utente scrive "5" e ottiene "05/".
  //
  //  • Clamping seconda cifra: se la prima cifra è il max consentito,
  //    la seconda viene limitata (es. ora "2" + "6" → "23").
  //
  // Soglie auto-pad:
  //   Giorno  → >3  (valori 01-31, "4"→"04")
  //   Mese    → >1  (valori 01-12, "2"→"02")
  //   Ora     → >2  (valori 00-23, "3"→"03")
  //   Minuto  → >5  (valori 00-59, "6"→"06")
  //   Anno    → nessun vincolo
  // ────────────────────────────────────────────────────────────────────

  List<String> _validateAndPadDigits(List<String> rawChars) {
    final result = <String>[];
    int i = 0;

    /// Processa un segmento a 2 cifre con auto-pad e clamping.
    void twoDigit(int autopadAbove, int Function(int firstDigit) maxSecond) {
      if (i >= rawChars.length) return;
      final d1 = int.parse(rawChars[i]);

      if (d1 > autopadAbove) {
        // Prima cifra impossibile come decina → auto-pad "0X"
        result.addAll(['0', rawChars[i]]);
        i++;
      } else {
        result.add(rawChars[i]);
        i++;
        if (i < rawChars.length) {
          final d2 = int.parse(rawChars[i]);
          final max = maxSecond(d1);
          result.add(d2 > max ? max.toString() : rawChars[i]);
          i++;
        }
      }
    }

    /// Processa un segmento a 4 cifre (anno) senza vincoli.
    void fourDigit() {
      for (int j = 0; j < 4 && i < rawChars.length; j++) {
        result.add(rawChars[i]);
        i++;
      }
    }

    void day() => twoDigit(3, (d1) => d1 == 3 ? 1 : 9);
    void month() => twoDigit(1, (d1) => d1 == 1 ? 2 : 9);
    void hour() => twoDigit(2, (d1) => d1 == 2 ? 3 : 9);
    void minute() => twoDigit(5, (_) => 9);

    switch (type) {
      case CLDateFieldType.date:
        day(); month(); fourDigit();
      case CLDateFieldType.dateTime:
        day(); month(); fourDigit(); hour(); minute();
      case CLDateFieldType.time:
        hour(); minute();
      case CLDateFieldType.month:
        month(); fourDigit();
      case CLDateFieldType.year:
        fourDigit();
    }

    return result;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CLDateFieldValidators – Validatori form per i campi data/ora inline
// ═══════════════════════════════════════════════════════════════════════════

class CLDateFieldValidators {
  CLDateFieldValidators._();

  /// Ritorna un [FormFieldValidator] per il [CLDateFieldType] specificato.
  /// Valida che il formato sia completo e che il valore sia corretto.
  static FormFieldValidator<String> forType(CLDateFieldType type) {
    return (String? value) {
      // Se vuoto, lascia gestire a Validators.required
      if (value == null || value.isEmpty) return null;

      // Formato incompleto
      if (value.length < type.expectedLength) {
        return _incompleteMessage(type);
      }

      // Valore non valido (es. 31/02, 00/05, ecc.)
      final parsed = type.parse(value);
      if (parsed == null) {
        return _invalidMessage(type);
      }

      return null;
    };
  }

  static String _incompleteMessage(CLDateFieldType type) => switch (type) {
        CLDateFieldType.date => 'Inserisci una data completa (gg/mm/aaaa)',
        CLDateFieldType.dateTime => 'Inserisci data e ora completi (gg/mm/aaaa hh:mm)',
        CLDateFieldType.time => 'Inserisci un orario completo (hh:mm)',
        CLDateFieldType.month => 'Inserisci mese e anno (mm/aaaa)',
        CLDateFieldType.year => 'Inserisci un anno valido (aaaa)',
      };

  static String _invalidMessage(CLDateFieldType type) => switch (type) {
        CLDateFieldType.date => 'Data non valida',
        CLDateFieldType.dateTime => 'Data o orario non valido',
        CLDateFieldType.time => 'Orario non valido',
        CLDateFieldType.month => 'Mese non valido',
        CLDateFieldType.year => 'Anno non valido',
      };
}
