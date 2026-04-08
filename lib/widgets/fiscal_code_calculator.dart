class FiscalCodeCalculator {
  static  String _months = 'ABCDEHLMPRST'.toUpperCase(); // Mesi per codice (A = gennaio, B = febbraio, ...)

  static String _getConsonants(String str) {
    return str.toUpperCase().replaceAll(RegExp('[^BCDFGHJKLMNPQRSTVWXYZ]'), '');
  }

  static String _getVowels(String str) {
    return str.toUpperCase().replaceAll(RegExp('[^AEIOU]'), '');
  }


  static String _extractSurname(String surname) {
    String consonants = _getConsonants(surname);
    if (consonants.length >= 3) return consonants.substring(0, 3);

    String vowels = _getVowels(surname);
    String combined = (consonants + vowels).padRight(3, 'X');
    return combined.substring(0, 3);
  }


  static String _extractName(String name) {
    String consonants = _getConsonants(name);
    if (consonants.length >= 4) {
      return consonants[0] + consonants[2] + consonants[3];
    } else if (consonants.length == 3) {
      return consonants;
    } else {
      String vowels = _getVowels(name);
      String combined = (consonants + vowels).padRight(3, 'X');
      return combined.substring(0, 3);
    }
  }



  // Funzione per ottenere il mese (es. "A" per gennaio, "B" per febbraio, ecc.)
  static String _getMonthCode(DateTime birthDate) {
    return _months[birthDate.month - 1];
  }

  // Funzione per ottenere il giorno (aggiungendo 40 per le donne)
  static String _getDayCode(DateTime birthDate, String gender) {
    int day = birthDate.day;
    if (gender == 'M') {
      return day.toString().padLeft(2, '0');
    } else {
      return (day + 40).toString().padLeft(2, '0');
    }
  }

  // Funzione per generare il codice fiscale
  static String generateFiscalCode({
    required String surname,
    required String firstName,
    required DateTime birthDate,
    required String gender,
    required String cityCode, // Codice catastale della città
  }) {
    // Cognome
    String surnameCode = _extractSurname(surname);

    // Nome
    String nameCode = _extractName(firstName);

    // Anno di nascita (ultime 2 cifre)
    String yearCode = birthDate.year.toString().substring(2, 4);

    // Mese di nascita
    String monthCode = _getMonthCode(birthDate);

    // Giorno di nascita
    String dayCode = _getDayCode(birthDate, gender);

    // Codice fiscale base
    String baseFiscalCode = surnameCode + nameCode + yearCode + monthCode + dayCode + cityCode;

    // Calcolo del carattere di controllo (qui puoi usare un algoritmo per ottenere il carattere di controllo)
    String controlCharacter = _getControlCharacter(baseFiscalCode);

    return baseFiscalCode + controlCharacter;
  }
  static String _getControlCharacter(String code) {
    const oddMap = {
      '0': 1,  '1': 0,  '2': 5,  '3': 7,  '4': 9,  '5': 13, '6': 15, '7': 17, '8': 19, '9': 21,
      'A': 1,  'B': 0,  'C': 5,  'D': 7,  'E': 9,  'F': 13, 'G': 15, 'H': 17, 'I': 19, 'J': 21,
      'K': 2,  'L': 4,  'M': 18, 'N': 20, 'O': 11, 'P': 3,  'Q': 6,  'R': 8,  'S': 12, 'T': 14,
      'U': 16, 'V': 10, 'W': 22, 'X': 25, 'Y': 24, 'Z': 23,
    };

    const evenMap = {
      '0': 0,  '1': 1,  '2': 2,  '3': 3,  '4': 4,  '5': 5,  '6': 6,  '7': 7,  '8': 8,  '9': 9,
      'A': 0,  'B': 1,  'C': 2,  'D': 3,  'E': 4,  'F': 5,  'G': 6,  'H': 7,  'I': 8,  'J': 9,
      'K': 10, 'L': 11, 'M': 12, 'N': 13, 'O': 14, 'P': 15, 'Q': 16, 'R': 17, 'S': 18, 'T': 19,
      'U': 20, 'V': 21, 'W': 22, 'X': 23, 'Y': 24, 'Z': 25,
    };

    const checkChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    int sum = 0;

    for (int i = 0; i < code.length; i++) {
      final c = code[i].toUpperCase();
      if ((i + 1) % 2 == 0) {
        sum += evenMap[c] ?? 0;
      } else {
        sum += oddMap[c] ?? 0;
      }
    }


    return checkChars[sum % 26];
  }


}
