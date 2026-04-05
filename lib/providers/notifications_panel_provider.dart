import 'package:flutter/material.dart';

enum PanelSection {
  notifications,
  chatbot,
}

class NotificationsPanelProvider extends ChangeNotifier {
  bool _isOpen = false;
  PanelSection _currentSection = PanelSection.notifications;

  bool get isOpen => _isOpen;
  PanelSection get currentSection => _currentSection;

  bool isCurrentSection(PanelSection section) => _isOpen && _currentSection == section;

  void toggle(PanelSection section) {
    if (_isOpen && _currentSection == section) {
      _isOpen = false;
    } else {
      _isOpen = true;
      _currentSection = section;
    }
    notifyListeners();
  }

  void open(PanelSection section) {
    _isOpen = true;
    _currentSection = section;
    notifyListeners();
  }

  void close() {
    _isOpen = false;
    notifyListeners();
  }
}
