# CL Components

UI component library for Generazione AI Flutter projects.

## Installation

```yaml
dependencies:
  cl_components:
    git:
      url: git@github.com:generazione-ai/cl_components.git
      ref: stable
```

## Usage

```dart
import 'package:cl_components/cl_components.dart';

// Wrap your app with CLThemeProvider
CLThemeProvider(
  theme: CLThemeData(
    primary: Color(0xFF0C8EC7),
  ),
  child: MaterialApp(...),
)
```

## Local Development

Use the `cl` CLI tool in your project:

```bash
./cl dev     # Link local package
./cl prod    # Switch back to GitHub
./cl push "msg"  # Push changes
./cl pull    # Pull latest
```
