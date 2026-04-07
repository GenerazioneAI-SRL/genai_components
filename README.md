# CL Components

UI component library for Flutter projects. Works out of the box with sensible defaults, fully customizable via `CLThemeProvider`.

## Installation

```yaml
dependencies:
  genai_components: ^2.0.0
```

Or from GitHub:

```yaml
dependencies:
  genai_components:
    git:
      url: git@github.com:generazione-ai/genai_components.git
      ref: stable
```

## Quick Start

Import and use — no setup required, default theme is applied automatically:

```dart
import 'package:genai_components/genai_components.dart';

// Usa i componenti direttamente, il tema default viene usato
CLButton(text: 'Click me', onPressed: () {});
```

## Custom Theme

Wrap il tuo widget tree con `CLThemeProvider` per personalizzare i colori:

```dart
import 'package:genai_components/genai_components.dart';
import 'package:provider/provider.dart';

ChangeNotifierProvider(
  create: (_) => CLThemeProvider(
    lightTheme: const LightModeTheme(
      primary: Color(0xFFFF5722),
      secondary: Color(0xFFE64A19),
      success: Color(0xFF4CAF50),
      // ... tutti i colori sono opzionali, hanno default sensati
    ),
    darkTheme: const DarkModeTheme(
      primary: Color(0xFFFF7043),
      secondary: Color(0xFFFF5722),
    ),
  ),
  child: MaterialApp(...),
)
```

### Fully Custom Theme (subclass)

Per controllo totale, estendi `CLTheme`:

```dart
class MyAppLightTheme extends CLTheme {
  const MyAppLightTheme() : super(
    primary: Color(0xFFFF5722),
    secondary: Color(0xFFE64A19),
    alternate: Color(0xFFE8EBF0),
    primaryText: Color(0xFF2E2E38),
    secondaryText: Color(0xFF6B7080),
    primaryBackground: Color(0xFFFAF9F7),
    secondaryBackground: Color(0xFFFFFFFF),
    tertiaryBackground: Color(0xFFF0F1F4),
    success: Color(0xFF16A34A),
    warning: Color(0xFFD97706),
    danger: Color(0xFFDC2626),
    info: Color(0xFF0C8EC7),
    borderColor: Color(0xFFE8EBF0),
    background: Color(0xFFFAF9F7),
    fillColor: Color(0xFFF0F1F4),
  );

  // Override typography if needed
  @override
  Typography get typography => MyCustomTypography(this);
}
```

### Access Theme in Widgets

```dart
final theme = CLTheme.of(context);

Text('Hello', style: theme.heading1);
Container(color: theme.primary);
```

### Update Theme at Runtime

```dart
final provider = Provider.of<CLThemeProvider>(context, listen: false);
provider.updateThemes(
  light: const LightModeTheme(primary: Color(0xFF9C27B0)),
);
```

## Local Development

Use the `cl` CLI tool in your project:

```bash
./cl dev     # Link local package
./cl prod    # Switch back to GitHub
./cl push "msg"  # Push changes
./cl pull    # Pull latest
```
