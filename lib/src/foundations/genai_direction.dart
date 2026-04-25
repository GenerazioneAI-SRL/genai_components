import 'package:flutter/widgets.dart';

/// Sets the active text [TextDirection] for descendants — v3 design system
/// (Forma LMS).
///
/// Identical in behaviour to Flutter's [Directionality]; the wrapper exists
/// so consumers have a single, discoverable surface for RTL configuration
/// alongside the rest of the Genai components, matching shadcn's `Direction`
/// primitive.
///
/// Typical usage at app or page boundary:
///
/// ```dart
/// GenaiDirection(
///   direction: TextDirection.rtl,
///   child: MyArabicLayout(),
/// )
/// ```
///
/// Wrap individual subtrees (rather than the whole app) when only certain
/// regions should flip — for example a comments panel rendering Hebrew while
/// the rest of the dashboard is LTR.
class GenaiDirection extends StatelessWidget {
  /// Subtree that inherits the requested direction.
  final Widget child;

  /// Active text direction. Defaults to [TextDirection.ltr].
  final TextDirection direction;

  const GenaiDirection({
    super.key,
    required this.child,
    this.direction = TextDirection.ltr,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: direction,
      child: child,
    );
  }
}
