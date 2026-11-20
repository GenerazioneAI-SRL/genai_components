/// Generated file. Do not edit.
///
/// Source: lib/src/i18n
/// To regenerate, run: `dart run slang`
///
/// Locales: 5
/// Strings: 805 (161 per locale)

// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'package:slang/slang.dart';
export 'package:slang/slang.dart';

import 'strings_de.g.dart' deferred as l_de;
import 'strings_en.g.dart' deferred as l_en;
import 'strings_es.g.dart' deferred as l_es;
import 'strings_fr.g.dart' deferred as l_fr;
part 'strings_it.g.dart';

/// Supported locales.
///
/// Usage:
/// - LocaleSettings.setLocale(CLAppLocale.it) // set locale
/// - Locale locale = CLAppLocale.it.flutterLocale // get flutter locale from enum
/// - if (LocaleSettings.currentLocale == CLAppLocale.it) // locale check
enum CLAppLocale with BaseAppLocale<CLAppLocale, CLTranslations> {
	it(languageCode: 'it'),
	de(languageCode: 'de'),
	en(languageCode: 'en'),
	es(languageCode: 'es'),
	fr(languageCode: 'fr');

	const CLAppLocale({
		required this.languageCode,
		this.scriptCode, // ignore: unused_element, unused_element_parameter
		this.countryCode, // ignore: unused_element, unused_element_parameter
	});

	@override final String languageCode;
	@override final String? scriptCode;
	@override final String? countryCode;

	@override
	Future<CLTranslations> build({
		Map<String, Node>? overrides,
		PluralResolver? cardinalResolver,
		PluralResolver? ordinalResolver,
	}) async {
		switch (this) {
			case CLAppLocale.it:
				return CLTranslationsIt(
					overrides: overrides,
					cardinalResolver: cardinalResolver,
					ordinalResolver: ordinalResolver,
				);
			case CLAppLocale.de:
				await l_de.loadLibrary();
				return l_de.CLTranslationsDe(
					overrides: overrides,
					cardinalResolver: cardinalResolver,
					ordinalResolver: ordinalResolver,
				);
			case CLAppLocale.en:
				await l_en.loadLibrary();
				return l_en.CLTranslationsEn(
					overrides: overrides,
					cardinalResolver: cardinalResolver,
					ordinalResolver: ordinalResolver,
				);
			case CLAppLocale.es:
				await l_es.loadLibrary();
				return l_es.CLTranslationsEs(
					overrides: overrides,
					cardinalResolver: cardinalResolver,
					ordinalResolver: ordinalResolver,
				);
			case CLAppLocale.fr:
				await l_fr.loadLibrary();
				return l_fr.CLTranslationsFr(
					overrides: overrides,
					cardinalResolver: cardinalResolver,
					ordinalResolver: ordinalResolver,
				);
		}
	}

	@override
	CLTranslations buildSync({
		Map<String, Node>? overrides,
		PluralResolver? cardinalResolver,
		PluralResolver? ordinalResolver,
	}) {
		switch (this) {
			case CLAppLocale.it:
				return CLTranslationsIt(
					overrides: overrides,
					cardinalResolver: cardinalResolver,
					ordinalResolver: ordinalResolver,
				);
			case CLAppLocale.de:
				return l_de.CLTranslationsDe(
					overrides: overrides,
					cardinalResolver: cardinalResolver,
					ordinalResolver: ordinalResolver,
				);
			case CLAppLocale.en:
				return l_en.CLTranslationsEn(
					overrides: overrides,
					cardinalResolver: cardinalResolver,
					ordinalResolver: ordinalResolver,
				);
			case CLAppLocale.es:
				return l_es.CLTranslationsEs(
					overrides: overrides,
					cardinalResolver: cardinalResolver,
					ordinalResolver: ordinalResolver,
				);
			case CLAppLocale.fr:
				return l_fr.CLTranslationsFr(
					overrides: overrides,
					cardinalResolver: cardinalResolver,
					ordinalResolver: ordinalResolver,
				);
		}
	}

	/// Gets current instance managed by [LocaleSettings].
	CLTranslations get translations => LocaleSettings.instance.getTranslations(this);
}

/// Method A: Simple
///
/// No rebuild after locale change.
/// Translation happens during initialization of the widget (call of clL10n).
/// Configurable via 'translate_var'.
///
/// Usage:
/// String a = clL10n.someKey.anotherKey;
/// String b = clL10n['someKey.anotherKey']; // Only for edge cases!
CLTranslations get clL10n => LocaleSettings.instance.currentTranslations;

/// Manages all translation instances and the current locale
class LocaleSettings extends BaseLocaleSettings<CLAppLocale, CLTranslations> {
	LocaleSettings._() : super(
		utils: AppLocaleUtils.instance,
		lazy: true,
	);

	static final instance = LocaleSettings._();

	// static aliases (checkout base methods for documentation)
	static CLAppLocale get currentLocale => instance.currentLocale;
	static Stream<CLAppLocale> getLocaleStream() => instance.getLocaleStream();
	static Future<CLAppLocale> setLocale(CLAppLocale locale, {bool? listenToDeviceLocale = false}) => instance.setLocale(locale, listenToDeviceLocale: listenToDeviceLocale);
	static Future<CLAppLocale> setLocaleRaw(String rawLocale, {bool? listenToDeviceLocale = false}) => instance.setLocaleRaw(rawLocale, listenToDeviceLocale: listenToDeviceLocale);
	static Future<void> setPluralResolver({String? language, CLAppLocale? locale, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver}) => instance.setPluralResolver(
		language: language,
		locale: locale,
		cardinalResolver: cardinalResolver,
		ordinalResolver: ordinalResolver,
	);

	// synchronous versions
	static CLAppLocale setLocaleSync(CLAppLocale locale, {bool? listenToDeviceLocale = false}) => instance.setLocaleSync(locale, listenToDeviceLocale: listenToDeviceLocale);
	static CLAppLocale setLocaleRawSync(String rawLocale, {bool? listenToDeviceLocale = false}) => instance.setLocaleRawSync(rawLocale, listenToDeviceLocale: listenToDeviceLocale);
	static void setPluralResolverSync({String? language, CLAppLocale? locale, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver}) => instance.setPluralResolverSync(
		language: language,
		locale: locale,
		cardinalResolver: cardinalResolver,
		ordinalResolver: ordinalResolver,
	);
}

/// Provides utility functions without any side effects.
class AppLocaleUtils extends BaseAppLocaleUtils<CLAppLocale, CLTranslations> {
	AppLocaleUtils._() : super(
		baseLocale: CLAppLocale.it,
		locales: CLAppLocale.values,
	);

	static final instance = AppLocaleUtils._();

	// static aliases (checkout base methods for documentation)
	static CLAppLocale parse(String rawLocale) => instance.parse(rawLocale);
	static CLAppLocale parseLocaleParts({required String languageCode, String? scriptCode, String? countryCode}) => instance.parseLocaleParts(languageCode: languageCode, scriptCode: scriptCode, countryCode: countryCode);
	static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
}
