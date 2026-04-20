import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';
import '../cl_theme.dart';

class LogoWidget extends StatefulWidget {
  const LogoWidget({super.key, this.logoImagePath, this.height, this.dark = false, this.color});

  final String? logoImagePath;
  final double? height;
  final bool dark;
  final Color? color;

  @override
  State<LogoWidget> createState() => _LogoWidgetState();
}

class _LogoWidgetState extends State<LogoWidget> {
  /// Cache globale delle stringhe SVG originali (caricata una sola volta)
  static String? _lightSvgRaw;
  static String? _darkSvgRaw;
  static const _accentPlaceholder = '#0282c4';

  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _ensureLoaded();
  }

  @override
  void didUpdateWidget(covariant LogoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dark != widget.dark) _ensureLoaded();
  }

  Future<void> _ensureLoaded() async {
    final path = widget.dark ? 'assets/svgs/logo-dark.svg' : 'assets/svgs/logo-light.svg';
    try {
      if (widget.dark) {
        _darkSvgRaw ??= await rootBundle.loadString(path);
      } else {
        _lightSvgRaw ??= await rootBundle.loadString(path);
      }
    } catch (e) {
      // Asset non trovato — fallback a placeholder
      debugPrint('Logo asset non trovato: $path');
    }
    if (mounted && !_loaded) setState(() => _loaded = true);
  }

  static String _colorToSvgHex(Color color) {
    final r = (color.r * 255.0).round().clamp(0, 255);
    final g = (color.g * 255.0).round().clamp(0, 255);
    final b = (color.b * 255.0).round().clamp(0, 255);
    return '#${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final raw = widget.dark ? _darkSvgRaw : _lightSvgRaw;

    // Fallback a placeholder se l'SVG non è caricato
    if (raw == null) {
      final theme = CLTheme.of(context);
      final h = widget.height ?? 90;
      return SizedBox(
        height: h,
        width: h,
        child: Container(
          decoration: BoxDecoration(
            color: widget.color?.withValues(alpha: 0.1) ?? theme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: HugeIcon(
              icon: HugeIcons.strokeRounded1Circle,
              size: h * 0.5,
              color: widget.color ?? theme.primary,
            ),
          ),
        ),
      );
    }

    final accentColor = widget.color ?? CLTheme.of(context).primary;

    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: accentColor),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      builder: (context, animatedColor, _) {
        final hexColor = _colorToSvgHex(animatedColor ?? accentColor);
        final svgString = raw.replaceAll(_accentPlaceholder, hexColor);
        return SizedBox(
          height: widget.height ?? 90,
          child: SvgPicture.string(svgString, height: widget.height ?? 90),
        );
      },
    );
  }
}
