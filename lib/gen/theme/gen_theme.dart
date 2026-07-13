import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:genai_components/gen/theme/gen_icon.dart';
import 'package:genai_components/gen/theme/gen_sizes.dart';

/// Skillera (CL) palette as a [ShadColorScheme]. Single source for brand tokens:
/// blu #0C8EC7 + neutri. Edit here (or pass a custom scheme to [GenThemeData]).
ShadColorScheme genSkilleraColorScheme(bool dark) {
  const white = Color(0xFFFFFFFF);
  if (dark) {
    const surface = Color(0xFF232427);
    const text = Color(0xFFE8E8EC);
    const grey = Color(0xFF2E2F33);
    return const ShadColorScheme(
      background: surface,
      foreground: text,
      card: surface,
      cardForeground: text,
      popover: surface,
      popoverForeground: text,
      primary: Color(0xFF3BA8D8),
      primaryForeground: white,
      secondary: grey,
      secondaryForeground: Color(0xFFFAFAFA),
      muted: grey,
      mutedForeground: Color(0xFF9A9DA4),
      accent: grey,
      accentForeground: Color(0xFFFAFAFA),
      destructive: Color(0xFFF87171),
      destructiveForeground: white,
      border: Color(0xFF313338),
      input: Color(0xFF313338),
      ring: Color(0xFF3BA8D8),
      selection: Color(0x403BA8D8),
    );
  }
  const grey = Color(0xFFECEEF0);
  const greyFg = Color(0xFF31302E);
  return const ShadColorScheme(
    background: white,
    foreground: Color(0xF2000000),
    card: white,
    cardForeground: Color(0xF2000000),
    popover: white,
    popoverForeground: Color(0xF2000000),
    primary: Color(0xFF0C8EC7),
    primaryForeground: white,
    secondary: grey,
    secondaryForeground: greyFg,
    muted: grey,
    mutedForeground: Color(0xFF9CA0A6),
    accent: grey,
    accentForeground: greyFg,
    destructive: Color(0xFFDC2626),
    destructiveForeground: white,
    border: Color(0x1A000000),
    input: Color(0x1A000000),
    ring: Color(0xFF097FE8),
    selection: Color(0x400C8EC7),
  );
}

/// The single customization surface for a project. Holds the token config and
/// produces a [ShadThemeData] under the hood — the Gen* primitives (typedefs
/// over Shad*) read it via the [GenTheme] ancestor.
class GenThemeData {
  const GenThemeData({
    this.brightness = Brightness.light,
    ShadColorScheme? colorScheme,
    // Default = radiusControl (12): stesso raggio dei controlli della tabella,
    // così ShadInput/ShadButton e la tabella condividono un'unica scala radius.
    this.radius = const BorderRadius.all(Radius.circular(GenSizes.radiusControl)),
    this.iconWeight = 400,
  }) : _colorScheme = colorScheme;

  final Brightness brightness;
  final ShadColorScheme? _colorScheme;
  final BorderRadius radius;

  /// Peso Lucide di default per [GenIcon] (100–600, clampato). Applicato via
  /// [GenIconTheme] montato da [GenTheme].
  final int iconWeight;

  bool get _isDark => brightness == Brightness.dark;

  /// Skillera scheme by default; override by passing a custom [ShadColorScheme].
  ShadColorScheme get colorScheme => _colorScheme ?? genSkilleraColorScheme(_isDark);

  ShadThemeData toShad() => ShadThemeData(
        brightness: brightness,
        colorScheme: colorScheme,
        radius: radius,
        textTheme: ShadTextTheme(family: 'Inter'),
      );

  factory GenThemeData.light() => const GenThemeData(brightness: Brightness.light);
  factory GenThemeData.dark() => const GenThemeData(brightness: Brightness.dark);
}

/// Wrap a project (or subtree) in this to apply the Gen theme. Internally it is
/// a [ShadTheme]; the Gen* primitives inherit tokens from it.
class GenTheme extends StatelessWidget {
  const GenTheme({super.key, required this.data, required this.child});

  final GenThemeData data;
  final Widget child;

  static ShadThemeData of(BuildContext context) => ShadTheme.of(context);

  @override
  Widget build(BuildContext context) => ShadTheme(
        data: data.toShad(),
        child: GenIconTheme(weight: data.iconWeight, child: child),
      );
}
