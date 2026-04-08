# genai_components

[![pub.dev](https://img.shields.io/pub/v/genai_components.svg)](https://pub.dev/packages/genai_components)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.7-blue)](https://flutter.dev)

Flutter component library with built-in routing, auth, AI assistant, theme system, and 40+ UI widgets. Used as the foundation for enterprise Flutter web apps.

---

## Installation

```yaml
dependencies:
  genai_components: ^4.0.0
```

```bash
flutter pub get
```

---

## Quick Start — Full App Bootstrap

The recommended way is to extend `CLAppConfig` and let `CLApp` handle initialization, routing, auth, providers and theming:

```dart
import 'package:genai_components/genai_components.dart';

void main() {
  runApp(CLApp(config: MyAppConfig()));
}

class MyAppConfig extends CLAppConfig {
  @override
  String get appName => 'My App';

  @override
  String get baseUrl => 'https://api.myapp.com/api/';

  @override
  String get oidcEndpoint => 'https://auth.myapp.com/oidc';

  @override
  CLAuthState get authState => MyAuthState();

  @override
  String get initialRoute => '/home';

  @override
  String get authRoute => '/auth';

  @override
  List<ModularRoute> get preAuthRoutes => [
    ModuleRoute(module: AuthModule(), isVisible: false),
  ];

  @override
  List<ModularRoute> get shellRoutes => [
    ModuleRoute(module: HomeModule(), isVisible: true),
    ModuleRoute(module: SettingsModule(), isVisible: true),
  ];
}
```

---

## Routing — GoRouterModular

Module-based routing wrapping GoRouter:

```dart
class HomeModule extends Module {
  @override
  CLRoute get moduleRoute => HomeRoutes.moduleRoute;

  @override
  List<ModularRoute> get routes => [
    ChildRoute(
      route: HomeRoutes.moduleRoute,
      builder: (context, state) => HomeView.builder(context),
    ),
  ];
}
```

---

## MVVM — CLBaseViewModel

```dart
class HomeViewModel extends CLBaseViewModel {
  List<Item> items = [];

  @override
  Future<void> initialize() async {
    setBusy(true);
    final response = await ApiManager.make(
      callName: 'getItems',
      apiUrl: ApiEndpoints.items,
      callType: ApiCallType.GET,
    );
    if (response.succeeded) {
      items = (response.jsonBody['data'] as List)
          .map((e) => Item.fromJson(e))
          .toList();
    }
    setBusy(false);
  }
}
```

---

## Theme

```dart
// Read anywhere in the widget tree
final theme = CLTheme.of(context);

Text('Hello', style: theme.heading1);
Container(color: theme.primary);
Icon(Icons.star, color: theme.warning);
```

Custom theme via `CLThemeProvider`:

```dart
ChangeNotifierProvider(
  create: (_) => CLThemeProvider(
    lightTheme: const LightModeTheme(
      primary: Color(0xFF6366F1),
      secondary: Color(0xFF4F46E5),
      success: Color(0xFF16A34A),
      danger: Color(0xFFDC2626),
    ),
    darkTheme: const DarkModeTheme(
      primary: Color(0xFF818CF8),
    ),
  ),
  child: MaterialApp(...),
)
```

---

## UI Components

| Category | Components |
|---|---|
| **Buttons** | `CLButton`, `CLSoftButton`, `CLGhostButton`, `CLOutlineButton` |
| **Forms** | `CLTextField`, `CLDropdown`, `CLCheckbox`, `CLFilePicker`, `CLDateInput`, `CLTimeInput` |
| **Data** | `PagedDataTable`, `CLPagination`, `CLMonthCalendar` |
| **Charts** | `CLBarChart`, `CLPieChart`, `CLSplineChart`, `CLAreaChart` |
| **Layout** | `CLCard`, `CLContainer`, `CLSectionCard`, `CLPageHeader`, `CLResponsiveGrid` |
| **Feedback** | `CLAlert`, `CLInfoBanner`, `CLShimmer`, `CLLifecycleProgress` |
| **Media** | `CLMediaViewer`, `CLPdfViewer`, `CLVideoPlayer` |
| **Complex** | `CLOrgChart`, `CLSurvey`, `CLAiAssistant`, `CLAnnouncement`, `CLFaq` |
| **Misc** | `CLTabs`, `CLPill`, `CLStatusBadge`, `CLRoleBadge`, `CLPopupMenu`, `Avatar` |

---

## AI Assistant

Built-in LLM-powered assistant with tool calling, voice input and navigation:

```dart
AiAssistantConfig(
  provider: OpenAiProvider(
    apiKey: 'YOUR_KEY',
    model: 'gpt-4o',
  ),
  assistantName: 'My Assistant',
  voiceEnabled: true,
  knownRoutes: ['home', 'settings'],
  navigateToRoute: (route) async => GoRouter.of(context).go('/$route'),
  globalContextProvider: () async => {
    'userName': authState.currentUser?.name,
    'locale': 'it_IT',
  },
)
```

---

## Local Development

Use the `cl` CLI tool to work on the library inside a consumer project:

```bash
# Bootstrap (first time in a new project)
curl -fsSL https://raw.githubusercontent.com/GenerazioneAI-SRL/genai_components/stable/cl -o ./cl && chmod +x ./cl

./cl dev              # Clone genai_components locally and link it
./cl push "msg"       # Commit + push changes to GitHub
./cl release patch    # Bump version → push → publish to pub.dev
./cl prod             # Remove local clone, use pub.dev version
./cl status           # Show current mode
```

---

## License

MIT — see [LICENSE](LICENSE)
