/// Le traduzioni della libreria per i suoi file: `clL10n.<namespace>.<chiave>`.
///
/// Si importa con un percorso relativo (`import '../../src/i18n/l10n.dart';`). Convenzioni e ricetta nel README del
/// repo, sezione «Traduzioni». Fuori dalla libreria non si esporta niente di qui: l'app imposta la lingua con
/// [CLLocale] (`cl_locale.dart`, nel barrel).
library;

export 'strings.g.dart' show clL10n, CLTranslations;

/// [value] se l'ha scelto chi usa il componente, il testo tradotto se è rimasto il valore di serie in italiano.
///
/// Serve ai parametri pubblici che hanno un testo italiano come valore di serie (`confirmLabel = 'Conferma'`): la firma
/// non cambia (resta un `String` con lo stesso default) e chi non lo passa vede il testo nella lingua dell'app. Chi
/// passa proprio il testo italiano di serie lo vede tradotto: è lo stesso significato.
String clDefault(String value, String italianDefault, String translated) => value == italianDefault ? translated : value;
