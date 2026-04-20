import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';
import 'page_scaffold.dart';

class ButtonsScreen extends StatelessWidget {
  const ButtonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    return PageScaffold(
      title: 'Buttons',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Variants', style: theme.heading5),
          const SizedBox(height: 12),
          Wrap(spacing: 12, runSpacing: 12, children: [
            CLButton(context: context, text: 'Primary', onTap: () {}, iconAlignment: IconAlignment.start),
            CLOutlineButton(context: context, text: 'Outline', onTap: () {}, color: theme.primary, iconAlignment: IconAlignment.start),
            CLSoftButton(context: context, text: 'Soft', onTap: () {}, color: theme.primary, iconAlignment: IconAlignment.start),
            CLGhostButton(context: context, text: 'Ghost', onTap: () {}, color: theme.primary, iconAlignment: IconAlignment.start),
          ]),
          const SizedBox(height: 32),
          Text('Semantic colors', style: theme.heading5),
          const SizedBox(height: 12),
          Wrap(spacing: 12, runSpacing: 12, children: [
            CLButton(context: context, text: 'Success', onTap: () {}, backgroundColor: theme.success, iconAlignment: IconAlignment.start),
            CLButton(context: context, text: 'Warning', onTap: () {}, backgroundColor: theme.warning, iconAlignment: IconAlignment.start),
            CLButton(context: context, text: 'Danger', onTap: () {}, backgroundColor: theme.danger, iconAlignment: IconAlignment.start),
            CLButton(context: context, text: 'Info', onTap: () {}, backgroundColor: theme.info, iconAlignment: IconAlignment.start),
          ]),
        ],
      ),
    );
  }
}

