import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
          // ── CLButton (filled) ──
          Text('CLButton — Filled', style: theme.heading5),
          const SizedBox(height: 12),
          Wrap(spacing: 12, runSpacing: 12, children: [
            CLButton.primary(text: 'Primary', onTap: () {}, context: context, iconAlignment: IconAlignment.start),
            CLButton.secondary(text: 'Secondary', onTap: () {}, context: context, iconAlignment: IconAlignment.start),
            CLButton(context: context, text: 'Success', onTap: () {}, backgroundColor: theme.success, iconAlignment: IconAlignment.start),
            CLButton(context: context, text: 'Warning', onTap: () {}, backgroundColor: theme.warning, iconAlignment: IconAlignment.start),
            CLButton(context: context, text: 'Danger', onTap: () {}, backgroundColor: theme.danger, iconAlignment: IconAlignment.start),
            CLButton(context: context, text: 'Info', onTap: () {}, backgroundColor: theme.info, iconAlignment: IconAlignment.start),
          ]),
          const SizedBox(height: 32),

          // ── CLOutlineButton ──
          Text('CLOutlineButton — Border', style: theme.heading5),
          const SizedBox(height: 12),
          Wrap(spacing: 12, runSpacing: 12, children: [
            CLOutlineButton.primary(text: 'Primary', onTap: () {}, context: context, iconAlignment: IconAlignment.start),
            CLOutlineButton.secondary(text: 'Secondary', onTap: () {}, context: context, iconAlignment: IconAlignment.start),
            CLOutlineButton.success(text: 'Success', onTap: () {}, context: context, iconAlignment: IconAlignment.start),
            CLOutlineButton.warning(text: 'Warning', onTap: () {}, context: context, iconAlignment: IconAlignment.start),
            CLOutlineButton.danger(text: 'Danger', onTap: () {}, context: context, iconAlignment: IconAlignment.start),
            CLOutlineButton.info(text: 'Info', onTap: () {}, context: context, iconAlignment: IconAlignment.start),
          ]),
          const SizedBox(height: 32),

          // ── CLSoftButton ──
          Text('CLSoftButton — Soft fill', style: theme.heading5),
          const SizedBox(height: 12),
          Wrap(spacing: 12, runSpacing: 12, children: [
            CLSoftButton.primary(text: 'Primary', onTap: () {}, context: context, iconAlignment: IconAlignment.start),
            CLSoftButton.secondary(text: 'Secondary', onTap: () {}, context: context, iconAlignment: IconAlignment.start),
            CLSoftButton.success(text: 'Success', onTap: () {}, context: context, iconAlignment: IconAlignment.start),
            CLSoftButton.warning(text: 'Warning', onTap: () {}, context: context, iconAlignment: IconAlignment.start),
            CLSoftButton.danger(text: 'Danger', onTap: () {}, context: context, iconAlignment: IconAlignment.start),
            CLSoftButton.info(text: 'Info', onTap: () {}, context: context, iconAlignment: IconAlignment.start),
          ]),
          const SizedBox(height: 32),

          // ── CLGhostButton ──
          Text('CLGhostButton — No fill', style: theme.heading5),
          const SizedBox(height: 12),
          Wrap(spacing: 12, runSpacing: 12, children: [
            CLGhostButton.primary(text: 'Primary', onTap: () {}, context: context, iconAlignment: IconAlignment.start),
            CLGhostButton.secondary(text: 'Secondary', onTap: () {}, context: context, iconAlignment: IconAlignment.start),
            CLGhostButton.success(text: 'Success', onTap: () {}, context: context, iconAlignment: IconAlignment.start),
            CLGhostButton.warning(text: 'Warning', onTap: () {}, context: context, iconAlignment: IconAlignment.start),
            CLGhostButton.danger(text: 'Danger', onTap: () {}, context: context, iconAlignment: IconAlignment.start),
            CLGhostButton.info(text: 'Info', onTap: () {}, context: context, iconAlignment: IconAlignment.start),
          ]),
          const SizedBox(height: 32),

          // ── With Icons ──
          Text('With Icons — Lucide Icons', style: theme.heading5),
          const SizedBox(height: 12),
          Wrap(spacing: 12, runSpacing: 12, children: [
            CLButton.primary(text: 'Save', onTap: () {}, context: context, iconAlignment: IconAlignment.start, icon: LucideIcons.save),
            CLOutlineButton.primary(text: 'Delete', onTap: () {}, context: context, iconAlignment: IconAlignment.start, icon: LucideIcons.trash2),
            CLSoftButton.primary(text: 'Download', onTap: () {}, context: context, iconAlignment: IconAlignment.start, icon: LucideIcons.download),
            CLGhostButton.primary(text: 'Settings', onTap: () {}, context: context, iconAlignment: IconAlignment.start, icon: LucideIcons.settings),
            CLButton.success(text: 'Check', onTap: () {}, context: context, iconAlignment: IconAlignment.start, icon: LucideIcons.check),
            CLButton.danger(text: 'Alert', onTap: () {}, context: context, iconAlignment: IconAlignment.start, icon: LucideIcons.x),
          ]),
          const SizedBox(height: 32),

          // ── Async / Loading State ──
          Text('Async Loading — Click to trigger', style: theme.heading5),
          const SizedBox(height: 12),
          const _AsyncButtonsSection(),
        ],
      ),
    );
  }
}

class _AsyncButtonsSection extends StatelessWidget {
  const _AsyncButtonsSection();

  Future<void> _simulateDelay(Duration duration) async {
    await Future.delayed(duration);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 12, runSpacing: 12, children: [
      CLButton.primary(
        text: 'Fetch (1s)',
        onTap: () => _simulateDelay(const Duration(seconds: 1)),
        context: context,
        iconAlignment: IconAlignment.start,
        icon: LucideIcons.download,
      ),
      CLOutlineButton.primary(
        text: 'Save (2s)',
        onTap: () => _simulateDelay(const Duration(seconds: 2)),
        context: context,
        iconAlignment: IconAlignment.start,
        icon: LucideIcons.save,
      ),
      CLSoftButton.success(
        text: 'Process (3s)',
        onTap: () => _simulateDelay(const Duration(seconds: 3)),
        context: context,
        iconAlignment: IconAlignment.start,
        icon: LucideIcons.check,
      ),
      CLGhostButton.primary(
        text: 'Sync (1.5s)',
        onTap: () => _simulateDelay(const Duration(milliseconds: 1500)),
        context: context,
        iconAlignment: IconAlignment.start,
        icon: LucideIcons.loader,
      ),
    ]);
  }
}

