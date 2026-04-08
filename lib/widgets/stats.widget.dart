import 'package:flutter/material.dart';

import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';
import 'cl_container.widget.dart';

class StatsWidget extends StatelessWidget {
  final Color color;
  final String label;
  final String body;
  final Function()? onTap;
  final IconData icon;

  const StatsWidget({super.key, required this.label, required this.body, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.translucent,
        child: CLContainer(
          showShadow: false,
          contentPadding: EdgeInsets.all(Sizes.padding),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(radius: Sizes.padding * 1.5, backgroundColor: color.withValues(alpha: 0.1), child: Icon(icon, color: color, size: Sizes.medium)),
                    SizedBox(height: Sizes.padding),
                    Text(
                      body,
                      style: CLTheme.of(context).heading2.override(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis, // Anche qui per evitare overflow
                    ),
                    SizedBox(height: Sizes.padding),
                    Text(
                      label,
                      style: CLTheme.of(context).bodyLabel,
                      overflow: TextOverflow.ellipsis, // Anche qui per evitare overflow
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
