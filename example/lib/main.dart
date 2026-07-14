import 'package:flutter/material.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;
import 'package:provider/provider.dart';

import 'app/router.dart';
import 'app/theme_controller.dart';

/// Example: GenAdaptiveShell + go_router. Showcase componenti Gen (route
/// `/component`) + modulo "esempio" Users con navigazione a dettaglio
/// (`/users` → `/users/:id`). Header con theme playground ([ThemeController]).
/// Run: `flutter run -d macos`.
void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  /// Unica sorgente della config Gen (preset/radius/scale/color mode). Mutata dal
  /// customizer nell'header; qui la osserviamo per ricostruire il tema live.
  final _theme = ThemeController();
  final _router = buildRouter();

  @override
  void dispose() {
    _theme.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeController>.value(
      value: _theme,
      child: AnimatedBuilder(
        animation: _theme,
        builder: (context, _) {
          final data = _theme.dataFor(_theme.brightness);
          return GenApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Gen shell + primitives',
            themeMode: _theme.isDark ? ThemeMode.dark : ThemeMode.light,
            theme: _theme.dataFor(Brightness.light).toShad(),
            darkTheme: _theme.dataFor(Brightness.dark).toShad(),
            routerConfig: _router,
            // GenTheme avvolge tutto l'instradato; TextScaler applica la scala UI
            // del playground. Overlay root usano theme/darkTheme.
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(_theme.textScale)),
              child: GenTheme(data: data, child: child ?? const SizedBox.shrink()),
            ),
          );
        },
      ),
    );
  }
}
