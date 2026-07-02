import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/cl_theme.dart';
import 'package:genai_components/widgets/buttons/cl_ghost_button.widget.dart';
import 'package:responsive_framework/responsive_framework.dart';

const theme = CLTheme.light;

// NB: il build di CLGhostButton chiama ResponsiveBreakpoints.of(context),
// quindi l'harness DEVE fornire l'ancestor via MaterialApp.builder.
Future<TextButton> _pump(WidgetTester tester,
    CLGhostButton Function(BuildContext) build) async {
  await tester.pumpWidget(MaterialApp(
    theme: ThemeData(brightness: Brightness.light),
    builder: (context, child) => ResponsiveBreakpoints.builder(
      child: child!,
      breakpoints: const [
        Breakpoint(start: 0, end: 800, name: MOBILE),
        Breakpoint(start: 801, end: double.infinity, name: DESKTOP),
      ],
    ),
    home: Scaffold(body: Builder(builder: (context) => build(context))),
  ));
  return tester.widget<TextButton>(find.byType(TextButton));
}

void main() {
  testWidgets('danger: hover/press tintati col tono (fix bug color ignorato)',
      (tester) async {
    final btn = await _pump(
        tester,
        (context) => CLGhostButton.danger(
            text: 'Elimina', onTap: () {}, context: context));
    final hoverBg = btn.style!.backgroundColor!.resolve({WidgetState.hovered});
    final pressBg = btn.style!.backgroundColor!.resolve({WidgetState.pressed});
    final fg = btn.style!.foregroundColor!.resolve({});
    expect(hoverBg, theme.danger.withValues(alpha: theme.opacitySoft));
    expect(pressBg, theme.danger.withValues(alpha: theme.opacityMuted));
    expect(fg, theme.danger);
  });

  testWidgets('secondary: resta neutro (hover=accent, fg=primaryText)',
      (tester) async {
    final btn = await _pump(
        tester,
        (context) => CLGhostButton.secondary(
            text: 'Annulla', onTap: () {}, context: context));
    final hoverBg = btn.style!.backgroundColor!.resolve({WidgetState.hovered});
    final fg = btn.style!.foregroundColor!.resolve({});
    expect(hoverBg, theme.accent);
    expect(fg, theme.primaryText);
  });

  testWidgets('foregroundColor override vince sul tono', (tester) async {
    final btn = await _pump(
        tester,
        (context) => CLGhostButton.danger(
            text: 'X',
            onTap: () {},
            context: context,
            foregroundColor: Colors.purple));
    expect(btn.style!.foregroundColor!.resolve({}), Colors.purple);
  });
}
