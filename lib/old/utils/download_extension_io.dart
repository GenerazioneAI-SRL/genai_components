// lib/extensions/download_extension_io.dart

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import '../widgets/alertmanager/alert_manager.dart';

extension DownloadExtension on BuildContext {
  Future<void> downloadFile(dynamic fileOrUrl) async {
    BehaviorSubject<double> downloadPercentage = BehaviorSubject<double>.seeded(0);

    if (fileOrUrl is String) {
      // ── Download da URL ──────────────────────────────────────────
      String? selectedDirectory;

      try {
        selectedDirectory = await FilePicker.platform.getDirectoryPath();
      } catch (e) {
        // Il FilePicker potrebbe non funzionare in sandbox, usiamo il fallback
      }

      // Se l'utente ha annullato il picker o il picker ha fallito,
      // usiamo la cartella Downloads come fallback
      if (selectedDirectory == null) {
        try {
          final downloadsDir = await _getDownloadsDirectory();
          if (downloadsDir != null) {
            selectedDirectory = downloadsDir.path;
          }
        } catch (e) {
          // Intentionally swallowed — directory resolution best-effort, fallback warning shown below
        }
      }

      if (selectedDirectory == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AlertManager.showWarning(
            "Download Annullato",
            "Impossibile determinare la cartella di destinazione. Verifica i permessi dell'app.",
            alertPosition: AlertPosition.leftBottomCorner,
          );
        });
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        AlertManager.showDownloadPercentage("Download", "Download in corso", downloadPercentage);
      });

      try {
        final client = http.Client();
        final request = http.Request('GET', Uri.parse(fileOrUrl));
        final response = await client.send(request);

        if (response.statusCode == 200) {
          Uri uri = Uri.parse(fileOrUrl);
          String fileName = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'downloaded_file';
          // Rimuovi query parameters dal nome
          if (fileName.contains('?')) {
            fileName = fileName.split('?').first;
          }
          fileName = Uri.decodeComponent(fileName);

          final file = File('$selectedDirectory/$fileName');
          final fileStream = file.openWrite();

          int totalBytes = response.contentLength ?? 0;
          int downloadedBytes = 0;

          response.stream.listen(
            (data) {
              downloadedBytes += data.length;
              fileStream.add(data);
              if (totalBytes > 0) {
                final progress = (downloadedBytes / totalBytes) * 100;
                downloadPercentage.add(progress);
              }
            },
            onDone: () async {
              await fileStream.close();
              downloadPercentage.close();
              client.close();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                AlertManager.showSuccess("Successo", "Download completato: ${file.path}");
              });
            },
            onError: (error) {
              downloadPercentage.close();
              fileStream.close();
              client.close();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                AlertManager.showDanger("Errore", "Errore nel download: $error");
              });
            },
            cancelOnError: true,
          );
        } else {
          downloadPercentage.close();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AlertManager.showDanger("Errore", "Errore nella richiesta: Status ${response.statusCode}");
          });
        }
      } catch (e) {
        downloadPercentage.close();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AlertManager.showDanger("Errore", "Errore nel download: $e");
        });
      }
    } else {
      // ── Salva file da bytes ──────────────────────────────────────
      String? selectedDirectory;

      try {
        selectedDirectory = await FilePicker.platform.getDirectoryPath();
      } catch (e) {
        // Intentionally swallowed — picker may fail in sandbox, fallback to Downloads dir
      }

      if (selectedDirectory == null) {
        try {
          final downloadsDir = await _getDownloadsDirectory();
          if (downloadsDir != null) {
            selectedDirectory = downloadsDir.path;
          }
        } catch (e) {
          // Intentionally swallowed — directory resolution best-effort, fallback warning shown below
        }
      }

      if (selectedDirectory == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AlertManager.showWarning(
            "Salvataggio Annullato",
            "Impossibile determinare la cartella di destinazione. Verifica i permessi dell'app.",
            alertPosition: AlertPosition.leftBottomCorner,
          );
        });
        return;
      }

      try {
        String newFilePath = path.join(selectedDirectory, fileOrUrl.name);
        File newFile = File(newFilePath);
        await newFile.writeAsBytes(fileOrUrl.bytes!);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AlertManager.showSuccess("Successo", "Download completato: $newFilePath");
        });
      } catch (e) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AlertManager.showDanger("Errore", "Errore nel salvataggio: $e");
        });
      }
    }
  }

  /// Restituisce la cartella Downloads come fallback.
  Future<Directory?> _getDownloadsDirectory() async {
    if (Platform.isMacOS || Platform.isLinux) {
      final home = Platform.environment['HOME'];
      if (home != null) {
        final downloadsDir = Directory('$home/Downloads');
        if (await downloadsDir.exists()) {
          return downloadsDir;
        }
      }
    } else if (Platform.isWindows) {
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null) {
        final downloadsDir = Directory('$userProfile\\Downloads');
        if (await downloadsDir.exists()) {
          return downloadsDir;
        }
      }
    }

    // Fallback generico: cartella temporanea
    try {
      return await getDownloadsDirectory();
    } catch (_) {
      return await getTemporaryDirectory();
    }
  }
}
