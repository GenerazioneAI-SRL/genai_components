import 'package:flutter/material.dart';

/// Logical window size buckets §10.2.
///
/// Always classify by **window width**, never by [Platform].
enum GenaiWindowSize {
  compact, // < 600
  medium, // 600 - 900
  expanded, // 900 - 1280
  large, // 1280 - 1536
  extraLarge; // > 1536

  static GenaiWindowSize fromWidth(double width) {
    if (width < 600) return GenaiWindowSize.compact;
    if (width < 900) return GenaiWindowSize.medium;
    if (width < 1280) return GenaiWindowSize.expanded;
    if (width < 1536) return GenaiWindowSize.large;
    return GenaiWindowSize.extraLarge;
  }
}

/// Static helpers for window-size resolution.
class GenaiResponsive {
  GenaiResponsive._();

  static GenaiWindowSize sizeOf(BuildContext context) => GenaiWindowSize.fromWidth(MediaQuery.sizeOf(context).width);

  /// True if the user's accessibility settings request reduced motion.
  static bool reducedMotion(BuildContext context) => MediaQuery.disableAnimationsOf(context);
}

/// Picks one of N builders based on the current [GenaiWindowSize].
///
/// [compact] is required as the smallest fallback. Larger sizes fall back to
/// the next-smaller defined builder.
class GenaiResponsiveLayout extends StatelessWidget {
  final WidgetBuilder compact;
  final WidgetBuilder? medium;
  final WidgetBuilder? expanded;
  final WidgetBuilder? large;
  final WidgetBuilder? extraLarge;

  const GenaiResponsiveLayout({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
    this.large,
    this.extraLarge,
  });

  @override
  Widget build(BuildContext context) {
    final size = GenaiResponsive.sizeOf(context);
    return _resolveBuilder(size)(context);
  }

  WidgetBuilder _resolveBuilder(GenaiWindowSize size) {
    switch (size) {
      case GenaiWindowSize.extraLarge:
        return extraLarge ?? large ?? expanded ?? medium ?? compact;
      case GenaiWindowSize.large:
        return large ?? expanded ?? medium ?? compact;
      case GenaiWindowSize.expanded:
        return expanded ?? medium ?? compact;
      case GenaiWindowSize.medium:
        return medium ?? compact;
      case GenaiWindowSize.compact:
        return compact;
    }
  }
}

/// Resolves a single typed value based on the current [GenaiWindowSize].
///
/// ```dart
/// final pad = GenaiResponsiveValue<double>(
///   compact: 16, expanded: 24, large: 32,
/// ).resolve(context);
/// ```
class GenaiResponsiveValue<T> {
  final T compact;
  final T? medium;
  final T? expanded;
  final T? large;
  final T? extraLarge;

  const GenaiResponsiveValue({
    required this.compact,
    this.medium,
    this.expanded,
    this.large,
    this.extraLarge,
  });

  T resolve(BuildContext context) {
    final size = GenaiResponsive.sizeOf(context);
    return resolveFor(size);
  }

  T resolveFor(GenaiWindowSize size) {
    switch (size) {
      case GenaiWindowSize.extraLarge:
        return extraLarge ?? large ?? expanded ?? medium ?? compact;
      case GenaiWindowSize.large:
        return large ?? expanded ?? medium ?? compact;
      case GenaiWindowSize.expanded:
        return expanded ?? medium ?? compact;
      case GenaiWindowSize.medium:
        return medium ?? compact;
      case GenaiWindowSize.compact:
        return compact;
    }
  }
}
