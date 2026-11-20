
import '../src/i18n/l10n.dart';

class Validators {
  // Validator per controllare se il campo non è vuoto
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return clL10n.form.validation.required;
    }
    return null;
  }

  // Validator per controllare la lunghezza minima
  static String? minLength(String? value, int min) {
    if (value != null && value.length < min) {
      return clL10n.form.validation.minLength(min: min);
    }
    return null;
  }

  // Validator per email valida
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Email non obbligatoria
    }
    // Ancorata (^...$) → niente coda spuria; domini con sottodomini e hyphen.
    String pattern = r"^[\w.!#$%&'*+/=?^_`{|}~-]+@"
        r"[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$";
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return clL10n.form.validation.email;
    }
    return null;
  }
  // Validator per una password forte (almeno un carattere maiuscolo, un numero e un simbolo)
  static String? strongPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return clL10n.form.validation.passwordEmpty;
    }

    // Min 8 caratteri, almeno una minuscola, una maiuscola, un numero e un simbolo.
    String pattern =
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return clL10n.form.validation.passwordWeak;
    }

    return null;
  }

}
