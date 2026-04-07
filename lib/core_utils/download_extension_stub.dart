// lib/extensions/download_extension_stub.dart

import 'package:flutter/material.dart';

import 'package:genai_components/widgets/alertmanager/alert_manager.dart';

extension DownloadExtension on BuildContext {
  Future<void> downloadFile(String url) async {
    // Implementazione di fallback
    AlertManager.showWarning("Download Annullato", "Il download non è supportato su questa piattaforma.", alertPosition: AlertPosition.leftBottomCorner);
  }
}