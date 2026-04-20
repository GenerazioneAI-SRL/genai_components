import 'package:flutter/material.dart';

import '../../foundations/animations.dart';
import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

class GenaiAccordionItem {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget content;
  final bool initiallyExpanded;

  const GenaiAccordionItem({
    required this.title,
    this.subtitle,
    this.leadingIcon,
    required this.content,
    this.initiallyExpanded = false,
  });
}

/// Collapsible accordion (§6.3.3).
class GenaiAccordion extends StatefulWidget {
  final List<GenaiAccordionItem> items;
  final bool allowMultiple;

  const GenaiAccordion({
    super.key,
    required this.items,
    this.allowMultiple = false,
  });

  @override
  State<GenaiAccordion> createState() => _GenaiAccordionState();
}

class _GenaiAccordionState extends State<GenaiAccordion> {
  late Set<int> _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = {
      for (var i = 0; i < widget.items.length; i++)
        if (widget.items[i].initiallyExpanded) i,
    };
  }

  void _toggle(int i) {
    setState(() {
      if (_expanded.contains(i)) {
        _expanded.remove(i);
      } else {
        if (!widget.allowMultiple) _expanded.clear();
        _expanded.add(i);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(radius.md),
        border: Border.all(color: colors.borderDefault),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < widget.items.length; i++) ...[
            if (i > 0) Container(height: 1, color: colors.borderDefault),
            _AccordionTile(
              item: widget.items[i],
              expanded: _expanded.contains(i),
              onToggle: () => _toggle(i),
            ),
          ],
        ],
      ),
    );
  }
}

class _AccordionTile extends StatelessWidget {
  final GenaiAccordionItem item;
  final bool expanded;
  final VoidCallback onToggle;
  const _AccordionTile({
    required this.item,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                if (item.leadingIcon != null) ...[
                  Icon(item.leadingIcon, size: 18, color: colors.textSecondary),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(item.title, style: ty.label.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600)),
                      if (item.subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(item.subtitle!, style: ty.bodySm.copyWith(color: colors.textSecondary)),
                        ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: GenaiDurations.accordionOpen,
                  child: Icon(LucideIcons.chevronDown, size: 18, color: colors.textSecondary),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: GenaiDurations.accordionOpen,
          curve: GenaiCurves.open,
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: expanded ? double.infinity : 0),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: item.content,
            ),
          ),
        ),
      ],
    );
  }
}
