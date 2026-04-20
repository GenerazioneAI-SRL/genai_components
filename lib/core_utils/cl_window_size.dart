import 'package:flutter/widgets.dart';

/// Breakpoint enum per il design system CL.
///
/// Usare sempre la **larghezza della finestra**, non Platform.isIOS/isAndroid.
///
/// | Enum          | Range px          | Uso tipico      |
/// |---------------|-------------------|-----------------|
/// | compact       | < 600             | Mobile          |
/// | medium        | 600 – 900         | Tablet          |
/// | expanded      | 900 – 1280        | Laptop          |
/// | large         | 1280 – 1536       | Desktop         |
/// | extraLarge    | > 1536            | Desktop largo   |
enum CLWindowSize {
  compact,
  medium,
  expanded,
  large,
  extraLarge;

  factory CLWindowSize.fromWidth(double width) {
    if (width < 600) return CLWindowSize.compact;
    if (width < 900) return CLWindowSize.medium;
    if (width < 1280) return CLWindowSize.expanded;
    if (width < 1536) return CLWindowSize.large;
    return CLWindowSize.extraLarge;
  }

  /// `true` se ≥ questo livello (utile per comparazioni "almeno X").
  bool atLeast(CLWindowSize size) => index >= size.index;

  /// `true` se ≤ questo livello.
  bool atMost(CLWindowSize size) => index <= size.index;
}

// ── Context extension ─────────────────────────────────────────────────────

extension CLResponsiveContext on BuildContext {
  /// Window size corrente basata su [MediaQuery].
  CLWindowSize get windowSize =>
      CLWindowSize.fromWidth(MediaQuery.sizeOf(this).width);

  /// < 600px — layout mobile
  bool get isCompact => windowSize == CLWindowSize.compact;

  /// 600 – 900px — layout tablet
  bool get isMedium => windowSize == CLWindowSize.medium;

  /// ≥ 900px — layout desktop (expanded, large, extraLarge)
  bool get isExpanded => windowSize.index >= CLWindowSize.expanded.index;

  /// ≥ 1280px — desktop largo
  bool get isDesktopWide => windowSize.index >= CLWindowSize.large.index;
}

// ── CLResponsiveValue ─────────────────────────────────────────────────────

/// Seleziona un valore scalare in base al [CLWindowSize] corrente.
///
/// ```dart
/// final padding = CLResponsiveValue<double>(
///   compact: 16,
///   expanded: 24,
///   large: 32,
/// ).resolve(context);
/// ```
///
/// Se un breakpoint non è specificato, usa il valore del breakpoint
/// inferiore più vicino. [compact] è obbligatorio come fallback base.
class CLResponsiveValue<T> {
  const CLResponsiveValue({
    required this.compact,
    this.medium,
    this.expanded,
    this.large,
    this.extraLarge,
  });

  final T compact;
  final T? medium;
  final T? expanded;
  final T? large;
  final T? extraLarge;

  T resolve(BuildContext context) {
    final size = context.windowSize;
    return _forSize(size);
  }

  T _forSize(CLWindowSize size) {
    switch (size) {
      case CLWindowSize.extraLarge:
        if (extraLarge != null) return extraLarge as T;
        continue large;
      large:
      case CLWindowSize.large:
        if (large != null) return large as T;
        continue expanded;
      expanded:
      case CLWindowSize.expanded:
        if (expanded != null) return expanded as T;
        continue medium;
      medium:
      case CLWindowSize.medium:
        if (medium != null) return medium as T;
        continue compact;
      compact:
      case CLWindowSize.compact:
        return compact;
    }
  }
}

// ── CLResponsive widget ───────────────────────────────────────────────────

/// Renderizza builder diversi in base al [CLWindowSize] corrente.
///
/// ```dart
/// CLResponsive<Widget>(
///   compact: (ctx) => MobileLayout(),
///   medium:  (ctx) => TabletLayout(),
///   expanded: (ctx) => DesktopLayout(),
/// )
/// ```
///
/// Se un breakpoint non è specificato, usa il builder del breakpoint
/// inferiore più vicino. [compact] è obbligatorio.
class CLResponsive<T extends Widget> extends StatelessWidget {
  const CLResponsive({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
    this.large,
    this.extraLarge,
  });

  final T Function(BuildContext) compact;
  final T Function(BuildContext)? medium;
  final T Function(BuildContext)? expanded;
  final T Function(BuildContext)? large;
  final T Function(BuildContext)? extraLarge;

  @override
  Widget build(BuildContext context) {
    final size = context.windowSize;
    return _builderFor(size)(context);
  }

  T Function(BuildContext) _builderFor(CLWindowSize size) {
    switch (size) {
      case CLWindowSize.extraLarge:
        if (extraLarge != null) return extraLarge!;
        continue large;
      large:
      case CLWindowSize.large:
        if (large != null) return large!;
        continue expanded;
      expanded:
      case CLWindowSize.expanded:
        if (expanded != null) return expanded!;
        continue medium;
      medium:
      case CLWindowSize.medium:
        if (medium != null) return medium!;
        continue compact;
      compact:
      case CLWindowSize.compact:
        return compact;
    }
  }
}

