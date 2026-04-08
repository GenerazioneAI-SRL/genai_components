# Changelog

## 4.0.6

- **Widgets:** Updated 9 components


## 4.0.5

- **Widgets:** Updated CLFile_picker, Flutter Responsive Flex Grid, Survey


## 4.0.4

- **Widgets:** Updated Dropdown State, CLFile_picker


## 4.0.3

- **Core:** Updated Changelog Md
- **Package:** Updated Pubspec Yaml


## 4.0.2

- **Core:** Updated Changelog Md
- **Package:** Updated Pubspec Yaml


## 4.0.1

- **Core:** Updated Readme Md, Cl


## 4.0.0

- **Core:** Updated Changelog Md
- **Package:** Updated Pubspec Yaml


## 3.0.2

- **Core:** Updated Changelog Md


## 3.0.0

- **Breaking:** Renamed package from `cl_components` to `genai_components`
- Updated all internal imports to use `genai_components`
- Refactored as standalone library for pub.dev publication
- **CLApp:** Generic app bootstrap with `CLAppConfig` — OIDC, routing, providers out of the box
- **CLTheme:** Light/dark mode with per-module color overrides via `ModuleThemeProvider`
- **GoRouterModular:** Custom routing system wrapping GoRouter — `Module`, `CLRoute`, `ChildRoute`, `ModuleRoute`, `ShellModularRoute`
- **ApiManager:** HTTP wrapper with auto Bearer token, tenant header, multipart upload
- **CLBaseViewModel:** Stacked MVVM base class with page actions, breadcrumbs, lifecycle
- **Layout:** `AppLayout`, `MenuLayout`, `HeaderLayout`, `FooterLayout`, `BreadcrumbsLayout`
- **Charts:** Generic `CLBarChart<T>`, `CLPieChart<T>`, `CLSplineChart<T>`, `CLSplineAreaChart<T>`, `CLAreaChart<T>` with `CLChartSeries<T>`
- **Widgets:** `CLButton`, `CLTextField`, `CLDropdown`, `CLPagination`, `PagedDataTable`, `CLOrgChart`, `CLSurvey`, `CLAiAssistant`, and 30+ reusable components
- **Auth:** Abstract `CLAuthState`, `CLUserInfo`, `CLTenant` interfaces
- **Providers:** `AppState`, `ErrorState`, `ThemeProvider`, `NavigationState`
- **Core models:** `BaseModel`, `Media`, `City`, `Country`, `Province`, `PageAction`

## 1.0.0

- Initial release — internal package via GitHub
