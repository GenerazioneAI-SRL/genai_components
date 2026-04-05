import 'package:flutter/material.dart';

import '../cl_theme.dart';
import '../widgets/clock/digitalclock.dart';

class FooterLayout extends StatefulWidget {
  const FooterLayout({super.key});

  @override
  State<FooterLayout> createState() => _FooterLayoutState();
}

class _FooterLayoutState extends State<FooterLayout> {
  @override
  Widget build(BuildContext context) {
    return DigitalClock(
        showSeconds: true,
        isLive: true,
        textScaleFactor: 1,
        digitalClockTextColor: CLTheme.of(context).primaryText,
        decoration: BoxDecoration(color: CLTheme.of(context).primaryBackground, shape: BoxShape.rectangle, borderRadius: const BorderRadius.all(Radius.circular(15))),
        datetime: DateTime.now());
  }
}
