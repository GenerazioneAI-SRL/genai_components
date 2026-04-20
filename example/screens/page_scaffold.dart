import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

class PageScaffold extends StatelessWidget {
  const PageScaffold({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.heading2),
          const SizedBox(height: 4),
          Container(height: 2, width: 48, color: theme.primary),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

