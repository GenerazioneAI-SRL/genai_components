import 'package:flutter/material.dart';
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';
import 'cl_file_picker.widget.dart';
import 'cl_media_viewer.widget.dart';

/// Modello leggero per rappresentare un media allegato.
/// Può essere esteso o mappato dal modello specifico del progetto.
class CLAttachedMedia {
  final String id;
  final String? url;
  final String? originalName;
  final String path;

  const CLAttachedMedia({
    required this.id,
    this.url,
    this.originalName,
    this.path = '',
  });
}

/// Widget riutilizzabile per gestire i media allegati a una risorsa.
///
/// Si passa il [resourceIdentifier] (es. l'id dell'evento o del prodotto)
/// e i callback [onUpload] / [onDelete] per delegare le operazioni API al chiamante.
///
/// Esempio d'uso:
/// ```dart
/// CLMediaAttachWidget(
///   resourceIdentifier: widget.eventId,
///   initialMediaList: vm.attachedMedia.map((m) => CLAttachedMedia(
///     id: m.id, url: m.url, originalName: m.originalName, path: m.path,
///   )).toList(),
///   onUpload: (media) async {
///     // upload via API, ritorna il nuovo media
///     final result = await myUploadCall(media);
///     return result != null
///         ? CLAttachedMedia(id: result.id, url: result.url, ...)
///         : null;
///   },
///   onDelete: (id) async => await myDeleteCall(id),
///   onMediaChanged: () => vm.refreshMediaList(),
/// )
/// ```
class CLMediaAttachWidget extends StatefulWidget {
  /// ID della risorsa a cui collegare i media.
  final String resourceIdentifier;

  /// Lista iniziale di media già caricati.
  final List<CLAttachedMedia> initialMediaList;

  /// Callback per caricare un file. Riceve il [CLMedia] dal picker.
  /// Deve restituire un [CLAttachedMedia] se l'upload va a buon fine, `null` altrimenti.
  final Future<CLAttachedMedia?> Function(CLMedia media)? onUpload;

  /// Callback per eliminare un media. Riceve l'[id] del media.
  /// Deve restituire `true` se l'eliminazione va a buon fine.
  final Future<bool> Function(String id)? onDelete;

  /// Callback dopo ogni modifica (upload o delete) per aggiornare il parent.
  final VoidCallback? onMediaChanged;

  /// Estensioni file consentite.
  final List<String> allowedExtensions;

  /// Testo mostrato quando non ci sono media.
  final String emptyText;

  const CLMediaAttachWidget({
    super.key,
    required this.resourceIdentifier,
    this.initialMediaList = const [],
    this.onUpload,
    this.onDelete,
    this.onMediaChanged,
    this.emptyText = 'Nessun media allegato',
    this.allowedExtensions = const [
      'jpg', 'jpeg', 'png', 'gif', 'webp',
      'pdf', 'doc', 'docx', 'xls', 'xlsx',
      'mp4', 'mov', 'avi',
    ],
  });

  @override
  State<CLMediaAttachWidget> createState() => _CLMediaAttachWidgetState();
}

class _CLMediaAttachWidgetState extends State<CLMediaAttachWidget> {
  late List<CLAttachedMedia> _mediaList;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _mediaList = List.from(widget.initialMediaList);
  }

  @override
  void didUpdateWidget(CLMediaAttachWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialMediaList != widget.initialMediaList) {
      _mediaList = List.from(widget.initialMediaList);
    }
  }

  Future<void> _uploadFile(CLMedia media) async {
    if (media.file == null || widget.onUpload == null) return;

    setState(() => _isUploading = true);
    try {
      final result = await widget.onUpload!(media);
      if (result != null) {
        setState(() => _mediaList.add(result));
        widget.onMediaChanged?.call();
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteMedia(CLAttachedMedia media) async {
    if (widget.onDelete == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Elimina media'),
        content: Text(
          'Vuoi eliminare "${media.originalName ?? media.path}"? L\'operazione è irreversibile.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Elimina', style: TextStyle(color: CLTheme.of(ctx).danger)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isUploading = true);
    try {
      final success = await widget.onDelete!(media.id);
      if (success) {
        setState(() => _mediaList.removeWhere((m) => m.id == media.id));
        widget.onMediaChanged?.call();
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // File picker
        if (widget.onUpload != null)
          ClFilePicker.single(
            allowedExtensions: widget.allowedExtensions,
            onPickedFile: (media) async {
              if (media?.file != null) {
                await _uploadFile(media!);
              }
            },
          ),

        if (_isUploading) ...[
          const SizedBox(height: Sizes.padding),
          const Center(child: CircularProgressIndicator()),
        ],

        // Media preview grid
        if (_mediaList.isNotEmpty) ...[
          const SizedBox(height: Sizes.padding),
          SizedBox(
            height: 270,
            child: CLMediaViewer(
              medias: _mediaList
                  .where((m) => m.url != null && m.url!.isNotEmpty)
                  .map((m) {
                final media = CLMedia(fileUrl: m.url);
                media.fileName = m.originalName ?? m.path.split('/').last;
                return media;
              }).toList(),
              clMediaViewerMode: CLMediaViewerMode.previewMode,
              isItemRemovable: widget.onDelete != null,
              isPreviewEnabled: true,
              isDownloadEnabled: true,
              onRemove: (index) {
                final filteredList = _mediaList
                    .where((m) => m.url != null && m.url!.isNotEmpty)
                    .toList();
                if (index < filteredList.length) {
                  _deleteMedia(filteredList[index]);
                }
              },
            ),
          ),
        ],

        // Empty state
        if (_mediaList.isEmpty && !_isUploading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Sizes.padding),
            child: Center(
              child: Text(widget.emptyText, style: CLTheme.of(context).bodyLabel),
            ),
          ),
      ],
    );
  }
}

