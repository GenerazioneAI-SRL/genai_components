import 'package:provider/provider.dart';
import '../cl_theme.dart';
import '../utils/providers/navigation.util.provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import 'constants/sizes.constant.dart';

class BreadcrumbsLayout extends StatefulWidget {
  const BreadcrumbsLayout({super.key});

  @override
  State<BreadcrumbsLayout> createState() => _BreadcrumbsLayoutState();
}

class _BreadcrumbsLayoutState extends State<BreadcrumbsLayout> {
  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationState>(
      builder: (context, navigationState, child) {
        return navigationState.breadcrumbs.isNotEmpty
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BreadCrumb(
                    items: navigationState.breadcrumbs.asMap().entries.map((entry) {
                      var segment = entry.value;
                      String label = segment.name;
                      bool isLast = navigationState.breadcrumbs.last.name == label;
                      Widget content;
                      if (isLast) {
                        content = Text(label, style: CLTheme.of(context).bodyText.merge(TextStyle(color: CLTheme.of(context).primary)));
                      } else if (!segment.isClickable) {
                        // Breadcrumb non cliccabile (modulo) in grigio
                        content = Text(label, style: CLTheme.of(context).bodyLabel.copyWith(color: CLTheme.of(context).secondaryText));
                      } else {
                        content = Text(label, style: CLTheme.of(context).bodyLabel);
                      }
                      return BreadCrumbItem(
                        content: content,
                        onTap: segment.isClickable && !isLast
                            ? () {
                                context.go(segment.path);
                              }
                            : null,
                      );
                    }).toList(),
                    divider: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, size: Sizes.small, color: CLTheme.of(context).secondaryText),
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink();
      },
    );
  }
}
