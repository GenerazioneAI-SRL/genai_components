import 'package:flutter/material.dart';

import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';

/// Decision-first hero card — v3 design system (§4.2).
///
/// The primary "next action" surface for Forma LMS dashboards. Matches the
/// `.focus` HTML block in the reference bundle.
///
/// Layout:
/// - Desktop (≥ expanded): two-column grid — 1fr content (padding 24/22,
///   column gap 14) + 320 px suggestion rail (padding 20/18, divided by a
///   left `borderDefault` edge).
/// - Compact: right rail collapses below the main content and loses the
///   divider edge.
///
/// Slots:
/// - [aiLabel] — uppercase AI caption (`ty.tiny` + info color).
/// - [title] — required widget; callers typically pass a `Text` or a
///   `RichText` with a highlighted span.
/// - [meta] — optional inline row of icon/text pairs under the title.
/// - [actions] — trailing button row (ink CTA + secondary + ghost).
/// - [suggestions] — [GenaiSuggestionItem]s stacked in the right column.
///
/// The card itself is `surfaceCard` bg, hairline border, `radius.hero` (14)
/// corners, no default shadow.
class GenaiFocusCard extends StatelessWidget {
  /// Uppercase AI caption above the title. Usually something like
  /// "Prossima azione consigliata".
  final String aiLabel;

  /// Hero title. Callers may pass a `RichText` with a gradient-accented span.
  final Widget title;

  /// Optional meta row (icon + bold value widgets).
  final List<Widget>? meta;

  /// Optional action buttons row.
  final List<Widget>? actions;

  /// Optional list of [GenaiSuggestionItem]-style widgets for the right rail.
  final List<Widget>? suggestions;

  /// Optional heading for the suggestion rail. Defaults to
  /// "Suggeriti per te".
  final String suggestionsHeading;

  /// Accessibility label for the whole card. Defaults to [aiLabel].
  final String? semanticLabel;

  const GenaiFocusCard({
    super.key,
    required this.aiLabel,
    required this.title,
    this.meta,
    this.actions,
    this.suggestions,
    this.suggestionsHeading = 'Suggeriti per te',
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;
    final windowSize = context.windowSize;
    final isDesktop = windowSize.index >= GenaiWindowSize.expanded.index;
    final hasRail = suggestions != null && suggestions!.isNotEmpty;

    final leftColumn = _buildLeftColumn(context);
    final rightColumn = hasRail ? _buildRightColumn(context, isDesktop) : null;

    final Widget body;
    if (!hasRail) {
      body = leftColumn;
    } else if (isDesktop) {
      body = IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: leftColumn),
            SizedBox(width: 320, child: rightColumn!),
          ],
        ),
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [leftColumn, rightColumn!],
      );
    }

    return Semantics(
      container: true,
      label: semanticLabel ?? aiLabel,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(radius.hero),
          border: Border.all(color: colors.borderDefault),
        ),
        clipBehavior: Clip.antiAlias,
        child: body,
      ),
    );
  }

  Widget _buildLeftColumn(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        spacing.s24,
        spacing.s24, // 24 ≈ spec 22 (nearest token; 22 is not in scale).
        spacing.s24,
        spacing.s24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // AI label row — sparkle dot + tiny uppercase caption.
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: spacing.s10,
                height: spacing.s10,
                decoration: BoxDecoration(
                  color: colors.colorInfoSubtle,
                  borderRadius: BorderRadius.circular(radius.pill),
                  border: Border.all(color: colors.colorInfo, width: 1.5),
                ),
              ),
              SizedBox(width: spacing.s8),
              Flexible(
                child: Text(
                  aiLabel.toUpperCase(),
                  style: ty.tiny.copyWith(
                    color: colors.colorInfoText,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.s14),
          // Title — whatever the caller provides, re-styled to focusTitle if
          // it's a plain Text via DefaultTextStyle.
          DefaultTextStyle.merge(
            style: ty.focusTitle.copyWith(color: colors.textPrimary),
            child: title,
          ),
          if (meta != null && meta!.isNotEmpty) ...[
            SizedBox(height: spacing.s14),
            Wrap(
              spacing: spacing.s14,
              runSpacing: spacing.s8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: meta!
                  .map(
                    (w) => DefaultTextStyle.merge(
                      style: ty.label.copyWith(color: colors.textSecondary),
                      child: IconTheme.merge(
                        data: IconThemeData(
                          color: colors.textSecondary,
                          size: context.sizing.iconSize,
                        ),
                        child: w,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (actions != null && actions!.isNotEmpty) ...[
            SizedBox(height: spacing.s20),
            Wrap(
              spacing: spacing.s8,
              runSpacing: spacing.s8,
              children: actions!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRightColumn(BuildContext context, bool isDesktop) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfacePage,
        border: isDesktop
            ? Border(left: BorderSide(color: colors.borderDefault))
            : Border(top: BorderSide(color: colors.borderDefault)),
      ),
      padding: EdgeInsets.fromLTRB(
        spacing.s20,
        spacing.s18,
        spacing.s20,
        spacing.s20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            suggestionsHeading.toUpperCase(),
            style: ty.tiny.copyWith(color: colors.textTertiary),
          ),
          SizedBox(height: spacing.s12),
          for (var i = 0; i < suggestions!.length; i++) ...[
            if (i > 0) SizedBox(height: spacing.s8),
            suggestions![i],
          ],
        ],
      ),
    );
  }
}
