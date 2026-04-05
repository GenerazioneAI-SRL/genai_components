import 'package:flutter/foundation.dart';

/// Simple stack-based breadcrumb manager. Push on navigate, pop on back.
class CLBreadcrumbStack extends ChangeNotifier {
  final List<CLBreadcrumbEntry> _items = [];

  List<CLBreadcrumbEntry> get items => List.unmodifiable(_items);
  int get length => _items.length;
  bool get isEmpty => _items.isEmpty;

  void push(CLBreadcrumbEntry item) {
    final existingIndex = _items.indexWhere((b) => b.path == item.path);
    if (existingIndex != -1) {
      _items.removeRange(existingIndex, _items.length);
    }
    _items.add(item);
    notifyListeners();
  }

  void pop() {
    if (_items.length > 1) {
      _items.removeLast();
      notifyListeners();
    }
  }

  void popUntil(String path) {
    final index = _items.indexWhere((b) => b.path == path);
    if (index != -1 && index < _items.length - 1) {
      _items.removeRange(index + 1, _items.length);
      notifyListeners();
    }
  }

  void reset() {
    _items.clear();
    notifyListeners();
  }
}

class CLBreadcrumbEntry {
  final String name;
  final String path;
  final bool isClickable;

  const CLBreadcrumbEntry({
    required this.name,
    required this.path,
    this.isClickable = true,
  });
}
