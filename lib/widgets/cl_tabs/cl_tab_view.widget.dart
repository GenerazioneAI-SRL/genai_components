import 'package:flutter/material.dart';
import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import 'cl_tab_item.model.dart';

/// Tab view moderna con stile segmentato basata su [TabBar] nativo di Flutter.
///
/// [showDivider] → mostra/nasconde la linea sotto la tab bar
class CLTabView extends StatefulWidget {
  final List<CLTabItem> clTabItems;
  final String? title;
  final bool showDivider;

  const CLTabView(
      {super.key,
      required this.clTabItems,
      this.title,
      this.showDivider = false});

  @override
  State<CLTabView> createState() => _CLTabViewState();
}

class _CLTabViewState extends State<CLTabView>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: widget.clTabItems.length, vsync: this);
    _controller.addListener(_onTabChanged);
  }

  @override
  void didUpdateWidget(covariant CLTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clTabItems.length != widget.clTabItems.length) {
      _controller.removeListener(_onTabChanged);
      _controller.dispose();
      _controller =
          TabController(length: widget.clTabItems.length, vsync: this);
      _controller.addListener(_onTabChanged);
    }
  }

  void _onTabChanged() {
    if (!_controller.indexIsChanging) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTabChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final containerRadius = BorderRadius.circular(Sizes.borderRadius + 2);
    final indicatorRadius = BorderRadius.circular(Sizes.borderRadius);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Titolo opzionale ──
        if (widget.title != null) ...[
          Padding(
              padding: const EdgeInsets.only(bottom: Sizes.borderRadius),
              child: Text(widget.title!, style: theme.bodyLabel)),
        ],

        // ── Tab bar ──
        Container(
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: containerRadius,
            border: Border.all(color: theme.cardBorder.withValues(alpha: 0.8)),
          ),
          padding: const EdgeInsets.all(4),
          child: Theme(
            data: Theme.of(context)
                .copyWith(splashFactory: NoSplash.splashFactory),
            child: TabBar(
              controller: _controller,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: EdgeInsets.zero,
              indicator: BoxDecoration(
                color: theme.primaryBackground,
                borderRadius: indicatorRadius,
                border:
                    Border.all(color: theme.cardBorder.withValues(alpha: 0.65)),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryText.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              labelColor: theme.primaryText,
              unselectedLabelColor: theme.mutedForeground,
              labelStyle: theme.bodyText.override(fontWeight: FontWeight.w600),
              unselectedLabelStyle:
                  theme.bodyText.override(fontWeight: FontWeight.w500),
              dividerColor: Colors.transparent,
              dividerHeight: 0,
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 14),
              tabs: widget.clTabItems
                  .map(
                    (item) => Tab(
                      height: 40,
                      child: item.icon != null
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(item.icon, size: 16),
                                const SizedBox(width: 6),
                                Text(item.tabName),
                              ],
                            )
                          : Text(item.tabName),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),

        // ── Divider opzionale ──
        if (widget.showDivider) ...[
          const SizedBox(height: Sizes.borderRadius),
          Divider(color: theme.cardBorder, height: 1)
        ],

        const SizedBox(height: Sizes.borderRadius),

        // ── Contenuto (IndexedStack per mantenere lo stato) ──
        IndexedStack(
          index: _controller.index,
          children: List.generate(widget.clTabItems.length, (index) {
            return Visibility(
                visible: _controller.index == index,
                maintainState: true,
                child: widget.clTabItems[index].tabContent);
          }),
        ),
      ],
    );
  }
}
