import 'dart:io';
import 'dart:math';

import 'package:chewie/chewie.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';
import '../utils/download_extension_io.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:universal_html/html.dart' as html;

import 'avatar.widget.dart';

// Helper class per gestire icone e colori dei file
class _FileTypeHelper {
  static dynamic getIcon(String mimeType) {
    if (mimeType.startsWith("image/")) {
      return HugeIcons.strokeRoundedImage01;
    } else if (mimeType.startsWith("video/")) {
      return HugeIcons.strokeRoundedVideo01;
    } else if (mimeType.startsWith("application/pdf")) {
      return HugeIcons.strokeRoundedPdf01;
    } else if (mimeType.contains("word") || mimeType.contains("document")) {
      return HugeIcons.strokeRoundedDoc01;
    } else if (mimeType.contains("excel") || mimeType.contains("spreadsheet")) {
      return HugeIcons.strokeRoundedFileAttachment;
    } else if (mimeType.contains("zip") || mimeType.contains("rar") || mimeType.contains("compressed")) {
      return HugeIcons.strokeRoundedZip01;
    } else {
      return HugeIcons.strokeRoundedFile02;
    }
  }

  static Color getColor(String mimeType) {
    if (mimeType.startsWith("image/")) {
      return const Color(0xFFFF7F00); // Orange
    } else if (mimeType.startsWith("video/")) {
      return const Color(0xFF9C27B0); // Purple
    } else if (mimeType.startsWith("application/pdf")) {
      return const Color(0xFFE53935); // Red
    } else if (mimeType.contains("word") || mimeType.contains("document")) {
      return const Color(0xFF1976D2); // Blue
    } else if (mimeType.contains("excel") || mimeType.contains("spreadsheet")) {
      return const Color(0xFF388E3C); // Green
    } else if (mimeType.contains("zip") || mimeType.contains("rar") || mimeType.contains("compressed")) {
      return const Color(0xFFF9A825); // Amber
    } else {
      return const Color(0xFF607D8B); // Blue Grey
    }
  }

  static String getLabel(String mimeType) {
    if (mimeType.startsWith("image/")) {
      return "Immagine";
    } else if (mimeType.startsWith("video/")) {
      return "Video";
    } else if (mimeType.startsWith("application/pdf")) {
      return "PDF";
    } else if (mimeType.contains("word") || mimeType.contains("document")) {
      return "Documento Word";
    } else if (mimeType.contains("excel") || mimeType.contains("spreadsheet")) {
      return "Foglio Excel";
    } else if (mimeType.contains("zip")) {
      return "Archivio ZIP";
    } else if (mimeType.contains("rar") || mimeType.contains("compressed")) {
      return "Archivio";
    } else {
      return "File";
    }
  }
}

class CLMediaViewer extends StatefulWidget {
  const CLMediaViewer({
    super.key,
    required this.medias,
    this.isItemRemovable = false,
    this.isPreviewEnabled = true,
    this.isDownloadEnabled = true,
    this.clMediaViewerMode = CLMediaViewerMode.cardMode,
    this.resourceName = "",
    this.elementToShow = 2,
    this.onRemove,
  });

  final List<CLMedia> medias;
  final bool isItemRemovable;
  final bool isPreviewEnabled;
  final bool isDownloadEnabled;
  final CLMediaViewerMode clMediaViewerMode;
  final double tableModeIconHeight = 40;
  final int elementToShow;
  final Function(int)? onRemove;
  final String resourceName;

  @override
  State<CLMediaViewer> createState() => _CLMediaViewerState();
}

class _CLMediaViewerState extends State<CLMediaViewer> {
  ScrollController scrollController = ScrollController();
  bool downloadHovered = false;
  bool closeHovered = false;

  @override
  Widget build(BuildContext context) {
    return widget.clMediaViewerMode == CLMediaViewerMode.tableMode
        ? SizedBox(
          height: widget.tableModeIconHeight,
          width:
              (widget.tableModeIconHeight * min(widget.elementToShow + 1, widget.medias.length)) -
              (24 * min(widget.elementToShow + 1, widget.medias.length - 1)),
          child: CLAvatarWidget(
            medias: widget.medias,
            elementToPreview: min(widget.elementToShow, widget.medias.length),
            name: widget.resourceName,
            iconSize: widget.tableModeIconHeight,
          ),
        )
        : MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              scrollController.jumpTo(scrollController.offset - details.delta.dx);
            },
            child: SizedBox(
              height: widget.clMediaViewerMode == CLMediaViewerMode.previewMode ? 270 : 90,
              width: double.infinity,
              child: ListView.builder(
                controller: scrollController,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: widget.medias.length,
                itemBuilder: (context, index) {
                  final media = widget.medias[index];
                  return Padding(
                    padding:
                        index == 0
                            ? EdgeInsets.only(left: 0, right: 0)
                            : index == widget.medias.length - 1
                            ? EdgeInsets.only(right: 0, left: Sizes.padding)
                            : EdgeInsets.symmetric(horizontal: Sizes.padding),
                    child: CLMediaViewerItem(
                      media: media,
                      clMediaViewerMode: widget.clMediaViewerMode,
                      isItemRemovable: widget.isItemRemovable,
                      isDownloadEnabled: widget.isDownloadEnabled,
                      onRemove: () {
                        if (widget.onRemove != null) {
                          widget.onRemove!(index);
                        } else {
                          removeFile(index);
                        }
                      },
                      onPreview: (media, mimetype) {
                        if (widget.isPreviewEnabled) {
                          previewFile(media, mimetype);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        );
  }

  void removeFile(int index) {
    int indexToRemove = index - 1;
    setState(() {
      widget.medias.removeAt(indexToRemove < 0 ? 0 : indexToRemove);
    });
  }

  void previewFile(CLMedia media, String mimeType) {
    !ResponsiveBreakpoints.of(context).isDesktop
        ? showModalBottomSheet(
          context: context,
          backgroundColor: CLTheme.of(context).secondaryBackground,
          builder: (context) {
            return StatefulBuilder(builder: (dialogContext, dialogSetState) => dialogContent(dialogContext, media, mimeType, dialogSetState));
          },
        )
        : showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              backgroundColor: CLTheme.of(context).secondaryBackground,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: StatefulBuilder(builder: (dialogContext, dialogSetState) => dialogContent(dialogContext, media, mimeType, dialogSetState)),
            );
          },
        );
  }

  Widget dialogContent(BuildContext context, CLMedia media, String mimeType, Function(void Function()) dialogSetState) {
    final fileColor = _FileTypeHelper.getColor(mimeType);
    final fileName = media.fileUrl != null ? getFileName(media.fileUrl!) : getFileName(media.file!.name);
    final isPdf = mimeType == 'application/pdf';

    return Container(
      clipBehavior: Clip.antiAlias,
      width: MediaQuery.of(context).size.width * (isPdf ? 0.55 : 0.6),
      height: isPdf ? MediaQuery.of(context).size.height * 0.85 : null,
      constraints: BoxConstraints(maxWidth: isPdf ? 850 : 900),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Sizes.borderRadius), color: CLTheme.of(context).secondaryBackground),
      child: Column(
        mainAxisSize: isPdf ? MainAxisSize.max : MainAxisSize.min,
        children: [
          // Preview area
          isPdf
              ? Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(Sizes.borderRadius), topRight: Radius.circular(Sizes.borderRadius)),
                    color: fileColor.withAlpha(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(Sizes.borderRadius), topRight: Radius.circular(Sizes.borderRadius)),
                    child: media.fileUrl != null
                        ? PdfViewer.uri(Uri.parse(media.fileUrl!))
                        : (media.file?.bytes != null
                            ? PdfViewer.data(media.file!.bytes!, sourceName: media.fileName ?? 'document.pdf')
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    HugeIcon(icon: _FileTypeHelper.getIcon(mimeType), color: fileColor, size: 64),
                                    const SizedBox(height: Sizes.small),
                                    Text('Impossibile caricare il PDF', style: CLTheme.of(context).heading6.override(color: fileColor)),
                                  ],
                                ),
                              )),
                  ),
                ),
              )
              : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(Sizes.borderRadius), topRight: Radius.circular(Sizes.borderRadius)),
                  color: fileColor.withAlpha(20),
                ),
                child:
                    mimeType.startsWith("image/")
                        ? AspectRatio(
                          aspectRatio: 16 / 9,
                          child:
                              media.fileUrl != null
                                  ? Image.network(media.fileUrl!, fit: BoxFit.contain)
                                  : Image.memory(media.file!.bytes!, fit: BoxFit.contain),
                        )
                        : mimeType.startsWith("video/")
                        ? AspectRatio(
                          aspectRatio: 16 / 9,
                          child: media.fileUrl != null ? ChewieVideoPlayerWidget(file: media.fileUrl) : ChewieVideoPlayerWidget(file: media.file),
                        )
                        : AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(Sizes.large),
                                  decoration: BoxDecoration(color: fileColor.withAlpha(30), shape: BoxShape.circle),
                                  child: HugeIcon(icon: _FileTypeHelper.getIcon(mimeType), color: fileColor, size: 64),
                                ),
                                const SizedBox(height: Sizes.small),
                                Text(_FileTypeHelper.getLabel(mimeType), style: CLTheme.of(context).heading6.override(color: fileColor)),
                              ],
                            ),
                          ),
                        ),
              ),
          // Footer con info file e azioni
          Container(
            padding: const EdgeInsets.all(Sizes.padding),
            decoration: BoxDecoration(
              color: CLTheme.of(context).primaryBackground,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(Sizes.borderRadius), bottomRight: Radius.circular(Sizes.borderRadius)),
            ),
            child: Row(
              children: [
                // Icona tipo file
                Container(
                  padding: const EdgeInsets.all(Sizes.small / 1.5),
                  decoration: BoxDecoration(color: fileColor.withAlpha(26), borderRadius: BorderRadius.circular(Sizes.borderRadius / 2)),
                  child: HugeIcon(icon: _FileTypeHelper.getIcon(mimeType), color: fileColor, size: Sizes.medium),
                ),
                const SizedBox(width: Sizes.small),
                // Info file
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CLTheme.of(context).bodyText.override(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: Sizes.padding / 4),
                      Text(media.fileSize ?? "0 KB", style: CLTheme.of(context).bodyLabel.override(color: CLTheme.of(context).secondaryText)),
                    ],
                  ),
                ),
                // Azioni
                if (widget.isDownloadEnabled) ...[
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) => dialogSetState(() => downloadHovered = true),
                    onExit: (_) => dialogSetState(() => downloadHovered = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.all(Sizes.small),
                      decoration: BoxDecoration(
                        color: downloadHovered ? CLTheme.of(context).primary.withAlpha(26) : Colors.transparent,
                        borderRadius: BorderRadius.circular(Sizes.borderRadius / 2),
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          if (media.fileUrl != null) {
                            await context.downloadFile(media.fileUrl!);
                          } else {
                            await context.downloadFile(media.file!);
                          }
                        },
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedDownload04,
                          color: downloadHovered ? CLTheme.of(context).primary : CLTheme.of(context).primaryText,
                          size: Sizes.medium,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Sizes.small / 2),
                ],
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => dialogSetState(() => closeHovered = true),
                  onExit: (_) => dialogSetState(() => closeHovered = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(Sizes.small),
                    decoration: BoxDecoration(
                      color: closeHovered ? CLTheme.of(context).danger.withAlpha(26) : Colors.transparent,
                      borderRadius: BorderRadius.circular(Sizes.borderRadius / 2),
                    ),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedCancel01,
                        color: closeHovered ? CLTheme.of(context).danger : CLTheme.of(context).primaryText,
                        size: Sizes.medium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getFileName(String url) {
    Uri uri = Uri.parse(url);
    String fileName = uri.path.split("/").last;
    return fileName;
  }
}

class CLMediaViewerItem extends StatefulWidget {
  const CLMediaViewerItem({
    super.key,
    required this.media,
    required this.onRemove(),
    required this.onPreview(CLMedia, String),
    required this.clMediaViewerMode,
    required this.isDownloadEnabled,
    required this.isItemRemovable,
  });

  final CLMedia media;
  final Function onRemove;
  final Function(CLMedia, String) onPreview;
  final bool isItemRemovable;
  final CLMediaViewerMode clMediaViewerMode;
  final bool isDownloadEnabled;

  @override
  State<CLMediaViewerItem> createState() => _CLMediaViewerItemState();
}

class _CLMediaViewerItemState extends State<CLMediaViewerItem> {
  bool hovered = false;
  String fileSize = "";

  @override
  void initState() {
    super.initState();
    _fetchFileSize();
  }

  Future<void> _fetchFileSize() async {
    String size = "";
    if (widget.media.fileUrl != null) {
      size = await getFileSizeFromUrl(widget.media.fileUrl!);
    } else {
      size = await getFileSizeFromFile(widget.media.file!);
    }
    setState(() {
      fileSize = size;
    });
  }

  @override
  Widget build(BuildContext context) {
    String mimeType = "";
    if (widget.media.fileUrl != null) {
      widget.media.fileName = getFileName(widget.media.fileUrl!);
    } else {
      widget.media.fileName = getFileName(widget.media.file!.name);
    }

    widget.media.fileSize = fileSize;
    if (widget.media.fileUrl != null) {
      mimeType = lookupMimeType(getFileName(widget.media.fileUrl!)) ?? "";
    } else {
      mimeType = lookupMimeType(getFileName(widget.media.file!.name)) ?? "";
    }

    final fileColor = _FileTypeHelper.getColor(mimeType);
    final fileName = widget.media.fileUrl != null ? getFileName(widget.media.fileUrl!) : getFileName(widget.media.file!.name);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: GestureDetector(
        onTap: () => widget.onPreview(widget.media, mimeType),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 280,
          decoration: BoxDecoration(
            border: Border.all(color: hovered ? CLTheme.of(context).primary.withAlpha(100) : CLTheme.of(context).borderColor, width: 1),
            borderRadius: BorderRadius.circular(Sizes.borderRadius),
            color: CLTheme.of(context).secondaryBackground,
            boxShadow: hovered ? [BoxShadow(color: CLTheme.of(context).primary.withAlpha(20), blurRadius: 12, offset: const Offset(0, 4))] : [],
          ),
          child:
              widget.clMediaViewerMode == CLMediaViewerMode.previewMode
                  ? _buildPreviewMode(context, mimeType, fileColor, fileName)
                  : _buildCardMode(context, mimeType, fileColor, fileName),
        ),
      ),
    );
  }

  Widget _buildPreviewMode(BuildContext context, String mimeType, Color fileColor, String fileName) {
    return Column(
      children: [
        // Preview area
        Expanded(
          flex: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(Sizes.borderRadius - 1), topRight: Radius.circular(Sizes.borderRadius - 1)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(Sizes.borderRadius - 1), topRight: Radius.circular(Sizes.borderRadius - 1)),
                color: fileColor.withAlpha(20),
              ),
              child: Stack(
                children: [
                  // Content
                  Center(
                    child:
                        mimeType.startsWith("image/")
                            ? widget.media.fileUrl != null
                                ? Image.network(widget.media.fileUrl!, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                                : Image.memory(widget.media.file!.bytes!, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                            : mimeType.startsWith("video/")
                            ? widget.media.fileUrl != null
                                ? VideoPlayerWidget(file: widget.media.fileUrl)
                                : VideoPlayerWidget(file: widget.media.file)
                            : mimeType == 'application/pdf'
                            ? IgnorePointer(
                              child: widget.media.fileUrl != null
                                  ? PdfViewer.uri(Uri.parse(widget.media.fileUrl!))
                                  : (widget.media.file?.bytes != null
                                      ? PdfViewer.data(widget.media.file!.bytes!, sourceName: widget.media.fileName ?? 'document.pdf')
                                      : Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            HugeIcon(icon: _FileTypeHelper.getIcon(mimeType), color: fileColor, size: 48),
                                            const SizedBox(height: 8),
                                            Text(_FileTypeHelper.getLabel(mimeType), style: CLTheme.of(context).bodyLabel.override(color: fileColor, fontWeight: FontWeight.w600)),
                                          ],
                                        )),
                            )
                            : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                HugeIcon(icon: _FileTypeHelper.getIcon(mimeType), color: fileColor, size: 48),
                                const SizedBox(height: 8),
                                Text(
                                  _FileTypeHelper.getLabel(mimeType),
                                  style: CLTheme.of(context).bodyLabel.override(color: fileColor, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                  ),
                  // Hover overlay
                  if (hovered)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(Sizes.borderRadius - 1),
                            topRight: Radius.circular(Sizes.borderRadius - 1),
                          ),
                          color: Colors.black.withAlpha(100),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white.withAlpha(40), shape: BoxShape.circle),
                            child: HugeIcon(icon: HugeIcons.strokeRoundedView, color: Colors.white, size: 28),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        // Footer
        Container(
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.all(Sizes.small),
          decoration: BoxDecoration(
            color: CLTheme.of(context).primaryBackground,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(Sizes.borderRadius - 1),
              bottomRight: Radius.circular(Sizes.borderRadius - 1),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(Sizes.small / 1.5),
                decoration: BoxDecoration(color: fileColor.withAlpha(26), borderRadius: BorderRadius.circular(Sizes.borderRadius / 2)),
                child: HugeIcon(icon: _FileTypeHelper.getIcon(mimeType), color: fileColor, size: Sizes.medium),
              ),
              const SizedBox(width: Sizes.small),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CLTheme.of(context).bodyText.override(fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.media.fileSize ?? "0 KB",
                      style: CLTheme.of(context).bodyLabel.override(fontSize: 11, color: CLTheme.of(context).secondaryText),
                    ),
                  ],
                ),
              ),
              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isDownloadEnabled)
                    _buildActionButton(
                      context,
                      icon: HugeIcons.strokeRoundedDownload04,
                      onTap: () async {
                        if (widget.media.fileUrl != null) {
                          await context.downloadFile(widget.media.fileUrl!);
                        } else {
                          await context.downloadFile(widget.media.file!);
                        }
                      },
                    ),
                  if (widget.isItemRemovable) ...[
                    const SizedBox(width: 4),
                    _buildActionButton(context, icon: HugeIcons.strokeRoundedDelete02, isDestructive: true, onTap: () => widget.onRemove()),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardMode(BuildContext context, String mimeType, Color fileColor, String fileName) {
    return Row(
      children: [
        // Icon container
        Container(
          width: 60,
          height: double.infinity,
          decoration: BoxDecoration(
            color: fileColor.withAlpha(20),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(Sizes.borderRadius - 1), bottomLeft: Radius.circular(Sizes.borderRadius - 1)),
          ),
          child: Stack(
            children: [
              Center(child: HugeIcon(icon: _FileTypeHelper.getIcon(mimeType), color: fileColor, size: 28)),
              if (hovered && widget.isDownloadEnabled)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () async {
                      if (widget.media.fileUrl != null) {
                        await context.downloadFile(widget.media.fileUrl!);
                      } else {
                        await context.downloadFile(widget.media.file!);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(100),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(Sizes.borderRadius - 1),
                          bottomLeft: Radius.circular(Sizes.borderRadius - 1),
                        ),
                      ),
                      child: Center(child: HugeIcon(icon: HugeIcons.strokeRoundedDownload04, color: Colors.white, size: 24)),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Info
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.small, vertical: Sizes.small / 1.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CLTheme.of(context).bodyText.override(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: Sizes.small / 2, vertical: 2),
                      decoration: BoxDecoration(color: fileColor.withAlpha(26), borderRadius: BorderRadius.circular(Sizes.borderRadius / 3)),
                      child: Text(
                        _FileTypeHelper.getLabel(mimeType),
                        style: CLTheme.of(context).bodyLabel.override(fontSize: 10, color: fileColor, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: Sizes.small / 2),
                    Text(
                      widget.media.fileSize ?? "0 KB",
                      style: CLTheme.of(context).bodyLabel.override(fontSize: 11, color: CLTheme.of(context).secondaryText),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Delete action
        if (widget.isItemRemovable)
          Padding(
            padding: const EdgeInsets.only(right: Sizes.small / 1.5),
            child: _buildActionButton(context, icon: HugeIcons.strokeRoundedDelete02, isDestructive: true, onTap: () => widget.onRemove()),
          ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, {required dynamic icon, required VoidCallback onTap, bool isDestructive = false}) {
    return _ActionButton(icon: icon, onTap: onTap, isDestructive: isDestructive);
  }

  String? detectMimeType(String url) {
    String path = getFileName(url);
    return lookupMimeType(path);
  }

  String getFileName(String url) {
    Uri uri = Uri.parse(url);
    String fileName = uri.path.split("/").last;
    return fileName;
  }

  Future<String> getFileSizeFromUrl(String url) async {
    try {
      var response = await http.get(Uri.parse(url), headers: {"Range": "bytes=0-1"});

      if (response.statusCode == 206 || response.statusCode == 200) {
        String? contentLength = response.headers['content-range'];
        if (contentLength != null) {
          RegExp regex = RegExp(r"/(\d+)");
          Match? match = regex.firstMatch(contentLength);
          if (match != null) {
            int fileSizeInBytes = int.parse(match.group(1)!);
            return formatFileSize(fileSizeInBytes);
          }
        }
      }
    } catch (e) {}

    return "0 KB";
  }

  Future<String> getFileSizeFromFile(PlatformFile file) async {
    try {
      return formatFileSize(file.size);
    } catch (e) {}

    return "0 KB";
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return "$bytes B";
    } else if (bytes < 1024 * 1024) {
      return "${(bytes / 1024).toStringAsFixed(2)} KB";
    } else if (bytes < 1024 * 1024 * 1024) {
      return "${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB";
    } else if (bytes < 1024 * 1024 * 1024 * 1024) {
      return "${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB";
    } else {
      return "${(bytes / (1024 * 1024 * 1024 * 1024)).toStringAsFixed(2)} TB";
    }
  }
}

class CLMedia {
  String? fileUrl;
  PlatformFile? file;
  String? fileSize;
  String? fileName;

  CLMedia({this.fileUrl, this.file});
}

class VideoPlayerWidget extends StatefulWidget {
  final dynamic file;

  const VideoPlayerWidget({super.key, required this.file});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<dynamic> saveBytesToFile(Uint8List bytes, String fileName) async {
    if (kIsWeb) {
      // 🔹 WEB: Create a virtual file and trigger download
      final blob = html.Blob([widget.file.bytes!]);
      return html.Url.createObjectUrlFromBlob(blob);
    } else {
      // 🔹 MOBILE/DESKTOP: Save the file locally
      final tempDir = await getTemporaryDirectory();
      final file = File("${tempDir.path}/$fileName");
      await file.writeAsBytes(bytes);
      return file;
    }
  }

  void _initializeVideo() async {
    if (widget.file is PlatformFile) {
      dynamic videoFile = await saveBytesToFile(widget.file.bytes!, widget.file.name);
      if (kIsWeb) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(videoFile!))
          ..initialize().then((_) {
            setState(() {});
            _controller!.setLooping(true);
            // _controller!.play();
          });
      } else {
        _controller = VideoPlayerController.file(videoFile)
          ..initialize().then((_) {
            setState(() {});
            _controller!.setLooping(true);
            // _controller!.play();
          });
      }
    } else {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.file))
        ..initialize().then((_) {
          setState(() {});
          _controller!.setLooping(true);
          // _controller!.play();
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller == null || !_controller!.value.isInitialized
        ? const Center(child: CircularProgressIndicator()) // Loader durante il caricamento
        : AspectRatio(aspectRatio: _controller!.value.aspectRatio, child: VideoPlayer(_controller!));
  }
}

class ChewieVideoPlayerWidget extends StatefulWidget {
  final dynamic file;

  const ChewieVideoPlayerWidget({super.key, this.file});

  @override
  _ChewieVideoPlayerWidgetState createState() => _ChewieVideoPlayerWidgetState();
}

class _ChewieVideoPlayerWidgetState extends State<ChewieVideoPlayerWidget> {
  VideoPlayerController? _controller;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<dynamic> saveBytesToFile(Uint8List bytes, String fileName) async {
    if (kIsWeb) {
      // 🔹 WEB: Create a virtual file and trigger download
      final blob = html.Blob([widget.file.bytes!]);
      return html.Url.createObjectUrlFromBlob(blob);
    } else {
      // 🔹 MOBILE/DESKTOP: Save the file locally
      final tempDir = await getTemporaryDirectory();
      final file = File("${tempDir.path}/$fileName");
      await file.writeAsBytes(bytes);
      return file;
    }
  }

  void _initializeVideo() async {
    if (widget.file is PlatformFile) {
      dynamic videoFile = await saveBytesToFile(widget.file.bytes!, widget.file.name);
      if (kIsWeb) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(videoFile!))
          ..initialize().then((_) {
            _setupChewie();
            setState(() {});
          });
      } else {
        _controller = VideoPlayerController.file(videoFile)
          ..initialize().then((_) {
            _setupChewie();

            setState(() {});
          });
      }
    } else {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.file))
        ..initialize().then((_) {
          _setupChewie();
          setState(() {});
        });
    }
  }

  void _setupChewie() {
    _chewieController = ChewieController(
      videoPlayerController: _controller!,
      autoPlay: true,
      looping: false,
      showControls: true,
      // ✅ Abilita controlli play/pause, volume, fullscreen
      allowFullScreen: true,
      showOptions: false,
      allowPlaybackSpeedChanging: false,
      allowMuting: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.blue,
        handleColor: Colors.white,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.lightBlueAccent,
      ),
      aspectRatio: _controller!.value.aspectRatio,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _chewieController == null ? const Center(child: CircularProgressIndicator()) : Chewie(controller: _chewieController!);
  }
}

// Widget separato per gestire correttamente lo stato hover
class _ActionButton extends StatefulWidget {
  final dynamic icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionButton({required this.icon, required this.onTap, this.isDestructive = false});

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(Sizes.small / 2),
          decoration: BoxDecoration(
            color:
                isHovered
                    ? (widget.isDestructive ? CLTheme.of(context).danger.withAlpha(26) : CLTheme.of(context).primary.withAlpha(26))
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(Sizes.borderRadius / 2),
          ),
          child: HugeIcon(
            icon: widget.icon,
            color: isHovered ? (widget.isDestructive ? CLTheme.of(context).danger : CLTheme.of(context).primary) : CLTheme.of(context).secondaryText,
            size: Sizes.medium,
          ),
        ),
      ),
    );
  }
}

enum CLMediaViewerMode { previewMode, tableMode, cardMode }
