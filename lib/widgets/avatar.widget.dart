import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mime/mime.dart';
import '../cl_theme.dart';

import 'cl_media_viewer.widget.dart';

/// CLAvatarWidget — avatar circolare con stack di media o iniziali su gradient.
///
/// Linguaggio Skillera Refined Editorial:
/// - cerchio pieno (`shape: BoxShape.circle`)
/// - sfondo a gradient generato dall'hash del nome
///   (`CLTheme.generateColorFromText`) per identità visiva stabile
/// - iniziali Inter Bold bianche, centrate
/// - misure consigliate: `CLSizes.avatarSize{Small,Medium,Large}`
///   (24 / 36 / 48). I default storici sono mantenuti per non rompere l'API.
class CLAvatarWidget extends StatelessWidget {
  const CLAvatarWidget({
    super.key,
    required this.medias,
    required this.name,
    this.elementToPreview = 1,
    this.iconSize = 35,
    this.fontSize = 14,
  });

  final List<CLMedia> medias;
  final int elementToPreview;
  final String name;
  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    if (medias.isEmpty) {
      return _initialsAvatar(context, name, withWhiteBorder: false);
    }

    return SizedBox(
      width: iconSize + (elementToPreview * 20),
      height: iconSize,
      child: Stack(
        children: medias.asMap().entries.map((entry) {
          int index = entry.key;
          CLMedia media = entry.value;
          if (index >= elementToPreview) {
            return Positioned(
              left: (elementToPreview * 20).toDouble(),
              child: _initialsAvatar(
                context,
                "+ ${medias.length - elementToPreview}",
                withWhiteBorder: true,
                borderWidth: 1.5,
              ),
            );
          }
          return Positioned(
            left: (index * 20).toDouble(),
            child: Container(
              constraints: BoxConstraints.tight(Size.square(iconSize)),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _tintBgFor(context, name),
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
              ),
              child: _buildImage(context, media.fileUrl!),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Bg tinted alpha 0.12 dal color hash del nome — pattern coerente con
  /// menu selected item / pill page header / accreditation icons.
  Color _tintBgFor(BuildContext context, String text) {
    final base = CLTheme.of(context).generateColorFromText(text);
    return base.withValues(alpha: 0.12);
  }

  /// Color base hash (per icone/iniziali su tinted bg).
  Color _baseFor(BuildContext context, String text) {
    return CLTheme.of(context).generateColorFromText(text);
  }

  Widget _initialsAvatar(
    BuildContext context,
    String text, {
    required bool withWhiteBorder,
    double borderWidth = 1,
  }) {
    return Container(
      constraints: BoxConstraints.tight(Size.square(iconSize)),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _tintBgFor(context, text),
        border: withWhiteBorder
            ? Border.all(
                color: Colors.white,
                width: borderWidth,
                strokeAlign: BorderSide.strokeAlignOutside,
              )
            : null,
      ),
      child: _buildInitialsWidget(context, text),
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
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey));
            },
          )
        : mimeType.startsWith("video/")
            ? Padding(
                padding: const EdgeInsets.all(10.0),
                child: SvgPicture.asset(
                  "assets/svgs/video.svg",
                  fit: BoxFit.cover,
                  colorFilter:
                      ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              )
            : mimeType.startsWith(
                    "application/vnd.openxmlformats-officedocument.wordprocessingml.document")
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      "assets/svgs/word.svg",
                      fit: BoxFit.cover,
                    ),
                  )
                : mimeType.startsWith(
                            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet") ||
                        mimeType.startsWith("application/vnd.ms-excel")
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SvgPicture.asset("assets/svgs/excel.svg",
                            fit: BoxFit.cover))
                    : mimeType.startsWith("application/pdf")
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SvgPicture.asset("assets/svgs/pdf.svg",
                                fit: BoxFit.fitHeight))
                        : mimeType.startsWith("application/zip")
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SvgPicture.asset("assets/svgs/zip.svg",
                                    fit: BoxFit.fitHeight))
                            : mimeType
                                    .startsWith("application/x-rar-compressed")
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SvgPicture.asset(
                                        "assets/svgs/rar.svg",
                                        fit: BoxFit.cover))
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SvgPicture.asset(
                                      "assets/svgs/file.svg",
                                      fit: BoxFit.cover,
                                      colorFilter: ColorFilter.mode(
                                          CLTheme.hexToColor("#647F94"),
                                          BlendMode.srcIn),
                                    ),
                                  );
  }

  String _buildInitials(String fullName) {
    const String fallbackInitial = 'N/A';
    final nameParts = fullName.split(' ');
    String initials = '';
    if (nameParts.isNotEmpty) {
      initials = nameParts
          .where((part) => part.isNotEmpty)
          .map((part) => part[0])
          .take(2)
          .join();
    }
    if (initials.isEmpty) {
      initials = fallbackInitial;
    }
    return initials.toUpperCase();
  }

  Widget _buildInitialsWidget(BuildContext context, String fullName) {
    String initials = _buildInitials(fullName);
    return Center(
      child: Text(
        initials.toUpperCase(),
        style: CLTheme.of(context).smallText.override(
              color: _baseFor(context, fullName),
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
      ),
    );
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
