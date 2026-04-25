# Migration Guide: genai_components 4.4.x → 5.0.0

**Target version:** `5.0.0`
**Status:** Draft (initial version)
**Audience:** Maintainers and consumers of `genai_components` (notably `skillera_admin` and downstream apps).

---

## 1. Why this migration

- **Security hardening** — `HttpOverrides` accept-all certificate bypass removed from production paths; only debug-mode opt-in remains.
- **Performance** — Lazy module routing reduces cold-start cost; redirect operations consolidated to cut redundant rebuilds.
- **Maintainability** — `AppState` god class split into granular `ChangeNotifier`s (`UiToggleState`, `MaintenanceState`, `AppThemeState`, `HeaderVisibilityState`, ...). Easier to reason about, fewer spurious rebuilds.
- **API hygiene** — 13+ deprecated APIs from the 4.x line are removed; backward-compat shims phased out.

---

## 2. Find-and-replace table

| 4.4.x API (deprecated) | 5.0.0 replacement | Notes |
|---|---|---|
| `ApiManager.configure(baseUrl, apiVersion)` | `ApiManager.fromConfig(ApiConfig(baseUrl: ..., apiVersion: ...))` | Single config object; future-proof for additional fields (timeouts, interceptors). |
| `appState.aiChatOpen` (read/write) | `uiToggleState.aiChatOpen` | UI toggles split out of `AppState`. |
| `appState.maintenanceMode` | `maintenanceState.value` | Dedicated notifier; subscribe only where needed. |
| `appState.themeMode` | `appThemeState.themeMode` | Theme isolated from generic app state. |
| `context.read<ThemeProvider>()` | `context.read<AppThemeState>()` | `ThemeProvider` removed; `AppThemeState` is the canonical theme notifier. |
| `navigationState.headerTitleVisible.value = x` | `headerVisibilityState.value = x` (or `setHeaderTitleVisibility(x)`) | Header visibility extracted from `NavigationState`. |
| `Module.configureRoutes()` (sync) | `Module.configureRoutesAsync()` (async) | Enables lazy loading and async-resolved children. |
| `AiMessageRole`, `LlmRole` | `MessageRole` | Single unified enum across chat + LLM layers. |
| String tool names (`'click'`, `'type'`, ...) | `ToolName.click`, `ToolName.type`, ... | Type-safe; compile-time check for typos. |
| `HttpOverrides` accept-all (`badCertificateCallback => true`) | mkcert / proper dev cert, OR debug-mode-only opt-in via `kDebugMode` guard | 🔴 Removed in release builds. |

---

## 3. Step-by-step migration order

1. **Bind `AuthSingleton` at bootstrap** — before any `ApiManager` call. Required for tenant + token injection.
2. **Migrate `ApiManager.configure` → `ApiConfig`** — update bootstrap; remove old positional args.
3. **Switch to sub-notifiers** — replace `appState.*` reads/writes with `UiToggleState`, `MaintenanceState`, `AppThemeState`, `HeaderVisibilityState`. Register them in the provider tree.
4. **Replace `ThemeProvider` with `AppThemeState`** — update all `context.read`/`context.watch` call sites.
5. **Update `headerTitleVisible` call sites** — switch to `headerVisibilityState` (or the setter helper).
6. **Replace string tool names with `ToolName` enum** — search-and-replace literal strings; compiler will flag remaining ones.
7. **Migrate to `configureRoutesAsync`** — convert each `Module` override; mark `async`, return `Future<...>`.
8. **Test end-to-end** — `flutter build web`, `flutter build apk`, `flutter build ipa`. Smoke-test auth flow, AI chat, maintenance redirect, theme switching.

---

## 4. Breaking changes in 5.0.0

🔴 **Removed:**
- `HttpOverrides.badCertificateCallback` accept-all path (production builds).
- `Module.configureRoutes()` synchronous variant.

⚠️ **Behavior changes:**
- Router `refreshListenable` default narrowed to `authState` only. If you rely on theme/UI changes to refresh routing, register them explicitly.

---

## 5. New additive APIs (4.4.x) — adopt now

These shipped in 4.4.x as additive; adopting them before bumping to 5.0.0 reduces migration surface.

- `DisposableMixin` — centralizes `dispose()` boilerplate for controllers/streams.
- `FormValidationMixin` — declarative validators with composition.
- `safeCall<T>` extension — wraps async calls with consistent error handling.
- `CLDialog<T>` — base class for dialogs with typed result.
- `CLErrorPage` — drop-in error UI with retry hook.
- `QRCodeDialog`, `ConfirmationDialog`, `AssignEntitiesModal<T>` — common dialogs.
- `TableColumnBuilder` extension — fluent column definition.
- `context.isRouteDefined` / `context.goIfDefined` — safe navigation.
- New `CLSizes` tokens — replace ad-hoc paddings/radii.

---

## 6. Rollback plan

- **Tag both versions** — `git tag v4.4.x` and `git tag v5.0.0` in `genai_components` so consumers can pin.
- **Pubspec constraint** — keep consumer apps on `genai_components: ^4.3.0` (or `^4.4.0`) until migration tested in staging.
- **`./cl` script downgrade flow** — use `./cl dev` to clone locally, `./cl branch v4.4.x` to switch, `./cl prod` to revert override. For published rollback, bump consumer pubspec to last-known-good version and `flutter pub get`.

---

## 7. References

- Refactoring roadmap: [`docs/ROADMAP_REFACTORING.md`](../skillera_admin/docs/ROADMAP_REFACTORING.md) (in `skillera_admin`).
