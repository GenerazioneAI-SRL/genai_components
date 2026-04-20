import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/icons.dart';
import '../../tokens/sizing.dart';
import 'genai_button.dart';
import 'genai_icon_button.dart';

/// Copies [valueToCopy] to the system clipboard. The icon flips to a check
/// for ~1.5s as feedback (§6.2.7).
class GenaiCopyButton extends StatefulWidget {
  final String valueToCopy;
  final GenaiSize size;
  final String semanticLabel;

  const GenaiCopyButton({
    super.key,
    required this.valueToCopy,
    this.size = GenaiSize.xs,
    this.semanticLabel = 'Copia',
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
    await Future<void>.delayed(const Duration(milliseconds: 1500));
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
      semanticLabel: _copied ? 'Copiato' : widget.semanticLabel,
      tooltip: _copied ? 'Copiato' : widget.semanticLabel,
    );
  }
}
