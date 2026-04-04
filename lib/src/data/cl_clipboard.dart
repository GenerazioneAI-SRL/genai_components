import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/cl_theme_provider.dart';

/// Displays a text value with a copy-to-clipboard button.
///
/// Set [showAlert] to true to show a SnackBar confirmation after copying.
///
/// ```dart
/// CLClipboard(text: 'user@example.com')
/// CLClipboard(text: 'TOKEN-XYZ', showAlert: true)
/// ```
class CLClipboard extends StatelessWidget {
  final String text;
  final bool showAlert;

  const CLClipboard({
    super.key,
    required this.text,
    this.showAlert = false,
  });

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    if (showAlert) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Copied: $text')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            text,
            style: theme.bodyText,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          onPressed: () => _copy(context),
          icon: const Icon(Icons.copy),
          iconSize: 18,
          splashRadius: 18,
          padding: EdgeInsets.all(theme.xs),
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}
