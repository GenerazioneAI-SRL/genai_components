# Changelog

## 5.8.0

- **Foundation:** Added CLToneStyle recipe (single resolver for tone × variant × interaction-state colors) and CLSurface primitive (card/soft/recessed/panel/tint surface presets)
- **Buttons:** CLGhostButton now reads its `color` param via CLToneStyle — tone factories (primary/success/info/warning/danger) render tinted hover/press/foreground; `secondary` and raw constructor stay neutral (fix ignored `color`, same bug class as 5.7.3 outline/soft fix); icons/spinner now follow the foreground color (neutral ghost icons shift from secondaryText to primaryText, and a caller-supplied foregroundColor now recolors the icon too)
- **Fixes:** hardcoded disabled opacities in CLIconButton (0.5) and CLPagination (0.4) replaced with `theme.opacityDisabled`

## 5.7.3

- **Foundation:** Added CLPressable shared interaction primitive (hover/press/focus/disabled + keyboard activation)
- **Buttons:** CLActionChip and CLActionText migrated onto CLPressable; CLOutlineButton and CLSoftButton tone factories now render colored (fix ignored `color` param — secondary and raw constructor stay neutral)
- **Widgets:** Updated Cl Tab View, Cl Nav List, Cl Nav Rail

## 5.7.2

- **Widgets:** Updated 18 components
- **Layout:** Updated Sizes Constant
- **Theme:** Updated Cl Theme
- **Core:** Updated Changelog Md


## 5.7.1

- **Widgets:** Updated 18 components (incl. Paged Datatable Controller, Paged Datatable State)
- **Layout:** Updated Sizes Constant
- **Theme:** Updated Cl Theme


## 5.7.0

- **Widgets:** Updated 22 components
- **Theme:** Updated Cl Theme
- **Core:** Updated Genai Components
- **Tests:** Updated Cl Adaptive Shell Frosted Test


## 5.6.0

- **Widgets:** Updated 5 components


## 5.5.1

- **Widgets:** Updated 4 components


## 5.5.0

- **Widgets:** CLEntityTabs gained `groupByDomain` — when true, entries are grouped by `EntityDomain` into one tab per domain (Anagrafica, Risorse Umane, ...), each tab stacking that domain's cards vertically. Keeps the tab count bounded by the number of domains (max 6) instead of the number of cards; moving a card across domains (via `EntityTab.domain`) re-homes it to the right tab. Default false (one tab per entry, unchanged).


## 5.4.0

- **Widgets:** Added CLEntityTabs — domain-tagged, gated tab registry over CLTabView. Declares a list of `EntityTab` (key/label/`EntityDomain`/icon/guard/lazy builder), filters by per-tab `guard`, and renders the survivors through CLTabView preserving lazy content mount.
- **Enums:** Added EntityDomain (`id`, `hr`, `atlas`, `lms`, `certet`, `bill`) with it_IT labels and a per-domain theme accent color.


## 5.3.0

- **Widgets:** Updated 90 components
- **Layout:** Updated Sizes Constant
- **Theme:** Updated Cl Theme
- **Core:** Updated Genai Components


## 5.2.5

- **Widgets:** Updated 14 components
- **Core:** Updated Genai Components


## 5.2.4

- **Widgets:** Updated CLCommand, CLDropdown, Dropdown State


## 5.2.3

- **Widgets:** Updated 12 components
- **Layout:** Updated Sizes Constant
- **Theme:** Updated Cl Theme


## 5.2.2

- **Widgets:** Updated 14 components
- **Layout:** Updated Sizes Constant
- **Theme:** Updated Cl Theme


## 5.2.1

- **Widgets:** Updated Paged Datatable


## 5.2.0

- **Widgets:** Updated 16 components
- **Theme:** Updated Cl Theme
- **Core:** Updated Changelog Md, Genai Components
- **Package:** Updated Pubspec Yaml


## 5.1.0

**Behavior change — compact by default.** Buttons, text fields and dropdowns now render
in compact size (`isCompact: true`) by default; pass `isCompact: false` to keep the
previous standard height. Signatures are otherwise unchanged.

- **Theme (new tokens):** `buttonHeightDefault` (40), `buttonHeightCompact` (32),
  `buttonHeightLarge` (48), `inputHeight` (40), `inputHeightCompact` (32) — overridable getters.
- **Buttons:** `CLButton`, `CLOutlineButton`, `CLSoftButton`, `CLGhostButton` support
  `isCompact` (default `true`); heights/paddings read from theme tokens; icon-only compact 16px.
- **CLTextField:** `isCompact` on constructor + factories (textArea excluded); compact uses
  `inputHeightCompact`, cursor 16, line-height 1.0, compact icons, full-height clear tap target.
- **CLDropdown:** `isCompact` on all factories; dense menu items, compact search field,
  computed search bar height, compact chevron/clear icons, compact multi-select checkbox.
- **Overlays:** `CLPopupSurface` now provides a transparent `Material` ancestor (fixes
  "No Material widget found" for InkWell/ListTile content); exported scrim tokens
  `kCLModalScrim`/`kCLPopoverScrim` applied consistently to sheets, dialogs and popovers;
  `CLSheet` uses `radiusModal`, theme `cardShadow` and border.
- **Example:** new `Compact` gallery screen comparing standard vs compact.


## 5.0.0

**BREAKING — the package is now a pure UI kit.** The application framework has been removed:
apps own their bootstrap, routing, state, auth and HTTP layers.

- **Removed (framework):** `CLApp`, `CLAppConfig`, `GoRouterModular` (Module, ChildRoute, CLRoute,
  RouteRegistry, transitions), `ApiManager`/`ApiConfig`, auth (`CLAuthState`, `AuthSingleton`,
  `CLUserInfo`, `CLTenant`), providers (`AppState`, `NavigationState`, `ErrorState`,
  `ThemeProvider`, `UiToggleState`, `MaintenanceState`, `RefreshState`, `AppThemeState`,
  `HeaderVisibilityState`), `CLBaseViewModel` + core utils, layout shell (`CLAppLayout`,
  `CLMenuLayout`, `CLHeaderLayout`, breadcrumbs, notifications panel), `ErrorPage`,
  `CLPageHeader` + `PageAction`.
- **Removed (app domain):** `City`, `Province`, `Country`, `State`, `Tolerances` models,
  `CityGraphData`/`UserGraphData`, `FiscalCodeCalculator`, `ModuleThemeProvider`.
- **Theme (breaking):** `CLTheme` no longer has `idColor`/`certColor`/`hrColor`/`lmsColor`;
  `CLTheme.of` resolves `CLThemeProvider` only (ModuleThemeProvider fallback removed).
- **Theme (new):** 19 dimensional design tokens on `CLTheme` as overridable getters
  (`gapXs..gap4Xl`, `pagePadX`, `pageTop`, `radiusChip/Control/Surface/Card/Modal/Pill`,
  `iconSizeCompact/Default/Large`). Widgets read spacing/radius/icon sizes from the theme;
  `CLSizes` stays unchanged for backward compatibility.
- **Widgets:** `CLTextField` now supports optional `fillColor` in `time`, `date`, `dateTime`,
  `month`, and `year` factory constructors (retrocompatible).
- **Deps removed:** go_router, stacked, flutter_breadcrumb, http_parser, package_info_plus.
- **Example:** rewritten as a pure widget gallery (no framework).

## 4.2.28

- **Widgets:** Updated 15 components
- **Theme:** Updated Cl Theme
- **Core:** Updated Genai Components


## 4.2.27

- **Widgets:** Updated 9 components
- **Layout:** Updated 4 components
- **Router:** Updated Module
- **API:** Updated Api Manager
- **Providers:** Updated Navigation Util Provider
- **Core:** Updated Genai Components


## 4.2.26

- **Widgets:** Updated 96 components
- **Layout:** Updated 9 components
- **Router:** Updated 8 components
- **API:** Updated Api Config, Api Manager
- **Theme:** Updated Cl Theme
- **Providers:** Updated 10 components
- **Core:** Updated 13 components
- **Package:** Updated Pubspec Yaml
- **Tests:** Updated Disposable Mixin Test, Form Validation Mixin Test


## 4.2.25

- **Widgets:** Updated 19 components
- **Layout:** Updated App Layout, Sizes Constant, Menu Layout
- **Theme:** Updated Cl Theme
- **Core:** Updated Genai Components, Podfile Lock


## 4.2.24

- **Widgets:** Updated CLSummary_stat_card, CLTab_view
- **Core:** Updated Genai Components


## 4.2.23

- **Widgets:** Updated CLDropdown, Dropdown State


## 4.2.22

- **Widgets:** Updated 9 components
- **Layout:** Updated Header Layout, Menu Layout
- **Router:** Updated Child Route
- **Providers:** Updated App State
- **Core:** Updated 31 components
- **Package:** Updated Pubspec Yaml
- **Example:** Updated 4 components


## 4.2.21

- **Widgets:** Updated 22 components
- **Layout:** Updated Sizes Constant
- **Theme:** Updated Cl Theme
- **Core:** Updated Genai Components

## 4.2.20

- **Widgets:** Updated 4 components
- **Layout:** Updated App Layout, Header Layout, Menu Layout
- **Providers:** Updated App State
- **Core:** Updated Cl App, Cl App Config, Genai Components

## 4.2.19

- **Layout:** Updated App Layout

## 4.2.18

- **Router:** Updated Module Route
- **Core:** Updated Changelog Md
- **Package:** Updated Pubspec Yaml

## 4.2.17

- **Router:** Updated Module Route

## 4.2.16

- **Widgets:** Updated CLMonth_calendar
- **Layout:** Updated App Layout, Menu Layout
- **API:** Updated Api Manager
- **Core:** Updated Cl App, Cl App Config

## 4.2.15

- **Widgets:** Updated CLMedia_attach, CLText_field, CLUniversal_repeatable
- **Core:** Updated Changelog Md, Cl, Genai Components
- **Package:** Updated Pubspec Yaml

## 4.2.14

- **Widgets:** Updated CLMedia_attach, CLText_field, CLUniversal_repeatable
- **Core:** Updated Changelog Md, Cl, Genai Components
- **Package:** Updated Pubspec Yaml

## 4.2.13

- **Widgets:** Updated CLMedia_attach, CLText_field, CLUniversal_repeatable
- **Core:** Updated Changelog Md, Cl, Genai Components
- **Package:** Updated Pubspec Yaml

## 4.2.12

- **Widgets:** Updated CLMedia_attach, CLText_field, CLUniversal_repeatable
- **Core:** Updated Changelog Md, Genai Components
- **Package:** Updated Pubspec Yaml

## 4.2.11

- **Widgets:** Updated CLMedia_attach, CLText_field, CLUniversal_repeatable
- **Core:** Updated Genai Components

## 4.2.10

- **Layout:** Updated 4 components
- **Core:** Updated Cl App, Cl App Config, Genai Components

## 4.2.9

- **Widgets:** Updated Analogclock, Clockpainter, Digitalclock
- **Layout:** Updated Footer Layout
- **Core:** Updated Genai Components

## 4.2.8

- **Widgets:** Updated 21 components
- **Layout:** Updated 5 components
- **Router:** Updated Go Router Modular Configure, Module, Transition
- **API:** Updated Api Manager
- **Providers:** Updated App State, Theme Provider
- **Models:** Updated 12 components
- **Core:** Updated 6 components
- **Package:** Updated Pubspec Yaml

## 4.2.7

- **Widgets:** Updated CLPopup_menu
- **Layout:** Updated Header Layout
- **Core:** Updated Changelog Md
- **Package:** Updated Pubspec Yaml

## 4.2.6

- **Widgets:** Updated CLPopup_menu
- **Layout:** Updated Header Layout

## 4.2.5

- **Widgets:** Updated CLPage_header
- **Layout:** Updated App Layout, Header Layout, Menu Layout
- **Theme:** Updated Cl Theme

## 4.2.4

- **Widgets:** Updated Paged Datatable, Paged Datatable Rows, Paged Datatable State
- **Layout:** Updated Menu Layout

## 4.2.3

- **Layout:** Updated Menu Layout
- **Router:** Updated Module, Module Route

## 4.2.2

- **Widgets:** Updated 7 components

## 4.2.1

- **Package:** Updated Pubspec Yaml

## 4.1.1

- Maintenance and minor improvements

## 4.1.0

- Maintenance and minor improvements

## 4.0.7

- **Widgets:** Updated Paged Datatable, Paged Datatable Menu
- **Core:** Updated Changelog Md
- **Package:** Updated Pubspec Yaml

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
- **GoRouterModular:** Custom routing system wrapping GoRouter — `Module`, `CLRoute`, `ChildRoute`,
  `ModuleRoute`, `ShellModularRoute`
- **ApiManager:** HTTP wrapper with auto Bearer token, tenant header, multipart upload
- **CLBaseViewModel:** Stacked MVVM base class with page actions, breadcrumbs, lifecycle
- **Layout:** `AppLayout`, `MenuLayout`, `HeaderLayout`, `FooterLayout`, `BreadcrumbsLayout`
- **Charts:** Generic `CLBarChart<T>`, `CLPieChart<T>`, `CLSplineChart<T>`, `CLSplineAreaChart<T>`,
  `CLAreaChart<T>` with `CLChartSeries<T>`
- **Widgets:** `CLButton`, `CLTextField`, `CLDropdown`, `CLPagination`, `PagedDataTable`,
  `CLOrgChart`, `CLSurvey`, `CLAiAssistant`, and 30+ reusable components
- **Auth:** Abstract `CLAuthState`, `CLUserInfo`, `CLTenant` interfaces
- **Providers:** `AppState`, `ErrorState`, `ThemeProvider`, `NavigationState`
- **Core models:** `BaseModel`, `Media`, `City`, `Country`, `Province`, `PageAction`

## 1.0.0

- Initial release — internal package via GitHub
