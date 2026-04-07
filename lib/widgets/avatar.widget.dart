import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mime/mime.dart';
import 'package:genai_components/cl_theme.dart';

import 'cl_media_viewer.widget.dart';

class CLAvatarWidget extends StatelessWidget {
  const CLAvatarWidget({super.key, required this.medias, required this.name, this.elementToPreview = 1, this.iconSize = 35, this.fontSize = 14});

  final List<CLMedia> medias;
  final int elementToPreview;
  final String name;
  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return medias.isEmpty
        ? Container(
          constraints: BoxConstraints.tight(Size.square(iconSize)),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(shape: BoxShape.circle, color: CLTheme.of(context).generateColorFromText(_buildInitials(name))),
          child: _buildInitialsWidget(context, name),
        )
        : Stack(
          children:
              medias.asMap().entries.map((entry) {
                int index = entry.key;
                CLMedia media = entry.value;
                if (index >= elementToPreview) {
                  return Positioned(
                    left: (elementToPreview * 20).toDouble(),
                    child: Container(
                      constraints: BoxConstraints.tight(Size.square(iconSize)),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: CLTheme.of(context).generateColorFromText(_buildInitials(name)),
                        border: Border.all(color: Colors.white, width: 1.5, strokeAlign: BorderSide.strokeAlignOutside),
                      ),
                      child: _buildInitialsWidget(context, "+ ${medias.length - elementToPreview}"),
                    ),
                  );
                } else {
                  return Positioned(
                    left: (index * 20).toDouble(),
                    child: Container(
                      constraints: BoxConstraints.tight(Size.square(iconSize)),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: CLTheme.of(context).generateColorFromText(_buildInitials(name)),
                        border: Border.all(color: Colors.white, width: 1, strokeAlign: BorderSide.strokeAlignOutside),
                      ),
                      child: _buildImage(context, media.fileUrl!),
                    ),
                  );
                }
              }).toList(),
        );
  }

  Widget _buildImage(BuildContext context, String mediaPath) {
    String mimeType = detectMimeType(mediaPath) ?? "";
    return mimeType.startsWith("image/")
        ? Image.network(
          mediaPath,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey));
          },
        )
        : mimeType.startsWith("video/")
        ? Padding(
          padding: const EdgeInsets.all(10.0),
          child: SvgPicture.asset(
            "assets/svgs/video.svg", // Ora verrà rispettato
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        )
        : mimeType.startsWith("application/vnd.openxmlformats-officedocument.wordprocessingml.document")
        ? Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset(
            "assets/svgs/word.svg", // Ora verrà rispettato
            fit: BoxFit.cover,
          ),
        )
        : mimeType.startsWith("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet") || mimeType.startsWith("application/vnd.ms-excel")
        ? Padding(padding: const EdgeInsets.all(8.0), child: SvgPicture.asset("assets/svgs/excel.svg", fit: BoxFit.cover))
        : mimeType.startsWith("application/pdf")
        ? Padding(padding: const EdgeInsets.all(8.0), child: SvgPicture.asset("assets/svgs/pdf.svg", fit: BoxFit.fitHeight))
        : mimeType.startsWith("application/zip")
        ? Padding(padding: const EdgeInsets.all(8.0), child: SvgPicture.asset("assets/svgs/zip.svg", fit: BoxFit.fitHeight))
        : mimeType.startsWith("application/x-rar-compressed")
        ? Padding(padding: const EdgeInsets.all(8.0), child: SvgPicture.asset("assets/svgs/rar.svg", fit: BoxFit.cover))
        : Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset(
            "assets/svgs/file.svg",
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(CLTheme.hexToColor("#647F94"), BlendMode.srcIn), // Giallo per immagini
          ),
        );
  }

  String _buildInitials(String fullName) {
    const String fallbackInitial = 'N/A';
    final nameParts = fullName.split(' ');
    String initials = '';
    if (nameParts.isNotEmpty) {
      initials = nameParts.where((part) => part.isNotEmpty).map((part) => part[0]).take(2).join();
    }
    if (initials.isEmpty) {
      initials = fallbackInitial;
    }
    return initials.toUpperCase();
  }

  Widget _buildInitialsWidget(BuildContext context, String fullName) {
    String initials = _buildInitials(fullName);
    return Center(child: Text(initials.toUpperCase(), style: CLTheme.of(context).smallText.copyWith(color: Colors.white, fontSize: fontSize)));
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
}
