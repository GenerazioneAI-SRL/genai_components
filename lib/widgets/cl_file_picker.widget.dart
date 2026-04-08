import 'dart:io';
import 'package:genai_components/layout/constants/sizes.constant.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:genai_components/widgets/loading.widget.dart';
import 'package:hugeicons/hugeicons.dart';
import '../cl_theme.dart';
import 'package:flutter/foundation.dart';

import 'alertmanager/alert_manager.dart';
import 'cl_media_viewer.widget.dart';
import 'package:http/http.dart' as http;

class ClFilePicker extends StatefulWidget {
  final Function(List<CLMedia>)? onFilesPicked;
  final Function(CLMedia?)? onFilePicked;
  final bool isMultiple;
  final List<CLMedia>? initialFiles;
  final List<String> allowedExtensions;
  final int maxNumberOfFile;

  const ClFilePicker(
      {super.key,
      this.onFilesPicked,
      this.onFilePicked,
      required this.isMultiple,
      required this.allowedExtensions,
      this.initialFiles,
      required this.maxNumberOfFile});

  factory ClFilePicker.multiple(
      {required Function(List<CLMedia>) onFilesPicked, List<CLMedia>? initialFiles, required List<String> allowedExtensions, int maxNumberOfFile = 1000}) {
    return ClFilePicker(
        onFilesPicked: onFilesPicked, isMultiple: true, initialFiles: initialFiles, allowedExtensions: allowedExtensions, maxNumberOfFile: maxNumberOfFile);
  }

  factory ClFilePicker.single({required Function(CLMedia?) onPickedFile, CLMedia? initialFile, required List<String> allowedExtensions}) {
    return ClFilePicker(
      onFilePicked: onPickedFile,
      isMultiple: false,
      initialFiles: initialFile != null ? [initialFile] : null,
      allowedExtensions: allowedExtensions,
      maxNumberOfFile: 1,
    );
  }

  @override
  State<ClFilePicker> createState() => _ClFilePickerState();
}

class _ClFilePickerState extends State<ClFilePicker> {
  late List<CLMedia> _uploadedFiles;
  bool _isDragging = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _uploadedFiles = widget.initialFiles ?? [];
    _initUploadedFiles();
  }

  Future<void> _initUploadedFiles() async {
    setState(() {
      isLoading = true;
    });

    if (widget.isMultiple) {
      // Per ogni media, scarica il file se necessario e aggiorna l'oggetto
      await Future.wait(
        _uploadedFiles.map((media) async {
          if (media.file == null && media.fileUrl != null) {
            final downloadedFile = await urlToPlatformFile(media.fileUrl!);
            media.file = downloadedFile; // Aggiorna l'oggetto media nella lista principale
          }
        }).toList(),
      );
      // Passa la lista degli oggetti media aggiornati (filtrando eventualmente quelli senza file)
      final updatedMedia = _uploadedFiles.where((media) => media.file != null).toList();
      widget.onFilesPicked?.call(updatedMedia);
    } else {
      if(_uploadedFiles.isNotEmpty){
        final media = _uploadedFiles.first;
        media.file = media.file ?? (media.fileUrl != null ? await urlToPlatformFile(media.fileUrl!) : null);
        widget.onFilePicked?.call(media);
      }

    }
    setState(() {
      isLoading = false;
    });
  }

  Future<PlatformFile> urlToPlatformFile(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      // Estrai il nome del file dall'URL, oppure assegna un nome di default
      final filename = getFileName(url);

      return PlatformFile(
        name: filename,
        size: bytes.length,
        bytes: bytes,
        path: null, // in questo caso il file non è salvato localmente
      );
    } else {
      throw Exception('Errore durante il download dell\'immagine');
    }
  }

  Future<void> _pickFile() async {
    List<CLMedia> filesResult = [];
    if (!widget.isMultiple && _uploadedFiles.isNotEmpty) return;

    try {
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(allowMultiple: widget.isMultiple, withData: true, type: FileType.custom, allowedExtensions: widget.allowedExtensions);

      if (result != null) {
        List<PlatformFile> validFiles = result.files.where((file) {
          String extension = file.extension?.toLowerCase() ?? "";
          bool validFile = widget.allowedExtensions.contains(extension);
          if (!validFile) {
            AlertManager.showDanger("Errore", "Il file ${file.name} non valido. L'estensioni abilitare sono ${widget.allowedExtensions.join(', ')}.");
          } else {
            filesResult.add(CLMedia(file: file));
          }
          return validFile;
        }).toList();

        if (validFiles.isEmpty) {
          AlertManager.showDanger("Errore", "Nessun file valido selezionato.");
          return;
        }

        setState(() {
          if (widget.isMultiple) {
            _uploadedFiles.addAll(filesResult);
          } else {
            _uploadedFiles = [filesResult.first];
          }
        });

        widget.isMultiple ? widget.onFilesPicked?.call(_uploadedFiles.toList()) : widget.onFilePicked?.call(_uploadedFiles.firstOrNull);
      } else {
        AlertManager.showWarning("Attenzione", "Selezione file annullata.");
      }
    } catch (e) {
      AlertManager.showDanger("Errore", "Impossibile aprire il selettore file: $e");
    }
  }

  Future<void> _handleWebDrop(String name, Uint8List bytes) async {
    PlatformFile file = PlatformFile(name: name, size: bytes.length, bytes: bytes);
    String extension = file.extension?.toLowerCase() ?? "";
    if (!widget.allowedExtensions.contains(extension)) {
      AlertManager.showDanger("Errore", "Il file ${file.name} non valido. L'estensioni abilitare sono ${widget.allowedExtensions.join(', ')}.");
      return;
    }

    setState(() {
      if (widget.isMultiple) {
        _uploadedFiles.add(CLMedia(file: file));
      } else {
        _uploadedFiles = [CLMedia(file: file)];
      }
    });
    widget.isMultiple ? widget.onFilesPicked?.call(_uploadedFiles.toList()) : widget.onFilePicked?.call(_uploadedFiles.firstOrNull);
  }

  void _removeFile(int index) {
    setState(() {
      _uploadedFiles.removeAt(index);
    });
    widget.isMultiple ? widget.onFilesPicked?.call(_uploadedFiles.toList()) : widget.onFilePicked?.call(_uploadedFiles.firstOrNull);
  }

  @override
  Widget build(BuildContext context) {
    return kIsWeb ? _buildWebDropZone() : _buildDesktopDropZone();
  }

  Widget _buildWebDropZone() {
    late DropzoneViewController dropzoneViewController;
    return isLoading
        ? LoadingWidget()
        : Column(
            children: [
              Stack(
                children: [
                  IgnorePointer(
                    ignoring: !_isDragging,
                    child: SizedBox(
                        height: 140,
                        width: double.infinity,
                        child: DropzoneView(
                          operation: DragOperation.copy,
                          cursor: CursorType.grab,
                          onCreated: (DropzoneViewController ctrl) => dropzoneViewController = ctrl,
                          onHover: () {
                            setState(() => _isDragging = true);
                          },
                          onDropFile: (DropzoneFileInterface file) async {
                            Uint8List bytes = await dropzoneViewController.getFileData(file);
                            String fileName = await dropzoneViewController.getFilename(file);
                            await _handleWebDrop(fileName, bytes);
                            setState(() => _isDragging = false);
                          },
                          onDropFiles: (List<DropzoneFileInterface>? files) {},
                          onLeave: () {
                            setState(() => _isDragging = false);
                          },
                        )),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: _pickFile,
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: CLTheme.of(context).primary.withAlpha(10),
                          borderRadius: BorderRadius.circular(Sizes.borderRadius),
                        ),
                        child: CustomPaint(
                          painter: _DashedBorderPainter(
                            color: CLTheme.of(context).primary.withAlpha(100),
                            borderRadius: Sizes.borderRadius,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(Sizes.small),
                                decoration: BoxDecoration(
                                  color: CLTheme.of(context).primary.withAlpha(20),
                                  shape: BoxShape.circle,
                                ),
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedCloudUpload,
                                  color: CLTheme.of(context).primary,
                                  size: Sizes.large,
                                ),
                              ),
                              const SizedBox(height: Sizes.small),
                              Text(
                                "Trascina i file qui o clicca per caricare",
                                style: CLTheme.of(context).bodyText.override(
                                  color: CLTheme.of(context).primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: Sizes.small / 2),
                              Text(
                                "Max ${widget.maxNumberOfFile} file • ${widget.allowedExtensions.map((e) => e.toUpperCase()).join(', ')}",
                                style: CLTheme.of(context).bodyLabel.override(
                                  color: CLTheme.of(context).secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_isDragging)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: CLTheme.of(context).primary.withAlpha(40),
                          borderRadius: BorderRadius.circular(Sizes.borderRadius),
                          border: Border.all(
                            color: CLTheme.of(context).primary,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedCloudUpload,
                              color: CLTheme.of(context).primary,
                              size: 48,
                            ),
                            const SizedBox(height: Sizes.small),
                            Text(
                              "Rilascia i file qui",
                              style: CLTheme.of(context).bodyText.override(
                                color: CLTheme.of(context).primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              if (_uploadedFiles.isNotEmpty) ...[
                const SizedBox(height: Sizes.padding),
                CLMediaViewer(
                  medias: _uploadedFiles,
                  isItemRemovable: true,
                  clMediaViewerMode: CLMediaViewerMode.previewMode,
                ),
              ],
            ],
          );
  }

  Widget _buildDesktopDropZone() {
    return Column(
      children: [
        if (_uploadedFiles.length < widget.maxNumberOfFile)
          Stack(
            children: [
              DropTarget(
                onDragDone: (details) async {
                  final files = details.files;
                  await _handleDesktopDrop(files);
                  setState(() => _isDragging = false);
                },
                onDragEntered: (_) => setState(() => _isDragging = true),
                onDragExited: (_) => setState(() => _isDragging = false),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: _pickFile,
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: CLTheme.of(context).primary.withAlpha(10),
                        borderRadius: BorderRadius.circular(Sizes.borderRadius),
                      ),
                      child: CustomPaint(
                        painter: _DashedBorderPainter(
                          color: CLTheme.of(context).primary.withAlpha(100),
                          borderRadius: Sizes.borderRadius,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(Sizes.small),
                              decoration: BoxDecoration(
                                color: CLTheme.of(context).primary.withAlpha(20),
                                shape: BoxShape.circle,
                              ),
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedCloudUpload,
                                color: CLTheme.of(context).primary,
                                size: Sizes.large,
                              ),
                            ),
                            const SizedBox(height: Sizes.small),
                            Text(
                              "Trascina i file qui o clicca per caricare",
                              style: CLTheme.of(context).bodyText.override(
                                color: CLTheme.of(context).primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: Sizes.small / 2),
                            Text(
                              "Max ${widget.maxNumberOfFile} file • ${widget.allowedExtensions.map((e) => e.toUpperCase()).join(', ')}",
                              style: CLTheme.of(context).bodyLabel.override(
                                color: CLTheme.of(context).secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Overlay durante il drag
              if (_isDragging)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: CLTheme.of(context).primary.withAlpha(40),
                      borderRadius: BorderRadius.circular(Sizes.borderRadius),
                      border: Border.all(
                        color: CLTheme.of(context).primary,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedCloudUpload,
                          color: CLTheme.of(context).primary,
                          size: 48,
                        ),
                        const SizedBox(height: Sizes.small),
                        Text(
                          "Rilascia i file qui",
                          style: CLTheme.of(context).bodyText.override(
                            color: CLTheme.of(context).primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        if (_uploadedFiles.isNotEmpty) ...[
          const SizedBox(height: Sizes.padding),
          CLMediaViewer(
            medias: _uploadedFiles,
            clMediaViewerMode: CLMediaViewerMode.previewMode,
            isItemRemovable: true,
            onRemove: (index) {
              _removeFile(index);
            },
          ),
        ],
      ],
    );
  }

  Future _handleDesktopDrop(List<DropItem> files) async {
    if (!widget.isMultiple && _uploadedFiles.isNotEmpty) return;

    for (final file in files) {
      try {
        final bytes = await file.readAsBytes(); // 📥 Legge i dati binari

        PlatformFile platformFile = PlatformFile(
          name: file.path.split(Platform.pathSeparator).last, // 📄 Nome del file
          size: bytes.length, // 📏 Dimensione
          bytes: bytes, // 📂 Contenuto
        );
        String extension = platformFile.extension?.toLowerCase() ?? "";
        if (!widget.allowedExtensions.contains(extension)) {
          AlertManager.showDanger("Errore", "Il file ${platformFile.name} non valido. L'estensioni abilitare sono ${widget.allowedExtensions.join(', ')}.");
          continue;
        }
        setState(() {
          if (widget.isMultiple) {
            _uploadedFiles.add(CLMedia(file: platformFile));
          } else {
            _uploadedFiles = [CLMedia(file: platformFile)];
          }
        });

        widget.isMultiple ? widget.onFilesPicked?.call(_uploadedFiles.toList()) : widget.onFilePicked?.call(_uploadedFiles.firstOrNull);
      } catch (e) {
      }
    }
  }

  String getFileName(String url) {
    Uri uri = Uri.parse(url);
    String fileName = uri.path.split("/").last;
    return fileName;
  }
}

// CustomPainter per il bordo tratteggiato
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;
  final double dashWidth = 6;
  final double dashSpace = 4;
  final double strokeWidth = 1.5;

  _DashedBorderPainter({
    required this.color,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, size.width - strokeWidth, size.height - strokeWidth),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final pathMetrics = path.computeMetrics();

    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        final double end = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, end.clamp(0, metric.length)),
          paint,
        );
        distance = end + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

