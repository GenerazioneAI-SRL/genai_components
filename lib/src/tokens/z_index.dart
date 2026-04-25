/// Global z-index / layering tokens — v3 design system.
///
/// Mirror of the v1 / v2 scale (re-declared in the v3 namespace so consumers
/// using `import as v3;` don't cross-reference sibling libraries). Forma LMS
/// reference HTML uses `z-index: 20` on the sticky topbar — matches the
/// `chrome` bucket here by overriding at the component level if needed.
class GenaiZIndex {
  GenaiZIndex._();

  /// Default content layer.
  static const int content = 0;

  /// Sticky elements inside a scrollable (table header, filter bar).
  static const int sticky = 10;

  /// Sidebar / AppBar level.
  static const int chrome = 100;

  /// Dropdown, popover, tooltip.
  static const int overlay = 200;

  /// Lateral drawer.
  static const int drawer = 300;

  /// Modal backdrop.
  static const int modalBackdrop = 400;

  /// Modal content above its backdrop.
  static const int modalContent = 401;

  /// Toast / snackbar.
  static const int toast = 500;

  /// Command palette.
  static const int commandPalette = 600;

  /// Global loader / blocking overlay.
  static const int loader = 700;

  /// Debug overlay — dev mode only.
  static const int debug = 999;
}
