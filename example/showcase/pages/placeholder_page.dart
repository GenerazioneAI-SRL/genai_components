import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import '../widgets/showcase_section.dart';

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return ShowcaseScaffold(
      title: title,
      children: const [
        SizedBox(height: 80),
        GenaiEmptyState(
          icon: LucideIcons.construction,
          title: 'In arrivo',
          description: 'Questa sezione verrà popolata nelle prossime fasi.',
        ),
      ],
    );
  }
}
