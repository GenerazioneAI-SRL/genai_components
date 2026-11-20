///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef CLTranslationsIt = CLTranslations; // ignore: unused_element
class CLTranslations with BaseTranslations<CLAppLocale, CLTranslations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [CLAppLocale.build] is preferred.
	CLTranslations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<CLAppLocale, CLTranslations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: CLAppLocale.it,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <it>.
	@override final TranslationMetadata<CLAppLocale, CLTranslations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final CLTranslations _root = this; // ignore: unused_field

	CLTranslations $copyWith({TranslationMetadata<CLAppLocale, CLTranslations>? meta}) => CLTranslations(meta: meta ?? this.$meta);

	// Translations
	late final CLTranslations$assistant$it assistant = CLTranslations$assistant$it.internal(_root);
	late final CLTranslations$calendar$it calendar = CLTranslations$calendar$it.internal(_root);
	late final CLTranslations$command$it command = CLTranslations$command$it.internal(_root);
	late final CLTranslations$common$it common = CLTranslations$common$it.internal(_root);
	late final CLTranslations$dialogs$it dialogs = CLTranslations$dialogs$it.internal(_root);
	late final CLTranslations$dropdown$it dropdown = CLTranslations$dropdown$it.internal(_root);
	late final CLTranslations$files$it files = CLTranslations$files$it.internal(_root);
	late final CLTranslations$form$it form = CLTranslations$form$it.internal(_root);
	late final CLTranslations$table$it table = CLTranslations$table$it.internal(_root);
}

// Path: assistant
class CLTranslations$assistant$it {
	CLTranslations$assistant$it.internal(this._root);

	final CLTranslations _root; // ignore: unused_field

	// Translations

	/// it: 'Nuova conversazione'
	String get newConversation => 'Nuova conversazione';

	/// it: 'Ciao'
	String get greeting => 'Ciao';

	/// it: 'Ciao $name'
	String greetingName({required Object name}) => 'Ciao ${name}';

	/// it: 'Come posso aiutarti oggi?'
	String get howCanIHelp => 'Come posso aiutarti oggi?';

	/// it: 'Sto pensando…'
	String get thinking => 'Sto pensando…';

	/// it: 'Sto elaborando...'
	String get working => 'Sto elaborando...';

	/// it: 'Vai in fondo'
	String get scrollToBottom => 'Vai in fondo';

	/// it: 'Skillera AI opera nel rispetto dei tuoi permessi e del GDPR. Verifica sempre le risposte.'
	String get privacy => 'Skillera AI opera nel rispetto dei tuoi permessi e del GDPR. Verifica sempre le risposte.';

	late final CLTranslations$assistant$composer$it composer = CLTranslations$assistant$composer$it.internal(_root);
	late final CLTranslations$assistant$conversations$it conversations = CLTranslations$assistant$conversations$it.internal(_root);
	late final CLTranslations$assistant$message$it message = CLTranslations$assistant$message$it.internal(_root);
	late final CLTranslations$assistant$overlay$it overlay = CLTranslations$assistant$overlay$it.internal(_root);
}

// Path: calendar
class CLTranslations$calendar$it {
	CLTranslations$calendar$it.internal(this._root);

	final CLTranslations _root; // ignore: unused_field

	// Translations

	/// it: 'Mese precedente'
	String get previousMonth => 'Mese precedente';

	/// it: 'Mese successivo'
	String get nextMonth => 'Mese successivo';

	/// it: 'Vai ad oggi'
	String get goToToday => 'Vai ad oggi';

	/// it: 'Con avvisi'
	String get withWarnings => 'Con avvisi';

	/// it: 'Nessun dato'
	String get noData => 'Nessun dato';
}

// Path: command
class CLTranslations$command$it {
	CLTranslations$command$it.internal(this._root);

	final CLTranslations _root; // ignore: unused_field

	// Translations

	/// it: 'Cerca…'
	String get hint => 'Cerca…';

	/// it: 'Ricerca…'
	String get searching => 'Ricerca…';

	/// it: 'Nessun risultato'
	String get noResults => 'Nessun risultato';

	/// it: 'Chiedi all’AI: “$query”'
	String askAi({required Object query}) => 'Chiedi all’AI: “${query}”';
}

// Path: common
class CLTranslations$common$it {
	CLTranslations$common$it.internal(this._root);

	final CLTranslations _root; // ignore: unused_field

	// Translations
	late final CLTranslations$common$actions$it actions = CLTranslations$common$actions$it.internal(_root);

	/// it: 'Copiato'
	String get copied => 'Copiato';

	/// it: 'Testo $text copiato'
	String copiedText({required Object text}) => 'Testo ${text} copiato';

	/// it: 'Errore'
	String get error => 'Errore';

	/// it: 'Codice $code'
	String errorCode({required Object code}) => 'Codice ${code}';

	/// it: 'Attenzione'
	String get warning => 'Attenzione';

	/// it: 'Info'
	String get info => 'Info';

	/// it: 'Home'
	String get home => 'Home';

	late final CLTranslations$common$date$it date = CLTranslations$common$date$it.internal(_root);
}

// Path: dialogs
class CLTranslations$dialogs$it {
	CLTranslations$dialogs$it.internal(this._root);

	final CLTranslations _root; // ignore: unused_field

	// Translations

	/// it: 'Sei sicuro di voler effettuare quest'operazione?'
	String get confirmMessage => 'Sei sicuro di voler effettuare quest\'operazione?';

	late final CLTranslations$dialogs$assign$it assign = CLTranslations$dialogs$assign$it.internal(_root);
	late final CLTranslations$dialogs$qr$it qr = CLTranslations$dialogs$qr$it.internal(_root);
}

// Path: dropdown
class CLTranslations$dropdown$it {
	CLTranslations$dropdown$it.internal(this._root);

	final CLTranslations _root; // ignore: unused_field

	// Translations

	/// it: 'Seleziona…'
	String get placeholder => 'Seleziona…';

	/// it: 'Nessun risultato trovato'
	String get noResults => 'Nessun risultato trovato';
}

// Path: files
class CLTranslations$files$it {
	CLTranslations$files$it.internal(this._root);

	final CLTranslations _root; // ignore: unused_field

	// Translations

	/// it: 'Il file $name non è valido. Le estensioni ammesse sono $extensions.'
	String invalidFile({required Object name, required Object extensions}) => 'Il file ${name} non è valido. Le estensioni ammesse sono ${extensions}.';

	/// it: 'Nessun file valido selezionato.'
	String get noValidFile => 'Nessun file valido selezionato.';

	/// it: 'Selezione file annullata.'
	String get pickCancelled => 'Selezione file annullata.';

	/// it: 'Impossibile aprire il selettore file: $error'
	String pickerFailed({required Object error}) => 'Impossibile aprire il selettore file: ${error}';

	/// it: 'Trascina i file qui o clicca per caricare'
	String get dropOrClick => 'Trascina i file qui o clicca per caricare';

	/// it: 'Rilascia i file qui'
	String get dropHere => 'Rilascia i file qui';

	/// it: 'Max $count file • $extensions'
	String limits({required Object count, required Object extensions}) => 'Max ${count} file • ${extensions}';

	late final CLTranslations$files$kinds$it kinds = CLTranslations$files$kinds$it.internal(_root);
	late final CLTranslations$files$viewer$it viewer = CLTranslations$files$viewer$it.internal(_root);
}

// Path: form
class CLTranslations$form$it {
	CLTranslations$form$it.internal(this._root);

	final CLTranslations _root; // ignore: unused_field

	// Translations

	/// it: 'Seleziona file'
	String get pickFile => 'Seleziona file';

	/// it: 'Seleziona data'
	String get pickDate => 'Seleziona data';

	/// it: 'Seleziona intervallo'
	String get pickRange => 'Seleziona intervallo';

	late final CLTranslations$form$time$it time = CLTranslations$form$time$it.internal(_root);
	late final CLTranslations$form$validation$it validation = CLTranslations$form$validation$it.internal(_root);
}

// Path: table
class CLTranslations$table$it {
	CLTranslations$table$it.internal(this._root);

	final CLTranslations _root; // ignore: unused_field

	// Translations

	/// it: 'Seleziona periodo'
	String get selectPeriod => 'Seleziona periodo';

	/// it: '(one) {$n selezionato} (other) {$n selezionati}'
	String selectedCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n,
		one: '${n} selezionato',
		other: '${n} selezionati',
	);

	/// it: 'Deseleziona tutto'
	String get deselectAll => 'Deseleziona tutto';

	/// it: 'Deseleziona'
	String get deselect => 'Deseleziona';

	/// it: 'Azioni'
	String get actions => 'Azioni';

	/// it: 'Altre azioni'
	String get moreActions => 'Altre azioni';

	/// it: 'Download'
	String get download => 'Download';

	/// it: 'Non ci sono altri risultati'
	String get endOfList => 'Non ci sono altri risultati';

	late final CLTranslations$table$empty$it empty = CLTranslations$table$empty$it.internal(_root);
	late final CLTranslations$table$error$it error = CLTranslations$table$error$it.internal(_root);
	late final CLTranslations$table$filter$it filter = CLTranslations$table$filter$it.internal(_root);
	late final CLTranslations$table$sort$it sort = CLTranslations$table$sort$it.internal(_root);
	late final CLTranslations$table$footer$it footer = CLTranslations$table$footer$it.internal(_root);
}

// Path: assistant.composer
class CLTranslations$assistant$composer$it {
	CLTranslations$assistant$composer$it.internal(this._root);

	final CLTranslations _root; // ignore: unused_field

	// Translations

	/// it: 'Scrivi un messaggio...'
	String get hint => 'Scrivi un messaggio...';

	/// it: 'Rispondi...'
	String get reply => 'Rispondi...';

	/// it: 'Attendi la risposta...'
	String get wait => 'Attendi la risposta...';

	/// it: 'Invia (Invio)'
	String get send => 'Invia (Invio)';

	/// it: 'Stop'
	String get stop => 'Stop';
}

// Path: assistant.conversations
class CLTranslations$assistant$conversations$it {
	CLTranslations$assistant$conversations$it.internal(this._root);

	final CLTranslations _root; // ignore: unused_field

	// Translations

	/// it: 'Conversazioni'
	String get title => 'Conversazioni';

	/// it: 'Nuova'
	String get newConversation => 'Nuova';

	/// it: 'Nessuna conversazione salvata'
	String get empty => 'Nessuna conversazione salvata';

	/// it: 'Archivia'
	String get archive => 'Archivia';

	/// it: 'oggi'
	String get today => 'oggi';

	/// it: 'ieri'
	String get yesterday => 'ieri';

	/// it: '(one) {${n}g fa} (other) {${n}g fa}'
	String daysAgo({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n,
		one: '${n}g fa',
		other: '${n}g fa',
	);
}

// Path: assistant.message
class CLTranslations$assistant$message$it {
	CLTranslations$assistant$message$it.internal(this._root);

	final CLTranslations _root; // ignore: unused_field

	// Translations

	/// it: 'Invio…'
	String get sending => 'Invio…';

	/// it: 'Messaggio non inviato'
	String get notSent => 'Messaggio non inviato';

	/// it: 'Risposta non riuscita'
	String get replyFailed => 'Risposta non riuscita';

	/// it: 'Fonte $n: $label'
	String source({required Object n, required Object label}) => 'Fonte ${n}: ${label}';
}

// Path: assistant.overlay
class CLTranslations$assistant$overlay$it {
	CLTranslations$assistant$overlay$it.internal(this._root);

	final CLTranslations _root; // ignore: unused_field

	// Translations

	/// it: 'Chiedi qualcosa...'
	String get ask => 'Chiedi qualcosa...';

	/// it: 'Chiedimi informazioni su presenze, turni, anomalìe o naviga nelle sezioni.'
	String get intro => 'Chiedimi informazioni su presenze, turni,\nanomalìe o naviga nelle sezioni.';

	/// it: 'Pronto'
	String get ready => 'Pronto';

	/// it: 'Aspetto te...'
	String get waitingForYou => 'Aspetto te...';

	/// it: 'Aspetto la tua risposta...'
	String get waitingForResponse => 'Aspetto la tua risposta...';

	/// it: 'Sto lavorando alla tua richiesta...'
	String get workingOnRequest => 'Sto lavorando alla tua richiesta...';

	/// it: 'Tocca «$label» per confermare'
	String tapToConfirm({required Object label}) => 'Tocca «${label}» per confermare';

	/// it: 'Tocca per vedere la chat'
	String get tapToViewChat => 'Tocca per vedere la chat';

	/// it: 'Tocca per vedere di più'
	String get tapToSeeMore => 'Tocca per vedere di più';
}

// Path: common.actions
class CLTranslations$common$actions$it {
	CLTranslations$common$actions$it.internal(this._root);

	final CLTranslations _root; // ignore: unused_field

	// Translations

	/// it: 'Applica'
	String get apply => 'Applica';

	/// it: 'Annulla'
	String get cancel => 'Annulla';

	/// it: 'Chiudi'
	String get close => 'Chiudi';

	/// it: 'Conferma'
	String get confirm => 'Conferma';

	/// it: 'Copia'
	String get copy => 'Copia';

	/// it: 'Elimina'
	String get delete => 'Elimina';

	/// it: 'Modifica'
	String get edit => 'Modifica';

	/// it: 'Altro'
	String get more => 'Altro';

	/// it: 'Rimuovi'
	String get remove => 'Rimuovi';

	/// it: 'Ripristina'
	String get reset => 'Ripristina';

	/// it: 'Riprova'
	String get retry => 'Riprova';

	/// it: 'Salva'
	String get save => 'Salva';

	/// it: 'Cerca'
	String get search => 'Cerca';
}

// Path: common.date
class CLTranslations$common$date$it {
	CLTranslations$common$date$it.internal(this._root);

	final CLTranslations _root; // ignore: unused_field

	// Translations

	/// it: 'Oggi'
	String get today => 'Oggi';

	/// it: '$month $year'
	String monthYear({required Object month, required Object year}) => '${month} ${year}';

	List<String> get monthsTitle => [
		'Gennaio',
		'Febbraio',
		'Marzo',
		'Aprile',
		'Maggio',
		'Giugno',
		'Luglio',
		'Agosto',
		'Settembre',
		'Ottobre',
		'Novembre',
		'Dicembre',
	];
	List<String> get weekdaysTitle => [
		'Lun',
		'Mar',
		'Mer',
		'Gio',
		'Ven',
		'Sab',
		'Dom',
	];
}

// Path: dialogs.assign
class CLTranslations$dialogs$assign$it {
	CLTranslations$dialogs$assign$it.internal(this._root);

	final CLTranslations _root; // ignore: unused_field

	// Translations

	/// it: 'Seleziona uno o più elementi'
	String get pickMany => 'Seleziona uno o più elementi';

	/// it: 'Seleziona un elemento'
	String get pickOne => 'Seleziona un elemento';

	/// it: '(one) {$n selezionato} (other) {$n selezionati}'
	String selected({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n,
		one: '${n} selezionato',
		other: '${n} selezionati',
	);

	/// it: 'Assegna'
	String get assign => 'Assegna';

	/// it: 'Assegna ($count)'
	String assignCount({required Object count}) => 'Assegna (${count})';

	/// it: 'Cerca...'
	String get search => 'Cerca...';

	/// it: 'Nessun elemento disponibile'
	String get empty => 'Nessun elemento disponibile';

	/// it: 'Nessun risultato'
	String get noResults => 'Nessun risultato';

	/// it: 'Nessuna corrispondenza per "$query"'
	String noMatch({required Object query}) => 'Nessuna corrispondenza per "${query}"';
}

// Path: dialogs.qr
class CLTranslations$dialogs$qr$it {
	CLTranslations$dialogs$qr$it.internal(this._root);

	final CLTranslations _root; // ignore: unused_field

	// Translations

	/// it: 'QR Code'
	String get title => 'QR Code';

	/// it: 'Copia'
	String get copy => 'Copia';

	/// it: 'Codice copiato'
	String get copied => 'Codice copiato';
}

// Path: files.kinds
class CLTranslations$files$kinds$it {
	CLTranslations$files$kinds$it.internal(this._root);

	final CLTranslations _root; // ignore: unused_field

	// Translations

	/// it: 'Immagine'
	String get image => 'Immagine';

	/// it: 'Video'
	String get video => 'Video';

	/// it: 'Documento Word'
	String get word => 'Documento Word';

	/// it: 'Foglio Excel'
	String get excel => 'Foglio Excel';

	/// it: 'Archivio ZIP'
	String get zip => 'Archivio ZIP';

	/// it: 'Archivio'
	String get archive => 'Archivio';

	/// it: 'File'
	String get file => 'File';
}

// Path: files.viewer
class CLTranslations$files$viewer$it {
	CLTranslations$files$viewer$it.internal(this._root);

	final CLTranslations _root; // ignore: unused_field

	// Translations

	/// it: 'Pagina precedente'
	String get previousPage => 'Pagina precedente';

	/// it: 'Pagina successiva'
	String get nextPage => 'Pagina successiva';

	/// it: 'Zoom in'
	String get zoomIn => 'Zoom in';

	/// it: 'Zoom out'
	String get zoomOut => 'Zoom out';

	/// it: 'Reset zoom'
	String get zoomReset => 'Reset zoom';

	/// it: 'Impossibile caricare il PDF'
	String get pdfFailed => 'Impossibile caricare il PDF';
}

// Path: form.time
class CLTranslations$form$time$it {
	CLTranslations$form$time$it.internal(this._root);

	final CLTranslations _root; // ignore: unused_field

	// Translations

	/// it: 'Ore'
	String get hours => 'Ore';

	/// it: 'Minuti'
	String get minutes => 'Minuti';

	/// it: 'Secondi'
	String get seconds => 'Secondi';
}

// Path: form.validation
class CLTranslations$form$validation$it {
	CLTranslations$form$validation$it.internal(this._root);

	final CLTranslations _root; // ignore: unused_field

	// Translations

	/// it: 'Questo campo non può essere vuoto'
	String get required => 'Questo campo non può essere vuoto';

	/// it: 'Deve avere almeno $min caratteri'
	String minLength({required Object min}) => 'Deve avere almeno ${min} caratteri';

	/// it: 'Inserisci un'email valida'
	String get email => 'Inserisci un\'email valida';

	/// it: 'La password non può essere vuota'
	String get passwordEmpty => 'La password non può essere vuota';

	/// it: 'La password deve avere almeno 8 caratteri, una maiuscola, una minuscola, un numero e un simbolo'
	String get passwordWeak => 'La password deve avere almeno 8 caratteri, una maiuscola, una minuscola, un numero e un simbolo';
}

// Path: table.empty
class CLTranslations$table$empty$it {
	CLTranslations$table$empty$it.internal(this._root);

	final CLTranslations _root; // ignore: unused_field

	// Translations

	/// it: 'Nessun elemento trovato'
	String get noneFound => 'Nessun elemento trovato';

	/// it: 'Prova a modificare i filtri'
	String get tryFilters => 'Prova a modificare i filtri';

	/// it: 'Nessun risultato'
	String get noResults => 'Nessun risultato';

	/// it: 'Non c'è ancora niente'
	String get nothingYet => 'Non c\'è ancora niente';

	/// it: 'Prova a modificare i filtri di ricerca'
	String get tryFiltersSearch => 'Prova a modificare i filtri di ricerca';

	/// it: 'Qui compariranno gli elementi quando ce ne saranno'
	String get willAppear => 'Qui compariranno gli elementi quando ce ne saranno';
}

// Path: table.error
class CLTranslations$table$error$it {
	CLTranslations$table$error$it.internal(this._root);

	final CLTranslations _root; // ignore: unused_field

	// Translations

	/// it: 'Errore di caricamento'
	String get loading => 'Errore di caricamento';

	/// it: 'Si è verificato un errore'
	String get generic => 'Si è verificato un errore';

	/// it: 'Errore sconosciuto'
	String get unknown => 'Errore sconosciuto';
}

// Path: table.filter
class CLTranslations$table$filter$it {
	CLTranslations$table$filter$it.internal(this._root);

	final CLTranslations _root; // ignore: unused_field

	// Translations

	/// it: 'Filtri'
	String get title => 'Filtri';

	/// it: 'Filtri di ricerca'
	String get searchFilters => 'Filtri di ricerca';

	/// it: 'Filtra con...'
	String get filterWith => 'Filtra con...';

	/// it: 'Cerca per $title'
	String searchBy({required Object title}) => 'Cerca per ${title}';

	/// it: 'Filtra per $title'
	String filterBy({required Object title}) => 'Filtra per ${title}';

	/// it: '$title: $value'
	String chip({required Object title, required Object value}) => '${title}: ${value}';
}

// Path: table.sort
class CLTranslations$table$sort$it {
	CLTranslations$table$sort$it.internal(this._root);

	final CLTranslations _root; // ignore: unused_field

	// Translations

	/// it: 'Ordina per'
	String get by => 'Ordina per';

	/// it: 'Ordina'
	String get short => 'Ordina';

	/// it: '$column - Ascendente'
	String ascending({required Object column}) => '${column} - Ascendente';

	/// it: '$column - Discendente'
	String descending({required Object column}) => '${column} - Discendente';
}

// Path: table.footer
class CLTranslations$table$footer$it {
	CLTranslations$table$footer$it.internal(this._root);

	final CLTranslations _root; // ignore: unused_field

	// Translations

	/// it: '$start – $end di $total'
	String range({required Object start, required Object end, required Object total}) => '${start} – ${end} di ${total}';

	/// it: '0 risultati'
	String get none => '0 risultati';
}

/// The flat map containing all translations for locale <it>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on CLTranslations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'assistant.newConversation' => 'Nuova conversazione',
			'assistant.greeting' => 'Ciao',
			'assistant.greetingName' => ({required Object name}) => 'Ciao ${name}',
			'assistant.howCanIHelp' => 'Come posso aiutarti oggi?',
			'assistant.thinking' => 'Sto pensando…',
			'assistant.working' => 'Sto elaborando...',
			'assistant.scrollToBottom' => 'Vai in fondo',
			'assistant.privacy' => 'Skillera AI opera nel rispetto dei tuoi permessi e del GDPR. Verifica sempre le risposte.',
			'assistant.composer.hint' => 'Scrivi un messaggio...',
			'assistant.composer.reply' => 'Rispondi...',
			'assistant.composer.wait' => 'Attendi la risposta...',
			'assistant.composer.send' => 'Invia (Invio)',
			'assistant.composer.stop' => 'Stop',
			'assistant.conversations.title' => 'Conversazioni',
			'assistant.conversations.newConversation' => 'Nuova',
			'assistant.conversations.empty' => 'Nessuna conversazione salvata',
			'assistant.conversations.archive' => 'Archivia',
			'assistant.conversations.today' => 'oggi',
			'assistant.conversations.yesterday' => 'ieri',
			'assistant.conversations.daysAgo' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n, one: '${n}g fa', other: '${n}g fa', ), 
			'assistant.message.sending' => 'Invio…',
			'assistant.message.notSent' => 'Messaggio non inviato',
			'assistant.message.replyFailed' => 'Risposta non riuscita',
			'assistant.message.source' => ({required Object n, required Object label}) => 'Fonte ${n}: ${label}',
			'assistant.overlay.ask' => 'Chiedi qualcosa...',
			'assistant.overlay.intro' => 'Chiedimi informazioni su presenze, turni,\nanomalìe o naviga nelle sezioni.',
			'assistant.overlay.ready' => 'Pronto',
			'assistant.overlay.waitingForYou' => 'Aspetto te...',
			'assistant.overlay.waitingForResponse' => 'Aspetto la tua risposta...',
			'assistant.overlay.workingOnRequest' => 'Sto lavorando alla tua richiesta...',
			'assistant.overlay.tapToConfirm' => ({required Object label}) => 'Tocca «${label}» per confermare',
			'assistant.overlay.tapToViewChat' => 'Tocca per vedere la chat',
			'assistant.overlay.tapToSeeMore' => 'Tocca per vedere di più',
			'calendar.previousMonth' => 'Mese precedente',
			'calendar.nextMonth' => 'Mese successivo',
			'calendar.goToToday' => 'Vai ad oggi',
			'calendar.withWarnings' => 'Con avvisi',
			'calendar.noData' => 'Nessun dato',
			'command.hint' => 'Cerca…',
			'command.searching' => 'Ricerca…',
			'command.noResults' => 'Nessun risultato',
			'command.askAi' => ({required Object query}) => 'Chiedi all’AI: “${query}”',
			'common.actions.apply' => 'Applica',
			'common.actions.cancel' => 'Annulla',
			'common.actions.close' => 'Chiudi',
			'common.actions.confirm' => 'Conferma',
			'common.actions.copy' => 'Copia',
			'common.actions.delete' => 'Elimina',
			'common.actions.edit' => 'Modifica',
			'common.actions.more' => 'Altro',
			'common.actions.remove' => 'Rimuovi',
			'common.actions.reset' => 'Ripristina',
			'common.actions.retry' => 'Riprova',
			'common.actions.save' => 'Salva',
			'common.actions.search' => 'Cerca',
			'common.copied' => 'Copiato',
			'common.copiedText' => ({required Object text}) => 'Testo ${text} copiato',
			'common.error' => 'Errore',
			'common.errorCode' => ({required Object code}) => 'Codice ${code}',
			'common.warning' => 'Attenzione',
			'common.info' => 'Info',
			'common.home' => 'Home',
			'common.date.today' => 'Oggi',
			'common.date.monthYear' => ({required Object month, required Object year}) => '${month} ${year}',
			'common.date.monthsTitle.0' => 'Gennaio',
			'common.date.monthsTitle.1' => 'Febbraio',
			'common.date.monthsTitle.2' => 'Marzo',
			'common.date.monthsTitle.3' => 'Aprile',
			'common.date.monthsTitle.4' => 'Maggio',
			'common.date.monthsTitle.5' => 'Giugno',
			'common.date.monthsTitle.6' => 'Luglio',
			'common.date.monthsTitle.7' => 'Agosto',
			'common.date.monthsTitle.8' => 'Settembre',
			'common.date.monthsTitle.9' => 'Ottobre',
			'common.date.monthsTitle.10' => 'Novembre',
			'common.date.monthsTitle.11' => 'Dicembre',
			'common.date.weekdaysTitle.0' => 'Lun',
			'common.date.weekdaysTitle.1' => 'Mar',
			'common.date.weekdaysTitle.2' => 'Mer',
			'common.date.weekdaysTitle.3' => 'Gio',
			'common.date.weekdaysTitle.4' => 'Ven',
			'common.date.weekdaysTitle.5' => 'Sab',
			'common.date.weekdaysTitle.6' => 'Dom',
			'dialogs.confirmMessage' => 'Sei sicuro di voler effettuare quest\'operazione?',
			'dialogs.assign.pickMany' => 'Seleziona uno o più elementi',
			'dialogs.assign.pickOne' => 'Seleziona un elemento',
			'dialogs.assign.selected' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n, one: '${n} selezionato', other: '${n} selezionati', ), 
			'dialogs.assign.assign' => 'Assegna',
			'dialogs.assign.assignCount' => ({required Object count}) => 'Assegna (${count})',
			'dialogs.assign.search' => 'Cerca...',
			'dialogs.assign.empty' => 'Nessun elemento disponibile',
			'dialogs.assign.noResults' => 'Nessun risultato',
			'dialogs.assign.noMatch' => ({required Object query}) => 'Nessuna corrispondenza per "${query}"',
			'dialogs.qr.title' => 'QR Code',
			'dialogs.qr.copy' => 'Copia',
			'dialogs.qr.copied' => 'Codice copiato',
			'dropdown.placeholder' => 'Seleziona…',
			'dropdown.noResults' => 'Nessun risultato trovato',
			'files.invalidFile' => ({required Object name, required Object extensions}) => 'Il file ${name} non è valido. Le estensioni ammesse sono ${extensions}.',
			'files.noValidFile' => 'Nessun file valido selezionato.',
			'files.pickCancelled' => 'Selezione file annullata.',
			'files.pickerFailed' => ({required Object error}) => 'Impossibile aprire il selettore file: ${error}',
			'files.dropOrClick' => 'Trascina i file qui o clicca per caricare',
			'files.dropHere' => 'Rilascia i file qui',
			'files.limits' => ({required Object count, required Object extensions}) => 'Max ${count} file • ${extensions}',
			'files.kinds.image' => 'Immagine',
			'files.kinds.video' => 'Video',
			'files.kinds.word' => 'Documento Word',
			'files.kinds.excel' => 'Foglio Excel',
			'files.kinds.zip' => 'Archivio ZIP',
			'files.kinds.archive' => 'Archivio',
			'files.kinds.file' => 'File',
			'files.viewer.previousPage' => 'Pagina precedente',
			'files.viewer.nextPage' => 'Pagina successiva',
			'files.viewer.zoomIn' => 'Zoom in',
			'files.viewer.zoomOut' => 'Zoom out',
			'files.viewer.zoomReset' => 'Reset zoom',
			'files.viewer.pdfFailed' => 'Impossibile caricare il PDF',
			'form.pickFile' => 'Seleziona file',
			'form.pickDate' => 'Seleziona data',
			'form.pickRange' => 'Seleziona intervallo',
			'form.time.hours' => 'Ore',
			'form.time.minutes' => 'Minuti',
			'form.time.seconds' => 'Secondi',
			'form.validation.required' => 'Questo campo non può essere vuoto',
			'form.validation.minLength' => ({required Object min}) => 'Deve avere almeno ${min} caratteri',
			'form.validation.email' => 'Inserisci un\'email valida',
			'form.validation.passwordEmpty' => 'La password non può essere vuota',
			'form.validation.passwordWeak' => 'La password deve avere almeno 8 caratteri, una maiuscola, una minuscola, un numero e un simbolo',
			'table.selectPeriod' => 'Seleziona periodo',
			'table.selectedCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n, one: '${n} selezionato', other: '${n} selezionati', ), 
			'table.deselectAll' => 'Deseleziona tutto',
			'table.deselect' => 'Deseleziona',
			'table.actions' => 'Azioni',
			'table.moreActions' => 'Altre azioni',
			'table.download' => 'Download',
			'table.endOfList' => 'Non ci sono altri risultati',
			'table.empty.noneFound' => 'Nessun elemento trovato',
			'table.empty.tryFilters' => 'Prova a modificare i filtri',
			'table.empty.noResults' => 'Nessun risultato',
			'table.empty.nothingYet' => 'Non c\'è ancora niente',
			'table.empty.tryFiltersSearch' => 'Prova a modificare i filtri di ricerca',
			'table.empty.willAppear' => 'Qui compariranno gli elementi quando ce ne saranno',
			'table.error.loading' => 'Errore di caricamento',
			'table.error.generic' => 'Si è verificato un errore',
			'table.error.unknown' => 'Errore sconosciuto',
			'table.filter.title' => 'Filtri',
			'table.filter.searchFilters' => 'Filtri di ricerca',
			'table.filter.filterWith' => 'Filtra con...',
			'table.filter.searchBy' => ({required Object title}) => 'Cerca per ${title}',
			'table.filter.filterBy' => ({required Object title}) => 'Filtra per ${title}',
			'table.filter.chip' => ({required Object title, required Object value}) => '${title}: ${value}',
			'table.sort.by' => 'Ordina per',
			'table.sort.short' => 'Ordina',
			'table.sort.ascending' => ({required Object column}) => '${column} - Ascendente',
			'table.sort.descending' => ({required Object column}) => '${column} - Discendente',
			'table.footer.range' => ({required Object start, required Object end, required Object total}) => '${start} – ${end} di ${total}',
			'table.footer.none' => '0 risultati',
			_ => null,
		};
	}
}
