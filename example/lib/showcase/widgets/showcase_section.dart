import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

/// Standard v3 page chrome — scroll, max-width, page title.
class ShowcaseScaffold extends StatelessWidget {
  final List<Widget> children;
  final String? title;
  final String? description;

  const ShowcaseScaffold({
    super.key,
    required this.children,
    this.title,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    return Container(
      color: colors.surfacePage,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: context.pageMargin,
          vertical: spacing.s28,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null)
              Padding(
                padding: EdgeInsets.only(bottom: spacing.s4),
                child: Semantics(
                  header: true,
                  child: Text(
                    title!,
                    style: ty.pageTitle.copyWith(color: colors.textPrimary),
                  ),
                ),
              ),
            if (description != null)
              Padding(
                padding: EdgeInsets.only(bottom: spacing.s24),
                child: Text(
                  description!,
                  style: ty.bodySm.copyWith(color: colors.textSecondary),
                ),
              ),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// v3 section block wrapping [GenaiSection] with vertical rhythm.
class ShowcaseSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const ShowcaseSection({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.spacing.s32),
      child: GenaiSection(title: title, description: subtitle, child: child),
    );
  }
}

/// Label + children row used in variant listings.
class ShowcaseRow extends StatelessWidget {
  final String label;
  final List<Widget> children;
  final double spacing;

  const ShowcaseRow({
    super.key,
    required this.label,
    required this.children,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    final ty = context.typography;
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.spacing.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: ty.labelSm.copyWith(color: colors.textSecondary),
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: spacing,
              runSpacing: spacing,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}
