import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import 'pages/actions_page.dart';
import 'pages/ai_assistant_page.dart';
import 'pages/charts_page.dart';
import 'pages/display_page.dart';
import 'pages/feedback_page.dart';
import 'pages/foundations_page.dart';
import 'pages/home_page.dart';
import 'pages/indicators_page.dart';
import 'pages/inputs_page.dart';
import 'pages/layout_page.dart';
import 'pages/navigation_page.dart';
import 'pages/org_chart_page.dart';
import 'pages/overlay_page.dart';
import 'pages/survey_page.dart';
import 'pages/typography_page.dart';
import 'pages/utils_page.dart';
import 'showcase_shell.dart';

/// Top-level showcase app — wires the canonical Forma LMS theme presets to
/// the shell and exposes the full page set (v3 component pages plus the
/// kept-from-v1 domain pages: Survey, Org Chart, AI Assistant, Utils).
class ShowcaseApp extends StatefulWidget {
  const ShowcaseApp({super.key});

  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  ThemeMode _mode = ThemeMode.light;
  ShowcasePreset _preset = ShowcasePreset.lms;

  ThemeData _resolveLight() => switch (_preset) {
    ShowcasePreset.lms => GenaiThemePresets.formaLms(),
    ShowcasePreset.aurora => GenaiThemePresets.formaAurora(),
    ShowcasePreset.sunset => GenaiThemePresets.formaSunset(),
    ShowcasePreset.neoMono => GenaiThemePresets.formaNeoMono(),
    ShowcasePreset.shadcn => GenaiThemePresets.formaShadcn(),
  };

  ThemeData _resolveDark() => switch (_preset) {
    ShowcasePreset.lms => GenaiThemePresets.formaLms(),
    ShowcasePreset.aurora => GenaiThemePresets.formaAurora(),
    ShowcasePreset.sunset => GenaiThemePresets.formaSunset(),
    ShowcasePreset.neoMono => GenaiThemePresets.formaNeoMono(),
    ShowcasePreset.shadcn => GenaiThemePresets.formaShadcnDark(),
  };

  ThemeMode _resolveMode() {
    if (_preset.isDarkOnly) return ThemeMode.dark;
    if (_preset.isLightOnly) return ThemeMode.light;
    return _mode;
  }

  void _toggleTheme() => setState(() {
    _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Genai Components — Showcase',
      debugShowCheckedModeBanner: false,
      themeMode: _resolveMode(),
      theme: _resolveLight(),
      darkTheme: _resolveDark(),
      home: ShowcaseShell(
        themeMode: _mode,
        preset: _preset,
        onToggleTheme: _toggleTheme,
        onPresetChanged: (p) => setState(() => _preset = p),
        pages: const [
          ShowcasePage(
            id: 'home',
            label: 'Home',
            group: 'Generale',
            child: HomePage(),
          ),
          ShowcasePage(
            id: 'foundations',
            label: 'Foundations',
            group: 'Generale',
            child: FoundationsPage(),
          ),
          ShowcasePage(
            id: 'typography',
            label: 'Typography',
            group: 'Generale',
            child: TypographyPage(),
          ),
          ShowcasePage(
            id: 'utils',
            label: 'Utils',
            group: 'Generale',
            child: UtilsPage(),
          ),
          ShowcasePage(
            id: 'actions',
            label: 'Actions',
            group: 'Componenti',
            child: ActionsPage(),
          ),
          ShowcasePage(
            id: 'inputs',
            label: 'Inputs',
            group: 'Componenti',
            child: InputsPage(),
          ),
          ShowcasePage(
            id: 'indicators',
            label: 'Indicators',
            group: 'Componenti',
            child: IndicatorsPage(),
          ),
          ShowcasePage(
            id: 'layout',
            label: 'Layout',
            group: 'Componenti',
            child: LayoutPage(),
          ),
          ShowcasePage(
            id: 'feedback',
            label: 'Feedback',
            group: 'Componenti',
            child: FeedbackPage(),
          ),
          ShowcasePage(
            id: 'overlay',
            label: 'Overlay',
            group: 'Componenti',
            child: OverlayPage(),
          ),
          ShowcasePage(
            id: 'display',
            label: 'Display',
            group: 'Componenti',
            child: DisplayPage(),
          ),
          ShowcasePage(
            id: 'navigation',
            label: 'Navigation',
            group: 'Componenti',
            child: NavigationPage(),
          ),
          ShowcasePage(
            id: 'charts',
            label: 'Charts',
            group: 'Componenti',
            child: ChartsPage(),
          ),
          ShowcasePage(
            id: 'survey',
            label: 'Survey',
            group: 'Domain',
            child: SurveyPage(),
          ),
          ShowcasePage(
            id: 'org-chart',
            label: 'Org Chart',
            group: 'Domain',
            child: OrgChartPage(),
          ),
          ShowcasePage(
            id: 'ai-assistant',
            label: 'AI Assistant',
            group: 'Domain',
            child: AiAssistantPage(),
          ),
        ],
      ),
    );
  }
}
