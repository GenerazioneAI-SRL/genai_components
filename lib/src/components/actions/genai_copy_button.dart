import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/icons.dart';
import 'genai_button.dart';
import 'genai_icon_button.dart';

/// Copy-to-clipboard icon button with a checkmark flash confirmation —
/// v3 design system (Forma LMS).
///
/// The icon flips from `copy` to `check` on tap for a brief window, then
/// restores. Tooltip and semantic label track the same state.
class GenaiCopyButton extends StatefulWidget {
  /// The string written to the system clipboard on tap.
  final String valueToCopy;

  /// Visual size scale.
  final GenaiButtonSize size;

  /// Default semantic label / tooltip ("Copy" state).
  final String semanticLabel;

  /// Label used while the "copied" flash is active.
  final String copiedLabel;

  /// How long the "copied" confirmation remains. Defaults to 1500 ms to feel
  /// brisk without blocking a subsequent copy attempt.
  final Duration? feedbackDuration;

  const GenaiCopyButton({
    super.key,
    required this.valueToCopy,
    this.size = GenaiButtonSize.sm,
    this.semanticLabel = 'Copy',
    this.copiedLabel = 'Copied',
    this.feedbackDuration,
  });

  @override
  State<GenaiCopyButton> createState() => _GenaiCopyButtonState();
}

class _GenaiCopyButtonState extends State<GenaiCopyButton> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.valueToCopy));
    if (!mounted) return;
    setState(() => _copied = true);
    final delay = widget.feedbackDuration ?? const Duration(milliseconds: 1500);
    await Future<void>.delayed(delay);
    if (!mounted) return;
    setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return GenaiIconButton(
      icon: _copied ? LucideIcons.check : LucideIcons.copy,
      onPressed: _copy,
      size: widget.size,
      variant: GenaiButtonVariant.ghost,
      semanticLabel: _copied ? widget.copiedLabel : widget.semanticLabel,
      tooltip: _copied ? widget.copiedLabel : widget.semanticLabel,
    );
  }
}
