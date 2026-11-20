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
class CLTranslationsEs extends CLTranslations with BaseTranslations<CLAppLocale, CLTranslations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [CLAppLocale.build] is preferred.
	CLTranslationsEs({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<CLAppLocale, CLTranslations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: CLAppLocale.es,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <es>.
	@override final TranslationMetadata<CLAppLocale, CLTranslations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final CLTranslationsEs _root = this; // ignore: unused_field

	@override 
	CLTranslationsEs $copyWith({TranslationMetadata<CLAppLocale, CLTranslations>? meta}) => CLTranslationsEs(meta: meta ?? this.$meta);

	// Translations
	@override late final _CLTranslations$assistant$es assistant = _CLTranslations$assistant$es._(_root);
	@override late final _CLTranslations$calendar$es calendar = _CLTranslations$calendar$es._(_root);
	@override late final _CLTranslations$command$es command = _CLTranslations$command$es._(_root);
	@override late final _CLTranslations$common$es common = _CLTranslations$common$es._(_root);
	@override late final _CLTranslations$dialogs$es dialogs = _CLTranslations$dialogs$es._(_root);
	@override late final _CLTranslations$dropdown$es dropdown = _CLTranslations$dropdown$es._(_root);
	@override late final _CLTranslations$files$es files = _CLTranslations$files$es._(_root);
	@override late final _CLTranslations$form$es form = _CLTranslations$form$es._(_root);
	@override late final _CLTranslations$table$es table = _CLTranslations$table$es._(_root);
}

// Path: assistant
class _CLTranslations$assistant$es extends CLTranslations$assistant$it {
	_CLTranslations$assistant$es._(CLTranslationsEs root) : this._root = root, super.internal(root);

	final CLTranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get newConversation => 'Nueva conversación';
	@override String get greeting => 'Hola';
	@override String greetingName({required Object name}) => 'Hola, ${name}';
	@override String get howCanIHelp => '¿En qué puedo ayudarte hoy?';
	@override String get thinking => 'Pensando…';
	@override String get working => 'Procesando...';
	@override String get scrollToBottom => 'Ir al final';
	@override String get privacy => 'Skillera AI respeta tus permisos y el RGPD. Comprueba siempre las respuestas.';
	@override late final _CLTranslations$assistant$composer$es composer = _CLTranslations$assistant$composer$es._(_root);
	@override late final _CLTranslations$assistant$conversations$es conversations = _CLTranslations$assistant$conversations$es._(_root);
	@override late final _CLTranslations$assistant$message$es message = _CLTranslations$assistant$message$es._(_root);
	@override late final _CLTranslations$assistant$overlay$es overlay = _CLTranslations$assistant$overlay$es._(_root);
}

// Path: calendar
class _CLTranslations$calendar$es extends CLTranslations$calendar$it {
	_CLTranslations$calendar$es._(CLTranslationsEs root) : this._root = root, super.internal(root);

	final CLTranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get previousMonth => 'Mes anterior';
	@override String get nextMonth => 'Mes siguiente';
	@override String get goToToday => 'Ir a hoy';
	@override String get withWarnings => 'Con avisos';
	@override String get noData => 'Sin datos';
}

// Path: command
class _CLTranslations$command$es extends CLTranslations$command$it {
	_CLTranslations$command$es._(CLTranslationsEs root) : this._root = root, super.internal(root);

	final CLTranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get hint => 'Buscar…';
	@override String get searching => 'Buscando…';
	@override String get noResults => 'Sin resultados';
	@override String askAi({required Object query}) => 'Preguntar a la IA: «${query}»';
}

// Path: common
class _CLTranslations$common$es extends CLTranslations$common$it {
	_CLTranslations$common$es._(CLTranslationsEs root) : this._root = root, super.internal(root);

	final CLTranslationsEs _root; // ignore: unused_field

	// Translations
	@override late final _CLTranslations$common$actions$es actions = _CLTranslations$common$actions$es._(_root);
	@override String get copied => 'Copiado';
	@override String copiedText({required Object text}) => 'Texto ${text} copiado';
	@override String get error => 'Error';
	@override String errorCode({required Object code}) => 'Código ${code}';
	@override String get warning => 'Atención';
	@override String get info => 'Info';
	@override String get home => 'Inicio';
	@override late final _CLTranslations$common$date$es date = _CLTranslations$common$date$es._(_root);
}

// Path: dialogs
class _CLTranslations$dialogs$es extends CLTranslations$dialogs$it {
	_CLTranslations$dialogs$es._(CLTranslationsEs root) : this._root = root, super.internal(root);

	final CLTranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get confirmMessage => '¿Seguro que quieres realizar esta operación?';
	@override late final _CLTranslations$dialogs$assign$es assign = _CLTranslations$dialogs$assign$es._(_root);
	@override late final _CLTranslations$dialogs$qr$es qr = _CLTranslations$dialogs$qr$es._(_root);
}

// Path: dropdown
class _CLTranslations$dropdown$es extends CLTranslations$dropdown$it {
	_CLTranslations$dropdown$es._(CLTranslationsEs root) : this._root = root, super.internal(root);

	final CLTranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get placeholder => 'Elige…';
	@override String get noResults => 'No se han encontrado resultados';
}

// Path: files
class _CLTranslations$files$es extends CLTranslations$files$it {
	_CLTranslations$files$es._(CLTranslationsEs root) : this._root = root, super.internal(root);

	final CLTranslationsEs _root; // ignore: unused_field

	// Translations
	@override String invalidFile({required Object name, required Object extensions}) => 'El archivo ${name} no es válido. Extensiones permitidas: ${extensions}.';
	@override String get noValidFile => 'No se ha seleccionado ningún archivo válido.';
	@override String get pickCancelled => 'Selección de archivo cancelada.';
	@override String pickerFailed({required Object error}) => 'No se puede abrir el selector de archivos: ${error}';
	@override String get dropOrClick => 'Arrastra los archivos aquí o haz clic para subirlos';
	@override String get dropHere => 'Suelta los archivos aquí';
	@override String limits({required Object count, required Object extensions}) => 'Máx. ${count} archivos • ${extensions}';
	@override late final _CLTranslations$files$kinds$es kinds = _CLTranslations$files$kinds$es._(_root);
	@override late final _CLTranslations$files$viewer$es viewer = _CLTranslations$files$viewer$es._(_root);
}

// Path: form
class _CLTranslations$form$es extends CLTranslations$form$it {
	_CLTranslations$form$es._(CLTranslationsEs root) : this._root = root, super.internal(root);

	final CLTranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get pickFile => 'Elegir archivo';
	@override String get pickDate => 'Elegir fecha';
	@override String get pickRange => 'Elegir periodo';
	@override late final _CLTranslations$form$time$es time = _CLTranslations$form$time$es._(_root);
	@override late final _CLTranslations$form$validation$es validation = _CLTranslations$form$validation$es._(_root);
}

// Path: table
class _CLTranslations$table$es extends CLTranslations$table$it {
	_CLTranslations$table$es._(CLTranslationsEs root) : this._root = root, super.internal(root);

	final CLTranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get selectPeriod => 'Elegir periodo';
	@override String selectedCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
		one: '${n} seleccionado',
		other: '${n} seleccionados',
	);
	@override String get deselectAll => 'Deseleccionar todo';
	@override String get deselect => 'Deseleccionar';
	@override String get actions => 'Acciones';
	@override String get moreActions => 'Más acciones';
	@override String get download => 'Descargar';
	@override String get endOfList => 'No hay más resultados';
	@override late final _CLTranslations$table$empty$es empty = _CLTranslations$table$empty$es._(_root);
	@override late final _CLTranslations$table$error$es error = _CLTranslations$table$error$es._(_root);
	@override late final _CLTranslations$table$filter$es filter = _CLTranslations$table$filter$es._(_root);
	@override late final _CLTranslations$table$sort$es sort = _CLTranslations$table$sort$es._(_root);
	@override late final _CLTranslations$table$footer$es footer = _CLTranslations$table$footer$es._(_root);
}

// Path: assistant.composer
class _CLTranslations$assistant$composer$es extends CLTranslations$assistant$composer$it {
	_CLTranslations$assistant$composer$es._(CLTranslationsEs root) : this._root = root, super.internal(root);

	final CLTranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get hint => 'Escribe un mensaje...';
	@override String get reply => 'Responde...';
	@override String get wait => 'Espera la respuesta...';
	@override String get send => 'Enviar (Intro)';
	@override String get stop => 'Detener';
}

// Path: assistant.conversations
class _CLTranslations$assistant$conversations$es extends CLTranslations$assistant$conversations$it {
	_CLTranslations$assistant$conversations$es._(CLTranslationsEs root) : this._root = root, super.internal(root);

	final CLTranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Conversaciones';
	@override String get newConversation => 'Nueva';
	@override String get empty => 'No hay conversaciones guardadas';
	@override String get archive => 'Archivar';
	@override String get today => 'hoy';
	@override String get yesterday => 'ayer';
	@override String daysAgo({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
		one: 'hace ${n} d',
		other: 'hace ${n} d',
	);
}

// Path: assistant.message
class _CLTranslations$assistant$message$es extends CLTranslations$assistant$message$it {
	_CLTranslations$assistant$message$es._(CLTranslationsEs root) : this._root = root, super.internal(root);

	final CLTranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get sending => 'Enviando…';
	@override String get notSent => 'Mensaje no enviado';
	@override String get replyFailed => 'Respuesta fallida';
	@override String source({required Object n, required Object label}) => 'Fuente ${n}: ${label}';
}

// Path: assistant.overlay
class _CLTranslations$assistant$overlay$es extends CLTranslations$assistant$overlay$it {
	_CLTranslations$assistant$overlay$es._(CLTranslationsEs root) : this._root = root, super.internal(root);

	final CLTranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get ask => 'Pregunta algo...';
	@override String get intro => 'Pregúntame sobre asistencia, turnos,\nanomalías o muévete por las secciones.';
	@override String get ready => 'Listo';
	@override String get waitingForYou => 'Te espero...';
	@override String get waitingForResponse => 'Espero tu respuesta...';
	@override String get workingOnRequest => 'Estoy trabajando en tu solicitud...';
	@override String tapToConfirm({required Object label}) => 'Toca «${label}» para confirmar';
	@override String get tapToViewChat => 'Toca para ver el chat';
	@override String get tapToSeeMore => 'Toca para ver más';
}

// Path: common.actions
class _CLTranslations$common$actions$es extends CLTranslations$common$actions$it {
	_CLTranslations$common$actions$es._(CLTranslationsEs root) : this._root = root, super.internal(root);

	final CLTranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get apply => 'Aplicar';
	@override String get cancel => 'Cancelar';
	@override String get close => 'Cerrar';
	@override String get confirm => 'Confirmar';
	@override String get copy => 'Copiar';
	@override String get delete => 'Eliminar';
	@override String get edit => 'Editar';
	@override String get more => 'Más';
	@override String get remove => 'Quitar';
	@override String get reset => 'Restablecer';
	@override String get retry => 'Reintentar';
	@override String get save => 'Guardar';
	@override String get search => 'Buscar';
}

// Path: common.date
class _CLTranslations$common$date$es extends CLTranslations$common$date$it {
	_CLTranslations$common$date$es._(CLTranslationsEs root) : this._root = root, super.internal(root);

	final CLTranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get today => 'Hoy';
	@override String monthYear({required Object month, required Object year}) => '${month} ${year}';
	@override List<String> get monthsTitle => [
		'Enero',
		'Febrero',
		'Marzo',
		'Abril',
		'Mayo',
		'Junio',
		'Julio',
		'Agosto',
		'Septiembre',
		'Octubre',
		'Noviembre',
		'Diciembre',
	];
	@override List<String> get weekdaysTitle => [
		'Lun',
		'Mar',
		'Mié',
		'Jue',
		'Vie',
		'Sáb',
		'Dom',
	];
}

// Path: dialogs.assign
class _CLTranslations$dialogs$assign$es extends CLTranslations$dialogs$assign$it {
	_CLTranslations$dialogs$assign$es._(CLTranslationsEs root) : this._root = root, super.internal(root);

	final CLTranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get pickMany => 'Selecciona uno o más elementos';
	@override String get pickOne => 'Selecciona un elemento';
	@override String selected({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
		one: '${n} seleccionado',
		other: '${n} seleccionados',
	);
	@override String get assign => 'Asignar';
	@override String assignCount({required Object count}) => 'Asignar (${count})';
	@override String get search => 'Buscar...';
	@override String get empty => 'No hay elementos disponibles';
	@override String get noResults => 'Sin resultados';
	@override String noMatch({required Object query}) => 'Ninguna coincidencia para «${query}»';
}

// Path: dialogs.qr
class _CLTranslations$dialogs$qr$es extends CLTranslations$dialogs$qr$it {
	_CLTranslations$dialogs$qr$es._(CLTranslationsEs root) : this._root = root, super.internal(root);

	final CLTranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Código QR';
	@override String get copy => 'Copiar';
	@override String get copied => 'Código copiado';
}

// Path: files.kinds
class _CLTranslations$files$kinds$es extends CLTranslations$files$kinds$it {
	_CLTranslations$files$kinds$es._(CLTranslationsEs root) : this._root = root, super.internal(root);

	final CLTranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get image => 'Imagen';
	@override String get video => 'Vídeo';
	@override String get word => 'Documento de Word';
	@override String get excel => 'Hoja de Excel';
	@override String get zip => 'Archivo ZIP';
	@override String get archive => 'Archivo comprimido';
	@override String get file => 'Archivo';
}

// Path: files.viewer
class _CLTranslations$files$viewer$es extends CLTranslations$files$viewer$it {
	_CLTranslations$files$viewer$es._(CLTranslationsEs root) : this._root = root, super.internal(root);

	final CLTranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get previousPage => 'Página anterior';
	@override String get nextPage => 'Página siguiente';
	@override String get zoomIn => 'Acercar';
	@override String get zoomOut => 'Alejar';
	@override String get zoomReset => 'Restablecer zoom';
	@override String get pdfFailed => 'No se puede cargar el PDF';
}

// Path: form.time
class _CLTranslations$form$time$es extends CLTranslations$form$time$it {
	_CLTranslations$form$time$es._(CLTranslationsEs root) : this._root = root, super.internal(root);

	final CLTranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get hours => 'Horas';
	@override String get minutes => 'Minutos';
	@override String get seconds => 'Segundos';
}

// Path: form.validation
class _CLTranslations$form$validation$es extends CLTranslations$form$validation$it {
	_CLTranslations$form$validation$es._(CLTranslationsEs root) : this._root = root, super.internal(root);

	final CLTranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get required => 'Este campo no puede estar vacío';
	@override String minLength({required Object min}) => 'Debe tener al menos ${min} caracteres';
	@override String get email => 'Introduce un correo electrónico válido';
	@override String get passwordEmpty => 'La contraseña no puede estar vacía';
	@override String get passwordWeak => 'La contraseña necesita al menos 8 caracteres, una mayúscula, una minúscula, un número y un símbolo';
}

// Path: table.empty
class _CLTranslations$table$empty$es extends CLTranslations$table$empty$it {
	_CLTranslations$table$empty$es._(CLTranslationsEs root) : this._root = root, super.internal(root);

	final CLTranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get noneFound => 'No se ha encontrado ningún elemento';
	@override String get tryFilters => 'Prueba a cambiar los filtros';
	@override String get noResults => 'Sin resultados';
	@override String get nothingYet => 'Aún no hay nada';
	@override String get tryFiltersSearch => 'Prueba a cambiar los filtros de búsqueda';
	@override String get willAppear => 'Los elementos aparecerán aquí cuando los haya';
}

// Path: table.error
class _CLTranslations$table$error$es extends CLTranslations$table$error$it {
	_CLTranslations$table$error$es._(CLTranslationsEs root) : this._root = root, super.internal(root);

	final CLTranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get loading => 'Error al cargar';
	@override String get generic => 'Se ha producido un error';
	@override String get unknown => 'Error desconocido';
}

// Path: table.filter
class _CLTranslations$table$filter$es extends CLTranslations$table$filter$it {
	_CLTranslations$table$filter$es._(CLTranslationsEs root) : this._root = root, super.internal(root);

	final CLTranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Filtros';
	@override String get searchFilters => 'Filtros de búsqueda';
	@override String get filterWith => 'Filtrar por...';
	@override String searchBy({required Object title}) => 'Buscar por ${title}';
	@override String filterBy({required Object title}) => 'Filtrar por ${title}';
	@override String chip({required Object title, required Object value}) => '${title}: ${value}';
}

// Path: table.sort
class _CLTranslations$table$sort$es extends CLTranslations$table$sort$it {
	_CLTranslations$table$sort$es._(CLTranslationsEs root) : this._root = root, super.internal(root);

	final CLTranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get by => 'Ordenar por';
	@override String get short => 'Ordenar';
	@override String ascending({required Object column}) => '${column} - Ascendente';
	@override String descending({required Object column}) => '${column} - Descendente';
}

// Path: table.footer
class _CLTranslations$table$footer$es extends CLTranslations$table$footer$it {
	_CLTranslations$table$footer$es._(CLTranslationsEs root) : this._root = root, super.internal(root);

	final CLTranslationsEs _root; // ignore: unused_field

	// Translations
	@override String range({required Object start, required Object end, required Object total}) => '${start} – ${end} de ${total}';
	@override String get none => '0 resultados';
}

/// The flat map containing all translations for locale <es>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on CLTranslationsEs {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'assistant.newConversation' => 'Nueva conversación',
			'assistant.greeting' => 'Hola',
			'assistant.greetingName' => ({required Object name}) => 'Hola, ${name}',
			'assistant.howCanIHelp' => '¿En qué puedo ayudarte hoy?',
			'assistant.thinking' => 'Pensando…',
			'assistant.working' => 'Procesando...',
			'assistant.scrollToBottom' => 'Ir al final',
			'assistant.privacy' => 'Skillera AI respeta tus permisos y el RGPD. Comprueba siempre las respuestas.',
			'assistant.composer.hint' => 'Escribe un mensaje...',
			'assistant.composer.reply' => 'Responde...',
			'assistant.composer.wait' => 'Espera la respuesta...',
			'assistant.composer.send' => 'Enviar (Intro)',
			'assistant.composer.stop' => 'Detener',
			'assistant.conversations.title' => 'Conversaciones',
			'assistant.conversations.newConversation' => 'Nueva',
			'assistant.conversations.empty' => 'No hay conversaciones guardadas',
			'assistant.conversations.archive' => 'Archivar',
			'assistant.conversations.today' => 'hoy',
			'assistant.conversations.yesterday' => 'ayer',
			'assistant.conversations.daysAgo' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n, one: 'hace ${n} d', other: 'hace ${n} d', ), 
			'assistant.message.sending' => 'Enviando…',
			'assistant.message.notSent' => 'Mensaje no enviado',
			'assistant.message.replyFailed' => 'Respuesta fallida',
			'assistant.message.source' => ({required Object n, required Object label}) => 'Fuente ${n}: ${label}',
			'assistant.overlay.ask' => 'Pregunta algo...',
			'assistant.overlay.intro' => 'Pregúntame sobre asistencia, turnos,\nanomalías o muévete por las secciones.',
			'assistant.overlay.ready' => 'Listo',
			'assistant.overlay.waitingForYou' => 'Te espero...',
			'assistant.overlay.waitingForResponse' => 'Espero tu respuesta...',
			'assistant.overlay.workingOnRequest' => 'Estoy trabajando en tu solicitud...',
			'assistant.overlay.tapToConfirm' => ({required Object label}) => 'Toca «${label}» para confirmar',
			'assistant.overlay.tapToViewChat' => 'Toca para ver el chat',
			'assistant.overlay.tapToSeeMore' => 'Toca para ver más',
			'calendar.previousMonth' => 'Mes anterior',
			'calendar.nextMonth' => 'Mes siguiente',
			'calendar.goToToday' => 'Ir a hoy',
			'calendar.withWarnings' => 'Con avisos',
			'calendar.noData' => 'Sin datos',
			'command.hint' => 'Buscar…',
			'command.searching' => 'Buscando…',
			'command.noResults' => 'Sin resultados',
			'command.askAi' => ({required Object query}) => 'Preguntar a la IA: «${query}»',
			'common.actions.apply' => 'Aplicar',
			'common.actions.cancel' => 'Cancelar',
			'common.actions.close' => 'Cerrar',
			'common.actions.confirm' => 'Confirmar',
			'common.actions.copy' => 'Copiar',
			'common.actions.delete' => 'Eliminar',
			'common.actions.edit' => 'Editar',
			'common.actions.more' => 'Más',
			'common.actions.remove' => 'Quitar',
			'common.actions.reset' => 'Restablecer',
			'common.actions.retry' => 'Reintentar',
			'common.actions.save' => 'Guardar',
			'common.actions.search' => 'Buscar',
			'common.copied' => 'Copiado',
			'common.copiedText' => ({required Object text}) => 'Texto ${text} copiado',
			'common.error' => 'Error',
			'common.errorCode' => ({required Object code}) => 'Código ${code}',
			'common.warning' => 'Atención',
			'common.info' => 'Info',
			'common.home' => 'Inicio',
			'common.date.today' => 'Hoy',
			'common.date.monthYear' => ({required Object month, required Object year}) => '${month} ${year}',
			'common.date.monthsTitle.0' => 'Enero',
			'common.date.monthsTitle.1' => 'Febrero',
			'common.date.monthsTitle.2' => 'Marzo',
			'common.date.monthsTitle.3' => 'Abril',
			'common.date.monthsTitle.4' => 'Mayo',
			'common.date.monthsTitle.5' => 'Junio',
			'common.date.monthsTitle.6' => 'Julio',
			'common.date.monthsTitle.7' => 'Agosto',
			'common.date.monthsTitle.8' => 'Septiembre',
			'common.date.monthsTitle.9' => 'Octubre',
			'common.date.monthsTitle.10' => 'Noviembre',
			'common.date.monthsTitle.11' => 'Diciembre',
			'common.date.weekdaysTitle.0' => 'Lun',
			'common.date.weekdaysTitle.1' => 'Mar',
			'common.date.weekdaysTitle.2' => 'Mié',
			'common.date.weekdaysTitle.3' => 'Jue',
			'common.date.weekdaysTitle.4' => 'Vie',
			'common.date.weekdaysTitle.5' => 'Sáb',
			'common.date.weekdaysTitle.6' => 'Dom',
			'dialogs.confirmMessage' => '¿Seguro que quieres realizar esta operación?',
			'dialogs.assign.pickMany' => 'Selecciona uno o más elementos',
			'dialogs.assign.pickOne' => 'Selecciona un elemento',
			'dialogs.assign.selected' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n, one: '${n} seleccionado', other: '${n} seleccionados', ), 
			'dialogs.assign.assign' => 'Asignar',
			'dialogs.assign.assignCount' => ({required Object count}) => 'Asignar (${count})',
			'dialogs.assign.search' => 'Buscar...',
			'dialogs.assign.empty' => 'No hay elementos disponibles',
			'dialogs.assign.noResults' => 'Sin resultados',
			'dialogs.assign.noMatch' => ({required Object query}) => 'Ninguna coincidencia para «${query}»',
			'dialogs.qr.title' => 'Código QR',
			'dialogs.qr.copy' => 'Copiar',
			'dialogs.qr.copied' => 'Código copiado',
			'dropdown.placeholder' => 'Elige…',
			'dropdown.noResults' => 'No se han encontrado resultados',
			'files.invalidFile' => ({required Object name, required Object extensions}) => 'El archivo ${name} no es válido. Extensiones permitidas: ${extensions}.',
			'files.noValidFile' => 'No se ha seleccionado ningún archivo válido.',
			'files.pickCancelled' => 'Selección de archivo cancelada.',
			'files.pickerFailed' => ({required Object error}) => 'No se puede abrir el selector de archivos: ${error}',
			'files.dropOrClick' => 'Arrastra los archivos aquí o haz clic para subirlos',
			'files.dropHere' => 'Suelta los archivos aquí',
			'files.limits' => ({required Object count, required Object extensions}) => 'Máx. ${count} archivos • ${extensions}',
			'files.kinds.image' => 'Imagen',
			'files.kinds.video' => 'Vídeo',
			'files.kinds.word' => 'Documento de Word',
			'files.kinds.excel' => 'Hoja de Excel',
			'files.kinds.zip' => 'Archivo ZIP',
			'files.kinds.archive' => 'Archivo comprimido',
			'files.kinds.file' => 'Archivo',
			'files.viewer.previousPage' => 'Página anterior',
			'files.viewer.nextPage' => 'Página siguiente',
			'files.viewer.zoomIn' => 'Acercar',
			'files.viewer.zoomOut' => 'Alejar',
			'files.viewer.zoomReset' => 'Restablecer zoom',
			'files.viewer.pdfFailed' => 'No se puede cargar el PDF',
			'form.pickFile' => 'Elegir archivo',
			'form.pickDate' => 'Elegir fecha',
			'form.pickRange' => 'Elegir periodo',
			'form.time.hours' => 'Horas',
			'form.time.minutes' => 'Minutos',
			'form.time.seconds' => 'Segundos',
			'form.validation.required' => 'Este campo no puede estar vacío',
			'form.validation.minLength' => ({required Object min}) => 'Debe tener al menos ${min} caracteres',
			'form.validation.email' => 'Introduce un correo electrónico válido',
			'form.validation.passwordEmpty' => 'La contraseña no puede estar vacía',
			'form.validation.passwordWeak' => 'La contraseña necesita al menos 8 caracteres, una mayúscula, una minúscula, un número y un símbolo',
			'table.selectPeriod' => 'Elegir periodo',
			'table.selectedCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n, one: '${n} seleccionado', other: '${n} seleccionados', ), 
			'table.deselectAll' => 'Deseleccionar todo',
			'table.deselect' => 'Deseleccionar',
			'table.actions' => 'Acciones',
			'table.moreActions' => 'Más acciones',
			'table.download' => 'Descargar',
			'table.endOfList' => 'No hay más resultados',
			'table.empty.noneFound' => 'No se ha encontrado ningún elemento',
			'table.empty.tryFilters' => 'Prueba a cambiar los filtros',
			'table.empty.noResults' => 'Sin resultados',
			'table.empty.nothingYet' => 'Aún no hay nada',
			'table.empty.tryFiltersSearch' => 'Prueba a cambiar los filtros de búsqueda',
			'table.empty.willAppear' => 'Los elementos aparecerán aquí cuando los haya',
			'table.error.loading' => 'Error al cargar',
			'table.error.generic' => 'Se ha producido un error',
			'table.error.unknown' => 'Error desconocido',
			'table.filter.title' => 'Filtros',
			'table.filter.searchFilters' => 'Filtros de búsqueda',
			'table.filter.filterWith' => 'Filtrar por...',
			'table.filter.searchBy' => ({required Object title}) => 'Buscar por ${title}',
			'table.filter.filterBy' => ({required Object title}) => 'Filtrar por ${title}',
			'table.filter.chip' => ({required Object title, required Object value}) => '${title}: ${value}',
			'table.sort.by' => 'Ordenar por',
			'table.sort.short' => 'Ordenar',
			'table.sort.ascending' => ({required Object column}) => '${column} - Ascendente',
			'table.sort.descending' => ({required Object column}) => '${column} - Descendente',
			'table.footer.range' => ({required Object start, required Object end, required Object total}) => '${start} – ${end} de ${total}',
			'table.footer.none' => '0 resultados',
			_ => null,
		};
	}
}
