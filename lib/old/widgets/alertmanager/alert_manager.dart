// alert_manager.dart

import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import '../cl_alert.widget.dart';

part 'alert_state.dart';

part 'alert_models.dart';

part 'default_alert_listener.dart';

part 'custom_alert_listener.dart';

part 'overlay.dart';

class AlertManager {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void showPrimary(String title, String message, {alertPosition = AlertPosition.bottom, onTap, closeOnTap = false}) {
    final context = navigatorKey.currentContext;
    final alertState = Provider.of<_AlertState>(context!, listen: false);
    alertState.notify(
      _Alert(title: title, message: message, alertPosition: alertPosition, alertType: AlertType.primary, onTap: onTap, closeOnTap: closeOnTap),
    );
  }

  static void showSecondary(String title, String message, {alertPosition = AlertPosition.bottom, onTap, closeOnTap = false}) {
    final context = navigatorKey.currentContext;
    final alertState = Provider.of<_AlertState>(context!, listen: false);
    alertState.notify(
      _Alert(title: title, message: message, alertPosition: alertPosition, alertType: AlertType.secondary, onTap: onTap, closeOnTap: closeOnTap),
    );
  }

  static void showSuccess(String title, String message, {alertPosition = AlertPosition.bottom, onTap, closeOnTap = false}) {
    final context = navigatorKey.currentContext;
    final alertState = Provider.of<_AlertState>(context!, listen: false);
    alertState.notify(
      _Alert(title: title, message: message, alertPosition: alertPosition, alertType: AlertType.success, onTap: onTap, closeOnTap: closeOnTap),
    );
  }

  static void showDanger(String title, String message, {alertPosition = AlertPosition.bottom, onTap, closeOnTap = false}) {
    final context = navigatorKey.currentContext;
    final alertState = Provider.of<_AlertState>(context!, listen: false);
    alertState.notify(
      _Alert(title: title, message: message, alertPosition: alertPosition, alertType: AlertType.danger, onTap: onTap, closeOnTap: closeOnTap),
    );
  }

  static void showWarning(String title, String message, {alertPosition = AlertPosition.bottom, onTap, closeOnTap = false}) {
    final context = navigatorKey.currentContext;
    final alertState = Provider.of<_AlertState>(context!, listen: false);

    alertState.notify(
      _Alert(title: title, message: message, alertPosition: alertPosition, alertType: AlertType.warning, onTap: onTap, closeOnTap: closeOnTap),
    );
  }

  static void showInfo(String title, String message, {alertPosition = AlertPosition.bottom, onTap, closeOnTap = false}) {
    final context = navigatorKey.currentContext;
    final alertState = Provider.of<_AlertState>(context!, listen: false);
    alertState.notify(
      _Alert(title: title, message: message, alertPosition: alertPosition, alertType: AlertType.info, onTap: onTap, closeOnTap: closeOnTap),
    );
  }

  static void showNotification(String title, String message, {alertPosition = AlertPosition.rightTopCorner, onTap, closeOnTap = false}) {
    final context = navigatorKey.currentContext;
    final alertState = Provider.of<_AlertState>(context!, listen: false);
    alertState.notify(
      _Alert(title: title, message: message, alertPosition: alertPosition, alertType: AlertType.notification, onTap: onTap, closeOnTap: closeOnTap),
    );
  }

  static void showDownloadPercentage(
    String title,
    String message,
    BehaviorSubject<double> downloadPercentageStream, {
    alertPosition = AlertPosition.leftBottomCorner,
    onTap,
    closeOnTap = false,
  }) {
    final context = navigatorKey.currentContext;
    final alertState = Provider.of<_AlertState>(context!, listen: false);
    alertState.notify(
      _Alert(
        title: title,
        message: message,
        alertPosition: alertPosition,
        alertType: AlertType.download,
        downloadPercentageStream: downloadPercentageStream,
        onTap: onTap,
        closeOnTap: closeOnTap,
      ),
    );
  }
}

enum AlertPosition { top, bottom, leftTopCorner, rightTopCorner, leftBottomCorner, rightBottomCorner }

enum AlertType { primary, secondary, success, danger, warning, info, notification, download }
