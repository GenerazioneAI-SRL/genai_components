/// Validators for [GenaiTextField] / [GenaiFormController] (§7.1, §11).
///
/// All return `null` when valid or an italian error message when invalid.
library;

typedef GenaiValidator<T> = String? Function(T value);

class GenaiValidators {
  GenaiValidators._();

  /// Email RFC-light pattern.
  static final RegExp _emailRe = RegExp(r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$');

  static final RegExp _urlRe = RegExp(r'^(https?:\/\/)?([\w\-]+\.)+[\w\-]{2,}(\/[^\s]*)?$', caseSensitive: false);

  static final RegExp _phoneItRe = RegExp(r'^(\+?39)?\s?3\d{2}\s?\d{6,7}$');

  static bool isValidEmail(String value) => value.isNotEmpty && _emailRe.hasMatch(value.trim());

  static bool isValidUrl(String value) => value.isNotEmpty && _urlRe.hasMatch(value.trim());

  static bool isValidPhone(String value) => value.isNotEmpty && _phoneItRe.hasMatch(value.replaceAll(' ', ''));

  // ─────────── factories ───────────

  static GenaiValidator<String?> required({String message = 'Campo obbligatorio'}) => (v) => (v == null || v.trim().isEmpty) ? message : null;

  static GenaiValidator<String?> email({String message = 'Email non valida'}) => (v) {
        if (v == null || v.isEmpty) return null;
        return isValidEmail(v) ? null : message;
      };

  static GenaiValidator<String?> url({String message = 'URL non valido'}) => (v) {
        if (v == null || v.isEmpty) return null;
        return isValidUrl(v) ? null : message;
      };

  static GenaiValidator<String?> phone({String message = 'Numero di telefono non valido'}) => (v) {
        if (v == null || v.isEmpty) return null;
        return isValidPhone(v) ? null : message;
      };

  static GenaiValidator<String?> minLength(int min, {String? message}) =>
      (v) => (v == null || v.length < min) ? (message ?? 'Minimo $min caratteri') : null;

  static GenaiValidator<String?> maxLength(int max, {String? message}) =>
      (v) => (v != null && v.length > max) ? (message ?? 'Massimo $max caratteri') : null;

  static GenaiValidator<String?> pattern(RegExp re, {String message = 'Formato non valido'}) => (v) {
        if (v == null || v.isEmpty) return null;
        return re.hasMatch(v) ? null : message;
      };

  static GenaiValidator<num?> min(num m, {String? message}) => (v) => (v != null && v < m) ? (message ?? 'Valore minimo $m') : null;

  static GenaiValidator<num?> max(num m, {String? message}) => (v) => (v != null && v > m) ? (message ?? 'Valore massimo $m') : null;

  /// Combine multiple validators, returning the first error.
  static GenaiValidator<T> combine<T>(List<GenaiValidator<T>> validators) => (v) {
        for (final fn in validators) {
          final err = fn(v);
          if (err != null) return err;
        }
        return null;
      };
}
