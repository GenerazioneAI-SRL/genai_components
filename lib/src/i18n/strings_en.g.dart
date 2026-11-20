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
class CLTranslationsEn extends CLTranslations with BaseTranslations<CLAppLocale, CLTranslations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [CLAppLocale.build] is preferred.
	CLTranslationsEn({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<CLAppLocale, CLTranslations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: CLAppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<CLAppLocale, CLTranslations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final CLTranslationsEn _root = this; // ignore: unused_field

	@override 
	CLTranslationsEn $copyWith({TranslationMetadata<CLAppLocale, CLTranslations>? meta}) => CLTranslationsEn(meta: meta ?? this.$meta);

	// Translations
	@override late final _CLTranslations$assistant$en assistant = _CLTranslations$assistant$en._(_root);
	@override late final _CLTranslations$calendar$en calendar = _CLTranslations$calendar$en._(_root);
	@override late final _CLTranslations$command$en command = _CLTranslations$command$en._(_root);
	@override late final _CLTranslations$common$en common = _CLTranslations$common$en._(_root);
	@override late final _CLTranslations$dialogs$en dialogs = _CLTranslations$dialogs$en._(_root);
	@override late final _CLTranslations$dropdown$en dropdown = _CLTranslations$dropdown$en._(_root);
	@override late final _CLTranslations$files$en files = _CLTranslations$files$en._(_root);
	@override late final _CLTranslations$form$en form = _CLTranslations$form$en._(_root);
	@override late final _CLTranslations$table$en table = _CLTranslations$table$en._(_root);
}

// Path: assistant
class _CLTranslations$assistant$en extends CLTranslations$assistant$it {
	_CLTranslations$assistant$en._(CLTranslationsEn root) : this._root = root, super.internal(root);

	final CLTranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get newConversation => 'New conversation';
	@override String get greeting => 'Hello';
	@override String greetingName({required Object name}) => 'Hello ${name}';
	@override String get howCanIHelp => 'How can I help you today?';
	@override String get thinking => 'Thinking…';
	@override String get working => 'Working on it...';
	@override String get scrollToBottom => 'Go to the bottom';
	@override String get privacy => 'Skillera AI respects your permissions and the GDPR. Always check the answers.';
	@override late final _CLTranslations$assistant$composer$en composer = _CLTranslations$assistant$composer$en._(_root);
	@override late final _CLTranslations$assistant$conversations$en conversations = _CLTranslations$assistant$conversations$en._(_root);
	@override late final _CLTranslations$assistant$message$en message = _CLTranslations$assistant$message$en._(_root);
	@override late final _CLTranslations$assistant$overlay$en overlay = _CLTranslations$assistant$overlay$en._(_root);
}

// Path: calendar
class _CLTranslations$calendar$en extends CLTranslations$calendar$it {
	_CLTranslations$calendar$en._(CLTranslationsEn root) : this._root = root, super.internal(root);

	final CLTranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get previousMonth => 'Previous month';
	@override String get nextMonth => 'Next month';
	@override String get goToToday => 'Go to today';
	@override String get withWarnings => 'With warnings';
	@override String get noData => 'No data';
}

// Path: command
class _CLTranslations$command$en extends CLTranslations$command$it {
	_CLTranslations$command$en._(CLTranslationsEn root) : this._root = root, super.internal(root);

	final CLTranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get hint => 'Search…';
	@override String get searching => 'Searching…';
	@override String get noResults => 'No results';
	@override String askAi({required Object query}) => 'Ask the AI: “${query}”';
}

// Path: common
class _CLTranslations$common$en extends CLTranslations$common$it {
	_CLTranslations$common$en._(CLTranslationsEn root) : this._root = root, super.internal(root);

	final CLTranslationsEn _root; // ignore: unused_field

	// Translations
	@override late final _CLTranslations$common$actions$en actions = _CLTranslations$common$actions$en._(_root);
	@override String get copied => 'Copied';
	@override String copiedText({required Object text}) => 'Text ${text} copied';
	@override String get error => 'Error';
	@override String errorCode({required Object code}) => 'Code ${code}';
	@override String get warning => 'Warning';
	@override String get info => 'Info';
	@override String get home => 'Home';
	@override late final _CLTranslations$common$date$en date = _CLTranslations$common$date$en._(_root);
}

// Path: dialogs
class _CLTranslations$dialogs$en extends CLTranslations$dialogs$it {
	_CLTranslations$dialogs$en._(CLTranslationsEn root) : this._root = root, super.internal(root);

	final CLTranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get confirmMessage => 'Are you sure you want to do this?';
	@override late final _CLTranslations$dialogs$assign$en assign = _CLTranslations$dialogs$assign$en._(_root);
	@override late final _CLTranslations$dialogs$qr$en qr = _CLTranslations$dialogs$qr$en._(_root);
}

// Path: dropdown
class _CLTranslations$dropdown$en extends CLTranslations$dropdown$it {
	_CLTranslations$dropdown$en._(CLTranslationsEn root) : this._root = root, super.internal(root);

	final CLTranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get placeholder => 'Select…';
	@override String get noResults => 'No results found';
}

// Path: files
class _CLTranslations$files$en extends CLTranslations$files$it {
	_CLTranslations$files$en._(CLTranslationsEn root) : this._root = root, super.internal(root);

	final CLTranslationsEn _root; // ignore: unused_field

	// Translations
	@override String invalidFile({required Object name, required Object extensions}) => 'The file ${name} isn\'t valid. Allowed extensions: ${extensions}.';
	@override String get noValidFile => 'No valid file selected.';
	@override String get pickCancelled => 'File selection cancelled.';
	@override String pickerFailed({required Object error}) => 'Couldn\'t open the file picker: ${error}';
	@override String get dropOrClick => 'Drag files here or click to upload';
	@override String get dropHere => 'Drop the files here';
	@override String limits({required Object count, required Object extensions}) => 'Max ${count} files • ${extensions}';
	@override late final _CLTranslations$files$kinds$en kinds = _CLTranslations$files$kinds$en._(_root);
	@override late final _CLTranslations$files$viewer$en viewer = _CLTranslations$files$viewer$en._(_root);
}

// Path: form
class _CLTranslations$form$en extends CLTranslations$form$it {
	_CLTranslations$form$en._(CLTranslationsEn root) : this._root = root, super.internal(root);

	final CLTranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get pickFile => 'Select file';
	@override String get pickDate => 'Select date';
	@override String get pickRange => 'Select range';
	@override late final _CLTranslations$form$time$en time = _CLTranslations$form$time$en._(_root);
	@override late final _CLTranslations$form$validation$en validation = _CLTranslations$form$validation$en._(_root);
}

// Path: table
class _CLTranslations$table$en extends CLTranslations$table$it {
	_CLTranslations$table$en._(CLTranslationsEn root) : this._root = root, super.internal(root);

	final CLTranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get selectPeriod => 'Select period';
	@override String selectedCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '${n} selected',
		other: '${n} selected',
	);
	@override String get deselectAll => 'Deselect all';
	@override String get deselect => 'Deselect';
	@override String get actions => 'Actions';
	@override String get moreActions => 'More actions';
	@override String get download => 'Download';
	@override String get endOfList => 'No more results';
	@override late final _CLTranslations$table$empty$en empty = _CLTranslations$table$empty$en._(_root);
	@override late final _CLTranslations$table$error$en error = _CLTranslations$table$error$en._(_root);
	@override late final _CLTranslations$table$filter$en filter = _CLTranslations$table$filter$en._(_root);
	@override late final _CLTranslations$table$sort$en sort = _CLTranslations$table$sort$en._(_root);
	@override late final _CLTranslations$table$footer$en footer = _CLTranslations$table$footer$en._(_root);
}

// Path: assistant.composer
class _CLTranslations$assistant$composer$en extends CLTranslations$assistant$composer$it {
	_CLTranslations$assistant$composer$en._(CLTranslationsEn root) : this._root = root, super.internal(root);

	final CLTranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get hint => 'Write a message...';
	@override String get reply => 'Reply...';
	@override String get wait => 'Wait for the answer...';
	@override String get send => 'Send (Enter)';
	@override String get stop => 'Stop';
}

// Path: assistant.conversations
class _CLTranslations$assistant$conversations$en extends CLTranslations$assistant$conversations$it {
	_CLTranslations$assistant$conversations$en._(CLTranslationsEn root) : this._root = root, super.internal(root);

	final CLTranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Conversations';
	@override String get newConversation => 'New';
	@override String get empty => 'No saved conversations';
	@override String get archive => 'Archive';
	@override String get today => 'today';
	@override String get yesterday => 'yesterday';
	@override String daysAgo({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '${n}d ago',
		other: '${n}d ago',
	);
}

// Path: assistant.message
class _CLTranslations$assistant$message$en extends CLTranslations$assistant$message$it {
	_CLTranslations$assistant$message$en._(CLTranslationsEn root) : this._root = root, super.internal(root);

	final CLTranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get sending => 'Sending…';
	@override String get notSent => 'Message not sent';
	@override String get replyFailed => 'Answer failed';
	@override String source({required Object n, required Object label}) => 'Source ${n}: ${label}';
}

// Path: assistant.overlay
class _CLTranslations$assistant$overlay$en extends CLTranslations$assistant$overlay$it {
	_CLTranslations$assistant$overlay$en._(CLTranslationsEn root) : this._root = root, super.internal(root);

	final CLTranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get ask => 'Ask something...';
	@override String get intro => 'Ask me about attendance, shifts,\nanomalies or move around the sections.';
	@override String get ready => 'Ready';
	@override String get waitingForYou => 'Waiting for you...';
	@override String get waitingForResponse => 'Waiting for your answer...';
	@override String get workingOnRequest => 'Working on your request...';
	@override String tapToConfirm({required Object label}) => 'Tap “${label}” to confirm';
	@override String get tapToViewChat => 'Tap to view the chat';
	@override String get tapToSeeMore => 'Tap to see more';
}

// Path: common.actions
class _CLTranslations$common$actions$en extends CLTranslations$common$actions$it {
	_CLTranslations$common$actions$en._(CLTranslationsEn root) : this._root = root, super.internal(root);

	final CLTranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get apply => 'Apply';
	@override String get cancel => 'Cancel';
	@override String get close => 'Close';
	@override String get confirm => 'Confirm';
	@override String get copy => 'Copy';
	@override String get delete => 'Delete';
	@override String get edit => 'Edit';
	@override String get more => 'More';
	@override String get remove => 'Remove';
	@override String get reset => 'Reset';
	@override String get retry => 'Try again';
	@override String get save => 'Save';
	@override String get search => 'Search';
}

// Path: common.date
class _CLTranslations$common$date$en extends CLTranslations$common$date$it {
	_CLTranslations$common$date$en._(CLTranslationsEn root) : this._root = root, super.internal(root);

	final CLTranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get today => 'Today';
	@override String monthYear({required Object month, required Object year}) => '${month} ${year}';
	@override List<String> get monthsTitle => [
		'January',
		'February',
		'March',
		'April',
		'May',
		'June',
		'July',
		'August',
		'September',
		'October',
		'November',
		'December',
	];
	@override List<String> get weekdaysTitle => [
		'Mon',
		'Tue',
		'Wed',
		'Thu',
		'Fri',
		'Sat',
		'Sun',
	];
}

// Path: dialogs.assign
class _CLTranslations$dialogs$assign$en extends CLTranslations$dialogs$assign$it {
	_CLTranslations$dialogs$assign$en._(CLTranslationsEn root) : this._root = root, super.internal(root);

	final CLTranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get pickMany => 'Select one or more items';
	@override String get pickOne => 'Select an item';
	@override String selected({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '${n} selected',
		other: '${n} selected',
	);
	@override String get assign => 'Assign';
	@override String assignCount({required Object count}) => 'Assign (${count})';
	@override String get search => 'Search...';
	@override String get empty => 'No items available';
	@override String get noResults => 'No results';
	@override String noMatch({required Object query}) => 'No matches for “${query}”';
}

// Path: dialogs.qr
class _CLTranslations$dialogs$qr$en extends CLTranslations$dialogs$qr$it {
	_CLTranslations$dialogs$qr$en._(CLTranslationsEn root) : this._root = root, super.internal(root);

	final CLTranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'QR code';
	@override String get copy => 'Copy';
	@override String get copied => 'Code copied';
}

// Path: files.kinds
class _CLTranslations$files$kinds$en extends CLTranslations$files$kinds$it {
	_CLTranslations$files$kinds$en._(CLTranslationsEn root) : this._root = root, super.internal(root);

	final CLTranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get image => 'Image';
	@override String get video => 'Video';
	@override String get word => 'Word document';
	@override String get excel => 'Excel spreadsheet';
	@override String get zip => 'ZIP archive';
	@override String get archive => 'Archive';
	@override String get file => 'File';
}

// Path: files.viewer
class _CLTranslations$files$viewer$en extends CLTranslations$files$viewer$it {
	_CLTranslations$files$viewer$en._(CLTranslationsEn root) : this._root = root, super.internal(root);

	final CLTranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get previousPage => 'Previous page';
	@override String get nextPage => 'Next page';
	@override String get zoomIn => 'Zoom in';
	@override String get zoomOut => 'Zoom out';
	@override String get zoomReset => 'Reset zoom';
	@override String get pdfFailed => 'Couldn\'t load the PDF';
}

// Path: form.time
class _CLTranslations$form$time$en extends CLTranslations$form$time$it {
	_CLTranslations$form$time$en._(CLTranslationsEn root) : this._root = root, super.internal(root);

	final CLTranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Hours';
	@override String get minutes => 'Minutes';
	@override String get seconds => 'Seconds';
}

// Path: form.validation
class _CLTranslations$form$validation$en extends CLTranslations$form$validation$it {
	_CLTranslations$form$validation$en._(CLTranslationsEn root) : this._root = root, super.internal(root);

	final CLTranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get required => 'This field can\'t be empty';
	@override String minLength({required Object min}) => 'Must be at least ${min} characters';
	@override String get email => 'Enter a valid email';
	@override String get passwordEmpty => 'The password can\'t be empty';
	@override String get passwordWeak => 'The password needs at least 8 characters, an uppercase letter, a lowercase letter, a number and a symbol';
}

// Path: table.empty
class _CLTranslations$table$empty$en extends CLTranslations$table$empty$it {
	_CLTranslations$table$empty$en._(CLTranslationsEn root) : this._root = root, super.internal(root);

	final CLTranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get noneFound => 'No items found';
	@override String get tryFilters => 'Try changing the filters';
	@override String get noResults => 'No results';
	@override String get nothingYet => 'Nothing here yet';
	@override String get tryFiltersSearch => 'Try changing the search filters';
	@override String get willAppear => 'Items will appear here when there are some';
}

// Path: table.error
class _CLTranslations$table$error$en extends CLTranslations$table$error$it {
	_CLTranslations$table$error$en._(CLTranslationsEn root) : this._root = root, super.internal(root);

	final CLTranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get loading => 'Couldn\'t load';
	@override String get generic => 'Something went wrong';
	@override String get unknown => 'Unknown error';
}

// Path: table.filter
class _CLTranslations$table$filter$en extends CLTranslations$table$filter$it {
	_CLTranslations$table$filter$en._(CLTranslationsEn root) : this._root = root, super.internal(root);

	final CLTranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Filters';
	@override String get searchFilters => 'Search filters';
	@override String get filterWith => 'Filter by...';
	@override String searchBy({required Object title}) => 'Search by ${title}';
	@override String filterBy({required Object title}) => 'Filter by ${title}';
	@override String chip({required Object title, required Object value}) => '${title}: ${value}';
}

// Path: table.sort
class _CLTranslations$table$sort$en extends CLTranslations$table$sort$it {
	_CLTranslations$table$sort$en._(CLTranslationsEn root) : this._root = root, super.internal(root);

	final CLTranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get by => 'Sort by';
	@override String get short => 'Sort';
	@override String ascending({required Object column}) => '${column} - Ascending';
	@override String descending({required Object column}) => '${column} - Descending';
}

// Path: table.footer
class _CLTranslations$table$footer$en extends CLTranslations$table$footer$it {
	_CLTranslations$table$footer$en._(CLTranslationsEn root) : this._root = root, super.internal(root);

	final CLTranslationsEn _root; // ignore: unused_field

	// Translations
	@override String range({required Object start, required Object end, required Object total}) => '${start} – ${end} of ${total}';
	@override String get none => '0 results';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on CLTranslationsEn {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'assistant.newConversation' => 'New conversation',
			'assistant.greeting' => 'Hello',
			'assistant.greetingName' => ({required Object name}) => 'Hello ${name}',
			'assistant.howCanIHelp' => 'How can I help you today?',
			'assistant.thinking' => 'Thinking…',
			'assistant.working' => 'Working on it...',
			'assistant.scrollToBottom' => 'Go to the bottom',
			'assistant.privacy' => 'Skillera AI respects your permissions and the GDPR. Always check the answers.',
			'assistant.composer.hint' => 'Write a message...',
			'assistant.composer.reply' => 'Reply...',
			'assistant.composer.wait' => 'Wait for the answer...',
			'assistant.composer.send' => 'Send (Enter)',
			'assistant.composer.stop' => 'Stop',
			'assistant.conversations.title' => 'Conversations',
			'assistant.conversations.newConversation' => 'New',
			'assistant.conversations.empty' => 'No saved conversations',
			'assistant.conversations.archive' => 'Archive',
			'assistant.conversations.today' => 'today',
			'assistant.conversations.yesterday' => 'yesterday',
			'assistant.conversations.daysAgo' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '${n}d ago', other: '${n}d ago', ), 
			'assistant.message.sending' => 'Sending…',
			'assistant.message.notSent' => 'Message not sent',
			'assistant.message.replyFailed' => 'Answer failed',
			'assistant.message.source' => ({required Object n, required Object label}) => 'Source ${n}: ${label}',
			'assistant.overlay.ask' => 'Ask something...',
			'assistant.overlay.intro' => 'Ask me about attendance, shifts,\nanomalies or move around the sections.',
			'assistant.overlay.ready' => 'Ready',
			'assistant.overlay.waitingForYou' => 'Waiting for you...',
			'assistant.overlay.waitingForResponse' => 'Waiting for your answer...',
			'assistant.overlay.workingOnRequest' => 'Working on your request...',
			'assistant.overlay.tapToConfirm' => ({required Object label}) => 'Tap “${label}” to confirm',
			'assistant.overlay.tapToViewChat' => 'Tap to view the chat',
			'assistant.overlay.tapToSeeMore' => 'Tap to see more',
			'calendar.previousMonth' => 'Previous month',
			'calendar.nextMonth' => 'Next month',
			'calendar.goToToday' => 'Go to today',
			'calendar.withWarnings' => 'With warnings',
			'calendar.noData' => 'No data',
			'command.hint' => 'Search…',
			'command.searching' => 'Searching…',
			'command.noResults' => 'No results',
			'command.askAi' => ({required Object query}) => 'Ask the AI: “${query}”',
			'common.actions.apply' => 'Apply',
			'common.actions.cancel' => 'Cancel',
			'common.actions.close' => 'Close',
			'common.actions.confirm' => 'Confirm',
			'common.actions.copy' => 'Copy',
			'common.actions.delete' => 'Delete',
			'common.actions.edit' => 'Edit',
			'common.actions.more' => 'More',
			'common.actions.remove' => 'Remove',
			'common.actions.reset' => 'Reset',
			'common.actions.retry' => 'Try again',
			'common.actions.save' => 'Save',
			'common.actions.search' => 'Search',
			'common.copied' => 'Copied',
			'common.copiedText' => ({required Object text}) => 'Text ${text} copied',
			'common.error' => 'Error',
			'common.errorCode' => ({required Object code}) => 'Code ${code}',
			'common.warning' => 'Warning',
			'common.info' => 'Info',
			'common.home' => 'Home',
			'common.date.today' => 'Today',
			'common.date.monthYear' => ({required Object month, required Object year}) => '${month} ${year}',
			'common.date.monthsTitle.0' => 'January',
			'common.date.monthsTitle.1' => 'February',
			'common.date.monthsTitle.2' => 'March',
			'common.date.monthsTitle.3' => 'April',
			'common.date.monthsTitle.4' => 'May',
			'common.date.monthsTitle.5' => 'June',
			'common.date.monthsTitle.6' => 'July',
			'common.date.monthsTitle.7' => 'August',
			'common.date.monthsTitle.8' => 'September',
			'common.date.monthsTitle.9' => 'October',
			'common.date.monthsTitle.10' => 'November',
			'common.date.monthsTitle.11' => 'December',
			'common.date.weekdaysTitle.0' => 'Mon',
			'common.date.weekdaysTitle.1' => 'Tue',
			'common.date.weekdaysTitle.2' => 'Wed',
			'common.date.weekdaysTitle.3' => 'Thu',
			'common.date.weekdaysTitle.4' => 'Fri',
			'common.date.weekdaysTitle.5' => 'Sat',
			'common.date.weekdaysTitle.6' => 'Sun',
			'dialogs.confirmMessage' => 'Are you sure you want to do this?',
			'dialogs.assign.pickMany' => 'Select one or more items',
			'dialogs.assign.pickOne' => 'Select an item',
			'dialogs.assign.selected' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '${n} selected', other: '${n} selected', ), 
			'dialogs.assign.assign' => 'Assign',
			'dialogs.assign.assignCount' => ({required Object count}) => 'Assign (${count})',
			'dialogs.assign.search' => 'Search...',
			'dialogs.assign.empty' => 'No items available',
			'dialogs.assign.noResults' => 'No results',
			'dialogs.assign.noMatch' => ({required Object query}) => 'No matches for “${query}”',
			'dialogs.qr.title' => 'QR code',
			'dialogs.qr.copy' => 'Copy',
			'dialogs.qr.copied' => 'Code copied',
			'dropdown.placeholder' => 'Select…',
			'dropdown.noResults' => 'No results found',
			'files.invalidFile' => ({required Object name, required Object extensions}) => 'The file ${name} isn\'t valid. Allowed extensions: ${extensions}.',
			'files.noValidFile' => 'No valid file selected.',
			'files.pickCancelled' => 'File selection cancelled.',
			'files.pickerFailed' => ({required Object error}) => 'Couldn\'t open the file picker: ${error}',
			'files.dropOrClick' => 'Drag files here or click to upload',
			'files.dropHere' => 'Drop the files here',
			'files.limits' => ({required Object count, required Object extensions}) => 'Max ${count} files • ${extensions}',
			'files.kinds.image' => 'Image',
			'files.kinds.video' => 'Video',
			'files.kinds.word' => 'Word document',
			'files.kinds.excel' => 'Excel spreadsheet',
			'files.kinds.zip' => 'ZIP archive',
			'files.kinds.archive' => 'Archive',
			'files.kinds.file' => 'File',
			'files.viewer.previousPage' => 'Previous page',
			'files.viewer.nextPage' => 'Next page',
			'files.viewer.zoomIn' => 'Zoom in',
			'files.viewer.zoomOut' => 'Zoom out',
			'files.viewer.zoomReset' => 'Reset zoom',
			'files.viewer.pdfFailed' => 'Couldn\'t load the PDF',
			'form.pickFile' => 'Select file',
			'form.pickDate' => 'Select date',
			'form.pickRange' => 'Select range',
			'form.time.hours' => 'Hours',
			'form.time.minutes' => 'Minutes',
			'form.time.seconds' => 'Seconds',
			'form.validation.required' => 'This field can\'t be empty',
			'form.validation.minLength' => ({required Object min}) => 'Must be at least ${min} characters',
			'form.validation.email' => 'Enter a valid email',
			'form.validation.passwordEmpty' => 'The password can\'t be empty',
			'form.validation.passwordWeak' => 'The password needs at least 8 characters, an uppercase letter, a lowercase letter, a number and a symbol',
			'table.selectPeriod' => 'Select period',
			'table.selectedCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '${n} selected', other: '${n} selected', ), 
			'table.deselectAll' => 'Deselect all',
			'table.deselect' => 'Deselect',
			'table.actions' => 'Actions',
			'table.moreActions' => 'More actions',
			'table.download' => 'Download',
			'table.endOfList' => 'No more results',
			'table.empty.noneFound' => 'No items found',
			'table.empty.tryFilters' => 'Try changing the filters',
			'table.empty.noResults' => 'No results',
			'table.empty.nothingYet' => 'Nothing here yet',
			'table.empty.tryFiltersSearch' => 'Try changing the search filters',
			'table.empty.willAppear' => 'Items will appear here when there are some',
			'table.error.loading' => 'Couldn\'t load',
			'table.error.generic' => 'Something went wrong',
			'table.error.unknown' => 'Unknown error',
			'table.filter.title' => 'Filters',
			'table.filter.searchFilters' => 'Search filters',
			'table.filter.filterWith' => 'Filter by...',
			'table.filter.searchBy' => ({required Object title}) => 'Search by ${title}',
			'table.filter.filterBy' => ({required Object title}) => 'Filter by ${title}',
			'table.filter.chip' => ({required Object title, required Object value}) => '${title}: ${value}',
			'table.sort.by' => 'Sort by',
			'table.sort.short' => 'Sort',
			'table.sort.ascending' => ({required Object column}) => '${column} - Ascending',
			'table.sort.descending' => ({required Object column}) => '${column} - Descending',
			'table.footer.range' => ({required Object start, required Object end, required Object total}) => '${start} – ${end} of ${total}',
			'table.footer.none' => '0 results',
			_ => null,
		};
	}
}
