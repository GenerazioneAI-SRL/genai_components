import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '_field_frame.dart';

/// Metadata for a single uploaded file — v3 Forma LMS.
///
/// Rendered as a row below the drop zone. Consumers choose whatever transport
/// they like (multipart, direct upload, AI ingest) and merely feed progress +
/// status back via [GenaiUploadedFile].
@immutable
class GenaiUploadedFile {
  /// Display name (typically the filename).
  final String name;

  /// File size in bytes. Null = unknown.
  final int? sizeBytes;

  /// MIME type (e.g. `image/png`). Null = unknown.
  final String? mimeType;

  /// 0.0 to 1.0 progress. Ignored when [status] != uploading.
  final double progress;

  /// Current upload status.
  final GenaiUploadStatus status;

  /// Error copy — shown instead of progress when [status] is `error`.
  final String? errorText;

  const GenaiUploadedFile({
    required this.name,
    this.sizeBytes,
    this.mimeType,
    this.progress = 0.0,
    this.status = GenaiUploadStatus.done,
    this.errorText,
  });
}

/// Upload lifecycle state for a single [GenaiUploadedFile].
enum GenaiUploadStatus {
  /// Transfer in progress — `progress` is displayed as a determinate bar.
  uploading,

  /// Transfer completed successfully.
  done,

  /// Transfer failed — `errorText` is surfaced instead of progress.
  error,
}

/// Drop-zone + file-list uploader — v3 Forma LMS.
///
/// UI-only: calls [onPickFiles] when the user clicks the zone or drops files
/// (drop-detection is web-only and left to the host app). The host feeds
/// back [files] with any progress/error metadata.
class GenaiFileUpload extends StatefulWidget {
  /// Files currently displayed under the drop zone.
  final List<GenaiUploadedFile> files;

  /// Fired when the user clicks the zone.
  final VoidCallback? onPickFiles;

  /// Fired when the user removes a file row.
  final ValueChanged<int>? onRemove;

  /// Field label above the zone.
  final String? label;

  /// Placeholder inside the zone — defaults to standard Italian copy.
  final String? hintText;

  /// Helper copy below.
  final String? helperText;

  /// Error copy; takes precedence over helper.
  final String? errorText;

  /// Appends a red asterisk after [label].
  final bool isRequired;

  /// Muted colours, no interaction.
  final bool isDisabled;

  /// Screen-reader label override.
  final String? semanticLabel;

  const GenaiFileUpload({
    super.key,
    this.files = const [],
    this.onPickFiles,
    this.onRemove,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.isRequired = false,
    this.isDisabled = false,
    this.semanticLabel,
  });

  @override
  State<GenaiFileUpload> createState() => _GenaiFileUploadState();
}

class _GenaiFileUploadState extends State<GenaiFileUpload> {
  bool _hovered = false;
  bool _focused = false;

  bool get _hasError =>
      widget.errorText != null && widget.errorText!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final radius = context.radius;
    final motion = context.motion;

    final borderColor = widget.isDisabled
        ? colors.borderSubtle
        : _hasError
            ? colors.colorDanger
            : _focused || _hovered
                ? colors.textPrimary
                : colors.borderStrong;

    final dropZone = Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: MouseRegion(
        cursor: widget.isDisabled
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.isDisabled ? null : widget.onPickFiles,
          child: AnimatedContainer(
            duration: motion.hover.duration,
            curve: motion.hover.curve,
            padding: EdgeInsets.all(spacing.s20),
            decoration: BoxDecoration(
              color:
                  widget.isDisabled ? colors.surfaceHover : colors.surfaceCard,
              borderRadius: BorderRadius.circular(radius.xl),
              border: Border.all(
                color: borderColor,
                width: (_focused || _hovered || _hasError)
                    ? sizing.focusRingWidth
                    : 1.0,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.cloudUpload,
                    size: sizing.iconEmptyState, color: colors.textTertiary),
                SizedBox(height: spacing.s8),
                Text(
                  widget.hintText ??
                      'Clicca per caricare o rilascia i file qui',
                  style: ty.bodySm.copyWith(color: colors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final fileList = widget.files.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: EdgeInsets.only(top: spacing.s8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < widget.files.length; i++) ...[
                  if (i > 0) SizedBox(height: spacing.s4),
                  _FileRow(
                    file: widget.files[i],
                    onRemove: widget.isDisabled
                        ? null
                        : () => widget.onRemove?.call(i),
                  ),
                ],
              ],
            ),
          );

    return Semantics(
      button: true,
      label: widget.semanticLabel ?? widget.label ?? 'Caricamento file',
      enabled: !widget.isDisabled,
      focused: _focused,
      child: FieldFrame(
        label: widget.label,
        isRequired: widget.isRequired,
        isDisabled: widget.isDisabled,
        helperText: widget.helperText,
        errorText: widget.errorText,
        control: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [dropZone, fileList],
        ),
      ),
    );
  }
}

class _FileRow extends StatelessWidget {
  final GenaiUploadedFile file;
  final VoidCallback? onRemove;

  const _FileRow({required this.file, this.onRemove});

  String _formatBytes(int? b) {
    if (b == null) return '';
    if (b < 1024) return '$b B';
    if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(1)} KB';
    if (b < 1024 * 1024 * 1024) {
      return '${(b / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(b / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final radius = context.radius;

    final isError = file.status == GenaiUploadStatus.error;
    final isUploading = file.status == GenaiUploadStatus.uploading;

    final statusIcon = switch (file.status) {
      GenaiUploadStatus.uploading => LucideIcons.loader,
      GenaiUploadStatus.done => LucideIcons.check,
      GenaiUploadStatus.error => LucideIcons.circleAlert,
    };
    final statusColor = switch (file.status) {
      GenaiUploadStatus.uploading => colors.textTertiary,
      GenaiUploadStatus.done => colors.colorSuccess,
      GenaiUploadStatus.error => colors.colorDanger,
    };

    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: spacing.s12, vertical: spacing.s8),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(radius.md),
        border: Border.all(
            color: isError ? colors.colorDanger : colors.borderDefault),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.file,
              size: sizing.iconSize, color: colors.textSecondary),
          SizedBox(width: spacing.iconLabelGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(file.name,
                    style: ty.bodySm.copyWith(color: colors.textPrimary),
                    overflow: TextOverflow.ellipsis),
                if (file.sizeBytes != null || isError)
                  Padding(
                    padding: EdgeInsets.only(top: spacing.s2),
                    child: Text(
                      isError
                          ? file.errorText ?? 'Caricamento non riuscito'
                          : _formatBytes(file.sizeBytes),
                      style: ty.labelSm.copyWith(
                        color: isError
                            ? colors.colorDangerText
                            : colors.textTertiary,
                      ),
                    ),
                  ),
                if (isUploading) ...[
                  SizedBox(height: spacing.s4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(radius.xs),
                    child: LinearProgressIndicator(
                      value: file.progress.clamp(0.0, 1.0),
                      minHeight: 4,
                      backgroundColor: colors.borderSubtle,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(colors.colorPrimary),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: spacing.iconLabelGap),
          Icon(statusIcon, size: sizing.iconSize, color: statusColor),
          if (onRemove != null) ...[
            SizedBox(width: spacing.s4),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onRemove,
                child: Semantics(
                  button: true,
                  label: 'Rimuovi ${file.name}',
                  child: Icon(LucideIcons.x,
                      size: sizing.iconSize, color: colors.textTertiary),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
