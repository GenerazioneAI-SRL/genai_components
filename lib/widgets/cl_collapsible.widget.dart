import 'package:flutter/material.dart';
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

/// Sezione espandibile/collassabile con animazione. Alternativa più semplice
/// a `CustomExpansionTile` con stile coerente al tema.
///
/// Linguaggio Skillera Refined Editorial:
/// - header row con chevron rotante 180° (AnimatedRotation, easeInOutCubic)
/// - hover row su muted (sottile)
/// - border bottom 1px che appare a sezione aperta per separare dal contenuto
class CLCollapsible extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;
  final Widget? leading;

  const CLCollapsible({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    this.leading,
  });

  @override
  State<CLCollapsible> createState() => _CLCollapsibleState();
}

class _CLCollapsibleState extends State<CLCollapsible> {
  late bool _expanded;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  void _toggle() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);

    final Color headerBg = _hovering ? theme.muted : Colors.transparent;
    final Border? expandedBorder = _expanded
        ? Border(
            bottom: BorderSide(color: theme.borderColor, width: 1),
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: headerBg,
              borderRadius: BorderRadius.circular(CLSizes.radiusControl),
              border: expandedBorder,
            ),
            child: InkWell(
              onTap: _toggle,
              borderRadius: BorderRadius.circular(CLSizes.radiusControl),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: CLSizes.gapMd,
                  vertical: CLSizes.gapMd,
                ),
                child: Row(
                  children: [
                    if (widget.leading != null) ...[
                      widget.leading!,
                      const SizedBox(width: CLSizes.gapSm),
                    ],
                    Expanded(
                      child: Text(widget.title, style: theme.title),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOutCubic,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: CLSizes.iconSizeCompact + 2,
                        color: theme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: _expanded
                ? Padding(
                    key: const ValueKey('cl-collapsible-expanded'),
                    padding: const EdgeInsets.only(
                      top: CLSizes.gapMd,
                      bottom: CLSizes.gapMd,
                    ),
                    child: widget.child,
                  )
                : const SizedBox.shrink(key: ValueKey('cl-collapsible-collapsed')),
          ),
        ),
      ],
    );
  }
}
