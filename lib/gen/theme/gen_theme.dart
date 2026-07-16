import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
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
  }) : _colorScheme = colorScheme;

  final Brightness brightness;
  final ShadColorScheme? _colorScheme;
  final BorderRadius radius;

  bool get _isDark => brightness == Brightness.dark;

  /// Skillera scheme by default; override by passing a custom [ShadColorScheme].
  ShadColorScheme get colorScheme => _colorScheme ?? genSkilleraColorScheme(_isDark);

  ShadThemeData toShad() => ShadThemeData(
    brightness: brightness,
    colorScheme: colorScheme,
    radius: radius,
    textTheme: ShadTextTheme(family: 'Inter'),
    // Input alti come i button. ShadInput di default è content-sized (più
    // basso di un ShadButton, che è fisso 40): gli diamo minHeight =
    // GenSizes.inputHeight (40, = buttonHeightDefault) così un GenInput
    // accanto a un GenButton combacia in altezza. Un input multiline cresce
    // comunque oltre 40. Per un input compatto (32) si passa un `constraints`
    // locale al singolo GenInput.
    //
    // L'altezza 40 la diamo col PADDING verticale, non stirando via minHeight:
    // ShadInput mette il contenuto in un BoxyColumn(mainAxisSize.min) con
    // mainAxisAlignment hardcoded, quindi quando il minHeight stira la cella il
    // testo si ancora in ALTO (non centrabile via alignment). Con padding
    // simmetrico il contenuto è centrato per costruzione: muted ha line-height
    // 20px → +10/+10 = 40, pari a buttonHeightDefault. minHeight resta come
    // floor di sicurezza (non stira più, il naturale è già 40).
    inputTheme: const ShadInputTheme(
      constraints: BoxConstraints(minHeight: GenSizes.inputHeight),
      padding: EdgeInsets.symmetric(horizontal: GenSizes.gapMd, vertical: 10),
    ),
    // OTP: ogni slot è un ShadInput che EREDITA il minHeight globale (40) qui
    // sopra; dentro la cella lo slot aggiunge però ~4px di chrome (bordo 1+1 +
    // padding decorativo 1+1), quindi l'input da 40 non ci sta in una cella da
    // 40 → overflow di 4px. ShadInputOTPTheme non espone `constraints` per
    // togliere quel minHeight allo slot, quindi diamo alla cella l'altezza che
    // accoglie input(40) + chrome(4). La cifra resta centrata (padding input
    // simmetrico dentro i 40 imposti dal minHeight).
    inputOTPTheme: const ShadInputOTPTheme(
      height: GenSizes.inputHeight + 4, // 44 = 40 (minHeight input) + 4 (chrome)
    ),
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
  Widget build(BuildContext context) => ShadTheme(data: data.toShad(), child: child);
}
