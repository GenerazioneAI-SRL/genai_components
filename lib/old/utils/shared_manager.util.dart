import 'package:shared_preferences/shared_preferences.dart';

class SharedManager {
  //
  static SharedPreferences? prefs;

  /// In-memory cache to avoid repeated SharedPreferences reads for hot keys.
  /// Populated on read, updated on write-through, invalidated on remove.
  static final Map<String, dynamic> _cache = {};

  static initPrefs() async {
    prefs ??= await SharedPreferences.getInstance();
  }

  /*
  static bool firstTimeOnApp() {
    return prefs!.getBool(AppStrings.firstTimeOnApp) ?? true;
  }
  //
  static bool authenticated() {
    return prefs!.getBool(AppStrings.authenticated) ?? false;
  }*/

  static bool? getBool(String key) {
    final cached = _cache[key];
    if (cached is bool) return cached;
    final value = prefs!.getBool(key) ?? false;
    _cache[key] = value;
    return value;
  }

  static Future<bool?> setBool(String key, bool value) async {
    _cache[key] = value;
    prefs!.setBool(key, value);
    return getBool(key);
  }

  static String getString(String key, {String defaultValue = ""}) {
    final cached = _cache[key];
    if (cached is String) return cached;
    final value = prefs!.getString(key) ?? defaultValue;
    _cache[key] = value;
    return value;
  }

  static Future<String?> setString(String key, String value) async {
    _cache[key] = value;
    prefs!.setString(key, value);
    return getString(key);
  }

  static Future<List<String>?> setStringList(String key, List<String> value) async {
    _cache[key] = value;
    prefs!.setStringList(key, value);
    return getStringList(key);
  }

  static List<String>? getStringList(String key, {List<String>? defaultValue = const []}) {
    final cached = _cache[key];
    if (cached is List<String>) return cached;
    final value = prefs!.getStringList(key) ?? defaultValue;
    if (value != null) _cache[key] = value;
    return value;
  }

  static int getInt(String key) {
    final cached = _cache[key];
    if (cached is int) return cached;
    final value = prefs!.getInt(key) ?? 0;
    _cache[key] = value;
    return value;
  }

  static Future<int> setInt(String key, int value) async {
    _cache[key] = value;
    prefs!.setInt(key, value);
    return getInt(key);
  }

  static Future<bool?> remove(String key) async {
    _cache.remove(key);
    return await prefs!.remove(key);
  }
}
