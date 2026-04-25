import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Visual variant for [GenaiCard] — v3 design system (§2.5).
///
/// v3 is **flat-by-default**: cards carry no shadow, just a 1 px hairline
/// border and 12 px radius. The `elevated` variant is kept for API parity
/// with v1/v2 but intentionally maps to the same flat look — elevation is
/// reserved for overlays (`layer2`+).
enum GenaiCardVariant {
  /// 1 px border, no shadow, `surfaceCard` (default).
  outlined,

  /// Same as [outlined] in v3 — flat aesthetic. Preserved for API parity.
  elevated,

  /// Subtle `surfaceHover` (`--neutral-soft`) fill, no border.
  filled,

  /// Outlined + hover: border strengthens to `ink` + `layer1Hover` shadow,
  /// focus ring when keyboard-focused.
  interactive,
}

/// Grouped content container — v3 design system (§4.2 `.card`).
///
/// **v3 spec:**
/// - Background: `surfaceCard` (`--panel`).
/// - Border: 1 px `--line`.
/// - Radius: `xl` (12).
/// - No shadow by default.
/// - Optional `header` slot mirrors the `.card-h` pattern (padding 16/20,
///   border-bottom `--line`, title 14/600). The body keeps v2-style interior
///   padding unless [padding] is overridden.
/// - `interactive` hover: `border → ink` + `layer1Hover` shadow.
class GenaiCard extends StatefulWidget {
  /// Main body content.
  final Widget? child;

  /// Optional header above [child]. When set and [useHeaderSlot] is true
  /// (default), renders with the v3 `.card-h` chrome: 16/20 padding and a
  /// hairline `border-bottom`. Passing [headerTitle] instead is a shortcut
  /// that builds the canonical title + optional subtitle + actions row.
  final Widget? header;

  /// Convenience: when set and [header] is null, renders a title row with
  /// the v3 card-header typography (14 / 600).
  final String? headerTitle;

  /// Convenience: smaller grey subtitle next to [headerTitle] (12 / ink-3).
  final String? headerSubtitle;

  /// Convenience: trailing actions for the header (right-aligned).
  final List<Widget> headerActions;

  /// When true (default) the [header] (or title-built header) renders with
  /// 16/20 padding and a bottom hairline; when false, the header is dropped
  /// straight into the body column and the [padding] applies to everything.
  final bool useHeaderSlot;

  /// Optional footer below [child], separated by `s12` gap (lives inside the
  /// body padding — it does not get the header-chrome bottom border).
  final Widget? footer;

  /// Interior body padding. Defaults to `context.spacing.cardPadding` (18).
  final EdgeInsetsGeometry? padding;

  /// Press handler. Required for [GenaiCardVariant.interactive].
  final VoidCallback? onTap;

  /// Variant.
  final GenaiCardVariant variant;

  /// Background override. Rarely needed — prefer variant.
  final Color? backgroundColor;

  /// When true and [variant] is `interactive`, the card is non-interactive
  /// and visually muted.
  final bool isDisabled;

  /// Accessible label. Required for `interactive`.
  final String? semanticLabel;

  const GenaiCard({
    super.key,
    this.child,
    this.header,
    this.headerTitle,
    this.headerSubtitle,
    this.headerActions = const [],
    this.useHeaderSlot = true,
    this.footer,
    this.padding,
    this.backgroundColor,
    this.variant = GenaiCardVariant.outlined,
  })  : onTap = null,
        isDisabled = false,
        semanticLabel = null;

  const GenaiCard.outlined({
    super.key,
    this.child,
    this.header,
    this.headerTitle,
    this.headerSubtitle,
    this.headerActions = const [],
    this.useHeaderSlot = true,
    this.footer,
    this.padding,
    this.backgroundColor,
  })  : onTap = null,
        isDisabled = false,
        semanticLabel = null,
        variant = GenaiCardVariant.outlined;

  const GenaiCard.elevated({
    super.key,
    this.child,
    this.header,
    this.headerTitle,
    this.headerSubtitle,
    this.headerActions = const [],
    this.useHeaderSlot = true,
    this.footer,
    this.padding,
    this.backgroundColor,
  })  : onTap = null,
        isDisabled = false,
        semanticLabel = null,
        variant = GenaiCardVariant.elevated;

  const GenaiCard.filled({
    super.key,
    this.child,
    this.header,
    this.headerTitle,
    this.headerSubtitle,
    this.headerActions = const [],
    this.useHeaderSlot = true,
    this.footer,
    this.padding,
    this.backgroundColor,
  })  : onTap = null,
        isDisabled = false,
        semanticLabel = null,
        variant = GenaiCardVariant.filled;

  const GenaiCard.interactive({
    super.key,
    this.child,
    this.header,
    this.headerTitle,
    this.headerSubtitle,
    this.headerActions = const [],
    this.useHeaderSlot = true,
    this.footer,
    this.padding,
    this.backgroundColor,
    this.isDisabled = false,
    this.semanticLabel,
    required this.onTap,
  }) : variant = GenaiCardVariant.interactive;

  @override
  State<GenaiCard> createState() => _GenaiCardState();
}

class _GenaiCardState extends State<GenaiCard> {
  final WidgetStatesController _states = WidgetStatesController();

  @override
  void initState() {
    super.initState();
    _states.addListener(_onStatesChanged);
  }

  void _onStatesChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _states.removeListener(_onStatesChanged);
    _states.dispose();
    super.dispose();
  }

  bool get _hovered => _states.value.contains(WidgetState.hovered);
  bool get _pressed => _states.value.contains(WidgetState.pressed);
  bool get _focused => _states.value.contains(WidgetState.focused);

  Widget? _buildHeader(BuildContext context) {
    if (widget.header != null) return widget.header;
    if (widget.headerTitle == null) return null;

    final ty = context.typography;
    final colors = context.colors;
    final spacing = context.spacing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Semantics(
          header: true,
          child: Text(
            widget.headerTitle!,
            style: ty.cardTitle.copyWith(color: colors.textPrimary),
          ),
        ),
        if (widget.headerSubtitle != null) ...[
          SizedBox(width: spacing.s4),
          Flexible(
            child: Text(
              widget.headerSubtitle!,
              style: ty.label.copyWith(color: colors.textTertiary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        if (widget.headerActions.isNotEmpty) ...[
          const Spacer(),
          Wrap(
            spacing: spacing.s6,
            runSpacing: spacing.s4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: widget.headerActions,
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;
    final elevation = context.elevation;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final motion = context.motion;

    final effectivePadding =
        widget.padding ?? EdgeInsets.all(spacing.cardPadding);
    final disabled =
        widget.variant == GenaiCardVariant.interactive && widget.isDisabled;

    Color bg;
    Border? border;
    List<BoxShadow> shadows = const [];

    switch (widget.variant) {
      case GenaiCardVariant.outlined:
      case GenaiCardVariant.elevated:
        bg = widget.backgroundColor ?? colors.surfaceCard;
        border = Border.all(color: colors.borderDefault);
        break;
      case GenaiCardVariant.filled:
        bg = widget.backgroundColor ?? colors.surfaceHover;
        break;
      case GenaiCardVariant.interactive:
        bg = widget.backgroundColor ??
            (disabled
                ? colors.surfaceCard
                : _pressed
                    ? colors.surfacePressed
                    : colors.surfaceCard);
        // Keep painted bounds stable on focus toggle: border width never
        // changes here. Focus ring is rendered above as a non-layout
        // overlay (Stack), so it never shifts hit-test bounds and never
        // triggers hover/focus oscillation.
        border = Border.all(
          color: _hovered
              ? colors.textPrimary // `border → ink` on hover per §4.2
              : colors.borderDefault,
        );
        if (!disabled && _hovered && !_pressed) {
          shadows = elevation.layer1Hover;
        }
        break;
    }

    final headerChild = _buildHeader(context);
    final showHeader = headerChild != null && widget.useHeaderSlot;

    final body = LayoutBuilder(
      builder: (context, constraints) {
        final bounded = constraints.maxHeight.isFinite;
        final children = <Widget>[];
        if (widget.child != null) {
          children.add(
            bounded ? Expanded(child: widget.child!) : widget.child!,
          );
        }
        if (widget.footer != null) {
          children.add(Padding(
            padding: EdgeInsets.only(top: spacing.s12),
            child: widget.footer!,
          ));
        }
        if (children.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: effectivePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
            children: children,
          ),
        );
      },
    );

    final columnChildren = <Widget>[];
    if (showHeader) {
      columnChildren.add(
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.s20,
            vertical: spacing.s16,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colors.borderDefault,
                width: sizing.dividerThickness,
              ),
            ),
          ),
          child: headerChild,
        ),
      );
    } else if (headerChild != null) {
      // Inline header (no chrome) — live inside body padding.
      columnChildren.add(Padding(
        padding: EdgeInsets.only(
          left: effectivePadding is EdgeInsets
              ? (effectivePadding).left
              : spacing.cardPadding,
          right: effectivePadding is EdgeInsets
              ? (effectivePadding).right
              : spacing.cardPadding,
          top: effectivePadding is EdgeInsets
              ? (effectivePadding).top
              : spacing.cardPadding,
          bottom: spacing.s12,
        ),
        child: headerChild,
      ));
    }
    columnChildren.add(body);

    Widget card = AnimatedContainer(
      duration: motion.hover.duration,
      curve: motion.hover.curve,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius.xl),
        border: border,
        boxShadow: shadows,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: columnChildren,
      ),
    );

    if (widget.variant == GenaiCardVariant.interactive) {
      Widget visual = card;
      if (_focused && !disabled) {
        visual = Stack(
          clipBehavior: Clip.none,
          children: [
            card,
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius.xl),
                    border: Border.all(
                      color: colors.borderFocus,
                      width: sizing.focusRingWidth,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }
      card = Opacity(
        opacity: disabled ? 0.6 : 1,
        child: Semantics(
          button: true,
          enabled: !disabled,
          label: widget.semanticLabel,
          child: FocusableActionDetector(
            enabled: !disabled,
            onShowHoverHighlight: (v) => _states.update(WidgetState.hovered, v),
            onShowFocusHighlight: (v) => _states.update(WidgetState.focused, v),
            mouseCursor:
                disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
            actions: {
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) {
                  if (!disabled) widget.onTap?.call();
                  return null;
                },
              ),
            },
            child: GestureDetector(
              onTapDown: disabled
                  ? null
                  : (_) => _states.update(WidgetState.pressed, true),
              onTapUp: disabled
                  ? null
                  : (_) => _states.update(WidgetState.pressed, false),
              onTapCancel: disabled
                  ? null
                  : () => _states.update(WidgetState.pressed, false),
              onTap: disabled ? null : widget.onTap,
              behavior: HitTestBehavior.opaque,
              child: visual,
            ),
          ),
        ),
      );
    }

    return card;
  }
}
