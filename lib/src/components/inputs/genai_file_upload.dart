import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';
import '../actions/genai_button.dart';
import '../actions/genai_icon_button.dart';
import '../feedback/genai_progress_bar.dart';

class GenaiUploadedFile {
  final String name;
  final int sizeBytes;
  final String? mimeType;
  final Uint8List? bytes;
  final String? path;
  final double? progress; // 0..1, null when complete or not started
  final String? errorMessage;

  const GenaiUploadedFile({
    required this.name,
    required this.sizeBytes,
    this.mimeType,
    this.bytes,
    this.path,
    this.progress,
    this.errorMessage,
  });

  GenaiUploadedFile copyWith({double? progress, String? errorMessage}) => GenaiUploadedFile(
        name: name,
        sizeBytes: sizeBytes,
        mimeType: mimeType,
        bytes: bytes,
        path: path,
        progress: progress ?? this.progress,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

/// File upload (§6.1.10).
///
/// Logic-only widget: file picking is delegated to [onPickRequested] so the
/// host app can use whatever picker (file_picker / image_picker / web input).
class GenaiFileUpload extends StatefulWidget {
  final String? label;
  final String? helperText;
  final String? errorText;
  final List<GenaiUploadedFile> files;
  final ValueChanged<List<GenaiUploadedFile>>? onChanged;
  final VoidCallback? onPickRequested;
  final bool isMulti;
  final bool isDisabled;
  final List<String> acceptedExtensions;
  final int? maxSizeBytes;

  const GenaiFileUpload({
    super.key,
    this.label,
    this.helperText,
    this.errorText,
    required this.files,
    this.onChanged,
    this.onPickRequested,
    this.isMulti = false,
    this.isDisabled = false,
    this.acceptedExtensions = const [],
    this.maxSizeBytes,
  });

  const GenaiFileUpload.multi({
    super.key,
    this.label,
    this.helperText,
    this.errorText,
    required this.files,
    this.onChanged,
    this.onPickRequested,
    this.isDisabled = false,
    this.acceptedExtensions = const [],
    this.maxSizeBytes,
  }) : isMulti = true;

  @override
  State<GenaiFileUpload> createState() => _GenaiFileUploadState();
}

class _GenaiFileUploadState extends State<GenaiFileUpload> {
  bool _hovering = false;

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }

  void _remove(GenaiUploadedFile f) {
    widget.onChanged?.call(widget.files.where((x) => x != f).toList());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    final children = <Widget>[];
    if (widget.label != null) {
      children.add(Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(widget.label!, style: ty.label.copyWith(color: colors.textPrimary)),
      ));
    }

    final dropzone = MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.isDisabled ? null : widget.onPickRequested,
        child: DottedBorderBox(
          color: hasError ? colors.borderError : (_hovering ? colors.colorPrimary : colors.borderStrong),
          radius: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            color: _hovering ? colors.colorPrimarySubtle : Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.cloudUpload, size: 32, color: colors.textSecondary),
                const SizedBox(height: 8),
                Text(
                  widget.isMulti ? 'Trascina i file qui o clicca per selezionare' : 'Trascina un file qui o clicca per selezionare',
                  style: ty.bodyMd.copyWith(color: colors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                if (widget.acceptedExtensions.isNotEmpty || widget.maxSizeBytes != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (widget.acceptedExtensions.isNotEmpty) widget.acceptedExtensions.join(', '),
                      if (widget.maxSizeBytes != null) 'max ${_formatSize(widget.maxSizeBytes!)}',
                    ].join(' • '),
                    style: ty.caption.copyWith(color: colors.textSecondary),
                  ),
                ],
                const SizedBox(height: 12),
                GenaiButton.outline(
                  label: 'Seleziona file',
                  size: GenaiSize.sm,
                  onPressed: widget.isDisabled ? null : widget.onPickRequested,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    children.add(dropzone);

    if (widget.files.isNotEmpty) {
      children.add(const SizedBox(height: 8));
      for (final f in widget.files) {
        children.add(Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.surfaceCard,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: f.errorMessage != null ? colors.borderError : colors.borderDefault),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.file, size: 20, color: colors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(f.name, style: ty.label.copyWith(color: colors.textPrimary), overflow: TextOverflow.ellipsis),
                      Text(
                        f.errorMessage ?? _formatSize(f.sizeBytes),
                        style: ty.caption.copyWith(color: f.errorMessage != null ? colors.textError : colors.textSecondary),
                      ),
                      if (f.progress != null && f.progress! < 1) ...[
                        const SizedBox(height: 4),
                        GenaiProgressBar(value: f.progress),
                      ],
                    ],
                  ),
                ),
                GenaiIconButton(
                  icon: LucideIcons.x,
                  size: GenaiSize.xs,
                  semanticLabel: 'Rimuovi',
                  onPressed: () => _remove(f),
                ),
              ],
            ),
          ),
        ));
      }
    }

    if (widget.helperText != null || hasError) {
      children.add(Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          widget.errorText ?? widget.helperText!,
          style: ty.caption.copyWith(color: hasError ? colors.textError : colors.textSecondary),
        ),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

/// Dashed border container used by [GenaiFileUpload].
class DottedBorderBox extends StatelessWidget {
  final Widget child;
  final Color color;
  final double radius;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  const DottedBorderBox({
    super.key,
    required this.child,
    required this.color,
    this.radius = 8,
    this.dashWidth = 6,
    this.dashSpace = 4,
    this.strokeWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: color,
        radius: radius,
        dashWidth: dashWidth,
        dashSpace: dashSpace,
        strokeWidth: strokeWidth,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.dashWidth,
    required this.dashSpace,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final next = dist + dashWidth;
        canvas.drawPath(metric.extractPath(dist, next.clamp(0, metric.length)), paint);
        dist = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color || old.radius != radius || old.dashWidth != dashWidth || old.dashSpace != dashSpace || old.strokeWidth != strokeWidth;
}
