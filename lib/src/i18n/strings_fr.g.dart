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
class CLTranslationsFr extends CLTranslations with BaseTranslations<CLAppLocale, CLTranslations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [CLAppLocale.build] is preferred.
	CLTranslationsFr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<CLAppLocale, CLTranslations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: CLAppLocale.fr,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <fr>.
	@override final TranslationMetadata<CLAppLocale, CLTranslations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final CLTranslationsFr _root = this; // ignore: unused_field

	@override 
	CLTranslationsFr $copyWith({TranslationMetadata<CLAppLocale, CLTranslations>? meta}) => CLTranslationsFr(meta: meta ?? this.$meta);

	// Translations
	@override late final _CLTranslations$assistant$fr assistant = _CLTranslations$assistant$fr._(_root);
	@override late final _CLTranslations$calendar$fr calendar = _CLTranslations$calendar$fr._(_root);
	@override late final _CLTranslations$command$fr command = _CLTranslations$command$fr._(_root);
	@override late final _CLTranslations$common$fr common = _CLTranslations$common$fr._(_root);
	@override late final _CLTranslations$dialogs$fr dialogs = _CLTranslations$dialogs$fr._(_root);
	@override late final _CLTranslations$dropdown$fr dropdown = _CLTranslations$dropdown$fr._(_root);
	@override late final _CLTranslations$files$fr files = _CLTranslations$files$fr._(_root);
	@override late final _CLTranslations$form$fr form = _CLTranslations$form$fr._(_root);
	@override late final _CLTranslations$table$fr table = _CLTranslations$table$fr._(_root);
}

// Path: assistant
class _CLTranslations$assistant$fr extends CLTranslations$assistant$it {
	_CLTranslations$assistant$fr._(CLTranslationsFr root) : this._root = root, super.internal(root);

	final CLTranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get newConversation => 'Nouvelle conversation';
	@override String get greeting => 'Bonjour';
	@override String greetingName({required Object name}) => 'Bonjour ${name}';
	@override String get howCanIHelp => 'Comment puis-je vous aider aujourd\'hui ?';
	@override String get thinking => 'Réflexion en cours…';
	@override String get working => 'Traitement en cours...';
	@override String get scrollToBottom => 'Aller en bas';
	@override String get privacy => 'Skillera AI respecte vos autorisations et le RGPD. Vérifiez toujours les réponses.';
	@override late final _CLTranslations$assistant$composer$fr composer = _CLTranslations$assistant$composer$fr._(_root);
	@override late final _CLTranslations$assistant$conversations$fr conversations = _CLTranslations$assistant$conversations$fr._(_root);
	@override late final _CLTranslations$assistant$message$fr message = _CLTranslations$assistant$message$fr._(_root);
	@override late final _CLTranslations$assistant$overlay$fr overlay = _CLTranslations$assistant$overlay$fr._(_root);
}

// Path: calendar
class _CLTranslations$calendar$fr extends CLTranslations$calendar$it {
	_CLTranslations$calendar$fr._(CLTranslationsFr root) : this._root = root, super.internal(root);

	final CLTranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get previousMonth => 'Mois précédent';
	@override String get nextMonth => 'Mois suivant';
	@override String get goToToday => 'Aller à aujourd\'hui';
	@override String get withWarnings => 'Avec alertes';
	@override String get noData => 'Aucune donnée';
}

// Path: command
class _CLTranslations$command$fr extends CLTranslations$command$it {
	_CLTranslations$command$fr._(CLTranslationsFr root) : this._root = root, super.internal(root);

	final CLTranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get hint => 'Rechercher…';
	@override String get searching => 'Recherche…';
	@override String get noResults => 'Aucun résultat';
	@override String askAi({required Object query}) => 'Demander à l\'IA : « ${query} »';
}

// Path: common
class _CLTranslations$common$fr extends CLTranslations$common$it {
	_CLTranslations$common$fr._(CLTranslationsFr root) : this._root = root, super.internal(root);

	final CLTranslationsFr _root; // ignore: unused_field

	// Translations
	@override late final _CLTranslations$common$actions$fr actions = _CLTranslations$common$actions$fr._(_root);
	@override String get copied => 'Copié';
	@override String copiedText({required Object text}) => 'Texte ${text} copié';
	@override String get error => 'Erreur';
	@override String errorCode({required Object code}) => 'Code ${code}';
	@override String get warning => 'Attention';
	@override String get info => 'Info';
	@override String get home => 'Accueil';
	@override late final _CLTranslations$common$date$fr date = _CLTranslations$common$date$fr._(_root);
}

// Path: dialogs
class _CLTranslations$dialogs$fr extends CLTranslations$dialogs$it {
	_CLTranslations$dialogs$fr._(CLTranslationsFr root) : this._root = root, super.internal(root);

	final CLTranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get confirmMessage => 'Voulez-vous vraiment effectuer cette opération ?';
	@override late final _CLTranslations$dialogs$assign$fr assign = _CLTranslations$dialogs$assign$fr._(_root);
	@override late final _CLTranslations$dialogs$qr$fr qr = _CLTranslations$dialogs$qr$fr._(_root);
}

// Path: dropdown
class _CLTranslations$dropdown$fr extends CLTranslations$dropdown$it {
	_CLTranslations$dropdown$fr._(CLTranslationsFr root) : this._root = root, super.internal(root);

	final CLTranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get placeholder => 'Choisir…';
	@override String get noResults => 'Aucun résultat trouvé';
}

// Path: files
class _CLTranslations$files$fr extends CLTranslations$files$it {
	_CLTranslations$files$fr._(CLTranslationsFr root) : this._root = root, super.internal(root);

	final CLTranslationsFr _root; // ignore: unused_field

	// Translations
	@override String invalidFile({required Object name, required Object extensions}) => 'Le fichier ${name} n\'est pas valide. Extensions autorisées : ${extensions}.';
	@override String get noValidFile => 'Aucun fichier valide sélectionné.';
	@override String get pickCancelled => 'Sélection de fichier annulée.';
	@override String pickerFailed({required Object error}) => 'Impossible d\'ouvrir le sélecteur de fichiers : ${error}';
	@override String get dropOrClick => 'Faites glisser les fichiers ici ou cliquez pour importer';
	@override String get dropHere => 'Déposez les fichiers ici';
	@override String limits({required Object count, required Object extensions}) => '${count} fichiers max • ${extensions}';
	@override late final _CLTranslations$files$kinds$fr kinds = _CLTranslations$files$kinds$fr._(_root);
	@override late final _CLTranslations$files$viewer$fr viewer = _CLTranslations$files$viewer$fr._(_root);
}

// Path: form
class _CLTranslations$form$fr extends CLTranslations$form$it {
	_CLTranslations$form$fr._(CLTranslationsFr root) : this._root = root, super.internal(root);

	final CLTranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get pickFile => 'Choisir un fichier';
	@override String get pickDate => 'Choisir une date';
	@override String get pickRange => 'Choisir une période';
	@override late final _CLTranslations$form$time$fr time = _CLTranslations$form$time$fr._(_root);
	@override late final _CLTranslations$form$validation$fr validation = _CLTranslations$form$validation$fr._(_root);
}

// Path: table
class _CLTranslations$table$fr extends CLTranslations$table$it {
	_CLTranslations$table$fr._(CLTranslationsFr root) : this._root = root, super.internal(root);

	final CLTranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get selectPeriod => 'Choisir la période';
	@override String selectedCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('fr'))(n,
		one: '${n} sélectionné',
		other: '${n} sélectionnés',
	);
	@override String get deselectAll => 'Tout désélectionner';
	@override String get deselect => 'Désélectionner';
	@override String get actions => 'Actions';
	@override String get moreActions => 'Autres actions';
	@override String get download => 'Télécharger';
	@override String get endOfList => 'Il n\'y a pas d\'autres résultats';
	@override late final _CLTranslations$table$empty$fr empty = _CLTranslations$table$empty$fr._(_root);
	@override late final _CLTranslations$table$error$fr error = _CLTranslations$table$error$fr._(_root);
	@override late final _CLTranslations$table$filter$fr filter = _CLTranslations$table$filter$fr._(_root);
	@override late final _CLTranslations$table$sort$fr sort = _CLTranslations$table$sort$fr._(_root);
	@override late final _CLTranslations$table$footer$fr footer = _CLTranslations$table$footer$fr._(_root);
}

// Path: assistant.composer
class _CLTranslations$assistant$composer$fr extends CLTranslations$assistant$composer$it {
	_CLTranslations$assistant$composer$fr._(CLTranslationsFr root) : this._root = root, super.internal(root);

	final CLTranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get hint => 'Écrivez un message...';
	@override String get reply => 'Répondez...';
	@override String get wait => 'Attendez la réponse...';
	@override String get send => 'Envoyer (Entrée)';
	@override String get stop => 'Arrêter';
}

// Path: assistant.conversations
class _CLTranslations$assistant$conversations$fr extends CLTranslations$assistant$conversations$it {
	_CLTranslations$assistant$conversations$fr._(CLTranslationsFr root) : this._root = root, super.internal(root);

	final CLTranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Conversations';
	@override String get newConversation => 'Nouvelle';
	@override String get empty => 'Aucune conversation enregistrée';
	@override String get archive => 'Archiver';
	@override String get today => 'aujourd\'hui';
	@override String get yesterday => 'hier';
	@override String daysAgo({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('fr'))(n,
		one: 'il y a ${n} j',
		other: 'il y a ${n} j',
	);
}

// Path: assistant.message
class _CLTranslations$assistant$message$fr extends CLTranslations$assistant$message$it {
	_CLTranslations$assistant$message$fr._(CLTranslationsFr root) : this._root = root, super.internal(root);

	final CLTranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get sending => 'Envoi…';
	@override String get notSent => 'Message non envoyé';
	@override String get replyFailed => 'Réponse impossible';
	@override String source({required Object n, required Object label}) => 'Source ${n} : ${label}';
}

// Path: assistant.overlay
class _CLTranslations$assistant$overlay$fr extends CLTranslations$assistant$overlay$it {
	_CLTranslations$assistant$overlay$fr._(CLTranslationsFr root) : this._root = root, super.internal(root);

	final CLTranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get ask => 'Posez une question...';
	@override String get intro => 'Demandez-moi des informations sur les présences, les shifts,\nles anomalies ou naviguez dans les sections.';
	@override String get ready => 'Prêt';
	@override String get waitingForYou => 'Je vous attends...';
	@override String get waitingForResponse => 'J\'attends votre réponse...';
	@override String get workingOnRequest => 'Je traite votre demande...';
	@override String tapToConfirm({required Object label}) => 'Touchez « ${label} » pour confirmer';
	@override String get tapToViewChat => 'Touchez pour voir la conversation';
	@override String get tapToSeeMore => 'Touchez pour en voir plus';
}

// Path: common.actions
class _CLTranslations$common$actions$fr extends CLTranslations$common$actions$it {
	_CLTranslations$common$actions$fr._(CLTranslationsFr root) : this._root = root, super.internal(root);

	final CLTranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get apply => 'Appliquer';
	@override String get cancel => 'Annuler';
	@override String get close => 'Fermer';
	@override String get confirm => 'Confirmer';
	@override String get copy => 'Copier';
	@override String get delete => 'Supprimer';
	@override String get edit => 'Modifier';
	@override String get more => 'Plus';
	@override String get remove => 'Retirer';
	@override String get reset => 'Réinitialiser';
	@override String get retry => 'Réessayer';
	@override String get save => 'Enregistrer';
	@override String get search => 'Rechercher';
}

// Path: common.date
class _CLTranslations$common$date$fr extends CLTranslations$common$date$it {
	_CLTranslations$common$date$fr._(CLTranslationsFr root) : this._root = root, super.internal(root);

	final CLTranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get today => 'Aujourd\'hui';
	@override String monthYear({required Object month, required Object year}) => '${month} ${year}';
	@override List<String> get monthsTitle => [
		'Janvier',
		'Février',
		'Mars',
		'Avril',
		'Mai',
		'Juin',
		'Juillet',
		'Août',
		'Septembre',
		'Octobre',
		'Novembre',
		'Décembre',
	];
	@override List<String> get weekdaysTitle => [
		'Lun',
		'Mar',
		'Mer',
		'Jeu',
		'Ven',
		'Sam',
		'Dim',
	];
}

// Path: dialogs.assign
class _CLTranslations$dialogs$assign$fr extends CLTranslations$dialogs$assign$it {
	_CLTranslations$dialogs$assign$fr._(CLTranslationsFr root) : this._root = root, super.internal(root);

	final CLTranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get pickMany => 'Sélectionnez un ou plusieurs éléments';
	@override String get pickOne => 'Sélectionnez un élément';
	@override String selected({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('fr'))(n,
		one: '${n} sélectionné',
		other: '${n} sélectionnés',
	);
	@override String get assign => 'Attribuer';
	@override String assignCount({required Object count}) => 'Attribuer (${count})';
	@override String get search => 'Rechercher...';
	@override String get empty => 'Aucun élément disponible';
	@override String get noResults => 'Aucun résultat';
	@override String noMatch({required Object query}) => 'Aucune correspondance pour « ${query} »';
}

// Path: dialogs.qr
class _CLTranslations$dialogs$qr$fr extends CLTranslations$dialogs$qr$it {
	_CLTranslations$dialogs$qr$fr._(CLTranslationsFr root) : this._root = root, super.internal(root);

	final CLTranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Code QR';
	@override String get copy => 'Copier';
	@override String get copied => 'Code copié';
}

// Path: files.kinds
class _CLTranslations$files$kinds$fr extends CLTranslations$files$kinds$it {
	_CLTranslations$files$kinds$fr._(CLTranslationsFr root) : this._root = root, super.internal(root);

	final CLTranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get image => 'Image';
	@override String get video => 'Vidéo';
	@override String get word => 'Document Word';
	@override String get excel => 'Feuille Excel';
	@override String get zip => 'Archive ZIP';
	@override String get archive => 'Archive';
	@override String get file => 'Fichier';
}

// Path: files.viewer
class _CLTranslations$files$viewer$fr extends CLTranslations$files$viewer$it {
	_CLTranslations$files$viewer$fr._(CLTranslationsFr root) : this._root = root, super.internal(root);

	final CLTranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get previousPage => 'Page précédente';
	@override String get nextPage => 'Page suivante';
	@override String get zoomIn => 'Zoom avant';
	@override String get zoomOut => 'Zoom arrière';
	@override String get zoomReset => 'Réinitialiser le zoom';
	@override String get pdfFailed => 'Impossible de charger le PDF';
}

// Path: form.time
class _CLTranslations$form$time$fr extends CLTranslations$form$time$it {
	_CLTranslations$form$time$fr._(CLTranslationsFr root) : this._root = root, super.internal(root);

	final CLTranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Heures';
	@override String get minutes => 'Minutes';
	@override String get seconds => 'Secondes';
}

// Path: form.validation
class _CLTranslations$form$validation$fr extends CLTranslations$form$validation$it {
	_CLTranslations$form$validation$fr._(CLTranslationsFr root) : this._root = root, super.internal(root);

	final CLTranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get required => 'Ce champ ne peut pas être vide';
	@override String minLength({required Object min}) => 'Au moins ${min} caractères';
	@override String get email => 'Saisissez une adresse e-mail valide';
	@override String get passwordEmpty => 'Le mot de passe ne peut pas être vide';
	@override String get passwordWeak => 'Le mot de passe doit contenir au moins 8 caractères, une majuscule, une minuscule, un chiffre et un symbole';
}

// Path: table.empty
class _CLTranslations$table$empty$fr extends CLTranslations$table$empty$it {
	_CLTranslations$table$empty$fr._(CLTranslationsFr root) : this._root = root, super.internal(root);

	final CLTranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get noneFound => 'Aucun élément trouvé';
	@override String get tryFilters => 'Essayez de modifier les filtres';
	@override String get noResults => 'Aucun résultat';
	@override String get nothingYet => 'Il n\'y a encore rien';
	@override String get tryFiltersSearch => 'Essayez de modifier les filtres de recherche';
	@override String get willAppear => 'Les éléments apparaîtront ici dès qu\'il y en aura';
}

// Path: table.error
class _CLTranslations$table$error$fr extends CLTranslations$table$error$it {
	_CLTranslations$table$error$fr._(CLTranslationsFr root) : this._root = root, super.internal(root);

	final CLTranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get loading => 'Erreur de chargement';
	@override String get generic => 'Une erreur s\'est produite';
	@override String get unknown => 'Erreur inconnue';
}

// Path: table.filter
class _CLTranslations$table$filter$fr extends CLTranslations$table$filter$it {
	_CLTranslations$table$filter$fr._(CLTranslationsFr root) : this._root = root, super.internal(root);

	final CLTranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Filtres';
	@override String get searchFilters => 'Filtres de recherche';
	@override String get filterWith => 'Filtrer par...';
	@override String searchBy({required Object title}) => 'Rechercher par ${title}';
	@override String filterBy({required Object title}) => 'Filtrer par ${title}';
	@override String chip({required Object title, required Object value}) => '${title} : ${value}';
}

// Path: table.sort
class _CLTranslations$table$sort$fr extends CLTranslations$table$sort$it {
	_CLTranslations$table$sort$fr._(CLTranslationsFr root) : this._root = root, super.internal(root);

	final CLTranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get by => 'Trier par';
	@override String get short => 'Trier';
	@override String ascending({required Object column}) => '${column} - Croissant';
	@override String descending({required Object column}) => '${column} - Décroissant';
}

// Path: table.footer
class _CLTranslations$table$footer$fr extends CLTranslations$table$footer$it {
	_CLTranslations$table$footer$fr._(CLTranslationsFr root) : this._root = root, super.internal(root);

	final CLTranslationsFr _root; // ignore: unused_field

	// Translations
	@override String range({required Object start, required Object end, required Object total}) => '${start} – ${end} sur ${total}';
	@override String get none => '0 résultat';
}

/// The flat map containing all translations for locale <fr>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on CLTranslationsFr {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'assistant.newConversation' => 'Nouvelle conversation',
			'assistant.greeting' => 'Bonjour',
			'assistant.greetingName' => ({required Object name}) => 'Bonjour ${name}',
			'assistant.howCanIHelp' => 'Comment puis-je vous aider aujourd\'hui ?',
			'assistant.thinking' => 'Réflexion en cours…',
			'assistant.working' => 'Traitement en cours...',
			'assistant.scrollToBottom' => 'Aller en bas',
			'assistant.privacy' => 'Skillera AI respecte vos autorisations et le RGPD. Vérifiez toujours les réponses.',
			'assistant.composer.hint' => 'Écrivez un message...',
			'assistant.composer.reply' => 'Répondez...',
			'assistant.composer.wait' => 'Attendez la réponse...',
			'assistant.composer.send' => 'Envoyer (Entrée)',
			'assistant.composer.stop' => 'Arrêter',
			'assistant.conversations.title' => 'Conversations',
			'assistant.conversations.newConversation' => 'Nouvelle',
			'assistant.conversations.empty' => 'Aucune conversation enregistrée',
			'assistant.conversations.archive' => 'Archiver',
			'assistant.conversations.today' => 'aujourd\'hui',
			'assistant.conversations.yesterday' => 'hier',
			'assistant.conversations.daysAgo' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('fr'))(n, one: 'il y a ${n} j', other: 'il y a ${n} j', ), 
			'assistant.message.sending' => 'Envoi…',
			'assistant.message.notSent' => 'Message non envoyé',
			'assistant.message.replyFailed' => 'Réponse impossible',
			'assistant.message.source' => ({required Object n, required Object label}) => 'Source ${n} : ${label}',
			'assistant.overlay.ask' => 'Posez une question...',
			'assistant.overlay.intro' => 'Demandez-moi des informations sur les présences, les shifts,\nles anomalies ou naviguez dans les sections.',
			'assistant.overlay.ready' => 'Prêt',
			'assistant.overlay.waitingForYou' => 'Je vous attends...',
			'assistant.overlay.waitingForResponse' => 'J\'attends votre réponse...',
			'assistant.overlay.workingOnRequest' => 'Je traite votre demande...',
			'assistant.overlay.tapToConfirm' => ({required Object label}) => 'Touchez « ${label} » pour confirmer',
			'assistant.overlay.tapToViewChat' => 'Touchez pour voir la conversation',
			'assistant.overlay.tapToSeeMore' => 'Touchez pour en voir plus',
			'calendar.previousMonth' => 'Mois précédent',
			'calendar.nextMonth' => 'Mois suivant',
			'calendar.goToToday' => 'Aller à aujourd\'hui',
			'calendar.withWarnings' => 'Avec alertes',
			'calendar.noData' => 'Aucune donnée',
			'command.hint' => 'Rechercher…',
			'command.searching' => 'Recherche…',
			'command.noResults' => 'Aucun résultat',
			'command.askAi' => ({required Object query}) => 'Demander à l\'IA : « ${query} »',
			'common.actions.apply' => 'Appliquer',
			'common.actions.cancel' => 'Annuler',
			'common.actions.close' => 'Fermer',
			'common.actions.confirm' => 'Confirmer',
			'common.actions.copy' => 'Copier',
			'common.actions.delete' => 'Supprimer',
			'common.actions.edit' => 'Modifier',
			'common.actions.more' => 'Plus',
			'common.actions.remove' => 'Retirer',
			'common.actions.reset' => 'Réinitialiser',
			'common.actions.retry' => 'Réessayer',
			'common.actions.save' => 'Enregistrer',
			'common.actions.search' => 'Rechercher',
			'common.copied' => 'Copié',
			'common.copiedText' => ({required Object text}) => 'Texte ${text} copié',
			'common.error' => 'Erreur',
			'common.errorCode' => ({required Object code}) => 'Code ${code}',
			'common.warning' => 'Attention',
			'common.info' => 'Info',
			'common.home' => 'Accueil',
			'common.date.today' => 'Aujourd\'hui',
			'common.date.monthYear' => ({required Object month, required Object year}) => '${month} ${year}',
			'common.date.monthsTitle.0' => 'Janvier',
			'common.date.monthsTitle.1' => 'Février',
			'common.date.monthsTitle.2' => 'Mars',
			'common.date.monthsTitle.3' => 'Avril',
			'common.date.monthsTitle.4' => 'Mai',
			'common.date.monthsTitle.5' => 'Juin',
			'common.date.monthsTitle.6' => 'Juillet',
			'common.date.monthsTitle.7' => 'Août',
			'common.date.monthsTitle.8' => 'Septembre',
			'common.date.monthsTitle.9' => 'Octobre',
			'common.date.monthsTitle.10' => 'Novembre',
			'common.date.monthsTitle.11' => 'Décembre',
			'common.date.weekdaysTitle.0' => 'Lun',
			'common.date.weekdaysTitle.1' => 'Mar',
			'common.date.weekdaysTitle.2' => 'Mer',
			'common.date.weekdaysTitle.3' => 'Jeu',
			'common.date.weekdaysTitle.4' => 'Ven',
			'common.date.weekdaysTitle.5' => 'Sam',
			'common.date.weekdaysTitle.6' => 'Dim',
			'dialogs.confirmMessage' => 'Voulez-vous vraiment effectuer cette opération ?',
			'dialogs.assign.pickMany' => 'Sélectionnez un ou plusieurs éléments',
			'dialogs.assign.pickOne' => 'Sélectionnez un élément',
			'dialogs.assign.selected' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('fr'))(n, one: '${n} sélectionné', other: '${n} sélectionnés', ), 
			'dialogs.assign.assign' => 'Attribuer',
			'dialogs.assign.assignCount' => ({required Object count}) => 'Attribuer (${count})',
			'dialogs.assign.search' => 'Rechercher...',
			'dialogs.assign.empty' => 'Aucun élément disponible',
			'dialogs.assign.noResults' => 'Aucun résultat',
			'dialogs.assign.noMatch' => ({required Object query}) => 'Aucune correspondance pour « ${query} »',
			'dialogs.qr.title' => 'Code QR',
			'dialogs.qr.copy' => 'Copier',
			'dialogs.qr.copied' => 'Code copié',
			'dropdown.placeholder' => 'Choisir…',
			'dropdown.noResults' => 'Aucun résultat trouvé',
			'files.invalidFile' => ({required Object name, required Object extensions}) => 'Le fichier ${name} n\'est pas valide. Extensions autorisées : ${extensions}.',
			'files.noValidFile' => 'Aucun fichier valide sélectionné.',
			'files.pickCancelled' => 'Sélection de fichier annulée.',
			'files.pickerFailed' => ({required Object error}) => 'Impossible d\'ouvrir le sélecteur de fichiers : ${error}',
			'files.dropOrClick' => 'Faites glisser les fichiers ici ou cliquez pour importer',
			'files.dropHere' => 'Déposez les fichiers ici',
			'files.limits' => ({required Object count, required Object extensions}) => '${count} fichiers max • ${extensions}',
			'files.kinds.image' => 'Image',
			'files.kinds.video' => 'Vidéo',
			'files.kinds.word' => 'Document Word',
			'files.kinds.excel' => 'Feuille Excel',
			'files.kinds.zip' => 'Archive ZIP',
			'files.kinds.archive' => 'Archive',
			'files.kinds.file' => 'Fichier',
			'files.viewer.previousPage' => 'Page précédente',
			'files.viewer.nextPage' => 'Page suivante',
			'files.viewer.zoomIn' => 'Zoom avant',
			'files.viewer.zoomOut' => 'Zoom arrière',
			'files.viewer.zoomReset' => 'Réinitialiser le zoom',
			'files.viewer.pdfFailed' => 'Impossible de charger le PDF',
			'form.pickFile' => 'Choisir un fichier',
			'form.pickDate' => 'Choisir une date',
			'form.pickRange' => 'Choisir une période',
			'form.time.hours' => 'Heures',
			'form.time.minutes' => 'Minutes',
			'form.time.seconds' => 'Secondes',
			'form.validation.required' => 'Ce champ ne peut pas être vide',
			'form.validation.minLength' => ({required Object min}) => 'Au moins ${min} caractères',
			'form.validation.email' => 'Saisissez une adresse e-mail valide',
			'form.validation.passwordEmpty' => 'Le mot de passe ne peut pas être vide',
			'form.validation.passwordWeak' => 'Le mot de passe doit contenir au moins 8 caractères, une majuscule, une minuscule, un chiffre et un symbole',
			'table.selectPeriod' => 'Choisir la période',
			'table.selectedCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('fr'))(n, one: '${n} sélectionné', other: '${n} sélectionnés', ), 
			'table.deselectAll' => 'Tout désélectionner',
			'table.deselect' => 'Désélectionner',
			'table.actions' => 'Actions',
			'table.moreActions' => 'Autres actions',
			'table.download' => 'Télécharger',
			'table.endOfList' => 'Il n\'y a pas d\'autres résultats',
			'table.empty.noneFound' => 'Aucun élément trouvé',
			'table.empty.tryFilters' => 'Essayez de modifier les filtres',
			'table.empty.noResults' => 'Aucun résultat',
			'table.empty.nothingYet' => 'Il n\'y a encore rien',
			'table.empty.tryFiltersSearch' => 'Essayez de modifier les filtres de recherche',
			'table.empty.willAppear' => 'Les éléments apparaîtront ici dès qu\'il y en aura',
			'table.error.loading' => 'Erreur de chargement',
			'table.error.generic' => 'Une erreur s\'est produite',
			'table.error.unknown' => 'Erreur inconnue',
			'table.filter.title' => 'Filtres',
			'table.filter.searchFilters' => 'Filtres de recherche',
			'table.filter.filterWith' => 'Filtrer par...',
			'table.filter.searchBy' => ({required Object title}) => 'Rechercher par ${title}',
			'table.filter.filterBy' => ({required Object title}) => 'Filtrer par ${title}',
			'table.filter.chip' => ({required Object title, required Object value}) => '${title} : ${value}',
			'table.sort.by' => 'Trier par',
			'table.sort.short' => 'Trier',
			'table.sort.ascending' => ({required Object column}) => '${column} - Croissant',
			'table.sort.descending' => ({required Object column}) => '${column} - Décroissant',
			'table.footer.range' => ({required Object start, required Object end, required Object total}) => '${start} – ${end} sur ${total}',
			'table.footer.none' => '0 résultat',
			_ => null,
		};
	}
}
