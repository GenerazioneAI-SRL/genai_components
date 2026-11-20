///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class CLTranslationsDe extends CLTranslations with BaseTranslations<CLAppLocale, CLTranslations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [CLAppLocale.build] is preferred.
	CLTranslationsDe({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<CLAppLocale, CLTranslations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: CLAppLocale.de,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <de>.
	@override final TranslationMetadata<CLAppLocale, CLTranslations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final CLTranslationsDe _root = this; // ignore: unused_field

	@override 
	CLTranslationsDe $copyWith({TranslationMetadata<CLAppLocale, CLTranslations>? meta}) => CLTranslationsDe(meta: meta ?? this.$meta);

	// Translations
	@override late final _CLTranslations$assistant$de assistant = _CLTranslations$assistant$de._(_root);
	@override late final _CLTranslations$calendar$de calendar = _CLTranslations$calendar$de._(_root);
	@override late final _CLTranslations$command$de command = _CLTranslations$command$de._(_root);
	@override late final _CLTranslations$common$de common = _CLTranslations$common$de._(_root);
	@override late final _CLTranslations$dialogs$de dialogs = _CLTranslations$dialogs$de._(_root);
	@override late final _CLTranslations$dropdown$de dropdown = _CLTranslations$dropdown$de._(_root);
	@override late final _CLTranslations$files$de files = _CLTranslations$files$de._(_root);
	@override late final _CLTranslations$form$de form = _CLTranslations$form$de._(_root);
	@override late final _CLTranslations$table$de table = _CLTranslations$table$de._(_root);
}

// Path: assistant
class _CLTranslations$assistant$de extends CLTranslations$assistant$it {
	_CLTranslations$assistant$de._(CLTranslationsDe root) : this._root = root, super.internal(root);

	final CLTranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get newConversation => 'Neue Unterhaltung';
	@override String get greeting => 'Hallo';
	@override String greetingName({required Object name}) => 'Hallo ${name}';
	@override String get howCanIHelp => 'Wie kann ich dir heute helfen?';
	@override String get thinking => 'Ich denke nach…';
	@override String get working => 'Wird bearbeitet...';
	@override String get scrollToBottom => 'Nach unten';
	@override String get privacy => 'Skillera AI respektiert deine Berechtigungen und die DSGVO. Prüfe die Antworten immer.';
	@override late final _CLTranslations$assistant$composer$de composer = _CLTranslations$assistant$composer$de._(_root);
	@override late final _CLTranslations$assistant$conversations$de conversations = _CLTranslations$assistant$conversations$de._(_root);
	@override late final _CLTranslations$assistant$message$de message = _CLTranslations$assistant$message$de._(_root);
	@override late final _CLTranslations$assistant$overlay$de overlay = _CLTranslations$assistant$overlay$de._(_root);
}

// Path: calendar
class _CLTranslations$calendar$de extends CLTranslations$calendar$it {
	_CLTranslations$calendar$de._(CLTranslationsDe root) : this._root = root, super.internal(root);

	final CLTranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get previousMonth => 'Vorheriger Monat';
	@override String get nextMonth => 'Nächster Monat';
	@override String get goToToday => 'Zu heute';
	@override String get withWarnings => 'Mit Hinweisen';
	@override String get noData => 'Keine Daten';
}

// Path: command
class _CLTranslations$command$de extends CLTranslations$command$it {
	_CLTranslations$command$de._(CLTranslationsDe root) : this._root = root, super.internal(root);

	final CLTranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get hint => 'Suchen…';
	@override String get searching => 'Suche läuft…';
	@override String get noResults => 'Keine Ergebnisse';
	@override String askAi({required Object query}) => 'Die KI fragen: „${query}“';
}

// Path: common
class _CLTranslations$common$de extends CLTranslations$common$it {
	_CLTranslations$common$de._(CLTranslationsDe root) : this._root = root, super.internal(root);

	final CLTranslationsDe _root; // ignore: unused_field

	// Translations
	@override late final _CLTranslations$common$actions$de actions = _CLTranslations$common$actions$de._(_root);
	@override String get copied => 'Kopiert';
	@override String copiedText({required Object text}) => 'Text ${text} kopiert';
	@override String get error => 'Fehler';
	@override String errorCode({required Object code}) => 'Code ${code}';
	@override String get warning => 'Achtung';
	@override String get info => 'Info';
	@override String get home => 'Start';
	@override late final _CLTranslations$common$date$de date = _CLTranslations$common$date$de._(_root);
}

// Path: dialogs
class _CLTranslations$dialogs$de extends CLTranslations$dialogs$it {
	_CLTranslations$dialogs$de._(CLTranslationsDe root) : this._root = root, super.internal(root);

	final CLTranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get confirmMessage => 'Möchtest du diesen Vorgang wirklich ausführen?';
	@override late final _CLTranslations$dialogs$assign$de assign = _CLTranslations$dialogs$assign$de._(_root);
	@override late final _CLTranslations$dialogs$qr$de qr = _CLTranslations$dialogs$qr$de._(_root);
}

// Path: dropdown
class _CLTranslations$dropdown$de extends CLTranslations$dropdown$it {
	_CLTranslations$dropdown$de._(CLTranslationsDe root) : this._root = root, super.internal(root);

	final CLTranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get placeholder => 'Auswählen…';
	@override String get noResults => 'Keine Ergebnisse gefunden';
}

// Path: files
class _CLTranslations$files$de extends CLTranslations$files$it {
	_CLTranslations$files$de._(CLTranslationsDe root) : this._root = root, super.internal(root);

	final CLTranslationsDe _root; // ignore: unused_field

	// Translations
	@override String invalidFile({required Object name, required Object extensions}) => 'Die Datei ${name} ist nicht gültig. Erlaubte Endungen: ${extensions}.';
	@override String get noValidFile => 'Keine gültige Datei ausgewählt.';
	@override String get pickCancelled => 'Dateiauswahl abgebrochen.';
	@override String pickerFailed({required Object error}) => 'Die Dateiauswahl lässt sich nicht öffnen: ${error}';
	@override String get dropOrClick => 'Dateien hierher ziehen oder zum Hochladen klicken';
	@override String get dropHere => 'Dateien hier ablegen';
	@override String limits({required Object count, required Object extensions}) => 'Max. ${count} Dateien • ${extensions}';
	@override late final _CLTranslations$files$kinds$de kinds = _CLTranslations$files$kinds$de._(_root);
	@override late final _CLTranslations$files$viewer$de viewer = _CLTranslations$files$viewer$de._(_root);
}

// Path: form
class _CLTranslations$form$de extends CLTranslations$form$it {
	_CLTranslations$form$de._(CLTranslationsDe root) : this._root = root, super.internal(root);

	final CLTranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get pickFile => 'Datei auswählen';
	@override String get pickDate => 'Datum wählen';
	@override String get pickRange => 'Zeitraum wählen';
	@override late final _CLTranslations$form$time$de time = _CLTranslations$form$time$de._(_root);
	@override late final _CLTranslations$form$validation$de validation = _CLTranslations$form$validation$de._(_root);
}

// Path: table
class _CLTranslations$table$de extends CLTranslations$table$it {
	_CLTranslations$table$de._(CLTranslationsDe root) : this._root = root, super.internal(root);

	final CLTranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get selectPeriod => 'Zeitraum wählen';
	@override String selectedCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('de'))(n,
		one: '${n} ausgewählt',
		other: '${n} ausgewählt',
	);
	@override String get deselectAll => 'Alle abwählen';
	@override String get deselect => 'Abwählen';
	@override String get actions => 'Aktionen';
	@override String get moreActions => 'Weitere Aktionen';
	@override String get download => 'Herunterladen';
	@override String get endOfList => 'Keine weiteren Ergebnisse';
	@override late final _CLTranslations$table$empty$de empty = _CLTranslations$table$empty$de._(_root);
	@override late final _CLTranslations$table$error$de error = _CLTranslations$table$error$de._(_root);
	@override late final _CLTranslations$table$filter$de filter = _CLTranslations$table$filter$de._(_root);
	@override late final _CLTranslations$table$sort$de sort = _CLTranslations$table$sort$de._(_root);
	@override late final _CLTranslations$table$footer$de footer = _CLTranslations$table$footer$de._(_root);
}

// Path: assistant.composer
class _CLTranslations$assistant$composer$de extends CLTranslations$assistant$composer$it {
	_CLTranslations$assistant$composer$de._(CLTranslationsDe root) : this._root = root, super.internal(root);

	final CLTranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get hint => 'Nachricht schreiben...';
	@override String get reply => 'Antworten...';
	@override String get wait => 'Warte auf die Antwort...';
	@override String get send => 'Senden (Enter)';
	@override String get stop => 'Stopp';
}

// Path: assistant.conversations
class _CLTranslations$assistant$conversations$de extends CLTranslations$assistant$conversations$it {
	_CLTranslations$assistant$conversations$de._(CLTranslationsDe root) : this._root = root, super.internal(root);

	final CLTranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Unterhaltungen';
	@override String get newConversation => 'Neu';
	@override String get empty => 'Keine gespeicherten Unterhaltungen';
	@override String get archive => 'Archivieren';
	@override String get today => 'heute';
	@override String get yesterday => 'gestern';
	@override String daysAgo({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('de'))(n,
		one: 'vor ${n} Tag',
		other: 'vor ${n} Tagen',
	);
}

// Path: assistant.message
class _CLTranslations$assistant$message$de extends CLTranslations$assistant$message$it {
	_CLTranslations$assistant$message$de._(CLTranslationsDe root) : this._root = root, super.internal(root);

	final CLTranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get sending => 'Wird gesendet…';
	@override String get notSent => 'Nachricht nicht gesendet';
	@override String get replyFailed => 'Antwort fehlgeschlagen';
	@override String source({required Object n, required Object label}) => 'Quelle ${n}: ${label}';
}

// Path: assistant.overlay
class _CLTranslations$assistant$overlay$de extends CLTranslations$assistant$overlay$it {
	_CLTranslations$assistant$overlay$de._(CLTranslationsDe root) : this._root = root, super.internal(root);

	final CLTranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get ask => 'Frag etwas...';
	@override String get intro => 'Frag mich nach Anwesenheit, Schichten,\nAuffälligkeiten oder wechsle zwischen den Bereichen.';
	@override String get ready => 'Bereit';
	@override String get waitingForYou => 'Ich warte auf dich...';
	@override String get waitingForResponse => 'Ich warte auf deine Antwort...';
	@override String get workingOnRequest => 'Ich bearbeite deine Anfrage...';
	@override String tapToConfirm({required Object label}) => 'Tippe auf „${label}“, um zu bestätigen';
	@override String get tapToViewChat => 'Tippen, um den Chat zu sehen';
	@override String get tapToSeeMore => 'Tippen, um mehr zu sehen';
}

// Path: common.actions
class _CLTranslations$common$actions$de extends CLTranslations$common$actions$it {
	_CLTranslations$common$actions$de._(CLTranslationsDe root) : this._root = root, super.internal(root);

	final CLTranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get apply => 'Anwenden';
	@override String get cancel => 'Abbrechen';
	@override String get close => 'Schließen';
	@override String get confirm => 'Bestätigen';
	@override String get copy => 'Kopieren';
	@override String get delete => 'Löschen';
	@override String get edit => 'Bearbeiten';
	@override String get more => 'Mehr';
	@override String get remove => 'Entfernen';
	@override String get reset => 'Zurücksetzen';
	@override String get retry => 'Erneut versuchen';
	@override String get save => 'Speichern';
	@override String get search => 'Suchen';
}

// Path: common.date
class _CLTranslations$common$date$de extends CLTranslations$common$date$it {
	_CLTranslations$common$date$de._(CLTranslationsDe root) : this._root = root, super.internal(root);

	final CLTranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get today => 'Heute';
	@override String monthYear({required Object month, required Object year}) => '${month} ${year}';
	@override List<String> get monthsTitle => [
		'Januar',
		'Februar',
		'März',
		'April',
		'Mai',
		'Juni',
		'Juli',
		'August',
		'September',
		'Oktober',
		'November',
		'Dezember',
	];
	@override List<String> get weekdaysTitle => [
		'Mo',
		'Di',
		'Mi',
		'Do',
		'Fr',
		'Sa',
		'So',
	];
}

// Path: dialogs.assign
class _CLTranslations$dialogs$assign$de extends CLTranslations$dialogs$assign$it {
	_CLTranslations$dialogs$assign$de._(CLTranslationsDe root) : this._root = root, super.internal(root);

	final CLTranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get pickMany => 'Ein oder mehrere Elemente auswählen';
	@override String get pickOne => 'Ein Element auswählen';
	@override String selected({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('de'))(n,
		one: '${n} ausgewählt',
		other: '${n} ausgewählt',
	);
	@override String get assign => 'Zuweisen';
	@override String assignCount({required Object count}) => 'Zuweisen (${count})';
	@override String get search => 'Suchen...';
	@override String get empty => 'Keine Elemente verfügbar';
	@override String get noResults => 'Keine Ergebnisse';
	@override String noMatch({required Object query}) => 'Keine Treffer für „${query}“';
}

// Path: dialogs.qr
class _CLTranslations$dialogs$qr$de extends CLTranslations$dialogs$qr$it {
	_CLTranslations$dialogs$qr$de._(CLTranslationsDe root) : this._root = root, super.internal(root);

	final CLTranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'QR-Code';
	@override String get copy => 'Kopieren';
	@override String get copied => 'Code kopiert';
}

// Path: files.kinds
class _CLTranslations$files$kinds$de extends CLTranslations$files$kinds$it {
	_CLTranslations$files$kinds$de._(CLTranslationsDe root) : this._root = root, super.internal(root);

	final CLTranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get image => 'Bild';
	@override String get video => 'Video';
	@override String get word => 'Word-Dokument';
	@override String get excel => 'Excel-Tabelle';
	@override String get zip => 'ZIP-Archiv';
	@override String get archive => 'Archiv';
	@override String get file => 'Datei';
}

// Path: files.viewer
class _CLTranslations$files$viewer$de extends CLTranslations$files$viewer$it {
	_CLTranslations$files$viewer$de._(CLTranslationsDe root) : this._root = root, super.internal(root);

	final CLTranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get previousPage => 'Vorherige Seite';
	@override String get nextPage => 'Nächste Seite';
	@override String get zoomIn => 'Vergrößern';
	@override String get zoomOut => 'Verkleinern';
	@override String get zoomReset => 'Zoom zurücksetzen';
	@override String get pdfFailed => 'Das PDF lässt sich nicht laden';
}

// Path: form.time
class _CLTranslations$form$time$de extends CLTranslations$form$time$it {
	_CLTranslations$form$time$de._(CLTranslationsDe root) : this._root = root, super.internal(root);

	final CLTranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Stunden';
	@override String get minutes => 'Minuten';
	@override String get seconds => 'Sekunden';
}

// Path: form.validation
class _CLTranslations$form$validation$de extends CLTranslations$form$validation$it {
	_CLTranslations$form$validation$de._(CLTranslationsDe root) : this._root = root, super.internal(root);

	final CLTranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get required => 'Dieses Feld darf nicht leer sein';
	@override String minLength({required Object min}) => 'Mindestens ${min} Zeichen';
	@override String get email => 'Gib eine gültige E-Mail-Adresse ein';
	@override String get passwordEmpty => 'Das Passwort darf nicht leer sein';
	@override String get passwordWeak => 'Das Passwort braucht mindestens 8 Zeichen, einen Groß- und einen Kleinbuchstaben, eine Zahl und ein Sonderzeichen';
}

// Path: table.empty
class _CLTranslations$table$empty$de extends CLTranslations$table$empty$it {
	_CLTranslations$table$empty$de._(CLTranslationsDe root) : this._root = root, super.internal(root);

	final CLTranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get noneFound => 'Keine Einträge gefunden';
	@override String get tryFilters => 'Versuche, die Filter zu ändern';
	@override String get noResults => 'Keine Ergebnisse';
	@override String get nothingYet => 'Hier ist noch nichts';
	@override String get tryFiltersSearch => 'Versuche, die Suchfilter zu ändern';
	@override String get willAppear => 'Hier erscheinen die Einträge, sobald es welche gibt';
}

// Path: table.error
class _CLTranslations$table$error$de extends CLTranslations$table$error$it {
	_CLTranslations$table$error$de._(CLTranslationsDe root) : this._root = root, super.internal(root);

	final CLTranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get loading => 'Laden fehlgeschlagen';
	@override String get generic => 'Es ist ein Fehler aufgetreten';
	@override String get unknown => 'Unbekannter Fehler';
}

// Path: table.filter
class _CLTranslations$table$filter$de extends CLTranslations$table$filter$it {
	_CLTranslations$table$filter$de._(CLTranslationsDe root) : this._root = root, super.internal(root);

	final CLTranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Filter';
	@override String get searchFilters => 'Suchfilter';
	@override String get filterWith => 'Filtern nach...';
	@override String searchBy({required Object title}) => 'Suchen nach ${title}';
	@override String filterBy({required Object title}) => 'Filtern nach ${title}';
	@override String chip({required Object title, required Object value}) => '${title}: ${value}';
}

// Path: table.sort
class _CLTranslations$table$sort$de extends CLTranslations$table$sort$it {
	_CLTranslations$table$sort$de._(CLTranslationsDe root) : this._root = root, super.internal(root);

	final CLTranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get by => 'Sortieren nach';
	@override String get short => 'Sortieren';
	@override String ascending({required Object column}) => '${column} - Aufsteigend';
	@override String descending({required Object column}) => '${column} - Absteigend';
}

// Path: table.footer
class _CLTranslations$table$footer$de extends CLTranslations$table$footer$it {
	_CLTranslations$table$footer$de._(CLTranslationsDe root) : this._root = root, super.internal(root);

	final CLTranslationsDe _root; // ignore: unused_field

	// Translations
	@override String range({required Object start, required Object end, required Object total}) => '${start} – ${end} von ${total}';
	@override String get none => '0 Ergebnisse';
}

/// The flat map containing all translations for locale <de>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on CLTranslationsDe {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'assistant.newConversation' => 'Neue Unterhaltung',
			'assistant.greeting' => 'Hallo',
			'assistant.greetingName' => ({required Object name}) => 'Hallo ${name}',
			'assistant.howCanIHelp' => 'Wie kann ich dir heute helfen?',
			'assistant.thinking' => 'Ich denke nach…',
			'assistant.working' => 'Wird bearbeitet...',
			'assistant.scrollToBottom' => 'Nach unten',
			'assistant.privacy' => 'Skillera AI respektiert deine Berechtigungen und die DSGVO. Prüfe die Antworten immer.',
			'assistant.composer.hint' => 'Nachricht schreiben...',
			'assistant.composer.reply' => 'Antworten...',
			'assistant.composer.wait' => 'Warte auf die Antwort...',
			'assistant.composer.send' => 'Senden (Enter)',
			'assistant.composer.stop' => 'Stopp',
			'assistant.conversations.title' => 'Unterhaltungen',
			'assistant.conversations.newConversation' => 'Neu',
			'assistant.conversations.empty' => 'Keine gespeicherten Unterhaltungen',
			'assistant.conversations.archive' => 'Archivieren',
			'assistant.conversations.today' => 'heute',
			'assistant.conversations.yesterday' => 'gestern',
			'assistant.conversations.daysAgo' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('de'))(n, one: 'vor ${n} Tag', other: 'vor ${n} Tagen', ), 
			'assistant.message.sending' => 'Wird gesendet…',
			'assistant.message.notSent' => 'Nachricht nicht gesendet',
			'assistant.message.replyFailed' => 'Antwort fehlgeschlagen',
			'assistant.message.source' => ({required Object n, required Object label}) => 'Quelle ${n}: ${label}',
			'assistant.overlay.ask' => 'Frag etwas...',
			'assistant.overlay.intro' => 'Frag mich nach Anwesenheit, Schichten,\nAuffälligkeiten oder wechsle zwischen den Bereichen.',
			'assistant.overlay.ready' => 'Bereit',
			'assistant.overlay.waitingForYou' => 'Ich warte auf dich...',
			'assistant.overlay.waitingForResponse' => 'Ich warte auf deine Antwort...',
			'assistant.overlay.workingOnRequest' => 'Ich bearbeite deine Anfrage...',
			'assistant.overlay.tapToConfirm' => ({required Object label}) => 'Tippe auf „${label}“, um zu bestätigen',
			'assistant.overlay.tapToViewChat' => 'Tippen, um den Chat zu sehen',
			'assistant.overlay.tapToSeeMore' => 'Tippen, um mehr zu sehen',
			'calendar.previousMonth' => 'Vorheriger Monat',
			'calendar.nextMonth' => 'Nächster Monat',
			'calendar.goToToday' => 'Zu heute',
			'calendar.withWarnings' => 'Mit Hinweisen',
			'calendar.noData' => 'Keine Daten',
			'command.hint' => 'Suchen…',
			'command.searching' => 'Suche läuft…',
			'command.noResults' => 'Keine Ergebnisse',
			'command.askAi' => ({required Object query}) => 'Die KI fragen: „${query}“',
			'common.actions.apply' => 'Anwenden',
			'common.actions.cancel' => 'Abbrechen',
			'common.actions.close' => 'Schließen',
			'common.actions.confirm' => 'Bestätigen',
			'common.actions.copy' => 'Kopieren',
			'common.actions.delete' => 'Löschen',
			'common.actions.edit' => 'Bearbeiten',
			'common.actions.more' => 'Mehr',
			'common.actions.remove' => 'Entfernen',
			'common.actions.reset' => 'Zurücksetzen',
			'common.actions.retry' => 'Erneut versuchen',
			'common.actions.save' => 'Speichern',
			'common.actions.search' => 'Suchen',
			'common.copied' => 'Kopiert',
			'common.copiedText' => ({required Object text}) => 'Text ${text} kopiert',
			'common.error' => 'Fehler',
			'common.errorCode' => ({required Object code}) => 'Code ${code}',
			'common.warning' => 'Achtung',
			'common.info' => 'Info',
			'common.home' => 'Start',
			'common.date.today' => 'Heute',
			'common.date.monthYear' => ({required Object month, required Object year}) => '${month} ${year}',
			'common.date.monthsTitle.0' => 'Januar',
			'common.date.monthsTitle.1' => 'Februar',
			'common.date.monthsTitle.2' => 'März',
			'common.date.monthsTitle.3' => 'April',
			'common.date.monthsTitle.4' => 'Mai',
			'common.date.monthsTitle.5' => 'Juni',
			'common.date.monthsTitle.6' => 'Juli',
			'common.date.monthsTitle.7' => 'August',
			'common.date.monthsTitle.8' => 'September',
			'common.date.monthsTitle.9' => 'Oktober',
			'common.date.monthsTitle.10' => 'November',
			'common.date.monthsTitle.11' => 'Dezember',
			'common.date.weekdaysTitle.0' => 'Mo',
			'common.date.weekdaysTitle.1' => 'Di',
			'common.date.weekdaysTitle.2' => 'Mi',
			'common.date.weekdaysTitle.3' => 'Do',
			'common.date.weekdaysTitle.4' => 'Fr',
			'common.date.weekdaysTitle.5' => 'Sa',
			'common.date.weekdaysTitle.6' => 'So',
			'dialogs.confirmMessage' => 'Möchtest du diesen Vorgang wirklich ausführen?',
			'dialogs.assign.pickMany' => 'Ein oder mehrere Elemente auswählen',
			'dialogs.assign.pickOne' => 'Ein Element auswählen',
			'dialogs.assign.selected' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('de'))(n, one: '${n} ausgewählt', other: '${n} ausgewählt', ), 
			'dialogs.assign.assign' => 'Zuweisen',
			'dialogs.assign.assignCount' => ({required Object count}) => 'Zuweisen (${count})',
			'dialogs.assign.search' => 'Suchen...',
			'dialogs.assign.empty' => 'Keine Elemente verfügbar',
			'dialogs.assign.noResults' => 'Keine Ergebnisse',
			'dialogs.assign.noMatch' => ({required Object query}) => 'Keine Treffer für „${query}“',
			'dialogs.qr.title' => 'QR-Code',
			'dialogs.qr.copy' => 'Kopieren',
			'dialogs.qr.copied' => 'Code kopiert',
			'dropdown.placeholder' => 'Auswählen…',
			'dropdown.noResults' => 'Keine Ergebnisse gefunden',
			'files.invalidFile' => ({required Object name, required Object extensions}) => 'Die Datei ${name} ist nicht gültig. Erlaubte Endungen: ${extensions}.',
			'files.noValidFile' => 'Keine gültige Datei ausgewählt.',
			'files.pickCancelled' => 'Dateiauswahl abgebrochen.',
			'files.pickerFailed' => ({required Object error}) => 'Die Dateiauswahl lässt sich nicht öffnen: ${error}',
			'files.dropOrClick' => 'Dateien hierher ziehen oder zum Hochladen klicken',
			'files.dropHere' => 'Dateien hier ablegen',
			'files.limits' => ({required Object count, required Object extensions}) => 'Max. ${count} Dateien • ${extensions}',
			'files.kinds.image' => 'Bild',
			'files.kinds.video' => 'Video',
			'files.kinds.word' => 'Word-Dokument',
			'files.kinds.excel' => 'Excel-Tabelle',
			'files.kinds.zip' => 'ZIP-Archiv',
			'files.kinds.archive' => 'Archiv',
			'files.kinds.file' => 'Datei',
			'files.viewer.previousPage' => 'Vorherige Seite',
			'files.viewer.nextPage' => 'Nächste Seite',
			'files.viewer.zoomIn' => 'Vergrößern',
			'files.viewer.zoomOut' => 'Verkleinern',
			'files.viewer.zoomReset' => 'Zoom zurücksetzen',
			'files.viewer.pdfFailed' => 'Das PDF lässt sich nicht laden',
			'form.pickFile' => 'Datei auswählen',
			'form.pickDate' => 'Datum wählen',
			'form.pickRange' => 'Zeitraum wählen',
			'form.time.hours' => 'Stunden',
			'form.time.minutes' => 'Minuten',
			'form.time.seconds' => 'Sekunden',
			'form.validation.required' => 'Dieses Feld darf nicht leer sein',
			'form.validation.minLength' => ({required Object min}) => 'Mindestens ${min} Zeichen',
			'form.validation.email' => 'Gib eine gültige E-Mail-Adresse ein',
			'form.validation.passwordEmpty' => 'Das Passwort darf nicht leer sein',
			'form.validation.passwordWeak' => 'Das Passwort braucht mindestens 8 Zeichen, einen Groß- und einen Kleinbuchstaben, eine Zahl und ein Sonderzeichen',
			'table.selectPeriod' => 'Zeitraum wählen',
			'table.selectedCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('de'))(n, one: '${n} ausgewählt', other: '${n} ausgewählt', ), 
			'table.deselectAll' => 'Alle abwählen',
			'table.deselect' => 'Abwählen',
			'table.actions' => 'Aktionen',
			'table.moreActions' => 'Weitere Aktionen',
			'table.download' => 'Herunterladen',
			'table.endOfList' => 'Keine weiteren Ergebnisse',
			'table.empty.noneFound' => 'Keine Einträge gefunden',
			'table.empty.tryFilters' => 'Versuche, die Filter zu ändern',
			'table.empty.noResults' => 'Keine Ergebnisse',
			'table.empty.nothingYet' => 'Hier ist noch nichts',
			'table.empty.tryFiltersSearch' => 'Versuche, die Suchfilter zu ändern',
			'table.empty.willAppear' => 'Hier erscheinen die Einträge, sobald es welche gibt',
			'table.error.loading' => 'Laden fehlgeschlagen',
			'table.error.generic' => 'Es ist ein Fehler aufgetreten',
			'table.error.unknown' => 'Unbekannter Fehler',
			'table.filter.title' => 'Filter',
			'table.filter.searchFilters' => 'Suchfilter',
			'table.filter.filterWith' => 'Filtern nach...',
			'table.filter.searchBy' => ({required Object title}) => 'Suchen nach ${title}',
			'table.filter.filterBy' => ({required Object title}) => 'Filtern nach ${title}',
			'table.filter.chip' => ({required Object title, required Object value}) => '${title}: ${value}',
			'table.sort.by' => 'Sortieren nach',
			'table.sort.short' => 'Sortieren',
			'table.sort.ascending' => ({required Object column}) => '${column} - Aufsteigend',
			'table.sort.descending' => ({required Object column}) => '${column} - Absteigend',
			'table.footer.range' => ({required Object start, required Object end, required Object total}) => '${start} – ${end} von ${total}',
			'table.footer.none' => '0 Ergebnisse',
			_ => null,
		};
	}
}
