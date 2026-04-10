import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/cl_media_viewer.widget.dart';

class FFUploadedFile {
  final CLMedia clMedia;
  final double? height;
  final double? width;
  final String? mimeType;

  const FFUploadedFile({
    required this.clMedia,
    this.height,
    this.width,
    this.mimeType,
  });

  /// 🔄 Crea un oggetto `FFUploadedFile` da un `XFile`
  static Future<FFUploadedFile> fromXFile(XFile file) async {
    Uint8List fileBytes = await file.readAsBytes();

    return FFUploadedFile(
      clMedia: CLMedia(
          file: PlatformFile(
        name: file.name,
        size: fileBytes.length,
        bytes: fileBytes,
        path: null, // in questo caso il file non è salvato localmente
      )),
      mimeType: file.mimeType ?? 'application/octet-stream',
    );
  }

  String serialize() {
    final bytes = clMedia.file?.bytes;
    return jsonEncode({
      'name': clMedia.file?.name,
      'bytes': bytes != null ? base64Encode(bytes) : null,
      'height': height,
      'width': width,
      'mimeType': mimeType,
    });
  }

  static FFUploadedFile deserialize(String jsonString) {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final name = data['name'] as String?;
    final bytes = data['bytes'] != null ? base64Decode(data['bytes']) : null;
    final size = bytes?.length ?? 0;

    // Crea il PlatformFile usando i dati decodificati
    final platformFile = PlatformFile(
      name: name ?? '',
      size: size,
      bytes: bytes,
      path: null, // In questo caso il file non è salvato localmente
    );

    // Incapsula il file in un oggetto CLMedia
    final clMedia = CLMedia(file: platformFile);

    return FFUploadedFile(
      clMedia: clMedia,
      height: (data['height'] as num?)?.toDouble(),
      width: (data['width'] as num?)?.toDouble(),
      mimeType: data['mimeType'] as String?,
    );
  }

  @override
  String toString() => 'FFUploadedFile(name: ${clMedia.file?.name}, size: ${clMedia.file?.bytes?.length ?? 0}, mimeType: $mimeType)';
}
