import 'package:flutter/animation.dart';

/// Animation durations §3.2.4 / §13.4.
class GenaiDurations {
  GenaiDurations._();

  // Generic interaction
  static const Duration hover = Duration(milliseconds: 150);
  static const Duration pressIn = Duration(milliseconds: 100);
  static const Duration pressOut = Duration(milliseconds: 150);

  // Overlays
  static const Duration modalOpen = Duration(milliseconds: 200);
  static const Duration modalClose = Duration(milliseconds: 150);
  static const Duration drawerDesktop = Duration(milliseconds: 250);
  static const Duration drawerMobile = Duration(milliseconds: 300);
  static const Duration dropdownOpen = Duration(milliseconds: 150);
  static const Duration dropdownClose = Duration(milliseconds: 100);
  static const Duration tooltipDelay = Duration(milliseconds: 400);
  static const Duration tooltipOpen = Duration(milliseconds: 100);

  // Toast
  static const Duration toastIn = Duration(milliseconds: 200);
  static const Duration toastOut = Duration(milliseconds: 150);

  // Accordion
  static const Duration accordionOpen = Duration(milliseconds: 200);
  static const Duration accordionClose = Duration(milliseconds: 150);

  // Tabs / pages
  static const Duration tabSwitch = Duration(milliseconds: 150);
  static const Duration pageDesktop = Duration(milliseconds: 200);
  static const Duration pageMobile = Duration(milliseconds: 300);

  // Misc
  static const Duration sortArrow = Duration(milliseconds: 180);
  static const Duration checkboxCheck = Duration(milliseconds: 150);
  static const Duration toggleSlide = Duration(milliseconds: 200);
  static const Duration sidebarCollapse = Duration(milliseconds: 250);
  static const Duration skeletonShimmer = Duration(milliseconds: 1500);

  // Async UX
  static const Duration loadingDelay = Duration(milliseconds: 300);
  static const Duration autosaveDebounce = Duration(milliseconds: 1000);
  static const Duration searchDebounce = Duration(milliseconds: 300);

  // Toast lifetimes
  static const Duration toastSuccess = Duration(milliseconds: 4000);
  static const Duration toastInfo = Duration(milliseconds: 5000);
  static const Duration toastWarning = Duration(milliseconds: 6000);
  static const Duration toastWithAction = Duration(milliseconds: 8000);
}

/// Animation curves §3.2.5.
class GenaiCurves {
  GenaiCurves._();

  static const Curve open = Curves.easeOut;
  static const Curve close = Curves.easeIn;
  static const Curve page = Curves.easeInOutCubic;
  static const Curve toggle = Curves.easeInOut;
}

/// Press scale factors §3.2.2.
class GenaiInteraction {
  GenaiInteraction._();

  static const double pressScale = 0.97;
  static const double pressScaleStrong = 0.95;
  static const double disabledOpacity = 0.38;
  static const double loadingOpacity = 0.7;
}
