# genai_components

[![pub.dev](https://img.shields.io/pub/v/genai_components.svg)](https://pub.dev/packages/genai_components)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.10-blue)](https://flutter.dev)

Flutter component library — design system, routing, auth scaffold, AI assistant, and 50+ UI components. Built for enterprise Flutter web apps.

---

## Installation

```yaml
dependencies:
  genai_components: ^5.0.0
```

```bash
flutter pub get
```

---

## Quick Start — App Bootstrap

```dart
import 'package:genai_components/genai_components.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GenaiAppState()),
        ChangeNotifierProvider(create: (_) => GenaiPageErrorState()),
      ],
      child: MaterialApp.router(
        theme: GenaiTheme.light(),
        darkTheme: GenaiTheme.dark(),
        routerConfig: GoRouterModular.configure(
          modules: [
            ModuleRoute(module: HomeModule()),
          ],
          shellBuilder: (context, state, child) => GenaiShell(
            routes: AppRoutes.shellRoutes,
            child: child,
          ),
        ),
      ),
    ),
  );
}
```

---

## Theme

Access tokens anywhere via `BuildContext` extensions:

```dart
// Colors
context.colors.colorPrimary
context.colors.surfaceCard
context.colors.textSecondary

// Typography
context.typography.headingLg
context.typography.bodySm

// Spacing
context.spacing.s4   // 16px
context.spacing.s8   // 32px

// Custom theme
GenaiTheme.light(
  colorsOverride: GenaiColorTokens.defaultLight().copyWith(
    colorPrimary: const Color(0xFF6366F1),
  ),
  fontFamily: 'Poppins',
)
```

---

## Routing — GoRouterModular

Module-based routing wrapping GoRouter:

```dart
class HomeModule extends Module {
  @override
  GenaiRoute get moduleRoute => HomeRoutes.root;

  @override
  List<ModularRoute> configureRoutes() => [
    ChildRoute(
      route: HomeRoutes.root,
      builder: (context, state) => const HomePage(),
    ),
  ];
}
```

---

## AI Assistant

LLM-powered assistant with tool calling, voice input, and navigation awareness:

```dart
GenaiShell(
  routes: shellRoutes,
  aiAssistantConfig: GenaiAiAssistantConfig(
    provider: OpenAiProvider(apiKey: 'YOUR_KEY', model: 'gpt-4o'),
    assistantName: 'Assistant',
    voiceEnabled: true,
    navigateToRoute: (route) async => context.go('/$route'),
  ),
  child: child,
)
```

---

## UI Components

| Category | Components |
|---|---|
| **Actions** | `GenaiButton`, `GenaiIconButton`, `GenaiLinkButton`, `GenaiFab`, `GenaiSplitButton`, `GenaiToggleButtonGroup`, `GenaicopyButton` |
| **Inputs** | `GenaiTextField`, `GenaiSelect`, `GenaiCheckbox`, `GenaiRadio`, `GenaiToggle`, `GenaiSlider`, `GenaiDatePicker`, `GenaiFileUpload`, `GenaiTagInput`, `GenaiOtpInput`, `GenaiColorPicker` |
| **Indicators** | `GenaiBadge`, `GenaiChip`, `GenaiAvatar`, `GenaiAvatarGroup`, `GenaiStatusBadge`, `GenaiTrendIndicator`, `GenaiProgressRing` |
| **Feedback** | `GenaiAlert`, `GenaiToast`, `GenaiSpinner`, `GenaiProgressBar`, `GenaiSkeleton`, `GenaiEmptyState`, `GenaiErrorState` |
| **Layout** | `GenaiCard`, `GenaiDivider`, `GenaiAccordion`, `GenaiSection` |
| **Overlay** | `GenaiModal`, `GenaiDrawer`, `GenaiTooltip`, `GenaiPopover`, `GenaiContextMenu` |
| **Display** | `GenaiTable`, `GenaiList`, `GenaiKpiCard`, `GenaiTimeline`, `GenaiCalendar`, `GenaiKanban`, `GenaiTreeView` |
| **Charts** | `GenaiBarChart`, `GenaiOrgChart`, `GenaiGenogram` |
| **Navigation** | `GenaiShell`, `GenaiSidebar`, `GenaiAppBar`, `GenaiTabs`, `GenaiBreadcrumb`, `GenaiStepper`, `GenaiPagination`, `GenaiBottomNav`, `GenaiNavigationRail`, `GenaiCommandPalette`, `GenaiNotificationCenter` |
| **Survey** | `GenaiSurvey`, `GenaiSurveyViewer`, `GenaiSurveyBuilder`, `GenaiSurveyResultViewer` |

---

## Scaffold Utilities

```dart
// Validators
GenaiValidators.combine([
  GenaiValidators.required(),
  GenaiValidators.email(),
])(value);

// Formatters
GenaiFormatters.currency(1234.56);        // '1.234,56 €'
GenaiFormatters.dateLong(DateTime.now()); // '20 aprile 2026'
GenaiFormatters.initials('Mario Rossi');  // 'MR'
```

---

## License

MIT — see [LICENSE](LICENSE)
