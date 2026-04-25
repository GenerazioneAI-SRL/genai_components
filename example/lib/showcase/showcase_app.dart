import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart' as v1;
import 'package:genai_components/genai_components_v2.dart' as v2;
import 'package:genai_components/genai_components_v3.dart' as v3;

import 'pages/actions_page.dart';
import 'pages/ai_assistant_page.dart';
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

import '../showcase_v2/pages_v2/actions_v2_page.dart';
import '../showcase_v2/pages_v2/charts_v2_page.dart';
import '../showcase_v2/pages_v2/display_v2_page.dart';
import '../showcase_v2/pages_v2/feedback_v2_page.dart';
import '../showcase_v2/pages_v2/foundations_v2_page.dart';
import '../showcase_v2/pages_v2/home_v2_page.dart';
import '../showcase_v2/pages_v2/indicators_v2_page.dart';
import '../showcase_v2/pages_v2/inputs_v2_page.dart';
import '../showcase_v2/pages_v2/layout_v2_page.dart';
import '../showcase_v2/pages_v2/navigation_v2_page.dart';
import '../showcase_v2/pages_v2/overlay_v2_page.dart';
import '../showcase_v2/pages_v2/typography_v2_page.dart';
import '../showcase_v2/showcase_v2_shell.dart';

import '../showcase_v3/pages_v3/actions_v3_page.dart';
import '../showcase_v3/pages_v3/charts_v3_page.dart';
import '../showcase_v3/pages_v3/display_v3_page.dart';
import '../showcase_v3/pages_v3/feedback_v3_page.dart';
import '../showcase_v3/pages_v3/foundations_v3_page.dart';
import '../showcase_v3/pages_v3/home_v3_page.dart';
import '../showcase_v3/pages_v3/indicators_v3_page.dart';
import '../showcase_v3/pages_v3/inputs_v3_page.dart';
import '../showcase_v3/pages_v3/layout_v3_page.dart';
import '../showcase_v3/pages_v3/navigation_v3_page.dart';
import '../showcase_v3/pages_v3/overlay_v3_page.dart';
import '../showcase_v3/pages_v3/typography_v3_page.dart';
import '../showcase_v3/showcase_v3_shell.dart';

/// Top-level design system version toggle.
enum DesignSystemVersion { v1, v2, v3 }

/// v1 theme preset identifier for the showcase switcher.
enum ShowcasePreset { defaultTheme, aurora, sunset, neoMono, shadcn }

extension ShowcasePresetX on ShowcasePreset {
  String get label => switch (this) {
        ShowcasePreset.defaultTheme => 'Default',
        ShowcasePreset.aurora => 'Aurora',
        ShowcasePreset.sunset => 'Sunset',
        ShowcasePreset.neoMono => 'Neo Mono',
        ShowcasePreset.shadcn => 'shadcn',
      };

  bool get isDarkOnly => this == ShowcasePreset.aurora;

  bool get isLightOnly =>
      this == ShowcasePreset.sunset || this == ShowcasePreset.neoMono;
}

class ShowcaseApp extends StatefulWidget {
  const ShowcaseApp({super.key});

  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  DesignSystemVersion _version = DesignSystemVersion.v1;
  ThemeMode _mode = ThemeMode.light;

  // v1 state
  v1.GenaiDensity _v1Density = v1.GenaiDensity.normal;
  double _v1BaseRadius = 8;
  ShowcasePreset _v1Preset = ShowcasePreset.defaultTheme;

  // v2 state
  v2.GenaiDensity _v2Density = v2.GenaiDensity.normal;
  ShowcaseV2Preset _v2Preset = ShowcaseV2Preset.azure;

  // v3 state
  ShowcaseV3Preset _v3Preset = ShowcaseV3Preset.lms;

  ThemeData _v1ResolveLight() {
    switch (_v1Preset) {
      case ShowcasePreset.defaultTheme:
        return v1.GenaiTheme.light(
            density: _v1Density, baseRadius: _v1BaseRadius);
      case ShowcasePreset.aurora:
        return v1.GenaiThemePresets.aurora(density: _v1Density);
      case ShowcasePreset.sunset:
        return v1.GenaiThemePresets.sunset(density: _v1Density);
      case ShowcasePreset.neoMono:
        return v1.GenaiThemePresets.neoMono(density: _v1Density);
      case ShowcasePreset.shadcn:
        return v1.GenaiThemePresets.shadcn(density: _v1Density);
    }
  }

  ThemeData _v1ResolveDark() {
    switch (_v1Preset) {
      case ShowcasePreset.defaultTheme:
        return v1.GenaiTheme.dark(
            density: _v1Density, baseRadius: _v1BaseRadius);
      case ShowcasePreset.aurora:
        return v1.GenaiThemePresets.aurora(density: _v1Density);
      case ShowcasePreset.sunset:
        return v1.GenaiThemePresets.sunset(density: _v1Density);
      case ShowcasePreset.neoMono:
        return v1.GenaiThemePresets.neoMono(density: _v1Density);
      case ShowcasePreset.shadcn:
        return v1.GenaiThemePresets.shadcnDark(density: _v1Density);
    }
  }

  ThemeMode _v1ResolveMode() {
    if (_v1Preset.isDarkOnly) return ThemeMode.dark;
    if (_v1Preset.isLightOnly) return ThemeMode.light;
    return _mode;
  }

  ThemeData _v2ResolveLight() {
    switch (_v2Preset) {
      case ShowcaseV2Preset.azure:
        return v2.GenaiThemePresets.vantaAzureLight(density: _v2Density);
      case ShowcaseV2Preset.violet:
        return v2.GenaiThemePresets.vantaVioletLight(density: _v2Density);
      case ShowcaseV2Preset.ember:
        return v2.GenaiThemePresets.vantaEmberLight(density: _v2Density);
      case ShowcaseV2Preset.aurora:
        return v2.GenaiThemePresets.vantaAurora(density: _v2Density);
      case ShowcaseV2Preset.sunset:
        return v2.GenaiThemePresets.vantaSunset(density: _v2Density);
      case ShowcaseV2Preset.neoMono:
        return v2.GenaiThemePresets.vantaNeoMono(density: _v2Density);
      case ShowcaseV2Preset.shadcn:
        return v2.GenaiThemePresets.vantaShadcn(density: _v2Density);
    }
  }

  ThemeData _v2ResolveDark() {
    switch (_v2Preset) {
      case ShowcaseV2Preset.azure:
        return v2.GenaiThemePresets.vantaAzureDark(density: _v2Density);
      case ShowcaseV2Preset.violet:
        return v2.GenaiThemePresets.vantaVioletDark(density: _v2Density);
      case ShowcaseV2Preset.ember:
        return v2.GenaiThemePresets.vantaEmberDark(density: _v2Density);
      case ShowcaseV2Preset.aurora:
        return v2.GenaiThemePresets.vantaAurora(density: _v2Density);
      case ShowcaseV2Preset.sunset:
        return v2.GenaiThemePresets.vantaSunset(density: _v2Density);
      case ShowcaseV2Preset.neoMono:
        return v2.GenaiThemePresets.vantaNeoMono(density: _v2Density);
      case ShowcaseV2Preset.shadcn:
        return v2.GenaiThemePresets.vantaShadcnDark(density: _v2Density);
    }
  }

  ThemeMode _v2ResolveMode() {
    if (_v2Preset.isDarkOnly) return ThemeMode.dark;
    if (_v2Preset.isLightOnly) return ThemeMode.light;
    return _mode;
  }

  ThemeData _v3ResolveLight() {
    switch (_v3Preset) {
      case ShowcaseV3Preset.lms:
        return v3.GenaiThemePresets.formaLms();
      case ShowcaseV3Preset.aurora:
        return v3.GenaiThemePresets.formaAurora();
      case ShowcaseV3Preset.sunset:
        return v3.GenaiThemePresets.formaSunset();
      case ShowcaseV3Preset.neoMono:
        return v3.GenaiThemePresets.formaNeoMono();
      case ShowcaseV3Preset.shadcn:
        return v3.GenaiThemePresets.formaShadcn();
    }
  }

  ThemeData _v3ResolveDark() {
    switch (_v3Preset) {
      case ShowcaseV3Preset.lms:
        return v3.GenaiThemePresets.formaLms();
      case ShowcaseV3Preset.aurora:
        return v3.GenaiThemePresets.formaAurora();
      case ShowcaseV3Preset.sunset:
        return v3.GenaiThemePresets.formaSunset();
      case ShowcaseV3Preset.neoMono:
        return v3.GenaiThemePresets.formaNeoMono();
      case ShowcaseV3Preset.shadcn:
        return v3.GenaiThemePresets.formaShadcnDark();
    }
  }

  ThemeMode _v3ResolveMode() {
    if (_v3Preset.isDarkOnly) return ThemeMode.dark;
    if (_v3Preset.isLightOnly) return ThemeMode.light;
    return _mode;
  }

  void _toggleTheme() => setState(() {
        _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      });

  Widget _buildVersionSwitch(BuildContext context) {
    return _VersionSwitch(
      value: _version,
      onChanged: (v) => setState(() => _version = v),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_version == DesignSystemVersion.v1) {
      return MaterialApp(
        key: const ValueKey('app-v1'),
        title: 'Genai Components — Showcase v1',
        debugShowCheckedModeBanner: false,
        themeMode: _v1ResolveMode(),
        theme: _v1ResolveLight(),
        darkTheme: _v1ResolveDark(),
        home: ShowcaseShell(
          themeMode: _mode,
          density: _v1Density,
          baseRadius: _v1BaseRadius,
          preset: _v1Preset,
          versionSwitchBuilder: _buildVersionSwitch,
          onToggleTheme: _toggleTheme,
          onDensityChanged: (d) => setState(() => _v1Density = d),
          onRadiusChanged: (r) => setState(() => _v1BaseRadius = r),
          onPresetChanged: (p) => setState(() => _v1Preset = p),
          pages: const [
            ShowcasePage(
                id: 'home',
                label: 'Home',
                group: 'Generale',
                child: HomePage()),
            ShowcasePage(
                id: 'foundations',
                label: 'Foundations',
                group: 'Generale',
                child: FoundationsPage()),
            ShowcasePage(
                id: 'typography',
                label: 'Typography',
                group: 'Generale',
                icon: v1.LucideIcons.type,
                child: TypographyPage()),
            ShowcasePage(
                id: 'utils',
                label: 'Utils & Formatters',
                group: 'Generale',
                child: UtilsPage()),
            ShowcasePage(
                id: 'actions',
                label: 'Actions',
                group: 'Componenti',
                child: ActionsPage()),
            ShowcasePage(
                id: 'inputs',
                label: 'Inputs',
                group: 'Componenti',
                child: InputsPage()),
            ShowcasePage(
                id: 'indicators',
                label: 'Indicators',
                group: 'Componenti',
                child: IndicatorsPage()),
            ShowcasePage(
                id: 'layout',
                label: 'Layout',
                group: 'Componenti',
                child: LayoutPage()),
            ShowcasePage(
                id: 'feedback',
                label: 'Feedback',
                group: 'Componenti',
                child: FeedbackPage()),
            ShowcasePage(
                id: 'overlay',
                label: 'Overlay',
                group: 'Componenti',
                child: OverlayPage()),
            ShowcasePage(
                id: 'display',
                label: 'Display',
                group: 'Componenti',
                child: DisplayPage()),
            ShowcasePage(
                id: 'navigation',
                label: 'Navigation',
                group: 'Componenti',
                child: NavigationPage()),
            ShowcasePage(
                id: 'survey',
                label: 'Survey',
                group: 'Componenti',
                child: SurveyPage()),
            ShowcasePage(
                id: 'org-chart',
                label: 'Org Chart',
                group: 'Componenti',
                child: OrgChartPage()),
            ShowcasePage(
                id: 'ai-assistant',
                label: 'AI Assistant',
                group: 'Componenti',
                child: AiAssistantPage()),
          ],
        ),
      );
    }

    if (_version == DesignSystemVersion.v3) {
      return MaterialApp(
        key: const ValueKey('app-v3'),
        title: 'Genai Components — Showcase v3',
        debugShowCheckedModeBanner: false,
        themeMode: _v3ResolveMode(),
        theme: _v3ResolveLight(),
        darkTheme: _v3ResolveDark(),
        home: ShowcaseV3Shell(
          versionSwitchBuilder: _buildVersionSwitch,
          themeMode: _mode,
          preset: _v3Preset,
          onToggleTheme: _toggleTheme,
          onPresetChanged: (p) => setState(() => _v3Preset = p),
          pages: const [
            ShowcaseV3Page(
                id: 'home',
                label: 'Home',
                group: 'Generale',
                child: HomeV3Page()),
            ShowcaseV3Page(
                id: 'foundations',
                label: 'Foundations',
                group: 'Generale',
                child: FoundationsV3Page()),
            ShowcaseV3Page(
                id: 'typography',
                label: 'Typography',
                group: 'Generale',
                child: TypographyV3Page()),
            ShowcaseV3Page(
                id: 'actions',
                label: 'Actions',
                group: 'Componenti',
                child: ActionsV3Page()),
            ShowcaseV3Page(
                id: 'inputs',
                label: 'Inputs',
                group: 'Componenti',
                child: InputsV3Page()),
            ShowcaseV3Page(
                id: 'indicators',
                label: 'Indicators',
                group: 'Componenti',
                child: IndicatorsV3Page()),
            ShowcaseV3Page(
                id: 'layout',
                label: 'Layout',
                group: 'Componenti',
                child: LayoutV3Page()),
            ShowcaseV3Page(
                id: 'feedback',
                label: 'Feedback',
                group: 'Componenti',
                child: FeedbackV3Page()),
            ShowcaseV3Page(
                id: 'overlay',
                label: 'Overlay',
                group: 'Componenti',
                child: OverlayV3Page()),
            ShowcaseV3Page(
                id: 'display',
                label: 'Display',
                group: 'Componenti',
                child: DisplayV3Page()),
            ShowcaseV3Page(
                id: 'navigation',
                label: 'Navigation',
                group: 'Componenti',
                child: NavigationV3Page()),
            ShowcaseV3Page(
                id: 'charts',
                label: 'Charts',
                group: 'Componenti',
                child: ChartsV3Page()),
          ],
        ),
      );
    }

    // v2 branch
    return MaterialApp(
      key: const ValueKey('app-v2'),
      title: 'Genai Components — Showcase v2',
      debugShowCheckedModeBanner: false,
      themeMode: _v2ResolveMode(),
      theme: _v2ResolveLight(),
      darkTheme: _v2ResolveDark(),
      home: ShowcaseV2Shell(
        themeMode: _mode,
        density: _v2Density,
        preset: _v2Preset,
        versionSwitchBuilder: _buildVersionSwitch,
        onToggleTheme: _toggleTheme,
        onDensityChanged: (d) => setState(() => _v2Density = d),
        onPresetChanged: (p) => setState(() => _v2Preset = p),
        pages: const [
          ShowcaseV2Page(
              id: 'home',
              label: 'Home',
              group: 'Generale',
              child: HomeV2Page()),
          ShowcaseV2Page(
              id: 'foundations',
              label: 'Foundations',
              group: 'Generale',
              child: FoundationsV2Page()),
          ShowcaseV2Page(
              id: 'typography',
              label: 'Typography',
              group: 'Generale',
              child: TypographyV2Page()),
          ShowcaseV2Page(
              id: 'actions',
              label: 'Actions',
              group: 'Componenti',
              child: ActionsV2Page()),
          ShowcaseV2Page(
              id: 'inputs',
              label: 'Inputs',
              group: 'Componenti',
              child: InputsV2Page()),
          ShowcaseV2Page(
              id: 'indicators',
              label: 'Indicators',
              group: 'Componenti',
              child: IndicatorsV2Page()),
          ShowcaseV2Page(
              id: 'layout',
              label: 'Layout',
              group: 'Componenti',
              child: LayoutV2Page()),
          ShowcaseV2Page(
              id: 'feedback',
              label: 'Feedback',
              group: 'Componenti',
              child: FeedbackV2Page()),
          ShowcaseV2Page(
              id: 'overlay',
              label: 'Overlay',
              group: 'Componenti',
              child: OverlayV2Page()),
          ShowcaseV2Page(
              id: 'display',
              label: 'Display',
              group: 'Componenti',
              child: DisplayV2Page()),
          ShowcaseV2Page(
              id: 'navigation',
              label: 'Navigation',
              group: 'Componenti',
              child: NavigationV2Page()),
          ShowcaseV2Page(
              id: 'charts',
              label: 'Charts',
              group: 'Componenti',
              child: ChartsV2Page()),
        ],
      ),
    );
  }
}

/// Pill-shaped v1 / v2 / v3 selector rendered in all shells' app bars.
class _VersionSwitch extends StatelessWidget {
  final DesignSystemVersion value;
  final ValueChanged<DesignSystemVersion> onChanged;

  const _VersionSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final borderColor = theme.dividerColor;
    return Container(
      height: 36,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _pill(
            label: 'v1',
            selected: value == DesignSystemVersion.v1,
            cs: cs,
            onTap: () => onChanged(DesignSystemVersion.v1),
          ),
          _pill(
            label: 'v2',
            selected: value == DesignSystemVersion.v2,
            cs: cs,
            onTap: () => onChanged(DesignSystemVersion.v2),
          ),
          _pill(
            label: 'v3',
            selected: value == DesignSystemVersion.v3,
            cs: cs,
            onTap: () => onChanged(DesignSystemVersion.v3),
          ),
        ],
      ),
    );
  }

  Widget _pill({
    required String label,
    required bool selected,
    required ColorScheme cs,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: selected ? cs.onPrimary : cs.onSurface,
          ),
        ),
      ),
    );
  }
}
