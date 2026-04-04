import 'package:flutter/material.dart';
import '../theme/cl_theme_provider.dart';

/// A circular avatar that displays initials generated from a name.
///
/// ```dart
/// CLAvatar(name: 'Mario Rossi')
/// CLAvatar(name: 'Anna', size: 56, backgroundColor: Colors.teal)
/// ```
class CLAvatar extends StatelessWidget {
  final String name;
  final double size;
  final Color? backgroundColor;
  final double? fontSize;

  const CLAvatar({
    super.key,
    required this.name,
    this.size = 40,
    this.backgroundColor,
    this.fontSize,
  });

  String _buildInitials(String fullName) {
    const String fallbackInitial = 'N/A';
    final nameParts = fullName.split(' ');
    final initials = nameParts
        .where((part) => part.isNotEmpty)
        .map((part) => part[0])
        .take(2)
        .join();
    return initials.isEmpty ? fallbackInitial : initials.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);
    final initials = _buildInitials(name);
    final bgColor = backgroundColor ?? theme.generateColorFromText(initials);
    final textSize = fontSize ?? (size * 0.35);

    return Container(
      constraints: BoxConstraints.tight(Size.square(size)),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
      ),
      child: Center(
        child: Text(
          initials,
          style: theme.smallText.copyWith(
            color: Colors.white,
            fontSize: textSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
