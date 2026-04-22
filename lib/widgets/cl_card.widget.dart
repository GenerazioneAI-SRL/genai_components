import 'package:flutter/material.dart';

import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

class CLCard extends StatefulWidget {
  final Color color;
  final String title;
  final String subtitle;
  final Function()? onTap;
  final IconData icon;
  final bool vertical;

  const CLCard({super.key, required this.color, required this.title, this.onTap, required this.icon, required this.vertical, required this.subtitle});

  @override
  State<CLCard> createState() => _CLCardState();
}

class _CLCardState extends State<CLCard> {
  @override
  Widget build(BuildContext context) {
    return widget.vertical
        ? Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: CLTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(Sizes.radiusCard),
              border: Border.all(color: CLTheme.of(context).cardBorder),
              boxShadow: CLTheme.of(context).cardShadow,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(Sizes.padding),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        padding: EdgeInsets.all(Sizes.padding),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(Sizes.borderRadius), color: widget.color),
                        child: Icon(
                          widget.icon,
                          color: Colors.white,
                          size: Sizes.large,
                        )),
                    SizedBox(
                      height: Sizes.padding,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          widget.title,
                          style: CLTheme.of(context).title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        Text(
                          widget.subtitle,
                          style: CLTheme.of(context).bodyLabel,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ))
        : Container(
            clipBehavior: Clip.antiAlias,
            padding: EdgeInsets.all(Sizes.padding),
            decoration: BoxDecoration(
              color: CLTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(Sizes.radiusCard),
              border: Border.all(color: CLTheme.of(context).cardBorder),
              boxShadow: CLTheme.of(context).cardShadow,
            ),
            child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      padding: EdgeInsets.all(Sizes.padding),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Sizes.borderRadius), color: widget.color),
                      child: Icon(
                        widget.icon,
                        color: Colors.white,
                        size: Sizes.large,
                      )),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: Sizes.padding, right: Sizes.padding / 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title, style: CLTheme.of(context).title, overflow: TextOverflow.ellipsis, // Anche qui per evitare overflow
                          ),
                          Text(
                            widget.subtitle, style: CLTheme.of(context).bodyLabel, overflow: TextOverflow.ellipsis, // Anche qui per evitare overflow
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
  }
}
