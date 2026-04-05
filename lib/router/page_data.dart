import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Wrapper for passing data between pages without exposing it in the URL.
class CLPageData {
  final Map<String, dynamic> _data;

  const CLPageData(this._data);

  static const empty = CLPageData({});

  T? get<T>(String key) {
    final value = _data[key];
    return value is T ? value : null;
  }

  bool has(String key) => _data.containsKey(key);

  static CLPageData of(BuildContext context) {
    try {
      final extra = GoRouterState.of(context).extra;
      if (extra is Map<String, dynamic>) return CLPageData(extra);
    } catch (_) {}
    return empty;
  }
}
