import 'package:flutter/material.dart';

enum GenaiPanelSection { notifications, chatbot }

/// Notifications / chatbot side panel state.
class GenaiNotificationsPanelState extends ChangeNotifier {
  bool _isOpen = false;
  GenaiPanelSection _currentSection = GenaiPanelSection.notifications;

  bool get isOpen => _isOpen;
  GenaiPanelSection get currentSection => _currentSection;

  bool isCurrentSection(GenaiPanelSection section) => _isOpen && _currentSection == section;

  void toggle(GenaiPanelSection section) {
    if (_isOpen && _currentSection == section) {
      _isOpen = false;
    } else {
      _isOpen = true;
      _currentSection = section;
    }
    notifyListeners();
  }

  void open(GenaiPanelSection section) {
    _isOpen = true;
    _currentSection = section;
    notifyListeners();
  }

  void close() {
    _isOpen = false;
    notifyListeners();
  }
}
