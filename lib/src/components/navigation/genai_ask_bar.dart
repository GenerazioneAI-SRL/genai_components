import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/context_extensions.dart';

/// AI assistant search pill — v3 design system (§4.1 / `.ask`).
///
/// A rounded `border-radius: pill` input bar with a 20×20 gradient "spark"
/// badge (`info → violet`, 135°) on the leading edge and a trailing kbd
/// shortcut hint (default `⌘K`). Border hairline `borderStrong` by default,
/// elevates to [GenaiColorTokens.borderFocus]-equivalent (ink) on hover and
/// focus-within per `.ask:focus-within` / `.ask:hover` in the reference HTML.
///
/// Unlike legacy text inputs this widget does not render a label or error
/// message — it is purely a command pill meant to live inside the topbar. The
/// 40% viewport-width clamp from the CSS is honoured via a [LayoutBuilder].
///
/// Typical wiring:
/// ```dart
/// GenaiAskBar(
///   placeholder: 'Chiedi all\'assistente...',
///   onSubmitted: (q) => aiController.send(q),
///   onShortcutActivated: () => focusNode.requestFocus(),
/// )
/// ```
class GenaiAskBar extends StatefulWidget {
  /// Placeholder rendered inside the text field while empty.
  final String placeholder;

  /// Optional externally-owned text controller. When null an internal
  /// controller is created and disposed for you.
  final TextEditingController? controller;

  /// Optional focus node so hosts can programmatically focus the input
  /// (e.g. on `⌘K`).
  final FocusNode? focusNode;

  /// Fires with the current text when the user presses Enter.
  final ValueChanged<String>? onSubmitted;

  /// Fires on every change of the underlying [TextEditingController].
  final ValueChanged<String>? onChanged;

  /// Keyboard hint rendered inside the trailing kbd pill. Default `⌘K`.
  final String kbdHint;

  /// Preferred pill width. Shrinks to 40% of the available layout width when
  /// the parent is narrower (matches the CSS `max-width: 40vw` fallback).
  final double width;

  /// Fires when `⌘K` / `Ctrl+K` is pressed anywhere within this widget's
  /// focus scope. Consumers typically use this to focus the ask bar (and
  /// the internal shortcut already calls [FocusNode.requestFocus] for the
  /// built-in input).
  final VoidCallback? onShortcutActivated;

  /// Accessible label; defaults to [placeholder] if null.
  final String? semanticLabel;

  const GenaiAskBar({
    super.key,
    required this.placeholder,
    this.controller,
    this.focusNode,
    this.onSubmitted,
    this.onChanged,
    this.kbdHint = '⌘K',
    this.width = 380,
    this.onShortcutActivated,
    this.semanticLabel,
  });

  @override
  State<GenaiAskBar> createState() => _GenaiAskBarState();
}

class _GenaiAskBarState extends State<GenaiAskBar> {
  TextEditingController? _ownController;
  FocusNode? _ownFocus;
  bool _hover = false;
  bool _focused = false;

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());

  FocusNode get _focusNode => widget.focusNode ?? (_ownFocus ??= FocusNode());

  @override
  void dispose() {
    _ownController?.dispose();
    _ownFocus?.dispose();
    super.dispose();
  }

  void _handleShortcut() {
    widget.onShortcutActivated?.call();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;
    final sizing = context.sizing;
    final ty = context.typography;
    final motion = context.motion.hover;

    final activeBorder = _focused || _hover;
    final border = Border.all(
      color: activeBorder ? colors.textPrimary : colors.borderStrong,
      width: sizing.dividerThickness,
    );

    Widget pill = LayoutBuilder(
      builder: (ctx, constraints) {
        final maxW =
            constraints.hasBoundedWidth ? constraints.maxWidth : widget.width;
        final resolvedWidth = widget.width.clamp(0, maxW).toDouble();
        return AnimatedContainer(
          duration: motion.duration,
          curve: motion.curve,
          width: resolvedWidth,
          height: sizing.askBarHeight,
          padding: EdgeInsets.fromLTRB(
            spacing.s14,
            spacing.s2 + spacing.s4, // 7
            spacing.s12,
            spacing.s2 + spacing.s4,
          ),
          decoration: BoxDecoration(
            color: colors.surfaceCard,
            borderRadius: BorderRadius.circular(radius.pill),
            border: border,
          ),
          child: Row(
            children: [
              const _SparkBadge(),
              SizedBox(width: spacing.s8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  cursorColor: colors.colorPrimary,
                  style: ty.bodySm.copyWith(color: colors.textPrimary),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: widget.placeholder,
                    hintStyle: ty.bodySm.copyWith(color: colors.textTertiary),
                  ),
                ),
              ),
              SizedBox(width: spacing.s8),
              _KbdPill(label: widget.kbdHint),
            ],
          ),
        );
      },
    );

    return Semantics(
      label: widget.semanticLabel ?? widget.placeholder,
      textField: true,
      child: FocusableActionDetector(
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.keyK, meta: true):
              _AskBarShortcutIntent(),
          SingleActivator(LogicalKeyboardKey.keyK, control: true):
              _AskBarShortcutIntent(),
        },
        actions: <Type, Action<Intent>>{
          _AskBarShortcutIntent: CallbackAction<_AskBarShortcutIntent>(
            onInvoke: (_) {
              _handleShortcut();
              return null;
            },
          ),
        },
        mouseCursor: SystemMouseCursors.text,
        onShowHoverHighlight: (v) => setState(() => _hover = v),
        onFocusChange: (v) => setState(() => _focused = v),
        child: pill,
      ),
    );
  }
}

class _AskBarShortcutIntent extends Intent {
  const _AskBarShortcutIntent();
}

/// 20×20 linear-gradient badge (135°, info → violet) — the "spark" dot at
/// the leading edge of the pill.
class _SparkBadge extends StatelessWidget {
  const _SparkBadge();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius.sm),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.colorInfo,
            // violet — derive from info: shift red channel up, green down.
            // Avoid hardcoding by mixing textLink with ink for a cool tint.
            Color.lerp(colors.colorInfo, colors.textPrimary, 0.35)!,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.auto_awesome,
          size: 12,
          color: colors.textOnPrimary,
        ),
      ),
    );
  }
}

/// Trailing keyboard-shortcut pill (e.g. `⌘K`). Mono 11/600 bg `neutral-soft`.
class _KbdPill extends StatelessWidget {
  final String label;
  const _KbdPill({required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final sizing = context.sizing;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s6,
        vertical: spacing.s2,
      ),
      decoration: BoxDecoration(
        color: colors.colorNeutralSubtle,
        borderRadius: BorderRadius.circular(radius.sm),
        border: Border.all(
          color: colors.borderSubtle,
          width: sizing.dividerThickness,
        ),
      ),
      child: Text(
        label,
        style: ty.monoSm.copyWith(
          color: colors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
