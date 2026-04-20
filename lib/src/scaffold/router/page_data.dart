import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Wrapper for passing data between pages without exposing it in the URL.
class GenaiPageData {
  final Map<String, dynamic> _data;

  const GenaiPageData(this._data);

  static const empty = GenaiPageData({});

  T? get<T>(String key) {
    final value = _data[key];
    return value is T ? value : null;
  }

  bool has(String key) => _data.containsKey(key);

  static GenaiPageData of(BuildContext context) {
    try {
      final extra = GoRouterState.of(context).extra;
      if (extra is Map<String, dynamic>) return GenaiPageData(extra);
    } catch (_) {}
    return empty;
  }
}
