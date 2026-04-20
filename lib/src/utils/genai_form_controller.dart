import 'dart:async';

import 'package:flutter/foundation.dart';

import 'genai_validators.dart';

/// State of a single field inside a [GenaiFormController].
class GenaiFieldState<T> {
  final String name;
  final T? initialValue;
  T? value;
  String? error;
  bool touched;
  bool dirty;

  GenaiFieldState({
    required this.name,
    this.initialValue,
    this.value,
    this.error,
    this.touched = false,
    this.dirty = false,
  });

  void reset() {
    value = initialValue;
    error = null;
    touched = false;
    dirty = false;
  }
}

/// Centralized form controller (§4.3 form, §7.1).
///
/// Features:
/// - Per-field value/error/touched/dirty tracking
/// - Pluggable validators
/// - `isDirty` / `isValid` for unsaved-changes guards
/// - Optional autosave via [enableAutosave]
class GenaiFormController extends ChangeNotifier {
  final Map<String, GenaiFieldState<dynamic>> _fields = {};
  final Map<String, GenaiValidator<dynamic>> _validators = {};

  final Future<void> Function(Map<String, dynamic> values)? onAutosave;
  final Duration autosaveDebounce;

  Timer? _autosaveTimer;
  bool _autosaveInFlight = false;
  bool _enableAutosave;

  GenaiFormController({
    this.onAutosave,
    this.autosaveDebounce = const Duration(milliseconds: 800),
    bool enableAutosave = false,
  }) : _enableAutosave = enableAutosave;

  // ─────────── registration ───────────

  void register<T>(
    String name, {
    T? initialValue,
    GenaiValidator<T?>? validator,
  }) {
    _fields[name] = GenaiFieldState<T?>(
      name: name,
      initialValue: initialValue,
      value: initialValue,
    );
    if (validator != null) _validators[name] = (v) => validator(v as T?);
  }

  void unregister(String name) {
    _fields.remove(name);
    _validators.remove(name);
  }

  // ─────────── values ───────────

  T? value<T>(String name) => _fields[name]?.value as T?;

  Map<String, dynamic> get values => {for (final e in _fields.entries) e.key: e.value.value};

  void setValue<T>(String name, T? value, {bool markTouched = false}) {
    final f = _fields[name];
    if (f == null) return;
    f.value = value;
    f.dirty = value != f.initialValue;
    if (markTouched) f.touched = true;
    // Re-run validation only if already touched (avoid premature errors).
    if (f.touched) f.error = _validators[name]?.call(value);
    notifyListeners();
    _scheduleAutosave();
  }

  void touch(String name) {
    final f = _fields[name];
    if (f == null) return;
    if (!f.touched) {
      f.touched = true;
      f.error = _validators[name]?.call(f.value);
      notifyListeners();
    }
  }

  String? errorOf(String name) => _fields[name]?.error;
  bool isTouched(String name) => _fields[name]?.touched ?? false;
  bool isDirtyField(String name) => _fields[name]?.dirty ?? false;

  // ─────────── form-wide ───────────

  bool get isDirty => _fields.values.any((f) => f.dirty);

  /// Validates all fields and returns true when no errors.
  bool validate() {
    var ok = true;
    for (final f in _fields.values) {
      f.touched = true;
      final err = _validators[f.name]?.call(f.value);
      f.error = err;
      if (err != null) ok = false;
    }
    notifyListeners();
    return ok;
  }

  /// True when no field currently holds a validation error AND all
  /// validators run clean against current values.
  bool get isValid {
    for (final f in _fields.values) {
      final err = _validators[f.name]?.call(f.value);
      if (err != null) return false;
    }
    return true;
  }

  void reset() {
    for (final f in _fields.values) {
      f.reset();
    }
    _autosaveTimer?.cancel();
    notifyListeners();
  }

  /// Marks the current values as the new "pristine" state (e.g. after save).
  void markPristine() {
    for (final f in _fields.values) {
      f.dirty = false;
    }
    notifyListeners();
  }

  // ─────────── autosave ───────────

  bool get isAutosaveEnabled => _enableAutosave;

  void setAutosaveEnabled(bool v) {
    _enableAutosave = v;
    if (!v) _autosaveTimer?.cancel();
  }

  void _scheduleAutosave() {
    if (!_enableAutosave || onAutosave == null) return;
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(autosaveDebounce, _runAutosave);
  }

  Future<void> _runAutosave() async {
    if (_autosaveInFlight) return;
    if (!isDirty) return;
    _autosaveInFlight = true;
    try {
      await onAutosave!(values);
      markPristine();
    } finally {
      _autosaveInFlight = false;
    }
  }

  /// Forces an immediate autosave (bypasses debounce).
  Future<void> flushAutosave() async {
    _autosaveTimer?.cancel();
    if (onAutosave != null) await _runAutosave();
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    super.dispose();
  }
}
