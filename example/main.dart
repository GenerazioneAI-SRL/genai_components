// ignore_for_file: unused_local_variable
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:genai_components/genai_components.dart';

/// Example app showcasing CL Components usage.
///
/// Run with: `flutter run -d chrome`
void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Provide a custom theme (all colors are optional, defaults are sensible)
      create: (_) => CLThemeProvider(
        lightTheme: const LightModeTheme(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF4F46E5),
        ),
        darkTheme: const DarkModeTheme(
          primary: Color(0xFF818CF8),
          secondary: Color(0xFF6366F1),
        ),
      ),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            title: 'CL Components Example',
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light(useMaterial3: true),
            darkTheme: ThemeData.dark(useMaterial3: true),
            home: const ExampleHome(),
          );
        },
      ),
    );
  }
}

class ExampleHome extends StatefulWidget {
  const ExampleHome({super.key});

  @override
  State<ExampleHome> createState() => _ExampleHomeState();
}

class _ExampleHomeState extends State<ExampleHome> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────
                Text('CL Components', style: theme.heading1),
                const SizedBox(height: 4),
                Text('A comprehensive Flutter UI library', style: theme.subTitle),
                const SizedBox(height: 32),

                // ── Buttons ─────────────────────────────
                _SectionTitle('Buttons'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    CLButton(
                      context: context,
                      text: 'Primary',
                      onTap: () {},
                      iconAlignment: IconAlignment.start,
                    ),
                    CLOutlineButton(
                      context: context,
                      text: 'Outline',
                      onTap: () {},
                      color: theme.primary,
                      iconAlignment: IconAlignment.start,
                    ),
                    CLSoftButton(
                      context: context,
                      text: 'Soft',
                      onTap: () {},
                      color: theme.primary,
                      iconAlignment: IconAlignment.start,
                    ),
                    CLGhostButton(
                      context: context,
                      text: 'Ghost',
                      onTap: () {},
                      color: theme.primary,
                      iconAlignment: IconAlignment.start,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // ── Text Field ──────────────────────────
                _SectionTitle('Form'),
                const SizedBox(height: 12),
                CLTextField(
                  controller: _emailController,
                  labelText: 'Email',
                ),
                const SizedBox(height: 12),
                CLTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  isObscured: true,
                ),

                const SizedBox(height: 32),

                // ── Status Badges ───────────────────────
                _SectionTitle('Badges & Pills'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    CLStatusBadge(label: 'Active', color: theme.success),
                    CLStatusBadge(label: 'Pending', color: theme.warning),
                    CLStatusBadge(label: 'Error', color: theme.danger),
                    CLPill(pillText: 'Flutter', pillColor: theme.primary),
                    CLPill(pillText: 'Dart', pillColor: theme.info),
                  ],
                ),

                const SizedBox(height: 32),

                // ── Alerts ──────────────────────────────
                _SectionTitle('Alerts'),
                const SizedBox(height: 12),
                CLAlert.border(
                  'Success',
                  'Operation completed successfully.',
                  backgroundColor: theme.success,
                ),
                const SizedBox(height: 8),
                CLAlert.border(
                  'Warning',
                  'Please review before proceeding.',
                  backgroundColor: theme.warning,
                ),
                const SizedBox(height: 8),
                CLAlert.border(
                  'Error',
                  'Something went wrong.',
                  backgroundColor: theme.danger,
                ),

                const SizedBox(height: 32),

                // ── Bar Chart ───────────────────────────
                _SectionTitle('Charts'),
                const SizedBox(height: 12),
                SizedBox(
                  height: 250,
                  child: CLBarChart<Map<String, dynamic>>(
                    data: const [
                      {'month': 'Jan', 'value': 30.0},
                      {'month': 'Feb', 'value': 45.0},
                      {'month': 'Mar', 'value': 28.0},
                      {'month': 'Apr', 'value': 60.0},
                      {'month': 'May', 'value': 52.0},
                      {'month': 'Jun', 'value': 40.0},
                    ],
                    xValueMapper: (item, _) => item['month'] as String,
                    yValueMapper: (item, _) => item['value'] as double,
                    showGrid: true,
                  ),
                ),

                const SizedBox(height: 32),

                // ── Theme Colors ────────────────────────
                _SectionTitle('Theme Colors'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ColorChip('Primary', theme.primary),
                    _ColorChip('Secondary', theme.secondary),
                    _ColorChip('Success', theme.success),
                    _ColorChip('Warning', theme.warning),
                    _ColorChip('Danger', theme.danger),
                    _ColorChip('Info', theme.info),
                  ],
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helper widgets ──────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: theme.heading5),
        const SizedBox(height: 4),
        Container(height: 2, width: 40, color: theme.primary),
      ],
    );
  }
}

class _ColorChip extends StatelessWidget {
  const _ColorChip(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
