import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import 'pages/actions_page.dart';
import 'pages/dashboard_demo_page.dart';
import 'pages/data_table_demo_page.dart';
import 'pages/display_page.dart';
import 'pages/feedback_page.dart';
import 'pages/form_demo_page.dart';
import 'pages/foundations_page.dart';
import 'pages/home_page.dart';
import 'pages/inputs_page.dart';
import 'pages/layout_page.dart';
import 'pages/navigation_page.dart';
import 'pages/org_chart_page.dart';
import 'pages/overlay_page.dart';
import 'pages/survey_page.dart';
import 'showcase_shell.dart';

class ShowcaseApp extends StatefulWidget {
  const ShowcaseApp({super.key});

  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  ThemeMode _mode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Genai Components — Showcase',
      debugShowCheckedModeBanner: false,
      themeMode: _mode,
      theme: GenaiTheme.light(),
      darkTheme: GenaiTheme.dark(),
      home: ShowcaseShell(
        themeMode: _mode,
        onToggleTheme: () => setState(() => _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light),
        pages: const [
          ShowcasePage(id: 'home', label: 'Home', group: 'Generale', child: HomePage()),
          ShowcasePage(id: 'foundations', label: 'Foundations', group: 'Generale', child: FoundationsPage()),
          ShowcasePage(id: 'actions', label: 'Actions', group: 'Componenti', child: ActionsPage()),
          ShowcasePage(id: 'inputs', label: 'Inputs', group: 'Componenti', child: InputsPage()),
          ShowcasePage(id: 'layout', label: 'Layout', group: 'Componenti', child: LayoutPage()),
          ShowcasePage(id: 'feedback', label: 'Feedback', group: 'Componenti', child: FeedbackPage()),
          ShowcasePage(id: 'overlay', label: 'Overlay', group: 'Componenti', child: OverlayPage()),
          ShowcasePage(id: 'display', label: 'Display', group: 'Componenti', child: DisplayPage()),
          ShowcasePage(id: 'navigation', label: 'Navigation', group: 'Componenti', child: NavigationPage()),
          ShowcasePage(id: 'survey', label: 'Survey', group: 'Componenti', child: SurveyPage()),
          ShowcasePage(id: 'org-chart', label: 'Org Chart', group: 'Componenti', child: OrgChartPage()),
          ShowcasePage(id: 'dashboard', label: 'Dashboard', group: 'Demo', child: DashboardDemoPage()),
          ShowcasePage(id: 'form', label: 'Form + autosave', group: 'Demo', child: FormDemoPage()),
          ShowcasePage(id: 'data-table', label: 'Tabella ordini', group: 'Demo', child: DataTableDemoPage()),
        ],
      ),
    );
  }
}
