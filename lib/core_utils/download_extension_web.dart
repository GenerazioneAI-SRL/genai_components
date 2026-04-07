// lib/extensions/download_extension_web.dart

import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:genai_components/widgets/alertmanager/alert_manager.dart';

extension DownloadExtension on BuildContext {
  Future<void> downloadFile(String url) async {
    final uri = Uri.parse(url);

    // Prova prima con XHR per mostrare il progresso del download.
    // Se fallisce (es. CORS cross-origin verso S3), usa il fallback
    // con AnchorElement che apre il download direttamente nel browser.
    try {
      await _downloadWithXhr(url, uri);
    } catch (e) {
      _downloadWithAnchor(url, uri);
    }
  }

  /// Download con XHR — supporta progress bar ma richiede CORS ok.
  Future<void> _downloadWithXhr(String url, Uri uri) {
    final completer = Completer<void>();
    final request = html.HttpRequest();

    request
      ..open('GET', url)
      ..responseType = 'blob';

    BehaviorSubject<double> downloadPercentage = BehaviorSubject<double>.seeded(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AlertManager.showDownloadPercentage("Download", "Download in corso", downloadPercentage);
    });

    request.onProgress.listen((event) {
      if (event.lengthComputable && event.loaded != null && event.total != null) {
        double progress = (event.loaded! / event.total!) * 100;
        downloadPercentage.add(progress);
      }
    });

    request.onLoadEnd.listen((event) {
      if (completer.isCompleted) return;
      if (request.status == 200) {
        String fileName = _extractFileName(request, uri);
        final blob = request.response;
        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = html.Url.createObjectUrlFromBlob(blob)
          ..style.display = 'none'
          ..download = fileName;
        html.document.body!.children.add(anchor);
        anchor.click();
        html.document.body!.children.remove(anchor);
        html.Url.revokeObjectUrl(anchor.href!);
        downloadPercentage.close();
        AlertManager.showSuccess("Perfetto", "Download completato: $fileName");
        completer.complete();
      } else if (request.status == 0) {
        // Status 0 = CORS bloccato o errore di rete
        downloadPercentage.close();
        completer.completeError('Blocco CORS o errore di rete (status 0)');
      } else {
        downloadPercentage.close();
        completer.completeError('HTTP ${request.status}: ${request.statusText}');
      }
    });

    request.onError.listen((event) {
      if (completer.isCompleted) return;
      downloadPercentage.close();
      completer.completeError('Errore di rete (possibile blocco CORS)');
    });

    request.send();
    return completer.future;
  }

  /// Fallback: download diretto tramite AnchorElement.
  /// Non mostra progress ma funziona senza CORS perché il browser gestisce
  /// il download nativamente (navigazione, non XHR).
  void _downloadWithAnchor(String url, Uri uri) {
    String fileName = _fileNameFromUri(uri);

    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = fileName
      ..target = '_blank';

    html.document.body!.children.add(anchor);
    anchor.click();

    // Rimuovi l'elemento dopo un breve delay
    Future.delayed(const Duration(milliseconds: 100), () {
      html.document.body!.children.remove(anchor);
    });

    AlertManager.showSuccess("Download", "Il download è stato avviato: $fileName");
  }

  /// Estrae il nome file dall'header Content-Disposition o dall'URL.
  String _extractFileName(html.HttpRequest request, Uri uri) {
    String? contentDisposition = request.getResponseHeader('Content-Disposition');

    if (contentDisposition != null && contentDisposition.contains('filename=')) {
      // Prova a estrarre il filename dal Content-Disposition
      // Pattern: filename="qualcosa" oppure filename=qualcosa
      final pattern = RegExp('filename\\*?=["\']?([^"\';\n]+)["\']?');
      Match? match = pattern.firstMatch(contentDisposition);
      if (match != null) {
        String name = match.group(1)!.trim();
        return name;
      }
    }

    return _fileNameFromUri(uri);
  }

  /// Estrae il nome file dall'URI, rimuovendo query parameters.
  String _fileNameFromUri(Uri uri) {
    String fileName = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'downloaded_file';
    if (fileName.contains('?')) {
      fileName = fileName.split('?').first;
    }
    return Uri.decodeComponent(fileName);
  }
}
