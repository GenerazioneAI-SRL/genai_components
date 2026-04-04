import 'package:flutter/material.dart';
import '../theme/cl_theme_provider.dart';

/// Displays a prefixed code string, e.g. "# - ABC123".
///
/// If [code] is null a dash is shown in its place.
///
/// ```dart
/// CLCodeText(code: 'FORM-001')
/// CLCodeText(code: 'FORM-001', prefix: 'ID: ')
/// ```
class CLCodeText extends StatelessWidget {
  final String? code;
  final String prefix;

  const CLCodeText({
    super.key,
    required this.code,
    this.prefix = '# - ',
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          prefix,
          style: theme.bodyLabel.copyWith(color: theme.textSecondary),
        ),
        Flexible(
          child: Text(
            code ?? '-',
            style: theme.bodyText,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
